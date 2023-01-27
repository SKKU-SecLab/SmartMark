
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
pragma solidity 0.8.6;

 
interface IHuxleyComics is IERC721 {

    struct Issue {
        uint256 price;
        uint256 goldSupplyLeft;
        uint256 firstEditionSupplyLeft;
        uint256 holographicSupplyLeft;
        uint256 serialNumberToMintGold;
        uint256 serialNumberToMintFirstEdition;
        uint256 serialNumberToMintHolographic;
        uint256 maxPayableMintBatch;
        string uri;
        bool exist;
    }

    struct Token {
        uint256 serialNumber;
        uint256 issueNumber;
        TokenType tokenType;
    }

    enum TokenType {FirstEdition, Gold, Holographic}

    function safeMint(address _to) external returns (uint256);


    function getCurrentIssue() external returns (uint256 _currentIssue);

    function getCurrentPrice() external returns (uint256 _currentPrice);

    function getCurrentMaxPayableMintBatch() external returns (uint256 _currentMaxPayableMintBatch);


    function createNewIssue(
        uint256 _price,
        uint256 _goldSupply,
        uint256 _firstEditionSupply,
        uint256 _holographicSupply,
        uint256 _startSerialNumberGold,
        uint256 _startSerialNumberFirstEdition,
        uint256 _startSerialNumberHolographic,
        uint256 _maxPaybleMintBatch,
        string memory _uri
    ) external;


    function getIssue(uint256 _issueNumber) external returns (Issue memory _issue);


    function getToken(uint256 _tokenId) external returns (Token memory _token);


    function setTokenDetails(uint256 _tokenId, TokenType _tokenType) external;


    function setBaseURI(uint256 _issueNumber, string memory _uri) external;


