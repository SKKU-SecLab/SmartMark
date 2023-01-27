
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
}// MIT
pragma solidity ^0.8.4;

library LandLib {

	struct Site {
		uint8 typeId;

		uint16 x;

		uint16 y;
	}

	struct PlotView {
		uint8 regionId;

		uint16 x;

		uint16 y;

		uint8 tierId;

		uint16 size;

		uint8 landmarkTypeId;

		uint8 elementSites;

		uint8 fuelSites;

		Site[] sites;
	}

	struct PlotStore {
		uint8 version;

		uint8 regionId;

		uint16 x;

		uint16 y;

		uint8 tierId;

		uint16 size;

		uint8 landmarkTypeId;

		uint8 elementSites;

		uint8 fuelSites;

		uint160 seed;
	}

	function pack(PlotStore memory store) internal pure returns (uint256 packed) {

		return uint256(store.version) << 248
			| uint248(store.regionId) << 240
			| uint240(store.x) << 224
			| uint224(store.y) << 208
			| uint208(store.tierId) << 200
			| uint200(store.size) << 184
			| uint184(store.landmarkTypeId) << 176
			| uint176(store.elementSites) << 168
			| uint168(store.fuelSites) << 160
			| uint160(store.seed);
	}

	function unpack(uint256 packed) internal pure returns (PlotStore memory store) {

		return PlotStore({
			version:        uint8(packed >> 248),
			regionId:       uint8(packed >> 240),
			x:              uint16(packed >> 224),
			y:              uint16(packed >> 208),
			tierId:         uint8(packed >> 200),
			size:           uint16(packed >> 184),
			landmarkTypeId: uint8(packed >> 176),
			elementSites:   uint8(packed >> 168),
			fuelSites:      uint8(packed >> 160),
			seed:           uint160(packed)
		});
	}

	function plotView(PlotStore memory store) internal pure returns (PlotView memory) {

		return PlotView({
			regionId:       store.regionId,
			x:              store.x,
			y:              store.y,
			tierId:         store.tierId,
			size:           store.size,
			landmarkTypeId: store.landmarkTypeId,
			elementSites:   store.elementSites,
			fuelSites:      store.fuelSites,
			sites:          getResourceSites(store.seed, store.elementSites, store.fuelSites, store.size, 2)
		});
	}

	function getResourceSites(
		uint256 seed,
		uint8 elementSites,
		uint8 fuelSites,
		uint16 gridSize,
		uint8 siteSize
	) internal pure returns (Site[] memory sites) {

		uint8 totalSites = elementSites + fuelSites;


		uint16 normalizedSize = gridSize / siteSize;

		normalizedSize = (normalizedSize - 2) / 2 * 2;

		uint16[] memory coords;
		(seed, coords) = getCoords(seed, totalSites, normalizedSize * (1 + normalizedSize / 2) - 4);

		sites = new Site[](totalSites);

		uint16 typeId;
		uint16 x;
		uint16 y;

		for(uint8 i = 0; i < totalSites; i++) {
			(seed, typeId) = nextRndUint16(seed, i < elementSites? 1: 4, 3);

			x = coords[i] % normalizedSize;
			y = coords[i] / normalizedSize;

			if(2 * (1 + x + y) < normalizedSize) {
				x += normalizedSize / 2;
				y += 1 + normalizedSize / 2;
			}
			else if(2 * x > normalizedSize && 2 * x > 2 * y + normalizedSize) {
				x -= normalizedSize / 2;
				y += 1 + normalizedSize / 2;
			}

			if(x >= normalizedSize / 2 - 1 && x <= normalizedSize / 2
			&& y >= normalizedSize / 2 - 1 && y <= normalizedSize / 2) {
				x += 5 * normalizedSize / 2 - 2 * (x + y) - 4;
				y = normalizedSize / 2;
			}

			uint16 offset = gridSize / siteSize % 2 + gridSize % siteSize;

			sites[i] = Site({
				typeId: uint8(typeId),
				x: (1 + x) * siteSize + offset,
				y: (1 + y) * siteSize + offset
			});
		}

		return sites;
	}

	function getLandmark(uint256 seed, uint8 tierId) internal pure returns (uint8 landmarkTypeId) {

		if(tierId == 3) {
			return uint8(1 + seed % 3);
		}
		if(tierId == 4) {
			return uint8(4 + seed % 3);
		}
		if(tierId == 5) {
			return 7;
		}

		return 0;
	}

	function getCoords(
		uint256 seed,
		uint8 length,
		uint16 size
	) internal pure returns (uint256 nextSeed, uint16[] memory coords) {

		coords = new uint16[](length);

		for(uint8 i = 0; i < coords.length; i++) {
			(seed, coords[i]) = nextRndUint16(seed, 0, size);
		}

		sort(coords);

		for(int256 i = findDup(coords); i >= 0; i = findDup(coords)) {
			(seed, coords[uint256(i)]) = nextRndUint16(seed, 0, size);
			sort(coords);
		}

		seed = shuffle(seed, coords);

		return (seed, coords);
	}

	function nextRndUint16(
		uint256 seed,
		uint16 offset,
		uint16 options
	) internal pure returns (
		uint256 nextSeed,
		uint16 rndVal
	) {

		nextSeed = uint256(keccak256(abi.encodePacked(seed)));

		rndVal = offset + uint16(nextSeed % options);

		return (nextSeed, rndVal);
	}


	function loc(PlotStore memory plot) internal pure returns (uint40) {

		return uint40(plot.regionId) << 32 | uint32(plot.y) << 16 | plot.x;
	}


	function findDup(uint16[] memory arr) internal pure returns (int256 index) {

		for(uint256 i = 1; i < arr.length; i++) {
			if(arr[i - 1] >= arr[i]) {
				return int256(i - 1);
			}
		}

		return -1;
	}

	function shuffle(uint256 seed, uint16[] memory arr) internal pure returns(uint256 nextSeed) {

		uint16 j;

		for(uint16 i = 0; i < arr.length; i++) {
			(seed, j) = nextRndUint16(seed, 0, uint16(arr.length));

			(arr[i], arr[j]) = (arr[j], arr[i]);
		}

		return seed;
	}

	function sort(uint16[] memory arr) internal pure {

		quickSort(arr, 0, int256(arr.length) - 1);
	}

	function quickSort(uint16[] memory arr, int256 left, int256 right) private pure {

		int256 i = left;
		int256 j = right;
		if(i >= j) {
			return;
		}
		uint16 pivot = arr[uint256(left + (right - left) / 2)];
		while(i <= j) {
			while(arr[uint256(i)] < pivot) {
				i++;
			}
			while(pivot < arr[uint256(j)]) {
				j--;
			}
			if(i <= j) {
				(arr[uint256(i)], arr[uint256(j)]) = (arr[uint256(j)], arr[uint256(i)]);
				i++;
				j--;
			}
		}
		if(left < j) {
			quickSort(arr, left, j);
		}
		if(i < right) {
			quickSort(arr, i, right);
		}
	}
}// MIT
pragma solidity ^0.8.4;


interface LandERC721Metadata {

	function viewMetadata(uint256 _tokenId) external view returns (LandLib.PlotView memory);


	function getMetadata(uint256 _tokenId) external view returns (LandLib.PlotStore memory);


	function hasMetadata(uint256 _tokenId) external view returns (bool);


	function setMetadata(uint256 _tokenId, LandLib.PlotStore memory _plot) external;


	function removeMetadata(uint256 _tokenId) external;


	function mintWithMetadata(address _to, uint256 _tokenId, LandLib.PlotStore memory _plot) external;

}

interface LandDescriptor {

	function tokenURI(uint256 _tokenId) external view returns (string memory);

}// Unlicense
pragma solidity >=0.8.4;

error PRBMath__MulDivFixedPointOverflow(uint256 prod1);

error PRBMath__MulDivOverflow(uint256 prod1, uint256 denominator);

error PRBMath__MulDivSignedInputTooSmall();

