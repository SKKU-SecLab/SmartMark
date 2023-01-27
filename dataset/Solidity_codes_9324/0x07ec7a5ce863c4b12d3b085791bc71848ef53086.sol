
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
}//Unlicense
pragma solidity ^0.8.0;


interface IThePixelsInc {

    function balanceOf(address owner) external view returns (uint256 balance);


    function ownerOf(uint256 tokenId) external view returns (address owner);


    function tokensOfOwner(address _owner)
        external
        view
        returns (uint256[] memory);


    function updateDNAExtension(uint256 _tokenId) external;


    function pixelDNAs(uint256 _tokenId) external view returns (uint256);


    function pixelDNAExtensions(uint256 _tokenId)
        external
        view
        returns (uint256);

}// pragma solidity ^0.8.0;


pragma solidity ^0.8.0;

interface IThePixelsMetadataProvider {

    function getMetadata(
        uint256 tokenId,
        uint256 dna,
        uint256 dnaExtension
    ) external view returns (string memory);


    function fullDNAOfToken(uint256 tokenId)
        external
        view
        returns (string memory);

}// pragma solidity ^0.8.0;


pragma solidity ^0.8.0;

interface IThePixelsIncExtensionStorage {

    struct Variant {
        bool isOperatorExecution;
        bool isFreeForCollection;
        bool isEnabled;
        bool isDisabledForSpecialPixels;
        uint16 contributerCut;
        uint128 cost;
        uint128 supply;
        uint128 count;
        uint128 categoryId;
        address contributer;
        address collection;
    }

    struct Category {
        uint128 cost;
        uint128 supply;
    }

    struct VariantStatus {
        bool isAlreadyClaimed;
        uint128 cost;
        uint128 supply;
    }

    function extendWithVariant(
        address owner,
        uint256 extensionId,
        uint256 tokenId,
        uint256 variantId,
        bool useCollectionTokenId,
        uint256 collectionTokenId
    ) external;


    function extendMultipleWithVariants(
        address owner,
        uint256 extensionId,
        uint256[] memory tokenIds,
        uint256[] memory variantIds,
        bool[] memory useCollectionTokenId,
        uint256[] memory collectionTokenIds
    ) external;


    function variantDetails(
        address owner,
        uint256 extensionId,
        uint256[] memory tokenIds,
        uint256[] memory variantIds,
        bool[] memory useCollectionTokenIds,
        uint256[] memory collectionTokenIds
    ) external view returns (Variant[] memory, VariantStatus[] memory);


    function pixelExtensions(uint256 tokenId) external view returns (uint256);


    function balanceOfToken(
        uint256 extensionId,
        uint256 tokenId,
        uint256[] memory variantIds
    ) external view returns (uint256);


    function currentVariantIdOf(uint256 extensionId, uint256 tokenId)
        external
        view
        returns (uint256);

}// MIT


pragma solidity ^0.8.0;



contract ThePixelsIncMetadataURLProviderV3 is
    IThePixelsMetadataProvider,
    Ownable
{

    using Strings for uint256;

    struct BaseURL {
        bool useDNA;
        string url;
        string description;
    }

    string public initialBaseURL;
    BaseURL[] public baseURLs;

    address public immutable pixelsAddress;
    address public extensionStorageAddress;

    constructor(address _pixelsAddress, address _extensionStorageAddress) {
        pixelsAddress = _pixelsAddress;
        extensionStorageAddress = _extensionStorageAddress;
    }


    function setInitialBaseURL(string calldata _initialBaseURL)
        external
        onlyOwner
    {

        initialBaseURL = _initialBaseURL;
    }

    function setExtensionStorageAddress(address _extensionStorageAddress)
        external
        onlyOwner
    {

        extensionStorageAddress = _extensionStorageAddress;
    }

    function addBaseURL(
        bool _useDNA,
        string memory _url,
        string memory _description
    ) external onlyOwner {

        baseURLs.push(BaseURL(_useDNA, _url, _description));
    }

    function setBaseURL(
        uint256 id,
        bool _useDNA,
        string memory _url,
        string memory _description
    ) external onlyOwner {

        baseURLs[id] = (BaseURL(_useDNA, _url, _description));
    }


    function getMetadata(
        uint256 tokenId,
        uint256 dna,
        uint256 extensionV1
    ) public view override returns (string memory) {

        uint256 extensionV2 = IThePixelsIncExtensionStorage(
            extensionStorageAddress
        ).pixelExtensions(tokenId);

        string memory fullDNA = _fullDNA(dna, extensionV1, extensionV2);
        BaseURL memory currentBaseURL = baseURLs[baseURLs.length - 1];

        if (extensionV1 > 0 || extensionV2 > 0) {
            if (currentBaseURL.useDNA) {
                return
                    string(abi.encodePacked(currentBaseURL.url, "/", fullDNA));
            } else {
                return
                    string(
                        abi.encodePacked(
                            currentBaseURL.url,
                            "/",
                            tokenId.toString()
                        )
                    );
            }
        } else {
            return string(abi.encodePacked(initialBaseURL, "/", fullDNA));
        }
    }

    function fullDNAOfToken(uint256 tokenId)
        public
        view
        override
        returns (string memory)
    {

        uint256 dna = IThePixelsInc(pixelsAddress).pixelDNAs(tokenId);
        uint256 extensionV1 = IThePixelsInc(pixelsAddress).pixelDNAExtensions(
            tokenId
        );
        uint256 extensionV2 = IThePixelsIncExtensionStorage(
            extensionStorageAddress
        ).pixelExtensions(tokenId);

        return _fullDNA(dna, extensionV1, extensionV2);
    }

    function lastBaseURL() public view returns (string memory) {

        return baseURLs[baseURLs.length - 1].url;
    }


    function _fullDNA(
        uint256 _dna,
        uint256 _extensionV1,
        uint256 _extensionV2
    ) internal pure returns (string memory) {

        if (_extensionV1 == 0 && _extensionV2 == 0) {
            return _dna.toString();
        }
        string memory _extension = _fixedExtension(_extensionV1, _extensionV2);
        return string(abi.encodePacked(_dna.toString(), "_", _extension));
    }

    function _fixedExtension(uint256 _extensionV1, uint256 _extensionV2)
        internal
        pure
        returns (string memory)
    {

        if (_extensionV2 > 0) {
            return
                string(
                    abi.encodePacked(
                        _extensionV1.toString(),
                        _extensionV2.toString()
                    )
                );
        }else if (_extensionV1 == 0) {
            return "";
        }

        return _extensionV1.toString();
    }
}