
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
        _setOwner(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
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

pragma solidity ^0.8.0;


abstract contract ERC20Burnable is Context, ERC20 {
    function burn(uint256 amount) public virtual {
        _burn(_msgSender(), amount);
    }

    function burnFrom(address account, uint256 amount) public virtual {
        uint256 currentAllowance = allowance(account, _msgSender());
        require(currentAllowance >= amount, "ERC20: burn amount exceeds allowance");
        unchecked {
            _approve(account, _msgSender(), currentAllowance - amount);
        }
        _burn(account, amount);
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
        require(operator != _msgSender(), "ERC721: approve to caller");

        _operatorApprovals[_msgSender()][operator] = approved;
        emit ApprovalForAll(_msgSender(), operator, approved);
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


abstract contract ERC721Burnable is Context, ERC721 {
    function burn(uint256 tokenId) public virtual {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721Burnable: caller is not owner nor approved");
        _burn(tokenId);
    }
}// MIT

pragma solidity ^0.8.0;


interface IERC721Enumerable is IERC721 {
    function totalSupply() external view returns (uint256);

    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256 tokenId);

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

library Base64 {
    string internal constant TABLE = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';

    function encode(bytes memory data) internal pure returns (string memory) {
        if (data.length == 0) return '';
        
        string memory table = TABLE;

        uint256 encodedLen = 4 * ((data.length + 2) / 3);

        string memory result = new string(encodedLen + 32);

        assembly {
            mstore(result, encodedLen)
            
            let tablePtr := add(table, 1)
            
            let dataPtr := data
            let endPtr := add(dataPtr, mload(data))
            
            let resultPtr := add(result, 32)
            
            for {} lt(dataPtr, endPtr) {}
            {
               dataPtr := add(dataPtr, 3)
               
               let input := mload(dataPtr)
               
               mstore(resultPtr, shl(248, mload(add(tablePtr, and(shr(18, input), 0x3F)))))
               resultPtr := add(resultPtr, 1)
               mstore(resultPtr, shl(248, mload(add(tablePtr, and(shr(12, input), 0x3F)))))
               resultPtr := add(resultPtr, 1)
               mstore(resultPtr, shl(248, mload(add(tablePtr, and(shr( 6, input), 0x3F)))))
               resultPtr := add(resultPtr, 1)
               mstore(resultPtr, shl(248, mload(add(tablePtr, and(        input,  0x3F)))))
               resultPtr := add(resultPtr, 1)
            }
            
            switch mod(mload(data), 3)
            case 1 { mstore(sub(resultPtr, 2), shl(240, 0x3d3d)) }
            case 2 { mstore(sub(resultPtr, 1), shl(248, 0x3d)) }
        }
        
        return result;
    }
}// MIT
pragma solidity ^0.8.4;






contract SettlementsLegacy is
    ERC721,
    ERC721Enumerable,
    ReentrancyGuard,
    Ownable
{
    constructor() ERC721("Settlements", "STL") {}

    struct Attributes {
        uint8 size;
        uint8 spirit;
        uint8 age;
        uint8 resource;
        uint8 morale;
        uint8 government;
        uint8 turns;
    }

    string[] private _sizes = [
        "Camp",
        "Hamlet",
        "Village",
        "Town",
        "District",
        "Precinct",
        "Capitol",
        "State"
    ];
    string[] private _spirits = ["Earth", "Fire", "Water", "Air", "Astral"];
    string[] private _ages = [
        "Ancient",
        "Classical",
        "Medieval",
        "Renaissance",
        "Industrial",
        "Modern",
        "Information",
        "Future"
    ];
    string[] private _resources = [
        "Iron",
        "Gold",
        "Silver",
        "Wood",
        "Wool",
        "Water",
        "Grass",
        "Grain"
    ];
    string[] private _morales = [
        "Expectant",
        "Enlightened",
        "Dismissive",
        "Unhappy",
        "Happy",
        "Undecided",
        "Warring",
        "Scared",
        "Unruly",
        "Anarchist"
    ];
    string[] private _governments = [
        "Democracy",
        "Communism",
        "Socialism",
        "Oligarchy",
        "Aristocracy",
        "Monarchy",
        "Theocracy",
        "Colonialism",
        "Dictatorship"
    ];
    string[] private _realms = [
        "Genesis",
        "Valhalla",
        "Keskella",
        "Shadow",
        "Plains",
        "Ends"
    ];

    mapping(uint256 => Attributes) private attrIndex;

    function indexFor(string memory input, uint256 length)
        internal
        pure
        returns (uint256)
    {
        return uint256(keccak256(abi.encodePacked(input))) % length;
    }

    function _getRandomSeed(uint256 tokenId, string memory seedFor)
        internal
        view
        returns (string memory)
    {
        return
            string(
                abi.encodePacked(
                    seedFor,
                    Strings.toString(tokenId),
                    block.timestamp,
                    block.difficulty
                )
            );
    }

    function generateAttribute(string memory salt, string[] memory items)
        internal
        pure
        returns (uint8)
    {
        return uint8(indexFor(string(salt), items.length));
    }

    function _makeParts(uint256 tokenId)
        internal
        view
        returns (string[15] memory)
    {
        string[15] memory parts;
        parts[
            0
        ] = '<svg xmlns="http://www.w3.org/2000/svg" preserveAspectRatio="xMinYMin meet" viewBox="0 0 350 350"><style>.txt { fill: black; font-family: monospace; font-size: 12px;}</style><rect width="100%" height="100%" fill="white" /><text x="10" y="20" class="txt">';
        parts[1] = _sizes[attrIndex[tokenId].size];
        parts[2] = '</text><text x="10" y="40" class="txt">';
        parts[3] = _spirits[attrIndex[tokenId].spirit];
        parts[4] = '</text><text x="10" y="60" class="txt">';
        parts[5] = _ages[attrIndex[tokenId].age];
        parts[6] = '</text><text x="10" y="80" class="txt">';
        parts[7] = _resources[attrIndex[tokenId].resource];
        parts[8] = '</text><text x="10" y="100" class="txt">';
        parts[9] = _morales[attrIndex[tokenId].morale];
        parts[10] = '</text><text x="10" y="120" class="txt">';
        parts[11] = _governments[attrIndex[tokenId].government];
        parts[12] = '</text><text x="10" y="140" class="txt">';
        parts[13] = _realms[attrIndex[tokenId].turns];
        parts[14] = "</text></svg>";
        return parts;
    }

    function _makeAttributeParts(string[15] memory parts)
        internal
        pure
        returns (string[15] memory)
    {
        string[15] memory attrParts;
        attrParts[0] = '[{ "trait_type": "Size", "value": "';
        attrParts[1] = parts[1];
        attrParts[2] = '" }, { "trait_type": "Spirit", "value": "';
        attrParts[3] = parts[3];
        attrParts[4] = '" }, { "trait_type": "Age", "value": "';
        attrParts[5] = parts[5];
        attrParts[6] = '" }, { "trait_type": "Resource", "value": "';
        attrParts[7] = parts[7];
        attrParts[8] = '" }, { "trait_type": "Morale", "value": "';
        attrParts[9] = parts[9];
        attrParts[10] = '" }, { "trait_type": "Government", "value": "';
        attrParts[11] = parts[11];
        attrParts[12] = '" }, { "trait_type": "Realm", "value": "';
        attrParts[13] = parts[13];
        attrParts[14] = '" }]';
        return attrParts;
    }

    function tokenURI(uint256 tokenId)
        public
        view
        virtual
        override
        returns (string memory)
    {
        require(_exists(tokenId), "Settlement does not exist");

        string[15] memory parts = _makeParts(tokenId);
        string[15] memory attributesParts = _makeAttributeParts(parts);

        string memory output = string(
            abi.encodePacked(
                parts[0],
                parts[1],
                parts[2],
                parts[3],
                parts[4],
                parts[5],
                parts[6],
                parts[7],
                parts[8]
            )
        );
        output = string(
            abi.encodePacked(
                output,
                parts[9],
                parts[10],
                parts[11],
                parts[12],
                parts[13],
                parts[14]
            )
        );

        string memory atrrOutput = string(
            abi.encodePacked(
                attributesParts[0],
                attributesParts[1],
                attributesParts[2],
                attributesParts[3],
                attributesParts[4],
                attributesParts[5],
                attributesParts[6],
                attributesParts[7],
                attributesParts[8]
            )
        );
        atrrOutput = string(
            abi.encodePacked(
                atrrOutput,
                attributesParts[9],
                attributesParts[10],
                attributesParts[11],
                attributesParts[12],
                attributesParts[13],
                attributesParts[14]
            )
        );

        string memory json = Base64.encode(
            bytes(
                string(
                    abi.encodePacked(
                        '{"name": "Settlement #',
                        Strings.toString(tokenId),
                        '", "description": "Settlements are a turn based civilisation simulator stored entirely on chain, go forth and conquer.", "image": "data:image/svg+xml;base64,',
                        Base64.encode(bytes(output)),
                        '"',
                        ',"attributes":',
                        atrrOutput,
                        "}"
                    )
                )
            )
        );
        output = string(
            abi.encodePacked("data:application/json;base64,", json)
        );

        return output;
    }

    function randomiseAttributes(uint256 tokenId, uint8 turn) internal {
        attrIndex[tokenId].size = generateAttribute(
            _getRandomSeed(tokenId, "size"),
            _sizes
        );
        attrIndex[tokenId].spirit = generateAttribute(
            _getRandomSeed(tokenId, "spirit"),
            _spirits
        );
        attrIndex[tokenId].age = generateAttribute(
            _getRandomSeed(tokenId, "age"),
            _ages
        );
        attrIndex[tokenId].resource = generateAttribute(
            _getRandomSeed(tokenId, "resource"),
            _resources
        );
        attrIndex[tokenId].morale = generateAttribute(
            _getRandomSeed(tokenId, "morale"),
            _morales
        );
        attrIndex[tokenId].government = generateAttribute(
            _getRandomSeed(tokenId, "government"),
            _governments
        );
        attrIndex[tokenId].turns = turn;
    }

    function randomise(uint256 tokenId) public nonReentrant {
        require(
            _exists(tokenId) &&
                msg.sender == ownerOf(tokenId) &&
                attrIndex[tokenId].turns < 5,
            "Settlement turns over"
        );
        randomiseAttributes(
            tokenId,
            uint8(SafeMath.add(attrIndex[tokenId].turns, 1))
        );
    }

    function settle(uint256 tokenId) public nonReentrant {
        require(
            !_exists(tokenId) && tokenId > 0 && tokenId < 9901,
            "Settlement id is invalid"
        );
        randomiseAttributes(tokenId, 0);
        _safeMint(msg.sender, tokenId);
    }

    function settleForOwner(uint256 tokenId) public nonReentrant onlyOwner {
        require(
            !_exists(tokenId) && tokenId > 9900 && tokenId < 10001,
            "Settlement id is invalid"
        );
        randomiseAttributes(tokenId, 0);
        _safeMint(msg.sender, tokenId);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal override(ERC721, ERC721Enumerable) {
        super._beforeTokenTransfer(from, to, tokenId);
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
pragma solidity >= 0.4.22 <0.9.0;

library console {
	address constant CONSOLE_ADDRESS = address(0x000000000000000000636F6e736F6c652e6c6f67);

	function _sendLogPayload(bytes memory payload) private view {
		uint256 payloadLength = payload.length;
		address consoleAddress = CONSOLE_ADDRESS;
		assembly {
			let payloadStart := add(payload, 32)
			let r := staticcall(gas(), consoleAddress, payloadStart, payloadLength, 0, 0)
		}
	}

	function log() internal view {
		_sendLogPayload(abi.encodeWithSignature("log()"));
	}

	function logInt(int p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(int)", p0));
	}

	function logUint(uint p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint)", p0));
	}

	function logString(string memory p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string)", p0));
	}

	function logBool(bool p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool)", p0));
	}

	function logAddress(address p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address)", p0));
	}

	function logBytes(bytes memory p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes)", p0));
	}

	function logBytes1(bytes1 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes1)", p0));
	}

	function logBytes2(bytes2 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes2)", p0));
	}

	function logBytes3(bytes3 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes3)", p0));
	}

	function logBytes4(bytes4 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes4)", p0));
	}

	function logBytes5(bytes5 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes5)", p0));
	}

	function logBytes6(bytes6 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes6)", p0));
	}

	function logBytes7(bytes7 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes7)", p0));
	}

	function logBytes8(bytes8 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes8)", p0));
	}

	function logBytes9(bytes9 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes9)", p0));
	}

	function logBytes10(bytes10 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes10)", p0));
	}

	function logBytes11(bytes11 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes11)", p0));
	}

	function logBytes12(bytes12 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes12)", p0));
	}

	function logBytes13(bytes13 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes13)", p0));
	}

	function logBytes14(bytes14 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes14)", p0));
	}

	function logBytes15(bytes15 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes15)", p0));
	}

	function logBytes16(bytes16 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes16)", p0));
	}

	function logBytes17(bytes17 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes17)", p0));
	}

	function logBytes18(bytes18 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes18)", p0));
	}

	function logBytes19(bytes19 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes19)", p0));
	}

	function logBytes20(bytes20 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes20)", p0));
	}

	function logBytes21(bytes21 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes21)", p0));
	}

	function logBytes22(bytes22 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes22)", p0));
	}

	function logBytes23(bytes23 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes23)", p0));
	}

	function logBytes24(bytes24 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes24)", p0));
	}

	function logBytes25(bytes25 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes25)", p0));
	}

	function logBytes26(bytes26 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes26)", p0));
	}

	function logBytes27(bytes27 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes27)", p0));
	}

	function logBytes28(bytes28 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes28)", p0));
	}

	function logBytes29(bytes29 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes29)", p0));
	}

	function logBytes30(bytes30 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes30)", p0));
	}

	function logBytes31(bytes31 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes31)", p0));
	}

	function logBytes32(bytes32 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes32)", p0));
	}

	function log(uint p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint)", p0));
	}

	function log(string memory p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string)", p0));
	}

	function log(bool p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool)", p0));
	}

	function log(address p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address)", p0));
	}

	function log(uint p0, uint p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint)", p0, p1));
	}

	function log(uint p0, string memory p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string)", p0, p1));
	}

	function log(uint p0, bool p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool)", p0, p1));
	}

	function log(uint p0, address p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address)", p0, p1));
	}

	function log(string memory p0, uint p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint)", p0, p1));
	}

	function log(string memory p0, string memory p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string)", p0, p1));
	}

	function log(string memory p0, bool p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool)", p0, p1));
	}

	function log(string memory p0, address p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address)", p0, p1));
	}

	function log(bool p0, uint p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint)", p0, p1));
	}

	function log(bool p0, string memory p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string)", p0, p1));
	}

	function log(bool p0, bool p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool)", p0, p1));
	}

	function log(bool p0, address p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address)", p0, p1));
	}

	function log(address p0, uint p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint)", p0, p1));
	}

	function log(address p0, string memory p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string)", p0, p1));
	}

	function log(address p0, bool p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool)", p0, p1));
	}

	function log(address p0, address p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address)", p0, p1));
	}

	function log(uint p0, uint p1, uint p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,uint)", p0, p1, p2));
	}

	function log(uint p0, uint p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,string)", p0, p1, p2));
	}

	function log(uint p0, uint p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,bool)", p0, p1, p2));
	}

	function log(uint p0, uint p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,address)", p0, p1, p2));
	}

	function log(uint p0, string memory p1, uint p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,uint)", p0, p1, p2));
	}

	function log(uint p0, string memory p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,string)", p0, p1, p2));
	}

	function log(uint p0, string memory p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,bool)", p0, p1, p2));
	}

	function log(uint p0, string memory p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,address)", p0, p1, p2));
	}

	function log(uint p0, bool p1, uint p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,uint)", p0, p1, p2));
	}

	function log(uint p0, bool p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,string)", p0, p1, p2));
	}

	function log(uint p0, bool p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,bool)", p0, p1, p2));
	}

	function log(uint p0, bool p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,address)", p0, p1, p2));
	}

	function log(uint p0, address p1, uint p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,uint)", p0, p1, p2));
	}

	function log(uint p0, address p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,string)", p0, p1, p2));
	}

	function log(uint p0, address p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,bool)", p0, p1, p2));
	}

	function log(uint p0, address p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,address)", p0, p1, p2));
	}

	function log(string memory p0, uint p1, uint p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,uint)", p0, p1, p2));
	}

	function log(string memory p0, uint p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,string)", p0, p1, p2));
	}

	function log(string memory p0, uint p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,bool)", p0, p1, p2));
	}

	function log(string memory p0, uint p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,address)", p0, p1, p2));
	}

	function log(string memory p0, string memory p1, uint p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,uint)", p0, p1, p2));
	}

	function log(string memory p0, string memory p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,string)", p0, p1, p2));
	}

	function log(string memory p0, string memory p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,bool)", p0, p1, p2));
	}

	function log(string memory p0, string memory p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,address)", p0, p1, p2));
	}

	function log(string memory p0, bool p1, uint p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,uint)", p0, p1, p2));
	}

	function log(string memory p0, bool p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,string)", p0, p1, p2));
	}

	function log(string memory p0, bool p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,bool)", p0, p1, p2));
	}

	function log(string memory p0, bool p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,address)", p0, p1, p2));
	}

	function log(string memory p0, address p1, uint p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,uint)", p0, p1, p2));
	}

	function log(string memory p0, address p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,string)", p0, p1, p2));
	}

	function log(string memory p0, address p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,bool)", p0, p1, p2));
	}

	function log(string memory p0, address p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,address)", p0, p1, p2));
	}

	function log(bool p0, uint p1, uint p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,uint)", p0, p1, p2));
	}

	function log(bool p0, uint p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,string)", p0, p1, p2));
	}

	function log(bool p0, uint p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,bool)", p0, p1, p2));
	}

	function log(bool p0, uint p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,address)", p0, p1, p2));
	}

	function log(bool p0, string memory p1, uint p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,uint)", p0, p1, p2));
	}

	function log(bool p0, string memory p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,string)", p0, p1, p2));
	}

	function log(bool p0, string memory p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,bool)", p0, p1, p2));
	}

	function log(bool p0, string memory p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,address)", p0, p1, p2));
	}

	function log(bool p0, bool p1, uint p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,uint)", p0, p1, p2));
	}

	function log(bool p0, bool p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,string)", p0, p1, p2));
	}

	function log(bool p0, bool p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,bool)", p0, p1, p2));
	}

	function log(bool p0, bool p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,address)", p0, p1, p2));
	}

	function log(bool p0, address p1, uint p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,uint)", p0, p1, p2));
	}

	function log(bool p0, address p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,string)", p0, p1, p2));
	}

	function log(bool p0, address p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,bool)", p0, p1, p2));
	}

	function log(bool p0, address p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,address)", p0, p1, p2));
	}

	function log(address p0, uint p1, uint p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,uint)", p0, p1, p2));
	}

	function log(address p0, uint p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,string)", p0, p1, p2));
	}

	function log(address p0, uint p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,bool)", p0, p1, p2));
	}

	function log(address p0, uint p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,address)", p0, p1, p2));
	}

	function log(address p0, string memory p1, uint p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,uint)", p0, p1, p2));
	}

	function log(address p0, string memory p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,string)", p0, p1, p2));
	}

	function log(address p0, string memory p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,bool)", p0, p1, p2));
	}

	function log(address p0, string memory p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,address)", p0, p1, p2));
	}

	function log(address p0, bool p1, uint p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,uint)", p0, p1, p2));
	}

	function log(address p0, bool p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,string)", p0, p1, p2));
	}

	function log(address p0, bool p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,bool)", p0, p1, p2));
	}

	function log(address p0, bool p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,address)", p0, p1, p2));
	}

	function log(address p0, address p1, uint p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,uint)", p0, p1, p2));
	}

	function log(address p0, address p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,string)", p0, p1, p2));
	}

	function log(address p0, address p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,bool)", p0, p1, p2));
	}

	function log(address p0, address p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,address)", p0, p1, p2));
	}

	function log(uint p0, uint p1, uint p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,uint,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, uint p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,uint,string)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, uint p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,uint,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, uint p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,uint,address)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, string memory p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,string,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,string,string)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,string,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,string,address)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, bool p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,bool,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,bool,string)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,bool,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,bool,address)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, address p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,address,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,address,string)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,address,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,address,address)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, uint p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,uint,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, uint p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,uint,string)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, uint p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,uint,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, uint p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,uint,address)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, string memory p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,string,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,string,string)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,string,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,string,address)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, bool p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,bool,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,bool,string)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,bool,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,bool,address)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, address p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,address,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,address,string)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,address,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,address,address)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, uint p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,uint,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, uint p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,uint,string)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, uint p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,uint,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, uint p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,uint,address)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, string memory p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,string,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,string,string)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,string,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,string,address)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, bool p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,bool,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,bool,string)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,bool,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,bool,address)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, address p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,address,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,address,string)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,address,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,address,address)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, uint p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,uint,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, uint p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,uint,string)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, uint p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,uint,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, uint p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,uint,address)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, string memory p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,string,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,string,string)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,string,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,string,address)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, bool p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,bool,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,bool,string)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,bool,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,bool,address)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, address p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,address,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,address,string)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,address,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,address,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, uint p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,uint,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, uint p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,uint,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, uint p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,uint,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, uint p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,uint,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, string memory p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,string,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,string,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,string,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,string,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, bool p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,bool,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,bool,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,bool,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,bool,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, address p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,address,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,address,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,address,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,address,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, uint p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,uint,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, uint p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,uint,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, uint p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,uint,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, uint p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,uint,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, string memory p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,string,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,string,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,string,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,string,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, bool p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,bool,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,bool,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,bool,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,bool,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, address p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,address,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,address,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,address,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,address,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, uint p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,uint,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, uint p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,uint,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, uint p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,uint,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, uint p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,uint,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, string memory p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,string,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,string,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,string,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,string,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, bool p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,bool,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,bool,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,bool,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,bool,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, address p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,address,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,address,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,address,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,address,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, uint p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,uint,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, uint p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,uint,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, uint p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,uint,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, uint p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,uint,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, string memory p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,string,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,string,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,string,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,string,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, bool p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,bool,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,bool,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,bool,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,bool,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, address p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,address,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,address,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,address,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,address,address)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, uint p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,uint,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, uint p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,uint,string)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, uint p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,uint,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, uint p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,uint,address)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, string memory p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,string,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,string,string)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,string,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,string,address)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, bool p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,bool,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,bool,string)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,bool,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,bool,address)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, address p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,address,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,address,string)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,address,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,address,address)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, uint p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,uint,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, uint p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,uint,string)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, uint p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,uint,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, uint p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,uint,address)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, string memory p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,string,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,string,string)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,string,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,string,address)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, bool p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,bool,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,bool,string)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,bool,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,bool,address)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, address p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,address,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,address,string)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,address,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,address,address)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, uint p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,uint,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, uint p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,uint,string)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, uint p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,uint,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, uint p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,uint,address)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, string memory p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,string,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,string,string)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,string,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,string,address)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, bool p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,bool,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,bool,string)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,bool,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,bool,address)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, address p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,address,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,address,string)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,address,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,address,address)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, uint p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,uint,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, uint p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,uint,string)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, uint p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,uint,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, uint p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,uint,address)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, string memory p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,string,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,string,string)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,string,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,string,address)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, bool p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,bool,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,bool,string)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,bool,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,bool,address)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, address p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,address,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,address,string)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,address,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,address,address)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, uint p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,uint,uint)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, uint p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,uint,string)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, uint p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,uint,bool)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, uint p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,uint,address)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, string memory p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,string,uint)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,string,string)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,string,bool)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,string,address)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, bool p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,bool,uint)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,bool,string)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,bool,bool)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,bool,address)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, address p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,address,uint)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,address,string)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,address,bool)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,address,address)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, uint p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,uint,uint)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, uint p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,uint,string)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, uint p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,uint,bool)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, uint p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,uint,address)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, string memory p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,string,uint)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,string,string)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,string,bool)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,string,address)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, bool p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,bool,uint)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,bool,string)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,bool,bool)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,bool,address)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, address p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,address,uint)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,address,string)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,address,bool)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,address,address)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, uint p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,uint,uint)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, uint p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,uint,string)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, uint p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,uint,bool)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, uint p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,uint,address)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, string memory p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,string,uint)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,string,string)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,string,bool)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,string,address)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, bool p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,bool,uint)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,bool,string)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,bool,bool)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,bool,address)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, address p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,address,uint)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,address,string)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,address,bool)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,address,address)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, uint p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,uint,uint)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, uint p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,uint,string)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, uint p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,uint,bool)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, uint p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,uint,address)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, string memory p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,string,uint)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,string,string)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,string,bool)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,string,address)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, bool p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,bool,uint)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,bool,string)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,bool,bool)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,bool,address)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, address p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,address,uint)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,address,string)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,address,bool)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,address,address)", p0, p1, p2, p3));
	}

}// MIT
pragma solidity ^0.8.4;


