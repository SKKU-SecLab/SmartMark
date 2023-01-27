
pragma solidity ^0.8.0;

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}// MIT

pragma solidity ^0.8.0;


abstract contract ERC165 is IERC165 {
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}// UNLICENSED

pragma solidity ^0.8.0;


interface IERC2981 is IERC165 {    


    function royaltyInfo(
        uint256 _tokenId,
        uint256 _salePrice
    ) external view returns (
        address receiver,
        uint256 royaltyAmount
    );

}

abstract contract _Royalties is IERC2981 {     
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC2981).interfaceId;
    }
}// MIT

pragma solidity ^0.8.0;

interface IAccessControl {

    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);

    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    function hasRole(bytes32 role, address account) external view returns (bool);


    function getRoleAdmin(bytes32 role) external view returns (bytes32);


    function grantRole(bytes32 role, address account) external;


    function revokeRole(bytes32 role, address account) external;


    function renounceRole(bytes32 role, address account) external;

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


abstract contract AccessControl is Context, IAccessControl, ERC165 {
    struct RoleData {
        mapping(address => bool) members;
        bytes32 adminRole;
    }

    mapping(bytes32 => RoleData) private _roles;

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    modifier onlyRole(bytes32 role) {
        _checkRole(role, _msgSender());
        _;
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IAccessControl).interfaceId || super.supportsInterface(interfaceId);
    }

    function hasRole(bytes32 role, address account) public view override returns (bool) {
        return _roles[role].members[account];
    }

    function _checkRole(bytes32 role, address account) internal view {
        if (!hasRole(role, account)) {
            revert(
                string(
                    abi.encodePacked(
                        "AccessControl: account ",
                        Strings.toHexString(uint160(account), 20),
                        " is missing role ",
                        Strings.toHexString(uint256(role), 32)
                    )
                )
            );
        }
    }

    function getRoleAdmin(bytes32 role) public view override returns (bytes32) {
        return _roles[role].adminRole;
    }

    function grantRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _grantRole(role, account);
    }

    function revokeRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _revokeRole(role, account);
    }

    function renounceRole(bytes32 role, address account) public virtual override {
        require(account == _msgSender(), "AccessControl: can only renounce roles for self");

        _revokeRole(role, account);
    }

    function _setupRole(bytes32 role, address account) internal virtual {
        _grantRole(role, account);
    }

    function _setRoleAdmin(bytes32 role, bytes32 adminRole) internal virtual {
        bytes32 previousAdminRole = getRoleAdmin(role);
        _roles[role].adminRole = adminRole;
        emit RoleAdminChanged(role, previousAdminRole, adminRole);
    }

    function _grantRole(bytes32 role, address account) private {
        if (!hasRole(role, account)) {
            _roles[role].members[account] = true;
            emit RoleGranted(role, account, _msgSender());
        }
    }

    function _revokeRole(bytes32 role, address account) private {
        if (hasRole(role, account)) {
            _roles[role].members[account] = false;
            emit RoleRevoked(role, account, _msgSender());
        }
    }
}// UNLICENSED

pragma solidity ^0.8.0;

library TypesV1 {

    struct Point2D {
        int256 x;
        int256 y;
    }

    struct Chunk2D {
        uint16 index;
        uint16 width;
        uint16 height;
        uint16 chunkWidth;
        uint16 chunkHeight;
        uint32 startX;
        uint32 startY;
    }
}// UNLICENSED

pragma solidity ^0.8.0;

library GraphicsV1 {

    
    function setPixel(
        uint32[16384 /* 128 * 128 */] memory result,
        uint256 width,
        int256 x,
        int256 y,
        uint32 color
    ) internal pure {

        uint256 p = uint256(int256(width) * y + x);
        result[p] = blend(result[p], color);
    }

    function blend(uint32 bg, uint32 fg) internal pure returns (uint32) {

        uint32 r1 = bg >> 16;
        uint32 g1 = bg >> 8;
        uint32 b1 = bg;
        
        uint32 a2 = fg >> 24;
        uint32 r2 = fg >> 16;
        uint32 g2 = fg >> 8;
        uint32 b2 = fg;
        
        uint32 alpha = (a2 & 0xFF) + 1;
        uint32 inverseAlpha = 257 - alpha;

        uint32 r = (alpha * (r2 & 0xFF) + inverseAlpha * (r1 & 0xFF)) >> 8;
        uint32 g = (alpha * (g2 & 0xFF) + inverseAlpha * (g1 & 0xFF)) >> 8;
        uint32 b = (alpha * (b2 & 0xFF) + inverseAlpha * (b1 & 0xFF)) >> 8;

        uint32 rgb = 0;
        rgb |= uint32(0xFF) << 24;
        rgb |= r << 16;
        rgb |= g << 8;
        rgb |= b;

        return rgb;
    }

    function setOpacity(uint32 color, uint32 opacity) internal pure returns (uint32) {


        require(opacity > 0 && opacity <= 255, "opacity must be between 0 and 255");
        
        uint32 r = color >> 16 & 0xFF;
        uint32 g = color >> 8 & 0xFF;
        uint32 b = color & 0xFF;

        uint32 rgb = 0;
        rgb |= opacity << 24;
        rgb |= r << 16;
        rgb |= g << 8;
        rgb |= b;

        return uint32(rgb);     
    }
}// UNLICENSED

pragma solidity ^0.8.0;


library GeometryV1 {

        
    struct Triangle2D {
        TypesV1.Point2D v0;
        TypesV1.Point2D v1;
        TypesV1.Point2D v2;
        uint32 strokeColor;
        uint32 fillColor;
        TypesV1.Chunk2D chunk;
    }

    struct Line2D {
        TypesV1.Point2D v0;
        TypesV1.Point2D v1;
        uint32 color;
        TypesV1.Chunk2D chunk;
    }

    struct Polygon2D {
        TypesV1.Point2D[40960] vertices;
        uint32 vertexCount;
        uint32 strokeColor;
        uint32 fillColor;
        TypesV1.Chunk2D chunk;
    }

    function edge(
        TypesV1.Point2D memory a,
        TypesV1.Point2D memory b,
        TypesV1.Point2D memory c
    ) external pure returns (int256) {

        return ((b.y - a.y) * (c.x - a.x)) - ((b.x - a.x) * (c.y - a.y));
    }

    function getBoundingBox(TypesV1.Point2D[] memory vertices)
        external
        pure
        returns (TypesV1.Point2D memory tl, TypesV1.Point2D memory br)
    {

        int256 xMax = vertices[0].x;
        int256 xMin = vertices[0].x;
        int256 yMax = vertices[0].y;
        int256 yMin = vertices[0].y;

        for (uint256 i; i < vertices.length; i++) {
            TypesV1.Point2D memory p = vertices[i];

            if (p.x > xMax) xMax = p.x;
            if (p.x < xMin) xMin = p.x;
            if (p.y > yMax) yMax = p.y;
            if (p.y < yMin) yMin = p.y;
        }

        return (TypesV1.Point2D(xMin, yMin), TypesV1.Point2D(xMax, yMax));
    }
}// UNLICENSED

pragma solidity ^0.8.0;

library MathV1 {

    function max(int256 a, int256 b) internal pure returns (int256) {

        return a >= b ? a : b;
    }

    function min(int256 a, int256 b) internal pure returns (int256) {

        return a < b ? a : b;
    }

    function max3(
        int256 a,
        int256 b,
        int256 c
    ) internal pure returns (int256) {

        int256 d = b >= c ? b : c;
        return a >= d ? a : d;
    }

    function min3(
        int256 a,
        int256 b,
        int256 c
    ) internal pure returns (int256) {

        int256 d = b < c ? b : c;
        return a < d ? a : d;
    }

    function abs(int256 x) internal pure returns (int256) {

        return x >= 0 ? x : -x;
    }

    function sign(int256 x) internal pure returns (int8) {

        return x == 0 ? int8(0) : x > 0 ? int8(1) : int8(-1);
    }
}// UNLICENSED

pragma solidity ^0.8.0;



library Fix64V1 {

    int64 public constant FRACTIONAL_PLACES = 32;
    int64 public constant ONE = 4294967296; // 1 << FRACTIONAL_PLACES
    int64 public constant TWO = ONE * 2;
    int64 public constant PI = 0x3243F6A88;
    int64 public constant TWO_PI = 0x6487ED511;
    int64 public constant MAX_VALUE = type(int64).max;
    int64 public constant MIN_VALUE = type(int64).min;
    int64 public constant PI_OVER_2 = 0x1921FB544;

    function countLeadingZeros(uint64 x) internal pure returns (int64) {        

        int64 result = 0;
        while ((x & 0xF000000000000000) == 0) {
            result += 4;
            x <<= 4;
        }
        while ((x & 0x8000000000000000) == 0) {
            result += 1;
            x <<= 1;
        }
        return result;
    }

    function div(int64 x, int64 y)
        internal
        pure
        returns (int64)
    {

        if (y == 0) {
            revert("attempted to divide by zero");
        }

        int64 xl = x;
        int64 yl = y;        

        uint64 remainder = uint64(xl >= 0 ? xl : -xl);
        uint64 divider = uint64((yl >= 0 ? yl : -yl));
        uint64 quotient = 0;
        int64 bitPos = 64 / 2 + 1;

        while ((divider & 0xF) == 0 && bitPos >= 4) {
            divider >>= 4;
            bitPos -= 4;
        }

        while (remainder != 0 && bitPos >= 0) {
            int64 shift = countLeadingZeros(remainder);
            if (shift > bitPos) {
                shift = bitPos;
            }
            remainder <<= uint64(shift);
            bitPos -= shift;

            uint64 d = remainder / divider;
            remainder = remainder % divider;
            quotient += d << uint64(bitPos);

            if ((d & ~(uint64(0xFFFFFFFFFFFFFFFF) >> uint64(bitPos)) != 0)) {
                return
                    ((xl ^ yl) & MIN_VALUE) == 0
                        ? MAX_VALUE
                        : MIN_VALUE;
            }

            remainder <<= 1;
            --bitPos;
        }

        ++quotient;
        int64 result = int64(quotient >> 1);
        if (((xl ^ yl) & MIN_VALUE) != 0) {
            result = -result;
        }

        return int64(result);
    }

    function mul(int64 x, int64 y)
        internal
        pure
        returns (int64)
    {

        int64 xl = x;
        int64 yl = y;

        uint64 xlo = (uint64)((xl & (int64)(0x00000000FFFFFFFF)));
        int64 xhi = xl >> 32; // FRACTIONAL_PLACES
        uint64 ylo = (uint64)(yl & (int64)(0x00000000FFFFFFFF));
        int64 yhi = yl >> 32; // FRACTIONAL_PLACES

        uint64 lolo = xlo * ylo;
        int64 lohi = int64(xlo) * yhi;
        int64 hilo = xhi * int64(ylo);
        int64 hihi = xhi * yhi;

        uint64 loResult = lolo >> 32; // FRACTIONAL_PLACES
        int64 midResult1 = lohi;
        int64 midResult2 = hilo;
        int64 hiResult = hihi << 32; // FRACTIONAL_PLACES

        int64 sum = int64(loResult) + midResult1 + midResult2 + hiResult;

        return int64(sum);
    }

    function mul_256(int x, int y)
        internal
        pure
        returns (int)
    {

        int xl = x;
        int yl = y;

        uint xlo = uint((xl & int(0x00000000FFFFFFFF)));
        int xhi = xl >> 32; // FRACTIONAL_PLACES
        uint ylo = uint(yl & int(0x00000000FFFFFFFF));
        int yhi = yl >> 32; // FRACTIONAL_PLACES

        uint lolo = xlo * ylo;
        int lohi = int(xlo) * yhi;
        int hilo = xhi * int(ylo);
        int hihi = xhi * yhi;

        uint loResult = lolo >> 32; // FRACTIONAL_PLACES
        int midResult1 = lohi;
        int midResult2 = hilo;
        int hiResult = hihi << 32; // FRACTIONAL_PLACES

        int sum = int(loResult) + midResult1 + midResult2 + hiResult;

        return sum;
    }

    function floor(int x) internal pure returns (int64) {

        return int64(x & 0xFFFFFFFF00000000);
    }

    function round(int x) internal pure returns (int) {

        int fractionalPart = x & 0x00000000FFFFFFFF;
        int integralPart = floor(x);
        if (fractionalPart < 0x80000000) return integralPart;
        if (fractionalPart > 0x80000000) return integralPart + ONE;
        if ((integralPart & ONE) == 0) return integralPart;
        return integralPart + ONE;
    }

    function sub(int64 x, int64 y)
        internal
        pure
        returns (int64)
    {

        int64 xl = x;
        int64 yl = y;
        int64 diff = xl - yl;
        if (((xl ^ yl) & (xl ^ diff) & MIN_VALUE) != 0) diff = xl < 0 ? MIN_VALUE : MAX_VALUE;
        return diff;
    }

    function add(int64 x, int64 y)
        internal
        pure
        returns (int64)
    {

        int64 xl = x;
        int64 yl = y;
        int64 sum = xl + yl;
        if ((~(xl ^ yl) & (xl ^ sum) & MIN_VALUE) != 0) sum = xl > 0 ? MAX_VALUE : MIN_VALUE;
        return sum;
    }

    function sign(int64 x) internal pure returns (int8) {

        return x == int8(0) ? int8(0) : x > int8(0) ? int8(1) : int8(-1);
    }

    function abs(int64 x) internal pure returns (int64) {

        int64 mask = x >> 63;
        return (x + mask) ^ mask;
    }
}// UNLICENSED

pragma solidity ^0.8.0;

