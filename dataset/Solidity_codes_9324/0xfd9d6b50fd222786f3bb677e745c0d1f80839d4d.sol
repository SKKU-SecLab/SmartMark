
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

pragma solidity ^0.8.7;

interface RewardLike {

    function mintMany(address to, uint256 amount) external;

}

interface IDNAChip is RewardLike {

    function tokenIdToTraits(uint256 tokenId) external view returns (uint256);


    function isEvolutionPod(uint256 tokenId) external view returns (bool);


    function breedingIdToEvolutionPod(uint256 tokenId) external view returns (uint256);

}

interface IDescriptor {

    function tokenURI(uint256 _tokenId) external view returns (string memory);


    function tokenBreedingURI(uint256 _tokenId, uint256 _breedingId) external view returns (string memory);


    function tokenIncubatorURI(uint256 _breedingId) external view returns (string memory);

}

interface IEvolutionTraits {

    function getDNAChipSVG(uint256 base) external view returns (string memory);


    function getEvolutionPodImageTag(uint256 base) external view returns (string memory);


    function getTraitsImageTags(uint8[8] memory traits) external view returns (string memory);


    function getTraitsImageTagsByOrder(uint8[8] memory traits, uint8[8] memory traitsOrder)
        external
        view
        returns (string memory);


    function getMetadata(uint8[8] memory traits) external view returns (string memory);


    function evolvedIncubatorImage() external view returns (string memory);

}

interface IERC721Like {

    function transferFrom(
        address from,
        address to,
        uint256 id
    ) external;


    function transfer(address to, uint256 id) external;


    function ownerOf(uint256 id) external returns (address owner);


    function mint(address to, uint256 tokenid) external;

}// MIT
pragma solidity ^0.8.0;