contract Helpers is Ownable {
    function _makeLegacyParts(
        string memory size,
        string memory spirit,
        string memory age,
        string memory resource,
        string memory morale,
        string memory government,
        string memory realm
    ) public pure returns (string[18] memory) {
        string[18] memory parts;

        parts[
            0
        ] = '<svg xmlns="http://www.w3.org/2000/svg" preserveAspectRatio="xMinYMin meet" viewBox="0 0 350 350"><style>.txt { fill: black; font-family: monospace; font-size: 12px;}</style><rect width="100%" height="100%" fill="white" /><text x="10" y="20" class="txt">';
        parts[1] = size;
        parts[2] = '</text><text x="10" y="40" class="txt">';
        parts[3] = spirit;
        parts[4] = '</text><text x="10" y="60" class="txt">';
        parts[5] = age;
        parts[6] = '</text><text x="10" y="80" class="txt">';
        parts[7] = resource;
        parts[8] = '</text><text x="10" y="100" class="txt">';
        parts[9] = morale;
        parts[10] = '</text><text x="10" y="120" class="txt">';
        parts[11] = government;
        parts[12] = '</text><text x="10" y="140" class="txt">';
        parts[13] = realm;
        parts[14] = "</text></svg>";
        return parts;
    }

    function _makeLegacyAttributeParts(string[18] memory parts)
        public
        pure
        returns (string[18] memory)
    {
        string[18] memory attrParts;
        attrParts[0] = '[{ "trait_type": "Size", "value": "';
        attrParts[1] = parts[1];
        attrParts[2] = '" }, { "trait_type": "Spirit", "value": "';
        attrParts[3] = parts[3];
        attrParts[4] = '" }, { "trait_type": "Age", "value": "';
        attrParts[5] = parts[5];
        attrParts[6] = '" }, { "trait_type": "Resource", "value": "';
        attrParts[7] = parts[7];
        attrParts[8] = '" }, { "trait_type": "Morale", "value": "';
        attrParts[9] = parts[9];
        attrParts[10] = '" }, { "trait_type": "Government", "value": "';
        attrParts[11] = parts[11];
        attrParts[12] = '" }, { "trait_type": "Realm", "value": "';
        attrParts[13] = parts[13];
        attrParts[14] = '" }]';
        return attrParts;
    }

    function _makeParts(
        string memory size,
        string memory spirit,
        string memory age,
        string memory resource,
        string memory morale,
        string memory government,
        string memory realm,
        uint256 unharvestedTokenAmount,
        string memory tokenSymbol
    ) public pure returns (string[18] memory) {
        string[18] memory parts;
        parts[
            0
        ] = '<svg xmlns="http://www.w3.org/2000/svg" preserveAspectRatio="xMinYMin meet" viewBox="0 0 350 350"><style>.txt { fill: black; font-family: monospace; font-size: 12px;}</style><rect width="100%" height="100%" fill="white" /><text x="10" y="20" class="txt">';
        parts[1] = size;
        parts[2] = '</text><text x="10" y="40" class="txt">';
        parts[3] = spirit;
        parts[4] = '</text><text x="10" y="60" class="txt">';
        parts[5] = age;
        parts[6] = '</text><text x="10" y="80" class="txt">';
        parts[7] = resource;
        parts[8] = '</text><text x="10" y="100" class="txt">';
        parts[9] = morale;
        parts[10] = '</text><text x="10" y="120" class="txt">';
        parts[11] = government;
        parts[12] = '</text><text x="10" y="140" class="txt">';
        parts[13] = realm;
        parts[14] = '</text><text x="10" y="160" class="txt">';
        parts[15] = "------------";
        parts[16] = '</text><text x="10" y="180" class="txt">';
        parts[17] = string(
            abi.encodePacked(
                "$",
                tokenSymbol,
                ": ",
                Strings.toString(unharvestedTokenAmount / 10**18),
                "</text></svg>"
            )
        );

        return parts;
    }

    function _makeAttributeParts(
        string memory size,
        string memory spirit,
        string memory age,
        string memory resource,
        string memory morale,
        string memory government,
        string memory realm,
        uint256 unharvestedTokenAmount,
        string memory tokenSymbol
    ) public pure returns (string[18] memory) {
        string[18] memory attrParts;
        attrParts[0] = '[{ "trait_type": "Size", "value": "';
        attrParts[1] = size;
        attrParts[2] = '" }, { "trait_type": "Spirit", "value": "';
        attrParts[3] = spirit;
        attrParts[4] = '" }, { "trait_type": "Age", "value": "';
        attrParts[5] = age;
        attrParts[6] = '" }, { "trait_type": "Resource", "value": "';
        attrParts[7] = resource;
        attrParts[8] = '" }, { "trait_type": "Morale", "value": "';
        attrParts[9] = morale;
        attrParts[10] = '" }, { "trait_type": "Government", "value": "';
        attrParts[11] = government;
        attrParts[12] = '" }, { "trait_type": "Realm", "value": "';
        attrParts[13] = realm;
        attrParts[14] = '" }, { "display_type": "number",  "trait_type": ';
        attrParts[15] = string(abi.encodePacked('"$', tokenSymbol, '", "value": '));
        attrParts[16] = string(abi.encodePacked(Strings.toString(unharvestedTokenAmount / 10**18)));
        attrParts[17] = " }]";
        return attrParts;
    }

    struct TokenURIInput {
        string size;
        string spirit;
        string age;
        string resource;
        string morale;
        string government;
        string realm;
    }

    function tokenURI(
        TokenURIInput memory tokenURIInput,
        uint256 unharvestedTokenAmount,
        string memory tokenSymbol,
        bool useLegacy,
        uint256 tokenId
    ) public view returns (string memory) {
        string[18] memory parts;
        string[18] memory attributesParts;

        if (useLegacy) {
            parts = _makeLegacyParts(
                tokenURIInput.size,
                tokenURIInput.spirit,
                tokenURIInput.age,
                tokenURIInput.resource,
                tokenURIInput.morale,
                tokenURIInput.government,
                tokenURIInput.realm
            );

            attributesParts = _makeLegacyAttributeParts(
                _makeLegacyParts(
                    tokenURIInput.size,
                    tokenURIInput.spirit,
                    tokenURIInput.age,
                    tokenURIInput.resource,
                    tokenURIInput.morale,
                    tokenURIInput.government,
                    tokenURIInput.realm
                )
            );
        } else {
            parts = _makeParts(
                tokenURIInput.size,
                tokenURIInput.spirit,
                tokenURIInput.age,
                tokenURIInput.resource,
                tokenURIInput.morale,
                tokenURIInput.government,
                tokenURIInput.realm,
                unharvestedTokenAmount,
                tokenSymbol
            );

            attributesParts = _makeAttributeParts(
                tokenURIInput.size,
                tokenURIInput.spirit,
                tokenURIInput.age,
                tokenURIInput.resource,
                tokenURIInput.morale,
                tokenURIInput.government,
                tokenURIInput.realm,
                unharvestedTokenAmount,
                tokenSymbol
            );
        }

        string memory output = string(
            abi.encodePacked(
                parts[0],
                parts[1],
                parts[2],
                parts[3],
                parts[4],
                parts[5],
                parts[6],
                parts[7],
                parts[8]
            )
        );
        output = string(
            abi.encodePacked(
                output,
                parts[9],
                parts[10],
                parts[11],
                parts[12],
                parts[13],
                parts[14],
                parts[15],
                parts[16]
            )
        );
        output = string(abi.encodePacked(output, parts[17]));

        string memory atrrOutput = string(
            abi.encodePacked(
                attributesParts[0],
                attributesParts[1],
                attributesParts[2],
                attributesParts[3],
                attributesParts[4],
                attributesParts[5],
                attributesParts[6],
                attributesParts[7],
                attributesParts[8]
            )
        );
        atrrOutput = string(
            abi.encodePacked(
                atrrOutput,
                attributesParts[9],
                attributesParts[10],
                attributesParts[11],
                attributesParts[12],
                attributesParts[13],
                attributesParts[14]
            )
        );

        atrrOutput = string(
            abi.encodePacked(
                atrrOutput,
                attributesParts[15],
                attributesParts[16],
                attributesParts[17]
            )
        );

        string memory json = Base64.encode(
            bytes(
                string(
                    abi.encodePacked(
                        '{"name": "Settlement #',
                        Strings.toString(tokenId),
                        '", "description": "Settlements are a turn based civilisation simulator stored entirely on chain, go forth and conquer.", "image": "data:image/svg+xml;base64,',
                        Base64.encode(bytes(output)),
                        '"',
                        ',"attributes":',
                        atrrOutput,
                        "}"
                    )
                )
            )
        );

        return string(abi.encodePacked("data:application/json;base64,", json));
    }

    uint8[] public civMultipliers;
    uint8[] public realmMultipliers;
    uint8[] public moralMultipliers;

    uint256 constant ONE = 10**18;

    function setMultipliers(
        uint8[] memory civMultipliers_,
        uint8[] memory realmMultipliers_,
        uint8[] memory moralMultipliers_
    ) public onlyOwner {
        civMultipliers = civMultipliers_;
        realmMultipliers = realmMultipliers_;
        moralMultipliers = moralMultipliers_;
    }

    function getUnharvestedTokens(uint256 tokenId, SettlementsV2.Attributes memory attributes)
        public
        view
        returns (ERC20Mintable, uint256)
    {
        SettlementsV2 caller = SettlementsV2(msg.sender);

        uint256 lastHarvest = caller.tokenIdToLastHarvest(tokenId);
        uint256 blockDelta = block.number - lastHarvest;

        ERC20Mintable tokenAddress = caller.resourceTokenAddresses(attributes.resource);

        if (blockDelta == 0 || lastHarvest == 0) {
            return (tokenAddress, 0);
        }

        uint256 realmMultiplier = realmMultipliers[attributes.turns];
        uint256 civMultiplier = civMultipliers[attributes.size];
        uint256 moralMultiplier = moralMultipliers[attributes.morale];
        uint256 tokensToMint = (civMultiplier *
            blockDelta *
            moralMultiplier *
            ONE *
            realmMultiplier) / 300;

        return (tokenAddress, tokensToMint);
    }
}// MIT
pragma solidity ^0.8.4;




