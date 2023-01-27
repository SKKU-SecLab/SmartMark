
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

pragma solidity ^0.8.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address to, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
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

library OOOSafeMath {

    function safeAdd(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function safeSub(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b <= a, "SafeMath: subtraction overflow");
        return a - b;
    }

    function safeMul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function saveDiv(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0, "SafeMath: division by zero");
        return a / b;
    }

    function safeMod(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0, "SafeMath: modulo by zero");
        return a % b;
    }
}// MIT

pragma solidity ^0.8.0;

interface IERC20_Ex {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function increaseAllowance(address spender, uint256 addedValue) external returns (bool);


    function decreaseAllowance(address spender, uint256 subtractedValue) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}// MIT

pragma solidity ^0.8.0;

interface IRouter {

    function initialiseRequest(address, uint256, bytes32) external returns (bool);

}// MIT
pragma solidity ^0.8.0;

contract RequestIdBase {


    function makeRequestId(
        address _dataConsumer,
        address _dataProvider,
        address _router,
        uint256 _requestNonce,
        bytes32 _data) internal pure returns (bytes32) {

        return keccak256(abi.encodePacked(_dataConsumer, _dataProvider, _router, _requestNonce, _data));
    }
}// MIT

pragma solidity ^0.8.0;


abstract contract ConsumerBase is RequestIdBase {
    using OOOSafeMath for uint256;


    mapping(address => uint256) private nonces;

    IERC20_Ex internal immutable xFUND;
    IRouter internal router;


    constructor(address _router, address _xfund) {
        require(_router != address(0), "router cannot be the zero address");
        require(_xfund != address(0), "xfund cannot be the zero address");
        router = IRouter(_router);
        xFUND = IERC20_Ex(_xfund);
    }

    function _setRouter(address _router) internal returns (bool) {
        require(_router != address(0), "router cannot be the zero address");
        router = IRouter(_router);
        return true;
    }

    function _increaseRouterAllowance(uint256 _amount) internal returns (bool) {
        require(xFUND.increaseAllowance(address(router), _amount), "failed to increase allowance");
        return true;
    }

    function _requestData(address _dataProvider, uint256 _fee, bytes32 _data)
    internal returns (bytes32) {
        bytes32 requestId = makeRequestId(address(this), _dataProvider, address(router), nonces[_dataProvider], _data);
        require(router.initialiseRequest(_dataProvider, _fee, _data));
        nonces[_dataProvider] = nonces[_dataProvider].safeAdd(1);
        return requestId;
    }

    function rawReceiveData(
        uint256 _price,
        bytes32 _requestId) external
    {
        require(msg.sender == address(router), "only Router can call");

        receiveData(_price, _requestId);
    }

    function receiveData(
        uint256 _price,
        bytes32 _requestId
    ) internal virtual;


    function getRouterAddress() external view returns (address) {
        return address(router);
    }

}//MIT
pragma solidity ^0.8.13;

interface ILandRegistry {

    function mint(
        address user,
        int16 x,
        int16 y
    ) external;

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

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}// MIT

pragma solidity ^0.8.0;