error PRBMath__MulDivSignedOverflow(uint256 rAbs);

error PRBMathSD59x18__AbsInputTooSmall();

error PRBMathSD59x18__CeilOverflow(int256 x);

error PRBMathSD59x18__DivInputTooSmall();

error PRBMathSD59x18__DivOverflow(uint256 rAbs);

error PRBMathSD59x18__ExpInputTooBig(int256 x);

error PRBMathSD59x18__Exp2InputTooBig(int256 x);

error PRBMathSD59x18__FloorUnderflow(int256 x);

error PRBMathSD59x18__FromIntOverflow(int256 x);

error PRBMathSD59x18__FromIntUnderflow(int256 x);

error PRBMathSD59x18__GmNegativeProduct(int256 x, int256 y);

error PRBMathSD59x18__GmOverflow(int256 x, int256 y);

error PRBMathSD59x18__LogInputTooSmall(int256 x);

error PRBMathSD59x18__MulInputTooSmall();

error PRBMathSD59x18__MulOverflow(uint256 rAbs);

error PRBMathSD59x18__PowuOverflow(uint256 rAbs);

error PRBMathSD59x18__SqrtNegativeInput(int256 x);

error PRBMathSD59x18__SqrtOverflow(int256 x);

error PRBMathUD60x18__AddOverflow(uint256 x, uint256 y);

error PRBMathUD60x18__CeilOverflow(uint256 x);

error PRBMathUD60x18__ExpInputTooBig(uint256 x);

error PRBMathUD60x18__Exp2InputTooBig(uint256 x);

error PRBMathUD60x18__FromUintOverflow(uint256 x);

error PRBMathUD60x18__GmOverflow(uint256 x, uint256 y);

error PRBMathUD60x18__LogInputTooSmall(uint256 x);

error PRBMathUD60x18__SqrtOverflow(uint256 x);

error PRBMathUD60x18__SubUnderflow(uint256 x, uint256 y);

