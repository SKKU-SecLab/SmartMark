
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
}// GPL-3.0-or-later

pragma solidity >=0.6.0;

library TransferHelper {

    function safeApprove(
        address token,
        address to,
        uint256 value
    ) internal {

        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            'TransferHelper::safeApprove: approve failed'
        );
    }

    function safeTransfer(
        address token,
        address to,
        uint256 value
    ) internal {

        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            'TransferHelper::safeTransfer: transfer failed'
        );
    }

    function safeTransferFrom(
        address token,
        address from,
        address to,
        uint256 value
    ) internal {

        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            'TransferHelper::transferFrom: transferFrom failed'
        );
    }

    function safeTransferETH(address to, uint256 value) internal {

        (bool success, ) = to.call{value: value}(new bytes(0));
        require(success, 'TransferHelper::safeTransferETH: ETH transfer failed');
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

interface IERC2981Royalties {
    function royaltyInfo(uint256 _tokenId, uint256 _value)
        external
        view
        returns (address _receiver, uint256 _royaltyAmount);
}// MIT
pragma solidity ^0.8.0;



abstract contract ERC2981Base is ERC165, IERC2981Royalties {
    struct RoyaltyInfo {
        address recipient;
        uint24 amount;
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override
        returns (bool)
    {
        return
            interfaceId == type(IERC2981Royalties).interfaceId ||
            super.supportsInterface(interfaceId);
    }
}// MIT
pragma solidity ^0.8.0;



abstract contract ERC2981ContractWideRoyalties is ERC2981Base {
    RoyaltyInfo private _royalties;

    function _setRoyalties(address recipient, uint256 value) internal {
        require(value <= 10000, 'ERC2981Royalties: Too high');
        _royalties = RoyaltyInfo(recipient, uint24(value));
    }

    function royaltyInfo(uint256, uint256 value)
        external
        view
        override
        returns (address receiver, uint256 royaltyAmount)
    {
        RoyaltyInfo memory royalties = _royalties;
        receiver = royalties.recipient;
        royaltyAmount = (value * royalties.amount) / 10000;
    }
}// MIT
pragma solidity ^0.8.2;


contract EroNFT is ERC721, ERC721Enumerable, ERC721URIStorage, ERC2981ContractWideRoyalties, Ownable {
    using Strings for uint256;
    string public baseURI;

    constructor(uint _royalties, string memory _name, string memory _symbol) 
        ERC721(_name, _symbol) {
        _setRoyalties(_msgSender(), _royalties);
    }

    function safeMint(address to, uint256 tokenId) public onlyOwner {
        _safeMint(to, tokenId);
    }

    function _beforeTokenTransfer(address from, address to, uint256 tokenId)
        internal
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
        return string(abi.encodePacked(baseURI, tokenId.toString(), ".json"));
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable, ERC2981Base)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    function _baseURI() 
        internal 
        view
        override(ERC721) returns (string memory) {
        return baseURI;
    }

    function setBaseURI(string memory _baseURI) public onlyOwner {
        baseURI = _baseURI;
    }
}// GPL-3.0-only
pragma solidity ^0.8.4;


contract ListingRegistry is Ownable, Pausable {
    uint16 public constant BPS_DIVISOR = 10000;
    address public immutable ERO_TOKEN_ADDRESS;
    address public immutable ERO_NFT_ADDRESS;
    address public immutable NAMESPACE_CONTRACT_ADDRESS;

    constructor(
        address _eroToken,
        address _eroNFT,
        address _namespaceContract,
        address _devAddress,
        address _daoAddress,
        uint16 _creatorRevShareBips,
        uint16 _devRevShareBips,
        uint16 _daoRevShareBips
    ) {
        require(
            _creatorRevShareBips + _devRevShareBips + _daoRevShareBips ==
                BPS_DIVISOR,
            "LR: Sum must eq 10000."
        );

        NAMESPACE_CONTRACT_ADDRESS = _namespaceContract;
        ERO_NFT_ADDRESS = _eroNFT;
        ERO_TOKEN_ADDRESS = _eroToken;

        devAddress = _devAddress;
        daoAddress = _daoAddress;

        creatorRevShareBips = _creatorRevShareBips;
        devRevShareBips = _devRevShareBips;
        daoRevShareBips = _daoRevShareBips;
    }

    struct Listing {
        bytes1 listingFlags; // 1 byte,
        uint16 endDiscountBips; // 16 bytes
        address listingOwner; //20 bytes
        address minterToken; // 20 bytes
        uint256 listingPrice; // 32 bytes
        uint256 mintableSupply; // 32 bytes
        uint256 startBlock; // 32 bytes
        uint256 endBlock; // 32 bytes
        uint256 nonce; // 32 bytes
        uint256 startAlloc; //32 bytes
    }

    event ListingAdded(Listing newListing);

    event FlagsUpdated(
        bytes32 listingId,
        address executedBy,
        bytes1 prev,
        bytes1 current
    );

    event ListingUnitPriceUpdated(
        uint256 oldValue,
        uint256 newValue
    );

    event RevShareBipsUpdated(
        uint16 prevCreatorRevShareBips,
        uint16 prevDevRevShareBips,
        uint16 prevDaoRevShareBips,
        uint16 curCreatorRevShareBips,
        uint16 curDevRevShareBips,
        uint16 curDaoRevShareBips
    );

    event DevAddressUpdated(address prevDevAddress, address curDevAddress);
    event DaoAddressUpdated(address prevDaoAddress, address curDaoAddress);
    event ERC20Whitelisted(address erc20Address);

    uint16 public creatorRevShareBips;
    uint16 public devRevShareBips;
    uint16 public daoRevShareBips;

    address public devAddress;
    address public daoAddress;

    uint256 public lastAllocatedIndex;
    uint256 public listingUnitPrice;

    mapping(address => bool) public erc20Whitelist;
    mapping(bytes32 => Listing) public registry;
    mapping(address => mapping(address => uint256)) public claimableERC20;

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    function addWhitelistERC20(address _erc20Address) public onlyOwner {
        erc20Whitelist[_erc20Address] = true;

        emit ERC20Whitelisted(_erc20Address);
    }

    function removeWhitelistERC20(address _erc20Address) public onlyOwner {
        erc20Whitelist[_erc20Address] = false;

        emit ERC20Whitelisted(_erc20Address);
    }

    function setListingUnitPrice(uint256 val) public onlyOwner {
        emit ListingUnitPriceUpdated(listingUnitPrice, val);

        listingUnitPrice = val;
    }

    function setRevShareBips(
        uint16 _creatorRevShareBips,
        uint16 _devRevShareBips,
        uint16 _daoRevShareBips
    ) public onlyOwner {
        require(
            _creatorRevShareBips + _devRevShareBips + _daoRevShareBips ==
                BPS_DIVISOR,
            "LR: Sum !eq 10000."
        );

        emit RevShareBipsUpdated(
            creatorRevShareBips,
            devRevShareBips,
            daoRevShareBips,
            _creatorRevShareBips,
            _devRevShareBips,
            _daoRevShareBips
        );
        creatorRevShareBips = _creatorRevShareBips;
        devRevShareBips = _devRevShareBips;
        daoRevShareBips = _daoRevShareBips;
    }

    function setDevAddress(address _devAddress) public onlyOwner {
        require(_devAddress != address(0), "LR: can't set to zero address.");

        emit DevAddressUpdated(devAddress, _devAddress);
        devAddress = _devAddress;
    }

    function setDaoAddress(address _daoAddress) public onlyOwner {
        require(_daoAddress != address(0), "LR: can't set to zero address.");

        emit DaoAddressUpdated(daoAddress, _daoAddress);
        daoAddress = _daoAddress;
    }

    function getListingId(string memory _namespace, string memory _ctx) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(
            _namespace,
            _ctx
        ));
    }

    function _getNamespaceOwner(string memory _namespace)
    internal view returns (address) {
        bytes32 _tokenId = keccak256(abi.encodePacked(_namespace));

        return IERC721(NAMESPACE_CONTRACT_ADDRESS).ownerOf(uint256(_tokenId));
    }

    function addListing(
        string memory _namespace,
        string memory _ctx,
        uint16 _endDiscountBips,
        address _mintingToken,
        uint256 _initialPrice,
        uint256 _mintableSupply,
        uint256 _startBlock,
        uint256 _listingDuration,
        bytes1 _listingFlags
    ) public whenNotPaused {
        require(_getNamespaceOwner(_namespace) == _msgSender(), "LR: Namespace unauthorized.");
        require(_startBlock >= block.number, "LR: Invalid _startBlock.");
        require(_listingDuration != 0, "LR: Invalid _listingDuration.");
        require(EroNFT(ERO_NFT_ADDRESS).owner() == address(this), "LR: Contract isn't owner");
        require(_endDiscountBips <= 10000, "LR: endDiscountBips > 10000.");
        require(
            erc20Whitelist[_mintingToken],
            "LR: ERC20 Not whitelisted."
        );

        bytes32 listingId = getListingId(_namespace, _ctx);
        require(
            !_getBoolean(registry[listingId].listingFlags, 7),
            "LR: Listing exists."
        );

        TransferHelper.safeTransferFrom(ERO_TOKEN_ADDRESS, _msgSender(), daoAddress, _mintableSupply * listingUnitPrice);

        bytes1 initializedListingFlags = (bytes1(0x0f) & _listingFlags) | bytes1(0x80);

        Listing memory listing = Listing(
            initializedListingFlags,
            _endDiscountBips,
            _msgSender(),
            _mintingToken,
            _initialPrice,
            _mintableSupply,
            _startBlock,
            _startBlock + _listingDuration,
            0,
            lastAllocatedIndex
        );

        emit ListingAdded(listing);
        registry[listingId] = listing;

        lastAllocatedIndex = lastAllocatedIndex + _mintableSupply;
    }

    function setListingFlags(bytes32 _listingId, bytes1 _listingFlags)
        public
    {
        Listing storage listing = registry[_listingId];
        require(_getBoolean(listing.listingFlags, 7), "LR: Listing inactive.");
        require(
            _msgSender() == owner() || _msgSender() == listing.listingOwner,
            "LR: Unauthorized."
        );
        if (_msgSender() == owner()) {
            emit FlagsUpdated(
                _listingId,
                _msgSender(),
                listing.listingFlags,
                _listingFlags
            );
            listing.listingFlags = _listingFlags;
        } else if (_msgSender() == listing.listingOwner) {
            emit FlagsUpdated(
                _listingId,
                _msgSender(),
                listing.listingFlags,
                listing.listingFlags | (_listingFlags & bytes1(0x0f))
            );
            listing.listingFlags =
                listing.listingFlags |
                (_listingFlags & bytes1(0x0f));
        }
    }

    function getListingFlags(bytes32 _listingId)
        public
        view
        returns (bytes1)
    {
        Listing memory listing = registry[_listingId];

        return listing.listingFlags;
    }

    function _getBoolean(bytes1 _packedBools, uint8 _index)
        internal
        pure
        returns (bool)
    {
        uint8 flag = (uint8(_packedBools) >> _index) & uint8(1);
        return (flag > 0 ? true : false);
    }

    function mintNFT(
        bytes32 _listingId,
        uint256 _amount
    ) public whenNotPaused {
        require(
            hasStarted(_listingId) && !hasEnded(_listingId),
            "LR: Listing is not active."
        );
        Listing storage listing = registry[_listingId];

        uint256 currentPrice = getCurrentPrice(_listingId);

        require(
            _amount > 0 && _amount >= currentPrice,
            "LR: amount < currentPrice"
        );

        uint256 n = _amount / currentPrice;

        require(listing.mintableSupply >= n, "LR: Not enough mintableSupply.");
        listing.mintableSupply = listing.mintableSupply - n;

        uint256 contractCurrentERC20Balance = IERC20(listing.minterToken)
            .balanceOf(address(this));

        TransferHelper.safeTransferFrom(
            listing.minterToken,
            _msgSender(),
            address(this),
            n * currentPrice
        );

        require(
            (IERC20(listing.minterToken).balanceOf(address(this)) >
                contractCurrentERC20Balance),
            "LR: Balance not increased."
        );

        _addRevClaimables(
            _listingId,
            listing.minterToken,
            n * currentPrice
        );

        for (uint256 i = 0; i < n; i++) {

            uint256 tokenId = uint256(
                keccak256(
                    abi.encodePacked(
                        _listingId, listing.startAlloc + listing.nonce
                    )
                )
            );

            listing.nonce += 1;

            EroNFT(ERO_NFT_ADDRESS).safeMint(_msgSender(), tokenId);
        }
    }

    function _addRevClaimables(
        bytes32 _listingId,
        address _erc20Token,
        uint256 _value
    ) internal {
        address creatorAddress = registry[_listingId].listingOwner;

        claimableERC20[_erc20Token][creatorAddress] +=
            (_value * creatorRevShareBips) /
            BPS_DIVISOR;
        claimableERC20[_erc20Token][devAddress] +=
            (_value * devRevShareBips) /
            BPS_DIVISOR;
        claimableERC20[_erc20Token][daoAddress] +=
            (_value * daoRevShareBips) /
            BPS_DIVISOR;
    }

    function claimToken(address _erc20Address, uint256 _amount) public {
        require(
            claimableERC20[_erc20Address][_msgSender()] >= _amount,
            "LR: claimable < amount"
        );

        claimableERC20[_erc20Address][_msgSender()] -= _amount;
        require(
            IERC20(_erc20Address).transfer(_msgSender(), _amount),
            "LR: token transfer failed"
        );
    }

    function getCurrentPrice(bytes32 _listingId)
        public
        view
        returns (uint256)
    {
        Listing memory listing = registry[_listingId];
        require(
            listing.listingFlags >= bytes1(0x80),
            "LR: Listing not found."
        );

        uint256 discount = _calculateDiscount(
            listing.listingPrice,
            listing.endDiscountBips,
            listing.startBlock,
            listing.endBlock,
            block.number
        );
        uint256 currentPrice = listing.listingPrice - discount;

        return currentPrice;
    }

    function getNextPrice(bytes32 _listingId)
        public
        view
        returns (uint256)
    {
        Listing memory listing = registry[_listingId];
        require(
            listing.listingFlags >= bytes1(0x80),
            "LR: Listing not found."
        );

        uint256 discount = _calculateDiscount(
            listing.listingPrice,
            listing.endDiscountBips,
            listing.startBlock,
            listing.endBlock,
            block.number + 1
        );
        uint256 nextPrice = listing.listingPrice - discount;

        return nextPrice;
    }

    function _calculateDiscount(
        uint256 _initialPrice,
        uint256 _endDiscountBips,
        uint256 _startBlock,
        uint256 _endBlock,
        uint256 _currentBlock
    ) internal pure returns (uint256) {
        require(_endDiscountBips <= 10000, "LR: _endDiscountBips > 10000.");
        require(_startBlock < _endBlock, "LR: _startBlock >= _endBlock.");
        if (_currentBlock > _endBlock) {
            return (_initialPrice * _endDiscountBips) / BPS_DIVISOR;
        }

        if (_currentBlock < _startBlock) {
            return 0;
        }

        return
            ((_initialPrice *
                _endDiscountBips *
                (_currentBlock - _startBlock)) / (_endBlock - _startBlock)) /
            BPS_DIVISOR;
    }

    function hasStarted(bytes32 _listingId) public view returns (bool) {
        Listing memory listing = registry[_listingId];

        return block.number >= listing.startBlock;
    }

    function hasEnded(bytes32 _listingId) public view returns (bool) {
        Listing memory listing = registry[_listingId];

        return block.number >= listing.endBlock;
    }

    function transferNFTOwnership(address _to)
        public
        onlyOwner
    {
        EroNFT(ERO_NFT_ADDRESS).transferOwnership(_to);
    }
}