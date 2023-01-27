
pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

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
}

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
}

pragma solidity ^0.8.0;

interface IERC721Receiver {

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);

}

pragma solidity ^0.8.0;

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}

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

}

pragma solidity ^0.8.0;


interface IERC721Metadata is IERC721 {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function tokenURI(uint256 tokenId) external view returns (string memory);

}

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
}

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
}

pragma solidity ^0.8.0;


abstract contract ERC165 is IERC165 {
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}

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

}

pragma solidity ^0.8.0;


interface IERC721Enumerable is IERC721 {
    function totalSupply() external view returns (uint256);

    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256 tokenId);

    function tokenByIndex(uint256 index) external view returns (uint256);
}

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
}

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
}

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
}

pragma solidity ^0.8.0;


interface IERC20Metadata is IERC20 {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

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
}
                                                

pragma solidity ^0.8.0;


contract Fluff is ERC20, Ownable {
    address public hammieAddress;
    address public galaxyAddress;
    
    mapping(address => bool) public allowedAddresses;

    constructor() ERC20("Fluff", "FLF") {}
    
    function setHammieAddress(address hammieAddr) external onlyOwner {
        hammieAddress = hammieAddr;
    }
    
    function setGalaxyAddress(address galaxyAddr) external onlyOwner {
        galaxyAddress = galaxyAddr;
    }
    
    function burn(address user, uint256 amount) external {
        require(msg.sender == galaxyAddress || msg.sender == hammieAddress, "Address not authorized");
        _burn(user, amount);
    }
    
    function mint(address to, uint256 value) external {
        require(msg.sender == galaxyAddress || msg.sender == hammieAddress, "Address not authorized");
        _mint(to, value);
    }
}// ___  ___  ________  _____ ______   _____ ______   ___  _______           ________  ________  _____ ______   _______      


pragma solidity ^0.8.0;


contract Hammies is ERC721Enumerable, Ownable {
    using SafeMath for uint256;
    using Counters for Counters.Counter;
    using Strings for uint256;
    
    Counters.Counter private _tokenIdTracker;

    Fluff fluff;
    
    uint256 public maxFreeSupply = 888;
    uint256 public constant maxPublicSupply = 4888;
    uint256 public constant maxTotalSupply = 8888;
    uint256 public constant mintPrice = 0.06 ether;
    uint256 public constant maxPerTx = 10;
    uint256 public constant maxFreePerWallet = 10;

    address public constant dev1Address = 0xcd2367Fcfbd8bf8eF87C98fC53Cc2EA27437f6EE;
    address public constant dev2Address = 0x2E824997ACE675F5BdB0d56121Aa04B2599BDa8B;

    bool mintActive = false;
    bool public fluffMinting = false;
    
    mapping(address => uint256) public freeMintsClaimed; //Track free mints claimed per wallet
    
    string public baseTokenURI;

    constructor() ERC721("Hammies", "HG") {}
    
    
    function toggleMint() public onlyOwner {
        mintActive = !mintActive;
    }

    function mint(uint256 _count) public payable {
        uint256 total = _totalSupply();
        require(mintActive, "Sale has not begun");
        require(total + _count <= maxPublicSupply, "No hammies left");
        require(_count <= maxPerTx, "10 max per tx");
        require(msg.value >= price(_count), "Not enough eth sent");

        for (uint256 i = 0; i < _count; i++) {
            _mintHammie(msg.sender);
        }
    }
    
    function freeMint(uint256 _count) public {
        uint256 total = _totalSupply();
        require(mintActive, "Public Sale is not active");
        require(total + _count <= maxFreeSupply, "No more free hammies");
        require(_count + freeMintsClaimed[msg.sender] <= maxFreePerWallet, "Only 10 free mints per wallet");
        require(_count <= maxPerTx, "10 max per tx");

        for (uint256 i = 0; i < _count; i++) {
            freeMintsClaimed[msg.sender]++;
            _mintHammie(msg.sender);
        }
    }
    
    function mintHammieForFluff() public {
        uint256 total = _totalSupply();
        require(total < maxTotalSupply, "No Hammies left");
        require(fluffMinting, "Minting with $fluff has not begun");
        fluff.burn(msg.sender, getFluffCost(total));
        _mintHammie(msg.sender);
    }
    
    function getFluffCost(uint256 totalSupply) internal pure returns (uint256 cost){
        if (totalSupply < 5888)
            return 100;
        else if (totalSupply < 6887)
            return 200;
        else if (totalSupply < 7887)
            return 400;
        else if (totalSupply < 8887)
            return 800;
    }
    
    function _mintHammie(address _to) private {
        uint id = _tokenIdTracker.current();
        _tokenIdTracker.increment();
        _safeMint(_to, id);
    }

    function price(uint256 _count) public pure returns (uint256) {
        return mintPrice.mul(_count);
    }
    

    function setFluffAddress(address fluffAddr) external onlyOwner {
        fluff = Fluff(fluffAddr);
    }
    
    function _baseURI() internal view virtual override returns (string memory) {
        return baseTokenURI;
    }

    function toggleFluffMinting() public onlyOwner {
        fluffMinting = !fluffMinting;
    }
    
    function setBaseURI(string memory baseURI) public onlyOwner {
        baseTokenURI = baseURI;
    }
    
    function withdrawAll() public onlyOwner {
        uint256 balance = address(this).balance;
        uint256 dev1Share = balance.mul(50).div(100);
        uint256 dev2Share = balance.mul(50).div(100);

        require(balance > 0);
        _withdraw(dev1Address, dev1Share);
        _withdraw(dev2Address, dev2Share);
    }

    function _withdraw(address _address, uint256 _amount) private {
        (bool success, ) = _address.call{value: _amount}("");
        require(success, "Transfer failed.");
    }
    
    function _totalSupply() public view returns (uint) {
        return _tokenIdTracker.current();
    }
}// ________  ________  ___       ________     ___    ___ ___    ___ 
                                                                  