    function setCanBurn(bool _canBurn) external;

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
        return _verifyCallResult(success, returndata, errorMessage);
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
        return _verifyCallResult(success, returndata, errorMessage);
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
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) private pure returns (bytes memory) {

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
                return retval == IERC721Receiver(to).onERC721Received.selector;
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
pragma solidity 0.8.6;



contract HuxleyComics is ERC721Enumerable, IHuxleyComics, ReentrancyGuard, Ownable {
    using Strings for uint256;

    address public minter;

    bool public canBurn;

    uint256 public tokenId;

    uint256 private currentIssue;

    uint256 private currentPrice;

    uint256 private currentMaxPayableMintBatch;

    mapping(uint256 => Issue) private issues;

    mapping(uint256 => bool) public redemptions;

    mapping(uint256 => Token) private tokens;

    modifier onlyMinter() {
        require(msg.sender == minter, "HT: Only minter");
        _;
    }

    constructor() ERC721("HUXLEY Comics", "HUXLEY") {}

    function safeMint(address to) external override onlyMinter() nonReentrant returns (uint256 _tokenId) {
        tokenId++;
        super._safeMint(to, tokenId);
        return tokenId;
    }

    function burn(uint256 _tokenId) external {
        require(canBurn, "HT: is not burnable");
        require(ownerOf(_tokenId) == msg.sender, "HT: Not owner");
        super._burn(_tokenId);
    }

    function createNewIssue(
        uint256 _price,
        uint256 _goldSupply,
        uint256 _firstEditionSupply,
        uint256 _holographicSupply,
        uint256 _startSerialNumberGold,
        uint256 _startSerialNumberFirstEdition,
        uint256 _startSerialNumberHolographic,
        uint256 _maxPayableMintBatch,
        string memory _uri
    ) external override onlyMinter {
        currentIssue = currentIssue + 1;
        currentPrice = _price;
        currentMaxPayableMintBatch = _maxPayableMintBatch;

        Issue storage issue = issues[currentIssue];

        issue.price = _price;
        issue.goldSupplyLeft = _goldSupply;
        issue.firstEditionSupplyLeft = _firstEditionSupply;
        issue.holographicSupplyLeft = _holographicSupply;
        issue.serialNumberToMintGold = _startSerialNumberGold;
        issue.serialNumberToMintFirstEdition = _startSerialNumberFirstEdition;
        issue.serialNumberToMintHolographic = _startSerialNumberHolographic;
        issue.maxPayableMintBatch = _maxPayableMintBatch;
        issue.uri = _uri;
        issue.exist = true;
    }

    function _issueExists(uint256 _issueNumber) internal view virtual returns (bool) {
        return issues[_issueNumber].exist ? true : false;
    }

    function setTokenDetails(uint256 _tokenId, TokenType _tokenType) external override onlyMinter {
        Token storage token = tokens[_tokenId];
        token.issueNumber = currentIssue;

        Issue storage issue = issues[currentIssue];
        if (_tokenType == TokenType.Gold) {
            uint256 goldSupplyLeft = issue.goldSupplyLeft;
            require(goldSupplyLeft > 0, "HT: no gold");

            issue.goldSupplyLeft = goldSupplyLeft - 1;
            uint256 serialNumberGold = issue.serialNumberToMintGold;
            issue.serialNumberToMintGold = serialNumberGold + 1; //next mint

            token.tokenType = TokenType.Gold;
            token.serialNumber = serialNumberGold;
        } else if (_tokenType == TokenType.FirstEdition) {
            uint256 firstEditionSupplyLeft = issue.firstEditionSupplyLeft;
            require(firstEditionSupplyLeft > 0, "HT: no firstEdition");

            issue.firstEditionSupplyLeft = firstEditionSupplyLeft - 1;
            uint256 serialNumberFirstEdition = issue.serialNumberToMintFirstEdition;
            issue.serialNumberToMintFirstEdition = serialNumberFirstEdition + 1; //next mint

            token.tokenType = TokenType.FirstEdition;
            token.serialNumber = serialNumberFirstEdition;
        } else if (_tokenType == TokenType.Holographic) {
            uint256 holographicSupplyLeft = issue.holographicSupplyLeft;
            require(holographicSupplyLeft > 0, "HT: no holographic");

            issue.holographicSupplyLeft = holographicSupplyLeft - 1;
            uint256 serialNumberHolographic = issue.serialNumberToMintHolographic;
            issue.serialNumberToMintHolographic = serialNumberHolographic + 1; //next mint

            token.tokenType = TokenType.Holographic;
            token.serialNumber = serialNumberHolographic;
        } else {
            revert();
        }
    }

    function tokenURI(uint256 _tokenId) public view virtual override returns (string memory) {
        require(_exists(_tokenId), "UT: invalid token");

        Token memory token = tokens[_tokenId];
        uint256 issueNumber = token.issueNumber;
        require(issueNumber > 0, "HT: invalid issue");

        Issue memory issue = issues[issueNumber];
        string memory baseURI = issue.uri;

        return
            bytes(baseURI).length > 0
                ? string(abi.encodePacked(baseURI, _tokenId.toString()))
                : "";
    }

    function setBaseURI(uint256 _issueNumber, string memory _uri) external override onlyMinter {
        require(_issueExists(_issueNumber), "UT: invalid issue");

        Issue storage issue = issues[_issueNumber];
        issue.uri = _uri;
    }

    function getCurrentIssue() external view override returns (uint256 _currentIssue) {
        return currentIssue;
    }

    function getCurrentPrice() external view override returns (uint256 _currentPrice) {
        return currentPrice;
    }

    function getCurrentMaxPayableMintBatch() external view override returns (uint256 _currentMaxaPaybleMintBatch) {
        return currentMaxPayableMintBatch;
    }

    function getIssue(uint256 _issueNumber) external view override returns (Issue memory _issue) {
        return issues[_issueNumber];
    }

    function getToken(uint256 _tokenId) external view override returns (Token memory _token) {
        return tokens[_tokenId];
    }

    function redeemCopy(uint256 _tokenId) external {
        require(ownerOf(_tokenId) == msg.sender, "HT: Not owner");
        require(redemptions[_tokenId] == false, "HT: already redeemed");

        redemptions[_tokenId] = true;
    }

    function updateMinter(address _minter) external onlyOwner {
        minter = _minter;
    }

    function setCanBurn(bool _canBurn) external override onlyMinter {
        canBurn = _canBurn;
    }
}// MIT
pragma solidity 0.8.6;

interface IGenesisToken {
    function mint(
        address account,
        uint256 category,
        bytes memory data
    ) external;

    function mintBatch(
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) external;

    function burnBatch(
        address account,
        uint256[] memory ids,
        uint256[] memory amounts
    ) external;

    function redeem(address _account, uint256 _category) external;

    function privateMintBatch(
        address _account,
        uint256 _amountToMint,
        uint256 _category,
        bytes memory _data
    ) external;
}// MIT

pragma solidity ^0.8.0;


interface IAccessControl {
    function hasRole(bytes32 role, address account) external view returns (bool);

    function getRoleAdmin(bytes32 role) external view returns (bytes32);

    function grantRole(bytes32 role, address account) external;

    function revokeRole(bytes32 role, address account) external;

    function renounceRole(bytes32 role, address account) external;
}

abstract contract AccessControl is Context, IAccessControl, ERC165 {
    struct RoleData {
        mapping(address => bool) members;
        bytes32 adminRole;
    }

    mapping(bytes32 => RoleData) private _roles;

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);

    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

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
        emit RoleAdminChanged(role, getRoleAdmin(role), adminRole);
        _roles[role].adminRole = adminRole;
    }

    function _grantRole(bytes32 role, address account) private {
        if (!hasRole(role, account)) {
            _roles[role].members[account] = true;
            emit RoleGranted(role, account, _msgSender());
        }
    }

    function _revokeRole(bytes32 role, address account) private {
        if (hasRole(role, account)) {
            _roles[role].members[account] = false;
            emit RoleRevoked(role, account, _msgSender());
        }
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
pragma solidity 0.8.6;



contract HuxleyBurn is Pausable, AccessControl {
    HuxleyComics public huxleyComics;

    IGenesisToken public genesisToken;

    bool public checkNotRedeemed = true;

    bool public checkTokensIsFromIssue1 = false;

    event GenesisTokenMinted(
        address _sender,
        uint256 _categoryId,
        uint256 _tokenId1,
        uint256 _tokenId2
    );
    event SetCheckNotRedeemedExecuted(address _sender, bool _newValue);
    event SetCheckTokensIsFromIssue1Executed(address _sender, bool _newValue);

    mapping(uint256 => bool) public usedTokens;

    constructor(address _huxleyComics, address _genesisToken) {
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);

        huxleyComics = HuxleyComics(_huxleyComics);
        genesisToken = IGenesisToken(_genesisToken);

        _pause();
    }

    function getGenesisToken(
        uint256 tokenId1,
        uint256 tokenId2,
        uint256 tokenId3,
        uint256 tokenId4,
        uint256 tokenId5
    ) external whenNotPaused {
        if (checkNotRedeemed) {
            isTokenNotRedeemed(tokenId1, tokenId2, tokenId3, tokenId4, tokenId5);
        }

        isTokenValid(tokenId1, tokenId2, tokenId3, tokenId4, tokenId5);

        require(!usedTokens[tokenId3], "HB: TokenId3 already used");
        usedTokens[tokenId3] = true;

        require(!usedTokens[tokenId4], "HB: TokenId4 already used");
        usedTokens[tokenId4] = true;

        require(!usedTokens[tokenId5], "HB: TokenId5 already used");
        usedTokens[tokenId5] = true;

        require(!usedTokens[tokenId1], "HB: TokenId1 already used");
        require(!usedTokens[tokenId2], "HB: TokenId2 already used");

        huxleyComics.transferFrom(msg.sender, address(this), tokenId1);
        huxleyComics.transferFrom(msg.sender, address(this), tokenId2);

        uint256 categoryId = getTokensCategory(tokenId1, tokenId2);

        huxleyComics.burn(tokenId1);
        huxleyComics.burn(tokenId2);

        mintGenesisToken(categoryId);

        emit GenesisTokenMinted(msg.sender, categoryId, tokenId1, tokenId2);
    }

    function isTokenNotRedeemed(
        uint256 tokenId1,
        uint256 tokenId2,
        uint256 tokenId3,
        uint256 tokenId4,
        uint256 tokenId5
    ) internal view {
        require(huxleyComics.redemptions(tokenId1) == false, "HB: TokenId1 was redeemed");
        require(huxleyComics.redemptions(tokenId2) == false, "HB: TokenId2 was redeemed");
        require(huxleyComics.redemptions(tokenId3) == false, "HB: TokenId3 was redeemed");
        require(huxleyComics.redemptions(tokenId4) == false, "HB: TokenId4 was redeemed");
        require(huxleyComics.redemptions(tokenId5) == false, "HB: TokenId5 was redeemed");
    }

    function isTokenValid(
        uint256 tokenId1,
        uint256 tokenId2,
        uint256 tokenId3,
        uint256 tokenId4,
        uint256 tokenId5
    ) internal view returns (bool) {
        require(huxleyComics.ownerOf(tokenId3) == msg.sender, "HB: Not owner tokenId3");
        require(huxleyComics.ownerOf(tokenId4) == msg.sender, "HB: Not owner tokenId4");
        require(huxleyComics.ownerOf(tokenId5) == msg.sender, "HB: Not owner tokenId5");

        if (checkTokensIsFromIssue1) {
            IHuxleyComics.Token memory tokenDetails1 = huxleyComics.getToken(tokenId1);
            IHuxleyComics.Token memory tokenDetails2 = huxleyComics.getToken(tokenId2);
            IHuxleyComics.Token memory tokenDetails3 = huxleyComics.getToken(tokenId3);
            IHuxleyComics.Token memory tokenDetails4 = huxleyComics.getToken(tokenId4);
            IHuxleyComics.Token memory tokenDetails5 = huxleyComics.getToken(tokenId5);

            require(tokenDetails1.issueNumber == 1, "HB: TokenId1 not from Issue 1");
            require(tokenDetails2.issueNumber == 1, "HB: TokenId2 not from Issue 1");
            require(tokenDetails3.issueNumber == 1, "HB: TokenId3 not from Issue 1");
            require(tokenDetails4.issueNumber == 1, "HB: TokenId4 not from Issue 1");
            require(tokenDetails5.issueNumber == 1, "HB: TokenId5 not from Issue 1");
        }

        return true;
    }

    function mintGenesisToken(uint256 _categoryId) internal virtual {
        require(_categoryId > 0 && _categoryId <= 10, "HB: Invalid Category");
        genesisToken.mint(msg.sender, _categoryId, "");
    }

    function getTokensCategory(uint256 tokenId1, uint256 tokenId2)
        internal
        pure
        returns (uint256 categoryId)
    {
        uint256 serialNumber1 = tokenId1 - 100;
        uint256 serialNumber2 = tokenId2 - 100;

        uint256 categoryToken1 = getCategory(serialNumber1);
        uint256 categoryToken2 = getCategory(serialNumber2);

        if (categoryToken1 == categoryToken2) {
            return categoryToken1;
        } else {
            return getCategoryFromFormula(serialNumber1, serialNumber2);
        }
    }

    function getCategory(uint256 _serialNumber) internal pure returns (uint256 category) {
        if (_serialNumber <= 1000) {
            return 1;
        } else if (_serialNumber <= 2000) {
            return 2;
        } else if (_serialNumber <= 3000) {
            return 3;
        } else if (_serialNumber <= 4000) {
            return 4;
        } else if (_serialNumber <= 5000) {
            return 5;
        } else if (_serialNumber <= 6000) {
            return 6;
        } else if (_serialNumber <= 7000) {
            return 7;
        } else if (_serialNumber <= 8000) {
            return 8;
        } else if (_serialNumber <= 9000) {
            return 9;
        } else if (_serialNumber <= 10000) {
            return 10;
        } else {
            revert("HB: Invalid category");
        }
    }

    function getCategoryFromFormula(uint256 _serialNumber1, uint256 _serialNumber2)
        internal
        pure
        returns (uint256)
    {
        uint256 result;
        if (_serialNumber1 < _serialNumber2) {
            result = (_serialNumber1 * 10000) / _serialNumber2;
        } else {
            result = (_serialNumber2 * 10000) / _serialNumber1;
        }

        if (result <= 1000) {
            return 1;
        } else if (result <= 2000) {
            return 2;
        } else if (result <= 3000) {
            return 3;
        } else if (result <= 4000) {
            return 4;
        } else if (result <= 5000) {
            return 5;
        } else if (result <= 6000) {
            return 6;
        } else if (result <= 7000) {
            return 7;
        } else if (result <= 8000) {
            return 8;
        } else if (result <= 9000) {
            return 9;
        } else if (result <= 10000) {
            return 10;
        } else {
            revert("HB: Invalid Formula category");
        }
    }

    function setCheckNotRedeemed(bool _check) external onlyRole(DEFAULT_ADMIN_ROLE) {
        checkNotRedeemed = _check;

        emit SetCheckNotRedeemedExecuted(msg.sender, _check);
    }

    function setCheckTokensIsFromIssue1(bool _check) external onlyRole(DEFAULT_ADMIN_ROLE) {
        checkTokensIsFromIssue1 = _check;

        emit SetCheckTokensIsFromIssue1Executed(msg.sender, _check);
    }

    function pause() external onlyRole(DEFAULT_ADMIN_ROLE) {
        _pause();
    }

    function unpause() external onlyRole(DEFAULT_ADMIN_ROLE) {
        _unpause();
    }
}