abstract contract ERC165 is IERC165 {
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
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

    function hasRole(bytes32 role, address account) public view virtual override returns (bool) {
        return _roles[role].members[account];
    }

    function _checkRole(bytes32 role, address account) internal view virtual {
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

    function getRoleAdmin(bytes32 role) public view virtual override returns (bytes32) {
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

    function _grantRole(bytes32 role, address account) internal virtual {
        if (!hasRole(role, account)) {
            _roles[role].members[account] = true;
            emit RoleGranted(role, account, _msgSender());
        }
    }

    function _revokeRole(bytes32 role, address account) internal virtual {
        if (hasRole(role, account)) {
            _roles[role].members[account] = false;
            emit RoleRevoked(role, account, _msgSender());
        }
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


library ECDSA {

    enum RecoverError {
        NoError,
        InvalidSignature,
        InvalidSignatureLength,
        InvalidSignatureS,
        InvalidSignatureV
    }

    function _throwError(RecoverError error) private pure {

        if (error == RecoverError.NoError) {
            return; // no error: do nothing
        } else if (error == RecoverError.InvalidSignature) {
            revert("ECDSA: invalid signature");
        } else if (error == RecoverError.InvalidSignatureLength) {
            revert("ECDSA: invalid signature length");
        } else if (error == RecoverError.InvalidSignatureS) {
            revert("ECDSA: invalid signature 's' value");
        } else if (error == RecoverError.InvalidSignatureV) {
            revert("ECDSA: invalid signature 'v' value");
        }
    }

    function tryRecover(bytes32 hash, bytes memory signature) internal pure returns (address, RecoverError) {

        if (signature.length == 65) {
            bytes32 r;
            bytes32 s;
            uint8 v;
            assembly {
                r := mload(add(signature, 0x20))
                s := mload(add(signature, 0x40))
                v := byte(0, mload(add(signature, 0x60)))
            }
            return tryRecover(hash, v, r, s);
        } else if (signature.length == 64) {
            bytes32 r;
            bytes32 vs;
            assembly {
                r := mload(add(signature, 0x20))
                vs := mload(add(signature, 0x40))
            }
            return tryRecover(hash, r, vs);
        } else {
            return (address(0), RecoverError.InvalidSignatureLength);
        }
    }

    function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {

        (address recovered, RecoverError error) = tryRecover(hash, signature);
        _throwError(error);
        return recovered;
    }

    function tryRecover(
        bytes32 hash,
        bytes32 r,
        bytes32 vs
    ) internal pure returns (address, RecoverError) {

        bytes32 s = vs & bytes32(0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff);
        uint8 v = uint8((uint256(vs) >> 255) + 27);
        return tryRecover(hash, v, r, s);
    }

    function recover(
        bytes32 hash,
        bytes32 r,
        bytes32 vs
    ) internal pure returns (address) {

        (address recovered, RecoverError error) = tryRecover(hash, r, vs);
        _throwError(error);
        return recovered;
    }

    function tryRecover(
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure returns (address, RecoverError) {

        if (uint256(s) > 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0) {
            return (address(0), RecoverError.InvalidSignatureS);
        }
        if (v != 27 && v != 28) {
            return (address(0), RecoverError.InvalidSignatureV);
        }

        address signer = ecrecover(hash, v, r, s);
        if (signer == address(0)) {
            return (address(0), RecoverError.InvalidSignature);
        }

        return (signer, RecoverError.NoError);
    }

    function recover(
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure returns (address) {

        (address recovered, RecoverError error) = tryRecover(hash, v, r, s);
        _throwError(error);
        return recovered;
    }

    function toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32) {

        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }

    function toEthSignedMessageHash(bytes memory s) internal pure returns (bytes32) {

        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n", Strings.toString(s.length), s));
    }

    function toTypedDataHash(bytes32 domainSeparator, bytes32 structHash) internal pure returns (bytes32) {

        return keccak256(abi.encodePacked("\x19\x01", domainSeparator, structHash));
    }
}// GPL-3.0
pragma solidity ^0.8.13;

interface IWETH {

    function deposit() external payable;


    function withdraw(uint256 wad) external;


    function transfer(address to, uint256 value) external returns (bool);

}//MIT
pragma solidity ^0.8.13;

interface ILockShiboshi {

    function lockInfoOf(address user)
        external
        view
        returns (
            uint256[] memory ids,
            uint256 startTime,
            uint256 numDays,
            address ogUser
        );


    function weightOf(address user) external view returns (uint256);


    function extraShiboshiNeeded(address user, uint256 targetWeight)
        external
        view
        returns (uint256);


    function extraDaysNeeded(address user, uint256 targetWeight)
        external
        view
        returns (uint256);


    function isWinner(address user) external view returns (bool);


    function unlockAt(address user) external view returns (uint256);

}//MIT
pragma solidity ^0.8.13;

interface ILockLeash {

    function lockInfoOf(address user)
        external
        view
        returns (
            uint256 amount,
            uint256 startTime,
            uint256 numDays,
            address ogUser
        );


    function weightOf(address user) external view returns (uint256);


    function extraLeashNeeded(address user, uint256 targetWeight)
        external
        view
        returns (uint256);


    function extraDaysNeeded(address user, uint256 targetWeight)
        external
        view
        returns (uint256);


    function isWinner(address user) external view returns (bool);


    function unlockAt(address user) external view returns (uint256);

}//MIT
pragma solidity ^0.8.13;

interface ILandAuction {

    function winningsBidsOf(address user) external view returns (uint256);

}// MIT
pragma solidity ^0.8.13;



contract LandAuction is ILandAuction, AccessControl, ReentrancyGuard {

    using ECDSA for bytes32;

    bytes32 public constant GRID_SETTER_ROLE = keccak256("GRID_SETTER_ROLE");

    uint32 constant clearLow = 0xffff0000;
    uint32 constant clearHigh = 0x0000ffff;
    uint32 constant factor = 0x10000;

    uint16 public constant N = 194; // xHigh + 97 + 1
    uint16 public constant M = 200; // yHigh + 100 + 1


    int16 public constant xLow = -96;
    int16 public constant yLow = -99;
    int16 public constant xHigh = 96;
    int16 public constant yHigh = 99;

    enum Stage {
        Default,
        Bidding,
        PrivateSale,
        PublicSale
    }

    struct Bid {
        uint256 amount;
        address bidder;
    }

    address public immutable weth;
    ILandRegistry public landRegistry;
    ILockLeash public lockLeash;
    ILockShiboshi public lockShiboshi;
    bool public multiBidEnabled;

    address public signerAddress;
    Stage public currentStage;

    int8[N + 10][M + 10] private _categoryBIT;

    mapping(int16 => mapping(int16 => Bid)) public getCurrentBid;
    mapping(int8 => uint256) public priceOfCategory;
    mapping(address => uint256) public winningsBidsOf;

    mapping(address => uint32[]) private _allBidsOf;
    mapping(address => mapping(uint32 => uint8)) private _statusOfBidsOf;

    event CategoryPriceSet(int8 category, uint256 price);
    event StageSet(uint256 stage);
    event SignerSet(address signer);
    event multiBidToggled(bool newValue);
    event BidCreated(
        address indexed user,
        uint32 indexed encXY,
        int16 x,
        int16 y,
        uint256 price,
        uint256 time
    );
    event LandBought(
        address indexed user,
        uint32 indexed encXY,
        int16 x,
        int16 y,
        uint256 price,
        Stage saleStage
    );

    constructor(
        address _weth,
        ILandRegistry _landRegistry,
        ILockLeash _lockLeash,
        ILockShiboshi _lockShiboshi
    ) {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(GRID_SETTER_ROLE, msg.sender);

        weth = _weth;
        landRegistry = _landRegistry;
        lockLeash = _lockLeash;
        lockShiboshi = _lockShiboshi;

        signerAddress = msg.sender;
    }

    modifier onlyValid(int16 x, int16 y) {

        require(xLow <= x && x <= xHigh, "ERR_X_OUT_OF_RANGE");
        require(yLow <= y && y <= yHigh, "ERR_Y_OUT_OF_RANGE");
        _;
    }

    modifier onlyStage(Stage s) {

        require(currentStage == s, "ERR_THIS_STAGE_NOT_LIVE_YET");
        _;
    }

    function weightToCapacity(uint256 weightLeash, uint256 weightShiboshi)
        public
        pure
        returns (uint256)
    {

        uint256[10] memory QRangeLeash = [
            uint256(9),
            uint256(30),
            uint256(60),
            uint256(100),
            uint256(130),
            uint256(180),
            uint256(220),
            uint256(300),
            uint256(370),
            uint256(419)
        ];
        uint256[10] memory QRangeShiboshi = [
            uint256(45),
            uint256(89),
            uint256(150),
            uint256(250),
            uint256(350),
            uint256(480),
            uint256(600),
            uint256(700),
            uint256(800),
            uint256(850)
        ];
        uint256[10] memory buckets = [
            uint256(1),
            uint256(5),
            uint256(10),
            uint256(20),
            uint256(50),
            uint256(80),
            uint256(100),
            uint256(140),
            uint256(180),
            uint256(200)
        ];
        uint256 capacity;

        if (weightLeash > 0) {
            for (uint256 i = 9; i >= 0; i = _uncheckedDec(i)) {
                if (weightLeash > QRangeLeash[i] * 1e18) {
                    capacity += buckets[i];
                    break;
                }
            }
        }

        if (weightShiboshi > 0) {
            for (uint256 i = 9; i >= 0; i = _uncheckedDec(i)) {
                if (weightShiboshi > QRangeShiboshi[i]) {
                    capacity += buckets[i];
                    break;
                }
            }
        }

        return capacity;
    }

    function getOutbidPrice(uint256 bidPrice) public pure returns (uint256) {

        return (bidPrice * 21) / 20;
    }

    function availableCapacityOf(address user) public view returns (uint256) {

        uint256 weightLeash = lockLeash.weightOf(user);
        uint256 weightShiboshi = lockShiboshi.weightOf(user);

        return
            weightToCapacity(weightLeash, weightShiboshi) -
            winningsBidsOf[user];
    }

    function getReservePrice(int16 x, int16 y) public view returns (uint256) {

        uint256 price = priceOfCategory[getCategory(x, y)];
        require(price != 0, "ERR_NOT_UP_FOR_SALE");
        return price;
    }

    function getPriceOf(int16 x, int16 y) public view returns (uint256) {

        Bid storage currentBid = getCurrentBid[x][y];
        if (currentBid.amount == 0) {
            return getReservePrice(x, y);
        } else {
            return getOutbidPrice(currentBid.amount);
        }
    }

    function getCategory(int16 x, int16 y) public view returns (int8) {

        (uint16 x_mapped, uint16 y_mapped) = _transformXY(x, y);

        int8 category;
        for (uint16 i = x_mapped; i > 0; i = _subLowbit(i)) {
            for (uint16 j = y_mapped; j > 0; j = _subLowbit(j)) {
                unchecked {
                    category += _categoryBIT[i][j];
                }
            }
        }
        return category;
    }

    function isShiboshiZone(int16 x, int16 y) public pure returns (bool) {


        if (x >= 12 && x <= 48 && y <= 99 && y >= 65) {
            return true;
        }
        if (x >= 49 && x <= 77 && y <= 99 && y >= 78) {
            return true;
        }
        if (x >= 76 && x <= 77 && y <= 77 && y >= 50) {
            return true;
        }
        if (x >= 65 && x <= 75 && y == 50) {
            return true;
        }
        return false;
    }

    function bidInfoOf(address user)
        external
        view
        returns (int16[] memory, int16[] memory)
    {

        uint256 bidCount = winningsBidsOf[user];
        int16[] memory xs = new int16[](bidCount);
        int16[] memory ys = new int16[](bidCount);

        uint256 ptr;
        uint32[] storage allBids = _allBidsOf[user];
        uint256 length = allBids.length;

        for (uint256 i = 0; i < length; i = _uncheckedInc(i)) {
            if (_statusOfBidsOf[user][allBids[i]] == 1) {
                (int16 x, int16 y) = _decodeXY(allBids[i]);
                xs[ptr] = x;
                ys[ptr] = y;
                ptr = _uncheckedInc(ptr);
            }
        }

        return (xs, ys);
    }

    function allBidInfoOf(address user)
        external
        view
        returns (int16[] memory, int16[] memory)
    {

        uint32[] storage allBids = _allBidsOf[user];
        uint256 bidCount = allBids.length;
        int16[] memory xs = new int16[](bidCount);
        int16[] memory ys = new int16[](bidCount);

        for (uint256 i = 0; i < bidCount; i = _uncheckedInc(i)) {
            (int16 x, int16 y) = _decodeXY(allBids[i]);
            xs[i] = x;
            ys[i] = y;
        }

        return (xs, ys);
    }

    function setGridVal(
        int16 x1,
        int16 y1,
        int16 x2,
        int16 y2,
        int8 val
    ) external onlyRole(GRID_SETTER_ROLE) {

        (uint16 x1_mapped, uint16 y1_mapped) = _transformXY(x1, y1);
        (uint16 x2_mapped, uint16 y2_mapped) = _transformXY(x2, y2);

        _updateGrid(x2_mapped + 1, y2_mapped + 1, val);
        _updateGrid(x1_mapped, y1_mapped, val);
        _updateGrid(x1_mapped, y2_mapped + 1, -val);
        _updateGrid(x2_mapped + 1, y1_mapped, -val);
    }

    function setPriceOfCategory(int8 category, uint256 price)
        external
        onlyRole(GRID_SETTER_ROLE)
    {

        priceOfCategory[category] = price;

        emit CategoryPriceSet(category, price);
    }

    function setStage(uint256 stage) external onlyRole(DEFAULT_ADMIN_ROLE) {

        currentStage = Stage(stage);
        emit StageSet(stage);
    }

    function setSignerAddress(address signer)
        external
        onlyRole(DEFAULT_ADMIN_ROLE)
    {

        require(signer != address(0), "ERR_CANNOT_BE_ZERO_ADDRESS");
        signerAddress = signer;
        emit SignerSet(signer);
    }

    function setLandRegistry(address _landRegistry)
        external
        onlyRole(DEFAULT_ADMIN_ROLE)
    {

        landRegistry = ILandRegistry(_landRegistry);
    }

    function setLockLeash(address _lockLeash)
        external
        onlyRole(DEFAULT_ADMIN_ROLE)
    {

        lockLeash = ILockLeash(_lockLeash);
    }

    function setLockShiboshi(address _lockShiboshi)
        external
        onlyRole(DEFAULT_ADMIN_ROLE)
    {

        lockShiboshi = ILockShiboshi(_lockShiboshi);
    }

    function setMultiBid(bool desiredValue)
        external
        onlyRole(DEFAULT_ADMIN_ROLE)
    {

        require(multiBidEnabled != desiredValue, "ERR_ALREADY_DESIRED_VALUE");
        multiBidEnabled = desiredValue;

        emit multiBidToggled(desiredValue);
    }

    function withdraw(address to, uint256 amount)
        external
        onlyRole(DEFAULT_ADMIN_ROLE)
    {

        payable(to).transfer(amount);
    }

    function bidOne(int16 x, int16 y)
        external
        payable
        onlyStage(Stage.Bidding)
        nonReentrant
    {

        address user = msg.sender;
        require(availableCapacityOf(user) != 0, "ERR_NO_BIDS_REMAINING");
        require(!isShiboshiZone(x, y), "ERR_NO_MINT_IN_SHIBOSHI_ZONE");
        _bid(user, x, y, msg.value);
    }

    function bidShiboshiZoneOne(
        int16 x,
        int16 y,
        bytes calldata signature
    ) external payable onlyStage(Stage.Bidding) nonReentrant {

        address user = msg.sender;
        require(
            _verifySigner(_hashMessage(user), signature),
            "ERR_SIGNATURE_INVALID"
        );
        require(isShiboshiZone(x, y), "ERR_NOT_IN_SHIBOSHI_ZONE");
        _bid(user, x, y, msg.value);
    }

    function bidMulti(
        int16[] calldata xs,
        int16[] calldata ys,
        uint256[] calldata prices
    ) external payable onlyStage(Stage.Bidding) nonReentrant {

        require(multiBidEnabled, "ERR_MULTI_BID_DISABLED");

        address user = msg.sender;

        uint256 length = xs.length;
        require(length != 0, "ERR_NO_INPUT");
        require(length == ys.length, "ERR_INPUT_LENGTH_MISMATCH");
        require(length == prices.length, "ERR_INPUT_LENGTH_MISMATCH");

        uint256 total;
        require(
            availableCapacityOf(user) >= length,
            "ERR_INSUFFICIENT_BIDS_REMAINING"
        );

        for (uint256 i = 0; i < length; i = _uncheckedInc(i)) {
            total += prices[i];
        }
        require(msg.value == total, "ERR_INSUFFICIENT_AMOUNT_SENT");

        for (uint256 i = 0; i < length; i = _uncheckedInc(i)) {
            int16 x = xs[i];
            int16 y = ys[i];
            require(!isShiboshiZone(x, y), "ERR_NO_MINT_IN_SHIBOSHI_ZONE");
            _bid(user, x, y, prices[i]);
        }
    }

    function bidShiboshiZoneMulti(
        int16[] calldata xs,
        int16[] calldata ys,
        uint256[] calldata prices,
        bytes calldata signature
    ) external payable onlyStage(Stage.Bidding) nonReentrant {

        require(multiBidEnabled, "ERR_MULTI_BID_DISABLED");

        address user = msg.sender;
        require(
            _verifySigner(_hashMessage(user), signature),
            "ERR_SIGNATURE_INVALID"
        );

        uint256 length = xs.length;
        require(length != 0, "ERR_NO_INPUT");
        require(length == ys.length, "ERR_INPUT_LENGTH_MISMATCH");
        require(length == prices.length, "ERR_INPUT_LENGTH_MISMATCH");

        uint256 total;
        for (uint256 i = 0; i < length; i = _uncheckedInc(i)) {
            total += prices[i];
        }
        require(msg.value == total, "ERR_INSUFFICIENT_AMOUNT_SENT");

        for (uint256 i = 0; i < length; i = _uncheckedInc(i)) {
            int16 x = xs[i];
            int16 y = ys[i];
            require(isShiboshiZone(x, y), "ERR_NOT_IN_SHIBOSHI_ZONE");
            _bid(user, x, y, prices[i]);
        }
    }

    function mintWinningBid(int16[] calldata xs, int16[] calldata ys) external {

        require(
            currentStage == Stage.PublicSale ||
                currentStage == Stage.PrivateSale,
            "ERR_MUST_WAIT_FOR_BIDDING_TO_END"
        );

        uint256 length = xs.length;
        require(length == ys.length, "ERR_INPUT_LENGTH_MISMATCH");

        for (uint256 i = 0; i < length; i = _uncheckedInc(i)) {
            int16 x = xs[i];
            int16 y = ys[i];
            require(xLow <= x && x <= xHigh, "ERR_X_OUT_OF_RANGE");
            require(yLow <= y && y <= yHigh, "ERR_Y_OUT_OF_RANGE");

            address user = getCurrentBid[x][y].bidder;
            require(user != address(0), "ERR_NO_BID_FOUND");
            landRegistry.mint(user, x, y);
        }
    }

    function mintPrivate(int16 x, int16 y)
        external
        payable
        onlyStage(Stage.PrivateSale)
        nonReentrant
    {

        require(availableCapacityOf(msg.sender) != 0, "ERR_NO_BIDS_REMAINING");
        require(!isShiboshiZone(x, y), "ERR_NO_MINT_IN_SHIBOSHI_ZONE");
        _mintPublicOrPrivate(msg.sender, x, y);
        emit LandBought(
            msg.sender,
            _encodeXY(x, y),
            x,
            y,
            msg.value,
            Stage.PrivateSale
        );
    }

    function mintPrivateShiboshiZone(
        int16 x,
        int16 y,
        bytes calldata signature
    ) external payable onlyStage(Stage.PrivateSale) nonReentrant {

        require(
            _verifySigner(_hashMessage(msg.sender), signature),
            "ERR_SIGNATURE_INVALID"
        );
        require(isShiboshiZone(x, y), "ERR_NOT_IN_SHIBOSHI_ZONE");
        _mintPublicOrPrivate(msg.sender, x, y);
        emit LandBought(
            msg.sender,
            _encodeXY(x, y),
            x,
            y,
            msg.value,
            Stage.PrivateSale
        );
    }

    function mintPublic(int16 x, int16 y)
        external
        payable
        onlyStage(Stage.PublicSale)
        nonReentrant
    {

        _mintPublicOrPrivate(msg.sender, x, y);
        emit LandBought(
            msg.sender,
            _encodeXY(x, y),
            x,
            y,
            msg.value,
            Stage.PublicSale
        );
    }

    function _transformXY(int16 x, int16 y)
        internal
        pure
        onlyValid(x, y)
        returns (uint16, uint16)
    {

        return (uint16(x + 97), uint16(100 - y));
    }

    function _bid(
        address user,
        int16 x,
        int16 y,
        uint256 price
    ) internal onlyValid(x, y) {

        uint32 encXY = _encodeXY(x, y);
        Bid storage currentBid = getCurrentBid[x][y];
        if (currentBid.amount == 0) {
            require(
                price >= getReservePrice(x, y),
                "ERR_INSUFFICIENT_AMOUNT_SENT"
            );
        } else {
            require(user != currentBid.bidder, "ERR_CANNOT_OUTBID_YOURSELF");
            require(
                price >= getOutbidPrice(currentBid.amount),
                "ERR_INSUFFICIENT_AMOUNT_SENT"
            );
            _safeTransferETHWithFallback(currentBid.bidder, currentBid.amount);
            winningsBidsOf[currentBid.bidder] -= 1;
            _statusOfBidsOf[currentBid.bidder][encXY] = 2;
        }

        currentBid.bidder = user;
        currentBid.amount = price;
        winningsBidsOf[user] += 1;

        if (_statusOfBidsOf[user][encXY] == 0) {
            _allBidsOf[user].push(encXY);
        }
        _statusOfBidsOf[user][encXY] = 1;

        emit BidCreated(user, encXY, x, y, price, block.timestamp);
    }

    function _mintPublicOrPrivate(
        address user,
        int16 x,
        int16 y
    ) internal onlyValid(x, y) {

        Bid storage currentBid = getCurrentBid[x][y];
        require(currentBid.amount == 0, "ERR_NOT_UP_FOR_SALE");
        require(
            msg.value == getReservePrice(x, y),
            "ERR_INSUFFICIENT_AMOUNT_SENT"
        );

        currentBid.bidder = user;
        currentBid.amount = msg.value;
        winningsBidsOf[user] += 1;

        uint32 encXY = _encodeXY(x, y);
        _allBidsOf[user].push(encXY);
        _statusOfBidsOf[user][encXY] = 1;

        landRegistry.mint(user, x, y);
    }

    function _hashMessage(address sender) private pure returns (bytes32) {

        return keccak256(abi.encodePacked(sender));
    }

    function _verifySigner(bytes32 messageHash, bytes memory signature)
        private
        view
        returns (bool)
    {

        return
            signerAddress ==
            messageHash.toEthSignedMessageHash().recover(signature);
    }

    function _safeTransferETHWithFallback(address to, uint256 amount) internal {

        if (!_safeTransferETH(to, amount)) {
            IWETH(weth).deposit{value: amount}();
            IERC20(weth).transfer(to, amount);
        }
    }

    function _safeTransferETH(address to, uint256 value)
        internal
        returns (bool)
    {

        (bool success, ) = to.call{value: value, gas: 30_000}(new bytes(0));
        return success;
    }

    function _uncheckedInc(uint256 i) internal pure returns (uint256) {

        unchecked {
            return i + 1;
        }
    }

    function _uncheckedDec(uint256 i) internal pure returns (uint256) {

        unchecked {
            return i - 1;
        }
    }

    function _encodeXY(int16 x, int16 y) internal pure returns (uint32) {

        return
            ((uint32(uint16(x)) * factor) & clearLow) |
            (uint32(uint16(y)) & clearHigh);
    }

    function _decodeXY(uint32 value) internal pure returns (int16 x, int16 y) {

        x = _expandNegative16BitCast((value & clearLow) >> 16);
        y = _expandNegative16BitCast(value & clearHigh);
    }

    function _expandNegative16BitCast(uint32 value)
        internal
        pure
        returns (int16)
    {

        if (value & (1 << 15) != 0) {
            return int16(int32(value | clearLow));
        }
        return int16(int32(value));
    }


    function _updateGrid(
        uint16 x,
        uint16 y,
        int8 val
    ) internal {

        for (uint16 i = x; i <= N; i = _addLowbit(i)) {
            for (uint16 j = y; j <= M; j = _addLowbit(j)) {
                unchecked {
                    _categoryBIT[i][j] += val;
                }
            }
        }
    }

    function _addLowbit(uint16 i) internal pure returns (uint16) {

        unchecked {
            return i + uint16(int16(i) & (-int16(i)));
        }
    }

    function _subLowbit(uint16 i) internal pure returns (uint16) {

        unchecked {
            return i - uint16(int16(i) & (-int16(i)));
        }
    }
}// MIT
pragma solidity ^0.8.13;



contract LandAuctionV3 is ConsumerBase, Ownable, ReentrancyGuard {

    uint32 constant clearLow = 0xffff0000;
    uint32 constant clearHigh = 0x0000ffff;
    uint32 constant factor = 0x10000;

    int16 public constant xLow = -96;
    int16 public constant yLow = -99;
    int16 public constant xHigh = 96;
    int16 public constant yHigh = 99;

    enum Stage {
        Default,
        Inactive1,
        Inactive2,
        PublicSale
    }

    uint256 public ethToShib;
    bool public multiMintEnabled;

    LandAuction public auctionV1;
    LandAuction public auctionV2;
    ILandRegistry public landRegistry;

    IERC20 public immutable SHIB;
    Stage public currentStage;

    mapping(address => uint32[]) private _allMintsOf;

    event StageSet(uint256 stage);
    event multiMintToggled(bool newValue);
    event LandBoughtWithShib(
        address indexed user,
        uint32 indexed encXY,
        int16 x,
        int16 y,
        uint256 price,
        uint256 time,
        Stage saleStage
    );

    constructor(
        IERC20 _shib,
        LandAuction _auctionV1,
        LandAuction _auctionV2,
        ILandRegistry _landRegistry,
        address _router,
        address _xfund
    ) ConsumerBase(_router, _xfund) {
        SHIB = _shib;
        auctionV1 = _auctionV1;
        auctionV2 = _auctionV2;
        landRegistry = _landRegistry;
    }

    modifier onlyValid(int16 x, int16 y) {

        require(xLow <= x && x <= xHigh, "ERR_X_OUT_OF_RANGE");
        require(yLow <= y && y <= yHigh, "ERR_Y_OUT_OF_RANGE");
        _;
    }

    modifier onlyStage(Stage s) {

        require(currentStage == s, "ERR_THIS_STAGE_NOT_LIVE_YET");
        _;
    }

    function bidInfoOf(address user)
        external
        view
        returns (int16[] memory, int16[] memory)
    {

        (int16[] memory xsV1, int16[] memory ysV1) = auctionV2.bidInfoOf(user);
        uint256 lengthV1 = xsV1.length;

        uint256 bidCount = _allMintsOf[user].length;
        int16[] memory xs = new int16[](bidCount + lengthV1);
        int16[] memory ys = new int16[](bidCount + lengthV1);

        for (uint256 i = 0; i < lengthV1; i = _uncheckedInc(i)) {
            xs[i] = xsV1[i];
            ys[i] = ysV1[i];
        }

        uint256 ptr = lengthV1;
        uint32[] storage allMints = _allMintsOf[user];
        uint256 length = allMints.length;

        for (uint256 i = 0; i < length; i = _uncheckedInc(i)) {
            (int16 x, int16 y) = _decodeXY(allMints[i]);
            xs[ptr] = x;
            ys[ptr] = y;
            ptr = _uncheckedInc(ptr);
        }

        return (xs, ys);
    }

    function getReservePriceShib(int16 x, int16 y)
        public
        view
        onlyValid(x, y)
        returns (uint256)
    {

        uint256 reservePrice = auctionV1.getReservePrice(x, y);

        (uint256 cAmount, ) = auctionV1.getCurrentBid(x, y);
        require(cAmount == 0, "ERR_ALREADY_BOUGHT");

        uint256 reservePriceInShib = (ethToShib * reservePrice) / 1 ether;

        require(reservePriceInShib > 0, "ERR_BAD_PRICE");
        return reservePriceInShib;
    }

    function mintPublicWithShib(int16 x, int16 y)
        external
        onlyStage(Stage.PublicSale)
        nonReentrant
    {

        uint256 reservePriceInShib = getReservePriceShib(x, y);

        address user = msg.sender;

        SHIB.transferFrom(user, address(this), reservePriceInShib);

        uint32 encXY = _encodeXY(x, y);
        _allMintsOf[user].push(encXY);

        landRegistry.mint(user, x, y);

        emit LandBoughtWithShib(
            user,
            encXY,
            x,
            y,
            reservePriceInShib,
            block.timestamp,
            Stage.PublicSale
        );
    }

    function mintPublicWithShibMulti(
        int16[] calldata xs,
        int16[] calldata ys,
        uint256[] calldata prices
    ) external onlyStage(Stage.PublicSale) nonReentrant {

        require(multiMintEnabled, "ERR_MULTI_BID_DISABLED");

        uint256 length = xs.length;
        require(length != 0, "ERR_NO_INPUT");
        require(length == ys.length, "ERR_INPUT_LENGTH_MISMATCH");
        require(length == prices.length, "ERR_INPUT_LENGTH_MISMATCH");

        uint256 total;
        for (uint256 i = 0; i < length; i = _uncheckedInc(i)) {
            total += prices[i];
        }

        address user = msg.sender;

        SHIB.transferFrom(user, address(this), total);

        for (uint256 i = 0; i < length; i = _uncheckedInc(i)) {
            int16 x = xs[i];
            int16 y = ys[i];

            uint256 reservePriceInShib = getReservePriceShib(x, y);
            require(
                reservePriceInShib == prices[i],
                "ERR_INSUFFICIENT_SHIB_SENT"
            );

            uint32 encXY = _encodeXY(x, y);
            _allMintsOf[user].push(encXY);

            landRegistry.mint(user, x, y);

            emit LandBoughtWithShib(
                user,
                encXY,
                x,
                y,
                prices[i],
                block.timestamp,
                Stage.PublicSale
            );
        }
    }

    function setStage(uint256 stage) external onlyOwner {

        currentStage = Stage(stage);
        emit StageSet(stage);
    }

    function setLandRegistry(address _landRegistry) external onlyOwner {

        landRegistry = ILandRegistry(_landRegistry);
    }

    function setAuctionV1(LandAuction _auctionV1) external onlyOwner {

        auctionV1 = _auctionV1;
    }

    function setAuctionV2(LandAuction _auctionV2) external onlyOwner {

        auctionV2 = _auctionV2;
    }

    function setMultiMint(bool desiredValue) external onlyOwner {

        require(multiMintEnabled != desiredValue, "ERR_ALREADY_DESIRED_VALUE");
        multiMintEnabled = desiredValue;

        emit multiMintToggled(desiredValue);
    }

    function increaseRouterAllowance(uint256 _amount) external onlyOwner {

        require(_increaseRouterAllowance(_amount), "ERR_FAILED_TO_INCREASE");
    }

    function getData(address _provider, uint256 _fee)
        external
        onlyOwner
        returns (bytes32)
    {

        bytes32 data = 0x4554482e534849422e50522e4156430000000000000000000000000000000000; // ETH.SHIB.PR.AVC
        return _requestData(_provider, _fee, data);
    }

    function withdrawShib(address to, uint256 amount) external onlyOwner {

        SHIB.transfer(to, amount);
    }

    function withdrawAny(
        address token,
        address to,
        uint256 amount
    ) external onlyOwner {

        IERC20(token).transfer(to, amount);
    }

    function receiveData(uint256 _price, bytes32) internal override {

        ethToShib = _price;
    }

    function _uncheckedInc(uint256 i) internal pure returns (uint256) {

        unchecked {
            return i + 1;
        }
    }

    function _encodeXY(int16 x, int16 y) internal pure returns (uint32) {

        return
            ((uint32(uint16(x)) * factor) & clearLow) |
            (uint32(uint16(y)) & clearHigh);
    }

    function _decodeXY(uint32 value) internal pure returns (int16 x, int16 y) {

        x = _expandNegative16BitCast((value & clearLow) >> 16);
        y = _expandNegative16BitCast(value & clearHigh);
    }

    function _expandNegative16BitCast(uint32 value)
        internal
        pure
        returns (int16)
    {

        if (value & (1 << 15) != 0) {
            return int16(int32(value | clearLow));
        }
        return int16(int32(value));
    }
}