library SinLut256 {

    function sinlut(int256 i) external pure returns (int64) {

        if (i <= 127) {
            if (i <= 63) {
                if (i <= 31) {
                    if (i <= 15) {
                        if (i <= 7) {
                            if (i <= 3) {
                                if (i <= 1) {
                                    if (i == 0) {
                                        return 0;
                                    } else {
                                        return 26456769;
                                    }
                                } else {
                                    if (i == 2) {
                                        return 52912534;
                                    } else {
                                        return 79366292;
                                    }
                                }
                            } else {
                                if (i <= 5) {
                                    if (i == 4) {
                                        return 105817038;
                                    } else {
                                        return 132263769;
                                    }
                                } else {
                                    if (i == 6) {
                                        return 158705481;
                                    } else {
                                        return 185141171;
                                    }
                                }
                            }
                        } else {
                            if (i <= 11) {
                                if (i <= 9) {
                                    if (i == 8) {
                                        return 211569835;
                                    } else {
                                        return 237990472;
                                    }
                                } else {
                                    if (i == 10) {
                                        return 264402078;
                                    } else {
                                        return 290803651;
                                    }
                                }
                            } else {
                                if (i <= 13) {
                                    if (i == 12) {
                                        return 317194190;
                                    } else {
                                        return 343572692;
                                    }
                                } else {
                                    if (i == 14) {
                                        return 369938158;
                                    } else {
                                        return 396289586;
                                    }
                                }
                            }
                        }
                    } else {
                        if (i <= 23) {
                            if (i <= 19) {
                                if (i <= 17) {
                                    if (i == 16) {
                                        return 422625977;
                                    } else {
                                        return 448946331;
                                    }
                                } else {
                                    if (i == 18) {
                                        return 475249649;
                                    } else {
                                        return 501534935;
                                    }
                                }
                            } else {
                                if (i <= 21) {
                                    if (i == 20) {
                                        return 527801189;
                                    } else {
                                        return 554047416;
                                    }
                                } else {
                                    if (i == 22) {
                                        return 580272619;
                                    } else {
                                        return 606475804;
                                    }
                                }
                            }
                        } else {
                            if (i <= 27) {
                                if (i <= 25) {
                                    if (i == 24) {
                                        return 632655975;
                                    } else {
                                        return 658812141;
                                    }
                                } else {
                                    if (i == 26) {
                                        return 684943307;
                                    } else {
                                        return 711048483;
                                    }
                                }
                            } else {
                                if (i <= 29) {
                                    if (i == 28) {
                                        return 737126679;
                                    } else {
                                        return 763176903;
                                    }
                                } else {
                                    if (i == 30) {
                                        return 789198169;
                                    } else {
                                        return 815189489;
                                    }
                                }
                            }
                        }
                    }
                } else {
                    if (i <= 47) {
                        if (i <= 39) {
                            if (i <= 35) {
                                if (i <= 33) {
                                    if (i == 32) {
                                        return 841149875;
                                    } else {
                                        return 867078344;
                                    }
                                } else {
                                    if (i == 34) {
                                        return 892973912;
                                    } else {
                                        return 918835595;
                                    }
                                }
                            } else {
                                if (i <= 37) {
                                    if (i == 36) {
                                        return 944662413;
                                    } else {
                                        return 970453386;
                                    }
                                } else {
                                    if (i == 38) {
                                        return 996207534;
                                    } else {
                                        return 1021923881;
                                    }
                                }
                            }
                        } else {
                            if (i <= 43) {
                                if (i <= 41) {
                                    if (i == 40) {
                                        return 1047601450;
                                    } else {
                                        return 1073239268;
                                    }
                                } else {
                                    if (i == 42) {
                                        return 1098836362;
                                    } else {
                                        return 1124391760;
                                    }
                                }
                            } else {
                                if (i <= 45) {
                                    if (i == 44) {
                                        return 1149904493;
                                    } else {
                                        return 1175373592;
                                    }
                                } else {
                                    if (i == 46) {
                                        return 1200798091;
                                    } else {
                                        return 1226177026;
                                    }
                                }
                            }
                        }
                    } else {
                        if (i <= 55) {
                            if (i <= 51) {
                                if (i <= 49) {
                                    if (i == 48) {
                                        return 1251509433;
                                    } else {
                                        return 1276794351;
                                    }
                                } else {
                                    if (i == 50) {
                                        return 1302030821;
                                    } else {
                                        return 1327217884;
                                    }
                                }
                            } else {
                                if (i <= 53) {
                                    if (i == 52) {
                                        return 1352354586;
                                    } else {
                                        return 1377439973;
                                    }
                                } else {
                                    if (i == 54) {
                                        return 1402473092;
                                    } else {
                                        return 1427452994;
                                    }
                                }
                            }
                        } else {
                            if (i <= 59) {
                                if (i <= 57) {
                                    if (i == 56) {
                                        return 1452378731;
                                    } else {
                                        return 1477249357;
                                    }
                                } else {
                                    if (i == 58) {
                                        return 1502063928;
                                    } else {
                                        return 1526821503;
                                    }
                                }
                            } else {
                                if (i <= 61) {
                                    if (i == 60) {
                                        return 1551521142;
                                    } else {
                                        return 1576161908;
                                    }
                                } else {
                                    if (i == 62) {
                                        return 1600742866;
                                    } else {
                                        return 1625263084;
                                    }
                                }
                            }
                        }
                    }
                }
            } else {
                if (i <= 95) {
                    if (i <= 79) {
                        if (i <= 71) {
                            if (i <= 67) {
                                if (i <= 65) {
                                    if (i == 64) {
                                        return 1649721630;
                                    } else {
                                        return 1674117578;
                                    }
                                } else {
                                    if (i == 66) {
                                        return 1698450000;
                                    } else {
                                        return 1722717974;
                                    }
                                }
                            } else {
                                if (i <= 69) {
                                    if (i == 68) {
                                        return 1746920580;
                                    } else {
                                        return 1771056897;
                                    }
                                } else {
                                    if (i == 70) {
                                        return 1795126012;
                                    } else {
                                        return 1819127010;
                                    }
                                }
                            }
                        } else {
                            if (i <= 75) {
                                if (i <= 73) {
                                    if (i == 72) {
                                        return 1843058980;
                                    } else {
                                        return 1866921015;
                                    }
                                } else {
                                    if (i == 74) {
                                        return 1890712210;
                                    } else {
                                        return 1914431660;
                                    }
                                }
                            } else {
                                if (i <= 77) {
                                    if (i == 76) {
                                        return 1938078467;
                                    } else {
                                        return 1961651733;
                                    }
                                } else {
                                    if (i == 78) {
                                        return 1985150563;
                                    } else {
                                        return 2008574067;
                                    }
                                }
                            }
                        }
                    } else {
                        if (i <= 87) {
                            if (i <= 83) {
                                if (i <= 81) {
                                    if (i == 80) {
                                        return 2031921354;
                                    } else {
                                        return 2055191540;
                                    }
                                } else {
                                    if (i == 82) {
                                        return 2078383740;
                                    } else {
                                        return 2101497076;
                                    }
                                }
                            } else {
                                if (i <= 85) {
                                    if (i == 84) {
                                        return 2124530670;
                                    } else {
                                        return 2147483647;
                                    }
                                } else {
                                    if (i == 86) {
                                        return 2170355138;
                                    } else {
                                        return 2193144275;
                                    }
                                }
                            }
                        } else {
                            if (i <= 91) {
                                if (i <= 89) {
                                    if (i == 88) {
                                        return 2215850191;
                                    } else {
                                        return 2238472027;
                                    }
                                } else {
                                    if (i == 90) {
                                        return 2261008923;
                                    } else {
                                        return 2283460024;
                                    }
                                }
                            } else {
                                if (i <= 93) {
                                    if (i == 92) {
                                        return 2305824479;
                                    } else {
                                        return 2328101438;
                                    }
                                } else {
                                    if (i == 94) {
                                        return 2350290057;
                                    } else {
                                        return 2372389494;
                                    }
                                }
                            }
                        }
                    }
                } else {
                    if (i <= 111) {
                        if (i <= 103) {
                            if (i <= 99) {
                                if (i <= 97) {
                                    if (i == 96) {
                                        return 2394398909;
                                    } else {
                                        return 2416317469;
                                    }
                                } else {
                                    if (i == 98) {
                                        return 2438144340;
                                    } else {
                                        return 2459878695;
                                    }
                                }
                            } else {
                                if (i <= 101) {
                                    if (i == 100) {
                                        return 2481519710;
                                    } else {
                                        return 2503066562;
                                    }
                                } else {
                                    if (i == 102) {
                                        return 2524518435;
                                    } else {
                                        return 2545874514;
                                    }
                                }
                            }
                        } else {
                            if (i <= 107) {
                                if (i <= 105) {
                                    if (i == 104) {
                                        return 2567133990;
                                    } else {
                                        return 2588296054;
                                    }
                                } else {
                                    if (i == 106) {
                                        return 2609359905;
                                    } else {
                                        return 2630324743;
                                    }
                                }
                            } else {
                                if (i <= 109) {
                                    if (i == 108) {
                                        return 2651189772;
                                    } else {
                                        return 2671954202;
                                    }
                                } else {
                                    if (i == 110) {
                                        return 2692617243;
                                    } else {
                                        return 2713178112;
                                    }
                                }
                            }
                        }
                    } else {
                        if (i <= 119) {
                            if (i <= 115) {
                                if (i <= 113) {
                                    if (i == 112) {
                                        return 2733636028;
                                    } else {
                                        return 2753990216;
                                    }
                                } else {
                                    if (i == 114) {
                                        return 2774239903;
                                    } else {
                                        return 2794384321;
                                    }
                                }
                            } else {
                                if (i <= 117) {
                                    if (i == 116) {
                                        return 2814422705;
                                    } else {
                                        return 2834354295;
                                    }
                                } else {
                                    if (i == 118) {
                                        return 2854178334;
                                    } else {
                                        return 2873894071;
                                    }
                                }
                            }
                        } else {
                            if (i <= 123) {
                                if (i <= 121) {
                                    if (i == 120) {
                                        return 2893500756;
                                    } else {
                                        return 2912997648;
                                    }
                                } else {
                                    if (i == 122) {
                                        return 2932384004;
                                    } else {
                                        return 2951659090;
                                    }
                                }
                            } else {
                                if (i <= 125) {
                                    if (i == 124) {
                                        return 2970822175;
                                    } else {
                                        return 2989872531;
                                    }
                                } else {
                                    if (i == 126) {
                                        return 3008809435;
                                    } else {
                                        return 3027632170;
                                    }
                                }
                            }
                        }
                    }
                }
            }
        } else {
            if (i <= 191) {
                if (i <= 159) {
                    if (i <= 143) {
                        if (i <= 135) {
                            if (i <= 131) {
                                if (i <= 129) {
                                    if (i == 128) {
                                        return 3046340019;
                                    } else {
                                        return 3064932275;
                                    }
                                } else {
                                    if (i == 130) {
                                        return 3083408230;
                                    } else {
                                        return 3101767185;
                                    }
                                }
                            } else {
                                if (i <= 133) {
                                    if (i == 132) {
                                        return 3120008443;
                                    } else {
                                        return 3138131310;
                                    }
                                } else {
                                    if (i == 134) {
                                        return 3156135101;
                                    } else {
                                        return 3174019130;
                                    }
                                }
                            }
                        } else {
                            if (i <= 139) {
                                if (i <= 137) {
                                    if (i == 136) {
                                        return 3191782721;
                                    } else {
                                        return 3209425199;
                                    }
                                } else {
                                    if (i == 138) {
                                        return 3226945894;
                                    } else {
                                        return 3244344141;
                                    }
                                }
                            } else {
                                if (i <= 141) {
                                    if (i == 140) {
                                        return 3261619281;
                                    } else {
                                        return 3278770658;
                                    }
                                } else {
                                    if (i == 142) {
                                        return 3295797620;
                                    } else {
                                        return 3312699523;
                                    }
                                }
                            }
                        }
                    } else {
                        if (i <= 151) {
                            if (i <= 147) {
                                if (i <= 145) {
                                    if (i == 144) {
                                        return 3329475725;
                                    } else {
                                        return 3346125588;
                                    }
                                } else {
                                    if (i == 146) {
                                        return 3362648482;
                                    } else {
                                        return 3379043779;
                                    }
                                }
                            } else {
                                if (i <= 149) {
                                    if (i == 148) {
                                        return 3395310857;
                                    } else {
                                        return 3411449099;
                                    }
                                } else {
                                    if (i == 150) {
                                        return 3427457892;
                                    } else {
                                        return 3443336630;
                                    }
                                }
                            }
                        } else {
                            if (i <= 155) {
                                if (i <= 153) {
                                    if (i == 152) {
                                        return 3459084709;
                                    } else {
                                        return 3474701532;
                                    }
                                } else {
                                    if (i == 154) {
                                        return 3490186507;
                                    } else {
                                        return 3505539045;
                                    }
                                }
                            } else {
                                if (i <= 157) {
                                    if (i == 156) {
                                        return 3520758565;
                                    } else {
                                        return 3535844488;
                                    }
                                } else {
                                    if (i == 158) {
                                        return 3550796243;
                                    } else {
                                        return 3565613262;
                                    }
                                }
                            }
                        }
                    }
                } else {
                    if (i <= 175) {
                        if (i <= 167) {
                            if (i <= 163) {
                                if (i <= 161) {
                                    if (i == 160) {
                                        return 3580294982;
                                    } else {
                                        return 3594840847;
                                    }
                                } else {
                                    if (i == 162) {
                                        return 3609250305;
                                    } else {
                                        return 3623522808;
                                    }
                                }
                            } else {
                                if (i <= 165) {
                                    if (i == 164) {
                                        return 3637657816;
                                    } else {
                                        return 3651654792;
                                    }
                                } else {
                                    if (i == 166) {
                                        return 3665513205;
                                    } else {
                                        return 3679232528;
                                    }
                                }
                            }
                        } else {
                            if (i <= 171) {
                                if (i <= 169) {
                                    if (i == 168) {
                                        return 3692812243;
                                    } else {
                                        return 3706251832;
                                    }
                                } else {
                                    if (i == 170) {
                                        return 3719550786;
                                    } else {
                                        return 3732708601;
                                    }
                                }
                            } else {
                                if (i <= 173) {
                                    if (i == 172) {
                                        return 3745724777;
                                    } else {
                                        return 3758598821;
                                    }
                                } else {
                                    if (i == 174) {
                                        return 3771330243;
                                    } else {
                                        return 3783918561;
                                    }
                                }
                            }
                        }
                    } else {
                        if (i <= 183) {
                            if (i <= 179) {
                                if (i <= 177) {
                                    if (i == 176) {
                                        return 3796363297;
                                    } else {
                                        return 3808663979;
                                    }
                                } else {
                                    if (i == 178) {
                                        return 3820820141;
                                    } else {
                                        return 3832831319;
                                    }
                                }
                            } else {
                                if (i <= 181) {
                                    if (i == 180) {
                                        return 3844697060;
                                    } else {
                                        return 3856416913;
                                    }
                                } else {
                                    if (i == 182) {
                                        return 3867990433;
                                    } else {
                                        return 3879417181;
                                    }
                                }
                            }
                        } else {
                            if (i <= 187) {
                                if (i <= 185) {
                                    if (i == 184) {
                                        return 3890696723;
                                    } else {
                                        return 3901828632;
                                    }
                                } else {
                                    if (i == 186) {
                                        return 3912812484;
                                    } else {
                                        return 3923647863;
                                    }
                                }
                            } else {
                                if (i <= 189) {
                                    if (i == 188) {
                                        return 3934334359;
                                    } else {
                                        return 3944871565;
                                    }
                                } else {
                                    if (i == 190) {
                                        return 3955259082;
                                    } else {
                                        return 3965496515;
                                    }
                                }
                            }
                        }
                    }
                }
            } else {
                if (i <= 223) {
                    if (i <= 207) {
                        if (i <= 199) {
                            if (i <= 195) {
                                if (i <= 193) {
                                    if (i == 192) {
                                        return 3975583476;
                                    } else {
                                        return 3985519583;
                                    }
                                } else {
                                    if (i == 194) {
                                        return 3995304457;
                                    } else {
                                        return 4004937729;
                                    }
                                }
                            } else {
                                if (i <= 197) {
                                    if (i == 196) {
                                        return 4014419032;
                                    } else {
                                        return 4023748007;
                                    }
                                } else {
                                    if (i == 198) {
                                        return 4032924300;
                                    } else {
                                        return 4041947562;
                                    }
                                }
                            }
                        } else {
                            if (i <= 203) {
                                if (i <= 201) {
                                    if (i == 200) {
                                        return 4050817451;
                                    } else {
                                        return 4059533630;
                                    }
                                } else {
                                    if (i == 202) {
                                        return 4068095769;
                                    } else {
                                        return 4076503544;
                                    }
                                }
                            } else {
                                if (i <= 205) {
                                    if (i == 204) {
                                        return 4084756634;
                                    } else {
                                        return 4092854726;
                                    }
                                } else {
                                    if (i == 206) {
                                        return 4100797514;
                                    } else {
                                        return 4108584696;
                                    }
                                }
                            }
                        }
                    } else {
                        if (i <= 215) {
                            if (i <= 211) {
                                if (i <= 209) {
                                    if (i == 208) {
                                        return 4116215977;
                                    } else {
                                        return 4123691067;
                                    }
                                } else {
                                    if (i == 210) {
                                        return 4131009681;
                                    } else {
                                        return 4138171544;
                                    }
                                }
                            } else {
                                if (i <= 213) {
                                    if (i == 212) {
                                        return 4145176382;
                                    } else {
                                        return 4152023930;
                                    }
                                } else {
                                    if (i == 214) {
                                        return 4158713929;
                                    } else {
                                        return 4165246124;
                                    }
                                }
                            }
                        } else {
                            if (i <= 219) {
                                if (i <= 217) {
                                    if (i == 216) {
                                        return 4171620267;
                                    } else {
                                        return 4177836117;
                                    }
                                } else {
                                    if (i == 218) {
                                        return 4183893437;
                                    } else {
                                        return 4189791999;
                                    }
                                }
                            } else {
                                if (i <= 221) {
                                    if (i == 220) {
                                        return 4195531577;
                                    } else {
                                        return 4201111955;
                                    }
                                } else {
                                    if (i == 222) {
                                        return 4206532921;
                                    } else {
                                        return 4211794268;
                                    }
                                }
                            }
                        }
                    }
                } else {
                    if (i <= 239) {
                        if (i <= 231) {
                            if (i <= 227) {
                                if (i <= 225) {
                                    if (i == 224) {
                                        return 4216895797;
                                    } else {
                                        return 4221837315;
                                    }
                                } else {
                                    if (i == 226) {
                                        return 4226618635;
                                    } else {
                                        return 4231239573;
                                    }
                                }
                            } else {
                                if (i <= 229) {
                                    if (i == 228) {
                                        return 4235699957;
                                    } else {
                                        return 4239999615;
                                    }
                                } else {
                                    if (i == 230) {
                                        return 4244138385;
                                    } else {
                                        return 4248116110;
                                    }
                                }
                            }
                        } else {
                            if (i <= 235) {
                                if (i <= 233) {
                                    if (i == 232) {
                                        return 4251932639;
                                    } else {
                                        return 4255587827;
                                    }
                                } else {
                                    if (i == 234) {
                                        return 4259081536;
                                    } else {
                                        return 4262413632;
                                    }
                                }
                            } else {
                                if (i <= 237) {
                                    if (i == 236) {
                                        return 4265583990;
                                    } else {
                                        return 4268592489;
                                    }
                                } else {
                                    if (i == 238) {
                                        return 4271439015;
                                    } else {
                                        return 4274123460;
                                    }
                                }
                            }
                        }
                    } else {
                        if (i <= 247) {
                            if (i <= 243) {
                                if (i <= 241) {
                                    if (i == 240) {
                                        return 4276645722;
                                    } else {
                                        return 4279005706;
                                    }
                                } else {
                                    if (i == 242) {
                                        return 4281203321;
                                    } else {
                                        return 4283238485;
                                    }
                                }
                            } else {
                                if (i <= 245) {
                                    if (i == 244) {
                                        return 4285111119;
                                    } else {
                                        return 4286821154;
                                    }
                                } else {
                                    if (i == 246) {
                                        return 4288368525;
                                    } else {
                                        return 4289753172;
                                    }
                                }
                            }
                        } else {
                            if (i <= 251) {
                                if (i <= 249) {
                                    if (i == 248) {
                                        return 4290975043;
                                    } else {
                                        return 4292034091;
                                    }
                                } else {
                                    if (i == 250) {
                                        return 4292930277;
                                    } else {
                                        return 4293663567;
                                    }
                                }
                            } else {
                                if (i <= 253) {
                                    if (i == 252) {
                                        return 4294233932;
                                    } else {
                                        return 4294641351;
                                    }
                                } else {
                                    if (i == 254) {
                                        return 4294885809;
                                    } else {
                                        return 4294967296;
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}// UNLICENSED

pragma solidity ^0.8.0;



library Trig256 {

    int64 private constant LARGE_PI = 7244019458077122842;
    int64 private constant LN2 = 0xB17217F7;
    int64 private constant LN_MAX = 0x157CD0E702;
    int64 private constant LN_MIN = -0x162E42FEFA;
    int64 private constant E = -0x2B7E15162;

    function sin(int64 x)
        internal
        pure
        returns (int64)
    {       

        (
            int64 clamped,
            bool flipHorizontal,
            bool flipVertical
        ) = clamp(x);

        int64 lutInterval = Fix64V1.div(((256 - 1) * Fix64V1.ONE), Fix64V1.PI_OVER_2);
        int rawIndex = Fix64V1.mul_256(clamped, lutInterval);
        int64 roundedIndex = int64(Fix64V1.round(rawIndex));
        int64 indexError = Fix64V1.sub(int64(rawIndex), roundedIndex);     

        roundedIndex = roundedIndex >> 32; /* FRACTIONAL_PLACES */

        int64 nearestValueIndex = flipHorizontal
            ? (256 - 1) - roundedIndex
            : roundedIndex;

        int64 nearestValue = SinLut256.sinlut(nearestValueIndex);

        int64 secondNearestValue = SinLut256.sinlut(
            flipHorizontal
                ? (256 - 1) -
                    roundedIndex -
                    Fix64V1.sign(indexError)
                : roundedIndex + Fix64V1.sign(indexError)
        );

        int64 delta = Fix64V1.mul(indexError, Fix64V1.abs(Fix64V1.sub(nearestValue, secondNearestValue)));
        int64 interpolatedValue = nearestValue + (flipHorizontal ? -delta : delta);
        int64 finalValue = flipVertical ? -interpolatedValue: interpolatedValue;
    
        return finalValue;
    }

    function cos(int64 x)
        internal
        pure
        returns (int64)
    {

        int64 xl = x;
        int64 angle;
        if(xl > 0) {            
            angle = Fix64V1.add(xl, Fix64V1.sub(0 - Fix64V1.PI, Fix64V1.PI_OVER_2));            
        } else {            
            angle = Fix64V1.add(xl, Fix64V1.PI_OVER_2);
        }        
        return sin(angle);
    }

    function sqrt(int64 x)
        internal
        pure        
        returns (int64)
    {

        int64 xl = x;
        if (xl < 0)
            revert("negative value passed to sqrt");

        uint64 num = uint64(xl);
        uint64 result = uint64(0);
        uint64 bit = uint64(1) << (64 - 2);

        while (bit > num) bit >>= 2;
        for (uint8 i = 0; i < 2; ++i)
        {
            while (bit != 0)
            {
                if (num >= result + bit)
                {
                    num -= result + bit;
                    result = (result >> 1) + bit;
                }
                else
                {
                    result = result >> 1;
                }

                bit >>= 2;
            }

            if (i == 0)
            {
                if (num > (uint64(1) << (64 / 2)) - 1)
                {
                    num -= result;
                    num = (num << (64 / 2)) - uint64(0x80000000);
                    result = (result << (64 / 2)) + uint64(0x80000000);
                }
                else
                {
                    num <<= 64 / 2;
                    result <<= 64 / 2;
                }

                bit = uint64(1) << (64 / 2 - 2);
            }
        }

        if (num > result) ++result;
        return int64(result);
    }

     function log2_256(int x)
        internal
        pure        
        returns (int)
    {

        if (x <= 0) {
            revert("negative value passed to log2_256");
        }


        int b = 1 << 31; // FRACTIONAL_PLACES - 1
        int y = 0;

        int rawX = x;
        while (rawX < Fix64V1.ONE) {
            rawX <<= 1;
            y -= Fix64V1.ONE;
        }

        while (rawX >= Fix64V1.ONE << 1) {
            rawX >>= 1;
            y += Fix64V1.ONE;
        }

        int z = rawX;

        for (uint8 i = 0; i < 32 /* FRACTIONAL_PLACES */; i++) {
            z = Fix64V1.mul_256(z, z);
            if (z >= Fix64V1.ONE << 1) {
                z = z >> 1;
                y += b;
            }
            b >>= 1;
        }

        return y;
    }

    function log_256(int x)
        internal
        pure        
        returns (int)
    {

        return Fix64V1.mul_256(log2_256(x), LN2);
    }

    function log2(int64 x)
        internal
        pure        
        returns (int64)
    {

        if (x <= 0) revert("non-positive value passed to log2");


        int64 b = 1 << 31; // FRACTIONAL_PLACES - 1
        int64 y = 0;

        int64 rawX = x;
        while (rawX < Fix64V1.ONE)
        {
            rawX <<= 1;
            y -= Fix64V1.ONE;
        }

        while (rawX >= Fix64V1.ONE << 1)
        {
            rawX >>= 1;
            y += Fix64V1.ONE;
        }

        int64 z = rawX;

        for (int32 i = 0; i < Fix64V1.FRACTIONAL_PLACES; i++)
        {
            z = Fix64V1.mul(z, z);
            if (z >= Fix64V1.ONE << 1)
            {
                z = z >> 1;
                y += b;
            }

            b >>= 1;
        }

        return y;
    }

    function log(int64 x)
        internal
        pure        
        returns (int64)
    {

        return Fix64V1.mul(log2(x), LN2);
    }

    function exp(int64 x)
        internal
        pure        
        returns (int64)
    {

        if (x == 0) return Fix64V1.ONE;
        if (x == Fix64V1.ONE) return E;
        if (x >= LN_MAX) return Fix64V1.MAX_VALUE;
        if (x <= LN_MIN) return 0;


        
        bool neg = (x < 0);
        if (neg) x = -x;

        int64 result = Fix64V1.add(
            int64(x),
            Fix64V1.ONE
        );
        int64 term = x;

        for (uint32 i = 2; i < 40; i++) {
            term = Fix64V1.mul(
                x,
                Fix64V1.div(term, int32(i) * Fix64V1.ONE)
            );
            result = Fix64V1.add(result, int64(term));
            if (term == 0) break;
        }

        if (neg) {
            result = Fix64V1.div(Fix64V1.ONE, result);
        }

        return result;
    }

    function clamp(int64 x)
        internal
        pure
        returns (
            int64,
            bool,
            bool
        )
    {

        int64 clamped2Pi = x;
        for (uint8 i = 0; i < 29; ++i) {
            clamped2Pi %= LARGE_PI >> i;
        }
        if (x < 0) {
            clamped2Pi += Fix64V1.TWO_PI;
        }

        bool flipVertical = clamped2Pi >= Fix64V1.PI;
        int64 clampedPi = clamped2Pi;
        while (clampedPi >= Fix64V1.PI) {
            clampedPi -= Fix64V1.PI;
        }

        bool flipHorizontal = clampedPi >= Fix64V1.PI_OVER_2;

        int64 clampedPiOver2 = clampedPi;
        if (clampedPiOver2 >= Fix64V1.PI_OVER_2)
            clampedPiOver2 -= Fix64V1.PI_OVER_2;

        return (clampedPiOver2, flipHorizontal, flipVertical);
    }
}// UNLICENSED

pragma solidity ^0.8.0;



library RandomV1 {


    int32 private constant MBIG = 0x7fffffff;
    int32 private constant MSEED = 161803398;

    struct PRNG {
        int32[56] _seedArray;
        int32 _inext;
        int32 _inextp;
    }
    
    function buildSeedTable(int32 seed) internal pure returns(PRNG memory prng) {

        uint8 ii = 0;
        int32 mj;
        int32 mk;

        int32 subtraction = (seed == type(int32).min) ? type(int32).max : int32(MathV1.abs(seed));
        mj = MSEED - subtraction;
        prng._seedArray[55] = mj;
        mk = 1;
        for (uint8 i = 1; i < 55; i++) {  
            if ((ii += 21) >= 55) {
                ii -= 55;
            }
            prng._seedArray[uint64(ii)] = mk;
            mk = mj - mk;
            if (mk < 0) mk += MBIG;
            mj = prng._seedArray[uint8(ii)];
        }

        for (uint8 k = 1; k < 5; k++) {

            for (uint8 i = 1; i < 56; i++) {                
                uint8 n = i + 30;           
                if (n >= 55) {
                    n -= 55;                
                }

                int64 an = prng._seedArray[1 + n];                
                int64 ai = prng._seedArray[i];
                prng._seedArray[i] = int32(ai - an);
                
                if (prng._seedArray[i] < 0) {
                    int64 x = prng._seedArray[i];
                    x += MBIG;
                    prng._seedArray[i] = int32(x);
                }               
            }
        }

        prng._inextp = 21;
    }   

    function next(PRNG memory prng, int32 maxValue) internal pure returns (int32) {

        require(maxValue >= 0, "maxValue < 0");

        int32 retval = next(prng);

        int64 fretval = retval * Fix64V1.ONE;
        int64 sample = Fix64V1.mul(fretval, Fix64V1.div(Fix64V1.ONE, MBIG * Fix64V1.ONE));
        int64 sr = Fix64V1.mul(sample, maxValue * Fix64V1.ONE);
        int32 r = int32(sr >> 32 /* FRACTIONAL_PLACES */);

        return r;
    }

    function next(PRNG memory prng, int32 minValue, int32 maxValue) internal pure returns(int32) {

        require(maxValue > minValue, "maxValue <= minValue");
        
        int64 range = maxValue - minValue;
        
        if (range <= type(int32).max) {
            int32 retval = next(prng);

            int64 fretval = retval * Fix64V1.ONE;
            int64 sample = Fix64V1.mul(fretval, Fix64V1.div(Fix64V1.ONE, MBIG * Fix64V1.ONE));
            int64 sr = Fix64V1.mul(sample, range * Fix64V1.ONE);
            int32 r = int32(sr >> 32  /* FRACTIONAL_PLACES */) + minValue;
            
            return r;
        }
        else {
            int64 fretval = nextForLargeRange(prng);
            int64 sr = Fix64V1.mul(fretval, range * Fix64V1.ONE);
            int32 r = int32(sr >> 32  /* FRACTIONAL_PLACES */) + minValue;
            return r;
        }
    }

    function next(PRNG memory prng) internal pure returns(int32) {


        int64 retVal;        
        int32 locINext = prng._inext;
        int32 locINextp = prng._inextp;

        if (++locINext >= 56) locINext = 1;
        if (++locINextp >= 56) locINextp = 1;

        int64 a = int64(prng._seedArray[uint32(locINext)]);
        int64 b = int64(prng._seedArray[uint32(locINextp)]);
        retVal = a - b;        

        if (retVal == MBIG) {
            retVal--;
        }
        if (retVal < 0) {
            retVal += MBIG;
        }

        prng._seedArray[uint32(locINext)] = int32(retVal);
        prng._inext = locINext;
        prng._inextp = locINextp;        

        int32 r = int32(retVal);
        return r;
    }

    function nextForLargeRange(PRNG memory prng) private pure returns(int64) {


        int sample1 = next(prng);
        int sample2 = next(prng);

        bool negative = sample2 % 2 == 0;
        if (negative) {
            sample1 = -sample1;
        }

        int64 d = int64(sample1) * Fix64V1.ONE;
        d = Fix64V1.add(int64(d), (type(int32).max - 1));
        d = Fix64V1.div(int64(d), int64(2) * (type(int32).max - 1));

        return d; 
    }

    function nextGaussian(PRNG memory prng) internal pure returns (int64 randNormal) {

        int64 u1 = Fix64V1.sub(Fix64V1.ONE, Fix64V1.mul(next(prng) * Fix64V1.ONE, Fix64V1.div(Fix64V1.ONE, Fix64V1.MAX_VALUE)));
        int64 u2 = Fix64V1.sub(Fix64V1.ONE, Fix64V1.mul(next(prng) * Fix64V1.ONE, Fix64V1.div(Fix64V1.ONE, Fix64V1.MAX_VALUE)));
        int64 sqrt = Trig256.sqrt(Fix64V1.mul(-2 * Fix64V1.ONE, Trig256.log(u1)));
        int64 randStdNormal = Fix64V1.mul(sqrt, Trig256.sin(Fix64V1.mul(Fix64V1.TWO, Fix64V1.mul(Fix64V1.PI, u2))));
        randNormal = Fix64V1.add(0, Fix64V1.mul(Fix64V1.ONE, randStdNormal));
        return randNormal;
    }
}// UNLICENSED

pragma solidity ^0.8.0;


library ProcessingV1 {

    uint32 internal constant BG_COLOR = 0xFFD3D3D3;
    uint32 internal constant FILL_COLOR = 0xFFFFFFFF;
    uint32 internal constant STROKE_COLOR = 0x00000000;
    uint32 internal constant MAX_POLYGON_NODES = 400;

    function background(
        uint32[16384] /* 128 * 128 */
            memory result,
        uint32 color,
        TypesV1.Chunk2D memory chunk
    ) internal pure {

        for (uint256 x = 0; x < chunk.chunkWidth; x++) {
            for (uint256 y = 0; y < chunk.chunkHeight; y++) {
                GraphicsV1.setPixel(
                    result,
                    chunk.chunkWidth,
                    int256(x),
                    int256(y),
                    color
                );
            }
        }
    }

    function triangle(
        uint32[16384] /* 128 * 128 */
            memory result,
        GeometryV1.Triangle2D memory f
    ) internal pure {

        TypesV1.Point2D memory p;

        uint256 minX = f.chunk.startX;
        uint256 maxX = (f.chunk.startX + f.chunk.chunkWidth) - 1;
        uint256 minY = f.chunk.startY;
        uint256 maxY = (f.chunk.startY + f.chunk.chunkHeight) - 1;

        while (GeometryV1.edge(f.v0, f.v1, f.v2) < 0) {
            TypesV1.Point2D memory temp = f.v1;
            f.v1 = f.v2;
            f.v2 = temp;
        }

        for (p.x = int256(minX); p.x <= int256(maxX); p.x++) {
            for (p.y = int256(minY); p.y <= int256(maxY); p.y++) {
                int256 w0 = GeometryV1.edge(f.v1, f.v2, p);
                int256 w1 = GeometryV1.edge(f.v2, f.v0, p);
                int256 w2 = GeometryV1.edge(f.v0, f.v1, p);

                if (w0 >= 0 && w1 >= 0 && w2 >= 0) {
                    GraphicsV1.setPixel(
                        result,
                        f.chunk.chunkWidth,
                        int256(p.x - int32(f.chunk.startX)),
                        int256(p.y - int32(f.chunk.startY)),
                        f.fillColor
                    );
                }
            }
        }

        if (f.strokeColor == f.fillColor) return;

        {
            line(result, GeometryV1.Line2D(f.v0, f.v1, f.strokeColor, f.chunk));
            line(result, GeometryV1.Line2D(f.v1, f.v2, f.strokeColor, f.chunk));
            line(result, GeometryV1.Line2D(f.v2, f.v0, f.strokeColor, f.chunk));
        }
    }

    function line(uint32[16384]memory result, GeometryV1.Line2D memory f
    ) internal pure {

        int256 x0 = f.v0.x;
        int256 x1 = f.v1.x;
        int256 y0 = f.v0.y;
        int256 y1 = f.v1.y;

        int256 dx = MathV1.abs(x1 - x0);        
        int256 dy = MathV1.abs(y1 - y0);

        int256 err = (dx > dy ? dx : -dy) / 2;
        int256 e2;

        for (;;) {
            if (
                x0 <= int32(f.chunk.startX) + int16(f.chunk.chunkWidth) - 1 &&
                x0 >= int32(f.chunk.startX) &&
                y0 <= int32(f.chunk.startY) + int16(f.chunk.chunkHeight) - 1 &&
                y0 >= int32(f.chunk.startY)
            ) {
                GraphicsV1.setPixel(
                    result,
                    f.chunk.chunkWidth,
                    x0 - int32(f.chunk.startX),
                    y0 - int32(f.chunk.startY),
                    f.color
                );
            }

            if (x0 == x1 && y0 == y1) break;
            e2 = err;
            if (e2 > -dx) {
                err -= dy;
                x0 += x0 < x1 ? int8(1) : -1;
            }
            if (e2 < dy) {
                err += dx;
                y0 += y0 < y1 ? int8(1) : -1;
            }
        }
    }

    function polygon(uint32[16384] memory result, GeometryV1.Polygon2D memory f
    ) internal pure {

        uint32 polyCorners = f.vertexCount;

        int32[MAX_POLYGON_NODES] memory nodeX;

        for (uint32 pixelY = f.chunk.startY; pixelY < (f.chunk.startY + f.chunk.chunkHeight); pixelY++) {
            uint32 i;

            uint256 nodes = 0;
            uint32 j = polyCorners - 1;
            for (i = 0; i < polyCorners; i++) {
                
                TypesV1.Point2D memory a = TypesV1.Point2D(
                    f.vertices[i].x,
                    f.vertices[i].y
                );
                TypesV1.Point2D memory b = TypesV1.Point2D(
                    f.vertices[j].x,
                    f.vertices[j].y
                );

                if (
                    (a.y < int32(pixelY) && b.y >= int32(pixelY)) ||
                    (b.y < int32(pixelY) && a.y >= int32(pixelY))
                ) {
                    int32 t = int32(a.x) + (int32(pixelY) - int32(a.y)) / (int32(b.y) - int32(a.y)) * (int32(b.x) - int32(a.x));
                    nodeX[nodes++] = t;
                }

                j = i;
            }

            if(nodes == 0) {
                continue; // nothing to draw
            }

            i = 0;
            while (i < nodes - 1) {
                if (nodeX[i] > nodeX[i + 1]) {
                    (nodeX[i], nodeX[i + 1]) = (nodeX[i + 1], nodeX[i]);
                    if (i != 0) i--;
                } else {
                    i++;
                }
            }

            for (i = 0; i < nodes; i += 2) {
                
                if (nodeX[i] >= int32(f.chunk.startX) + int16(f.chunk.chunkHeight)) break;
                if (nodeX[i + 1] <= int32(f.chunk.startX)) continue;
                if (nodeX[i] < int32(f.chunk.startX)) nodeX[i] = int32(f.chunk.startX);                
                if (nodeX[i + 1] > int32(f.chunk.startX) + int16(f.chunk.chunkHeight))
                    nodeX[i + 1] = int32(int32(f.chunk.startX) + int16(f.chunk.chunkHeight));

                for (
                    int32 pixelX = nodeX[i];
                    pixelX < nodeX[i + 1];
                    pixelX++
                ) {
                    if (pixelX >= int32(f.chunk.startX) + int16(f.chunk.chunkHeight)) continue;

                    int32 px = int32(pixelX) - int32(f.chunk.startX);
                    int32 py = int32(pixelY) - int32(f.chunk.startY);

                    if (
                        px >= 0 &&
                        px < int16(f.chunk.chunkWidth) &&
                        py >= 0 &&
                        py < int16(f.chunk.chunkHeight)
                    ) {
                        GraphicsV1.setPixel(
                            result,
                            f.chunk.chunkWidth,
                            px,
                            py,
                            f.fillColor
                        );
                    }
                }
            }
        }

        if (f.strokeColor == f.fillColor) return;

        {
            uint256 j = f.vertices.length - 1;
            for (uint256 i = 0; i < f.vertices.length; i++) {
                TypesV1.Point2D memory a = f.vertices[i];
                TypesV1.Point2D memory b = f.vertices[j];
                line(result, GeometryV1.Line2D(a, b, f.strokeColor, f.chunk));
                j = i;
            }
            line(
                result,
                GeometryV1.Line2D(
                    f.vertices[f.vertices.length - 1],
                    f.vertices[0],
                    f.strokeColor,
                    f.chunk
                )
            );
        }
    }

    function randomGaussian(RandomV1.PRNG memory prng)
        internal
        pure
        returns (int64) {

        return RandomV1.nextGaussian(prng);
    }
}// UNLICENSED

pragma solidity ^0.8.0;


interface IRenderer {


    struct RenderArgs {
        int16 index;
        uint8 stage;
        int32 seed;        
        uint32[16384] buffer;
        RandomV1.PRNG prng;
    }

    function render(RenderArgs memory args) external view returns (RenderArgs memory results);

}// UNLICENSED

pragma solidity ^0.8.0;

interface IAttributes {


    function getAttributes(int32 seed) external view returns (string memory attributes);

}// UNLICENSED

pragma solidity ^0.8.0;


library HatchLayer {

    
    struct HatchParameters {
        uint32 opacity;
        int32 spacing;
        uint32 color;
        uint32[16] palette;
        RandomV1.PRNG prng;
    }

    function getParameters(RandomV1.PRNG memory prng) external pure returns(
        HatchParameters memory hatch) {                

        hatch.spacing = 5;
        hatch.opacity = 80;
        hatch.palette[0] = 0xFF0088DC;
        hatch.palette[1] = 0xFFB31942;
        hatch.palette[2] = 0xFFEB618F;
        hatch.palette[3] = 0xFF6A0F8E;
        hatch.palette[4] = 0xFF4FBF26;
        hatch.palette[5] = 0xFF6F4E37;
        hatch.palette[6] = 0xFFFF9966;
        hatch.palette[7] = 0xFFBED9DB;
        hatch.palette[8] = 0xFF998E80;
        hatch.palette[9] = 0xFFFFB884;
        hatch.palette[10] = 0xFF2E4347;
        hatch.palette[11] = 0xFF0A837F;
        hatch.palette[12] = 0xFF076461;
        hatch.palette[13] = 0xFF394240;
        hatch.palette[14] = 0xFFFAF4B1;
        hatch.palette[15] = 0xFFFFFFFF;
        int32 hatchColor = RandomV1.next(prng, 16);
        hatch.color = hatch.palette[uint32(hatchColor)];
        hatch.prng = prng;
    }
}// UNLICENSED

pragma solidity ^0.8.0;


library WatercolorLayer {

    uint16 public constant MAX_POLYGONS = 40960;
    uint8 public constant NUM_SIDES = 10;

    struct WatercolorParameters {
        uint8 stackCount;        
        uint32[4] stackColors;        
        int64[4] r;
        uint32[16] palette;       
        TypesV1.Point2D[MAX_POLYGONS][4] basePoly;
        uint32[4] basePolyCount;
        RandomV1.PRNG prng;      
    }    

    struct StackList {
        TypesV1.Point2D[MAX_POLYGONS] stack1;
        TypesV1.Point2D[MAX_POLYGONS] stack2;
        TypesV1.Point2D[MAX_POLYGONS] stack3;
        TypesV1.Point2D[MAX_POLYGONS] stack4;        
        uint32 stack1Count;
        uint32 stack2Count;
        uint32 stack3Count;
        uint32 stack4Count;
        RandomV1.PRNG prng;
    }

    struct CreateBasePoly {
        int64 x;
        int64 y;
        int64 r;
    }

    struct CreatePolyStack {
        int64 r;
        TypesV1.Point2D[MAX_POLYGONS] basePoly;
        uint32 basePolyCount;
    }

    struct Subdivide {
        int32 depth;
        int64 variance;
        int64 vdiv;
        TypesV1.Point2D[MAX_POLYGONS] points;
        uint32 pointCount;
        int64 x1;
        int64 y1;
        int64 x2;
        int64 y2;
    }

    struct RPoly {
        uint32 count;
        TypesV1.Point2D[MAX_POLYGONS] points;
    }

    function getParameters(RandomV1.PRNG memory prng)
        external
        pure
        returns (WatercolorParameters memory watercolors)
    {

        uint8 stackCount = uint8(uint32(RandomV1.next(prng, 2, 5)));
        watercolors.stackCount = stackCount;

        watercolors.palette[0] = 0xFF0088DC;
        watercolors.palette[1] = 0xFFB31942;
        watercolors.palette[2] = 0xFFEB618F;
        watercolors.palette[3] = 0xFF6A0F8E;
        watercolors.palette[4] = 0xFF4FBF26;
        watercolors.palette[5] = 0xFF6F4E37;
        watercolors.palette[6] = 0xFFFF9966;
        watercolors.palette[7] = 0xFFBED9DB;
        watercolors.palette[8] = 0xFF998E80;
        watercolors.palette[9] = 0xFFFFB884;
        watercolors.palette[10] = 0xFF2E4347;
        watercolors.palette[11] = 0xFF0A837F;
        watercolors.palette[12] = 0xFF076461;
        watercolors.palette[13] = 0xFF394240;
        watercolors.palette[14] = 0xFFFAF4B1;   
        watercolors.palette[15] = 0xFFFFFFFF;   

        for (uint8 i = 0; i < watercolors.stackCount; i++) {
            RandomV1.next(prng);
            RandomV1.next(prng);

            int32 stackColorIndex = RandomV1.next(prng, 16);
            uint32 stackColor = watercolors.palette[uint32(stackColorIndex)];
            stackColor = GraphicsV1.setOpacity(stackColor, 4);
            watercolors.stackColors[i] = stackColor;

            int64 x = RandomV1.next(prng, 0, 1024 /* width */) * Fix64V1.ONE;
            int64 y = RandomV1.next(prng, 0, 1024 /* height */) * Fix64V1.ONE;
            watercolors.r[i] = RandomV1.next(prng, 341 /* width / 3 */, 1024 /* width */) * Fix64V1.ONE;

            (TypesV1.Point2D[MAX_POLYGONS] memory basePoly, uint32 basePolyCount)
             = createBasePoly(
                CreateBasePoly(x, y, watercolors.r[i]),                
                prng
            );

            watercolors.basePoly[i] = basePoly;
            watercolors.basePolyCount[i] = basePolyCount;            
        }

        watercolors.prng = prng;
    }

    function buildStackList(RandomV1.PRNG memory prng, WatercolorParameters memory p)
    external pure returns(StackList memory stackList) {

        require(p.stackCount > 0 && p.stackCount < 5, "invalid stack count");

        for (uint8 i = 0; i < p.stackCount; i++) {
            
            (TypesV1.Point2D[MAX_POLYGONS] memory stack, uint32 vertexCount)
             = createPolyStack(CreatePolyStack(p.r[i],
                p.basePoly[i],
                p.basePolyCount[i]),
                prng
            );
            
            if(i == 0) {
                stackList.stack1 = stack;
                stackList.stack1Count = vertexCount;
            } else if (i == 1) {
                stackList.stack2 = stack;
                stackList.stack2Count = vertexCount;
            } else if (i == 2) {
                stackList.stack3 = stack;    
                stackList.stack3Count = vertexCount;
            } else if (i == 3) {
                stackList.stack4 = stack;    
                stackList.stack4Count = vertexCount;
            }
        }        

        stackList.prng = prng;
    }

    function createPolyStack(
        CreatePolyStack memory f,        
        RandomV1.PRNG memory prng
    ) private pure returns (
        TypesV1.Point2D[MAX_POLYGONS] memory stack,
        uint32 vertexCount) {

        
        int32 variance = RandomV1.next(
            prng,
            int32(Fix64V1.div(f.r, 10 * Fix64V1.ONE) >> 32),
            int32(Fix64V1.div(f.r, 4 * Fix64V1.ONE) >> 32)
        );            

        (TypesV1.Point2D[MAX_POLYGONS] memory poly, uint32 polyCount) = deform(
            prng,
            f.basePoly,
            f.basePolyCount,
            5,                  // depth
            variance,           // variance
            4 * Fix64V1.ONE     // vdiv
        );

        require(polyCount == MAX_POLYGONS, "invalid algorithm");
        stack = poly;
        vertexCount = polyCount;
    }    

    function createBasePoly(CreateBasePoly memory f, RandomV1.PRNG memory prng) private pure returns (TypesV1.Point2D[MAX_POLYGONS] memory stack,
        uint32 vertexCount) {

        RPoly memory rPoly = rpoly(f);        
        require(rPoly.count == 10, "invalid algorithm");
        
        (TypesV1.Point2D[MAX_POLYGONS] memory basePoly, uint32 basePolyCount) = deform(prng, rPoly.points, rPoly.count, 5, 15, 2 * Fix64V1.ONE);
        require(basePolyCount == 640, "invalid algorithm");

        return (basePoly, basePolyCount);
    }

    function rpoly(CreateBasePoly memory f)
        private
        pure
        returns (RPoly memory _rpoly)
    {

        int64 angle = Fix64V1.div(
            Fix64V1.TWO_PI,
            int8(NUM_SIDES) * Fix64V1.ONE
        );

        for (int64 a = 0; a < Fix64V1.TWO_PI; a += angle) {
            int64 sx = Fix64V1.add(f.x, Fix64V1.mul(Trig256.cos(a), f.r));
            int64 sy = Fix64V1.add(f.y, Fix64V1.mul(Trig256.sin(a), f.r));
            _rpoly.points[_rpoly.count++] = TypesV1.Point2D(int32(sx >> 32), int32(sy >> 32));
        }
    }    

    function deform(
        RandomV1.PRNG memory prng,
        TypesV1.Point2D[MAX_POLYGONS] memory points,
        uint32 pointCount,
        int32 depth,
        int32 variance,
        int64 vdiv
    ) private pure returns(TypesV1.Point2D[MAX_POLYGONS] memory newPoints, uint32 newPointCount) {


        if (pointCount < 2) {
            return (newPoints, 0);
        }

        newPointCount = 0;
        for (uint32 i = 0; i < pointCount; i++) {

            int32 sx1 = int32(points[i].x);
            int32 sy1 = int32(points[i].y);
            int32 sx2 = int32(points[(i + 1) % pointCount].x);
            int32 sy2 = int32(points[(i + 1) % pointCount].y);

            newPoints[newPointCount++] = TypesV1.Point2D(sx1, sy1);

            newPointCount = subdivide(
                Subdivide(depth, variance * Fix64V1.ONE, vdiv, newPoints, newPointCount, sx1 * Fix64V1.ONE,
                sy1 * Fix64V1.ONE,
                sx2 * Fix64V1.ONE,
                sy2 * Fix64V1.ONE),
                prng                
            );
        }

        return (newPoints, newPointCount);
    }

    function subdivide(
        Subdivide memory f,
        RandomV1.PRNG memory prng
    ) private pure returns (uint32) {

        while (true) {
            if (f.depth >= 0) {

                (int64 nx) = subdivide_midpoint(f, prng, f.x1, f.x2);
                (int64 ny) = subdivide_midpoint(f, prng, f.y1, f.y2);

                int32 vardiv2 = int32(Fix64V1.div(f.variance, f.vdiv) >> 32);
                int64 variance2 = RandomV1.next(prng, vardiv2) * Fix64V1.ONE;
                
                f.pointCount = subdivide(Subdivide(                    
                    f.depth - 1,
                    variance2,
                    f.vdiv,
                    f.points,
                    f.pointCount,
                    f.x1, f.y1, nx, ny
                ), prng);
                
                uint32 pi = f.pointCount++;
                f.points[pi] = TypesV1.Point2D(int32(nx >> 32), int32(ny >> 32));
                f.x1 = nx;
                f.y1 = ny;
                f.depth = f.depth - 1;

                int32 vardiv = int32(Fix64V1.div(f.variance, f.vdiv) >> 32);
                f.variance = RandomV1.next(prng, vardiv) * Fix64V1.ONE;
                continue;
            }

            break;
        }

        return f.pointCount;
    }

    function subdivide_midpoint(
        Subdivide memory f,
        RandomV1.PRNG memory prng,
        int64 t1,
        int64 t2
    ) private pure returns (int64) {

        int64 mid = Fix64V1.div(Fix64V1.add(t1, t2), Fix64V1.TWO);
        int64 g = RandomV1.nextGaussian(prng);
        int64 n = Fix64V1.add(mid, Fix64V1.mul(g, f.variance));
        return n;
    }
}// UNLICENSED

pragma solidity ^0.8.0;



library LCG64 {

    uint64 internal constant M = 4294967296;
    uint32 internal constant A = 1664525;
    uint32 internal constant C = 1013904223;

    function next(uint64 z) internal pure returns(uint64, int64) {                

                
        uint256 r = uint(A) * uint(z) + uint(C);            
        uint64 g = uint64(r % M);           
        
        int lz = Trig256.log_256(int64(g) * int(Fix64V1.ONE));
        int lm = Trig256.log_256(int64(M) * int(Fix64V1.ONE));
        int64 lml = Fix64V1.sub(int64(lz), int64(lm));
        int64 v = Trig256.exp(lml);

        return (g, v);
    }
}// UNLICENSED

pragma solidity ^0.8.0;



library NoiseV1 {


    uint32 private constant NOISE_TABLE_SIZE = 4095;
    
    int32 private constant PERLIN_YWRAPB = 4;
    int32 private constant PERLIN_YWRAP = 16; // 1 << PERLIN_YWRAPB
    int32 private constant PERLIN_ZWRAPB = 8;
    int32 private constant PERLIN_ZWRAP = 256; // 1 << PERLIN_ZWRAPB   
    uint8 private constant PERLIN_OCTAVES = 4;
    int64 private constant PERLIN_AMP_FALLOFF = 2147483648; // 0.5

    struct noiseFunction {
        int64[NOISE_TABLE_SIZE + 1] noiseTable;
        
        int64 x;
        int64 y;
        int64 z;

        int32 xi;
        int32 yi;
        int32 zi;

        int64 xf;
        int64 yf;
        int64 zf;

        int64 rxf;
        int64 ryf;

        int64 n1;
        int64 n2;
        int64 n3;
    }

    function buildNoiseTable(int32 seed) external pure returns (int64[4096] memory noiseTable){

        for (uint16 i = 0; i < NOISE_TABLE_SIZE + 1; i++) {
            (uint64 s, int64 v) = LCG64.next(uint32(seed));
            noiseTable[i] = v;
            seed = int32(uint32(s));
        }
    }

    function noise(
        int64[NOISE_TABLE_SIZE + 1] memory noiseTable,
        int64 x,
        int64 y
    ) external pure returns (int64) {

        return noise_impl(noiseFunction(noiseTable, x, y, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0));
    }

    function noise(noiseFunction memory f) external pure returns (int64) {

        return noise_impl(f);
    }

    function noise_impl(noiseFunction memory f) private pure returns (int64) {

        if (f.x < 0) {
            f.x = -f.x;
        }
        if (f.y < 0) {
            f.y = -f.y;
        }
        if (f.z < 0) {
            f.z = -f.z;
        }

        f.xi = int32(Fix64V1.floor(f.x) >> 32 /* FRACTIONAL_PLACES */);
        f.yi = int32(Fix64V1.floor(f.y) >> 32 /* FRACTIONAL_PLACES */);
        f.zi = int32(Fix64V1.floor(f.z) >> 32 /* FRACTIONAL_PLACES */);        

        f.xf = Fix64V1.sub(f.x, (f.xi * Fix64V1.ONE));
        f.yf = Fix64V1.sub(f.y, (f.yi * Fix64V1.ONE));
        f.zf = Fix64V1.sub(f.z, (f.zi * Fix64V1.ONE)); 
        
        int64 r = 0;
        int64 ampl = PERLIN_AMP_FALLOFF;     

        for (uint8 o = 0; o < PERLIN_OCTAVES; o++) {

            int32 off = f.xi + (f.yi << uint32(PERLIN_YWRAPB)) + (f.zi << uint32(PERLIN_ZWRAPB));
            f.rxf = scaled_cosine(f.xf);
            f.ryf = scaled_cosine(f.yf);

            f.n1 = f.noiseTable[uint32(off) & NOISE_TABLE_SIZE];
            {
                f.n1 = Fix64V1.add(f.n1, Fix64V1.mul(f.rxf, Fix64V1.sub(int64(f.noiseTable[(uint32(off) + 1) & NOISE_TABLE_SIZE]), f.n1)));                        

                f.n2 = f.noiseTable[(uint32(off) + uint32(PERLIN_YWRAP)) & NOISE_TABLE_SIZE];
                f.n2 = Fix64V1.add(f.n2, Fix64V1.mul(f.rxf, Fix64V1.sub(int64(f.noiseTable[(uint32(off) + uint32(PERLIN_YWRAP) + 1) & NOISE_TABLE_SIZE]), f.n2)));
                f.n1 = Fix64V1.add(f.n1, Fix64V1.mul(f.ryf, Fix64V1.sub(f.n2, f.n1)));

                off += PERLIN_ZWRAP;

                f.n2 = f.noiseTable[uint32(off) & NOISE_TABLE_SIZE];
                f.n2 = Fix64V1.add(f.n2, Fix64V1.mul(f.rxf, Fix64V1.sub(int64(f.noiseTable[((uint32(off) + 1)) & NOISE_TABLE_SIZE]), f.n2)));

                f.n3 = f.noiseTable[(uint32(off) + uint32(PERLIN_YWRAP)) & NOISE_TABLE_SIZE];
                f.n3 = Fix64V1.add(f.n3, Fix64V1.mul(f.rxf, Fix64V1.sub(int64(f.noiseTable[(uint32(off) + uint32(PERLIN_YWRAP) + 1) & NOISE_TABLE_SIZE]), f.n3)));
                f.n2 = Fix64V1.add(f.n2, Fix64V1.mul(f.ryf, Fix64V1.sub(f.n3, f.n2)));
                f.n1 = Fix64V1.add(f.n1, Fix64V1.mul(scaled_cosine(f.zf), Fix64V1.sub(f.n2, f.n1)));
            }           

            r = Fix64V1.add(r, Fix64V1.mul(f.n1, ampl));
            ampl = Fix64V1.mul(ampl, PERLIN_AMP_FALLOFF);

            f.xi <<= 1;
            f.xf = Fix64V1.mul(f.xf, Fix64V1.TWO);
            f.yi <<= 1;
            f.yf = Fix64V1.mul(f.yf, Fix64V1.TWO);
            f.zi <<= 1;
            f.zf = Fix64V1.mul(f.zf, Fix64V1.TWO);

            if (f.xf >= Fix64V1.ONE) {
                f.xi++;
                f.xf = f.xf - Fix64V1.ONE;
            }
            if (f.yf >= Fix64V1.ONE) {
                f.yi++;
                f.yf = f.yf - Fix64V1.ONE;
            }
            if (f.zf >= Fix64V1.ONE) {
                f.zi++;
                f.zf = f.zf - Fix64V1.ONE;
            }
        }

        return r;
    }

    function scaled_cosine(int64 i)
        private
        pure
        returns (int64)
    {

        int64 angle = Fix64V1.mul(i, Fix64V1.PI);      
        int64 cosine = Trig256.cos(angle);
        int64 scaled = Fix64V1.mul(
                2147483648, /* 0.5f */
                Fix64V1.sub(Fix64V1.ONE, cosine)
            );        

        return scaled;            
    }
}// UNLICENSED

pragma solidity ^0.8.0;



library ParticleV1 {

    uint16 internal constant NOISE_TABLE_SIZE = 4096;

    struct Particle2D {
        int64 ox;
        int64 oy;
        int64 px;
        int64 py;
        int64 x;
        int64 y;
        uint32 frames;
        bool dead;
        TypesV1.Point2D force;
        uint8 _lifetime;
        int64 _forceScale;
        int64 _noiseScale;
    }

    function update(
        int64[NOISE_TABLE_SIZE] memory noiseTable,
        Particle2D memory p,
        uint256 width,
        uint256 height
    ) internal pure {

        p.frames++;

        if (p.frames >= p._lifetime) {
            p.dead = true;
            return;
        }

        p.force = forceAt(noiseTable, p, p.x, p.y);

        if (
            p.x >= int256(width) + int256(width) / 2 ||
            p.x < -int256(width) / 2 ||
            p.y >= int256(height) + int256(height) / 2 ||
            p.y < -int256(height) / 2
        ) {
            p.dead = true;
            return;
        }

        p.px = p.x;
        p.py = p.y;                

        p.x += int64(p.force.x);
        p.y += int64(p.force.y);        
    }

    function forceAt(
        int64[NOISE_TABLE_SIZE] memory noiseTable,
        Particle2D memory p,
        int64 x,
        int64 y
    ) internal pure returns (TypesV1.Point2D memory force) {


        int64 nx = Fix64V1.mul(x * Fix64V1.ONE, p._noiseScale);       
        int64 ny = Fix64V1.mul(y * Fix64V1.ONE, p._noiseScale);
        
        int64 noise = NoiseV1.noise(noiseTable, nx, ny);
        int64 theta = Fix64V1.mul(noise, Fix64V1.TWO_PI);

        return forceFromAngle(p, theta);
    }

    function forceFromAngle(Particle2D memory p, int64 theta)
        internal
        pure
        returns (TypesV1.Point2D memory force)
    {

        int64 px = Trig256.cos(theta);
        int64 py = Trig256.sin(theta);

        int64 pxl = Fix64V1.mul(px, p._forceScale) >> 32 /* FRACTIONAL_PLACES */;
        int64 pyl = Fix64V1.mul(py, p._forceScale) >> 32 /* FRACTIONAL_PLACES */;        
        
        force = TypesV1.Point2D(int32(pxl), int32(pyl));
    }
}// UNLICENSED

pragma solidity ^0.8.0;



abstract contract ParticleSetV1 {
    uint16 internal constant NOISE_TABLE_SIZE = 4095;
    uint16 internal constant PARTICLE_TABLE_SIZE = 5000;

    struct ParticleSet2D {
        ParticleV1.Particle2D[5000] particles;
        bool dead;
    }
    
    function update(
        int64[NOISE_TABLE_SIZE + 1] memory noiseTable,
        ParticleSet2D memory set,
        uint16 particleCount,
        uint256 width,
        uint256 height
    ) internal pure {
        set.dead = true;
        for (uint16 i = 0; i < particleCount; i++) {
            ParticleV1.Particle2D memory p = set.particles[i];
            if (p.dead) {
                continue;
            }
            set.dead = false;
            ParticleV1.update(noiseTable, p, width, height);
        }
    }

    function draw(
        ParticleSet2D memory set,
        uint16 particleCount,
        uint32[16384] memory result,
        TypesV1.Chunk2D memory chunk
    ) internal pure {
        if (set.dead) {
            return;
        }

        for (uint256 i = 0; i < particleCount; i++) {
            ParticleV1.Particle2D memory p = set.particles[i];
            if (p.dead) {
                continue;
            }
            step(p, result, chunk);
        }
    }

    function step(
        ParticleV1.Particle2D memory p, uint32[16384] memory result,
        TypesV1.Chunk2D memory chunk
    ) internal pure virtual;
}// UNLICENSED

pragma solidity ^0.8.0;



library ParticleSetFactoryV1 {

    uint16 internal constant PARTICLE_TABLE_SIZE = 5000;

    struct CreateParticleSet2D {
        int32 seed;
        uint32 range;
        uint16 width;
        uint16 height;
        uint16 n;
        int64 forceScale;
        int64 noiseScale;
        uint8 lifetime;
    }

    function createSet(CreateParticleSet2D memory f, RandomV1.PRNG memory prng)
        external
        pure
        returns (ParticleSetV1.ParticleSet2D memory set, RandomV1.PRNG memory)
    {

        ParticleV1.Particle2D[PARTICLE_TABLE_SIZE] memory particles;

        for (uint16 i = 0; i < f.n; i++) {  

            int256 px = RandomV1.next(
                prng,
                -int32(f.range),
                int16(f.width) + int32(f.range)
            );

            int256 py = RandomV1.next(
                prng,
                -int32(f.range),
                int16(f.height) + int32(f.range)
            );

            ParticleV1.Particle2D memory particle = ParticleV1.Particle2D(
                int64(px),
                int64(py),
                0,
                0,
                int64(px),
                int64(py),
                0,
                false,
                TypesV1.Point2D(0, 0),
                f.lifetime,
                f.forceScale,
                f.noiseScale
            );
            particles[i] = particle;
        }

        set.particles = particles;
        return (set, prng);
    }
}// UNLICENSED

pragma solidity ^0.8.0;


library KintsugiLayer {


    uint16 public constant PARTICLE_COUNT = 5000;
    uint8 public constant PARTICLE_RANGE = 65;
    uint8 public constant PARTICLE_LIFETIME = 100;
    int64 public constant PARTICLE_FORCE_SCALE = 15 * 4294967296; /* 15 * Fix64V1.ONE */
    int64 public constant PARTICLE_NOISE_SCALE = 42949673; /* 0.01 */

    struct KintsugiParameters {
        uint8 layers;        
        uint256 frame;
        uint256 iteration;
        ParticleSetV1.ParticleSet2D[4] particleSets;
    }

    function getParameters(RandomV1.PRNG memory prng, int32 seed) 
    external pure returns (KintsugiParameters memory kintsugi, RandomV1.PRNG memory) {

        kintsugi.layers = uint8(uint32(RandomV1.next(prng, 1, 5)));

        for (uint256 i = 0; i < kintsugi.layers; i++) {
            (ParticleSetV1.ParticleSet2D memory particleSet, RandomV1.PRNG memory p) = ParticleSetFactoryV1.createSet(
                ParticleSetFactoryV1.CreateParticleSet2D(
                    seed,
                    PARTICLE_RANGE,
                    1024,
                    1024,
                    PARTICLE_COUNT,                    
                    PARTICLE_FORCE_SCALE,
                    PARTICLE_NOISE_SCALE,
                    PARTICLE_LIFETIME                                        
                ),
                prng
            );
            prng = p;                
            kintsugi.particleSets[i] = particleSet;            
        }

        return (kintsugi, prng);
    }
}// UNLICENSED

pragma solidity ^0.8.0;


library HatchDraw {


    struct Draw {
        uint32[16384] result;
        HatchLayer.HatchParameters parameters;
        TypesV1.Chunk2D chunk;
    }

    function draw(Draw memory f) external pure returns (uint32[16384] memory buffer) {

        uint32 color = GraphicsV1.setOpacity(
            f.parameters.color,
            f.parameters.opacity
        );

        for (int32 i = f.parameters.spacing; i < 1024; i += f.parameters.spacing) {
            ProcessingV1.line(
                f.result,
                GeometryV1.Line2D(
                    TypesV1.Point2D(i, 0),
                    TypesV1.Point2D(0, i),
                    color,
                    f.chunk
                )
            );
            ProcessingV1.line(
                f.result,
                GeometryV1.Line2D(
                    TypesV1.Point2D(1024 - i - 3, 1024),
                    TypesV1.Point2D(1024, 1024 - i - 3),
                    color,
                    f.chunk
                )
            );
            ProcessingV1.line(
                f.result,
                GeometryV1.Line2D(
                    TypesV1.Point2D(i, 1024),
                    TypesV1.Point2D(0, 1024 - i),
                    color,
                    f.chunk
                )
            );
            ProcessingV1.line(
                f.result,
                GeometryV1.Line2D(
                    TypesV1.Point2D(i - 4, 0),
                    TypesV1.Point2D(1024, 1024 - i + 4),
                    color,
                    f.chunk
                )
            );
        }

        ProcessingV1.line(
            f.result,
            GeometryV1.Line2D(
                TypesV1.Point2D(1024 - 4, 1024),
                TypesV1.Point2D(1024, 1024 - 4),
                color,
                f.chunk
            )
        );
        ProcessingV1.line(
            f.result,
            GeometryV1.Line2D(
                TypesV1.Point2D(1024 - 3, 0),
                TypesV1.Point2D(1024, 3),
                color,
                f.chunk
            )
        );

        return f.result;
    }
}// UNLICENSED

pragma solidity ^0.8.0;


library KintsugiDraw {


    struct Draw {
        uint32[16384] result;
        KintsugiLayer.KintsugiParameters p;
        int64[4096] noiseTable;
        TypesV1.Chunk2D chunk;
    }

    uint16 internal constant NOISE_TABLE_SIZE = 4095;
    uint16 internal constant PARTICLE_COUNT = 5000;
    uint16 internal constant FRAME_COUNT = 400;
    
    function draw(Draw memory f) external pure returns(uint32[16384] memory buffer) {

        f.p.iteration = 0;
        f.p.frame = 0;

        while (f.p.frame < FRAME_COUNT) {
            f.p.frame++;

            if (f.p.iteration >= f.p.layers) {
                break;
            }

            bool dead = true;
            {
                for (uint256 i = 0; i < f.p.layers; i++) {
                    ParticleSetV1.ParticleSet2D memory particleSet = f.p.particleSets[i];
                    update(
                        f.noiseTable,
                        particleSet,
                        PARTICLE_COUNT,
                        f.chunk.width,
                        f.chunk.height
                    );
                    if (!particleSet.dead) {
                        dead = false;
                    }
                    draw(particleSet, PARTICLE_COUNT, f.result, f.chunk);
                }
            }

            if (dead) {
                f.p.iteration++;
            }
        }

        return f.result;
    }

    function update(
        int64[NOISE_TABLE_SIZE + 1] memory noiseTable,
        ParticleSetV1.ParticleSet2D memory set,
        uint16 particleCount,
        uint256 width,
        uint256 height
    ) internal pure {

        set.dead = true;
        for (uint16 i = 0; i < particleCount; i++) {
            ParticleV1.Particle2D memory p = set.particles[i];
            if (p.dead) {
                continue;
            }
            set.dead = false;
            ParticleV1.update(noiseTable, p, width, height);
        }
    }

    function draw(
        ParticleSetV1.ParticleSet2D memory set,
        uint16 particleCount,
        uint32[16384] memory result,
        TypesV1.Chunk2D memory chunk
    ) internal pure {

        if (set.dead) {
            return;
        }

        for (uint256 i = 0; i < particleCount; i++) {
            ParticleV1.Particle2D memory p = set.particles[i];
            if (p.dead) {
                continue;
            }
            step(p, result, chunk);
        }
    }

    function step(
        ParticleV1.Particle2D memory p,
        uint32[16384] memory result,
        TypesV1.Chunk2D memory chunk
    ) internal pure {

        if (p.frames < 40) {
            return;
        }

        uint32 dark = GraphicsV1.setOpacity(0xFFF4BB29, 10);

        TypesV1.Point2D memory v0 = TypesV1.Point2D(int32(p.x), int32(p.y));
        TypesV1.Point2D memory v1 = TypesV1.Point2D(int32(p.px), int32(p.py));

        ProcessingV1.line(
            result,
            GeometryV1.Line2D(
                TypesV1.Point2D(v0.x, v0.y - 2),
                TypesV1.Point2D(v1.x, v1.y - 2),
                dark,
                chunk
            )
        );
        ProcessingV1.line(
            result,
            GeometryV1.Line2D(
                TypesV1.Point2D(v0.x, v0.y + 2),
                TypesV1.Point2D(v1.x, v1.y + 2),
                dark,
                chunk
            )
        );

        uint32 bright = GraphicsV1.setOpacity(0xFFD5B983, 10);

        ProcessingV1.line(
            result,
            GeometryV1.Line2D(
                TypesV1.Point2D(v0.x, v0.y - 1),
                TypesV1.Point2D(v1.x, v1.y - 1),
                bright,
                chunk
            )
        );
        ProcessingV1.line(
            result,
            GeometryV1.Line2D(
                TypesV1.Point2D(v0.x, v0.y),
                TypesV1.Point2D(v1.x, v1.y),
                bright,
                chunk
            )
        );
        ProcessingV1.line(
            result,
            GeometryV1.Line2D(
                TypesV1.Point2D(v0.x, v0.y + 1),
                TypesV1.Point2D(v1.x, v1.y + 1),
                bright,
                chunk
            )
        );
    }
}// UNLICENSED

pragma solidity ^0.8.0;


library WatercolorDraw {

    uint16 public constant MAX_POLYGONS = 40960;
    
    struct Draw {
        uint32[16384] result;
        WatercolorLayer.WatercolorParameters p;
        WatercolorLayer.StackList stackList;
        TypesV1.Chunk2D chunk;
    }

    function draw(Draw memory f)
        external
        pure
        returns (uint32[16384] memory buffer)
    {

        for (uint8 s = 0; s < f.p.stackCount; s++) {
            
            TypesV1.Point2D[MAX_POLYGONS] memory stack;
            uint32 vertexCount;

            if (s == 0) {
                stack = f.stackList.stack1;
                vertexCount = f.stackList.stack1Count;
            } else if (s == 1) {
                stack = f.stackList.stack2;
                vertexCount = f.stackList.stack2Count;
            } else if (s == 2) {
                stack = f.stackList.stack3;
                vertexCount = f.stackList.stack3Count;
            } else if (s == 3) {
                stack = f.stackList.stack4;
                vertexCount = f.stackList.stack4Count;
            }

            uint32 fillColor = f.p.stackColors[s];

            require(vertexCount == MAX_POLYGONS, "invalid vertex count");
            
            ProcessingV1.polygon(
                    f.result,
                    GeometryV1.Polygon2D(
                        stack,
                        vertexCount,
                        fillColor,
                        fillColor,                            
                        f.chunk
                    )
                );
        }

        return f.result;
    }
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
}// UNLICENSED

pragma solidity ^0.8.0;



contract Kintsugi is IRenderer, IAttributes {


    using Address for address;

    address private _owner;
    address private _executor;

    constructor(address executor) {
        require(executor.isContract(), "invalid executor");
        _owner = msg.sender;
        _executor = executor;
    }

    function changeExecutor(address newExecutor) public {

        require(msg.sender == _owner, "owner only");
        require(newExecutor != address(0x0), "address must be set");
        _executor = newExecutor;        
    }

    function getAttributes(int32 seed)
        external
        view
        override        
        returns (string memory result)
    {

        require(msg.sender == _owner || msg.sender == _executor, "denied");
        require(seed != 0, "seed not specified");
        
        RandomV1.PRNG memory prng = RandomV1.buildSeedTable(seed);
        
        result = string(abi.encodePacked('{"attributes":['));

        {
            (HatchLayer.HatchParameters memory h) = HatchLayer.getParameters(prng);                        
            prng = h.prng;

            result = string(abi.encodePacked(result, '{"trait_type":"hatch_color","value":"'));
            result = string(abi.encodePacked(result, getColorName(h.color)));
            result = string(abi.encodePacked(result, '"},'));
        }

        {
            (WatercolorLayer.WatercolorParameters memory w) = WatercolorLayer.getParameters(prng);
            prng = w.prng;
            
            result = string(abi.encodePacked(result, '{"trait_type":"watercolor_count","value":"'));
            result = string(abi.encodePacked(result, Strings.toString(w.stackCount)));  
            result = string(abi.encodePacked(result, '"},'));

            for(uint8 i = 0; i < w.stackCount; i++) {
                result = string(abi.encodePacked(result, '{"trait_type":"watercolor_', Strings.toString(i + 1), '_color","value":"'));
                result = string(abi.encodePacked(result, getColorName(w.stackColors[i])));
                result = string(abi.encodePacked(result, '"},'));
            }
        }

        {
            (KintsugiLayer.KintsugiParameters memory k, RandomV1.PRNG memory p) = KintsugiLayer.getParameters(prng, seed);
            prng = p;       
            
            result = string(abi.encodePacked(result, '{"trait_type":"kintsugi_layers","value":"'));
            result = string(abi.encodePacked(result, Strings.toString(k.layers)));
            result = string(abi.encodePacked(result, '"}'));
        }

        return string(abi.encodePacked(result, ']}'));
    }

    function getColorName(uint32 color) private pure returns(string memory colorName) {


        color = GraphicsV1.setOpacity(color, 255);

        if(color == 0xFF0088DC) {
            return string(abi.encodePacked('Blue Cola'));    
        } else if(color == 0xFFB31942) {
            colorName = string(abi.encodePacked('American Red'));    
        } else if(color == 0xFFEB618F) {
            colorName = string(abi.encodePacked('Pastel Rose'));    
        } else if(color == 0xFF6A0F8E) {
            colorName = string(abi.encodePacked('Vivid Purple'));    
        } else if(color == 0xFF4FBF26) {
            colorName = string(abi.encodePacked('Perfect Green'));    
        } else if(color == 0xFF6F4E37) {
            colorName = string(abi.encodePacked('Coffee'));    
        } else if(color == 0xFFFF9966) {
            colorName = string(abi.encodePacked('Atomic Tangerine'));    
        } else if(color == 0xFFBED9DB) {
            colorName = string(abi.encodePacked('Phosphate Turquoise'));    
        } else if(color == 0xFF998E80) {
            colorName = string(abi.encodePacked('Hankey Brown'));    
        } else if(color == 0xFFFFB884) {
            colorName = string(abi.encodePacked('Coral Gold'));    
        } else if(color == 0xFF2E4347) {
            colorName = string(abi.encodePacked('Metallic Gray'));    
        } else if(color == 0xFF0A837F) {
            colorName = string(abi.encodePacked('Green Hills'));    
        } else if(color == 0xFF076461) {
            colorName = string(abi.encodePacked('Evening Green Hills'));    
        } else if(color == 0xFF394240) {
            colorName = string(abi.encodePacked('Private Black'));    
        } else if(color == 0xFFFAF4B1) {
            colorName = string(abi.encodePacked('Yellow Moon'));    
        } else if(color == 0xFFFFFFFF) {
            colorName = string(abi.encodePacked('White'));    
        } else {
            colorName = string(abi.encodePacked('Unknown'));    
        } 
    }

    function render(IRenderer.RenderArgs memory args)
        external
        view
        override
        returns (IRenderer.RenderArgs memory results)
    {

        require(msg.sender == _owner || msg.sender == _executor, "denied");
        require(args.index != -1, "rendering is finished");
        require(args.index >= 0 && args.index < 64, "index must be in range 0-63");
        require(args.stage >= 0 && args.stage < 104, "stage must be in range 0-103");
        require(args.seed != 0, "seed not specified");

        RandomV1.PRNG memory prng = RandomV1.buildSeedTable(args.seed);

        HatchLayer.HatchParameters memory hatch;
        {           
            (HatchLayer.HatchParameters memory h) = HatchLayer.getParameters(prng);
            hatch = h;
            prng = h.prng;
        }

        WatercolorLayer.WatercolorParameters memory watercolors;
        {
            (WatercolorLayer.WatercolorParameters memory w) = WatercolorLayer.getParameters(prng);
            watercolors = w;
            prng = w.prng;
        }

        KintsugiLayer.KintsugiParameters memory kintsugi;
        {
            (KintsugiLayer.KintsugiParameters memory k, RandomV1.PRNG memory p) = KintsugiLayer.getParameters(prng, args.seed);
            kintsugi = k;
            prng = p;
        }        

        if(args.stage == 0)
        {
            return background_stage(args);
        }
        else if(args.stage == 1)
        {
            return hatch_stage(hatch, prng, args);
        }
        else if(args.stage > 1 && args.stage < 103)
        {
            return watercolor_stage(watercolors, args.prng, args);
        }       
        else if(args.stage == 103)
        {
            return kintsugi_stage(kintsugi, args);
        } 
        else {
            revert("invalid render arguments");
        }        
    }

    function background_stage(IRenderer.RenderArgs memory args) private pure returns (IRenderer.RenderArgs memory results) {

        ProcessingV1.background(
            args.buffer,
            0xFF3B4248,
            TypesV1.Chunk2D(
                uint16(args.index),
                1024,
                1024,
                128,
                128,
                (uint16(args.index) % 8) * 128,
                (uint16(args.index) / 8) * 128
            )
        );
        return IRenderer.RenderArgs(args.index, args.stage + 1, args.seed, args.buffer, args.prng);
    }

    function hatch_stage(HatchLayer.HatchParameters memory hatch, RandomV1.PRNG memory prng, RenderArgs memory args) private pure returns (IRenderer.RenderArgs memory results) {


        require(hatch.opacity > 0, "opacity not set");
        require(hatch.spacing > 0, "spacing not set");
        require(hatch.color > 0, "color not set");
        
        uint32[16384] memory buffer = HatchDraw.draw(HatchDraw.Draw(
            args.buffer,
            hatch,
            TypesV1.Chunk2D(
                uint16(args.index),
                1024,
                1024,
                128,
                128,
                (uint16(args.index) % 8) * 128,
                (uint16(args.index) / 8) * 128
            ))
        );

        return IRenderer.RenderArgs(args.index, args.stage + 1, args.seed, buffer, prng);
    }

    function watercolor_stage(WatercolorLayer.WatercolorParameters memory watercolors, RandomV1.PRNG memory prng, IRenderer.RenderArgs memory args) private pure returns (IRenderer.RenderArgs memory results) {

        require(watercolors.stackCount > 0, "stackCount not set");
        require(watercolors.stackColors.length > 0, "stackColors not set");
                
        WatercolorLayer.StackList memory stackList;
        {
            (WatercolorLayer.StackList memory s) = WatercolorLayer.buildStackList(prng, watercolors);                        
            stackList = s;
            prng = s.prng;
        }    

        uint32[16384] memory buffer = WatercolorDraw.draw(
            WatercolorDraw.Draw(
                args.buffer,
                watercolors,
                stackList,
                TypesV1.Chunk2D(
                    uint16(args.index),
                    1024,
                    1024,
                    128,
                    128,
                    (uint16(args.index) % 8) * 128,
                    (uint16(args.index) / 8) * 128
                )
            )
        );

        return IRenderer.RenderArgs(args.index, args.stage + 1, args.seed, buffer, prng);
    }

    function kintsugi_stage(KintsugiLayer.KintsugiParameters memory kintsugi, IRenderer.RenderArgs memory args)
        private pure returns (IRenderer.RenderArgs memory results) {

        
        require(kintsugi.layers > 0, "layers not set");

        int64[4096] memory noiseTable = NoiseV1.buildNoiseTable(args.seed);
        
        uint32[16384] memory buffer = KintsugiDraw.draw(KintsugiDraw.Draw(
            args.buffer,
            kintsugi,
            noiseTable,
            TypesV1.Chunk2D(
                uint16(args.index),
                1024,
                1024,
                128,
                128,
                (uint16(args.index) % 8) * 128,
                (uint16(args.index) / 8) * 128
            ))
        );

        return IRenderer.RenderArgs(args.index == 63 ? -1 : args.index + 1, 0, args.seed, buffer, args.prng);
    }
}// UNLICENSED

pragma solidity ^0.8.0;


contract CityLights {


    using Address for address;

    address private _owner;
    address private _executor;

    constructor(address executor) {
        require(executor.isContract(), "invalid executor");
        _owner = msg.sender;
        _executor = executor;
    }

    function changeExecutor(address newExecutor) public {

        require(msg.sender == _owner, "owner only");
        require(newExecutor != address(0x0), "address must be set");
        _executor = newExecutor;        
    }
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


abstract contract ERC721Burnable is Context, ERC721 {
    function burn(uint256 tokenId) public virtual {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721Burnable: caller is not owner nor approved");
        _burn(tokenId);
    }
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
}// MIT

pragma solidity ^0.8.0;


abstract contract ERC721Pausable is ERC721, Pausable {
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual override {
        super._beforeTokenTransfer(from, to, tokenId);

        require(!paused(), "ERC721Pausable: token transfer while paused");
    }
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


interface IAccessControlEnumerable is IAccessControl {
    function getRoleMember(bytes32 role, uint256 index) external view returns (address);

    function getRoleMemberCount(bytes32 role) external view returns (uint256);
}// MIT

pragma solidity ^0.8.0;

library EnumerableSet {

    struct Set {
        bytes32[] _values;
        mapping(bytes32 => uint256) _indexes;
    }

    function _add(Set storage set, bytes32 value) private returns (bool) {
        if (!_contains(set, value)) {
            set._values.push(value);
            set._indexes[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

    function _remove(Set storage set, bytes32 value) private returns (bool) {
        uint256 valueIndex = set._indexes[value];

        if (valueIndex != 0) {

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;

            if (lastIndex != toDeleteIndex) {
                bytes32 lastvalue = set._values[lastIndex];

                set._values[toDeleteIndex] = lastvalue;
                set._indexes[lastvalue] = valueIndex; // Replace lastvalue's index to valueIndex
            }

            set._values.pop();

            delete set._indexes[value];

            return true;
        } else {
            return false;
        }
    }

    function _contains(Set storage set, bytes32 value) private view returns (bool) {
        return set._indexes[value] != 0;
    }

    function _length(Set storage set) private view returns (uint256) {
        return set._values.length;
    }

    function _at(Set storage set, uint256 index) private view returns (bytes32) {
        return set._values[index];
    }

    function _values(Set storage set) private view returns (bytes32[] memory) {
        return set._values;
    }


    struct Bytes32Set {
        Set _inner;
    }

    function add(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _add(set._inner, value);
    }

    function remove(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _remove(set._inner, value);
    }

    function contains(Bytes32Set storage set, bytes32 value) internal view returns (bool) {
        return _contains(set._inner, value);
    }

    function length(Bytes32Set storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    function at(Bytes32Set storage set, uint256 index) internal view returns (bytes32) {
        return _at(set._inner, index);
    }

    function values(Bytes32Set storage set) internal view returns (bytes32[] memory) {
        return _values(set._inner);
    }


    struct AddressSet {
        Set _inner;
    }

    function add(AddressSet storage set, address value) internal returns (bool) {
        return _add(set._inner, bytes32(uint256(uint160(value))));
    }

    function remove(AddressSet storage set, address value) internal returns (bool) {
        return _remove(set._inner, bytes32(uint256(uint160(value))));
    }

    function contains(AddressSet storage set, address value) internal view returns (bool) {
        return _contains(set._inner, bytes32(uint256(uint160(value))));
    }

    function length(AddressSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    function at(AddressSet storage set, uint256 index) internal view returns (address) {
        return address(uint160(uint256(_at(set._inner, index))));
    }

    function values(AddressSet storage set) internal view returns (address[] memory) {
        bytes32[] memory store = _values(set._inner);
        address[] memory result;

        assembly {
            result := store
        }

        return result;
    }


    struct UintSet {
        Set _inner;
    }

    function add(UintSet storage set, uint256 value) internal returns (bool) {
        return _add(set._inner, bytes32(value));
    }

    function remove(UintSet storage set, uint256 value) internal returns (bool) {
        return _remove(set._inner, bytes32(value));
    }

    function contains(UintSet storage set, uint256 value) internal view returns (bool) {
        return _contains(set._inner, bytes32(value));
    }

    function length(UintSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    function at(UintSet storage set, uint256 index) internal view returns (uint256) {
        return uint256(_at(set._inner, index));
    }

    function values(UintSet storage set) internal view returns (uint256[] memory) {
        bytes32[] memory store = _values(set._inner);
        uint256[] memory result;

        assembly {
            result := store
        }

        return result;
    }
}// MIT

pragma solidity ^0.8.0;


abstract contract AccessControlEnumerable is IAccessControlEnumerable, AccessControl {
    using EnumerableSet for EnumerableSet.AddressSet;

    mapping(bytes32 => EnumerableSet.AddressSet) private _roleMembers;

    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IAccessControlEnumerable).interfaceId || super.supportsInterface(interfaceId);
    }

    function getRoleMember(bytes32 role, uint256 index) public view override returns (address) {
        return _roleMembers[role].at(index);
    }

    function getRoleMemberCount(bytes32 role) public view override returns (uint256) {
        return _roleMembers[role].length();
    }

    function grantRole(bytes32 role, address account) public virtual override(AccessControl, IAccessControl) {
        super.grantRole(role, account);
        _roleMembers[role].add(account);
    }

    function revokeRole(bytes32 role, address account) public virtual override(AccessControl, IAccessControl) {
        super.revokeRole(role, account);
        _roleMembers[role].remove(account);
    }

    function renounceRole(bytes32 role, address account) public virtual override(AccessControl, IAccessControl) {
        super.renounceRole(role, account);
        _roleMembers[role].remove(account);
    }

    function _setupRole(bytes32 role, address account) internal virtual override {
        super._setupRole(role, account);
        _roleMembers[role].add(account);
    }
}// UNLICENSED

pragma solidity ^0.8.0;



contract Kohi is Context, AccessControlEnumerable, ERC721, ERC721Enumerable, ERC721Pausable, ERC721Burnable {

    using Address for address;

    struct Collection {
        string name;
        string baseTokenUri;        
        string description;
        string license;
        uint priceInWei;
        int32 seed;
        uint minted;
        uint mintedMax;        
        uint mintedMaxPerOwner;
        uint pauseAt;
        bool paused;
        bool active;        
        string[] creatorNames;
        address payable[] creatorAddresses; 
        uint8[] creatorSplits;
        bool useAllowList;
        address[] allowList;        
        address _renderer;
    }
    
    mapping(bytes32 => Collection) internal collections;   
    
    event CollectionMinted (
        bytes32 indexed collectionId,
        uint256 indexed tokenId,        
        address indexed recipient,        
        uint256 mintId,
        uint256 priceInWei,
        int32 seed
    );

    event CollectionAdded (
        bytes32 indexed collectionId
    );

    uint private lastTokenId;
    mapping(bytes32 => uint[]) private collectionTokens;        
    mapping(bytes32 => int32[]) private collectionSeeds;
    mapping(bytes32 => mapping(address => uint)) private ownerMints;

    mapping(uint => bytes32) internal tokenCollection;
    mapping(uint => int32) internal tokenSeed;

    uint8 private ownerRoyalty;
    address payable[] private ownerAddresses; 
    uint8[] private ownerSplits;
    address[] private bloomList;
    mapping(address => bool) private inBloomList;
    
    address internal _admin;

    constructor() ERC721("Kohi", "KOHI") {        
        lastTokenId = 0;
        _admin = _msgSender();
        _contractUri = "https://kohi.art/metadata";
        _pause();
    }

    string private _contractUri;

    function contractURI() public view returns (string memory) {
        return _contractUri;
    }

    function updateContractUri(string memory contractUri) public {
        require(_msgSender() == _admin, "admin only");
        _contractUri = contractUri;
    }

    function updateAdmin(address newAdmin) public {
        require(_msgSender() == _admin, "admin only");
        require(newAdmin != address(0x0), "address must be set");
        _admin = newAdmin;       
    }

    function updateOwnerData(uint8 royalty, address payable[] memory addresses, uint8[] memory splits) public {
        require(_msgSender() == _admin, "admin only");
        require(royalty > 0 && royalty <= 100, "invalid owner royalty");
        require(splits.length == addresses.length, "invalid owner splits");
        ownerRoyalty = royalty;
        ownerAddresses = addresses;
        ownerSplits = splits;
    }

    function togglePaused() public {
        require(_msgSender() == _admin, "admin only");
        if(paused()) {
            _unpause();
        }
        else {
            _pause();
        }
    }  

    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(AccessControlEnumerable, ERC721, ERC721Enumerable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual override (ERC721, ERC721Enumerable, ERC721Pausable) {
        super._beforeTokenTransfer(from, to, tokenId);    
        require(inBloomList[_msgSender()] || !collections[tokenCollection[tokenId]].paused, "collection paused");                    
    }

    function isInBloomList(address _address) external view returns (bool) {
        require(_msgSender() == _admin, "admin only");
        return inBloomList[_address];        
    }

    function getBloomList() external view returns (address[] memory) {
        require(_msgSender() == _admin, "admin only");
        return bloomList;
    }

    function addToBloomList(address _address) external {
        require(_msgSender() == _admin, "admin only");
        require(_address != address(0x0) && !_address.isContract(), "invalid address");
        bloomList.push(_address);
        inBloomList[_address] = true;
    }

    function setBloomList(address[] memory _addresses) external {
        require(_msgSender() == _admin, "admin only");
        require(bloomList.length == 0, "bloom list exists");
        bloomList = _addresses;
        for(uint i = 0; i < bloomList.length; i++) {
            inBloomList[bloomList[i]] = true;
        }
    }

    function removeFromBloomList(address _address) external {
        require(_msgSender() == _admin, "admin only");
        int index = getBloomAddressIndex(_address);
        require(index > -1, "address not found");        
        if (uint(index) >= bloomList.length) return;
        for (uint i = uint(index); i < bloomList.length - 1; i++) {
            bloomList[i] = bloomList[i + 1];
        }
        bloomList.pop();  
        inBloomList[_address] = false;
    }

    function getBloomAddressIndex(address _address) private view returns(int) {
        for(int i = 0; i < int(bloomList.length); i++) {
            if(bloomList[uint(i)] == _address)
                return i;
        }
        return -1;
    }

    function getCollection(bytes32 collectionId) public view returns (Collection memory collection) {
        require(collectionId.length > 0, "ID must be set");
        collection = collections[collectionId];
        require(bytes(collections[collectionId].name).length > 0, "collection not found");        
    }

    function addCollection(Collection memory collection) external {
        require(_msgSender() == _admin, "admin only");
        require(bytes(collection.name).length > 0, "name must be set");
        
        bytes32 id = keccak256(abi.encodePacked(collection.name));
        require(bytes(collections[id].name).length == 0, "collection already added");
        require(collection._renderer != address(0x0) && collection._renderer.isContract(), "invalid renderer");

        collections[id] = collection;
        emit CollectionAdded(id);
    }

    function updateCollection(bytes32 collectionId, Collection memory collection) public {
        require(_msgSender() == _admin, "admin only");
        require(bytes(collection.name).length > 0, "name must be set");
        
        collectionId = keccak256(abi.encodePacked(collection.name));
        require(bytes(collections[collectionId].name).length > 0, "collection not found");
        require(collection._renderer != address(0x0) && collection._renderer.isContract(), "invalid renderer");

        collections[collectionId] = collection;
    }
        
    function setSeed(bytes32 collectionId, int32 seed) external {  
        require(_msgSender() == _admin, "admin only");
        require(seed != 0, "invalid seed");
        require(collections[collectionId].seed == 0, "seed already set");
        collections[collectionId].seed = seed;
    }

    function getSeed(bytes32 collectionId) external view returns (int32) {  
        require(_msgSender() == _admin, "admin only");
        require(collections[collectionId].seed != 0, "seed not set");
        return collections[collectionId].seed;
    }

    function purchase(bytes32 collectionId) external payable {
        purchaseFor(collectionId, _msgSender());
    }

    function purchaseFor(bytes32 collectionId, address recipient) public payable {
        require(!_msgSender().isContract(), "cannot purchase from contract");                
        require(msg.value >= collections[collectionId].priceInWei, "insufficient funds sent to purchase");
        
        Collection memory collection = getCollection(collectionId);

        bool allowedToMint = false;
        if(collection.useAllowList && collection.allowList.length > 0) {
            for(uint i = 0; i < collection.allowList.length; i++) {
                if(_msgSender() == collection.allowList[i]) {
                    allowedToMint = true;
                    break;
                }
            }
        } else {
            allowedToMint = true;
        }
        require(allowedToMint, "mint not approved");

        mint(collectionId, _msgSender(), recipient);

        require(ownerAddresses.length > 0, "no owner addresses");
        require(ownerSplits.length == ownerAddresses.length, "invalid owner splits");
        require(collection.creatorAddresses.length > 0, "no creator addresses");
        require(collection.creatorSplits.length == collection.creatorAddresses.length, "invalid creator splits");

        distributeFunds(collection);
    }

    function mint(bytes32 collectionId, address minter, address recipient) internal {

        Collection memory collection = getCollection(collectionId);
        require(collections[collectionId].seed != 0, "seed not set");
        require(collection.active, "collection inactive");        
        require(collection.minted + 1 <= collection.mintedMax, "minted max tokens");
        require(collection.mintedMaxPerOwner == 0 || ownerMints[collectionId][minter] < collection.mintedMaxPerOwner, "minter exceeds max mints");
        
        uint256 nextTokenId = lastTokenId + 1;
        int32 seed = int32(int(uint(keccak256(abi.encodePacked(collection.seed, block.number, _msgSender(), recipient, nextTokenId)))));
        
        lastTokenId = nextTokenId;
        collectionTokens[collectionId].push(lastTokenId);
        tokenCollection[lastTokenId] = collectionId;

        collectionSeeds[collectionId].push(seed);
        tokenSeed[lastTokenId] = seed;        
        collections[collectionId].minted = collection.minted + 1;
        ownerMints[collectionId][recipient] = ownerMints[collectionId][recipient] + 1;

        _safeMint(recipient, nextTokenId);
        emit CollectionMinted(collectionId, nextTokenId, recipient, collection.minted, collection.priceInWei, seed);

        if(collection.pauseAt > 0) {
            if(lastTokenId >= collection.pauseAt)
                _pause();
        }
    }

    function distributeFunds(Collection memory collection) private {
        if (msg.value > 0) {

            uint priceInWei = collection.priceInWei;
            uint overpaid = msg.value - priceInWei;
            if (overpaid > 0) {
                payable(_msgSender()).transfer(overpaid);
            }

            uint dueToOwners = ownerRoyalty * collection.priceInWei / 100;        
            uint paidToOwners = distributeSplits(dueToOwners, ownerAddresses, ownerSplits);            
            uint dueToCreators = priceInWei - paidToOwners;
            uint paidToCreators = distributeSplits(dueToCreators, collection.creatorAddresses, collection.creatorSplits);

            require(priceInWei - paidToOwners - paidToCreators == 0, "funds had remainder");            
        }
    }

    function distributeSplits(uint fundsToDistribute, address payable[] memory addresses, uint8[] memory splits) 
        private returns(uint paidToAddresses)
    {
        paidToAddresses = 0;
        if (fundsToDistribute > 0) {                
            uint8 sum = 0;
            for(uint8 i = 0; i < splits.length; i++) {
                sum += splits[i];
            }
            require(sum == 100, "splits must sum to 100%");

            for(uint8 i = 0; i < addresses.length; i++) {
                uint dueToAddress = splits[i] * fundsToDistribute / 100;
                addresses[i].transfer(dueToAddress);
                paidToAddresses += dueToAddress;
            }
        }
        require(fundsToDistribute - paidToAddresses == 0, "incorrect distribution of funds");
    }   
    
    function ownsToken(address owner, uint tokenId) public view returns (bool) {
        for(uint i = 0; i < balanceOf(owner); i++) {
            if(tokenId == tokenOfOwnerByIndex(owner, i)) {
                return true;
            }            
        }
        return false;
    }  

    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");
        Collection memory collection = collections[tokenCollection[tokenId]];
        string memory baseURI = collection.baseTokenUri;
        return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, Strings.toString(tokenId))) : "";
    }  

    function getAttributes(uint tokenId) external view returns (string memory attributes) {
        require(_msgSender() == _admin || ownsToken(_msgSender(), tokenId), "unowned token");
        return IAttributes(collections[tokenCollection[tokenId]]._renderer).getAttributes(tokenSeed[tokenId]);
    }

    function _render(uint tokenId, IRenderer.RenderArgs memory args) private view returns (IRenderer.RenderArgs memory results) {
        require(_msgSender() == _admin || ownsToken(_msgSender(), tokenId), "unowned token");
        require(args.seed == tokenSeed[tokenId], "invalid seed");
        return IRenderer(collections[tokenCollection[tokenId]]._renderer).render(args);
    }

    function render(uint tokenId, IRenderer.RenderArgs memory args) external view returns (IRenderer.RenderArgs memory results) {        
        return _render(tokenId, args);
    }

    function beginRender(uint tokenId) external view returns (IRenderer.RenderArgs memory results) {        
        uint32[16384] memory buffer;
        RandomV1.PRNG memory prng;
        return _render(tokenId, IRenderer.RenderArgs(0, 0, tokenSeed[tokenId], buffer, prng));
    }
}