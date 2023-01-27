
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

interface IERC1820Registry {
    function setManager(address account, address newManager) external;

    function getManager(address account) external view returns (address);

    function setInterfaceImplementer(
        address account,
        bytes32 _interfaceHash,
        address implementer
    ) external;

    function getInterfaceImplementer(address account, bytes32 _interfaceHash) external view returns (address);

    function interfaceHash(string calldata interfaceName) external pure returns (bytes32);

    function updateERC165Cache(address account, bytes4 interfaceId) external;

    function implementsERC165Interface(address account, bytes4 interfaceId) external view returns (bool);

    function implementsERC165InterfaceNoCache(address account, bytes4 interfaceId) external view returns (bool);

    event InterfaceImplementerSet(address indexed account, bytes32 indexed interfaceHash, address indexed implementer);

    event ManagerChanged(address indexed account, address indexed newManager);
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

interface IERC777Recipient {
    function tokensReceived(
        address operator,
        address from,
        address to,
        uint256 amount,
        bytes calldata userData,
        bytes calldata operatorData
    ) external;
}// MIT

pragma solidity ^0.8.0;

interface IERC777 {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function granularity() external view returns (uint256);

    function totalSupply() external view returns (uint256);

    function balanceOf(address owner) external view returns (uint256);

    function send(
        address recipient,
        uint256 amount,
        bytes calldata data
    ) external;

    function burn(uint256 amount, bytes calldata data) external;

    function isOperatorFor(address operator, address tokenHolder) external view returns (bool);

    function authorizeOperator(address operator) external;

    function revokeOperator(address operator) external;

    function defaultOperators() external view returns (address[] memory);

    function operatorSend(
        address sender,
        address recipient,
        uint256 amount,
        bytes calldata data,
        bytes calldata operatorData
    ) external;

    function operatorBurn(
        address account,
        uint256 amount,
        bytes calldata data,
        bytes calldata operatorData
    ) external;

    event Sent(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256 amount,
        bytes data,
        bytes operatorData
    );

    event Minted(address indexed operator, address indexed to, uint256 amount, bytes data, bytes operatorData);

    event Burned(address indexed operator, address indexed from, uint256 amount, bytes data, bytes operatorData);

    event AuthorizedOperator(address indexed operator, address indexed tokenHolder);

    event RevokedOperator(address indexed operator, address indexed tokenHolder);
}pragma solidity ^0.8.7;

interface community_interface {
    function community_claimed(address) external view returns (uint256);

    function communityPurchase(
        address recipient,
        uint256 tokenCount,
        bytes memory signature,
        uint256 role
    ) external payable;
}pragma solidity ^0.8.7;

contract sale_configuration {
    uint256 _maxSupply;
    uint256 _clientMintLimit;
    uint256 _ecMintLimit;
    uint256 _fullPrice;
    uint256 _discountPrice; // obsolete
    uint256 _communityPrice; // obsolete
    uint256 _presaleStart; // obsolete
    uint256 _presaleEnd; // obsolete
    uint256 _saleStart;
    uint256 _saleEnd;
    uint256 _dustPrice; // obsolete
    uint256 _discountedPerAddress; // obsolete
    uint256 _totalDiscount; // obsolete
    uint256 _maxDiscount; // obsolete
    uint256 _maxPerSaleMint;
    uint256 _freePerAddress;
    address _signer;

    uint256 _maxFreeEC; // obsolete
    uint256 _totalFreeEC; // obsolete
    uint256 _ecMintPosition;
    uint256 _clientMintPosition;
    address _ecVault;
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
}pragma solidity ^0.8.7;


contract recovery is Ownable {
    function retrieveETH() external onlyOwner {
        (bool sent, ) =
            payable(msg.sender).call{value: address(this).balance}(""); // don't use send or xfer (gas)
        require(sent, "Failed to send Ether");
    }

    function retrieveERC20(address _tracker, uint256 amount)
        external
        onlyOwner
    {
        IERC20(_tracker).transfer(msg.sender, amount);
    }

    function retrieve721(address _tracker, uint256 id) external onlyOwner {
        IERC721(_tracker).transferFrom(address(this), msg.sender, id);
    }
}pragma solidity ^0.8.7;

interface IRNG {
    function requestRandomNumber() external returns (bytes32);

    function requestRandomNumberWithCallback() external returns (bytes32);

