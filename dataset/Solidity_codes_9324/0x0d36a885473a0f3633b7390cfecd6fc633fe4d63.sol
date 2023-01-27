
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
}// MIT LICENSE 

pragma solidity ^0.8.1;

interface ITraits {

  function tokenURI(uint256 tokenId) external view returns (string memory);

  function selectTrait(uint16 seed, uint8 traitType) external view returns(uint8);

}// MIT LICENSE

pragma solidity ^0.8.1;

interface IWildAbduction {


    struct CowboyAlien {
        bool isCowboy;
        bool isMutant;
        uint8 pants;
        uint8 top;
        uint8 hat;
        uint8 weapon;
        uint8 accessory;
        uint8 alphaIndex;
    }

    function minted() external returns (uint16);

    function mint(address recipient, uint256 seed) external;

    function burn(uint256 tokenId) external;

    function getPaidTokens() external view returns (uint256);

    function getTokenTraits(uint256 tokenId) external view returns (CowboyAlien memory);

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

    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
        }
        _balances[to] += amount;

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
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

    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
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
}// MIT LICENSE

pragma solidity ^0.8.1;

contract LAND is ERC20, Ownable {

    mapping(address => bool) controllers;

    constructor() ERC20("LAND", "LAND") { }

    function mint(address to, uint256 amount) external {
        require(controllers[msg.sender], "Only controllers can mint");
        _mint(to, amount);
    }

    function burn(address from, uint256 amount) external {
        require(controllers[msg.sender], "Only controllers can burn");
        _burn(from, amount);
    }

    function addController(address controller) external onlyOwner {
        controllers[controller] = true;
    }

    function removeController(address controller) external onlyOwner {
        controllers[controller] = false;
    }
}// MIT LICENSE

pragma solidity ^0.8.1;

interface ILAND {
    function mint(address to, uint256 amount) external;
    function burn(address from, uint256 amount) external;
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}// MIT LICENSE
pragma solidity ^0.8.0;

interface IRandomizer {
    function random() external view returns (uint256);
    function randomCall() external;
}// MIT LICENSE

pragma solidity ^0.8.1;


