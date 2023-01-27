
pragma solidity ^0.8.0;

library AddressUpgradeable {

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


abstract contract Initializable {
    bool private _initialized;

    bool private _initializing;

    modifier initializer() {
        require(_initializing ? _isConstructor() : !_initialized, "Initializable: contract is already initialized");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }

    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    function _isConstructor() private view returns (bool) {
        return !AddressUpgradeable.isContract(address(this));
    }
}// MIT

pragma solidity ^0.8.0;

interface IERC165Upgradeable {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}// MIT

pragma solidity ^0.8.0;


interface IERC1155Upgradeable is IERC165Upgradeable {

    event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value);

    event TransferBatch(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256[] ids,
        uint256[] values
    );

    event ApprovalForAll(address indexed account, address indexed operator, bool approved);

    event URI(string value, uint256 indexed id);

    function balanceOf(address account, uint256 id) external view returns (uint256);


    function balanceOfBatch(address[] calldata accounts, uint256[] calldata ids)
        external
        view
        returns (uint256[] memory);


    function setApprovalForAll(address operator, bool approved) external;


    function isApprovedForAll(address account, address operator) external view returns (bool);


    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes calldata data
    ) external;


    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] calldata ids,
        uint256[] calldata amounts,
        bytes calldata data
    ) external;

}// MIT

pragma solidity ^0.8.0;


interface IERC721Upgradeable is IERC165Upgradeable {

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


interface IERC1155ReceiverUpgradeable is IERC165Upgradeable {

    function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes calldata data
    ) external returns (bytes4);


    function onERC1155BatchReceived(
        address operator,
        address from,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    ) external returns (bytes4);

}// MIT

pragma solidity ^0.8.0;


abstract contract ERC165Upgradeable is Initializable, IERC165Upgradeable {
    function __ERC165_init() internal onlyInitializing {
        __ERC165_init_unchained();
    }

    function __ERC165_init_unchained() internal onlyInitializing {
    }
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165Upgradeable).interfaceId;
    }
    uint256[50] private __gap;
}// MIT

pragma solidity ^0.8.0;


abstract contract ERC1155ReceiverUpgradeable is Initializable, ERC165Upgradeable, IERC1155ReceiverUpgradeable {
    function __ERC1155Receiver_init() internal onlyInitializing {
        __ERC165_init_unchained();
        __ERC1155Receiver_init_unchained();
    }

    function __ERC1155Receiver_init_unchained() internal onlyInitializing {
    }
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165Upgradeable, IERC165Upgradeable) returns (bool) {
        return interfaceId == type(IERC1155ReceiverUpgradeable).interfaceId || super.supportsInterface(interfaceId);
    }
    uint256[50] private __gap;
}// MIT

pragma solidity ^0.8.0;


contract ERC1155HolderUpgradeable is Initializable, ERC1155ReceiverUpgradeable {

    function __ERC1155Holder_init() internal onlyInitializing {

        __ERC165_init_unchained();
        __ERC1155Receiver_init_unchained();
        __ERC1155Holder_init_unchained();
    }

    function __ERC1155Holder_init_unchained() internal onlyInitializing {

    }
    function onERC1155Received(
        address,
        address,
        uint256,
        uint256,
        bytes memory
    ) public virtual override returns (bytes4) {

        return this.onERC1155Received.selector;
    }

    function onERC1155BatchReceived(
        address,
        address,
        uint256[] memory,
        uint256[] memory,
        bytes memory
    ) public virtual override returns (bytes4) {

        return this.onERC1155BatchReceived.selector;
    }
    uint256[50] private __gap;
}// MIT

pragma solidity ^0.8.0;

interface IERC721ReceiverUpgradeable {

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);

}// MIT

pragma solidity ^0.8.0;