pragma solidity ^0.8.0;


contract Galaxy is Ownable, IERC721Receiver {
    using SafeMath for uint256;
    
    Hammies hammies;
    
    Fluff fluff;

    event HammieStolen(address previousOwner, address newOwner, uint256 tokenId);
    event HammieStaked(address owner, uint256 tokenId, uint256 status);
    event HammieClaimed(address owner, uint256 tokenId);
    
    struct tokenInfo {
        uint256 tokenId;
        address owner;
        uint256 status;
        uint256 timeStaked;
    }
    
    mapping(uint256 => tokenInfo) public galaxy;

    mapping(uint256 => uint256) public fluffStolen;
    
    uint256 public adventuringFluffRate = 100 ether;
    uint256 public totalAdventurersStaked = 0;
    uint256 public adventurerShare = 50;
    
    uint256 public pirateShare = 50;
    uint256 public chancePirateGetsLost = 5;
    
    uint256[] public piratesStaked;
    mapping(uint256 => uint256) public pirateIndices;

    uint256[] public salvagersStaked;
    mapping(uint256 => uint256) public salvagerIndices;
    
    uint256 public minStakeTime = 1 days;
    
    bool public staking = false;
    
    mapping (address => uint256) public claimableHammies;
    uint256 public totalSupply = 4889;

    constructor(){}
    
    function claimLostHammiesAndStake(uint256 _count, bool stake, uint256 status) public {
        uint256 numReserved = claimableHammies[msg.sender];
        require(numReserved > 0, "You do not have any claimable Hammies");
        require(_count <= numReserved, "You do not have that many Claimable Hammies");
        claimableHammies[msg.sender] = numReserved - _count;

        for (uint256 i = 0; i < _count; i++) {
            uint256 tokenId = totalSupply + i;
            hammies.mintHammieForFluff();
            if(stake){
                galaxy[tokenId] = tokenInfo({
                    tokenId: tokenId,
                    owner: msg.sender,
                    status: status,
                    timeStaked: block.timestamp
                });
                if (status == 1)
                    totalAdventurersStaked++;
                else if (status == 2){
                    piratesStaked.push(tokenId);
                    pirateIndices[tokenId] = piratesStaked.length - 1;
                }
                else if (status == 3){
                    salvagersStaked.push(tokenId);
                    salvagerIndices[tokenId] = salvagersStaked.length - 1;

                }
            } else {
                hammies.safeTransferFrom(address(this), msg.sender, tokenId);
            }
        }
        uint256 fluffOwed = _count * 100 ether;
        fluff.mint(msg.sender, fluffOwed);
        totalSupply += _count;
    }
    
    function editHammiesClaimable(address[] calldata addresses, uint256[] calldata count) external onlyOwner {
        for(uint256 i; i < addresses.length; i++){
            claimableHammies[addresses[i]] = count[i];
        }
    }

    function mintHammieForFluff(bool stake, uint256 status) public {
        require(staking, "Staking is paused");
        fluff.burn(msg.sender, getFluffCost(totalSupply));
        hammies.mintHammieForFluff();
        uint256 tokenId = totalSupply;
        totalSupply++;
        if(stake){
            galaxy[tokenId] = tokenInfo({
                tokenId: tokenId,
                owner: msg.sender,
                status: status,
                timeStaked: block.timestamp
            });
            if (status == 1)
                totalAdventurersStaked++;
            else if (status == 2){
                piratesStaked.push(tokenId);
                pirateIndices[tokenId] = piratesStaked.length - 1;
            }
            else if (status == 3){
                salvagersStaked.push(tokenId);
                salvagerIndices[tokenId] = salvagersStaked.length - 1;
            } 
        } else {
            hammies.safeTransferFrom(address(this), msg.sender, tokenId);
        }

    }
    
    function getFluffCost(uint256 supply) internal pure returns (uint256 cost){
        if (supply < 5888)
            return 100 ether;
        else if (supply < 6887)
            return 200 ether;
        else if (supply < 7887)
            return 400 ether;
        else if (supply < 8887)
            return 800 ether;
    }

    
    function sendManyToGalaxy(uint256[] calldata ids, uint256 status) external {
        for(uint256 i = 0; i < ids.length; i++){
            require(hammies.ownerOf(ids[i]) == msg.sender, "Not your Hammie");
            require(staking, "Staking is paused");

            galaxy[ids[i]] = tokenInfo({
                tokenId: ids[i],
                owner: msg.sender,
                status: status,
                timeStaked: block.timestamp
            });

            emit HammieStaked(msg.sender, ids[i], status);
            hammies.transferFrom(msg.sender, address(this), ids[i]);

            if (status == 1)
                totalAdventurersStaked++;
            else if (status == 2){
                piratesStaked.push(ids[i]);
                pirateIndices[ids[i]] = piratesStaked.length - 1;
            }
            else if (status == 3){
                salvagersStaked.push(ids[i]);
                salvagerIndices[ids[i]] = salvagersStaked.length - 1;

            }
        }
    }
    
    function unstakeManyHammies(uint256[] calldata ids) external {
        for(uint256 i = 0; i < ids.length; i++){
            tokenInfo memory token = galaxy[ids[i]];
            require(token.owner == msg.sender, "Not your Hammie");
            require(hammies.ownerOf(ids[i]) == address(this), "Hammie must be staked in order to claim");
            require(staking, "Staking is paused");
            require(block.timestamp - token.timeStaked >= minStakeTime, "1 day stake lock");

            _claim(msg.sender, ids[i]);

            if (token.status == 1){       
                totalAdventurersStaked--;
            }
            else if (token.status == 2){
                uint256 lastPirate = piratesStaked[piratesStaked.length - 1];
                piratesStaked[pirateIndices[ids[i]]] = lastPirate;
                pirateIndices[lastPirate] = pirateIndices[ids[i]];
                piratesStaked.pop();
            }
            else if (token.status == 3){
                uint256 lastSalvager = salvagersStaked[salvagersStaked.length - 1];
                salvagersStaked[salvagerIndices[ids[i]]] = lastSalvager;
                salvagerIndices[lastSalvager] = salvagerIndices[ids[i]];
                salvagersStaked.pop();
            } 

            emit HammieClaimed(address(this), ids[i]);

            tokenInfo memory newToken = galaxy[ids[i]];
            hammies.safeTransferFrom(address(this), newToken.owner, ids[i]);
            galaxy[ids[i]] = tokenInfo({
                tokenId: ids[i],
                owner: newToken.owner,
                status: 0,
                timeStaked: block.timestamp
            });
        }
    }

    function claimManyHammies(uint256[] calldata ids) external {
        for(uint256 i = 0; i < ids.length; i++){
            tokenInfo memory token = galaxy[ids[i]];
            require(token.owner == msg.sender, "Not your hammie");
            require(hammies.ownerOf(ids[i]) == address(this), "Hammie must be staked in order to claim");
            require(staking, "Staking is paused");
            
            _claim(msg.sender, ids[i]);
            emit HammieClaimed(address(this), ids[i]);

            tokenInfo memory newToken = galaxy[ids[i]];
            galaxy[ids[i]] = tokenInfo({
                tokenId: ids[i],
                owner: newToken.owner,
                status: newToken.status,
                timeStaked: block.timestamp
            });
        }
    }
    
    function _claim(address owner, uint256 tokenId) internal {
        tokenInfo memory token = galaxy[tokenId];
        if (token.status == 1){
            if(piratesStaked.length > 0){
                uint256 fluffGathered = getPendingFluff(tokenId);
                fluff.mint(owner, fluffGathered.mul(adventurerShare).div(100));
                stealFluff(fluffGathered.mul(pirateShare).div(100));
            }
            else {
                fluff.mint(owner, getPendingFluff(tokenId));
            }            
        }
        else if (token.status == 2){
            uint256 roll = randomIntInRange(tokenId, 100);
            if(roll > chancePirateGetsLost || salvagersStaked.length == 0){
                fluff.mint(owner, fluffStolen[tokenId]);
                fluffStolen[tokenId ]= 0;
            } else{
                getNewOwnerForPirate(roll, tokenId);
            }
        }
    }
    
    function getFluffEarnings(uint256 id) public view returns(uint256) {
        return getPendingFluff(id);
    }

    function getPendingFluff(uint256 id) internal view returns(uint256) {
        tokenInfo memory token = galaxy[id];
        return (block.timestamp - token.timeStaked) * 100 ether / 1 days;
    }
    
    function randomIntInRange(uint256 seed, uint256 max) internal view returns (uint256) {
        return uint256(keccak256(abi.encodePacked(
            tx.origin,
            blockhash(block.number - 1),
            block.timestamp,
            seed
        ))) % max;
    }
    
    function stealFluff(uint256 amount) internal{
        uint256 roll = randomIntInRange(amount, piratesStaked.length);
        fluffStolen[piratesStaked[roll]] += amount;
    }

    function getNewOwnerForPirate(uint256 seed, uint256 tokenId) internal{
        tokenInfo memory pirate = galaxy[tokenId];
        uint256 roll = randomIntInRange(seed, salvagersStaked.length);
        tokenInfo memory salvager = galaxy[salvagersStaked[roll]];
        emit HammieStolen(pirate.owner, salvager.owner, tokenId);
        galaxy[tokenId] = tokenInfo({
                tokenId: tokenId,
                owner: salvager.owner,
                status: 2,
                timeStaked: block.timestamp
        });
        fluff.mint(salvager.owner, fluffStolen[tokenId]);
        fluffStolen[tokenId] = 0;
    }
      
    function getTotalSalvagersStaked() public view returns (uint256) {
        return salvagersStaked.length;
    }

    function getTotalPiratesStaked() public view returns (uint256) {
        return piratesStaked.length;
    }

    function setHammieAddress(address hammieAddr) external onlyOwner {
        hammies = Hammies(hammieAddr);
    }
    
    function setFluffAddress(address fluffAddr) external onlyOwner {
        fluff = Fluff(fluffAddr);
    }
    
    function toggleStaking() public onlyOwner {
        staking = !staking;
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