library PRBMath {


    struct SD59x18 {
        int256 value;
    }

    struct UD60x18 {
        uint256 value;
    }


    uint256 internal constant SCALE = 1e18;

    uint256 internal constant SCALE_LPOTD = 262144;

    uint256 internal constant SCALE_INVERSE =
        78156646155174841979727994598816262306175212592076161876661_508869554232690281;


    function exp2(uint256 x) internal pure returns (uint256 result) {

        unchecked {
            result = 0x800000000000000000000000000000000000000000000000;

            if (x & 0x8000000000000000 > 0) {
                result = (result * 0x16A09E667F3BCC909) >> 64;
            }
            if (x & 0x4000000000000000 > 0) {
                result = (result * 0x1306FE0A31B7152DF) >> 64;
            }
            if (x & 0x2000000000000000 > 0) {
                result = (result * 0x1172B83C7D517ADCE) >> 64;
            }
            if (x & 0x1000000000000000 > 0) {
                result = (result * 0x10B5586CF9890F62A) >> 64;
            }
            if (x & 0x800000000000000 > 0) {
                result = (result * 0x1059B0D31585743AE) >> 64;
            }
            if (x & 0x400000000000000 > 0) {
                result = (result * 0x102C9A3E778060EE7) >> 64;
            }
            if (x & 0x200000000000000 > 0) {
                result = (result * 0x10163DA9FB33356D8) >> 64;
            }
            if (x & 0x100000000000000 > 0) {
                result = (result * 0x100B1AFA5ABCBED61) >> 64;
            }
            if (x & 0x80000000000000 > 0) {
                result = (result * 0x10058C86DA1C09EA2) >> 64;
            }
            if (x & 0x40000000000000 > 0) {
                result = (result * 0x1002C605E2E8CEC50) >> 64;
            }
            if (x & 0x20000000000000 > 0) {
                result = (result * 0x100162F3904051FA1) >> 64;
            }
            if (x & 0x10000000000000 > 0) {
                result = (result * 0x1000B175EFFDC76BA) >> 64;
            }
            if (x & 0x8000000000000 > 0) {
                result = (result * 0x100058BA01FB9F96D) >> 64;
            }
            if (x & 0x4000000000000 > 0) {
                result = (result * 0x10002C5CC37DA9492) >> 64;
            }
            if (x & 0x2000000000000 > 0) {
                result = (result * 0x1000162E525EE0547) >> 64;
            }
            if (x & 0x1000000000000 > 0) {
                result = (result * 0x10000B17255775C04) >> 64;
            }
            if (x & 0x800000000000 > 0) {
                result = (result * 0x1000058B91B5BC9AE) >> 64;
            }
            if (x & 0x400000000000 > 0) {
                result = (result * 0x100002C5C89D5EC6D) >> 64;
            }
            if (x & 0x200000000000 > 0) {
                result = (result * 0x10000162E43F4F831) >> 64;
            }
            if (x & 0x100000000000 > 0) {
                result = (result * 0x100000B1721BCFC9A) >> 64;
            }
            if (x & 0x80000000000 > 0) {
                result = (result * 0x10000058B90CF1E6E) >> 64;
            }
            if (x & 0x40000000000 > 0) {
                result = (result * 0x1000002C5C863B73F) >> 64;
            }
            if (x & 0x20000000000 > 0) {
                result = (result * 0x100000162E430E5A2) >> 64;
            }
            if (x & 0x10000000000 > 0) {
                result = (result * 0x1000000B172183551) >> 64;
            }
            if (x & 0x8000000000 > 0) {
                result = (result * 0x100000058B90C0B49) >> 64;
            }
            if (x & 0x4000000000 > 0) {
                result = (result * 0x10000002C5C8601CC) >> 64;
            }
            if (x & 0x2000000000 > 0) {
                result = (result * 0x1000000162E42FFF0) >> 64;
            }
            if (x & 0x1000000000 > 0) {
                result = (result * 0x10000000B17217FBB) >> 64;
            }
            if (x & 0x800000000 > 0) {
                result = (result * 0x1000000058B90BFCE) >> 64;
            }
            if (x & 0x400000000 > 0) {
                result = (result * 0x100000002C5C85FE3) >> 64;
            }
            if (x & 0x200000000 > 0) {
                result = (result * 0x10000000162E42FF1) >> 64;
            }
            if (x & 0x100000000 > 0) {
                result = (result * 0x100000000B17217F8) >> 64;
            }
            if (x & 0x80000000 > 0) {
                result = (result * 0x10000000058B90BFC) >> 64;
            }
            if (x & 0x40000000 > 0) {
                result = (result * 0x1000000002C5C85FE) >> 64;
            }
            if (x & 0x20000000 > 0) {
                result = (result * 0x100000000162E42FF) >> 64;
            }
            if (x & 0x10000000 > 0) {
                result = (result * 0x1000000000B17217F) >> 64;
            }
            if (x & 0x8000000 > 0) {
                result = (result * 0x100000000058B90C0) >> 64;
            }
            if (x & 0x4000000 > 0) {
                result = (result * 0x10000000002C5C860) >> 64;
            }
            if (x & 0x2000000 > 0) {
                result = (result * 0x1000000000162E430) >> 64;
            }
            if (x & 0x1000000 > 0) {
                result = (result * 0x10000000000B17218) >> 64;
            }
            if (x & 0x800000 > 0) {
                result = (result * 0x1000000000058B90C) >> 64;
            }
            if (x & 0x400000 > 0) {
                result = (result * 0x100000000002C5C86) >> 64;
            }
            if (x & 0x200000 > 0) {
                result = (result * 0x10000000000162E43) >> 64;
            }
            if (x & 0x100000 > 0) {
                result = (result * 0x100000000000B1721) >> 64;
            }
            if (x & 0x80000 > 0) {
                result = (result * 0x10000000000058B91) >> 64;
            }
            if (x & 0x40000 > 0) {
                result = (result * 0x1000000000002C5C8) >> 64;
            }
            if (x & 0x20000 > 0) {
                result = (result * 0x100000000000162E4) >> 64;
            }
            if (x & 0x10000 > 0) {
                result = (result * 0x1000000000000B172) >> 64;
            }
            if (x & 0x8000 > 0) {
                result = (result * 0x100000000000058B9) >> 64;
            }
            if (x & 0x4000 > 0) {
                result = (result * 0x10000000000002C5D) >> 64;
            }
            if (x & 0x2000 > 0) {
                result = (result * 0x1000000000000162E) >> 64;
            }
            if (x & 0x1000 > 0) {
                result = (result * 0x10000000000000B17) >> 64;
            }
            if (x & 0x800 > 0) {
                result = (result * 0x1000000000000058C) >> 64;
            }
            if (x & 0x400 > 0) {
                result = (result * 0x100000000000002C6) >> 64;
            }
            if (x & 0x200 > 0) {
                result = (result * 0x10000000000000163) >> 64;
            }
            if (x & 0x100 > 0) {
                result = (result * 0x100000000000000B1) >> 64;
            }
            if (x & 0x80 > 0) {
                result = (result * 0x10000000000000059) >> 64;
            }
            if (x & 0x40 > 0) {
                result = (result * 0x1000000000000002C) >> 64;
            }
            if (x & 0x20 > 0) {
                result = (result * 0x10000000000000016) >> 64;
            }
            if (x & 0x10 > 0) {
                result = (result * 0x1000000000000000B) >> 64;
            }
            if (x & 0x8 > 0) {
                result = (result * 0x10000000000000006) >> 64;
            }
            if (x & 0x4 > 0) {
                result = (result * 0x10000000000000003) >> 64;
            }
            if (x & 0x2 > 0) {
                result = (result * 0x10000000000000001) >> 64;
            }
            if (x & 0x1 > 0) {
                result = (result * 0x10000000000000001) >> 64;
            }

            result *= SCALE;
            result >>= (191 - (x >> 64));
        }
    }

    function mostSignificantBit(uint256 x) internal pure returns (uint256 msb) {

        if (x >= 2**128) {
            x >>= 128;
            msb += 128;
        }
        if (x >= 2**64) {
            x >>= 64;
            msb += 64;
        }
        if (x >= 2**32) {
            x >>= 32;
            msb += 32;
        }
        if (x >= 2**16) {
            x >>= 16;
            msb += 16;
        }
        if (x >= 2**8) {
            x >>= 8;
            msb += 8;
        }
        if (x >= 2**4) {
            x >>= 4;
            msb += 4;
        }
        if (x >= 2**2) {
            x >>= 2;
            msb += 2;
        }
        if (x >= 2**1) {
            msb += 1;
        }
    }

    function mulDiv(
        uint256 x,
        uint256 y,
        uint256 denominator
    ) internal pure returns (uint256 result) {

        uint256 prod0; // Least significant 256 bits of the product
        uint256 prod1; // Most significant 256 bits of the product
        assembly {
            let mm := mulmod(x, y, not(0))
            prod0 := mul(x, y)
            prod1 := sub(sub(mm, prod0), lt(mm, prod0))
        }

        if (prod1 == 0) {
            unchecked {
                result = prod0 / denominator;
            }
            return result;
        }

        if (prod1 >= denominator) {
            revert PRBMath__MulDivOverflow(prod1, denominator);
        }


        uint256 remainder;
        assembly {
            remainder := mulmod(x, y, denominator)

            prod1 := sub(prod1, gt(remainder, prod0))
            prod0 := sub(prod0, remainder)
        }

        unchecked {
            uint256 lpotdod = denominator & (~denominator + 1);
            assembly {
                denominator := div(denominator, lpotdod)

                prod0 := div(prod0, lpotdod)

                lpotdod := add(div(sub(0, lpotdod), lpotdod), 1)
            }

            prod0 |= prod1 * lpotdod;

            uint256 inverse = (3 * denominator) ^ 2;

            inverse *= 2 - denominator * inverse; // inverse mod 2^8
            inverse *= 2 - denominator * inverse; // inverse mod 2^16
            inverse *= 2 - denominator * inverse; // inverse mod 2^32
            inverse *= 2 - denominator * inverse; // inverse mod 2^64
            inverse *= 2 - denominator * inverse; // inverse mod 2^128
            inverse *= 2 - denominator * inverse; // inverse mod 2^256

            result = prod0 * inverse;
            return result;
        }
    }

    function mulDivFixedPoint(uint256 x, uint256 y) internal pure returns (uint256 result) {

        uint256 prod0;
        uint256 prod1;
        assembly {
            let mm := mulmod(x, y, not(0))
            prod0 := mul(x, y)
            prod1 := sub(sub(mm, prod0), lt(mm, prod0))
        }

        if (prod1 >= SCALE) {
            revert PRBMath__MulDivFixedPointOverflow(prod1);
        }

        uint256 remainder;
        uint256 roundUpUnit;
        assembly {
            remainder := mulmod(x, y, SCALE)
            roundUpUnit := gt(remainder, 499999999999999999)
        }

        if (prod1 == 0) {
            unchecked {
                result = (prod0 / SCALE) + roundUpUnit;
                return result;
            }
        }

        assembly {
            result := add(
                mul(
                    or(
                        div(sub(prod0, remainder), SCALE_LPOTD),
                        mul(sub(prod1, gt(remainder, prod0)), add(div(sub(0, SCALE_LPOTD), SCALE_LPOTD), 1))
                    ),
                    SCALE_INVERSE
                ),
                roundUpUnit
            )
        }
    }

    function mulDivSigned(
        int256 x,
        int256 y,
        int256 denominator
    ) internal pure returns (int256 result) {

        if (x == type(int256).min || y == type(int256).min || denominator == type(int256).min) {
            revert PRBMath__MulDivSignedInputTooSmall();
        }

        uint256 ax;
        uint256 ay;
        uint256 ad;
        unchecked {
            ax = x < 0 ? uint256(-x) : uint256(x);
            ay = y < 0 ? uint256(-y) : uint256(y);
            ad = denominator < 0 ? uint256(-denominator) : uint256(denominator);
        }

        uint256 rAbs = mulDiv(ax, ay, ad);
        if (rAbs > uint256(type(int256).max)) {
            revert PRBMath__MulDivSignedOverflow(rAbs);
        }

        uint256 sx;
        uint256 sy;
        uint256 sd;
        assembly {
            sx := sgt(x, sub(0, 1))
            sy := sgt(y, sub(0, 1))
            sd := sgt(denominator, sub(0, 1))
        }

        result = sx ^ sy ^ sd == 0 ? -int256(rAbs) : int256(rAbs);
    }

    function sqrt(uint256 x) internal pure returns (uint256 result) {

        if (x == 0) {
            return 0;
        }

        uint256 xAux = uint256(x);
        result = 1;
        if (xAux >= 0x100000000000000000000000000000000) {
            xAux >>= 128;
            result <<= 64;
        }
        if (xAux >= 0x10000000000000000) {
            xAux >>= 64;
            result <<= 32;
        }
        if (xAux >= 0x100000000) {
            xAux >>= 32;
            result <<= 16;
        }
        if (xAux >= 0x10000) {
            xAux >>= 16;
            result <<= 8;
        }
        if (xAux >= 0x100) {
            xAux >>= 8;
            result <<= 4;
        }
        if (xAux >= 0x10) {
            xAux >>= 4;
            result <<= 2;
        }
        if (xAux >= 0x8) {
            result <<= 1;
        }

        unchecked {
            result = (result + x / result) >> 1;
            result = (result + x / result) >> 1;
            result = (result + x / result) >> 1;
            result = (result + x / result) >> 1;
            result = (result + x / result) >> 1;
            result = (result + x / result) >> 1;
            result = (result + x / result) >> 1; // Seven iterations should be enough
            uint256 roundedDownResult = x / result;
            return result >= roundedDownResult ? roundedDownResult : result;
        }
    }
}// Unlicense
pragma solidity >=0.8.4;