contract ERC721HolderUpgradeable is Initializable, IERC721ReceiverUpgradeable {

    function __ERC721Holder_init() internal onlyInitializing {

        __ERC721Holder_init_unchained();
    }

    function __ERC721Holder_init_unchained() internal onlyInitializing {

    }
    function onERC721Received(
        address,
        address,
        uint256,
        bytes memory
    ) public virtual override returns (bytes4) {

        return this.onERC721Received.selector;
    }
    uint256[50] private __gap;
}// MIT

pragma solidity ^0.8.0;

abstract contract ReentrancyGuardUpgradeable is Initializable {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    function __ReentrancyGuard_init() internal onlyInitializing {
        __ReentrancyGuard_init_unchained();
    }

    function __ReentrancyGuard_init_unchained() internal onlyInitializing {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
    }
    uint256[49] private __gap;
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
}//Unlicense

pragma solidity ^0.8.0;

library Collections {

    struct LinkedList {
        mapping(uint256 => uint256) nodeToValue;
        mapping(uint256 => uint256) nodeLinks;
    }

    function addNode(
        LinkedList storage self,
        uint256 id,
        uint256 value
    ) internal {

        self.nodeToValue[id] = value;
        if (self.nodeLinks[0] == 0) {
            self.nodeLinks[0] = id;
            return;
        }

        uint256 lastNodeId = 0;
        uint256 currentNodeId = self.nodeLinks[0];
        while (currentNodeId != 0) {
            uint256 currentNodeValue = self.nodeToValue[currentNodeId];
            if (value < currentNodeValue) {
                self.nodeLinks[lastNodeId] = id;
                self.nodeLinks[id] = currentNodeId;
                return;
            }
            uint256 nextNodeId = self.nodeLinks[currentNodeId];
            lastNodeId = currentNodeId;
            currentNodeId = nextNodeId;
        }

        self.nodeLinks[lastNodeId] = id;
    }

    function removeNode(LinkedList storage self, uint256 id) internal {

        uint256 lastNodeId = 0;
        uint256 currentNodeId = self.nodeLinks[0];
        while (currentNodeId != 0) {
            uint256 nextNodeId = self.nodeLinks[currentNodeId];
            if (currentNodeId == id) {
                self.nodeLinks[lastNodeId] = nextNodeId;
                delete self.nodeLinks[id];
                break;
            }
            currentNodeId = nextNodeId;
        }
    }
}//Unlicense

pragma solidity ^0.8.0;


contract AdminManagerUpgradable is Initializable {

    mapping(address => bool) private _admins;

    function __AdminManager_init() internal onlyInitializing {

        _admins[msg.sender] = true;
    }

    function setAdminPermissions(address account, bool enable)
        external
        onlyAdmin
    {

        _admins[account] = enable;
    }

    modifier onlyAdmin() {

        require(_admins[msg.sender], "Not an admin");
        _;
    }

    uint256[49] private __gap;
}// MIT

pragma solidity ^0.8.0;

interface IERC20Upgradeable {

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
}//Unlicense

pragma solidity ^0.8.0;


interface IRaks is IERC20Upgradeable {

    function mint(address account, uint256 amount) external;


    function burn(address account, uint256 amount) external;

}//Unlicense

pragma solidity ^0.8.0;

interface IDeclareCoreTraits {

    struct CoreTraits {
        uint32 size;
        uint32 thc;
        uint32 terpenes;
        uint32 deathTime;
    }
}//Unlicense

pragma solidity ^0.8.0;


interface IStrainLike is IERC721Upgradeable, IDeclareCoreTraits {

    function coreTraits(uint256 id) external view returns (CoreTraits memory);


    function burn(uint256 id) external;

}//Unlicense

pragma solidity ^0.8.0;


interface IBredStrain is IStrainLike {

    function bredSupply() external returns (uint256);


    function breedMint(
        address account,
        uint256 seedId,
        CoreTraits memory traits
    ) external;

}//Unlicense

pragma solidity ^0.8.0;