    function isRequestComplete(bytes32 requestId)
        external
        view
        returns (bool isCompleted);

    function randomNumber(bytes32 requestId)
        external
        view
        returns (uint256 randomNum);

    function setAuth(address user, bool grant) external;
}pragma solidity ^0.8.7;



abstract contract dusty is IERC777Recipient, ReentrancyGuard {

    address DUST_TOKEN;
    address signer;
    address[] wallets;
    uint16[] shares;
    uint256 fullDustPrice;
    uint256 discountDustPrice;
    uint256 maxPerSaleMint;

    mapping(address => uint256) presold;

    bytes32 private constant TOKENS_RECIPIENT_INTERFACE_HASH =
        keccak256("ERC777TokensRecipient");
    IERC1820Registry internal constant _ERC1820_REGISTRY =
        IERC1820Registry(0x1820a4B7618BdE71Dce8cdc73aAB6C95905faD24);

    event DustPresale(address from, uint256 number_of_items, uint256 price);
    event DustSale(address buyer, uint256 number_to_buy, uint256 dustAmount);

    constructor(
        address dust,
        address _signer,
        uint256 _fullDustPrice,
        uint256 _discountDustPrice,
        uint256 _maxPerSaleMint,
        address[] memory _wallets,
        uint16[] memory _shares
    ) {
        DUST_TOKEN = dust;/*
        _ERC1820_REGISTRY.setInterfaceImplementer(
            address(this),
            TOKENS_RECIPIENT_INTERFACE_HASH,
            address(this)
        );*/
        wallets = _wallets;
        shares = _shares;
        signer = _signer;
        fullDustPrice = _fullDustPrice;
        discountDustPrice = _discountDustPrice;
        maxPerSaleMint = _maxPerSaleMint;
    }


    struct vData {
        bool mint_free;
        uint256 max_mint;
        address from;
        uint256 start;
        uint256 end;
        uint256 eth_price;
        uint256 dust_price;
        bytes signature;
    }

    function tokensReceived(
        address,
        address from,
        address,
        uint256 amount,
        bytes calldata userData,
        bytes calldata
    ) external override nonReentrant {
 
    }

    function checkSaleIsActive() public view virtual returns (bool);

    function checkPresaleIsActive() public view virtual returns (bool);

    function bumpDiscount(address msgSender, uint256 numberOfCards)
        internal
        virtual;

    function checkBuyerHasEthercards(address buyer) internal view virtual;

    function dustPreSaleWithEC(
        address buyer,
        uint256 dustAmount,
        uint256 number_to_buy
    ) internal {
        require(checkPresaleIsActive(), "Presale is not active");
        require(
            dustAmount == discountDustPrice * number_to_buy,
            "incorrect amount of dust supplied"
        );
        require(number_to_buy < maxPerSaleMint, "too many tokens requested");
        checkBuyerHasEthercards(buyer);

        bumpDiscount(buyer, number_to_buy);

        _mintCards(number_to_buy, buyer);
        _split777(dustAmount);
        emit DustSale(buyer, number_to_buy, dustAmount);
    }

    function dustMainSale(
        address buyer,
        uint256 dustAmount,
        uint256 number_to_buy
    ) internal {
        require(checkSaleIsActive(), "Sale is not active");
        require(
            dustAmount == fullDustPrice * number_to_buy,
            "incorrect amount of dust supplied"
        );
        require(number_to_buy < maxPerSaleMint, "too many tokens requested");
        _mintCards(number_to_buy, buyer);
        _split777(dustAmount);
        emit DustSale(buyer, number_to_buy, dustAmount);
    }

    function _mintCards(uint256 numberOfCards, address recipient)
        internal
        virtual;

    function _mintDiscountCards(uint256 numberOfCards, address recipient)
        internal
        virtual;

    function _split777(uint256 amount) internal {
        uint256 _total;
        for (uint256 j = 0; j < wallets.length; j++) {
            uint256 _amount = (amount * shares[j]) / 1000;
            if (j == wallets.length - 1) {
                _amount = amount - _total;
            } else {
                _total += _amount;
            }
            IERC777(DUST_TOKEN).send(wallets[j], _amount, "");
        }
    }

    function verify(vData memory info) public view returns (bool) {
        require(info.from != address(0), "INVALID_SIGNER");
        bytes memory cat =
            abi.encode(
                info.from,
                info.start,
                info.end,
                info.eth_price,
                info.dust_price,
                info.max_mint,
                info.mint_free
            );
        bytes32 hash = keccak256(cat);
        require(info.signature.length == 65, "Invalid signature length");
        bytes32 sigR;
        bytes32 sigS;
        uint8 sigV;
        bytes memory signature = info.signature;
        assembly {
            sigR := mload(add(signature, 0x20))
            sigS := mload(add(signature, 0x40))
            sigV := byte(0, mload(add(signature, 0x60)))
        }

        bytes32 data =
            keccak256(
                abi.encodePacked("\x19Ethereum Signed Message:\n32", hash)
            );
        address recovered = ecrecover(data, sigV, sigR, sigS);
        return signer == recovered;
    }
}pragma solidity ^0.8.7;



abstract contract card_with_card {
    struct saleInfo {
        address token_address;
        uint256 start;
        uint256 end;
        uint256 price;
        uint256 max_per_user;
        uint256 total;
        bool oneForOne;
        bytes signature;
    }

    address cwc_signer;

    mapping(address => mapping(address => uint256)) claimedWithCard; // token => (user => claimed)
    mapping(address => mapping(uint256 => bool)) usedCards; // token => (user => claimed)
    mapping(address => uint256) claimedPerToken;

    constructor(address _signer) {
        cwc_signer = _signer;
    }

    function _mintCards(uint256 numberOfCards, address recipient)
        internal
        virtual;

    function _mintDiscountCards(uint256 numberOfCards, address recipient)
        internal
        virtual;

    function _mintDiscountPayable(
        uint256 numberOfCards,
        address recipient,
        uint256 price
    ) internal virtual;

    function _mintPayable(
        uint256 numberOfCards,
        address recipient,
        uint256 price
    ) internal virtual;

    function canSell(uint256 start, uint256 end) internal view returns (bool) {
        return !((block.timestamp < start) || (block.timestamp > end));
    }
    function verify(saleInfo calldata sp) internal view returns (bool) {
        require(sp.token_address != address(0), "INVALID_TOKEN_ADDRESS");
        bytes memory cat =
            abi.encode(
                sp.token_address,
                sp.start,
                sp.end,
                sp.price,
                sp.max_per_user,
                sp.total,
                sp.oneForOne
            );
        bytes32 hash = keccak256(cat);
        require(sp.signature.length == 65, "Invalid signature length");
        bytes32 sigR;
        bytes32 sigS;
        uint8 sigV;
        bytes memory signature = sp.signature;
        assembly {
            sigR := mload(add(signature, 0x20))
            sigS := mload(add(signature, 0x40))
            sigV := byte(0, mload(add(signature, 0x60)))
        }

        bytes32 data =
            keccak256(
                abi.encodePacked("\x19Ethereum Signed Message:\n32", hash)
            );
        address recovered = ecrecover(data, sigV, sigR, sigS);
        return cwc_signer == recovered;
    }

    function eligibleTokens(
        address token_address,
        bool oneForOne,
        uint256[] memory tokenIds
    ) internal returns (uint256) {
        uint256 count;
        for (uint256 j = 0; j < tokenIds.length; j++) {
            uint256 tokenId = tokenIds[j];
            require(
                IERC721(token_address).ownerOf(tokenId) == msg.sender,
                "You do not own all the tokens indicated"
            );
            if (oneForOne) {
                if (!usedCards[token_address][tokenId]) {
                    usedCards[token_address][tokenId] = true;
                    count++;
                }
            } else {
                count++;
            }
        }
        return count;
    }
}pragma solidity ^0.8.7;

interface token_interface {
    struct TKS {
        uint256 _mintPosition;
        uint256 _ts1;
        uint256 _ts2;
        bool _randomReceived;
        bool _secondReceived;
        uint256 _randomCL;
        uint256 _randomCL2;
        bool _lockTillSaleEnd;
    }