library PRBMathUD60x18 {

    uint256 internal constant HALF_SCALE = 5e17;

    uint256 internal constant LOG2_E = 1_442695040888963407;

    uint256 internal constant MAX_UD60x18 =
        115792089237316195423570985008687907853269984665640564039457_584007913129639935;

    uint256 internal constant MAX_WHOLE_UD60x18 =
        115792089237316195423570985008687907853269984665640564039457_000000000000000000;

    uint256 internal constant SCALE = 1e18;

    function avg(uint256 x, uint256 y) internal pure returns (uint256 result) {

        unchecked {
            result = (x >> 1) + (y >> 1) + (x & y & 1);
        }
    }

    function ceil(uint256 x) internal pure returns (uint256 result) {

        if (x > MAX_WHOLE_UD60x18) {
            revert PRBMathUD60x18__CeilOverflow(x);
        }
        assembly {
            let remainder := mod(x, SCALE)

            let delta := sub(SCALE, remainder)

            result := add(x, mul(delta, gt(remainder, 0)))
        }
    }

    function div(uint256 x, uint256 y) internal pure returns (uint256 result) {

        result = PRBMath.mulDiv(x, SCALE, y);
    }

    function e() internal pure returns (uint256 result) {

        result = 2_718281828459045235;
    }

    function exp(uint256 x) internal pure returns (uint256 result) {

        if (x >= 133_084258667509499441) {
            revert PRBMathUD60x18__ExpInputTooBig(x);
        }

        unchecked {
            uint256 doubleScaleProduct = x * LOG2_E;
            result = exp2((doubleScaleProduct + HALF_SCALE) / SCALE);
        }
    }

    function exp2(uint256 x) internal pure returns (uint256 result) {

        if (x >= 192e18) {
            revert PRBMathUD60x18__Exp2InputTooBig(x);
        }

        unchecked {
            uint256 x192x64 = (x << 64) / SCALE;

            result = PRBMath.exp2(x192x64);
        }
    }

    function floor(uint256 x) internal pure returns (uint256 result) {

        assembly {
            let remainder := mod(x, SCALE)

            result := sub(x, mul(remainder, gt(remainder, 0)))
        }
    }

    function frac(uint256 x) internal pure returns (uint256 result) {

        assembly {
            result := mod(x, SCALE)
        }
    }

    function fromUint(uint256 x) internal pure returns (uint256 result) {

        unchecked {
            if (x > MAX_UD60x18 / SCALE) {
                revert PRBMathUD60x18__FromUintOverflow(x);
            }
            result = x * SCALE;
        }
    }

    function gm(uint256 x, uint256 y) internal pure returns (uint256 result) {

        if (x == 0) {
            return 0;
        }

        unchecked {
            uint256 xy = x * y;
            if (xy / x != y) {
                revert PRBMathUD60x18__GmOverflow(x, y);
            }

            result = PRBMath.sqrt(xy);
        }
    }

    function inv(uint256 x) internal pure returns (uint256 result) {

        unchecked {
            result = 1e36 / x;
        }
    }

    function ln(uint256 x) internal pure returns (uint256 result) {

        unchecked {
            result = (log2(x) * SCALE) / LOG2_E;
        }
    }

    function log10(uint256 x) internal pure returns (uint256 result) {

        if (x < SCALE) {
            revert PRBMathUD60x18__LogInputTooSmall(x);
        }

        assembly {
            switch x
            case 1 { result := mul(SCALE, sub(0, 18)) }
            case 10 { result := mul(SCALE, sub(1, 18)) }
            case 100 { result := mul(SCALE, sub(2, 18)) }
            case 1000 { result := mul(SCALE, sub(3, 18)) }
            case 10000 { result := mul(SCALE, sub(4, 18)) }
            case 100000 { result := mul(SCALE, sub(5, 18)) }
            case 1000000 { result := mul(SCALE, sub(6, 18)) }
            case 10000000 { result := mul(SCALE, sub(7, 18)) }
            case 100000000 { result := mul(SCALE, sub(8, 18)) }
            case 1000000000 { result := mul(SCALE, sub(9, 18)) }
            case 10000000000 { result := mul(SCALE, sub(10, 18)) }
            case 100000000000 { result := mul(SCALE, sub(11, 18)) }
            case 1000000000000 { result := mul(SCALE, sub(12, 18)) }
            case 10000000000000 { result := mul(SCALE, sub(13, 18)) }
            case 100000000000000 { result := mul(SCALE, sub(14, 18)) }
            case 1000000000000000 { result := mul(SCALE, sub(15, 18)) }
            case 10000000000000000 { result := mul(SCALE, sub(16, 18)) }
            case 100000000000000000 { result := mul(SCALE, sub(17, 18)) }
            case 1000000000000000000 { result := 0 }
            case 10000000000000000000 { result := SCALE }
            case 100000000000000000000 { result := mul(SCALE, 2) }
            case 1000000000000000000000 { result := mul(SCALE, 3) }
            case 10000000000000000000000 { result := mul(SCALE, 4) }
            case 100000000000000000000000 { result := mul(SCALE, 5) }
            case 1000000000000000000000000 { result := mul(SCALE, 6) }
            case 10000000000000000000000000 { result := mul(SCALE, 7) }
            case 100000000000000000000000000 { result := mul(SCALE, 8) }
            case 1000000000000000000000000000 { result := mul(SCALE, 9) }
            case 10000000000000000000000000000 { result := mul(SCALE, 10) }
            case 100000000000000000000000000000 { result := mul(SCALE, 11) }
            case 1000000000000000000000000000000 { result := mul(SCALE, 12) }
            case 10000000000000000000000000000000 { result := mul(SCALE, 13) }
            case 100000000000000000000000000000000 { result := mul(SCALE, 14) }
            case 1000000000000000000000000000000000 { result := mul(SCALE, 15) }
            case 10000000000000000000000000000000000 { result := mul(SCALE, 16) }
            case 100000000000000000000000000000000000 { result := mul(SCALE, 17) }
            case 1000000000000000000000000000000000000 { result := mul(SCALE, 18) }
            case 10000000000000000000000000000000000000 { result := mul(SCALE, 19) }
            case 100000000000000000000000000000000000000 { result := mul(SCALE, 20) }
            case 1000000000000000000000000000000000000000 { result := mul(SCALE, 21) }
            case 10000000000000000000000000000000000000000 { result := mul(SCALE, 22) }
            case 100000000000000000000000000000000000000000 { result := mul(SCALE, 23) }
            case 1000000000000000000000000000000000000000000 { result := mul(SCALE, 24) }
            case 10000000000000000000000000000000000000000000 { result := mul(SCALE, 25) }
            case 100000000000000000000000000000000000000000000 { result := mul(SCALE, 26) }
            case 1000000000000000000000000000000000000000000000 { result := mul(SCALE, 27) }
            case 10000000000000000000000000000000000000000000000 { result := mul(SCALE, 28) }
            case 100000000000000000000000000000000000000000000000 { result := mul(SCALE, 29) }
            case 1000000000000000000000000000000000000000000000000 { result := mul(SCALE, 30) }
            case 10000000000000000000000000000000000000000000000000 { result := mul(SCALE, 31) }
            case 100000000000000000000000000000000000000000000000000 { result := mul(SCALE, 32) }
            case 1000000000000000000000000000000000000000000000000000 { result := mul(SCALE, 33) }
            case 10000000000000000000000000000000000000000000000000000 { result := mul(SCALE, 34) }
            case 100000000000000000000000000000000000000000000000000000 { result := mul(SCALE, 35) }
            case 1000000000000000000000000000000000000000000000000000000 { result := mul(SCALE, 36) }
            case 10000000000000000000000000000000000000000000000000000000 { result := mul(SCALE, 37) }
            case 100000000000000000000000000000000000000000000000000000000 { result := mul(SCALE, 38) }
            case 1000000000000000000000000000000000000000000000000000000000 { result := mul(SCALE, 39) }
            case 10000000000000000000000000000000000000000000000000000000000 { result := mul(SCALE, 40) }
            case 100000000000000000000000000000000000000000000000000000000000 { result := mul(SCALE, 41) }
            case 1000000000000000000000000000000000000000000000000000000000000 { result := mul(SCALE, 42) }
            case 10000000000000000000000000000000000000000000000000000000000000 { result := mul(SCALE, 43) }
            case 100000000000000000000000000000000000000000000000000000000000000 { result := mul(SCALE, 44) }
            case 1000000000000000000000000000000000000000000000000000000000000000 { result := mul(SCALE, 45) }
            case 10000000000000000000000000000000000000000000000000000000000000000 { result := mul(SCALE, 46) }
            case 100000000000000000000000000000000000000000000000000000000000000000 { result := mul(SCALE, 47) }
            case 1000000000000000000000000000000000000000000000000000000000000000000 { result := mul(SCALE, 48) }
            case 10000000000000000000000000000000000000000000000000000000000000000000 { result := mul(SCALE, 49) }
            case 100000000000000000000000000000000000000000000000000000000000000000000 { result := mul(SCALE, 50) }
            case 1000000000000000000000000000000000000000000000000000000000000000000000 { result := mul(SCALE, 51) }
            case 10000000000000000000000000000000000000000000000000000000000000000000000 { result := mul(SCALE, 52) }
            case 100000000000000000000000000000000000000000000000000000000000000000000000 { result := mul(SCALE, 53) }
            case 1000000000000000000000000000000000000000000000000000000000000000000000000 { result := mul(SCALE, 54) }
            case 10000000000000000000000000000000000000000000000000000000000000000000000000 { result := mul(SCALE, 55) }
            case 100000000000000000000000000000000000000000000000000000000000000000000000000 { result := mul(SCALE, 56) }
            case 1000000000000000000000000000000000000000000000000000000000000000000000000000 { result := mul(SCALE, 57) }
            case 10000000000000000000000000000000000000000000000000000000000000000000000000000 { result := mul(SCALE, 58) }
            case 100000000000000000000000000000000000000000000000000000000000000000000000000000 { result := mul(SCALE, 59) }
            default {
                result := MAX_UD60x18
            }
        }

        if (result == MAX_UD60x18) {
            unchecked {
                result = (log2(x) * SCALE) / 3_321928094887362347;
            }
        }
    }

    function log2(uint256 x) internal pure returns (uint256 result) {

        if (x < SCALE) {
            revert PRBMathUD60x18__LogInputTooSmall(x);
        }
        unchecked {
            uint256 n = PRBMath.mostSignificantBit(x / SCALE);

            result = n * SCALE;

            uint256 y = x >> n;

            if (y == SCALE) {
                return result;
            }

            for (uint256 delta = HALF_SCALE; delta > 0; delta >>= 1) {
                y = (y * y) / SCALE;

                if (y >= 2 * SCALE) {
                    result += delta;

                    y >>= 1;
                }
            }
        }
    }

    function mul(uint256 x, uint256 y) internal pure returns (uint256 result) {

        result = PRBMath.mulDivFixedPoint(x, y);
    }

    function pi() internal pure returns (uint256 result) {

        result = 3_141592653589793238;
    }

    function pow(uint256 x, uint256 y) internal pure returns (uint256 result) {

        if (x == 0) {
            result = y == 0 ? SCALE : uint256(0);
        } else {
            result = exp2(mul(log2(x), y));
        }
    }

    function powu(uint256 x, uint256 y) internal pure returns (uint256 result) {

        result = y & 1 > 0 ? x : SCALE;

        for (y >>= 1; y > 0; y >>= 1) {
            x = PRBMath.mulDivFixedPoint(x, x);

            if (y & 1 > 0) {
                result = PRBMath.mulDivFixedPoint(result, x);
            }
        }
    }

    function scale() internal pure returns (uint256 result) {

        result = SCALE;
    }

    function sqrt(uint256 x) internal pure returns (uint256 result) {

        unchecked {
            if (x > MAX_UD60x18 / SCALE) {
                revert PRBMathUD60x18__SqrtOverflow(x);
            }
            result = PRBMath.sqrt(x * SCALE);
        }
    }

    function toUint(uint256 x) internal pure returns (uint256 result) {

        unchecked {
            result = x / SCALE;
        }
    }
}// MIT
pragma solidity ^0.8.4;


