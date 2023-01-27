
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
}// GPL-3.0-only
pragma solidity >=0.5.0;

interface IPrimitiveEngineView {


    function invariantOf(bytes32 poolId) external view returns (int128 invariant);



    function PRECISION() external view returns (uint256);


    function BUFFER() external view returns (uint256);



    function MIN_LIQUIDITY() external view returns (uint256);


    function factory() external view returns (address);


    function risky() external view returns (address);


    function stable() external view returns (address);


    function scaleFactorRisky() external view returns (uint256);


    function scaleFactorStable() external view returns (uint256);



    function reserves(bytes32 poolId)
        external
        view
        returns (
            uint128 reserveRisky,
            uint128 reserveStable,
            uint128 liquidity,
            uint32 blockTimestamp,
            uint256 cumulativeRisky,
            uint256 cumulativeStable,
            uint256 cumulativeLiquidity
        );


    function calibrations(bytes32 poolId)
        external
        view
        returns (
            uint128 strike,
            uint32 sigma,
            uint32 maturity,
            uint32 lastTimestamp,
            uint32 gamma
        );


    function liquidity(address account, bytes32 poolId) external view returns (uint256 liquidity);


    function margins(address account) external view returns (uint128 balanceRisky, uint128 balanceStable);

}// MIT

pragma solidity >=0.6.0;

library Base64 {

    string internal constant TABLE_ENCODE = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';
    bytes  internal constant TABLE_DECODE = hex"0000000000000000000000000000000000000000000000000000000000000000"
                                            hex"00000000000000000000003e0000003f3435363738393a3b3c3d000000000000"
                                            hex"00000102030405060708090a0b0c0d0e0f101112131415161718190000000000"
                                            hex"001a1b1c1d1e1f202122232425262728292a2b2c2d2e2f303132330000000000";

    function encode(bytes memory data) internal pure returns (string memory) {

        if (data.length == 0) return '';

        string memory table = TABLE_ENCODE;

        uint256 encodedLen = 4 * ((data.length + 2) / 3);

        string memory result = new string(encodedLen + 32);

        assembly {
            mstore(result, encodedLen)

            let tablePtr := add(table, 1)

            let dataPtr := data
            let endPtr := add(dataPtr, mload(data))

            let resultPtr := add(result, 32)

            for {} lt(dataPtr, endPtr) {}
            {
                dataPtr := add(dataPtr, 3)
                let input := mload(dataPtr)

                mstore8(resultPtr, mload(add(tablePtr, and(shr(18, input), 0x3F))))
                resultPtr := add(resultPtr, 1)
                mstore8(resultPtr, mload(add(tablePtr, and(shr(12, input), 0x3F))))
                resultPtr := add(resultPtr, 1)
                mstore8(resultPtr, mload(add(tablePtr, and(shr( 6, input), 0x3F))))
                resultPtr := add(resultPtr, 1)
                mstore8(resultPtr, mload(add(tablePtr, and(        input,  0x3F))))
                resultPtr := add(resultPtr, 1)
            }

            switch mod(mload(data), 3)
            case 1 { mstore(sub(resultPtr, 2), shl(240, 0x3d3d)) }
            case 2 { mstore(sub(resultPtr, 1), shl(248, 0x3d)) }
        }

        return result;
    }

    function decode(string memory _data) internal pure returns (bytes memory) {

        bytes memory data = bytes(_data);

        if (data.length == 0) return new bytes(0);
        require(data.length % 4 == 0, "invalid base64 decoder input");

        bytes memory table = TABLE_DECODE;

        uint256 decodedLen = (data.length / 4) * 3;

        bytes memory result = new bytes(decodedLen + 32);

        assembly {
            let lastBytes := mload(add(data, mload(data)))
            if eq(and(lastBytes, 0xFF), 0x3d) {
                decodedLen := sub(decodedLen, 1)
                if eq(and(lastBytes, 0xFFFF), 0x3d3d) {
                    decodedLen := sub(decodedLen, 1)
                }
            }

            mstore(result, decodedLen)

            let tablePtr := add(table, 1)

            let dataPtr := data
            let endPtr := add(dataPtr, mload(data))

            let resultPtr := add(result, 32)

            for {} lt(dataPtr, endPtr) {}
            {
               dataPtr := add(dataPtr, 4)
               let input := mload(dataPtr)

               let output := add(
                   add(
                       shl(18, and(mload(add(tablePtr, and(shr(24, input), 0xFF))), 0xFF)),
                       shl(12, and(mload(add(tablePtr, and(shr(16, input), 0xFF))), 0xFF))),
                   add(
                       shl( 6, and(mload(add(tablePtr, and(shr( 8, input), 0xFF))), 0xFF)),
                               and(mload(add(tablePtr, and(        input , 0xFF))), 0xFF)
                    )
                )
                mstore(resultPtr, shl(232, output))
                resultPtr := add(resultPtr, 3)
            }
        }

        return result;
    }
}// GPL-3.0-only
pragma solidity >=0.8.6;

interface IPositionRenderer {

    function render(address engine, uint256 tokenId) external view returns (string memory);

}// GPL-3.0-only
pragma solidity >=0.8.6;

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
}// GPL-3.0-only
pragma solidity >=0.8.6;


