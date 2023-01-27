
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
}//MIT
pragma solidity ^0.8.0;

library Randomize {

    struct Random {
        uint256 seed;
    }

    function next(Random memory random, uint256 min, uint256 max) internal pure returns (uint256) {

        random.seed ^= random.seed << 13;
        random.seed ^= random.seed >> 17;
        random.seed ^= random.seed << 5;
        return min + random.seed % (max - min);
    }
}//MIT
pragma solidity ^0.8.9;


interface ISuperglyphsRenderer {

    struct Configuration {
        uint256 seed;
        uint256 mod;
        int256 z1;
        int256 z2;
        bool randStroke;
        bool fullSymmetry;
        bool darkTheme;
        bytes9[2] colors;
        bytes16 symbols;
    }

    function start(
        uint256 seed,
        uint256 colorSeed,
        bytes16 selectedColors,
        bytes16 selectedSymbols
    )
        external
        pure
        returns (Randomize.Random memory random, Configuration memory config);


    function render(
        string memory name,
        uint256 tokenId,
        uint256 colorSeed,
        bytes16 selectedColors,
        bytes16 selectedSymbols,
        bool frozen
    ) external view returns (string memory);

}// MIT
pragma solidity ^0.8.0;

library DynamicBuffer {

    function allocate(uint256 capacity)
        internal
        pure
        returns (bytes memory container, bytes memory buffer)
    {

        assembly {
            container := mload(0x40)

            {
                let size := add(capacity, 0x40)
                let newNextFree := add(container, size)
                mstore(0x40, newNextFree)
            }

            {
                let length := add(capacity, 0x40)
                mstore(container, length)
            }

            buffer := add(container, 0x20)

            mstore(buffer, 0)
        }

        return (container, buffer);
    }

    function appendBytes(bytes memory buffer_, bytes memory data_)
        internal
        pure
    {

        assembly {
            let length := mload(data_)
            for {
                let data := add(data_, 32)
                let dataEnd := add(data, length)
                let buf := add(buffer_, add(mload(buffer_), 32))
            } lt(data, dataEnd) {
                data := add(data, 32)
                buf := add(buf, 32)
            } {
                mstore(buf, mload(data))
            }

            mstore(buffer_, add(mload(buffer_), length))
        }
    }
}pragma solidity ^0.8.0;


library Base64 {

    string internal constant TABLE =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';

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
}//MIT
pragma solidity ^0.8.9;




interface ISuperglyphs {

    function getSymbol(uint256 symbolId, Randomize.Random memory random)
        external
        view
        returns (bytes memory);

}