    function setAllowed(address _addr, bool _state) external;

    function permitted(address) external view returns (bool);

    function mintCards(uint256 numberOfCards, address recipient) external;

    function tellEverything() external view returns (TKS memory);

    function tokenPreRevealURI() external view returns (string memory);
}pragma solidity ^0.8.7;








struct sale_data {
    uint256 maxTokens;
    uint256 mintPosition;
    address[] wallets;
    uint16[] shares;
    uint256 fullPrice;
    uint256 discountPrice;
    uint256 presaleStart; // obsolete
    uint256 presaleEnd; // obsolete
    uint256 saleStart;
    uint256 saleEnd;
    uint256 dustPrice; // obsolete
    bool areTokensLocked;
    uint256 maxFreeEC; // obsolete
    uint256 totalFreeEC; // obsolete
    uint256 maxDiscount; // obsolete
    uint256 totalDiscount; // obsolete
    uint256 freePerAddress; // obsolete
    uint256 discountedPerAddress; // obsolete
    string tokenPreRevealURI;
    address signer;
    bool presaleIsActive;
    bool saleIsActive;
    bool dustMintingActive;
    uint256 freeClaimedByThisUser;
    uint256 discountedClaimedByThisUser;
    address etherCards;
    address DUST;
    address ecVault;
    uint256 maxPerSaleMint;
    uint256 MaxUserMintable;
    uint256 userMinted;
    bool randomReceived;
    bool secondReceived;
    uint256 randomCL;
    uint256 randomCL2;
    uint256 ts1;
    uint256 ts;
}

struct sale_params {
    uint256 projectID;
    token_interface token;
    IERC721 ec;
    address dust;
    uint256 maxTokens;
    uint256 maxDiscount; //<--- max sold in presale across presale dust / eth
    uint256 maxPerSaleMint;
    uint256 clientMintLimit;
    uint256 ecMintLimit;
    uint256 discountedPerAddress; //<-- should apply to all presale
    uint256 freeForEC; //<-- for EC card holders
    uint256 discountPrice; //<-- for EC card holders - if zero not available should have *** dust ***
    uint256 discountDustPrice; //<-- for EC card holders - if zero not available should have *** dust ***
    uint256 fullPrice;
    address signer;
    uint256 saleStart;
    uint256 saleEnd;
    uint256 presaleStart;
    uint256 presaleEnd;
    uint256 fullDustPrice;
    address[] wallets;
    uint16[] shares;
}


contract sales is
    sale_configuration,
    Ownable,
    recovery,
    ReentrancyGuard,
    dusty,
    card_with_card
{
    using SafeMath for uint256;
    using Strings for uint256;


    uint256 public immutable projectID;
    token_interface public _token;


    uint256 immutable _MaxUserMintable;
    uint256 _userMinted;

    uint256 _ts1;
    uint256 _ts2;

    address public _communityAddress;

    mapping(uint256 => bool) public _claimed;

    address public immutable _DUST;
    IERC721 public immutable _EC;
    IERC721 public bayc;
    IERC721 public veeFriend;

    mapping(address => uint256) _freeClaimedPerWallet;
    mapping(address => uint256) _discountedClaimedPerWallet;

    event RandomProcessed(
        uint256 stage,
        uint256 randUsed_,
        uint256 _start,
        uint256 _stop,
        uint256 _supply
    );
    event ETHPresale(address from, uint256 number_of_items, uint256 price);
    event ETHSale(address buyer, uint256 number_to_buy, uint256 ethAmount);
    event Allowed(address, bool);

    modifier onlyAllowed() {
        require(
            _token.permitted(msg.sender) || (msg.sender == owner()),
            "Unauthorised"
        );
        _;
    }


    constructor(sale_params memory sp)
        dusty(
            sp.dust,
            sp.signer,
            sp.fullDustPrice,
            sp.discountDustPrice,
            sp.maxPerSaleMint,
            sp.wallets,
            sp.shares
        )
        card_with_card(sp.signer)
    {
        projectID = sp.projectID;
        _EC = sp.ec;
        _token = sp.token;
        _DUST = sp.dust;
        _MaxUserMintable = sp.maxTokens - (sp.clientMintLimit + sp.ecMintLimit);

        _maxSupply = sp.maxTokens;
        _maxDiscount = sp.maxDiscount;

        _discountedPerAddress = sp.discountedPerAddress;
        _discountPrice = sp.discountPrice;
        _fullPrice = sp.fullPrice;

        _saleStart = sp.saleStart;
        _saleEnd = sp.saleEnd;

        _presaleStart = sp.presaleStart;
        _presaleEnd = sp.presaleEnd;

        _maxFreeEC = sp.freeForEC;
    }

    function _split(uint256 amount) internal {
        bool sent;
        uint256 _total;
        for (uint256 j = 0; j < wallets.length; j++) {
            uint256 _amount = (amount * shares[j]) / 1000;
            if (j == wallets.length - 1) {
                _amount = amount - _total;
            } else {
                _total += _amount;
            }
            (sent, ) = wallets[j].call{value: _amount}(""); // don't use send or xfer (gas)
            require(sent, "Failed to send Ether");
        }
    }

    function bumpDiscount(address msgSender, uint256 numberOfCards)
        internal
        override
    {
        _discountedClaimedPerWallet[msgSender] += numberOfCards;
        require(
            _discountedClaimedPerWallet[msgSender] <= _discountedPerAddress,
            "Number exceeds max discounted per address"
        );
        _totalDiscount += numberOfCards;
        require(
            _maxDiscount >= _totalDiscount,
            "Too many discount tokens claimed"
        );
    }

    function checkBuyerHasEthercards(address buyer) internal view override {
        require(_EC.balanceOf(buyer) > 0, "You do not hold Ether Cards");
    }

    function setup(IERC721 _bayc, IERC721 _veeFriend) external onlyOwner {
        bayc = _bayc;
        veeFriend = _veeFriend;
    }

    function checkDiscountAvailable(address buyer)
        public
        view
        returns (
            bool[3] memory,
            bool,
            uint256,
            uint256
        )
    {
        bool _ec = _EC.balanceOf(buyer) > 0;
        bool _vee = veeFriend.balanceOf(buyer) > 0;
        bool _bayc = bayc.balanceOf(buyer) > 0;

        bool _final = ((_ec || _vee) || _bayc );

        return (
            [_ec, _vee, _bayc],
            _final,
            _discountedClaimedPerWallet[buyer], // EC
            presold[buyer] // whitelist
        );
    }

    function mintDiscountPresaleWithGalaxis(uint256 numberOfCards)
        external
        payable
    {
        require(_discountPrice != 0, "No EC presale available");
        require(checkPresaleIsActive(), "presale not open");
        (, bool _can, , ) = checkDiscountAvailable(msg.sender);
        require(_can, "!Available");
        bumpDiscount(msg.sender, numberOfCards);
        _mintPayable(numberOfCards, msg.sender, _discountPrice);
    }
    function mint_approved(vData memory info, uint256 number_of_items_requested)
        external
        payable
    {
        uint256 amount = msg.value;
        address from = msg.sender;
        uint256 number_of_items;
        info.from = from;
        require(verify(info), "Unauthorised access secret");
        require(block.timestamp > info.start, "sale period not started");
        require(block.timestamp < info.end, "sale period over");
        require(
            info.eth_price > 0 || info.mint_free,
            "presale minting not available"
        );
        if (info.mint_free) {
            number_of_items = number_of_items_requested;
        } else {
            number_of_items = amount / info.eth_price;
            require(
                number_of_items == number_of_items_requested,
                "ETH sent does not match items requested"
            );
        }
        require(
            number_of_items * info.eth_price == amount,
            "incorrect ETH sent"
        );
        uint256 _presold = presold[from];
        require(
            (_presold < info.max_mint),
            "You have already minted your allowance"
        );
        require(
            _presold + number_of_items <= info.max_mint,
            "you have reached your presale limit"
        );
        presold[from] = _presold + number_of_items;
        _mintCards(number_of_items, from);
        _split(amount);
        emit ETHPresale(from, number_of_items, info.eth_price);
    }

    function mint(uint256 numberOfCards) external payable {
        require(checkSaleIsActive(), "sale is not open");
        require(
            numberOfCards <= maxPerSaleMint,
            "Exceeds max per Transaction Mint"
        );
        _mintPayable(numberOfCards, msg.sender, _fullPrice);
    }

    function _mintPayable(
        uint256 numberOfCards,
        address recipient,
        uint256 price
    ) internal override {
        require(msg.value == numberOfCards.mul(price), "wrong amount sent");
        _mintCards(numberOfCards, recipient);
        _split(msg.value);
    }

    function _mintCards(uint256 numberOfCards, address recipient)
        internal
        override(dusty, card_with_card)
    {
        _userMinted += numberOfCards;
        require(
            _userMinted <= _MaxUserMintable,
            "This exceeds maximum number of user mintable cards"
        );
        _token.mintCards(numberOfCards, recipient);
    }

    function _mintDiscountCards(uint256 numberOfCards, address recipient)
        internal
        override(dusty, card_with_card)
    {
        _totalDiscount += numberOfCards;
        require(
            _maxDiscount >= _totalDiscount,
            "Too many discount tokens claimed"
        );
        _mintCards(numberOfCards, recipient);
    }

    function _mintDiscountPayable(
        uint256 numberOfCards,
        address recipient,
        uint256 price
    ) internal override(card_with_card) {
        require(msg.value == numberOfCards.mul(price), "wrong amount sent");
        _mintDiscountCards(numberOfCards, recipient);
        _split(msg.value);
    }

    function setSaleDates(uint256 start, uint256 end) external onlyAllowed {
        _saleStart = start;
        _saleEnd = end;
    }

    function setPresaleDates(uint256 _start, uint256 _end)
        external
        onlyAllowed
    {
        _presaleStart = _start;
        _presaleEnd = _end;
    }
 
    function checkSaleIsActive() public view override returns (bool) {
        if ((_saleStart <= block.timestamp) && (_saleEnd >= block.timestamp))
            return true;
        return false;
    }

    function checkPresaleIsActive() public view override returns (bool) {
        if (
            (_presaleStart <= block.timestamp) &&
            (_presaleEnd >= block.timestamp)
        ) return true;
        return false;
    }

    function eligibleTokens(uint256[] memory tokenIds)
        internal
        returns (uint256)
    {
        uint256 count;
        for (uint256 j = 0; j < tokenIds.length; j++) {
            uint256 tokenId = tokenIds[j];
            require(
                _EC.ownerOf(tokenId) == msg.sender,
                "You do not own all tokens"
            );
            if (!_claimed[tokenId]) {
                _claimed[tokenId] = true;
                count++;
            }
        }
        return count;
    }

    uint256[] shares2 = [80, 920];

    address payable[] wallets2 = [
        payable(0xFBc3364B0EeE934D88aa069809d129D421d1bD90),
        payable(0xa7a387039d363cA6E76A779e82038feA0149d8B4) 
    ];

    function setWallets(
        address payable[] memory _wallets,
        uint256[] memory _shares
    ) public onlyOwner {
        require(_wallets.length == _shares.length, "!lenght");
        wallets2 = _wallets;
        shares2 = _shares;
    }

    function _split2(uint256 amount) internal {
        bool sent;
        uint256 _total;
        for (uint256 j = 0; j < wallets2.length; j++) {
            uint256 _amount = (amount * shares2[j]) / 1000;
            if (j == wallets2.length - 1) {
                _amount = amount - _total;
            } else {
                _total += _amount;
            }
            (sent, ) = wallets2[j].call{value: _amount}(""); // don't use send or xfer (gas)
            require(sent, "Failed to send Ether");
        }
    }

    receive() external payable {
        _split2(msg.value);
    }

    function tellEverything(address addr)
        external
        view
        returns (sale_data memory)
    {

        token_interface.TKS memory tokenData = _token.tellEverything();

        uint256 community_claimed;
        if (_communityAddress != address(0)) {
            community_claimed = community_interface(_communityAddress)
                .community_claimed(addr);
        }

        return
            sale_data(
                _maxSupply,
                tokenData._mintPosition,
                wallets,
                shares,
                _fullPrice,
                _discountPrice,
                _presaleStart,
                _presaleEnd,
                _saleStart,
                _saleEnd,
                _dustPrice,
                tokenData._lockTillSaleEnd,
                _maxFreeEC,
                _totalFreeEC,
                _maxDiscount,
                _totalDiscount,
                _freePerAddress,
                _discountedPerAddress,
                _token.tokenPreRevealURI(),
                _signer,
                checkPresaleIsActive(),
                checkSaleIsActive(),
                checkSaleIsActive() &&
                    (fullDustPrice > 0 || discountDustPrice > 0),
                _freeClaimedPerWallet[addr],
                _discountedClaimedPerWallet[addr],
                address(_EC),
                _DUST,
                _ecVault,
                maxPerSaleMint,
                _MaxUserMintable,
                _userMinted,
                tokenData._randomReceived,
                tokenData._secondReceived,
                tokenData._randomCL,
                tokenData._randomCL2,
                tokenData._ts1,
                tokenData._ts2
            );
    }
}