library AnonymiceLibrary {

    string internal constant TABLE =
        "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

    function encode(bytes memory data) internal pure returns (string memory) {

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

    function parseInt(string memory _a)
        internal
        pure
        returns (uint8 _parsedInt)
    {

        bytes memory bresult = bytes(_a);
        uint8 mint = 0;
        for (uint8 i = 0; i < bresult.length; i++) {
            if (
                (uint8(uint8(bresult[i])) >= 48) &&
                (uint8(uint8(bresult[i])) <= 57)
            ) {
                mint *= 10;
                mint += uint8(bresult[i]) - 48;
            }
        }
        return mint;
    }

    function substring(
        string memory str,
        uint256 startIndex,
        uint256 endIndex
    ) internal pure returns (string memory) {

        bytes memory strBytes = bytes(str);
        bytes memory result = new bytes(endIndex - startIndex);
        for (uint256 i = startIndex; i < endIndex; i++) {
            result[i - startIndex] = strBytes[i];
        }
        return string(result);
    }

    function isContract(address account) internal view returns (bool) {


        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }
}// MIT
pragma solidity ^0.8.7;

library RedactedLibrary {

    struct Traits {
        uint256 base;
        uint256 earrings;
        uint256 eyes;
        uint256 hats;
        uint256 mouths;
        uint256 necks;
        uint256 noses;
        uint256 whiskers;
    }

    struct TightTraits {
        uint8 base;
        uint8 earrings;
        uint8 eyes;
        uint8 hats;
        uint8 mouths;
        uint8 necks;
        uint8 noses;
        uint8 whiskers;
    }

    function traitsToRepresentation(Traits memory traits) internal pure returns (uint256) {

        uint256 representation = uint256(traits.base);
        representation |= traits.earrings << 8;
        representation |= traits.eyes << 16;
        representation |= traits.hats << 24;
        representation |= traits.mouths << 32;
        representation |= traits.necks << 40;
        representation |= traits.noses << 48;
        representation |= traits.whiskers << 56;

        return representation;
    }

    function representationToTraits(uint256 representation) internal pure returns (Traits memory traits) {

        traits.base = uint8(representation);
        traits.earrings = uint8(representation >> 8);
        traits.eyes = uint8(representation >> 16);
        traits.hats = uint8(representation >> 24);
        traits.mouths = uint8(representation >> 32);
        traits.necks = uint8(representation >> 40);
        traits.noses = uint8(representation >> 48);
        traits.whiskers = uint8(representation >> 56);
    }

    function representationToTraitsArray(uint256 representation) internal pure returns (uint8[8] memory traitsArray) {

        traitsArray[0] = uint8(representation); // base
        traitsArray[1] = uint8(representation >> 8); // earrings
        traitsArray[2] = uint8(representation >> 16); // eyes
        traitsArray[3] = uint8(representation >> 24); // hats
        traitsArray[4] = uint8(representation >> 32); // mouths
        traitsArray[5] = uint8(representation >> 40); // necks
        traitsArray[6] = uint8(representation >> 48); // noses
        traitsArray[7] = uint8(representation >> 56); // whiskers
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


interface IERC721Enumerable is IERC721 {

    function totalSupply() external view returns (uint256);


    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256 tokenId);


    function tokenByIndex(uint256 index) external view returns (uint256);

}// MIT


pragma solidity ^0.8.0;


interface IAnonymiceBreeding is IERC721Enumerable {

    struct Incubator {
        uint256 parentId1;
        uint256 parentId2;
        uint256 childId;
        uint256 revealBlock;
    }

    function _tokenIdToLegendary(uint256 _tokenId) external view returns (bool);


    function _tokenIdToLegendaryNumber(uint256 _tokenId)
        external
        view
        returns (uint8);


    function _tokenToRevealed(uint256 _tokenId) external view returns (bool);


    function _tokenIdToHash(uint256 _tokenId)
        external
        view
        returns (string memory);


    function _tokenToIncubator(uint256 _tokenId)
        external
        view
        returns (Incubator memory);

}// MIT
pragma solidity ^0.8.7;


contract DNAChipDescriptor is Ownable {

    address public dnaChipAddress;
    address public evolutionTraitsAddress;
    address public breedingAddress;

    uint8 public constant BASE_INDEX = 0;
    uint8 public constant EARRINGS_INDEX = 1;
    uint8 public constant EYES_INDEX = 2;
    uint8 public constant HATS_INDEX = 3;
    uint8 public constant MOUTHS_INDEX = 4;
    uint8 public constant NECKS_INDEX = 5;
    uint8 public constant NOSES_INDEX = 6;
    uint8 public constant WHISKERS_INDEX = 7;

    constructor() {}

    function setAddresses(
        address _dnaChipAddress,
        address _evolutionTraitsAddress,
        address _breedingAddress
    ) external onlyOwner {

        dnaChipAddress = _dnaChipAddress;
        evolutionTraitsAddress = _evolutionTraitsAddress;
        breedingAddress = _breedingAddress;
    }

    function tokenURI(uint256 _tokenId) public view returns (string memory) {

        uint8[8] memory traits = RedactedLibrary.representationToTraitsArray(
            IDNAChip(dnaChipAddress).tokenIdToTraits(_tokenId)
        );
        bool isEvolutionPod = IDNAChip(dnaChipAddress).isEvolutionPod(_tokenId);
        string memory name;
        string memory image;
        if (!isEvolutionPod) {
            name = string(abi.encodePacked('{"name": "DNA Chip #', AnonymiceLibrary.toString(_tokenId)));
            image = AnonymiceLibrary.encode(bytes(getChipSVG(traits)));
        } else {
            name = string(abi.encodePacked('{"name": "Evolution Pod #', AnonymiceLibrary.toString(_tokenId)));
            image = AnonymiceLibrary.encode(bytes(getEvolutionPodSVG(traits)));
        }

        return
            string(
                abi.encodePacked(
                    "data:application/json;base64,",
                    AnonymiceLibrary.encode(
                        bytes(
                            string(
                                abi.encodePacked(
                                    name,
                                    '", "image": "data:image/svg+xml;base64,',
                                    image,
                                    '","attributes": [',
                                    IEvolutionTraits(evolutionTraitsAddress).getMetadata(traits),
                                    ', {"trait_type" :"Assembled", "value" : "',
                                    isEvolutionPod ? "Yes" : "No",
                                    '"}',
                                    "]",
                                    ', "description": "DNA Chips is a collection of 3,550 DNA Chips. All the metadata and images are generated and stored 100% on-chain. No IPFS, no API. Just the Ethereum blockchain."',
                                    "}"
                                )
                            )
                        )
                    )
                )
            );
    }

    function tokenBreedingURI(uint256 _tokenId, uint256 _breedingId) public view returns (string memory) {
        uint256 traitsRepresentation = IDNAChip(dnaChipAddress).tokenIdToTraits(_tokenId);
        uint8[8] memory traits = RedactedLibrary.representationToTraitsArray(traitsRepresentation);
        string memory name = string(abi.encodePacked('{"name": "Baby Mouse #', AnonymiceLibrary.toString(_breedingId)));
        return
            string(
                abi.encodePacked(
                    "data:application/json;base64,",
                    AnonymiceLibrary.encode(
                        bytes(
                            string(
                                abi.encodePacked(
                                    name,
                                    '", "image": "data:image/svg+xml;base64,',
                                    AnonymiceLibrary.encode(bytes(getBreedingSVG(traits))),
                                    '","attributes": [',
                                    IEvolutionTraits(evolutionTraitsAddress).getMetadata(traits),
                                    "]",
                                    ', "description": "Anonymice Breeding is a collection of 3,550 baby mice. All the metadata and images are generated and stored 100% on-chain. No IPFS, no API. Just the Ethereum blockchain."',
                                    "}"
                                )
                            )
                        )
                    )
                )
            );
    }

    function tokenIncubatorURI(uint256 _breedingId) public view returns (string memory) {
        string memory name = string(
            abi.encodePacked('{"name": "Evolved Incubator #', AnonymiceLibrary.toString(_breedingId))
        );
        return
            string(
                abi.encodePacked(
                    "data:application/json;base64,",
                    AnonymiceLibrary.encode(
                        bytes(
                            string(
                                abi.encodePacked(
                                    name,
                                    '", "image": "data:image/svg+xml;base64,',
                                    AnonymiceLibrary.encode(bytes(getEvolvedIncubatorSVG())),
                                    '","attributes":',
                                    evolvedIncubatorIdToAttributes(_breedingId),
                                    ', "description": "Anonymice Breeding is a collection of 3,550 baby mice. All the metadata and images are generated and stored 100% on-chain. No IPFS, no API. Just the Ethereum blockchain."',
                                    "}"
                                )
                            )
                        )
                    )
                )
            );
    }

    function evolvedIncubatorIdToAttributes(uint256 _breedingId) public view returns (string memory) {
        return
            string(
                abi.encodePacked(
                    '[{"trait_type": "Parent #1 ID", "value": "',
                    AnonymiceLibrary.toString(
                        IAnonymiceBreeding(breedingAddress)._tokenToIncubator(_breedingId).parentId1
                    ),
                    '"},{"trait_type": "Parent #2 ID", "value": "',
                    AnonymiceLibrary.toString(
                        IAnonymiceBreeding(breedingAddress)._tokenToIncubator(_breedingId).parentId2
                    ),
                    '"}, {"trait_type" :"revealed","value" : "Not Revealed Evolution"}]'
                )
            );
    }

    function getChipSVG(uint8[8] memory traits) internal view returns (string memory) {
        string memory imageTag = IEvolutionTraits(evolutionTraitsAddress).getDNAChipSVG(traits[0]);
        return
            string(
                abi.encodePacked(
                    '<svg id="dna-chip" width="100%" height="100%" version="1.1" viewBox="0 0 120 120" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink">',
                    imageTag,
                    '<g transform="translate(43, 33) scale(1.5)">',
                    IEvolutionTraits(evolutionTraitsAddress).getTraitsImageTagsByOrder(
                        traits,
                        [
                            BASE_INDEX,
                            NECKS_INDEX,
                            MOUTHS_INDEX,
                            NOSES_INDEX,
                            WHISKERS_INDEX,
                            EYES_INDEX,
                            EARRINGS_INDEX,
                            HATS_INDEX
                        ]
                    ),
                    "</g>",
                    "</svg>"
                )
            );
    }

    function getEvolutionPodSVG(uint8[8] memory traits) public view returns (string memory) {
        uint8 base = traits[0];
        string memory preview;
        if (base == 0) {
            preview = '<g transform="translate(75,69)">';
        } else if (base == 1) {
            preview = '<g transform="translate(85,74)">';
        } else if (base == 2) {
            preview = '<g transform="translate(70,80)">';
        } else if (base == 3) {
            preview = '<g transform="translate(19,56)">';
        } else if (base == 4) {
            preview = '<g transform="translate(75,58)">';
        }
        preview = string(
            abi.encodePacked(
                preview,
                IEvolutionTraits(evolutionTraitsAddress).getTraitsImageTagsByOrder(
                    traits,
                    [
                        BASE_INDEX,
                        NECKS_INDEX,
                        MOUTHS_INDEX,
                        NOSES_INDEX,
                        WHISKERS_INDEX,
                        EYES_INDEX,
                        EARRINGS_INDEX,
                        HATS_INDEX
                    ]
                ),
                "</g>"
            )
        );

        string
            memory result = '<svg id="evolution-pod" width="100%" height="100%" version="1.1" viewBox="0 0 125 125" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink">';

        result = string(
            abi.encodePacked(
                result,
                IEvolutionTraits(evolutionTraitsAddress).getEvolutionPodImageTag(base),
                preview,
                "</svg>"
            )
        );
        return result;
    }

    function getBreedingSVG(uint8[8] memory traits) public view returns (string memory) {
        string
            memory result = '<svg id="ebaby" width="100%" height="100%" version="1.1" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink">';

        result = string(
            abi.encodePacked(
                result,
                IEvolutionTraits(evolutionTraitsAddress).getTraitsImageTagsByOrder(
                    traits,
                    [
                        BASE_INDEX,
                        NECKS_INDEX,
                        MOUTHS_INDEX,
                        NOSES_INDEX,
                        WHISKERS_INDEX,
                        EYES_INDEX,
                        EARRINGS_INDEX,
                        HATS_INDEX
                    ]
                ),
                "</svg>"
            )
        );
        return result;
    }

    function getEvolvedIncubatorSVG() public view returns (string memory) {
        string
            memory result = '<svg id="eincubator" width="100%" height="100%" version="1.1" viewBox="0 0 52 52" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink">';

        result = string(
            abi.encodePacked(result, IEvolutionTraits(evolutionTraitsAddress).evolvedIncubatorImage(), "</svg>")
        );
        return result;
    }
}