contract SettlementsV2 is ERC721, ERC721Enumerable, Ownable {
    struct Attributes {
        uint8 size;
        uint8 spirit;
        uint8 age;
        uint8 resource;
        uint8 morale;
        uint8 government;
        uint8 turns;
    }

    SettlementsLegacy public legacySettlements;
    Helpers public helpersContract;

    ERC20Mintable[] public resourceTokenAddresses;
    mapping(uint256 => uint256) public tokenIdToLastHarvest;
    mapping(uint256 => Attributes) public attrIndex;

    string[] public _sizes = [
        "Camp",
        "Hamlet",
        "Village",
        "Town",
        "District",
        "Precinct",
        "Capitol",
        "State"
    ];
    string[] public _spirits = ["Earth", "Fire", "Water", "Air", "Astral"];
    string[] public _ages = [
        "Ancient",
        "Classical",
        "Medieval",
        "Renaissance",
        "Industrial",
        "Modern",
        "Information",
        "Future"
    ];
    string[] public _resources = [
        "Iron",
        "Gold",
        "Silver",
        "Wood",
        "Wool",
        "Water",
        "Grass",
        "Grain"
    ];
    string[] public _morales = [
        "Expectant",
        "Enlightened",
        "Dismissive",
        "Unhappy",
        "Happy",
        "Undecided",
        "Warring",
        "Scared",
        "Unruly",
        "Anarchist"
    ];
    string[] public _governments = [
        "Democracy",
        "Communism",
        "Socialism",
        "Oligarchy",
        "Aristocracy",
        "Monarchy",
        "Theocracy",
        "Colonialism",
        "Dictatorship"
    ];
    string[] public _realms = ["Genesis", "Valhalla", "Keskella", "Shadow", "Plains", "Ends"];

    constructor(
        SettlementsLegacy _legacyAddress,
        ERC20Mintable ironToken_,
        ERC20Mintable goldToken_,
        ERC20Mintable silverToken_,
        ERC20Mintable woodToken_,
        ERC20Mintable woolToken_,
        ERC20Mintable waterToken_,
        ERC20Mintable grassToken_,
        ERC20Mintable grainToken_
    ) ERC721("Settlements", "STL") {
        legacySettlements = _legacyAddress;
        resourceTokenAddresses = [
            ironToken_,
            goldToken_,
            silverToken_,
            woodToken_,
            woolToken_,
            waterToken_,
            grassToken_,
            grainToken_
        ];
    }

    function setHelpersContract(Helpers helpersContract_) public onlyOwner {
        helpersContract = helpersContract_;
    }

    function indexFor(string memory input, uint256 length) internal pure returns (uint256) {
        return uint256(keccak256(abi.encodePacked(input))) % length;
    }

    function _getRandomSeed(uint256 tokenId, string memory seedFor)
        internal
        view
        returns (string memory)
    {
        return
            string(
                abi.encodePacked(
                    seedFor,
                    Strings.toString(tokenId),
                    block.timestamp,
                    block.difficulty
                )
            );
    }

    function generateAttribute(string memory salt, string[] memory items)
        internal
        pure
        returns (uint8)
    {
        return uint8(indexFor(string(salt), items.length));
    }

    function _oldTokenURI(uint256 tokenId) private view returns (string memory) {
        return _tokenURI(tokenId, true);
    }

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        return _tokenURI(tokenId, false);
    }

    function getUnharvestedTokens(uint256 tokenId) public view returns (ERC20Mintable, uint256) {
        Attributes memory attributes = attrIndex[tokenId];
        return helpersContract.getUnharvestedTokens(tokenId, attributes);
    }

    function _tokenURI(uint256 tokenId, bool useLegacy) private view returns (string memory) {
        require(_exists(tokenId), "Settlement does not exist");

        Helpers.TokenURIInput memory tokenURIInput;

        tokenURIInput.size = _sizes[attrIndex[tokenId].size];
        tokenURIInput.spirit = _spirits[attrIndex[tokenId].spirit];
        tokenURIInput.age = _ages[attrIndex[tokenId].age];
        tokenURIInput.resource = _resources[attrIndex[tokenId].resource];
        tokenURIInput.morale = _morales[attrIndex[tokenId].morale];
        tokenURIInput.government = _governments[attrIndex[tokenId].government];
        tokenURIInput.realm = _realms[attrIndex[tokenId].turns];

        ERC20Mintable tokenContract = resourceTokenAddresses[0];
        uint256 unharvestedTokenAmount = 0;

        if (useLegacy == false) {
            Attributes memory attributes = attrIndex[tokenId];
            (tokenContract, unharvestedTokenAmount) = getUnharvestedTokens(tokenId);
        }

        string memory output = helpersContract.tokenURI(
            tokenURIInput,
            unharvestedTokenAmount,
            tokenContract.symbol(),
            useLegacy,
            tokenId
        );

        return output;
    }

    function randomiseAttributes(uint256 tokenId, uint8 turn) internal {
        attrIndex[tokenId].size = generateAttribute(_getRandomSeed(tokenId, "size"), _sizes);
        attrIndex[tokenId].spirit = generateAttribute(_getRandomSeed(tokenId, "spirit"), _spirits);
        attrIndex[tokenId].age = generateAttribute(_getRandomSeed(tokenId, "age"), _ages);
        attrIndex[tokenId].resource = generateAttribute(
            _getRandomSeed(tokenId, "resource"),
            _resources
        );
        attrIndex[tokenId].morale = generateAttribute(_getRandomSeed(tokenId, "morale"), _morales);
        attrIndex[tokenId].government = generateAttribute(
            _getRandomSeed(tokenId, "government"),
            _governments
        );
        attrIndex[tokenId].turns = turn;
    }

    function randomise(uint256 tokenId) public {
        require(
            _exists(tokenId) && msg.sender == ownerOf(tokenId) && attrIndex[tokenId].turns < 5,
            "Settlement turns over"
        );

        harvest(tokenId);
        randomiseAttributes(tokenId, attrIndex[tokenId].turns + 1);
    }

    function harvest(uint256 tokenId) public {
        (ERC20Mintable tokenAddress, uint256 tokensToMint) = getUnharvestedTokens(tokenId);

        tokenAddress.mint(ownerOf(tokenId), tokensToMint);
        tokenIdToLastHarvest[tokenId] = block.number;
    }

    function multiClaim(uint256[] calldata tokenIds, Attributes[] memory tokenAttributes) public {
        for (uint256 i = 0; i < tokenAttributes.length; i++) {
            claim(tokenIds[i], tokenAttributes[i]);
        }
    }

    function claim(uint256 tokenId, Attributes memory attributes) public {
        legacySettlements.transferFrom(msg.sender, address(this), tokenId);
        _safeMint(msg.sender, tokenId);
        attrIndex[tokenId] = attributes;
        bytes32 v2Uri = keccak256(abi.encodePacked(_oldTokenURI(tokenId)));
        bytes32 legacyURI = keccak256(abi.encodePacked(legacySettlements.tokenURI(tokenId)));

        tokenIdToLastHarvest[tokenId] = block.number;
        require(v2Uri == legacyURI, "Attributes don't match legacy contract");
    }

    function claimAndReroll(uint256 tokenId) public {
        legacySettlements.transferFrom(msg.sender, address(this), tokenId);
        randomiseAttributes(tokenId, 3);
        _safeMint(msg.sender, tokenId);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal override(ERC721, ERC721Enumerable) {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    function getSettlementSize(uint256 tokenId) public view returns (string memory) {
        require(_exists(tokenId), "Settlement does not exist");
        return _sizes[attrIndex[tokenId].size];
    }

    function getSettlementSpirit(uint256 tokenId) public view returns (string memory) {
        require(_exists(tokenId), "Settlement does not exist");
        return _spirits[attrIndex[tokenId].spirit];
    }

    function getSettlementAge(uint256 tokenId) public view returns (string memory) {
        require(_exists(tokenId), "Settlement does not exist");
        return _ages[attrIndex[tokenId].age];
    }

    function getSettlementResource(uint256 tokenId) public view returns (string memory) {
        require(_exists(tokenId), "Settlement does not exist");
        return _resources[attrIndex[tokenId].resource];
    }

    function getSettlementMorale(uint256 tokenId) public view returns (string memory) {
        require(_exists(tokenId), "Settlement does not exist");
        return _morales[attrIndex[tokenId].morale];
    }

    function getSettlementGovernment(uint256 tokenId) public view returns (string memory) {
        require(_exists(tokenId), "Settlement does not exist");
        return _governments[attrIndex[tokenId].government];
    }

    function getSettlementRealm(uint256 tokenId) public view returns (string memory) {
        require(_exists(tokenId), "Settlement does not exist");
        return _realms[attrIndex[tokenId].turns];
    }
}// MIT
pragma solidity ^0.8.4;

contract ERC20Mintable is ERC20Burnable, Ownable {
    mapping(address => bool) public approvedMinters;
    SettlementsV2 settlements;
    uint256 public totalMinters = 0;
    bool public canToggleMints = true;

    modifier onlyMinter() {
        require(approvedMinters[msg.sender] == true, "Not an approved minter");
        _;
    }

    constructor(string memory name_, string memory symbol_)
        ERC20(name_, symbol_)
    {
        approvedMinters[msg.sender] = true;
    }

    function setSettlementsAddress(SettlementsV2 _settlements)
        public
        onlyOwner
    {
        settlements = _settlements;
    }

    function turnOffMintGovernance() public onlyOwner {
        canToggleMints = false;
    }

    function addMinter(address minter) public onlyOwner {
        require(canToggleMints, "Minting turned off");
        totalMinters += 1;
        approvedMinters[minter] = true;
    }

    function removeMinter(address minter) public onlyOwner {
        require(canToggleMints, "Minting turned off");
        approvedMinters[minter] = false;
        totalMinters -= 1;
    }

    function mint(address to, uint256 amount) public onlyMinter {
        _mint(to, amount);
    }
}// MIT
pragma solidity ^0.8.4;


contract IslandsHelper is Ownable {
    uint256 constant ONE = 10**18;

    Islands public islandContract;

    uint8[] public climateMultipliers;
    uint8[] public terrainMultipliers;

    function setIslandsContract(Islands islandContract_) public onlyOwner {
        islandContract = islandContract_;
    }

    function setMultipliers(uint8[] memory climateMultipliers_, uint8[] memory terrainMultipliers_)
        public
        onlyOwner
    {
        climateMultipliers = climateMultipliers_;
        terrainMultipliers = terrainMultipliers_;
    }

    function getImageOutput(Islands.Island memory islandInfo) public view returns (string memory) {
        string memory imageOutput = string(
            abi.encodePacked(
                '<svg xmlns="http://www.w3.org/2000/svg" preserveAspectRatio="xMinYMin meet" viewBox="0 0 350 350"><style>.txt { fill: black; font-family: monospace; font-size: 12px;}</style><rect width="100%" height="100%" fill="white" /><text x="10" y="20" class="txt">',
                islandInfo.climate,
                '</text><text x="10" y="40" class="txt">',
                islandInfo.terrain,
                '</text><text x="10" y="60" class="txt">',
                islandInfo.resource,
                '</text><text x="10" y="80" class="txt">',
                string(abi.encodePacked(Strings.toString(islandInfo.area), " sq mi")),
                '</text><text x="10" y="100" class="txt">'
            )
        );

        (ERC20Mintable resourceTokenContract, uint256 taxIncome) = getTaxIncome(islandInfo.tokenId);

        imageOutput = string(
            abi.encodePacked(
                imageOutput,
                string(
                    abi.encodePacked(
                        "Pop. ",
                        Strings.toString(islandInfo.population),
                        "/",
                        Strings.toString(islandInfo.maxPopulation)
                    )
                ),
                '</text><text x="10" y="120" class="txt">',
                "------------",
                '</text><text x="10" y="140" class="txt">',
                string(abi.encodePacked("Tax Rate: ", Strings.toString(islandInfo.taxRate), "%")),
                '</text><text x="10" y="160" class="txt">',
                string(
                    abi.encodePacked(
                        "Tax Income: ",
                        Strings.toString(taxIncome / 10**18),
                        " $",
                        resourceTokenContract.symbol()
                    )
                ),
                '</text><text x="10" y="180" class="txt">',
                "</text></svg>"
            )
        );

        return imageOutput;
    }

    function getAttrOutput(Islands.Island memory islandInfo) public view returns (string memory) {
        (ERC20Mintable __, uint256 taxIncome) = getTaxIncome(islandInfo.tokenId);

        string memory attrOutput = string(
            abi.encodePacked(
                '[{ "trait_type": "Climate", "value": "',
                islandInfo.climate,
                '" }, { "trait_type": "Terain", "value": "',
                islandInfo.terrain,
                '" }, { "trait_type": "Resource", "value": "',
                islandInfo.resource,
                '" }, { "trait_type": "Area (sq mi)", "display_type": "number", "value": ',
                Strings.toString(islandInfo.area),
                ' }, { "trait_type": "Population", "display_type": "number", "value": ',
                Strings.toString(islandInfo.population),
                ' }, { "trait_type": "Tax Rate", "display_type": "boost_percentage", "value": ',
                Strings.toString(islandInfo.taxRate)
            )
        );

        attrOutput = string(
            abi.encodePacked(
                attrOutput,
                ' }, { "trait_type": "Max Population", "display_type": "number", "value": ',
                Strings.toString(islandInfo.maxPopulation),
                ' }, { "trait_type": "Tax Income", "display_type": "number", "value": ',
                Strings.toString(taxIncome / 10**18),
                " }]"
            )
        );

        return attrOutput;
    }

    function getTaxIncome(uint256 tokenId) public view returns (ERC20Mintable, uint256) {
        Islands.Attributes memory islandInfo = islandContract.getTokenIdToAttributes(tokenId);
        ERC20Mintable resourceTokenContract = islandContract.resourcesToTokenContracts(
            islandInfo.resource
        );

        uint256 lastHarvest = islandContract.tokenIdToLastHarvest(tokenId);
        uint256 blockDelta = block.number - lastHarvest;

        uint256 tokenAmount = (blockDelta *
            climateMultipliers[islandInfo.climate] *
            terrainMultipliers[islandInfo.terrain] *
            islandInfo.taxRate *
            islandInfo.population *
            ONE) / 1_000_000_000;

        return (resourceTokenContract, tokenAmount);
    }

    function tokenURI(uint256 tokenId) public view returns (string memory) {
        Islands.Island memory islandInfo = islandContract.getIslandInfo(tokenId);

        string memory imageOutput = getImageOutput(islandInfo);
        string memory attrOutput = getAttrOutput(islandInfo);

        string memory json = Base64.encode(
            bytes(
                string(
                    abi.encodePacked(
                        '{"name": "Island #',
                        Strings.toString(tokenId),
                        '", "description": "Islands can be discovered and harvested for their resources. All data is onchain.", "image": "data:image/svg+xml;base64,',
                        Base64.encode(bytes(imageOutput)),
                        '", "attributes": ',
                        attrOutput,
                        "}"
                    )
                )
            )
        );

        return string(abi.encodePacked("data:application/json;base64,", json));
    }
}// MIT
pragma solidity ^0.8.4;



contract Islands is ERC721, ERC721Enumerable, Ownable {
    struct Attributes {
        uint8 resource;
        uint8 climate;
        uint8 terrain;
        uint8 taxRate;
        uint32 area;
        uint32 population;
    }

    struct Island {
        uint256 tokenId;
        ERC20Mintable resourceTokenContract;
        string resource;
        string climate;
        string terrain;
        uint32 area;
        uint32 maxPopulation;
        uint32 population;
        uint8 taxRate;
    }

    string[] public resources = ["Fish", "Wood", "Iron", "Silver", "Pearl", "Oil", "Diamond"];
    string[] public climates = ["Temperate", "Rainy", "Humid", "Arid", "Tropical", "Icy"];
    string[] public terrains = ["Flatlands", "Hilly", "Canyons", "Mountainous"];

    ERC20Mintable[] public resourcesToTokenContracts;

    uint256 constant MAX_AREA = 5_000;
    uint32 constant MAX_POPULATION_PER_SQ_MI = 2_000;

    IslandsHelper public helperContract;

    mapping(uint256 => Attributes) public tokenIdToAttributes;
    mapping(uint256 => uint256) public tokenIdToLastHarvest;

    mapping(address => bool) public populationEditors;

    modifier onlyPopulationEditor() {
        require(
            populationEditors[msg.sender] == true,
            "You don't have permission to edit the population"
        );
        _;
    }

    constructor(
        ERC20Mintable fishToken,
        ERC20Mintable woodToken,
        ERC20Mintable ironToken,
        ERC20Mintable silverToken,
        ERC20Mintable pearlToken,
        ERC20Mintable oilToken,
        ERC20Mintable diamondToken
    ) ERC721("Islands", "ILND") {
        resourcesToTokenContracts = [
            fishToken,
            woodToken,
            ironToken,
            silverToken,
            pearlToken,
            oilToken,
            diamondToken
        ];
    }

    function addPopulationEditor(address newPopulationEditor) public onlyOwner {
        populationEditors[newPopulationEditor] = true;
    }

    function removePopulationEditor(address newPopulationEditor) public onlyOwner {
        populationEditors[newPopulationEditor] = false;
    }

    function setHelperContract(IslandsHelper helperContract_) public onlyOwner {
        helperContract = helperContract_;
    }

    function setPopulation(uint256 tokenId, uint32 population) public onlyPopulationEditor {
        require(population <= getIslandInfo(tokenId).maxPopulation, "Population is over max");
        tokenIdToAttributes[tokenId].population = population;
    }

    function getTaxIncome(uint256 tokenId) public view returns (ERC20Mintable, uint256) {
        return helperContract.getTaxIncome(tokenId);
    }

    function getRandomNumber(bytes memory seed, uint256 maxValue) public pure returns (uint256) {
        return uint256(keccak256(abi.encode(seed))) % maxValue;
    }

    function getTokenIdToAttributes(uint256 tokenId) public view returns (Attributes memory) {
        return tokenIdToAttributes[tokenId];
    }

    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        return helperContract.tokenURI(tokenId);
    }

    function getPopulationPerSqMi(uint256 tokenId) public pure returns (uint32) {
        return uint32(getRandomNumber(abi.encode(tokenId), MAX_POPULATION_PER_SQ_MI)) + 10;
    }

    function getIslandInfo(uint256 tokenId) public view returns (Island memory) {
        require(_exists(tokenId), "Island with that tokenId doesn't exist");

        Attributes memory attr = tokenIdToAttributes[tokenId];

        uint32 populationPerSqMi = getPopulationPerSqMi(tokenId);
        uint32 maxPopulation = populationPerSqMi * attr.area;

        return
            Island({
                tokenId: tokenId,
                resource: resources[attr.resource],
                resourceTokenContract: resourcesToTokenContracts[attr.resource],
                climate: climates[attr.climate],
                terrain: terrains[attr.terrain],
                area: attr.area,
                maxPopulation: maxPopulation,
                population: attr.population,
                taxRate: attr.taxRate
            });
    }

    function mint(uint256 tokenId) public {
        require(!_exists(tokenId), "Island with that id already exists");
        require(
            (tokenId <= 9900) || (tokenId <= 10_000 && tokenId > 9900 && msg.sender == owner()),
            "Island id is invalid"
        );

        Attributes memory attr;

        uint256 value = getRandomNumber(abi.encode(tokenId, "r"), 1000);
        attr.resource = uint8(value < 700 ? value % 3 : value % 7);

        value = getRandomNumber(abi.encode(tokenId, "c"), 1000);
        attr.climate = uint8(value % 6);

        value = getRandomNumber(abi.encode(tokenId, "t"), 1000);
        attr.terrain = uint8(value % 4);

        value = getRandomNumber(abi.encode(tokenId, "ta"), 1000);
        attr.taxRate = uint8(value % 50) + 1;

        attr.area = uint32(getRandomNumber(abi.encode(tokenId, "a"), MAX_AREA)) + 1;

        uint32 populationPerSqMi = getPopulationPerSqMi(tokenId);
        uint32 maxPopulation = populationPerSqMi * attr.area;
        attr.population =
            (uint32(maxPopulation * getRandomNumber(abi.encode(tokenId), 100)) / 100) +
            10;

        tokenIdToAttributes[tokenId] = attr;
        tokenIdToLastHarvest[tokenId] = block.number;

        _safeMint(msg.sender, tokenId);
    }

    function harvest(uint256 tokenId) public {
        (ERC20Mintable resourceTokenContract, uint256 taxIncome) = helperContract.getTaxIncome(
            tokenId
        );

        tokenIdToLastHarvest[tokenId] = block.number;
        resourceTokenContract.mint(ownerOf(tokenId), taxIncome);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal override(ERC721, ERC721Enumerable) {
        super._beforeTokenTransfer(from, to, tokenId);
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
pragma solidity ^0.8.4;


contract ShipsHelper is Ownable {
    uint256 constant ONE = 10**18;

    Ships public shipsContract;

    uint256[] public nameToMaxRouteLength = [2, 3, 4, 5, 5];
    uint256[] public expeditionMultipliers = [3, 2, 2, 1, 1];

    uint256[] public setlNameMultipliers = [1, 2, 2, 4, 4];
    uint256[] public setlExpeditionMultipliers = [1, 3, 1, 2, 2];

    Ships.TokenHarvest[][] public nameToCost;

    SettlementsV2 public settlementsContract;
    Islands public islandsContract;

    ERC20Mintable public setlTokenAddress;

    enum Status {
        Resting,
        Sailing,
        Harvesting
    }

    constructor(ERC20Mintable setlTokenAddress_) {
        setlTokenAddress = setlTokenAddress_;
    }

    function setShipsContract(Ships shipsContract_) public onlyOwner {
        shipsContract = shipsContract_;
    }

    function setSettlementsContract(SettlementsV2 settlementsContract_) public onlyOwner {
        settlementsContract = settlementsContract_;
    }

    function setIslandsContract(Islands islandsContract_) public onlyOwner {
        islandsContract = islandsContract_;
    }

    function setCosts(Ships.TokenHarvest[][] memory costs) public onlyOwner {
        delete nameToCost;

        for (uint256 i = 0; i < costs.length; i++) {
            nameToCost.push();
            for (uint256 s = 0; s < costs[i].length; s++) {
                nameToCost[i].push();
                nameToCost[i][s].resourceTokenContract = costs[i][s].resourceTokenContract;
                nameToCost[i][s].amount = costs[i][s].amount;
            }
        }
    }

    function getStatus(uint256 tokenId) public view returns (Status) {
        Ships.Ship memory shipInfo = shipsContract.getShipInfo(tokenId);

        uint256 lastRouteUpdate = shipsContract.tokenIdToLastRouteUpdate(tokenId);
        uint256 blockDelta = block.number - lastRouteUpdate;

        uint256 sailingDuration = getSailingDuration(shipInfo);
        uint256 harvestDuration = 120;

        uint256 progressIntoCurrentPath = blockDelta % (sailingDuration + harvestDuration);
        uint256 currentTargetIndex = getCurrentTargetIndex(tokenId);
        Status status = progressIntoCurrentPath >= sailingDuration
            ? currentTargetIndex == 0 ? Status.Resting : Status.Harvesting
            : Status.Sailing;

        return status;
    }

    function getCurrentTargetIndex(uint256 tokenId) public view returns (uint256) {
        Ships.Ship memory shipInfo = shipsContract.getShipInfo(tokenId);

        uint256 lastRouteUpdate = shipsContract.tokenIdToLastRouteUpdate(tokenId);
        uint256 blockDelta = block.number - lastRouteUpdate;

        uint256 sailingDuration = getSailingDuration(shipInfo);
        uint256 harvestDuration = 120;

        uint256 singlePathDuration = sailingDuration + harvestDuration;

        uint256 index = (blockDelta % (singlePathDuration * shipInfo.route.length)) /
            singlePathDuration;
        uint256 currentTargetIndex = (index + 1) % shipInfo.route.length;

        return currentTargetIndex;
    }

    function getCurrentTarget(uint256 tokenId) public view returns (Ships.Path memory) {
        uint256 currentTargetIndex = getCurrentTargetIndex(tokenId);
        Ships.Ship memory shipInfo = shipsContract.getShipInfo(tokenId);
        return shipInfo.route[currentTargetIndex];
    }

    function getSailingDuration(Ships.Ship memory shipInfo) public pure returns (uint256) {
        return (15 * 200) / shipInfo.speed;
    }

    function getBlocksUntilNextPhase(uint256 tokenId) public view returns (uint256) {
        Ships.Ship memory shipInfo = shipsContract.getShipInfo(tokenId);
        uint256 lastRouteUpdate = shipsContract.tokenIdToLastRouteUpdate(tokenId);
        uint256 blockDelta = block.number - lastRouteUpdate;

        uint256 sailingDuration = getSailingDuration(shipInfo);
        uint256 harvestDuration = 120;

        uint256 singlePathDuration = sailingDuration + harvestDuration;
        uint256 progressIntoCurrentPath = blockDelta % singlePathDuration;

        uint256 blocksUntilNextPhase = progressIntoCurrentPath < sailingDuration
            ? sailingDuration - progressIntoCurrentPath
            : singlePathDuration - progressIntoCurrentPath;

        return blocksUntilNextPhase;
    }

    function getUnharvestedTokens(uint256 tokenId)
        public
        view
        returns (Ships.TokenHarvest[] memory)
    {
        Ships.Ship memory shipInfo = shipsContract.getShipInfo(tokenId);
        Ships.Attributes memory shipAttr = shipsContract.getTokenIdToAttributes(tokenId);

        uint256 lastRouteUpdate = shipsContract.tokenIdToLastRouteUpdate(tokenId);
        uint256 blockDelta = block.number - lastRouteUpdate;

        uint256 sailingDuration = getSailingDuration(shipInfo);
        uint256 harvestDuration = 120;
        uint256 singlePathDuration = sailingDuration + harvestDuration;
        uint256 totalPathDuration = singlePathDuration * shipInfo.route.length;

        Ships.TokenHarvest[] memory listOfTokensToHarvest = new Ships.TokenHarvest[](
            shipInfo.route.length - 1
        );
        uint256 tokensSeen = 0;

        for (uint256 i = 1; i < shipInfo.route.length; i++) {
            uint256 tokensToHarvest = (((blockDelta +
                (totalPathDuration - singlePathDuration * i)) / totalPathDuration) *
                ONE *
                expeditionMultipliers[shipAttr.expedition]);

            (ERC20Mintable resourceTokenContract, uint256 __) = islandsContract.getTaxIncome(
                shipInfo.route[i].tokenId
            );

            uint256 index = shipInfo.route.length;
            for (uint256 s = 0; s < listOfTokensToHarvest.length; s++) {
                if (
                    listOfTokensToHarvest[s].resourceTokenContract == address(resourceTokenContract)
                ) {
                    index = s;
                }
            }

            if (tokensToHarvest > 0) {
                if (index != shipInfo.route.length) {
                    listOfTokensToHarvest[index].amount += tokensToHarvest;
                } else {
                    listOfTokensToHarvest[tokensSeen].amount += tokensToHarvest;
                    listOfTokensToHarvest[tokensSeen].resourceTokenContract = address(
                        resourceTokenContract
                    );
                    tokensSeen += 1;
                }
            }
        }

        Ships.TokenHarvest[] memory filteredListOfTokensToHarvest = new Ships.TokenHarvest[](
            tokensSeen + 1
        );
        for (uint256 i = 0; i < tokensSeen; i++) {
            filteredListOfTokensToHarvest[i] = listOfTokensToHarvest[i];
        }

        filteredListOfTokensToHarvest[tokensSeen] = Ships.TokenHarvest({
            resourceTokenContract: address(setlTokenAddress),
            amount: getUnharvestedSettlementTokens(tokenId)
        });

        return filteredListOfTokensToHarvest;
    }

    function getUnharvestedSettlementTokens(uint256 tokenId) public view returns (uint256) {
        Ships.Attributes memory shipAttr = shipsContract.getTokenIdToAttributes(tokenId);
        uint256 lastSetlHarvest = shipsContract.tokenIdToLastRouteUpdate(tokenId);
        uint256 blockDelta = block.number - lastSetlHarvest;

        uint256 unharvestedSetlTokens = (setlExpeditionMultipliers[shipAttr.expedition] *
            setlNameMultipliers[shipAttr.name] *
            blockDelta *
            ONE) / 1000;

        return unharvestedSetlTokens;
    }

    function getTaxDestination(uint256 tokenId) public view returns (address) {
        Ships.Ship memory shipInfo = shipsContract.getShipInfo(tokenId);
        return settlementsContract.ownerOf(shipInfo.route[0].tokenId);
    }

    function getInitialRoute(uint256 tokenId, uint8 name)
        public
        view
        returns (Ships.Path[] memory)
    {
        uint256 routeLength = nameToMaxRouteLength[name];
        Ships.Path[] memory routes = new Ships.Path[](routeLength);

        uint256 settlementId = getRandomNumber(abi.encodePacked("s", tokenId), 9_900);
        routes[0] = Ships.Path({
            tokenId: settlementId,
            tokenContract: address(settlementsContract)
        });

        for (uint256 i = 1; i < routes.length; i++) {
            uint256 islandId = getRandomNumber(abi.encodePacked(i, tokenId), 10_000);
            routes[i] = Ships.Path({tokenId: islandId, tokenContract: address(islandsContract)});
        }

        return routes;
    }

    function getRandomNumber(bytes memory seed, uint256 maxValue) public pure returns (uint256) {
        return uint256(keccak256(abi.encode(seed))) % maxValue;
    }

    function getCost(uint8 name) public view returns (Ships.TokenHarvest[] memory) {
        return nameToCost[name];
    }

    function isValidRoute(
        Ships.Path[] memory route,
        uint256 tokenId,
        address sender,
        bool init
    ) public view returns (bool) {
        return init;
    }

    function getImageOutput(Ships.Ship memory shipInfo) public view returns (string memory) {
        string memory imageOutput = string(
            abi.encodePacked(
                '<svg xmlns="http://www.w3.org/2000/svg" preserveAspectRatio="xMinYMin meet" viewBox="0 0 350 350"><style>.txt { fill: black; font-family: monospace; font-size: 12px;}</style><rect width="100%" height="100%" fill="white" /><text x="10" y="20" class="txt">',
                shipInfo.name,
                '</text><text x="10" y="40" class="txt">',
                shipInfo.expedition,
                '</text><text x="10" y="60" class="txt">',
                string(abi.encodePacked(Strings.toString(uint256(shipInfo.length)), " ft")),
                '</text><text x="10" y="80" class="txt">',
                string(abi.encodePacked(Strings.toString(uint256(shipInfo.speed)), " km/h")),
                '</text><text x="10" y="100" class="txt">'
            )
        );

        string memory routeStr = "";
        uint256 svgY = 160;
        for (uint256 i = 0; i < shipInfo.route.length; i++) {
            string memory symbol = shipInfo.route[i].tokenContract == address(settlementsContract)
                ? "S"
                : "I";

            string memory suffix = i == shipInfo.route.length - 1 ? "" : ",";

            routeStr = string(
                abi.encodePacked(
                    routeStr,
                    " ",
                    symbol,
                    Strings.toString(shipInfo.route[i].tokenId),
                    suffix
                )
            );

            if ((i + 1) % 4 == 0 && i + 1 != shipInfo.route.length) {
                svgY += 20;
                routeStr = string(
                    abi.encodePacked(
                        routeStr,
                        '</text><text x="10" y="',
                        Strings.toString(svgY),
                        '" class="txt">'
                    )
                );
            }
        }

        Status shipStatus = getStatus(shipInfo.tokenId);
        Ships.Path memory currentTarget = getCurrentTarget(shipInfo.tokenId);
        imageOutput = string(
            abi.encodePacked(
                imageOutput,
                "------------",
                '</text><text x="10" y="120" class="txt">',
                "Status: ",
                shipStatus == Status.Harvesting ? "Harvesting " : shipStatus == Status.Resting
                    ? "Resting at "
                    : "Sailing to ",
                currentTarget.tokenContract == address(settlementsContract) ? "S" : "I",
                Strings.toString(currentTarget.tokenId),
                '</text><text x="10" y="140" class="txt">',
                abi.encodePacked(
                    "ETA: ",
                    Strings.toString(getBlocksUntilNextPhase(shipInfo.tokenId)),
                    " blocks"
                ),
                '</text><text x="10" y="160" class="txt">',
                "Route: ",
                routeStr,
                abi.encodePacked(
                    '</text><text x="10" y="',
                    Strings.toString(svgY + 20),
                    '" class="txt">'
                ),
                "------------",
                abi.encodePacked(
                    '</text><text x="10" y="',
                    Strings.toString(svgY + 40),
                    '" class="txt">'
                )
            )
        );

        svgY += 40;
        Ships.TokenHarvest[] memory unharvestedTokens = getUnharvestedTokens(shipInfo.tokenId);
        string memory unharvestedTokenStr = "";
        for (uint256 i = 0; i < unharvestedTokens.length; i++) {
            string memory suffix = i == unharvestedTokens.length - 1 ? "" : ", ";
            unharvestedTokenStr = string(
                abi.encodePacked(
                    unharvestedTokenStr,
                    Strings.toString(unharvestedTokens[i].amount / ONE),
                    " $",
                    ERC20Mintable(unharvestedTokens[i].resourceTokenContract).symbol(),
                    suffix
                )
            );

            if ((i + 1) % 3 == 0) {
                svgY += 20;
                unharvestedTokenStr = string(
                    abi.encodePacked(
                        unharvestedTokenStr,
                        '</text><text x="10" y="',
                        Strings.toString(svgY),
                        '" class="txt">'
                    )
                );
            }
        }

        imageOutput = string(abi.encodePacked(imageOutput, unharvestedTokenStr, "</text></svg>"));

        return imageOutput;
    }

    function getAttrOutput(Ships.Ship memory shipInfo) public view returns (string memory) {
        string memory routeStr = "";
        for (uint256 i = 0; i < shipInfo.route.length; i++) {
            string memory symbol = shipInfo.route[i].tokenContract == address(settlementsContract)
                ? "S"
                : "I";

            string memory suffix = i == shipInfo.route.length - 1 ? "" : ",";

            routeStr = string(
                abi.encodePacked(
                    routeStr,
                    '"',
                    symbol,
                    Strings.toString(shipInfo.route[i].tokenId),
                    '"',
                    suffix
                )
            );
        }

        string memory attrOutput = string(
            abi.encodePacked(
                '[{ "trait_type": "Name", "value": "',
                shipInfo.name,
                '" }, { "trait_type": "Expedition", "value": "',
                shipInfo.expedition,
                '" }, { "trait_type": "Length (ft)", "display_type": "number", "value": ',
                Strings.toString(uint256(shipInfo.length)),
                ' }, { "trait_type": "Speed (km/h)", "display_type": "number", "value": ',
                Strings.toString(uint256(shipInfo.speed)),
                ' }, { "trait_type": "Trade Route", "value": [',
                routeStr,
                "]"
            )
        );

        attrOutput = string(abi.encodePacked(attrOutput, " }]"));

        return attrOutput;
    }

    function tokenURI(uint256 tokenId) external view returns (string memory) {
        Ships.Ship memory shipInfo = shipsContract.getShipInfo(tokenId);

        string memory imageOutput = getImageOutput(shipInfo);
        string memory attrOutput = getAttrOutput(shipInfo);

        string memory json = Base64.encode(
            bytes(
                string(
                    abi.encodePacked(
                        '{"name": "Ship #',
                        Strings.toString(tokenId),
                        '", "description": "Ships can sail around the Settlements world to trade, discover and attack. All data is onchain.", "image": "data:image/svg+xml;base64,',
                        Base64.encode(bytes(imageOutput)),
                        '", "attributes": ',
                        attrOutput,
                        "}"
                    )
                )
            )
        );

        return string(abi.encodePacked("data:application/json;base64,", json));
    }
}// MIT
pragma solidity ^0.8.4;



contract Ships is ERC721, ERC721Enumerable, Ownable {
    struct Attributes {
        uint8 name;
        uint8 expedition;
        uint32 length;
        uint32 speed;
    }

    struct Path {
        address tokenContract;
        uint256 tokenId;
    }

    struct Ship {
        uint256 tokenId;
        string name;
        string expedition;
        uint32 length;
        uint32 speed;
        Path[] route;
    }

    struct TokenHarvest {
        address resourceTokenContract;
        uint256 amount;
    }

    string[] public names = ["Canoe", "Longship", "Clipper", "Galleon", "Man-of-war"];
    string[] public expeditions = ["Trader", "Explorer", "Pirate", "Military", "Diplomat"];

    uint32[] public speedMultipliers = [10, 20, 50, 40, 40];
    uint32[] public lengthMultipliers = [5, 10, 10, 30, 40];

    ShipsHelper public helperContract;
    ERC20Mintable public goldTokenContract;

    mapping(uint256 => Attributes) public tokenIdToAttributes;
    mapping(uint256 => Path[]) public tokenIdToRoute;
    mapping(uint256 => uint256) public tokenIdToLastRouteUpdate;

    uint256 purchasedShipsCount = 1000;
    uint256 maxPurchaseLimit = 10_000;

    mapping(address => bool) permissionedMinters;

    constructor(ERC20Mintable goldTokenContract_) ERC721("Ships", "SHIP") {
        goldTokenContract = goldTokenContract_;
    }

    function setHelperContract(ShipsHelper helperContract_) public onlyOwner {
        helperContract = helperContract_;
    }

    function setMaxPurchaseLimit(uint256 maxPurchaseLimit_) public onlyOwner {
        maxPurchaseLimit = maxPurchaseLimit_;
    }

    function togglePermissionedMinter(address minter, bool enabled) public onlyOwner {
        permissionedMinters[minter] = enabled;
    }

    function getShipInfo(uint256 tokenId) public view returns (Ship memory) {
        require(_exists(tokenId), "Ship with that tokenId doesn't exist");

        Attributes memory attr = tokenIdToAttributes[tokenId];

        return
            Ship({
                tokenId: tokenId,
                name: names[attr.name],
                expedition: expeditions[attr.expedition],
                length: attr.length,
                speed: attr.speed,
                route: tokenIdToRoute[tokenId]
            });
    }

    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        return helperContract.tokenURI(tokenId);
    }

    function getTokenIdToAttributes(uint256 tokenId) public view returns (Attributes memory) {
        return tokenIdToAttributes[tokenId];
    }

    function getRandomNumber(bytes memory seed, uint256 maxValue) public pure returns (uint256) {
        return uint256(keccak256(abi.encode(seed))) % maxValue;
    }

    function getUnharvestedTokens(uint256 tokenId) public view returns (TokenHarvest[] memory) {
        return helperContract.getUnharvestedTokens(tokenId);
    }

    function getSailingDuration(uint256 tokenId) public view returns (uint256) {
        Ship memory shipInfo = getShipInfo(tokenId);
        return helperContract.getSailingDuration(shipInfo);
    }

    function mint(uint256 tokenId) public {
        require(!_exists(tokenId), "Ship with that id already exists");
        require(tokenId <= 999, "Ship id is invalid");

        uint256 value = getRandomNumber(abi.encode(tokenId, "n", block.timestamp), 1000);
        uint8 name = uint8(value < 900 ? value % 3 : value < 950 ? value % 4 : value % 5);

        _mintShip(name, tokenId);
    }

    function permissionedMint(
        uint256 tokenId,
        Attributes memory attr,
        Path[] memory route
    ) public {
        require(permissionedMinters[msg.sender], "You are not a permissioned minter");
        require(!_exists(tokenId), "Can't mint token that already exists");

        tokenIdToAttributes[tokenId] = attr;
        _updateRoute(route, tokenId, true);
        _safeMint(msg.sender, tokenId);
    }

    function harvest(uint256 tokenId) public {
        TokenHarvest[] memory unharvestedTokens = getUnharvestedTokens(tokenId);
        tokenIdToLastRouteUpdate[tokenId] = block.number;

        uint256 totalGoldTax = 0;
        for (uint256 i = 0; i < unharvestedTokens.length; i++) {
            ERC20Mintable(unharvestedTokens[i].resourceTokenContract).mint(
                ownerOf(tokenId),
                unharvestedTokens[i].amount
            );

            totalGoldTax += (unharvestedTokens[i].amount * 6) / 100;
        }

        address taxDestination = helperContract.getTaxDestination(tokenId);
        goldTokenContract.mint(taxDestination, totalGoldTax);
    }

    function updateRoute(Path[] memory route, uint256 tokenId) public {
        _updateRoute(route, tokenId, false);
    }

    function _updateRoute(
        Path[] memory route,
        uint256 tokenId,
        bool init
    ) internal {
        require(helperContract.isValidRoute(route, tokenId, msg.sender, init), "Invalid route");

        delete tokenIdToRoute[tokenId];
        for (uint256 i = 0; i < route.length; i++) {
            tokenIdToRoute[tokenId].push(route[i]);
        }

        tokenIdToLastRouteUpdate[tokenId] = block.number;
    }

    function purchaseShip(uint8 name) public {
        require(
            purchasedShipsCount <= maxPurchaseLimit,
            "Maximum amount of ships have been purchased"
        );

        TokenHarvest[] memory cost = helperContract.getCost(name);
        for (uint256 i = 0; i < cost.length; i++) {
            ERC20Mintable(cost[i].resourceTokenContract).burnFrom(msg.sender, cost[i].amount);
        }

        purchasedShipsCount += 1;
        _mintShip(name, purchasedShipsCount);
    }

    function _mintShip(uint8 name, uint256 tokenId) internal {
        Attributes memory attr;

        attr.name = name;

        uint256 value = getRandomNumber(abi.encode(tokenId, "c"), 1000);
        attr.expedition = uint8(value % 5);

        value = getRandomNumber(abi.encode(tokenId, "l"), 50);
        attr.length = uint32((value + 1) * uint256(lengthMultipliers[attr.name])) / 10 + 2;
        attr.length = attr.length < lengthMultipliers[attr.name]
            ? lengthMultipliers[attr.name]
            : attr.length;

        value = getRandomNumber(abi.encode(tokenId, "s"), 100);
        attr.speed = uint32((value + 1) * uint256(speedMultipliers[attr.name])) / 100 + 2;
        attr.speed = attr.speed < speedMultipliers[attr.name] / 2
            ? speedMultipliers[attr.name] / 2
            : attr.speed;

        tokenIdToAttributes[tokenId] = attr;

        _updateRoute(helperContract.getInitialRoute(tokenId, attr.name), tokenId, true);
        _safeMint(msg.sender, tokenId);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal override(ERC721, ERC721Enumerable) {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}