contract WAGGame is Ownable, Pausable, ERC721Enumerable {

    bool private _reentrant = false;

    modifier nonReentrant() {
        require(!_reentrant, "No reentrancy");
        _reentrant = true;
        _;
        _reentrant = false;
    }

    struct Whitelist {
    bool isWhitelisted;
    uint16 numMinted;
    bool freeMint;
    }

    bool public hasPublicSaleStarted;
    uint256 public presalePrice = 0.025 ether;
    uint256 public publicPrice = 0.04 ether;
    uint256 maxLandCost = 70000 ether;
    uint256 maxTokens = 40000;
    uint256 private startedTime;

    mapping (address => Whitelist) private _whitelistAddresses;
    mapping (address => bool) private _freeMintAddresses;

    ILAND public land;
    ITraits public traits;
    IWildAbduction wagNFT;
    IBank bank;

    constructor(ILAND _land, ITraits _traits, IWildAbduction _wagNFT) ERC721("WAG Game", 'WGAME') {
        land = _land;
        hasPublicSaleStarted = false;
        wagNFT = _wagNFT;
        _pause;
        traits = _traits;
        startedTime = block.timestamp;
    }

    modifier requireContractsSet() {
      require(address(land) != address(0) && address(traits) != address(0) 
        && address(wagNFT) != address(0) && address(bank) != address(0)
        , "Contracts not set");
      _;
    }

    function setBank(address _bank) external onlyOwner {
        bank = IBank(_bank);
    }
    



     function mint(uint256 amount, bool stake) external payable whenNotPaused nonReentrant requireContractsSet {
        require(tx.origin == _msgSender(), "Only EOA");
        uint16 minted = wagNFT.minted();
        uint256 paidTokens = wagNFT.getPaidTokens();
        require(amount + minted <= maxTokens);
        require(amount > 0 && amount <= 20, "Invalid mint amount");

        if (minted < paidTokens) {
            require(minted + amount <= paidTokens, "All gen 0's minted");
            if (hasPublicSaleStarted) {
                require(msg.value >= amount * publicPrice, "Invalid payment amount");
            } else {
                require(_whitelistAddresses[_msgSender()].isWhitelisted, "Not on whitelist");
                if (_whitelistAddresses[_msgSender()].freeMint == true) {
                    require(msg.value == (amount * presalePrice) - presalePrice);
                    _whitelistAddresses[_msgSender()].freeMint = false;
                } else {
                    require(msg.value == amount * presalePrice, "Invalid payment amount");
                }
                require(_whitelistAddresses[_msgSender()].numMinted + amount <= 20, "too many mints");
                _whitelistAddresses[_msgSender()].numMinted += uint16(amount);
            }
        } else {
            require(msg.value == 0);
        }

        uint256 totalLandCost = 0;
        uint16[] memory tokenIds = new uint16[](amount);
        uint256 seed = 0;

        for  (uint i = 0; i < amount; i++) {
            minted++;
            seed = random(minted);
            address recipient = _msgSender();

            if (minted <= paidTokens || ((seed >> 245) % 10) != 0) {
                recipient = _msgSender();
            } else {
                recipient = bank.randomAlienOwner(seed >> 144);
                if (recipient == address(0x0)) {
                    recipient = _msgSender();
                }
            }

            tokenIds[i] = minted;
            if (!stake || recipient != _msgSender()) {
                wagNFT.mint(recipient, seed);
            } else {
                wagNFT.mint(address(bank), seed);
            }
            totalLandCost += mintCost(minted, paidTokens);
        }

        if (totalLandCost > 0) {
            land.burn(_msgSender(), totalLandCost);
        }

        if (stake) {
            bank.addManyToBankAndPack(_msgSender(), tokenIds);
        }
    }

    function addToWhitelist(address[] calldata addressesToAdd, bool freeMint) external onlyOwner {
        for (uint256 i = 0; i < addressesToAdd.length; i++) {
            _whitelistAddresses[addressesToAdd[i]] = Whitelist(true, 0, freeMint);
        }
    }

    function setPublicSaleStart(bool started) external onlyOwner {
        hasPublicSaleStarted = started;
        if(hasPublicSaleStarted) {
            startedTime = block.timestamp;
        }
    } 

    function mintCost(uint256 tokenId, uint256 paidTokens) public view returns (uint256) {
        if (tokenId <= paidTokens) return 0;
        if (tokenId <= maxTokens * 1 / 2) return 20000 ether;
        if (tokenId <= maxTokens * 3 / 4) return 40000 ether;
        return 70000 ether;
    }


    function selectRecipient(uint256 seed, uint256 minted, uint256 paidTokens) internal view returns (address) {
        if (minted <= paidTokens || ((seed >> 245) % 10) != 0) return _msgSender(); // top 10 bits haven't been used
        address thief = bank.randomAlienOwner(seed >> 144); // 144 bits reserved for trait selection
        if (thief == address(0x0)) return _msgSender();
        return thief;
    }

    function random(uint256 seed) internal view returns (uint256) {
        return
            uint256(
                keccak256(
                    abi.encodePacked(
                        tx.origin,
                        blockhash(block.number - 1),
                        block.timestamp,
                        seed
                    )
                )
            );
    }

    
    function setPaused(bool _paused) external requireContractsSet onlyOwner {
        if (_paused) _pause();
        else _unpause();
    }

    function setmaxLandCost(uint256 _amount) external requireContractsSet onlyOwner {
        maxLandCost = _amount;
    } 

    function withdraw() external onlyOwner {
        payable(owner()).transfer(address(this).balance);
    }

}// MIT LICENSE

pragma solidity ^0.8.1;