contract SuperglyphsRenderer is ISuperglyphsRenderer {

    using Strings for uint256;
    using Randomize for Randomize.Random;

    int256 public constant HALF = 24;
    uint256 public constant CELL_SIZE = 44;
    uint256 public constant SEED_BOUND = 0xfffffff;

    constructor() {}

    function start(
        uint256 seed,
        uint256 colorSeed,
        bytes16 selectedColors,
        bytes16 selectedSymbols
    )
        public
        pure
        returns (Randomize.Random memory random, Configuration memory config)
    {

        random = Randomize.Random({seed: seed});

        config = _getConfiguration(
            random,
            seed,
            colorSeed,
            selectedColors,
            selectedSymbols
        );
    }

    function render(
        string memory name,
        uint256 tokenId,
        uint256 colorSeed,
        bytes16 selectedColors,
        bytes16 selectedSymbols,
        bool frozen
    ) external view returns (string memory) {

        (Randomize.Random memory random, Configuration memory config) = start(
            tokenId,
            colorSeed,
            selectedColors,
            selectedSymbols
        );

        (, bytes memory buffer) = DynamicBuffer.allocate(100000);

        DynamicBuffer.appendBytes(
            buffer,
            "%3Csvg xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink' viewBox='0 0 2464 2464' width='2464' height='2464'%3E%3Cdefs%3E"
        );

        _addGradient(buffer, config, random);
        _addSymbols(buffer, config);
        _fill(buffer, config, random);

        {
            bool yMirror = random.next(0, 10) < 8;
            DynamicBuffer.appendBytes(
                buffer,
                abi.encodePacked(
                    "%3Cmask id='mask' stroke-width='",
                    (config.randStroke ? random.next(4, 8).toString() : '4'),
                    "'%3E",
                    "%3Cuse href='%23left'/%3E%3Cuse href='%23left' transform='translate(-352, ",
                    yMirror ? '-352' : '0',
                    ') scale(-1, ',
                    yMirror ? '-1' : '1',
                    ")' transform-origin='50%25 50%25'/%3E",
                    '%3C/mask%3E',
                    '%3C/defs%3E'
                )
            );
        }

        DynamicBuffer.appendBytes(
            buffer,
            abi.encodePacked(
                "%3Crect width='100%25' height='100%25' fill='",
                (config.darkTheme ? '%23000' : '%23fff'),
                "'/%3E",
                "%3Cg transform='translate(176, 176)'%3E%3Crect width='2112' height='2112' fill='url(%23gr)' mask='url(%23mask)'/%3E%3C/g%3E",
                '%3C/svg%3E'
            )
        );

        string[6] memory data = [
            tokenId.toString(),
            config.mod.toString(),
            (tokenId % SEED_BOUND).toString(),
            string(
                abi.encodePacked(
                    '[{"trait_type":"Customizable","value":"',
                    ((frozen == false) ? 'Yes' : 'No'),
                    '"},{"trait_type":"Colors","value":"',
                    ((selectedColors == 0) ? 'Auto' : 'Custom'),
                    '"},{"trait_type":"Symbols","value":"',
                    ((selectedSymbols == 0) ? 'Auto' : 'Custom'),
                    '"},{"trait_type":"Last refresh","value":"',
                    _getDateTime(),
                    '"}]'
                )
            ),
            string(_getDescription(frozen, tokenId)),
            name
        ];

        return
            string(
                abi.encodePacked(
                    'data:application/json;base64,',
                    Base64.encode(
                        abi.encodePacked(
                            '{"image":"data:image/svg+xml;utf8,',
                            buffer,
                            '","seed":"',
                            data[0],
                            '","mod":"',
                            data[1],
                            '","base":"',
                            data[2],
                            '","attributes":',
                            data[3],
                            ',"license":"Full ownership with unlimited commercial rights.","creator":"dievardump"'
                            ',"description":',
                            data[4],
                            ',"name":"',
                            data[5],
                            '"}'
                        )
                    )
                )
            );
    }

    function _getDescription(bool frozen, uint256 tokenId)
        internal
        pure
        returns (bytes memory)
    {

        return
            abi.encodePacked(
                '"Superglyphs.sol\\n\\n',
                (
                    frozen
                        ? 'This Superglyph has been frozen and can not be customized anymore.'
                        : string(
                            abi.encodePacked(
                                'Name, Symbols and Colors customizable at [https://solSeedlings.art](https://solSeedlings.art/superglyphs/',
                                tokenId.toString(),
                                '). Non-customized tokens will change colors when they change owner.'
                            )
                        )
                ),
                '\\n\\nSuperglyphs.sol is the third of the [sol]Seedlings, an experiment of art and collectible NFTs 100% generated with Solidity.\\n\\nLicense: Full ownership with unlimited commercial rights.\\n\\nMore info at [https://solSeedlings.art](https://solSeedlings.art)\\n\\nby @dievardump with <3"'
            );
    }

    function _getConfiguration(
        Randomize.Random memory random,
        uint256 seed,
        uint256 colorSeed,
        bytes16 selectedColors,
        bytes16 selectedSymbols
    ) internal pure returns (Configuration memory config) {

        config.seed = seed;
        config.mod = random.next(5, 16);

        config.z1 = int256(random.next(2, 500));

        config.z2 = random.next(0, 10) < 3
            ? int256(random.next(501, 1000))
            : config.z1;

        config.randStroke = random.next(0, 10) < 1;

        config.darkTheme = random.next(0, 10) < 5;


        if (selectedColors != 0) {
            config.colors = [
                bytes9(
                    abi.encodePacked(
                        '%23',
                        selectedColors[1],
                        selectedColors[2],
                        selectedColors[3],
                        selectedColors[4],
                        selectedColors[5],
                        selectedColors[6]
                    )
                ),
                bytes9(
                    abi.encodePacked(
                        '%23',
                        selectedColors[8],
                        selectedColors[9],
                        selectedColors[10],
                        selectedColors[11],
                        selectedColors[12],
                        selectedColors[13]
                    )
                )
            ];
        } else {
            config.colors = _getColors(colorSeed, config.darkTheme);
        }

        if (selectedSymbols == 0) {
            selectedSymbols = [
                bytes16(0x01020000000000000000000000000000), // vertical, horizontal
                bytes16(0x01020304050000000000000000000000), // vert, hor, diag1, diag2, cross
                bytes16(0x01020600000000000000000000000000), // vert, hor, circle
                bytes16(0x0C0D0700000000000000000000000000), // rounded 512Print 1, rounded 2, circle with dot
                bytes16(0x03040000000000000000000000000000), // diag 1, diag 2
                bytes16(0x1A0A0900000000000000000000000000), // circle with dot, square with square, square with cross
                bytes16(0x03040500000000000000000000000000), // diagonal 1, diagonal 2, cross
                bytes16(0x06050800000000000000000000000000), // cross, circle, square
                bytes16(0x01020B00000000000000000000000000), // plus, horizontal, vertical
                bytes16(0x01020B0C0D0000000000000000000000), // vert, hor, plus, rounded 512Print 1, rounded 2
                bytes16(0x0E0F1011000000000000000000000000), // sides
                bytes16(0x12131415000000000000000000000000), // triangles
                bytes16(0x1C1D1E00000000000000000000000000), // vert hor plus animated
                bytes16(0x1F1F1F00000000000000000000000000), // random squares
                bytes16(0x1B1B1B00000000000000000000000000), // animated squares
                bytes16(0x20030421000000000000000000000000), // longer (diagonals, verticals, horizontals)
                bytes16(0x22002200220000000000000000000000), // growing lines
                bytes16(0x23241A0A090000000000000000000000), // stroked square, stroked circle, circle with dot, square with square, square with cross
                bytes16(0x25002600270000000000000000000000), // 3 circles, barred circle, double triangle
                bytes16(0x28002800280000000000000000000000) // hashtags
            ][seed % 20];


            Randomize.Random memory random2 = Randomize.Random({
                seed: uint256(keccak256(abi.encode(seed)))
            });

            uint256 temp = config.mod;
            uint256[] memory available = new uint256[](config.mod);
            for (uint256 i; i < temp; i++) {
                available[i] = i;
            }

            bytes memory selected = new bytes(config.mod);
            for (uint256 i; i < selected.length; i++) {
                if (selectedSymbols[i] != 0) {
                    uint256 index = random2.next(0, temp);
                    selected[available[index]] = selectedSymbols[i];

                    available[index] = available[temp - 1];

                    temp--;
                }
            }

            config.symbols = bytes16(selected);
        } else {
            config.symbols = selectedSymbols;
        }
    }

    function _fill(
        bytes memory buffer,
        Configuration memory config,
        Randomize.Random memory random
    ) internal pure {

        uint256 v;
        int256 y;
        int256 y2;
        int256 x;
        int256 base = int256(config.seed % SEED_BOUND);

        bool rot = random.next(0, 3) < 2;
        bool invert = random.next(0, 2) == 0;
        bool translate = random.next(0, 2) == 0;

        DynamicBuffer.appendBytes(buffer, "%3Cg id='left'%3E");

        for (int256 i; i < HALF; i++) {
            if (translate) {
                y = (config.z1 * (i - HALF) + 1) * base;
                y2 = (config.z2 * (i + 1) - 1) * base;
            } else {
                y = (config.z1 * (i + 1)) * base;
                y2 = (config.z2 * (HALF - i)) * base;
            }

            if (invert) {
                (y, y2) = (y2, y);
            }

            for (int256 j; j < HALF; j++) {
                x = ((config.z1 * config.z2) * (j + 1)) * base;

                v = ((uint256(x * y)) / SEED_BOUND) % config.mod;

                bytes memory stroke = (
                    config.randStroke
                        ? abi.encodePacked(
                            "stroke-width='",
                            random.next(4, 8).toString(),
                            "'"
                        )
                        : bytes('')
                );

                if (config.symbols[v] != 0) {
                    DynamicBuffer.appendBytes(
                        buffer,
                        abi.encodePacked(
                            "%3Cuse x='",
                            _getPosition(j, 0),
                            "' y='",
                            _getPosition(i, 0),
                            "' href='%23s-",
                            v.toString(),
                            "' ",
                            stroke,
                            '/%3E'
                        )
                    );
                }

                v = ((uint256(x * y2)) / SEED_BOUND) % config.mod;

                if (config.symbols[v] != 0) {
                    DynamicBuffer.appendBytes(
                        buffer,
                        abi.encodePacked(
                            "%3Cuse x='",
                            _getPosition(j, 0),
                            "' y='",
                            _getPosition(i + HALF, 0),
                            "' href='%23s-",
                            v.toString(),
                            "' ",
                            (
                                !rot
                                    ? bytes('')
                                    : abi.encodePacked(
                                        "transform='rotate(180 ",
                                        _getPosition(j, 22),
                                        ' ',
                                        _getPosition(i + HALF, 22),
                                        ")'"
                                    )
                            ),
                            ' ',
                            stroke,
                            '/%3E'
                        )
                    );
                }
            }
        }

        DynamicBuffer.appendBytes(buffer, '%3C/g%3E');
    }

    function _getPosition(int256 index, uint256 offset)
        internal
        pure
        returns (string memory)
    {

        return (uint256(index) * CELL_SIZE + offset).toString();
    }

    function _addSymbols(bytes memory buffer, Configuration memory config)
        internal
        view
    {

        Randomize.Random memory random = Randomize.Random({
            seed: uint256(keccak256(abi.encode(config.seed)))
        });

        uint256 b;
        for (uint256 i; i < config.symbols.length; i++) {
            b = uint256(uint8(config.symbols[i]));
            if (b == 0) {
                continue;
            } else if (b == 1) {
                DynamicBuffer.appendBytes(
                    buffer,
                    abi.encodePacked(
                        "%3Cpath id='s-",
                        i.toString(),
                        "' d='M0,22L44,22' stroke='%23fff'/%3E"
                    )
                );
            } else if (b == 2) {
                DynamicBuffer.appendBytes(
                    buffer,
                    abi.encodePacked(
                        "%3Cpath id='s-",
                        i.toString(),
                        "' d='M22,0L22,44' stroke='%23fff'/%3E"
                    )
                );
            } else if (b == 3) {
                DynamicBuffer.appendBytes(
                    buffer,
                    abi.encodePacked(
                        "%3Cpath id='s-",
                        i.toString(),
                        "' d='M0,0L44,44' stroke='%23fff'/%3E"
                    )
                );
            } else if (b == 4) {
                DynamicBuffer.appendBytes(
                    buffer,
                    abi.encodePacked(
                        "%3Cpath id='s-",
                        i.toString(),
                        "' d='M44,0L0,44' stroke='%23fff'/%3E"
                    )
                );
            } else if (b == 5) {
                DynamicBuffer.appendBytes(
                    buffer,
                    abi.encodePacked(
                        "%3Cpath id='s-",
                        i.toString(),
                        "' d='M0,0L44,44M0,44L44,0' stroke='%23fff'/%3E"
                    )
                );
            } else if (b == 6) {
                DynamicBuffer.appendBytes(
                    buffer,
                    abi.encodePacked(
                        "%3Ccircle id='s-",
                        i.toString(),
                        "' cx='22' cy='22' r='22' fill='%23fff'/%3E"
                    )
                );
            } else if (b == 7) {
                DynamicBuffer.appendBytes(
                    buffer,
                    abi.encodePacked(
                        "%3Cg id='s-",
                        i.toString(),
                        "'%3E%3Ccircle cx='22' cy='22' r='18' fill='none' stroke='%23fff'/%3E%3Ccircle cx='22' cy='22' r='4' fill='%23fff'/%3E%3C/g%3E"
                    )
                );
            } else if (b == 8) {
                DynamicBuffer.appendBytes(
                    buffer,
                    abi.encodePacked(
                        "%3Crect id='s-",
                        i.toString(),
                        "' x='7' y='7' width='30' height='30' fill='%23fff'/%3E"
                    )
                );
            } else if (b == 9) {
                DynamicBuffer.appendBytes(
                    buffer,
                    abi.encodePacked(
                        "%3Cg id='s-",
                        i.toString(),
                        "'%3E%3Crect x='2' y='2' width='40' height='40' fill='%23fff'%3E%3C/rect%3E%3Cpath d='M18,18L26,26M18,26L26,18' stroke='%23000' stroke-width='4' stroke-linecap='round'/%3E%3C/g%3E"
                    )
                );
            } else if (b == 10) {
                DynamicBuffer.appendBytes(
                    buffer,
                    abi.encodePacked(
                        "%3Cg id='s-",
                        i.toString(),
                        "'%3E%3Crect x='2' y='2' width='40' height='40' fill='%23fff'/%3E%3Crect fill='%23000' x='18' y='18' width='8' height='8'/%3E%3C/g%3E"
                    )
                );
            } else if (b == 11) {
                DynamicBuffer.appendBytes(
                    buffer,
                    abi.encodePacked(
                        "%3Cg id='s-",
                        i.toString(),
                        "'%3E%3Cpath d='M0,22L44,22M22,0L22,44' stroke='%23fff'/%3E%3C/g%3E"
                    )
                );
            } else if (b == 12) {
                DynamicBuffer.appendBytes(
                    buffer,
                    abi.encodePacked(
                        "%3Cpath id='s-",
                        i.toString(),
                        "' d='M22 0a22 22 0 0 1 -22 22m44 0a22 22 0 0 0 -22 22' stroke='%23fff' stroke-linecap='round'/%3E"
                    )
                );
            } else if (b == 13) {
                DynamicBuffer.appendBytes(
                    buffer,
                    abi.encodePacked(
                        "%3Cpath id='s-",
                        i.toString(),
                        "' d='M22 0a22 22 0 0 0 22 22m-44 0a22 22 0 0 1 22 22' stroke='%23fff' stroke-linecap='round'/%3E"
                    )
                );
            } else if (b == 14) {
                DynamicBuffer.appendBytes(
                    buffer,
                    abi.encodePacked(
                        "%3Cpath id='s-",
                        i.toString(),
                        "' d='M0 0L44 0L44 44' stroke='%23fff'/%3E"
                    )
                );
            } else if (b == 15) {
                DynamicBuffer.appendBytes(
                    buffer,
                    abi.encodePacked(
                        "%3Cpath id='s-",
                        i.toString(),
                        "' d='M44 0L44 44L0 44' stroke='%23fff'/%3E"
                    )
                );
            } else if (b == 16) {
                DynamicBuffer.appendBytes(
                    buffer,
                    abi.encodePacked(
                        "%3Cpath id='s-",
                        i.toString(),
                        "' d='M44 44L0 44L0 0' stroke='%23fff'/%3E"
                    )
                );
            } else if (b == 17) {
                DynamicBuffer.appendBytes(
                    buffer,
                    abi.encodePacked(
                        "%3Cpath id='s-",
                        i.toString(),
                        "' d='M0 44L0 0L44 0' stroke='%23fff'/%3E"
                    )
                );
            } else if (b == 18) {
                DynamicBuffer.appendBytes(
                    buffer,
                    abi.encodePacked(
                        "%3Cpath id='s-",
                        i.toString(),
                        "' d='M0 0L44 0L44 44Z' ",
                        (
                            random.next(0, 100) < 50
                                ? "fill='none' stroke='%23fff'"
                                : "fill='%23fff'"
                        ),
                        '/%3E'
                    )
                );
            } else if (b == 19) {
                DynamicBuffer.appendBytes(
                    buffer,
                    abi.encodePacked(
                        "%3Cpath id='s-",
                        i.toString(),
                        "' d='M44 0L44 44L0 44Z' ",
                        (
                            random.next(0, 100) < 50
                                ? "fill='none' stroke='%23fff'"
                                : "fill='%23fff'"
                        ),
                        '/%3E'
                    )
                );
            } else if (b == 20) {
                DynamicBuffer.appendBytes(
                    buffer,
                    abi.encodePacked(
                        "%3Cpath id='s-",
                        i.toString(),
                        "' d='M44 44L0 44L0 0Z' ",
                        (
                            random.next(0, 100) < 50
                                ? "fill='none' stroke='%23fff'"
                                : "fill='%23fff'"
                        ),
                        '/%3E'
                    )
                );
            } else if (b == 21) {
                DynamicBuffer.appendBytes(
                    buffer,
                    abi.encodePacked(
                        "%3Cpath id='s-",
                        i.toString(),
                        "' d='M0 44L0 0L44 0Z' ",
                        (
                            random.next(0, 100) < 50
                                ? "fill='none' stroke='%23fff'"
                                : "fill='%23fff'"
                        ),
                        '/%3E'
                    )
                );
            } else if (b == 22) {
                DynamicBuffer.appendBytes(
                    buffer,
                    abi.encodePacked(
                        "%3Cpath d='M0 0 h44 a44,44 0 0 1 -44,44z' id='s-",
                        i.toString(),
                        "' fill='%23fff'/%3E"
                    )
                );
            } else if (b == 23) {
                DynamicBuffer.appendBytes(
                    buffer,
                    abi.encodePacked(
                        "%3Cpath d='M44 0 v44 a44,44 0 0 1 -44,-44z' id='s-",
                        i.toString(),
                        "' fill='%23fff'/%3E"
                    )
                );
            } else if (b == 24) {
                DynamicBuffer.appendBytes(
                    buffer,
                    abi.encodePacked(
                        "%3Cpath d='M44 44 h-44 a44,44 0 0 1 44,-44z' id='s-",
                        i.toString(),
                        "' fill='%23fff'/%3E"
                    )
                );
            } else if (b == 25) {
                DynamicBuffer.appendBytes(
                    buffer,
                    abi.encodePacked(
                        "%3Cpath d='M0 44 v-44 a44,44 0 0 1 44,44z' id='s-",
                        i.toString(),
                        "' fill='%23fff'/%3E"
                    )
                );
            } else if (b == 26) {
                DynamicBuffer.appendBytes(
                    buffer,
                    abi.encodePacked(
                        "%3Cg id='s-",
                        i.toString(),
                        "'%3E%3Ccircle cx='22' cy='22' r='20' fill='%23fff'/%3E%3Ccircle cx='22' cy='22' r='4' fill='%23000'/%3E%3C/g%3E"
                    )
                );
            } else if (b == 27) {
                DynamicBuffer.appendBytes(
                    buffer,
                    abi.encodePacked(
                        "%3Crect id='s-",
                        i.toString(),
                        "' x='7' y='7' width='30' height='30' fill='%23fff' transform='scale(1)' transform-origin='22 22' ",
                        "%3E%3CanimateTransform attributeName='transform' type='scale' values='1;0;1' dur='8s' fill='freeze' repeatCount='indefinite' begin='",
                        random.next(0, 5000).toString(),
                        "ms'/%3E%3C/rect%3E"
                    )
                );
            } else if (b == 28) {
                DynamicBuffer.appendBytes(
                    buffer,
                    abi.encodePacked(
                        "%3Cpath id='s-",
                        i.toString(),
                        "' d='M0,22L44,22' stroke='%23fff' transform='scale(1)' transform-origin='22 22' ",
                        "%3E%3CanimateTransform attributeName='transform' type='scale' values='1;0;1' dur='8s' fill='freeze' repeatCount='indefinite' begin='",
                        random.next(0, 5000).toString(),
                        "ms'/%3E%3C/path%3E"
                    )
                );
            } else if (b == 29) {
                DynamicBuffer.appendBytes(
                    buffer,
                    abi.encodePacked(
                        "%3Cpath id='s-",
                        i.toString(),
                        "' d='M22,0L22,44' stroke='%23fff' transform='scale(1)' transform-origin='22 22' ",
                        "%3E%3CanimateTransform attributeName='transform' type='scale' values='1;0;1' dur='8s' fill='freeze' repeatCount='indefinite' begin='",
                        random.next(0, 5000).toString(),
                        "ms'/%3E%3C/path%3E"
                    )
                );
            } else if (b == 30) {
                DynamicBuffer.appendBytes(
                    buffer,
                    abi.encodePacked(
                        "%3Cpath id='s-",
                        i.toString(),
                        "' d='M0,22L44,22M22,0L22,44' stroke='%23fff' transform='scale(1)' transform-origin='22 22' ",
                        "%3E%3CanimateTransform attributeName='transform' type='scale' values='1;0;1' dur='8s' fill='freeze' repeatCount='indefinite' begin='",
                        random.next(0, 5000).toString(),
                        "ms'/%3E%3C/path%3E"
                    )
                );
            } else if (b == 31) {
                uint256 size = random.next(30, 44);
                if (size % 2 != 0) {
                    size++;
                }

                uint256 offset = (44 - size) / 2;
                DynamicBuffer.appendBytes(
                    buffer,
                    abi.encodePacked(
                        "%3Crect id='s-",
                        i.toString(),
                        "' x='",
                        offset.toString(),
                        "' y='",
                        offset.toString(),
                        "' width='",
                        size.toString(),
                        "' height='",
                        size.toString(),
                        "' fill='%23fff' transform='scale(1)' transform-origin='22 22' ",
                        '%3E%3C/rect%3E'
                    )
                );
            } else if (b == 32) {
                DynamicBuffer.appendBytes(
                    buffer,
                    abi.encodePacked(
                        "%3Cpath id='s-",
                        i.toString(),
                        "' d='M0,0L44,44' stroke='%23fff' transform='rotate(45 22 22)'/%3E"
                    )
                );
            } else if (b == 33) {
                DynamicBuffer.appendBytes(
                    buffer,
                    abi.encodePacked(
                        "%3Cpath id='s-",
                        i.toString(),
                        "' d='M0,0L44,44' stroke='%23fff' transform='rotate(-45 22 22)'/%3E"
                    )
                );
            } else if (b == 34) {
                uint256 length = 44 * random.next(1, 10);
                string memory delay = random.next(500, 4000).toString();

                DynamicBuffer.appendBytes(
                    buffer,
                    abi.encodePacked(
                        "%3Cline id='s-",
                        i.toString(),
                        "' x1='0' y1='0' x2='",
                        (length.toString()),
                        "' y2='0' stroke='%23fff' stroke-dasharray='",
                        length.toString(),
                        "' stroke-dashoffset='",
                        (length - 1).toString(),
                        "' stroke-linecap='round' transform='rotate(",
                        (random.next(0, 4) * 90).toString(),
                        " 22 22)' stroke-width='22'%3E%3Canimate attributeName='stroke-dashoffset' "
                    )
                );
                DynamicBuffer.appendBytes(
                    buffer,
                    abi.encodePacked(
                        " values='",
                        (length - 1).toString(),
                        ';0;',
                        (length - 1).toString(),
                        "' dur='",
                        random.next(4000, 15000).toString(),
                        "ms' repeatCount='indefinite' begin='",
                        delay,
                        'ms;op.end+',
                        delay,
                        "ms'/%3E%3C/line%3E"
                    )
                );
            } else if (b == 35) {
                DynamicBuffer.appendBytes(
                    buffer,
                    abi.encodePacked(
                        "%3Crect id='s-",
                        i.toString(),
                        "' x='7' y='7' width='30' height='30' fill='none' stroke='%23fff'/%3E"
                    )
                );
            } else if (b == 36) {
                DynamicBuffer.appendBytes(
                    buffer,
                    abi.encodePacked(
                        "%3Ccircle id='s-",
                        i.toString(),
                        "' cx='22' cy='22' r='22' fill='none' stroke='%23fff'/%3E"
                    )
                );
            } else if (b == 37) {
                DynamicBuffer.appendBytes(
                    buffer,
                    abi.encodePacked(
                        "%3Cg id='s-",
                        i.toString(),
                        "'%3E%3Ccircle cx='22' cy='22' r='20' fill='none' stroke='%23fff'/%3E%3Ccircle cx='22' cy='22' r='11' fill='none' stroke='%23fff'/%3E%3Ccircle cx='22' cy='22' r='4' fill='%23fff'/%3E%3C/g%3E"
                    )
                );
            } else if (b == 38) {
                DynamicBuffer.appendBytes(
                    buffer,
                    abi.encodePacked(
                        "%3Cg transform='rotate(-45 22 22)' id='s-",
                        i.toString(),
                        "'%3E%3Ccircle cx='22' cy='22' r='20' fill='none' stroke='%23fff'/%3E%3Cpath d='M22 0L22 44' stroke='%23fff'/%3E%3Ccircle cx='22' cy='22' r='6' fill='%23fff'/%3E%3C/g%3E"
                    )
                );
            } else if (b == 39) {
                DynamicBuffer.appendBytes(
                    buffer,
                    abi.encodePacked(
                        "%3Cpath id='s-",
                        i.toString(),
                        "' d='M4 4L40 4L22 40Z M22 4L40 40L4 40Z' stroke='%23fff'/%3E"
                    )
                );
            } else if (b == 40) {
                DynamicBuffer.appendBytes(
                    buffer,
                    abi.encodePacked(
                        "%3Cpath id='s-",
                        i.toString(),
                        "' d='M14 6L14 38M30 6L30 38M6 14L38 14M6 30L38 30' stroke='%23fff'/%3E"
                    )
                );
            } else {
                DynamicBuffer.appendBytes(
                    buffer,
                    ISuperglyphs(msg.sender).getSymbol(b, random)
                );
            }
        }
    }

    function _addGradient(
        bytes memory buffer,
        Configuration memory config,
        Randomize.Random memory random
    ) internal pure {

        if (random.next(0, 10) < 5) {
            uint256 x1;
            uint256 y1;
            uint256 x2;
            uint256 y2;
            if (random.next(0, 10) < 5) {
                x1 = 0;
                x2 = 100;
                y1 = random.next(0, 100);
                y2 = 100 - y1;
            } else {
                y1 = 0;
                y2 = 100;
                x1 = random.next(0, 100);
                x2 = 100 - x1;
            }
            if (random.next(0, 10) < 5) {
                DynamicBuffer.appendBytes(
                    buffer,
                    abi.encodePacked(
                        "%3ClinearGradient id='gr' x1='",
                        x1.toString(),
                        "%25' y1='",
                        y1.toString(),
                        "%25' x2='",
                        x2.toString(),
                        "%25' y2='"
                    )
                );
                DynamicBuffer.appendBytes(
                    buffer,
                    abi.encodePacked(
                        y2.toString(),
                        "%25'%3E",
                        "%3Cstop offset='0%25' stop-color='",
                        config.colors[0],
                        "'/%3E",
                        "%3Cstop offset='100%25' stop-color='",
                        config.colors[1],
                        "'/%3E",
                        '%3C/linearGradient%3E'
                    )
                );
            } else {
                string memory animation = random.next(10000, 20000).toString();
                DynamicBuffer.appendBytes(
                    buffer,
                    abi.encodePacked(
                        "%3ClinearGradient id='gr' x1='",
                        x1.toString(),
                        "%25' y1='",
                        y1.toString(),
                        "%25' x2='",
                        x2.toString(),
                        "%25' y2='"
                    )
                );
                DynamicBuffer.appendBytes(
                    buffer,
                    abi.encodePacked(
                        y2.toString(),
                        "%25'%3E%3Cstop offset='0%25' stop-color='",
                        config.colors[0],
                        "'%3E",
                        "%3Canimate attributeName='stop-color' dur='",
                        animation,
                        "ms' values='",
                        config.colors[0],
                        ';',
                        config.colors[1],
                        ';',
                        config.colors[0]
                    )
                );

                DynamicBuffer.appendBytes(
                    buffer,
                    abi.encodePacked(
                        "' repeatCount='indefinite'/%3E%3C/stop%3E%3Cstop offset='100%25' stop-color='",
                        config.colors[1],
                        "'%3E%3Canimate attributeName='stop-color' dur='",
                        animation,
                        "ms' values='",
                        config.colors[1],
                        ';',
                        config.colors[0],
                        ';',
                        config.colors[1],
                        "' repeatCount='indefinite'/%3E%3C/stop%3E%3C/linearGradient%3E"
                    )
                );
            }
        } else {
            if (random.next(0, 10) < 5) {
                DynamicBuffer.appendBytes(
                    buffer,
                    abi.encodePacked(
                        "%3CradialGradient id='gr' cx='",
                        (random.next(1, 4) * 25).toString(),
                        "%25' cy='",
                        (random.next(1, 4) * 25).toString(),
                        "%25'%3E%3Cstop offset='0%25' stop-color='",
                        config.colors[0],
                        "'/%3E%3Cstop offset='100%25' stop-color='",
                        config.colors[1],
                        "'/%3E%3C/radialGradient%3E"
                    )
                );
            } else {
                string memory animation = random.next(10000, 20000).toString();
                DynamicBuffer.appendBytes(
                    buffer,
                    abi.encodePacked(
                        "%3CradialGradient id='gr' cx='",
                        (random.next(1, 4) * 25).toString(),
                        "%25' cy='",
                        (random.next(1, 4) * 25).toString(),
                        "%25'%3E%3Cstop offset='0%25' stop-color='",
                        config.colors[0],
                        "' %3E%3Canimate attributeName='stop-color' dur='",
                        animation,
                        "ms' values='",
                        config.colors[0],
                        ';',
                        config.colors[1],
                        ';',
                        config.colors[0]
                    )
                );

                DynamicBuffer.appendBytes(
                    buffer,
                    abi.encodePacked(
                        "' repeatCount='indefinite'/%3E%3C/stop%3E%3Cstop offset='100%25' stop-color='",
                        config.colors[1],
                        "'%3E%3Canimate attributeName='stop-color' dur='",
                        animation,
                        "ms' values='",
                        config.colors[1],
                        ';',
                        config.colors[0],
                        ';',
                        config.colors[1],
                        "' repeatCount='indefinite'/%3E%3C/stop%3E%3C/radialGradient%3E"
                    )
                );
            }
        }
    }

    function _getColors(uint256 colorSeed, bool darkTheme)
        public
        pure
        returns (bytes9[2] memory)
    {

        string[14] memory colors;
        if (!darkTheme) {
            colors = [
                '%236a2c70',
                '%233f72af',
                '%23b83b5e',
                '%23112d4e',
                '%23a82ffc',
                '%23212121',
                '%23004a7c',
                '%233a0088',
                '%23364f6b',
                '%2353354a',
                '%23903749',
                '%232b2e4a',
                '%236639a6',
                '%23000000'
            ];
        } else {
            colors = [
                '%233fc1c9',
                '%23ffd3b5',
                '%23f9f7f7',
                '%23d6c8ff',
                '%2300bbf0',
                '%23ffde7d',
                '%23f6416c',
                '%23ff99fe',
                '%231891ac',
                '%23f8f3d4',
                '%2300b8a9',
                '%23f9ffea',
                '%23ff2e63',
                '%23ffffff'
            ];
        }

        uint256 length = colors.length;
        uint256 index1 = colorSeed % length;
        uint256 index2 = (index1 +
            1 +
            (uint256(keccak256(abi.encode(colorSeed))) % (length - 1))) %
            length;

        return [bytes9(bytes(colors[index1])), bytes9(bytes(colors[index2]))];
    }

    function _getDateTime() internal view returns (string memory) {

        uint256 chainId = block.chainid;

        address bokky;
        if (chainId == 1) {
            bokky = address(0x23d23d8F243e57d0b924bff3A3191078Af325101);
        } else if (chainId == 4) {
            bokky = address(0x047C6386C30E785F7a8fd536945410802a605395);
        }

        if (address(0) != bokky) {
            (
                uint256 year,
                uint256 month,
                uint256 day,
                uint256 hour,
                uint256 minute,
                uint256 second
            ) = IBokkyPooBahsDateTimeContract(bokky).timestampToDateTime(
                    block.timestamp
                );

            return
                string(
                    abi.encodePacked(
                        year.toString(),
                        '/',
                        month.toString(),
                        '/',
                        day.toString(),
                        ' ',
                        hour.toString(),
                        ':',
                        minute.toString(),
                        ':',
                        second.toString(),
                        ' UTC'
                    )
                );
        }

        return '';
    }
}

interface IBokkyPooBahsDateTimeContract {

    function timestampToDateTime(uint256 timestamp)
        external
        pure
        returns (
            uint256 year,
            uint256 month,
            uint256 day,
            uint256 hour,
            uint256 minute,
            uint256 second
        );

}