
pragma solidity ^0.8.0;

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}// MIT

pragma solidity ^0.8.0;



interface IAdminControl is IERC165 {


    event AdminApproved(address indexed account, address indexed sender);
    event AdminRevoked(address indexed account, address indexed sender);

    function getAdmins() external view returns (address[] memory);


    function approveAdmin(address admin) external;


    function revokeAdmin(address admin) external;


    function isAdmin(address admin) external view returns (bool);


}// MIT

pragma solidity ^0.8.0;



interface ICreatorCore is IERC165 {


    event ExtensionRegistered(address indexed extension, address indexed sender);
    event ExtensionUnregistered(address indexed extension, address indexed sender);
    event ExtensionBlacklisted(address indexed extension, address indexed sender);
    event MintPermissionsUpdated(address indexed extension, address indexed permissions, address indexed sender);
    event RoyaltiesUpdated(uint256 indexed tokenId, address payable[] receivers, uint256[] basisPoints);
    event DefaultRoyaltiesUpdated(address payable[] receivers, uint256[] basisPoints);
    event ExtensionRoyaltiesUpdated(address indexed extension, address payable[] receivers, uint256[] basisPoints);
    event ExtensionApproveTransferUpdated(address indexed extension, bool enabled);

    function getExtensions() external view returns (address[] memory);


    function registerExtension(address extension, string calldata baseURI) external;


    function registerExtension(address extension, string calldata baseURI, bool baseURIIdentical) external;


    function unregisterExtension(address extension) external;


    function blacklistExtension(address extension) external;


    function setBaseTokenURIExtension(string calldata uri) external;


    function setBaseTokenURIExtension(string calldata uri, bool identical) external;


    function setTokenURIPrefixExtension(string calldata prefix) external;


    function setTokenURIExtension(uint256 tokenId, string calldata uri) external;


    function setTokenURIExtension(uint256[] memory tokenId, string[] calldata uri) external;


    function setBaseTokenURI(string calldata uri) external;


    function setTokenURIPrefix(string calldata prefix) external;


    function setTokenURI(uint256 tokenId, string calldata uri) external;


    function setTokenURI(uint256[] memory tokenIds, string[] calldata uris) external;


    function setMintPermissions(address extension, address permissions) external;


    function setApproveTransferExtension(bool enabled) external;


    function tokenExtension(uint256 tokenId) external view returns (address);


    function setRoyalties(address payable[] calldata receivers, uint256[] calldata basisPoints) external;


    function setRoyalties(uint256 tokenId, address payable[] calldata receivers, uint256[] calldata basisPoints) external;


    function setRoyaltiesExtension(address extension, address payable[] calldata receivers, uint256[] calldata basisPoints) external;


    function getRoyalties(uint256 tokenId) external view returns (address payable[] memory, uint256[] memory);

    
    function getFeeRecipients(uint256 tokenId) external view returns (address payable[] memory);

    function getFeeBps(uint256 tokenId) external view returns (uint[] memory);

    function getFees(uint256 tokenId) external view returns (address payable[] memory, uint256[] memory);

    function royaltyInfo(uint256 tokenId, uint256 value) external view returns (address, uint256);


}// MIT

pragma solidity ^0.8.0;



interface IERC721CreatorCore is ICreatorCore {


    function mintBase(address to) external returns (uint256);


    function mintBase(address to, string calldata uri) external returns (uint256);


    function mintBaseBatch(address to, uint16 count) external returns (uint256[] memory);


    function mintBaseBatch(address to, string[] calldata uris) external returns (uint256[] memory);


    function mintExtension(address to) external returns (uint256);


    function mintExtension(address to, string calldata uri) external returns (uint256);


    function mintExtensionBatch(address to, uint16 count) external returns (uint256[] memory);


    function mintExtensionBatch(address to, string[] calldata uris) external returns (uint256[] memory);


    function burn(uint256 tokenId) external;


}// MIT

pragma solidity ^0.8.0;


abstract contract ERC165 is IERC165 {
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}// MIT

pragma solidity ^0.8.0;