interface IERC20WithMetadata is IERC20 {

    function symbol() external view returns (string memory);


    function name() external view returns (string memory);


    function decimals() external view returns (uint8);

}// GPL-3.0-only
pragma solidity >=0.8.6;

interface IPositionDescriptor {


    function positionRenderer() external view returns (address);


    function getMetadata(address engine, uint256 tokenId) external view returns (string memory);

}// GPL-3.0-only
pragma solidity 0.8.6;


contract PositionDescriptor is IPositionDescriptor {

    using Strings for uint256;


    address public override positionRenderer;


    constructor(address positionRenderer_) {
        positionRenderer = positionRenderer_;
    }


    function getMetadata(address engine, uint256 tokenId) external view override returns (string memory) {

        return
            string(
                abi.encodePacked(
                    "data:application/json;base64,",
                    Base64.encode(
                        bytes(
                            abi.encodePacked(
                                '{"name":"',
                                getName(IPrimitiveEngineView(engine)),
                                '","image":"',
                                IPositionRenderer(positionRenderer).render(engine, tokenId),
                                '","license":"MIT","creator":"primitive.eth",',
                                '"description":"Concentrated liquidity tokens of a two-token AMM",',
                                '"properties":{',
                                getProperties(IPrimitiveEngineView(engine), tokenId),
                                "}}"
                            )
                        )
                    )
                )
            );
    }

    function getName(IPrimitiveEngineView engine) private view returns (string memory) {
        address risky = engine.risky();
        address stable = engine.stable();

        return
            string(
                abi.encodePacked(
                    "Primitive RMM-01 LP ",
                    IERC20WithMetadata(risky).symbol(),
                    "-",
                    IERC20WithMetadata(stable).symbol()
                )
            );
    }

    function getProperties(IPrimitiveEngineView engine, uint256 tokenId) private view returns (string memory) {
        int128 invariant = engine.invariantOf(bytes32(tokenId));

        return
            string(
                abi.encodePacked(
                    '"factory":"',
                    uint256(uint160(engine.factory())).toHexString(),
                    '",',
                    getTokenMetadata(engine.risky(), true),
                    ",",
                    getTokenMetadata(engine.stable(), false),
                    ',"invariant":"',
                    invariant < 0 ? "-" : "",
                    uint256((uint128(invariant < 0 ? ~invariant + 1 : invariant))).toString(),
                    '",',
                    getCalibration(engine, tokenId),
                    ",",
                    getReserve(engine, tokenId),
                    ',"chainId":',
                    block.chainid.toString(),
                    ''
                )
            );
    }

    function getTokenMetadata(address token, bool isRisky) private view returns (string memory) {
        string memory prefix = isRisky ? "risky" : "stable";
        string memory metadata;

        {
            metadata = string(
                abi.encodePacked(
                    '"',
                    prefix,
                    'Name":"',
                    IERC20WithMetadata(token).name(),
                    '","',
                    prefix,
                    'Symbol":"',
                    IERC20WithMetadata(token).symbol(),
                    '","',
                    prefix,
                    'Decimals":"',
                    uint256(IERC20WithMetadata(token).decimals()).toString(),
                    '"'
                )
            );
        }

        return
            string(abi.encodePacked(metadata, ',"', prefix, 'Address":"', uint256(uint160(token)).toHexString(), '"'));
    }

    function getCalibration(IPrimitiveEngineView engine, uint256 tokenId) private view returns (string memory) {
        (uint128 strike, uint64 sigma, uint32 maturity, uint32 lastTimestamp, uint32 gamma) = engine.calibrations(
            bytes32(tokenId)
        );

        return
            string(
                abi.encodePacked(
                    '"strike":"',
                    uint256(strike).toString(),
                    '","sigma":"',
                    uint256(sigma).toString(),
                    '","maturity":"',
                    uint256(maturity).toString(),
                    '","lastTimestamp":"',
                    uint256(lastTimestamp).toString(),
                    '","gamma":"',
                    uint256(gamma).toString(),
                    '"'
                )
            );
    }

    function getReserve(IPrimitiveEngineView engine, uint256 tokenId) private view returns (string memory) {
        (
            uint128 reserveRisky,
            uint128 reserveStable,
            uint128 liquidity,
            uint32 blockTimestamp,
            uint256 cumulativeRisky,
            uint256 cumulativeStable,
            uint256 cumulativeLiquidity
        ) = engine.reserves(bytes32(tokenId));

        return
            string(
                abi.encodePacked(
                    '"reserveRisky":"',
                    uint256(reserveRisky).toString(),
                    '","reserveStable":"',
                    uint256(reserveStable).toString(),
                    '","liquidity":"',
                    uint256(liquidity).toString(),
                    '","blockTimestamp":"',
                    uint256(blockTimestamp).toString(),
                    '","cumulativeRisky":"',
                    uint256(cumulativeRisky).toString(),
                    '","cumulativeStable":"',
                    uint256(cumulativeStable).toString(),
                    '","cumulativeLiquidity":"',
                    uint256(cumulativeLiquidity).toString(),
                    '"'
                )
            );
    }
}