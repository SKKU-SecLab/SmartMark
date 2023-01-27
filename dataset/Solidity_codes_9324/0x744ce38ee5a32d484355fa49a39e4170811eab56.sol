
pragma solidity ^0.8.0;

library StringsUpgradeable {

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

abstract contract Proxied {
    modifier proxied() {
        address proxyAdminAddress = _proxyAdmin();
        if (proxyAdminAddress == address(0)) {
            assembly {
                sstore(
                    0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103,
                    0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
                )
            }
        } else {
            require(msg.sender == proxyAdminAddress);
        }
        _;
    }

    modifier onlyProxyAdmin() {
        require(msg.sender == _proxyAdmin(), "NOT_AUTHORIZED");
        _;
    }

    function _proxyAdmin() internal view returns (address ownerAddress) {
        assembly {
            ownerAddress := sload(0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103)
        }
    }
}// MIT
pragma solidity ^0.8.0;

interface ITraits {

  function tokenURI(uint256 tokenId) external view returns (string memory);

}// MIT
pragma solidity ^0.8.0;

interface IChickenNoodle {

    struct ChickenNoodleTraits {
        bool minted;
        bool isChicken;
        uint8 backgrounds;
        uint8 snakeBodies;
        uint8 mouthAccessories;
        uint8 pupils;
        uint8 bodyAccessories;
        uint8 hats;
        uint8 tier;
    }

    function MAX_TOKENS() external view returns (uint256);


    function PAID_TOKENS() external view returns (uint256);


    function tokenTraits(uint256 tokenId)
        external
        view
        returns (ChickenNoodleTraits memory);


    function totalSupply() external view returns (uint256);


    function balanceOf(address tokenOwner) external view returns (uint256);


    function ownerOf(uint256 tokenId) external view returns (address);


    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;


    function mint(address to, uint16 tokenId) external;


    function finalize(
        uint16 tokenId,
        ChickenNoodleTraits memory traits,
        address thief
    ) external;

}// MIT
pragma solidity ^0.8.0;



contract Traits is Proxied, ITraits {

    using StringsUpgradeable for uint256;
    using StringsUpgradeable for uint8;

    string[7] _traitTypes;

    string public imageBaseURI;
    string public description;
    mapping(uint8 => mapping(uint8 => string)) public traitData;

    IChickenNoodle public chickenNoodle;


    function initialize(string memory _imageBaseURI) public proxied {

        imageBaseURI = _imageBaseURI;

        _traitTypes = [
            'Backgrounds',
            'Snake Bodies',
            'Mouth Accessories',
            'Pupils',
            'Body Accessories',
            'Hats',
            'Tier'
        ];
    }


    function setChickenNoodle(address _chickenNoodle) external onlyProxyAdmin {

        chickenNoodle = IChickenNoodle(_chickenNoodle);
    }

    function setImageBaseURI(string calldata _imageBaseURI)
        external
        onlyProxyAdmin
    {

        imageBaseURI = _imageBaseURI;
    }

    function setDescription(string calldata _description)
        external
        onlyProxyAdmin
    {

        description = _description;
    }

    function uploadTraits(
        uint8 traitType,
        uint8[] calldata traitIds,
        string[] calldata names
    ) external onlyProxyAdmin {

        require(traitIds.length == names.length, 'Mismatched inputs');
        for (uint256 i = 0; i < names.length; i++) {
            traitData[traitType][traitIds[i]] = names[i];
        }
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

        IChickenNoodle.ChickenNoodleTraits memory s = chickenNoodle.tokenTraits(
            tokenId
        );
        string memory traits;

        if (!s.minted) {
            return
                string(
                    abi.encodePacked(
                        '[{"trait_type":"Generation","value":',
                        tokenId <= chickenNoodle.PAID_TOKENS()
                            ? '"Gen 0"'
                            : '"Gen 1"',
                        '},{"trait_type":"Status","value":"Minting"}]'
                    )
                );
        }

        if (s.isChicken) {
            traits = string(
                abi.encodePacked(
                    attributeForTypeAndValue(
                        _traitTypes[0],
                        traitData[0][s.backgrounds]
                    ),
                    ',',
                    attributeForTypeAndValue(
                        _traitTypes[1],
                        traitData[1][s.snakeBodies]
                    ),
                    ',',
                    attributeForTypeAndValue(
                        _traitTypes[2],
                        traitData[2][s.mouthAccessories]
                    ),
                    ',',
                    attributeForTypeAndValue(
                        _traitTypes[3],
                        traitData[3][s.pupils]
                    ),
                    ',',
                    attributeForTypeAndValue(_traitTypes[4], 'Chicken Suit'),
                    ',',
                    attributeForTypeAndValue(
                        _traitTypes[5],
                        traitData[5][s.hats]
                    )
                )
            );
        } else {
            traits = string(
                abi.encodePacked(
                    attributeForTypeAndValue(
                        _traitTypes[0],
                        traitData[0][s.backgrounds]
                    ),
                    ',',
                    attributeForTypeAndValue(
                        _traitTypes[1],
                        traitData[1][s.snakeBodies]
                    ),
                    ',',
                    attributeForTypeAndValue(
                        _traitTypes[2],
                        traitData[2][s.mouthAccessories]
                    ),
                    ',',
                    attributeForTypeAndValue(
                        _traitTypes[3],
                        traitData[3][s.pupils]
                    ),
                    ',',
                    attributeForTypeAndValue(
                        _traitTypes[4],
                        traitData[4][s.bodyAccessories]
                    ),
                    ',',
                    attributeForTypeAndValue(
                        _traitTypes[5],
                        traitData[5][s.hats]
                    ),
                    ',',
                    attributeForTypeAndValue('Tier', s.tier.toString())
                )
            );
        }

        return
            string(
                abi.encodePacked(
                    '[',
                    '{"trait_type":"Generation","value":',
                    tokenId <= chickenNoodle.PAID_TOKENS()
                        ? '"Gen 0"'
                        : '"Gen 1"',
                    '},{"trait_type":"Type","value":',
                    s.isChicken ? '"Chicken"' : '"Snake"',
                    '},',
                    traits,
                    ']'
                )
            );
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override
        returns (string memory)
    {
        IChickenNoodle.ChickenNoodleTraits memory s = chickenNoodle.tokenTraits(
            tokenId
        );

        string memory metadata = string(
            abi.encodePacked(
                '{"name": "',
                s.isChicken ? 'Chicken #' : 'Noodle #',
                tokenId.toString(),
                '", "image": "',
                imageBaseURI,
                tokenId.toString(),
                '.png", "description": "',
                description,
                '", "attributes":',
                compileAttributes(tokenId),
                '}'
            )
        );

        return
            string(
                abi.encodePacked(
                    'data:application/json;base64,',
                    base64(bytes(metadata))
                )
            );
    }


    string internal constant TABLE =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';

    function base64(bytes memory data) internal pure returns (string memory) {
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