abstract contract CreatorExtension is ERC165 {

    bytes4 constant internal LEGACY_EXTENSION_INTERFACE = 0x7005caad;

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165) returns (bool) {
        return interfaceId == LEGACY_EXTENSION_INTERFACE
            || super.supportsInterface(interfaceId);
    }
    
}// MIT

pragma solidity ^0.8.0;



interface ICreatorExtensionTokenURI is IERC165 {


    function tokenURI(address creator, uint256 tokenId) external view returns (string memory);

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


interface IManifoldERC721Edition {

    event SeriesCreated(address caller, address creator, uint256 series, uint256 maxSupply);

    function createSeries(address creator, uint256 maxSupply, string calldata prefix) external returns(uint256);


    function latestSeries(address creator) external view returns(uint256);


    function setTokenURIPrefix(address creator, uint256 series, string calldata prefix) external;

    
    function mint(address creator, uint256 series, address recipient, uint16 count) external payable;


    function mintInternal(address creator, uint256 series, address[] calldata recipients) external;


    function totalSupply(address creator, uint256 series) external view returns(uint256);


    function maxSupply(address creator, uint256 series) external view returns(uint256);

}// MIT

pragma solidity ^0.8.0;




contract MitchellsExtension is CreatorExtension, ICreatorExtensionTokenURI, IManifoldERC721Edition, ReentrancyGuard {

    using SafeMath for uint256;
    using Strings for uint256;

    struct IndexRange {
        uint256 startIndex;
        uint256 count;
    }

    mapping(address => mapping(uint256 => string)) public _tokenPrefix;
    mapping(address => mapping(uint256 => uint256)) public _maxSupply;
    mapping(address => mapping(uint256 => uint256)) public _price;
    mapping(address => mapping(uint256 => uint256)) public _totalSupply;
    mapping(address => mapping(uint256 => IndexRange[])) public _indexRanges;
    mapping(address => mapping(uint256 => mapping(uint256 => string))) public _scripts;
    mapping(address => mapping(uint256 => mapping(uint256 => uint256))) _creationDates;
    mapping(address => mapping(uint256 => mapping(uint256 => address))) _creators;

    mapping(address => uint256) public _currentSeries;

    bool public pause = true;

    modifier creatorAdminRequired(address creator) {

        require(IAdminControl(creator).isAdmin(msg.sender), "Must be owner or admin of creator contract");
        _;
    }
    
    function supportsInterface(bytes4 interfaceId) public view virtual override(CreatorExtension, IERC165) returns (bool) {

        return interfaceId == type(ICreatorExtensionTokenURI).interfaceId || interfaceId == type(IManifoldERC721Edition).interfaceId ||
               CreatorExtension.supportsInterface(interfaceId);
    }

    function totalSupply(address creator, uint256 series) external view override returns(uint256) {

        return _totalSupply[creator][series];
    }

    function maxSupply(address creator, uint256 series) external view override returns(uint256) {

        return _maxSupply[creator][series];
    }

    function createSeries(address creator, uint256 maxSupply_, string calldata prefix) external override creatorAdminRequired(creator) returns(uint256) {

        _currentSeries[creator] += 1;
        uint256 series = _currentSeries[creator];
        _maxSupply[creator][series] = maxSupply_;
        _tokenPrefix[creator][series] = prefix;
        emit SeriesCreated(msg.sender, creator, series, maxSupply_);
        return series;
    }

    function latestSeries(address creator) external view override returns(uint256) {

        return _currentSeries[creator];
    }

    function setTokenURIPrefix(address creator, uint256 series, string calldata prefix) external override creatorAdminRequired(creator) {

        require(series > 0 && series <= _currentSeries[creator], "Invalid series");
        _tokenPrefix[creator][series] = prefix;
    }

    function setPrice(address creator, uint256 series, uint256 price) external creatorAdminRequired(creator) {

        require(series > 0 && series <= _currentSeries[creator], "Invalid series");
        _price[creator][series] = price;
    }
    
    function tokenURI(address creator, uint256 tokenId) external view override returns (string memory) {

        (uint256 series, uint256 index) = _tokenSeriesAndIndex(creator, tokenId);
        return string(abi.encodePacked(_tokenPrefix[creator][series], (index+1).toString()));
    }
    
    function mint(address creator, uint256 series, address recipient, uint16 count) external override payable {

        require(!pause, "Sale has not started");
        require(count > 0, "Invalid amount requested");
        require(_totalSupply[creator][series]+count <= _maxSupply[creator][series], "Too many requested");
        require(msg.value >=_price[creator][series].mul(count), "Not enough ETH sent");
        uint256[] memory tokenIds = IERC721CreatorCore(creator).mintExtensionBatch(recipient, count);
        
        uint mintIndex = _totalSupply[creator][series];
        for (uint256 i = 0; i < count;) {
            _creators[creator][series][mintIndex] = recipient;
            _creationDates[creator][series][mintIndex] = block.number;
            mintIndex++;
            unchecked{i++;}
        }

        _updateIndexRanges(creator, series, tokenIds[0], count);
    }

    function mintInternal(address creator, uint256 series, address[] calldata recipients) external override nonReentrant creatorAdminRequired(creator) {

        require(recipients.length > 0, "Invalid amount requested");
        require(_totalSupply[creator][series]+recipients.length <= _maxSupply[creator][series], "Too many requested");
        
        uint mintIndex = _totalSupply[creator][series];
        uint256 startIndex = IERC721CreatorCore(creator).mintExtension(recipients[0]);
        _creators[creator][series][mintIndex] = recipients[0];
        _creationDates[creator][series][mintIndex] = block.number;
        mintIndex ++;
        for (uint256 i = 1; i < recipients.length;) {
            IERC721CreatorCore(creator).mintExtension(recipients[i]);
            _creators[creator][series][mintIndex] = recipients[i];
            _creationDates[creator][series][mintIndex] = block.number;
            mintIndex++;
            unchecked{i++;}
        }
        _updateIndexRanges(creator, series, startIndex, recipients.length);
    }

    function _updateIndexRanges(address creator, uint256 series, uint256 startIndex, uint256 count) internal {

        IndexRange[] storage indexRanges = _indexRanges[creator][series];
        if (indexRanges.length == 0) {
           indexRanges.push(IndexRange(startIndex, count));
        } else {
          IndexRange storage lastIndexRange = indexRanges[indexRanges.length-1];
          if ((lastIndexRange.startIndex + lastIndexRange.count) == startIndex) {
             lastIndexRange.count += count;
          } else {
            indexRanges.push(IndexRange(startIndex, count));
          }
        }
        _totalSupply[creator][series] += count;
    }

    function _tokenSeriesAndIndex(address creator, uint256 tokenId) internal view returns(uint256, uint256) {

        require(_currentSeries[creator] > 0, "Invalid token");
        for (uint series=1; series <= _currentSeries[creator]; series++) {
            IndexRange[] memory indexRanges = _indexRanges[creator][series];
            uint256 offset;
            for (uint i = 0; i < indexRanges.length; i++) {
                IndexRange memory currentIndex = indexRanges[i];
                if (tokenId < currentIndex.startIndex) break;
                if (tokenId >= currentIndex.startIndex && tokenId < currentIndex.startIndex + currentIndex.count) {
                   return (series, tokenId - currentIndex.startIndex + offset);
                }
                offset += currentIndex.count;
            }
        }
        revert("Invalid token");
    }

    function tokenHash(address creator, uint256 series, uint256 tokenId) public view returns (bytes32){

        require(_totalSupply[creator][series] >= tokenId, "Token nonexistent");
        return bytes32(keccak256(abi.encodePacked(address(this), _creationDates[creator][series][tokenId], _creators[creator][series][tokenId], tokenId)));
    }

    function togglePause(address creator) public creatorAdminRequired(creator) {

        pause = !pause;
    }

    function addScriptChunk(address creator, uint256 series, uint256 index, string memory _chunk) public creatorAdminRequired(creator) {

        _scripts[creator][series][index]=_chunk;
    }

    function getScriptChunk(address creator, uint256 series, uint256 index) public view returns (string memory){

        return _scripts[creator][series][index];
    }

    function removeScriptChunk(address creator, uint256 series, uint256 index) public creatorAdminRequired(creator) {

        delete _scripts[creator][series][index];
    }

    function withdrawAll(address creator) public creatorAdminRequired(creator) payable {

        require(payable(msg.sender).send(address(this).balance));
    }
}