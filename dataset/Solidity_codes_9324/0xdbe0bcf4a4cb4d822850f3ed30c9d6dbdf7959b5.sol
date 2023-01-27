
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
}// UNLICENSED
pragma solidity >=0.8.0 <0.9.0;


contract Mandelbrot is Ownable {

    uint256 private constant PRECISION = 125;

    uint256 private constant PRECISION_PLUS_2 = 127;

    int256 public constant ONE = 2**125;

    int256 private constant TWO = 2**126;

    int256 private constant FOUR = 2**127;

    int256 private constant POINT_FOUR = 0xccccccccccccccccccccccccccccccc;

    int256 private constant QUARTER = 2**123;
    int256 private constant EIGHTH = 2**122;
    int256 private constant SIXTEENTH = 2**121;
    int256 private constant NEG_THREE_QUARTERS = 2**123 - 2**125;
    int256 private constant NEG_ONE_PT_TWO_FIVE = -(2**123 + 2**125);

    int256 public constant NEG_TWO = -TWO;

    enum Fractal {
        Mandelbrot,
        Mandelbar,
        Multi3,
        BurningShip,

        INVALID
    }

    struct Patch {
        int256 minReal;
        int256 minImaginary;
        int256 width;
        int256 height;
        int16 zoomLog2;
        uint8 maxIterations;
        Fractal fractal;
    }

    function patchPixels(Patch memory patch) public pure returns (bytes memory) {

        require(patch.width > 0, "Non-positive width");
        require(patch.height > 0, "Non-positive height");
        require(patch.zoomLog2 > 0, "Non-positive zoom");
        require(patch.fractal < Fractal.INVALID, "Unsupported fractal");

        int256 pixelWidth;
        {
            int16 zoomLog2 = patch.zoomLog2;
            assembly { pixelWidth := shl(sub(PRECISION_PLUS_2, zoomLog2), 1) }
        }
        int256 maxRe = patch.minReal + pixelWidth*patch.width;
        int256 maxIm = patch.minImaginary + pixelWidth*patch.height;

        if (patch.fractal == Fractal.Mandelbrot) {
            return _mandelbrot(patch, pixelWidth, maxRe, maxIm);
        } else if (patch.fractal == Fractal.Mandelbar) {
            return _mandelbar(patch, pixelWidth, maxRe, maxIm);
        } else if (patch.fractal == Fractal.Multi3) {
            return _multi3(patch, pixelWidth, maxRe, maxIm);
        } else if (patch.fractal == Fractal.BurningShip) {
            return _burningShip(patch, pixelWidth, maxRe, maxIm);
        }
        return new bytes(0);
    }

    function _mandelbrot(Patch memory patch, int256 pixelWidth, int256 maxRe, int256 maxIm) internal pure returns (bytes memory) {

        bytes memory pixels = new bytes(uint256(patch.width * patch.height));
        
        int256 zRe;
        int256 zIm;
        int256 reSq;
        int256 imSq;

        uint8 maxIters  = patch.maxIterations;
        uint256 pixelIdx = 0;
        for (int256 cIm = patch.minImaginary; cIm < maxIm; cIm += pixelWidth) {
            for (int256 cRe = patch.minReal; cRe < maxRe; cRe += pixelWidth) {


                if (cRe >= NEG_THREE_QUARTERS && cRe < POINT_FOUR) {
                    zRe = cRe - QUARTER;
                    zIm = cIm;
                    assembly {
                        reSq := shr(PRECISION, mul(zRe, zRe)) // (x - 1/4)^2
                        imSq := shr(PRECISION, mul(zIm, zIm)) // y^2
                        zIm := add(reSq, imSq) // q
                        zRe := add(zRe, zIm) // q + x - 1/4
                        zRe := sar(PRECISION, mul(zRe, zIm)) // q(q + x - 1/4)
                        imSq := shr(2, imSq) // y^2/4
                    }
                    if (zRe <= imSq) {
                        pixelIdx++;
                        continue;
                    }
                }
                
                if (cRe <= NEG_THREE_QUARTERS && cRe >= NEG_ONE_PT_TWO_FIVE) {
                    zRe = cRe + ONE;
                    zIm = cIm;
                    assembly {
                        reSq := shr(PRECISION, mul(zRe, zRe))
                        imSq := shr(PRECISION, mul(zIm, zIm))
                    }
                    if (reSq + imSq <= SIXTEENTH) {
                        pixelIdx++;
                        continue;
                    }
                }


                zRe = cRe;
                zIm = cIm;
                uint8 pixelVal;
                assembly {
                    for { let i := 0 } lt(i, maxIters) { i := add(i, 1) } {
                        reSq := shr(PRECISION, mul(zRe, zRe))
                        imSq := shr(PRECISION, mul(zIm, zIm))
                        
                        if gt(add(reSq, imSq), FOUR) {
                            pixelVal := sub(maxIters, i)
                            i := maxIters
                        }

                        zIm := add(cIm, sar(PRECISION, mul(add(zRe, zRe), zIm)))
                        zRe := add(cRe, sub(reSq, imSq))

                    } // for maxIters
                } // assembly

                pixels[pixelIdx] = bytes1(pixelVal);
                pixelIdx++;

            } // for cIm
        } // for cRe

        return pixels;
    }

    function _mandelbar(Patch memory patch, int256 pixelWidth, int256 maxRe, int256 maxIm) internal pure returns (bytes memory) {
        bytes memory pixels = new bytes(uint256(patch.width * patch.height));
        
        int256 zRe;
        int256 zIm;
        int256 reSq;
        int256 imSq;

        uint8 maxIters  = patch.maxIterations;
        uint256 pixelIdx = 0;
        for (int256 cIm = patch.minImaginary; cIm < maxIm; cIm += pixelWidth) {
            for (int256 cRe = patch.minReal; cRe < maxRe; cRe += pixelWidth) {

                zRe = cRe;
                zIm = -cIm;
                uint8 pixelVal;
                assembly {
                    for { let i := 0 } lt(i, maxIters) { i := add(i, 1) } {
                        reSq := shr(PRECISION, mul(zRe, zRe))
                        imSq := shr(PRECISION, mul(zIm, zIm))
                        
                        if gt(add(reSq, imSq), FOUR) {
                            pixelVal := sub(maxIters, i)
                            i := maxIters
                        }

                        zIm := sub(0, add(cIm, sar(PRECISION, mul(add(zRe, zRe), zIm))))
                        zRe := add(cRe, sub(reSq, imSq))

                    } // for maxIters
                } // assembly

                pixels[pixelIdx] = bytes1(pixelVal);
                pixelIdx++;

            } // for cIm
        } // for cRe

        return pixels;
    }

    function _multi3(Patch memory patch, int256 pixelWidth, int256 maxRe, int256 maxIm) internal pure returns (bytes memory) {
        bytes memory pixels = new bytes(uint256(patch.width * patch.height));
        
        int256 zRe;
        int256 zIm;
        int256 reSq;
        int256 imSq;

        uint8 maxIters  = patch.maxIterations;
        uint256 pixelIdx = 0;
        for (int256 cIm = patch.minImaginary; cIm < maxIm; cIm += pixelWidth) {
            for (int256 cRe = patch.minReal; cRe < maxRe; cRe += pixelWidth) {

                assembly {
                    reSq := shr(PRECISION, mul(cRe, cRe))
                    imSq := shr(PRECISION, mul(cIm, cIm))
                    reSq := add(reSq, imSq) // |z^2|
                }
                if (reSq > FOUR) {
                    pixels[pixelIdx] = bytes1(maxIters);
                    pixelIdx++;
                    continue;
                } else if (reSq < EIGHTH) {
                    pixelIdx++;
                    continue;
                }


                zRe = cRe;
                zIm = cIm;
                uint8 pixelVal;
                assembly {
                    for { let i := 0 } lt(i, maxIters) { i := add(i, 1) } {
                        reSq := shr(PRECISION, mul(zRe, zRe))
                        imSq := shr(PRECISION, mul(zIm, zIm))

                        zIm := sar(PRECISION, mul(add(zRe, zRe), zIm))
                        zRe := sub(reSq, imSq)
                        
                        reSq := shr(PRECISION, mul(zRe, zRe))
                        imSq := shr(PRECISION, mul(zIm, zIm))

                        if gt(add(reSq, imSq), FOUR) {
                            pixelVal := sub(maxIters, i)
                            i := maxIters
                        }

                        zIm := add(cIm, sar(PRECISION, mul(add(zRe, zRe), zIm)))
                        zRe := add(cRe, sub(reSq, imSq))

                    } // for maxIters
                } // assembly

                pixels[pixelIdx] = bytes1(pixelVal);
                pixelIdx++;

            } // for cIm
        } // for cRe

        return pixels;
    }

    function _burningShip(Patch memory patch, int256 pixelWidth, int256 maxRe, int256 maxIm) internal pure returns (bytes memory) {
        bytes memory pixels = new bytes(uint256(patch.width * patch.height));
        
        int256 zRe;
        int256 zIm;
        int256 reSq;
        int256 imSq;

        uint8 maxIters  = patch.maxIterations;
        uint256 pixelIdx = 0;
        for (int256 cIm = maxIm - pixelWidth; cIm >= patch.minImaginary; cIm -= pixelWidth) {
            for (int256 cRe = maxRe - pixelWidth; cRe >= patch.minReal; cRe -= pixelWidth) {
                zRe = cRe;
                zIm = cIm;
                uint8 pixelVal;
                assembly {
                    for { let i := 0 } lt(i, maxIters) { i := add(i, 1) } {
                        reSq := shr(PRECISION, mul(zRe, zRe))
                        imSq := shr(PRECISION, mul(zIm, zIm))
                        
                        if gt(add(reSq, imSq), FOUR) {
                            pixelVal := sub(maxIters, i)
                            i := maxIters
                        }

                        zIm := add(cIm, sar(PRECISION, mul(add(zRe, zRe), zIm)))
                        zRe := add(cRe, sub(reSq, imSq))

                        if slt(zRe, 0) {
                            zRe := sub(0, zRe)
                        }
                        if slt(zIm, 0) {
                            zIm := sub(0, zIm)
                        }
                    } // for maxIters
                } // assembly

                pixels[pixelIdx] = bytes1(pixelVal);
                pixelIdx++;

            } // for cIm
        } // for cRe

        return pixels;
    }

    struct CachedPatch {
        bytes pixels;
        Patch patch;
    }

    mapping(uint256 => CachedPatch) public patchCache;

    function patchCacheKey(Patch memory patch) public pure returns (uint256) {
        return uint256(keccak256(abi.encode(patch)));
    }

    function cachePatch(bytes memory pixels, Patch memory patch) public onlyOwner {
        require(pixels.length == uint256(patch.width * patch.height), "Invalid dimensions");
        patchCache[patchCacheKey(patch)] = CachedPatch(pixels, patch);
    }

    function cachedPatch(uint256 cacheIdx) public view returns (CachedPatch memory) {
        CachedPatch memory cached = patchCache[cacheIdx];
        require(cached.patch.width > 0 && cached.patch.height > 0, "Patch not cached");
        return cached;
    }

    function verifyCachedPatch(uint256 cacheIdx) public view returns (bool) {
        CachedPatch memory cached = cachedPatch(cacheIdx);
        bytes memory fresh = patchPixels(cached.patch);
        return keccak256(fresh) == keccak256(cached.pixels);
    }

    function concatenatePatches(uint256[] memory patches) public view returns (bytes memory) {
        CachedPatch[] memory cached = new CachedPatch[](patches.length);

        uint256 len;
        for (uint i = 0; i < patches.length; i++) {
            cached[i] = cachedPatch(patches[i]);
            len += cached[i].pixels.length;
        }

        bytes memory buf = new bytes(len);
        uint idx;
        for (uint i = 0; i < cached.length; i++) {
            for (uint j = 0; j < cached[i].pixels.length; j++) {
                buf[idx] = cached[i].pixels[j];
                idx++;
            }
        }
        return buf;
    }
}