library LandSvgLib {

	using Strings for uint256;
	using PRBMathUD60x18 for uint256;

	function _generateSVGImage(
		uint16 _gridSize, 
		uint8 _tierId, 
		uint8 _landmarkTypeId,
		LandLib.Site[] memory _sites
	) private pure returns (string memory) {


		return string(
			abi.encodePacked(
				"<svg height='",
				uint256(_gridSize * 3 + 6).toString(),
				"' width='",
				uint256(_gridSize * 3).toString(),
				"' stroke-width='2' xmlns='http://www.w3.org/2000/svg'>",
				"<rect rx='5%' ry='5%' width='100%' height='99%' fill='url(#BOARD_BOTTOM_BORDER_COLOR_TIER_",
				uint256(_tierId).toString(),
				")' stroke='none'/>",
				"<svg height='97.6%' width='100%' stroke-width='2' xmlns='http://www.w3.org/2000/svg'>",
				_generateLandBoard(_gridSize, _tierId, _landmarkTypeId, _sites), // This line should be replaced in the loop
				"</svg>"
			)
		);
	}

	function _siteBaseSvg(uint16 _x, uint16 _y, uint8 _typeId) private pure returns (string memory) {

		return string(
			abi.encodePacked(
				"<svg x='", 
				uint256(_x).toString(), 
				"' y='", 
				uint256(_y).toString(),
				"' width='6' height='6' xmlns='http://www.w3.org/2000/svg'><use href='#SITE_TYPE_",
				uint256(_typeId).toString(),
				"' /></svg>"
			)
		);
	}

	function _generateLandmarkSvg(uint16 _gridSize, uint8 _landmarkTypeId) private pure returns (string memory) {

		uint256 landmarkPos = uint256(_gridSize - 2).fromUint().div(uint256(2).fromUint()).mul(uint256(3).fromUint());

		string memory landmarkFloatX;
		string memory landmarkFloatY;
		if (_gridSize % 2 == 0) {
			landmarkFloatX = landmarkPos.toUint().toString();
			landmarkFloatY = (landmarkPos.toUint() - 3).toString();
		} else {
			landmarkFloatX = (landmarkPos.ceil().toUint() + 1).toString();
			landmarkFloatY = (landmarkPos.floor().toUint() - 1).toString();
		}

		return string(
			abi.encodePacked(
				"<svg x='",
				landmarkFloatX,
				"' y='",
				landmarkFloatY,
				"' width='12' height='12' xmlns='http://www.w3.org/2000/svg'><use href='#LANDMARK_TYPE_",
				uint256(_landmarkTypeId).toString(),
				"'/></svg>"
			)
		);
	}

	function _landBoardArray(
		uint16 _gridSize, 
		uint8 _tierId, 
		uint8 _landmarkTypeId, 
		LandLib.Site[] memory _sites
	) private pure returns (string[170] memory) {

		uint256 scaledGridSize = uint256(_gridSize).fromUint().div(uint256(2).fromUint()).mul(uint256(3).fromUint());
		string memory scaledGridSizeString = string(
			abi.encodePacked(
				scaledGridSize.toUint().toString(),
				".",
				(scaledGridSize.frac()/1e16).toString()
			)
		);
		return [
			"<defs><symbol id='SITE_TYPE_1' width='6' height='6'>", // Site Carbon
			"<svg width='6' height='6' viewBox='0 0 14 14' fill='none' xmlns='http://www.w3.org/2000/svg'>",
			"<rect x='1.12' y='1' width='12' height='12' fill='url(#site-type-1)' stroke='white' stroke-opacity='0.5'/>",
			"<defs><linearGradient id='site-type-1' x1='13.12' y1='1' x2='1.12' y2='13' gradientUnits='userSpaceOnUse'>",
			"<stop stop-color='#565656'/><stop offset='1'/></linearGradient></defs></svg></symbol>",
			"<symbol id='SITE_TYPE_2' width='6' height='6'>", // Site Silicon
			"<svg width='6' height='6' viewBox='0 0 12 12' fill='none' xmlns='http://www.w3.org/2000/svg'>",
			"<rect x='1.12' y='1' width='10' height='10' fill='url(#paint0_linear_1321_129011)' stroke='white' stroke-opacity='0.5'/>",
			"<defs><linearGradient id='paint0_linear_1321_129011' x1='11.12' y1='1' x2='1.12' y2='11' gradientUnits='userSpaceOnUse'>",
			"<stop stop-color='#CBE2FF'/><stop offset='1' stop-color='#EFEFEF'/></linearGradient></defs></svg></symbol>",
			"<symbol id='SITE_TYPE_3' width='6' height='6'>", // Site Hydrogen
			"<svg width='6' height='6' viewBox='0 0 12 12' fill='none' xmlns='http://www.w3.org/2000/svg'>",
			"<rect x='1.12' y='1' width='10' height='10' fill='url(#paint0_linear_1320_145814)' stroke='white' stroke-opacity='0.5'/>",
			"<defs><linearGradient id='paint0_linear_1320_145814' x1='11.12' y1='1' x2='-0.862058' y2='7.11845' gradientUnits='userSpaceOnUse'>",
			"<stop stop-color='#8CD4D9'/><stop offset='1' stop-color='#598FA6'/></linearGradient></defs></svg></symbol>",
			"<symbol id='SITE_TYPE_4' width='6' height='6'>", // Site Crypton
			"<svg width='6' height='6' viewBox='0 0 12 12' fill='none' xmlns='http://www.w3.org/2000/svg'>",
			"<rect x='1.12' y='1' width='10' height='10' fill='url(#paint0_linear_1321_129013)' stroke='white' stroke-opacity='0.5'/>",
			"<defs><linearGradient id='paint0_linear_1321_129013' x1='11.12' y1='1' x2='1.12' y2='11' gradientUnits='userSpaceOnUse'>",
			"<stop offset='1' stop-color='#52FF00'/></linearGradient></defs></svg></symbol>",
			"<symbol id='SITE_TYPE_5' width='6' height='6'>", // Site Hyperion
			"<svg width='6' height='6' viewBox='0 0 12 12' fill='none' xmlns='http://www.w3.org/2000/svg'>",
			"<rect x='1.12' y='1' width='10' height='10' fill='url(#paint0_linear_1321_129017)' stroke='white' stroke-opacity='0.5'/>",
			"<defs><linearGradient id='paint0_linear_1321_129017' x1='11.12' y1='1' x2='1.12' y2='11' gradientUnits='userSpaceOnUse'>",
			"<stop stop-color='#31F27F'/><stop offset='0.296875' stop-color='#F4BE86'/><stop offset='0.578125' stop-color='#B26FD2'/>",
			"<stop offset='0.734375' stop-color='#7F70D2'/><stop offset='1' stop-color='#8278F2'/></linearGradient></defs></svg></symbol>",
			"<symbol id='SITE_TYPE_6' width='6' height='6'>",
			"<svg width='6' height='6' viewBox='0 0 12 12' fill='none' xmlns='http://www.w3.org/2000/svg'>", // Site Solon
			"<rect x='1.12' y='1' width='10' height='10' fill='url(#paint0_linear_1321_129015)' stroke='white' stroke-opacity='0.5'/>",
			"<defs><linearGradient id='paint0_linear_1321_129015' x1='11.12' y1='1' x2='1.11999' y2='11' gradientUnits='userSpaceOnUse'>",
			"<stop stop-color='white'/><stop offset='0.544585' stop-color='#FFD600'/><stop offset='1' stop-color='#FF9900'/>",
			"</linearGradient></defs></svg></symbol>",
			"<linearGradient id='BOARD_BOTTOM_BORDER_COLOR_TIER_5' xmlns='http://www.w3.org/2000/svg'>",
			"<stop stop-color='#BE13AE'/></linearGradient><linearGradient",
			" id='BOARD_BOTTOM_BORDER_COLOR_TIER_4' xmlns='http://www.w3.org/2000/svg'>",
			"<stop stop-color='#1F7460'/></linearGradient><linearGradient",
			" id='BOARD_BOTTOM_BORDER_COLOR_TIER_3' xmlns='http://www.w3.org/2000/svg'>",
			"<stop stop-color='#6124AE'/></linearGradient><linearGradient",
			" id='BOARD_BOTTOM_BORDER_COLOR_TIER_2' xmlns='http://www.w3.org/2000/svg'>",
			"<stop stop-color='#5350AA'/></linearGradient><linearGradient",
			" id='BOARD_BOTTOM_BORDER_COLOR_TIER_1' xmlns='http://www.w3.org/2000/svg'>",
			"<stop stop-color='#2C2B67'/></linearGradient>",
			"<linearGradient id='GRADIENT_BOARD_TIER_5' x1='100%' y1='0' x2='100%' y2='100%'", 
			" gradientUnits='userSpaceOnUse' xmlns='http://www.w3.org/2000/svg'>",
			"<stop offset='0.130208' stop-color='#EFD700'/>",
			"<stop offset='0.6875' stop-color='#FF57EE'/><stop offset='1' stop-color='#9A24EC'/>",
			"</linearGradient><linearGradient id='GRADIENT_BOARD_TIER_4' x1='50%' y1='100%' x2='50%' y2='0'",
			" gradientUnits='userSpaceOnUse' xmlns='http://www.w3.org/2000/svg'>",
			"<stop stop-color='#239378'/><stop offset='1' stop-color='#41E23E'/></linearGradient>",
			"<linearGradient id='GRADIENT_BOARD_TIER_3' x1='50%' y1='100%' x2='50%' y2='0'",
			" gradientUnits='userSpaceOnUse' xmlns='http://www.w3.org/2000/svg'>",
			"<stop stop-color='#812DED'/><stop offset='1' stop-color='#F100D9'/></linearGradient>",
			"<linearGradient id='GRADIENT_BOARD_TIER_2' x1='50%' y1='0' x2='50%' y2='100%'",
			" gradientUnits='userSpaceOnUse' xmlns='http://www.w3.org/2000/svg'>",
			"<stop stop-color='#7DD6F2'/><stop offset='1' stop-color='#625EDC'/></linearGradient>",
			"<linearGradient id='GRADIENT_BOARD_TIER_1' x1='50%' y1='0' x2='50%' y2='100%'",
			" gradientUnits='userSpaceOnUse' xmlns='http://www.w3.org/2000/svg'>",
			"<stop stop-color='#4C44A0'/><stop offset='1' stop-color='#2F2C83'/></linearGradient>",
			"<linearGradient id='ROUNDED_BORDER_TIER_5' x1='100%' y1='16.6%' x2='100%' y2='100%'",
			" gradientUnits='userSpaceOnUse' xmlns='http://www.w3.org/2000/svg'>",
			"<stop stop-color='#D2FFD9'/><stop offset='1' stop-color='#F32BE1'/></linearGradient>",
			"<linearGradient id='ROUNDED_BORDER_TIER_4' x1='100%' y1='16.6%' x2='100%' y2='100%'",
			" gradientUnits='userSpaceOnUse' xmlns='http://www.w3.org/2000/svg'>",
			"<stop stop-color='#fff' stop-opacity='0.38'/><stop offset='1' stop-color='#fff'",
			" stop-opacity='0.08'/></linearGradient>",
			"<linearGradient id='ROUNDED_BORDER_TIER_3' x1='100%' y1='16.6%' x2='100%' y2='100%'",
			" gradientUnits='userSpaceOnUse' xmlns='http://www.w3.org/2000/svg'>",
			"<stop stop-color='#fff' stop-opacity='0.38'/><stop offset='1' stop-color='#fff'",
			" stop-opacity='0.08'/></linearGradient>",
			"<linearGradient id='ROUNDED_BORDER_TIER_2' x1='100%' y1='16.6%' x2='100%' y2='100%'",
			" gradientUnits='userSpaceOnUse' xmlns='http://www.w3.org/2000/svg'>",
			"<stop stop-color='#fff' stop-opacity='0.38'/><stop offset='1' stop-color='#fff'",
			" stop-opacity='0.08'/></linearGradient>",
			"<linearGradient id='ROUNDED_BORDER_TIER_1' x1='100%' y1='16.6%' x2='100%' y2='100%'",
			" gradientUnits='userSpaceOnUse' xmlns='http://www.w3.org/2000/svg'>",
			"<stop stop-color='#fff' stop-opacity='0.38'/><stop offset='1' stop-color='#fff'",
			" stop-opacity='0.08'/></linearGradient>",
			"<pattern id='smallGrid' width='3' height='3' patternUnits='userSpaceOnUse' patternTransform='rotate(45 ",
			string(abi.encodePacked(scaledGridSizeString, " ", scaledGridSizeString)),
			")'><path d='M 3 0 L 0 0 0 3' fill='none' stroke-width='0.3%' stroke='#130A2A' stroke-opacity='0.2' />",
			"</pattern><symbol id='LANDMARK_TYPE_1' width='12' height='12'>",
			"<svg width='12' height='12' viewBox='0 0 14 14' fill='none' xmlns='http://www.w3.org/2000/svg'>",
			"<rect x='1.12' y='1' width='12' height='12' fill='url(#paint0_linear_2371_558677)' stroke='white' stroke-opacity='0.5'/>",
			"<rect x='4.72' y='4.59998' width='4.8' height='4.8' fill='url(#paint1_linear_2371_558677)'/>",
			"<rect x='4.72' y='4.59998' width='4.8' height='4.8' fill='white'/>",
			"<defs><linearGradient id='paint0_linear_2371_558677' x1='13.12' y1='1' x2='1.12' y2='13' gradientUnits='userSpaceOnUse'>",
			"<stop stop-color='#565656'/><stop offset='1'/></linearGradient>",
			"<linearGradient id='paint1_linear_2371_558677' x1='9.52' y1='4.59998' x2='4.72' y2='9.39998' gradientUnits='userSpaceOnUse'>",
			"<stop stop-color='#565656'/><stop offset='1'/></linearGradient></defs></svg></symbol>",
			"<symbol id='LANDMARK_TYPE_2' width='12' height='12'><svg width='12' height='12'",
			" viewBox='0 0 12 12' fill='none' xmlns='http://www.w3.org/2000/svg'>",
			"<rect x='1.12' y='1' width='10' height='10' fill='url(#paint0_linear_2371_558683)' stroke='white' stroke-opacity='0.5'/>",
			"<rect x='4.12' y='4' width='4' height='4' fill='url(#paint1_linear_2371_558683)'/>",
			"<rect x='4.12' y='4' width='4' height='4' fill='white'/>",
			"<rect x='3.62' y='3.5' width='5' height='5' stroke='black' stroke-opacity='0.1'/>",
			"<defs><linearGradient id='paint0_linear_2371_558683' x1='11.12' y1='1' x2='-0.862058' y2='7.11845'",
			" gradientUnits='userSpaceOnUse'>",
			"<stop stop-color='#8CD4D9'/><stop offset='1' stop-color='#598FA6'/></linearGradient>",
			"<linearGradient id='paint1_linear_2371_558683' x1='8.12' y1='4' x2='4.12' y2='8' gradientUnits='userSpaceOnUse'>",
			"<stop stop-color='#565656'/><stop offset='1'/></linearGradient></defs></svg></symbol>",
			"<symbol id='LANDMARK_TYPE_3' width='12' height='12'>",
			"<svg width='12' height='12' viewBox='0 0 12 12' fill='none' xmlns='http://www.w3.org/2000/svg'>",
			"<rect x='1.12' y='1' width='10' height='10' fill='url(#paint0_linear_2371_558686)' stroke='white' stroke-opacity='0.5'/>",
			"<rect x='4.12' y='4' width='4' height='4' fill='url(#paint1_linear_2371_558686)'/>",
			"<rect x='4.12' y='4' width='4' height='4' fill='white'/>",
			"<rect x='3.62' y='3.5' width='5' height='5' stroke='black' stroke-opacity='0.1'/>",
			"<defs><linearGradient id='paint0_linear_2371_558686' x1='11.12' y1='1' x2='1.12' y2='11' gradientUnits='userSpaceOnUse'>",
			"<stop stop-color='#CBE2FF'/><stop offset='1' stop-color='#EFEFEF'/></linearGradient>",
			"<linearGradient id='paint1_linear_2371_558686' x1='8.12' y1='4' x2='4.12' y2='8' gradientUnits='userSpaceOnUse'>",
			"<stop stop-color='#565656'/><stop offset='1'/></linearGradient></defs></svg></symbol>",
			"<symbol id='LANDMARK_TYPE_4' width='12' height='12'>",
			"<svg width='12' height='12' viewBox='0 0 12 12' fill='none' xmlns='http://www.w3.org/2000/svg'>",
			"<rect x='1.12' y='1' width='10' height='10' fill='url(#paint0_linear_2371_558689)' stroke='white' stroke-opacity='0.5'/>",
			"<rect x='4.12' y='4' width='4' height='4' fill='url(#paint1_linear_2371_558689)'/>",
			"<rect x='4.12' y='4' width='4' height='4' fill='white'/>",
			"<rect x='3.62' y='3.5' width='5' height='5' stroke='black' stroke-opacity='0.1'/>",
			"<defs><linearGradient id='paint0_linear_2371_558689' x1='11.12' y1='1' x2='1.12' y2='11' gradientUnits='userSpaceOnUse'>",
			"<stop stop-color='#184B00'/><stop offset='1' stop-color='#52FF00'/></linearGradient>",
			"<linearGradient id='paint1_linear_2371_558689' x1='8.12' y1='4' x2='4.12' y2='8' gradientUnits='userSpaceOnUse'>",
			"<stop stop-color='#565656'/><stop offset='1'/></linearGradient></defs></svg></symbol>",
			"<symbol id='LANDMARK_TYPE_5' width='12' height='12'>",
			"<svg width='12' height='12' viewBox='0 0 12 12' fill='none' xmlns='http://www.w3.org/2000/svg'>",
			"<rect x='1.12' y='1' width='10' height='10' fill='url(#paint0_linear_2371_558695)' stroke='white' stroke-opacity='0.5'/>",
			"<rect x='4.12' y='4' width='4' height='4' fill='url(#paint1_linear_2371_558695)'/>",
			"<rect x='4.12' y='4' width='4' height='4' fill='white'/>",
			"<rect x='3.62' y='3.5' width='5' height='5' stroke='black' stroke-opacity='0.1'/>",
			"<defs><linearGradient id='paint0_linear_2371_558695' x1='11.12' y1='1' x2='1.12' y2='11' gradientUnits='userSpaceOnUse'>",
			"<stop stop-color='#31F27F'/><stop offset='0.296875' stop-color='#F4BE86'/><stop offset='0.578125' stop-color='#B26FD2'/>",
			"<stop offset='0.734375' stop-color='#7F70D2'/><stop offset='1' stop-color='#8278F2'/></linearGradient>",
			"<linearGradient id='paint1_linear_2371_558695' x1='8.12' y1='4' x2='4.12' y2='8' gradientUnits='userSpaceOnUse'>",
			"<stop stop-color='#565656'/><stop offset='1'/></linearGradient></defs></svg></symbol>",
			"<symbol id='LANDMARK_TYPE_6' width='12' height='12'>",
			"<svg width='12' height='12' viewBox='0 0 12 12' fill='none' xmlns='http://www.w3.org/2000/svg'>",
			"<rect x='1.12' y='1' width='10' height='10' fill='url(#paint0_linear_2371_558692)' stroke='white' stroke-opacity='0.5'/>",
			"<rect x='4.12' y='4' width='4' height='4' fill='url(#paint1_linear_2371_558692)'/>",
			"<rect x='4.12' y='4' width='4' height='4' fill='white'/>",
			"<rect x='3.62' y='3.5' width='5' height='5' stroke='black' stroke-opacity='0.1'/>",
			"<defs><linearGradient id='paint0_linear_2371_558692' x1='11.12' y1='1' x2='1.11999' y2='11' gradientUnits='userSpaceOnUse'>",
			"<stop stop-color='white'/><stop offset='0.544585' stop-color='#FFD600'/><stop offset='1' stop-color='#FF9900'/></linearGradient>",
			"<linearGradient id='paint1_linear_2371_558692' x1='8.12' y1='4' x2='4.12' y2='8' gradientUnits='userSpaceOnUse'>",
			"<stop stop-color='#565656'/><stop offset='1'/></linearGradient></defs></svg></symbol>",
			"<symbol id='LANDMARK_TYPE_7' width='12' height='12'>",
			"<svg width='12' height='12' viewBox='0 0 12 12' fill='none' xmlns='http://www.w3.org/2000/svg'>",
			"<rect x='1.12' y='1' width='10' height='10' fill='url(#paint0_linear_2373_559424)' stroke='white' stroke-opacity='0.5'/>",
			"<rect x='3.12' y='3' width='6' height='6' fill='url(#paint1_linear_2373_559424)'/>",
			"<rect x='3.12' y='3' width='6' height='6' fill='white'/>",
			"<rect x='2.62' y='2.5' width='7' height='7' stroke='black' stroke-opacity='0.1'/>",
			"<defs><linearGradient id='paint0_linear_2373_559424' x1='11.12' y1='1' x2='1.11999' y2='11' gradientUnits='userSpaceOnUse'>",
			"<stop stop-color='#08CE01'/><stop offset='0.171875' stop-color='#CEEF00'/><stop offset='0.34375' stop-color='#51F980'/>",
			"<stop offset='0.5' stop-color='#2D51ED'/><stop offset='0.671875' stop-color='#0060F1'/>",
			"<stop offset='0.833333' stop-color='#F100D9'/>",
			"<stop offset='1' stop-color='#9A24EC'/></linearGradient>",
			"<linearGradient id='paint1_linear_2373_559424' x1='9.12' y1='3' x2='3.12' y2='9' gradientUnits='userSpaceOnUse'>",
			"<stop stop-color='#565656'/><stop offset='1'/></linearGradient></defs></svg></symbol>",
			"</defs><rect width='100%' height='100%' fill='url(#GRADIENT_BOARD_TIER_",
			uint256(_tierId).toString(), // This line should be replaced in the loop
			")' stroke='none' rx='5%' ry='5%'/><svg x='",
			_gridSize % 2 == 0 
				? "-17%' y='-17%' width='117%' height='116.4%' ><g transform='scale(1.34)'"
					" rx='5%' ry='5%' ><rect x='11%' y='11.2%' width='63.6%' height='63.8%"
				: "-18%' y='-18%' width='117.8%' height='117.8%' ><g transform='scale(1.34)'"
					" rx='5%' ry='5%' ><rect x='11.6%' y='11.6%' width='63.0%' height='63.2%",
			"' fill='url(#smallGrid)' stroke='none'  rx='3%' ry='3%' /><g transform='rotate(45 ",
			scaledGridSizeString,
			" ",
			scaledGridSizeString,
			")'>",
			_generateLandmarkSvg(_gridSize, _landmarkTypeId), // Generate LandMark SVG
			_generateSites(_sites), // Generate Sites SVG
			"</g></g></svg>",
			"<rect xmlns='http://www.w3.org/2000/svg' x='0.3' y='0.3'", 
			" width='99.7%' height='99.7%' fill='none' stroke='url(#ROUNDED_BORDER_TIER_",
			uint256(_tierId).toString(),
			")' stroke-width='1' rx='4.5%' ry='4.5%'/></svg>"
		];
	}

	function _generateLandBoard(
		uint16 _gridSize, 
		uint8 _tierId, 
		uint8 _landmarkTypeId, 
		LandLib.Site[] memory _sites
	) private pure returns(string memory) {

		string[170] memory landBoardArray_ = _landBoardArray(
			_gridSize, 
			_tierId, 
			_landmarkTypeId, 
			_sites
		);
		bytes memory landBoardBytes;
		for (uint8 i = 0; i < landBoardArray_.length; i++) {
			landBoardBytes = abi.encodePacked(landBoardBytes, landBoardArray_[i]);
		}

		return string(landBoardBytes);
	}

	function generateLandName(uint8 _regionId, uint16 _x, uint16 _y) internal pure returns (string memory) {

		string memory region;
		if (_regionId == 1) {
			region = "Taiga Boreal";
		} else if (_regionId == 2) {
			region = "Crystal Shores";
		} else if (_regionId == 3) {
			region = "Shardbluff Labyrinth";
		} else if (_regionId == 4) {
			region = "Abyssal Basin";
		} else if (_regionId == 5) {
			region = "Crimson Waste";
		} else if (_regionId == 6) {
			region = "Brightland Steppes";
		} else if (_regionId == 7) {
			region = "Halcyon Sea";
		} else {
			revert("Invalid region ID");
		}
		return string(
			abi.encodePacked(
				region,
				" (",
				uint256(_x).toString(),
				", ",
				uint256(_y).toString(),
				")"
			)
		);
	}

	function generateLandDescription() internal pure returns (string memory) {

		return "Illuvium Land is a digital piece of real estate in the Illuvium universe that players can mine for fuels through Illuvium Zero. "
			"Fuels are ERC-20 tokens that are used in Illuvium games and can be traded on the marketplace. Higher-tiered lands produce more fuel."
			"\\n\\nLearn more about Illuvium Land at illuvidex.illuvium.io/land.";
	}

	function _generateSites(LandLib.Site[] memory _sites) private pure returns (string memory) {

		bytes memory _siteSvgBytes;
		for (uint256 i = 0; i < _sites.length; i++) {
			_siteSvgBytes = abi.encodePacked(
				_siteSvgBytes,
				_siteBaseSvg(
					convertToSvgPositionX(_sites[i].x),
					convertToSvgPositionY(_sites[i].y),
					_sites[i].typeId
				)
			);
		}

		return string(_siteSvgBytes);
	}

	function constructTokenURI(
		uint8 _regionId,
		uint16 _x,
		uint16 _y,
		uint8 _tierId,
		uint16 _gridSize,
		uint8 _landmarkTypeId,
		LandLib.Site[] memory _sites
	) internal pure returns (string memory) {

		string memory name = generateLandName(_regionId, _x, _y);
		string memory description = generateLandDescription();
		string memory image = Base64.encode(
			bytes(
				_generateSVGImage(
					_gridSize, 
					_tierId,
					_landmarkTypeId,
					_sites
				)
			)
		);

		return string(
			abi.encodePacked("data:application/json;base64, ", Base64.encode(
				bytes(
					abi.encodePacked('{"name":"',
					name,
					'", "description":"',
					description,
					'", "image": "',
					'data:image/svg+xml;base64,',
					image,
					'"}')
				)
			)
			)
		);
	}

	function convertToSvgPositionX(uint16 _positionX) private pure returns (uint16) {

		return _positionX * 3;
	}

	function convertToSvgPositionY(uint16 _positionY) private pure returns (uint16) {

		return _positionY * 3;
	}
}// MIT
pragma solidity ^0.8.4;


contract LandDescriptorImpl is LandDescriptor {

	function tokenURI(uint256 _tokenId) public view virtual override returns (string memory) {

		LandLib.PlotView memory _plot = LandERC721Metadata(msg.sender).viewMetadata(_tokenId);

		return LandSvgLib.constructTokenURI(
			_plot.regionId,
			_plot.x,
			_plot.y,
			_plot.tierId,
			_plot.size,
			_plot.landmarkTypeId,
			_plot.sites
		);
	}
}