contract Bank is Ownable, IERC721Receiver, Pausable {

    uint8 public constant MAX_ALPHA = 8;

    struct Stake {
        uint16 tokenId;
        uint80 value;
        address owner;
    }

    event CowboyStaked(address owner, uint256 tokenId, uint256 value);
    event MutantStaked(address owner, uint256 tokenId, uint256 value);
    event AlienStaked(address owner, uint256 tokenId, uint256 value);
    event CowboyClaimed(uint256 indexed tokenId, bool indexed unstaked, uint256 earned);
    event MutantClaimed(uint256 indexed tokenId, bool indexed unstaked, uint256 earned);
    event AlienClaimed(uint256 indexed tokenId, bool indexed unstaked, uint256 earned);

    WildAbduction public game;
    WAGGame public wag;
    ILAND public land;

    mapping(uint256 => Stake) public bank;
    mapping(uint256 => Stake[]) public pack;
    mapping(uint256 => uint256) public packIndices;
    uint256 public totalAlphaStaked = 0;
    uint256 public unaccountedRewards = 0;
    uint256 public LANDPerAlpha = 0;

    uint256 public DAILY_LAND_RATE = 9000 ether;

    uint256 public MUTANT_DAILY_LAND_RATE = 27000 ether;

    uint256 public MINIMUM_TO_EXIT = 2 days;
    uint256 public constant LAND_CLAIM_TAX_PERCENTAGE = 20;
    uint256 public MASTER_TAX = 30;
    uint256 public constant MAXIMUM_GLOBAL_LAND = 2400000000 ether;

    uint256 public totalLANDEarned;
    uint256 public totalCowboyStaked;
    uint256 public totalMutantStaked;
    uint256 public lastClaimTimestamp;

    bool public rescueEnabled = false;

    bool private _reentrant = false;

    modifier nonReentrant() {
        require(!_reentrant, "No reentrancy");
        _reentrant = true;
        _;
        _reentrant = false;
    }

    constructor() {}

    function setContracts(address _game, address _land, address _wag) external onlyOwner {
        game = WildAbduction(_game);
        land = ILAND(_land);
        wag = WAGGame(_wag);
    }


    function addManyToBankAndPack(address account, uint16[] calldata tokenIds) external nonReentrant {
        require( _msgSender() == tx.origin || _msgSender() == address(wag), "DONT GIVE YOUR TOKENS AWAY");
        require(account == tx.origin, "account to token mismatch");

        for (uint i = 0; i < tokenIds.length; i++) {
            if (tokenIds[i] == 0) {
                continue;
            }

            if (_msgSender() != address(wag)) {// dont do this step if its a mint + stake
                require(game.ownerOf(tokenIds[i]) == _msgSender(), "NOT YOUR TOKEN");
                game.transferFrom(_msgSender(), address(this), tokenIds[i]);
            }
            if (isMutant(tokenIds[i]))
                _addCowboyToBank(account, tokenIds[i], true);
            else if (isCowboy(tokenIds[i]))
                _addCowboyToBank(account, tokenIds[i], false);
            else
                _addAlienToBank(account, tokenIds[i]);
        }
    }

    function _addCowboyToBank(address account, uint256 tokenId, bool _mutant) internal whenNotPaused _updateEarnings {
        bank[tokenId] = Stake({
        owner : account,
        tokenId : uint16(tokenId),
        value : uint80(block.timestamp)
        });
        
        if (_mutant) {
            totalMutantStaked += 1;
            emit MutantStaked(account, tokenId, block.timestamp);
        } else {
            totalCowboyStaked += 1;
            emit CowboyStaked(account, tokenId, block.timestamp);
        }
    }

    function _addAlienToBank(address account, uint256 tokenId) internal {
        uint256 alpha = _alphaForAlien(tokenId);
        totalAlphaStaked += alpha;
        packIndices[tokenId] = pack[alpha].length;
        pack[alpha].push(Stake({
        owner : account,
        tokenId : uint16(tokenId),
        value : uint80(LANDPerAlpha)
        }));
        emit AlienStaked(account, tokenId, LANDPerAlpha);
    }


    function claimManyFromBankAndPack(uint16[] calldata tokenIds, bool unstake) external nonReentrant whenNotPaused _updateEarnings {
        require(_msgSender() == tx.origin || _msgSender() == address(wag) , "Only EOA");
        uint256 owed = 0;
        for (uint i = 0; i < tokenIds.length; i++) {
            if (isMutant(tokenIds[i]))
                owed += _claimCowboyFromBank(tokenIds[i], unstake, false);
            else if (isCowboy(tokenIds[i]))
                owed += _claimCowboyFromBank(tokenIds[i], unstake, true);
            else
                owed += _claimAlienFromPack(tokenIds[i], unstake);
        }

        owed *= (100 - MASTER_TAX) / 100;

        if (owed == 0) return;
        land.mint(_msgSender(), owed);
    }

    function _claimCowboyFromBank(uint256 tokenId, bool unstake, bool cowboy) internal returns (uint256 owed) {
        Stake memory stake = bank[tokenId];
        require(stake.owner == _msgSender(), "SWIPER, NO SWIPING");
        require(!(unstake && block.timestamp - stake.value < MINIMUM_TO_EXIT), "GONNA BE COLD WITHOUT TWO DAY'S LAND");

        uint256 unstaking_rate = DAILY_LAND_RATE;
        if (!cowboy) {
            unstaking_rate = MUTANT_DAILY_LAND_RATE;
        }

        if (totalLANDEarned < MAXIMUM_GLOBAL_LAND) {
            owed = (block.timestamp - stake.value) * unstaking_rate / 1 days;
        } else if (stake.value > lastClaimTimestamp) {
            owed = 0;
        } else {
            owed = (lastClaimTimestamp - stake.value) * unstaking_rate / 1 days;
        }

        if (unstake) {
            if (cowboy) {
                if (random(block.timestamp) & 1 == 1) {// 50% chance of all $LAND stolen
                _payAlienTax(owed);
                owed = 0;
                totalCowboyStaked -= 1;
                }
            } else {
                totalMutantStaked -= 1;
            }
            
            game.transferFrom(address(this), _msgSender(), tokenId);
            delete bank[tokenId];
            

        } else {
            if (cowboy) {
                _payAlienTax(owed * LAND_CLAIM_TAX_PERCENTAGE / 100);
                owed = owed * (100 - LAND_CLAIM_TAX_PERCENTAGE) / 100;
            }
            bank[tokenId] = Stake({
                owner : _msgSender(),
                tokenId : uint16(tokenId),
                value : uint80(block.timestamp)
                });
        }
        if (cowboy) {
            emit CowboyClaimed(tokenId, unstake, owed);
        } else {
            emit MutantClaimed(tokenId, unstake, owed);
        }
    }

    function _claimAlienFromPack(uint256 tokenId, bool unstake) internal returns (uint256 owed) {
        require(game.ownerOf(tokenId) == address(this), "AINT A PART OF THE PACK");
        uint256 alpha = _alphaForAlien(tokenId);
        Stake memory stake = pack[alpha][packIndices[tokenId]];
        require(stake.owner == _msgSender(), "SWIPER, NO SWIPING");
        owed = (alpha) * (LANDPerAlpha - stake.value);
        if (unstake) {
            totalAlphaStaked -= alpha;
            game.transferFrom(address(this), _msgSender(), tokenId);
            Stake memory lastStake = pack[alpha][pack[alpha].length - 1];
            pack[alpha][packIndices[tokenId]] = lastStake;
            packIndices[lastStake.tokenId] = packIndices[tokenId];
            pack[alpha].pop();
            delete packIndices[tokenId];
        } else {
            pack[alpha][packIndices[tokenId]] = Stake({
            owner : _msgSender(),
            tokenId : uint16(tokenId),
            value : uint80(LANDPerAlpha)
            });
        }
        emit AlienClaimed(tokenId, unstake, owed);
    }


    function _payAlienTax(uint256 amount) internal {
        if (totalAlphaStaked == 0) {// if there's no staked aliens
            unaccountedRewards += amount;
            return;
        }
        LANDPerAlpha += (amount + unaccountedRewards) / totalAlphaStaked;
        unaccountedRewards = 0;
    }

    modifier _updateEarnings() {
        if (totalLANDEarned < MAXIMUM_GLOBAL_LAND) {
            totalLANDEarned +=
            (block.timestamp - lastClaimTimestamp)
            * totalCowboyStaked
            * DAILY_LAND_RATE / 1 days;

            totalLANDEarned +=
            (block.timestamp - lastClaimTimestamp)
            * totalMutantStaked
            * MUTANT_DAILY_LAND_RATE / 1 days;
            lastClaimTimestamp = block.timestamp;
        }
        _;
    }


    function setSettings(uint256 rate, uint256 mutant_rate, uint256 exit) external onlyOwner {
        MINIMUM_TO_EXIT = exit;
        DAILY_LAND_RATE = rate;
        MUTANT_DAILY_LAND_RATE = mutant_rate;
    }

    function setRescueEnabled(bool _enabled) external onlyOwner {
        rescueEnabled = _enabled;
    }

    function setPaused(bool _paused) external onlyOwner {
        if (_paused) _pause();
        else _unpause();
    }

    function reduceMasterTax(uint256 tax) external onlyOwner {
        MASTER_TAX = tax;
    }


    function isCowboy(uint256 tokenId) public view returns (bool Cowboy) {
        (Cowboy, , , , , , ,) = game.tokenTraits(tokenId);
    }

    function isMutant(uint256 tokenId) public view returns (bool Mutant) {
        (,Mutant, , , , , ,) = game.tokenTraits(tokenId);
    }


    function _alphaForAlien(uint256 tokenId) internal view returns (uint8) {
        (, , , , , , , uint8 alphaIndex) = game.tokenTraits(tokenId);
        return MAX_ALPHA - alphaIndex;
    }

    function randomAlienOwner(uint256 seed) external view returns (address) {
        if (totalAlphaStaked == 0) return address(0x0);
        uint256 bucket = (seed & 0xFFFFFFFF) % totalAlphaStaked;
        uint256 cumulative;
        seed >>= 32;
        for (uint i = MAX_ALPHA - 3; i <= MAX_ALPHA; i++) {
            cumulative += pack[i].length * i;
            if (bucket >= cumulative) continue;
            return pack[i][seed % pack[i].length].owner;
        }
        return address(0x0);
    }

    function random(uint256 seed) internal view returns (uint256) {
        return
            uint256(
                keccak256(
                    abi.encodePacked(
                        tx.origin,
                        blockhash(block.number - 1),
                        block.timestamp,
                        seed
                    )
                )
            );
    }

    function onERC721Received(
        address,
        address from,
        uint256,
        bytes calldata
    ) external pure override returns (bytes4) {
        require(from == address(0x0), "Cannot send tokens to Barn directly");
        return IERC721Receiver.onERC721Received.selector;
    }
}// MIT LICENSE