contract Staking is
    Initializable,
    ERC1155HolderUpgradeable,
    ERC721HolderUpgradeable,
    ReentrancyGuardUpgradeable,
    AdminManagerUpgradable
{

    using PRBMathUD60x18 for uint256;
    using Collections for Collections.LinkedList;

    uint256 public constant PLOT_ID = 0;

    IERC1155Upgradeable _plotToken;
    IERC721Upgradeable _strainToken;
    IBredStrain _bredStrainToken;
    IRaks _raksToken;

    uint256 private _baseCapacity;
    uint256 private _plotCapacity;
    uint256 private _accrualTime;

    struct StakerData {
        uint256 plotBalances;
        uint256 strainBalances;
        uint256 claims;
        uint256 lastClaims;
        Collections.LinkedList pendingClaims;
    }

    mapping(uint256 => address) private _strainOwners;
    mapping(uint256 => address) private _bredStrainOwners;
    mapping(address => StakerData) private _stakersData;
    mapping(uint256 => uint256) private _raksPerSecondCache;
    mapping(uint256 => bool) _spentBredStrains;

    event Stake(
        address indexed account,
        uint256 plotsAmount,
        uint256[] strainIds,
        uint256[] bredStrainIds
    );

    event Withdraw(
        address indexed account,
        uint256 plotsAmount,
        uint256[] strainIds,
        uint256[] bredStrainIds
    );

    event Burn(address indexed account, uint256 strainId);

    event Claim(address indexed account);

    bool private _paused;

    function initialize(
        address plotToken,
        address strainToken,
        address bredStrainToken,
        address raksToken
    ) public initializer {

        __ERC1155Holder_init();
        __ERC721Holder_init();
        __ReentrancyGuard_init();
        __AdminManager_init();
        _plotToken = IERC1155Upgradeable(plotToken);
        _strainToken = IERC721Upgradeable(strainToken);
        _bredStrainToken = IBredStrain(bredStrainToken);
        _raksToken = IRaks(raksToken);
        _baseCapacity = 5;
        _plotCapacity = 5;
        _accrualTime = 10 days;
        _raksPerSecondCache[1] = _calculateRaksPerSecond(1);
        _raksPerSecondCache[2] = _calculateRaksPerSecond(2);
        _raksPerSecondCache[3] = _calculateRaksPerSecond(3);
        _raksPerSecondCache[4] = _calculateRaksPerSecond(4);
        _raksPerSecondCache[5] = _calculateRaksPerSecond(5);
        _raksPerSecondCache[6] = _calculateRaksPerSecond(6);
        _raksPerSecondCache[7] = _calculateRaksPerSecond(7);
        _raksPerSecondCache[8] = _calculateRaksPerSecond(8);
        _raksPerSecondCache[9] = _calculateRaksPerSecond(9);
        _raksPerSecondCache[10] = _calculateRaksPerSecond(10);
    }

    function stake(
        uint256 plotsAmount,
        uint256[] memory strainIds,
        uint256[] memory bredStrainIds
    ) external whenNotPaused nonReentrant {

        uint256 amount = strainIds.length + bredStrainIds.length;
        require(
            _getCapacity(_stakersData[msg.sender].plotBalances + plotsAmount) >=
                _stakersData[msg.sender].strainBalances + amount,
            "Not enough space in plots"
        );
        _stakePlots(plotsAmount);
        _stakeStrains(strainIds);
        _stakeBredStrains(bredStrainIds);
        _updateClaims();
        _stakersData[msg.sender].plotBalances += plotsAmount;
        _stakersData[msg.sender].strainBalances += amount;
        emit Stake(msg.sender, plotsAmount, strainIds, bredStrainIds);
    }

    function _stakePlots(uint256 amount) internal {

        if (amount > 0) {
            _plotToken.safeTransferFrom(
                msg.sender,
                address(this),
                PLOT_ID,
                amount,
                ""
            );
        }
    }

    function _stakeStrains(uint256[] memory strainIds) internal {

        uint256 amount = strainIds.length;
        for (uint256 i = 0; i < amount; i++) {
            _strainToken.safeTransferFrom(
                msg.sender,
                address(this),
                strainIds[i]
            );
            _strainOwners[strainIds[i]] = msg.sender;
        }
    }

    function _stakeBredStrains(uint256[] memory bredStrainIds) internal {

        uint256 amount = bredStrainIds.length;
        for (uint256 i = 0; i < amount; i++) {
            require(
                !_spentBredStrains[bredStrainIds[i]],
                "Staking a spent strain"
            );
            _bredStrainToken.safeTransferFrom(
                msg.sender,
                address(this),
                bredStrainIds[i]
            );
            _bredStrainOwners[bredStrainIds[i]] = msg.sender;
            _stakersData[msg.sender].pendingClaims.addNode(
                bredStrainIds[i],
                block.timestamp + _accrualTime
            );
        }
    }

    function withdraw(
        uint256 plotsAmount,
        uint256[] memory strainIds,
        uint256[] memory bredStrainIds
    ) external whenNotPaused nonReentrant {

        uint256 amount = strainIds.length + bredStrainIds.length;
        require(
            _stakersData[msg.sender].plotBalances >= plotsAmount,
            "Not enough plots staked"
        );
        require(
            _stakersData[msg.sender].strainBalances >= amount,
            "Not enough strains staked"
        );
        require(
            _getCapacity(_stakersData[msg.sender].plotBalances - plotsAmount) >=
                _stakersData[msg.sender].strainBalances - amount,
            "Plots are currently in use"
        );
        _withdrawPlots(plotsAmount);
        _withdrawStrains(strainIds);
        _withdrawBredStrains(bredStrainIds);
        _updateClaims();
        _stakersData[msg.sender].plotBalances -= plotsAmount;
        _stakersData[msg.sender].strainBalances -= strainIds.length;
        emit Withdraw(msg.sender, plotsAmount, strainIds, bredStrainIds);
    }

    function _withdrawPlots(uint256 amount) internal {

        if (amount > 0) {
            _plotToken.safeTransferFrom(
                address(this),
                msg.sender,
                PLOT_ID,
                amount,
                ""
            );
        }
    }

    function _withdrawStrains(uint256[] memory strainIds) internal {

        uint256 amount = strainIds.length;
        for (uint256 i = 0; i < amount; i++) {
            require(
                _strainOwners[strainIds[i]] == msg.sender,
                "Not original owner"
            );
            delete _strainOwners[strainIds[i]];
            _strainToken.safeTransferFrom(
                address(this),
                msg.sender,
                strainIds[i]
            );
        }
    }

    function _withdrawBredStrains(uint256[] memory bredStrainIds) internal {

        uint256 amount = bredStrainIds.length;
        for (uint256 i = 0; i < amount; i++) {
            require(
                _bredStrainOwners[bredStrainIds[i]] == msg.sender,
                "Not original owner"
            );
            require(
                _stakersData[msg.sender].pendingClaims.nodeToValue[
                    bredStrainIds[i]
                ] <= block.timestamp,
                "Strain not fully spent"
            );
            _spentBredStrains[bredStrainIds[i]] = true;
            delete _bredStrainOwners[bredStrainIds[i]];
            _bredStrainToken.safeTransferFrom(
                address(this),
                msg.sender,
                bredStrainIds[i]
            );
        }
    }

    function claim() external whenNotPaused nonReentrant {

        _updateClaims();
        _raksToken.mint(
            msg.sender,
            PRBMathUD60x18.toUint(_stakersData[msg.sender].claims * 1e18)
        );
        _stakersData[msg.sender].claims = 0;
        emit Claim(msg.sender);
    }

    function ownerOf(uint256 strainId, uint8 strainType)
        public
        view
        returns (address)
    {

        if (strainType == 0) {
            return _strainOwners[strainId];
        }
        if (strainType == 1) {
            return _bredStrainOwners[strainId];
        }
        return address(0);
    }

    function burn(address account, uint256 strainId)
        external
        whenNotPaused
        onlyAdmin
    {

        require(ownerOf(strainId, 1) == account, "Not the owner");
        require(
            _stakersData[account].pendingClaims.nodeToValue[strainId] <=
                block.timestamp,
            "Strain not fully spent"
        );
        delete _bredStrainOwners[strainId];
        _bredStrainToken.burn(strainId);
        emit Burn(account, strainId);
    }

    function _updateClaims() private {

        Collections.LinkedList storage pendingClaims = _stakersData[msg.sender]
            .pendingClaims;
        uint256 currentNodeId = pendingClaims.nodeLinks[0];
        uint256 currentStrainBalance = _stakersData[msg.sender].strainBalances;
        uint256 currentClaims = _stakersData[msg.sender].claims;
        uint256 lastClaim = _stakersData[msg.sender].lastClaims;
        uint256 secondsElapsed;
        while (currentNodeId != 0) {
            uint256 nextNodeId = pendingClaims.nodeLinks[currentNodeId];
            if (pendingClaims.nodeToValue[currentNodeId] <= block.timestamp) {
                uint256 timestamp = pendingClaims.nodeToValue[currentNodeId];
                secondsElapsed = timestamp - lastClaim;
                currentClaims +=
                    _calculateRaksPerSecond(currentStrainBalance) *
                    secondsElapsed;
                lastClaim = timestamp;
                currentStrainBalance--;
                pendingClaims.removeNode(currentNodeId);
            } else {
                break;
            }
            currentNodeId = nextNodeId;
        }
        secondsElapsed = block.timestamp - lastClaim;
        currentClaims +=
            _calculateRaksPerSecond(currentStrainBalance) *
            secondsElapsed;
        _stakersData[msg.sender].strainBalances = currentStrainBalance;
        _stakersData[msg.sender].claims = currentClaims;
        _stakersData[msg.sender].lastClaims = block.timestamp;
    }

    function _calculateRaksPerSecond(uint256 number) private returns (uint256) {

        if (_raksPerSecondCache[number] != 0) {
            return _raksPerSecondCache[number];
        }
        uint256 result = PRBMathUD60x18
            .fromUint(number)
            .pow(1_100000000000000000)
            .div(PRBMathUD60x18.fromUint(864));
        _raksPerSecondCache[number] = result;
        return result;
    }

    function _getCapacity(uint256 plotsAmount) private view returns (uint256) {

        return plotsAmount * _plotCapacity + _baseCapacity;
    }

    function setBaseCapacity(uint256 baseCapacity) external onlyAdmin {

        _baseCapacity = baseCapacity;
    }

    function setPlotCapacity(uint256 plotCapacity) external onlyAdmin {

        _plotCapacity = plotCapacity;
    }

    function setAccrualTime(uint256 accrualTime) external onlyAdmin {

        _accrualTime = accrualTime;
    }

    function setPlotToken(address plotTokenAddress) external onlyAdmin {

        _plotToken = IERC1155Upgradeable(plotTokenAddress);
    }

    function setStrainToken(address strainTokenAddress) external onlyAdmin {

        _strainToken = IERC721Upgradeable(strainTokenAddress);
    }

    function setBredStrainToken(address bredStrainTokenAddress)
        external
        onlyAdmin
    {

        _bredStrainToken = IBredStrain(bredStrainTokenAddress);
    }

    function setRaksToken(address raksTokenAddress) external onlyAdmin {

        _raksToken = IRaks(raksTokenAddress);
    }

    function paused() public view virtual returns (bool) {

        return _paused;
    }

    function pause() internal whenNotPaused onlyAdmin {

        _paused = true;
    }

    function unpause() internal whenPaused onlyAdmin {

        _paused = false;
    }

    modifier whenNotPaused() {

        require(!paused(), "Pausable: paused");
        _;
    }

    modifier whenPaused() {

        require(paused(), "Pausable: not paused");
        _;
    }
}