pragma solidity ^0.8.1;


interface IBank {
    function addManyToBankAndPack(address account, uint16[] calldata tokenIds) external;
    function randomAlienOwner(uint256 seed) external view returns (address);
    function bank(uint256) external view returns(uint16, uint80, address);
    function totalLANDEarned() external view returns(uint256);
    function lastClaimTimestamp() external view returns(uint256);
    function setOldTokenInfo(uint256 _tokenId) external;

    function pack(uint256, uint256) external view returns(Bank.Stake memory);
    function packIndices(uint256) external view returns(uint256);

}// MIT LICENSE

pragma solidity ^0.8.1;



contract WildAbduction is IWildAbduction, ERC721Enumerable, Ownable, Pausable {

    struct LastWrite {
        uint64 time;
        uint64 blockNum;
    }

    event CowboyMinted(uint256 indexed tokenId);
    event MutantMinted(uint256 indexed tokenId);
    event AlienMinted(uint256 indexed tokenId);
    event CowboyStolen(uint256 indexed tokenId);
    event CowboyBurned(uint256 indexed tokenId);
    event AlienBurned(uint256 indexed tokenId);


    uint256 public maxTokens;
    uint256 public MUTANT_COUNT;
    uint256 public PAID_TOKENS;
    uint16 public override minted;


    mapping(uint256 => CowboyAlien) public tokenTraits;
    mapping(uint256 => uint256) public existingCombinations;

    IBank public bank;
    ITraits public traits;
    
    mapping(address => bool) private admins;

    constructor(uint256 _maxTokens) ERC721("WAG Game", 'WGAME') {
        maxTokens = _maxTokens;
        admins[msg.sender] = true;
        PAID_TOKENS = 4444;
        _pause();
    }

    function setContracts(address _bank, address _traits) external onlyOwner {
        bank = IBank(_bank);
        traits = ITraits(_traits);
    }


    function mint(address recipient, uint256 seed) external override whenNotPaused {
        require(admins[_msgSender()], "Only admins can call this");
        require(minted + 1 <= maxTokens, "All tokens minted");
        minted++;
        generate(minted, seed);
        if(tx.origin != recipient && recipient != address(bank)) {
            emit CowboyStolen(minted);
        }
        _safeMint(recipient, minted);
    }

    function burn(uint256 tokenId) external override whenNotPaused {
        require(admins[_msgSender()], "Only admins can call this");
        require(ownerOf(tokenId) == tx.origin, "Oops you don't own that");
        if(tokenTraits[tokenId].isCowboy) {
            emit CowboyBurned(tokenId);
        }
        else {
            emit AlienBurned(tokenId);
        }
        _burn(tokenId);
    }

    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override(ERC721) {
        if(!admins[_msgSender()]) {
            require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");
        }
        _transfer(from, to, tokenId);
    }


    function generate(uint256 tokenId, uint256 seed) internal returns (CowboyAlien memory t) {
        t = selectTraits(seed);

        if (t.isMutant && MUTANT_COUNT == 55 && minted <= PAID_TOKENS) {
            return generate(tokenId, random(seed));
        }
        if (existingCombinations[structToHash(t)] == 0) {
            tokenTraits[tokenId] = t;
            existingCombinations[structToHash(t)] = tokenId;
            return t;
        }
        return generate(tokenId, random(seed));
    }

    function selectTrait(uint16 seed, uint8 traitType) internal view returns (uint8) {
        return traits.selectTrait(seed, traitType);
    }

    

    function selectTraits(uint256 seed) internal view returns (CowboyAlien memory t) {

        t.isMutant = (seed & 0xFFFF) % 3 == 0 && (seed & 0xFFFF) % 7 == 0;

        if (t.isMutant) {
            t.isCowboy = true;
        } else {
            t.isCowboy = (seed & 0xFFFF) % 10 != 0;
        }

        seed >>= 16;
        t.pants = selectTrait(uint16(seed & 0xFFFF), 0 );

        seed >>= 16;
        t.top = selectTrait(uint16(seed & 0xFFFF), 1 );

        seed >>= 16;
        t.hat = selectTrait(uint16(seed & 0xFFFF), 2 );

        seed >>= 16;
        t.weapon = selectTrait(uint16(seed & 0xFFFF), 3);

        seed >>= 16;
        t.accessory = selectTrait(uint16(seed & 0xFFFF), 4);

        seed >>= 16;
        if (!t.isCowboy) {
            t.alphaIndex = selectTrait(uint16(seed & 0xFFFF), 5);
        }
    }

    function structToHash(CowboyAlien memory s) internal pure returns (uint256) {
        return uint256(keccak256(
                abi.encodePacked(
                    s.isCowboy,
                    s.isMutant,
                    s.pants,
                    s.top,
                    s.hat,
                    s.weapon,
                    s.accessory,
                    s.alphaIndex
                )
            ));
    }

    function random(uint256 seed) internal view returns (uint256) {
        return
            uint256(
                keccak256(
                    abi.encodePacked(
                        tx.origin,
                        blockhash(block.number - 1),
                        block.timestamp,
                        seed
                    )
                )
            );
    }



    function getTokenTraits(uint256 tokenId) external view override returns (CowboyAlien memory) {
        return tokenTraits[tokenId];
    }

    function getPaidTokens() external view override returns (uint256) {
        return PAID_TOKENS;
    }



    function setPaidTokens(uint256 _paidTokens) external onlyOwner {
        PAID_TOKENS = uint16(_paidTokens);
    }

    function setPaused(bool _paused) external onlyOwner {
        if (_paused) _pause();
        else _unpause();
    }

    function addAdmin(address addr) external onlyOwner {
        admins[addr] = true;
    }

    function removeAdmin(address addr) external onlyOwner {
        admins[addr] = false;
    }


    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        require(_exists(tokenId), "Token ID does not exist");
        return traits.tokenURI(tokenId);
    }

}// MIT LICENSE

pragma solidity ^0.8.1;


contract Traits is Ownable, ITraits {
    using Strings for uint256;

    uint256 private alphaTypeIndex = 5;

    struct Trait {
        string name;
        string png;
    }

    string mutantBody;
    string[] cowboyBody;
    string[] alienBody;

    string[5] _traitTypes = [
        "Pants",
        "Top",
        "Hat",
        "Weapon",
        "Accessory"
    ];
    mapping(uint8 => mapping(uint8 => Trait)) public traitData;
    mapping(uint8 => uint8) public traitCountForType;
    string[4] _alphas = ["8", "7", "6", "5"];

    IWildAbduction public wagNFT;
    
    constructor() {}

    function selectTrait(uint16 seed, uint8 traitType)
        external
        view
        override
        returns (uint8)
    {
        if (traitType == alphaTypeIndex) {
            uint256 m = seed % 100;
            if (m > 95) {
                return 0;
            } else if (m > 80) {
                return 1;
            } else if (m > 50) {
                return 2;
            } else {
                return 3;
            }
        }

        uint8 modOf = traitCountForType[traitType];

        return uint8(seed % modOf);
    }


    function setGame(address _wag) external onlyOwner {
        wagNFT = IWildAbduction(_wag);
    }


    function uploadCowboyBody(string calldata _cowboy) external onlyOwner {
        cowboyBody.push(_cowboy);
    }

    function uploadAlienBody(string calldata _alien) external onlyOwner {
        alienBody.push(_alien);
    }

    function uploadMutantBody(string calldata _mutant) external onlyOwner {
        mutantBody = _mutant;
    }

    function cowboyBodies() external view returns(uint256) {
        return cowboyBody.length;
    }

    function alienBodies() external view returns(uint256) {
        return alienBody.length;
    }


    function uploadTraits(
        uint8 traitType,
        uint8[] calldata traitIds,
        Trait[] calldata traits
    ) external onlyOwner {
        require(traitIds.length == traits.length, "Mismatched inputs");

        for (uint256 i = 0; i < traits.length; i++) {
            traitData[traitType][traitIds[i]] = Trait(
                traits[i].name,
                traits[i].png
            );
        }
    }

    function setTraitCountForType(uint8[] memory _tType, uint8[] memory _len)
        public
        onlyOwner
    {
        for (uint256 i = 0; i < _tType.length; i++) {
            traitCountForType[_tType[i]] = _len[i];
        }
    }


    function drawTrait(Trait memory trait)
        internal
        pure
        returns (string memory)
    {
        return
            string(
                abi.encodePacked(
                    '<image x="4" y="4" width="32" height="32" image-rendering="pixelated" preserveAspectRatio="xMidYMid" xlink:href="data:image/png;base64,',
                    trait.png,
                    '"/>'
                )
            );
    }

    function draw(string memory png) internal pure returns (string memory) {
        return
            string(
                abi.encodePacked(
                    '<image x="4" y="4" width="32" height="32" image-rendering="pixelated" preserveAspectRatio="xMidYMid" xlink:href="data:image/png;base64,',
                    png,
                    '"/>'
                )
            );
    }


    function drawSVG(uint256 tokenId) public view returns (string memory) {
        IWildAbduction.CowboyAlien memory s = wagNFT.getTokenTraits(tokenId);

        string memory svgString = "";
        if (s.isMutant) {
            svgString = string(
                abi.encodePacked(
                    draw(mutantBody),
                    drawTrait(traitData[0][s.pants]),
                    drawTrait(traitData[1][s.top]),
                    drawTrait(traitData[2][s.hat]),
                    drawTrait(traitData[3][s.weapon]),
                    drawTrait(traitData[4][s.accessory])
                )
            );

        } else {

            svgString = string(
                abi.encodePacked(
                    s.isCowboy ? draw(cowboyBody[tokenId % 3]) : draw(alienBody[tokenId % 5]),
                    drawTrait(traitData[0][s.pants]),
                    drawTrait(traitData[1][s.top]),
                    drawTrait(traitData[2][s.hat]),
                    drawTrait(traitData[3][s.weapon]),
                    drawTrait(traitData[4][s.accessory])
                )
            );

        }

        return
            string(
                abi.encodePacked(
                    '<svg id="character" width="100%" height="100%" version="1.1" viewBox="0 0 40 40" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink">',
                    svgString,
                    "</svg>"
                )
            );
    }

    function attributeForTypeAndValue(
        string memory traitType,
        string memory value
    ) internal pure returns (string memory) {
        return
            string(
                abi.encodePacked(
                    '{"trait_type":"',
                    traitType,
                    '","value":"',
                    value,
                    '"}'
                )
            );
    }

    function compileAttributes(uint256 tokenId)
        public
        view
        returns (string memory)
    {
        IWildAbduction.CowboyAlien memory s = wagNFT.getTokenTraits(tokenId);
        string memory traits;
        if (s.isCowboy) {
            traits = string(
                abi.encodePacked(
                    attributeForTypeAndValue(
                        _traitTypes[0],
                        traitData[0][s.pants % traitCountForType[0]].name
                    ),
                    ",",
                    attributeForTypeAndValue(
                        _traitTypes[1],
                        traitData[1][s.top % traitCountForType[1]].name
                    ),
                    ",",
                    attributeForTypeAndValue(
                        _traitTypes[2],
                        traitData[2][s.hat % traitCountForType[2]].name
                    ),
                    ",",
                    attributeForTypeAndValue(
                        _traitTypes[3],
                        traitData[3][s.weapon % traitCountForType[3]].name
                    ),
                    ",",
                    attributeForTypeAndValue(
                        _traitTypes[4],
                        traitData[4][s.accessory % traitCountForType[4]].name
                    ),
                    ","
                )
            );

            return
            string(
                abi.encodePacked(
                    "[",
                    traits,
                    '{"trait_type":"Generation","value":',
                    tokenId <= wagNFT.getPaidTokens() ? '"Gen 0"' : '"Gen 1"',
                    '},{"trait_type":"Type","value":',
                    s.isMutant ? '"Mutant"' : '"Cowboy"',
                    "}]"
                )
            );

        } else {
            traits = string(
                abi.encodePacked(
                    attributeForTypeAndValue(
                        _traitTypes[0],
                        traitData[0][s.pants % traitCountForType[0]].name
                    ),
                    ",",
                    attributeForTypeAndValue(
                        _traitTypes[1],
                        traitData[1][s.top % traitCountForType[1]].name
                    ),
                    ",",
                    attributeForTypeAndValue(
                        _traitTypes[2],
                        traitData[2][s.hat % traitCountForType[2]].name
                    ),
                    ",",
                    attributeForTypeAndValue(
                        _traitTypes[3],
                        traitData[3][s.weapon % traitCountForType[3]].name
                    ),
                    ",",
                    attributeForTypeAndValue(
                        _traitTypes[4],
                        traitData[4][s.accessory % traitCountForType[4]].name
                    ),
                    ",",
                    attributeForTypeAndValue(
                        "Alpha Score",
                        _alphas[s.alphaIndex]
                    ),
                    ","
                )
            );
        }
        return
            string(
                abi.encodePacked(
                    "[",
                    traits,
                    '{"trait_type":"Generation","value":',
                    tokenId <= wagNFT.getPaidTokens() ? '"Gen 0"' : '"Gen 1"',
                    '},{"trait_type":"Type","value":',
                    '"Alien"',
                    "}]"
                )
            );
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override
        returns (string memory)
    {
        IWildAbduction.CowboyAlien memory s = wagNFT.getTokenTraits(tokenId);

        string memory metadata = string(
            abi.encodePacked(
                '{"name": "',
                s.isMutant ? "Mutant #" : "Cowboy #",
                tokenId.toString(),
                '", "description": "Take cover! A species of unidentifiable creatures have settled their starship above the Ethereum Wild West.", "image": "data:image/svg+xml;base64,',
                base64(bytes(drawSVG(tokenId))),
                '", "attributes":',
                compileAttributes(tokenId),
                "}"
            )
        );

        if (!s.isCowboy) {
            metadata = string(
            abi.encodePacked(
                '{"name": "',
                "Alien #",
                tokenId.toString(),
                '", "description": "Take cover! A species of unidentifiable creatures have settled their starship above the Ethereum Wild West.", "image": "data:image/svg+xml;base64,',
                base64(bytes(drawSVG(tokenId))),
                '", "attributes":',
                compileAttributes(tokenId),
                "}"
            )
        );
        }

        return
            string(
                abi.encodePacked(
                    "data:application/json;base64,",
                    base64(bytes(metadata))
                )
            );
    }


    string internal constant TABLE =
        "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

    function base64(bytes memory data) internal pure returns (string memory) {
        if (data.length == 0) return "";

        string memory table = TABLE;

        uint256 encodedLen = 4 * ((data.length + 2) / 3);

        string memory result = new string(encodedLen + 32);

        assembly {
            mstore(result, encodedLen)

            let tablePtr := add(table, 1)

            let dataPtr := data
            let endPtr := add(dataPtr, mload(data))

            let resultPtr := add(result, 32)

            for {

            } lt(dataPtr, endPtr) {

            } {
                dataPtr := add(dataPtr, 3)

                let input := mload(dataPtr)

                mstore(
                    resultPtr,
                    shl(248, mload(add(tablePtr, and(shr(18, input), 0x3F))))
                )
                resultPtr := add(resultPtr, 1)
                mstore(
                    resultPtr,
                    shl(248, mload(add(tablePtr, and(shr(12, input), 0x3F))))
                )
                resultPtr := add(resultPtr, 1)
                mstore(
                    resultPtr,
                    shl(248, mload(add(tablePtr, and(shr(6, input), 0x3F))))
                )
                resultPtr := add(resultPtr, 1)
                mstore(
                    resultPtr,
                    shl(248, mload(add(tablePtr, and(input, 0x3F))))
                )
                resultPtr := add(resultPtr, 1)
            }

            switch mod(mload(data), 3)
            case 1 {
                mstore(sub(resultPtr, 2), shl(240, 0x3d3d))
            }
            case 2 {
                mstore(sub(resultPtr, 1), shl(248, 0x3d))
            }
        }

        return result;
    }
}