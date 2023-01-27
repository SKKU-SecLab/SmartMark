
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
}// MIT

pragma solidity ^0.8.0;


interface IERC20Metadata is IERC20 {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function decimals() external view returns (uint8);

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
}// MIT

pragma solidity ^0.8.0;


library SafeERC20 {

    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {

        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {

        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {

        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {


        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
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


contract ERC721Holder is IERC721Receiver {

    function onERC721Received(
        address,
        address,
        uint256,
        bytes memory
    ) public virtual override returns (bytes4) {

        return this.onERC721Received.selector;
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


library SafeMath {

    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        return a + b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        return a * b;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        return a % b;
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
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

interface AggregatorV3Interface {

  function decimals() external view returns (uint8);


  function description() external view returns (string memory);


  function version() external view returns (uint256);


  function getRoundData(uint80 _roundId)
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );


  function latestRoundData()
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );

}// GPL-3.0-only
pragma solidity ^0.8.3;

contract ISimpleOracle {

  function getReservesForTokenPool(address _token)
    public
    view
    virtual
    returns (uint256 wethReserve, uint256 tokenReserve)
  {}


  function getTokenPrice(address tbnTokenAddress, address paymentTokenAddress)
    public
    view
    virtual
    returns (uint256)
  {}

}pragma solidity ^0.8.2;


abstract contract ITBNERC721 is IERC721 {
  struct TokenData {
    address tokenAddress;
    uint256 tokenAmount;
  }

  mapping(uint256 => TokenData) public nftsToTokenData;

  function retrieve(uint256 tokenId) public {}

  function mint(
    address paymentTokenAddress,
    uint256 paymentTokenAmount,
    string memory tokenData
  ) public payable returns (uint256) {}

  function pause() public {}

  function unpause() public {}
}// MIT
pragma solidity ^0.8.0;


contract IChainLinkOracle {
  function getAvailableToken(address tokenAddress)
    external
    view
    virtual
    returns (address)
  {}

  function setAvailableToken(address tokenAddress, address dataFeedAddress)
    external
    virtual
  {}

  function getAvailableTokenBatch(address[] memory tokenAddresss)
    external
    view
    virtual
    returns (address[] memory)
  {}

  function setAvailableTokenBatch(
    address[] memory tokenAddresss,
    address[] memory dataFeedAddresses
  ) external virtual {}

  function getLatestPrice(address tokenAddress)
    external
    view
    virtual
    returns (uint256)
  {}

  function hasToken(address tokenAddress) public view virtual returns (bool) {}
}pragma solidity ^0.8.0;
pragma experimental ABIEncoderV2;


contract TBNMarketplaceV2 is ERC721Holder, AccessControl, ReentrancyGuard {
  using EnumerableSet for EnumerableSet.UintSet;
  using SafeERC20 for IERC20;
  using SafeMath for uint256;

  bytes32 public constant ROLE_ADMIN = keccak256("ROLE_ADMIN");
  address public treasuryWallet;
  address public tbnNftAddress;
  address public wethAddress;
  IChainLinkOracle public chainLink;
  ISimpleOracle public oracle;
  uint256 public basisPointFee;
  uint256 public nextListingId;
  uint256 public errorMarginBasisPoint = 500;

  struct Listing {
    address ownerAddress;
    address nftTokenAddress;
    address paymentTokenAddress;
    uint256 priceBandBasisPoint;
    uint256 nftTokenId;
    uint256 fixedPrice; // min price listing is willing to sell for or payment amount if not price bound
    bool isPriceBound; // if true then price is bound to marketplace
  }

  mapping(uint256 => Listing) public listings;
  mapping(address => uint256[]) public sellerListings; // Get all TBNS for an address

  EnumerableSet.UintSet private listingIds;

  event ListingCreated(
    address ownerAddress,
    address nftTokenAddress,
    address TBNAddress,
    address paymentTokenAddress,
    uint256 TBNAmount,
    uint256 priceBandBasisPoint,
    uint256 nftTokenId,
    uint256 listingId,
    uint256 fixedPrice,
    bool isPriceBound
  );
  event ListingRemoved(uint256 listingId);
  event ListingSold(
    uint256 listingId,
    uint256 tbnTokenId,
    uint256 tbnTokenAmount,
    uint256 paymentTokenAmount,
    address tbnTokenAddress,
    address paymentTokenAddress,
    address buyer,
    address seller
  );

  modifier onlyAdmin() {
    require(hasRole(ROLE_ADMIN, msg.sender), "Sender is not admin");
    _;
  }

  constructor(
    address _admin,
    address payable _treasuryWallet,
    address _tbnNFTAddress,
    address _oracleAddress,
    address _chainLinkAddress,
    address _wethAddress,
    uint256 _basisPointFee
  ) {
    require(_admin != address(0), "Admin wallet cannot be 0 address");
    require(
      _treasuryWallet != address(0),
      "Treasury wallet cannot be 0 address"
    );
    require(_tbnNFTAddress != address(0), "TBN address cannot be 0 address");
    require(_oracleAddress != address(0), "Uniswap oracle cannot be 0 address");
    require(
      _chainLinkAddress != address(0),
      "Chainlink oracle cannot be 0 address"
    );
    require(_wethAddress != address(0), "Weth address cannot be 0 address");
    require(_basisPointFee < 10000, "Basis point fee must be less than 10000");
    _setupRole(ROLE_ADMIN, _admin);
    _setRoleAdmin(ROLE_ADMIN, ROLE_ADMIN);

    treasuryWallet = _treasuryWallet;
    tbnNftAddress = _tbnNFTAddress;

    oracle = ISimpleOracle(_oracleAddress);
    chainLink = IChainLinkOracle(_chainLinkAddress);

    basisPointFee = _basisPointFee;
    wethAddress = _wethAddress;
  }

  function updateWethAddress(address newWeth) external onlyAdmin {
    require(newWeth != address(0), "Weth cannot be 0 address");
    wethAddress = newWeth;
  }

  function updateOracleAddress(address newOracle) external onlyAdmin {
    require(newOracle != address(0), "Uniswap oracle cannot be 0 address");
    oracle = ISimpleOracle(newOracle);
  }

  function updateChainLinkOracleAddress(address newChainLinkOracle)
    external
    onlyAdmin
  {
    require(
      newChainLinkOracle != address(0),
      "Chainlink oracle cannot be 0 address"
    );
    chainLink = IChainLinkOracle(newChainLinkOracle);
  }

  function updateErrorMarginBasisPoint(uint256 newErrorMarginBasisPoint)
    external
    onlyAdmin
  {
    require(
      newErrorMarginBasisPoint <= 10000,
      "Error margin must be less than 10,000"
    );
    errorMarginBasisPoint = newErrorMarginBasisPoint;
  }

  function updateTbnNftAddress(address _tbnNftAddress) external onlyAdmin {
    require(_tbnNftAddress != address(0), "TBN address cannot be 0");
    tbnNftAddress = _tbnNftAddress;
  }

  function updateBasisPointFee(uint256 _basisPointFee) external onlyAdmin {
    require(_basisPointFee <= 10000, "Basis point cannot be more than 10,000");
    basisPointFee = _basisPointFee;
  }

  function updateTreasuryWalletAddress(address payable _treasuryWallet)
    external
    onlyAdmin
  {
    require(
      _treasuryWallet != address(0),
      "Treasury wallet cannot be 0 address"
    );
    treasuryWallet = _treasuryWallet;
  }

  function getNumListings() external view returns (uint256) {
    return listingIds.length();
  }

  function getListingIdsByUser(address userAddress)
    external
    view
    returns (uint256[] memory)
  {
    return sellerListings[userAddress];
  }

  function getListingsByListingIds(uint256[] calldata ids)
    external
    view
    returns (Listing[] memory)
  {
    Listing[] memory userListings = new Listing[](ids.length);
    for (uint256 i = 0; i < userListings.length; i++) {
      userListings[i] = listings[ids[i]];
    }
    return userListings;
  }

  function getListingIds(uint256 index) external view returns (uint256) {
    return listingIds.at(index);
  }

  function getListingAtIndex(uint256 index)
    external
    view
    returns (Listing memory)
  {
    return listings[listingIds.at(index)];
  }

  function listTBNTokens(
    address nftTokenAddress,
    address paymentTokenAddress,
    uint256 priceBandBasisPoint,
    uint256 nftTokenId,
    uint256 fixedPrice,
    bool priceBound
  ) external nonReentrant {
    require(nftTokenAddress == tbnNftAddress, "Only TBN NFTs can be listed");
    ITBNERC721 token = ITBNERC721(nftTokenAddress);
    (address TBNAddress, uint256 TBNAmount) = token.nftsToTokenData(nftTokenId);
    require(
      paymentTokenAddress != TBNAddress,
      "The same pair of tokens cannot be listed"
    );
    token.safeTransferFrom(msg.sender, address(this), nftTokenId);

    uint256 listingId = generateListingId();
    listings[listingId] = Listing(
      msg.sender,
      nftTokenAddress,
      paymentTokenAddress,
      priceBandBasisPoint,
      nftTokenId,
      fixedPrice,
      priceBound
    );
    listingIds.add(listingId);
    sellerListings[msg.sender].push(listingId);

    emit ListingCreated(
      msg.sender,
      nftTokenAddress,
      TBNAddress,
      paymentTokenAddress,
      TBNAmount,
      priceBandBasisPoint,
      nftTokenId,
      listingId,
      fixedPrice,
      priceBound
    );
  }

  function removeListing(uint256 listingId) external {
    require(listingIds.contains(listingId), "Listing does not exist.");
    Listing memory listing = listings[listingId];
    require(
      msg.sender == listing.ownerAddress,
      "You must be the person who created the listing"
    );

    IERC721 token = IERC721(listing.nftTokenAddress);
    token.safeTransferFrom(
      address(this),
      listing.ownerAddress,
      listing.nftTokenId
    );
    listingIds.remove(listingId);

    _removeFromSellersListings(listingId);

    emit ListingRemoved(listingId);
  }

  function buyToken(uint256 listingId, uint256 expectedPaymentAmount)
    external
    payable
    nonReentrant
  {
    require(listingIds.contains(listingId), "Listing does not exist.");
    Listing storage listing = listings[listingId];
    ITBNERC721 token = ITBNERC721(listing.nftTokenAddress);
    (address TBNAddress, uint256 TBNAmount) = token.nftsToTokenData(
      listing.nftTokenId
    );
    require(TBNAmount > 0, "TBN does not contain any tokens");
    uint256 fullCost;

    if (!listing.isPriceBound) {
      fullCost = listing.fixedPrice;
    } else {
      uint256 paymentTokensPerTBNToken;
      uint8 tbnTokenDecimals = 18;
      uint8 paymentTokenDecimals = 18;
      uint256 tbnPrice;
      uint256 paymentPrice;
      bool isNative = false;

      if (
        chainLink.hasToken(listing.paymentTokenAddress) &&
        chainLink.hasToken(TBNAddress)
      ) {
        tbnPrice = chainLink.getLatestPrice(TBNAddress);
        paymentPrice = chainLink.getLatestPrice(listing.paymentTokenAddress);
        paymentTokensPerTBNToken = (tbnPrice * 1 ether) / paymentPrice;
      } else if (
        listing.paymentTokenAddress == address(0) ||
        listing.paymentTokenAddress == wethAddress
      ) {
        isNative = true;
        (uint256 tbnWETHReserves, uint256 tbnTokenReserves) = oracle
          .getReservesForTokenPool(TBNAddress);
        tbnPrice = (tbnWETHReserves * 1 ether) / tbnTokenReserves;
        paymentPrice = 1 ether;
        paymentTokensPerTBNToken = (tbnPrice * 1 ether) / paymentPrice;
      } else if (TBNAddress == address(0) || TBNAddress == wethAddress) {
        isNative = true;
        tbnPrice = 1 ether;
        (uint256 paymentWETHReserves, uint256 paymentTokenReserves) = oracle
          .getReservesForTokenPool(listing.paymentTokenAddress);
        paymentPrice = (paymentWETHReserves * 1 ether) / paymentTokenReserves;
        paymentTokensPerTBNToken = (tbnPrice * 1 ether) / paymentPrice;
      } else {
        paymentTokensPerTBNToken = oracle.getTokenPrice(
          TBNAddress,
          listing.paymentTokenAddress
        );
      }

      if (TBNAddress != address(0)) {
        tbnTokenDecimals = IERC20Metadata(TBNAddress).decimals();
      }
      if (listing.paymentTokenAddress != address(0)) {
        paymentTokenDecimals = IERC20Metadata(listing.paymentTokenAddress)
          .decimals();
      }

      if (paymentTokenDecimals > tbnTokenDecimals && !isNative) {
        fullCost =
          (paymentTokensPerTBNToken *
            TBNAmount *
            listing.priceBandBasisPoint *
            (10**(paymentTokenDecimals - tbnTokenDecimals))) /
          (10000 * (1 ether));
      } else if (tbnTokenDecimals > paymentTokenDecimals && !isNative) {
        fullCost =
          (paymentTokensPerTBNToken * TBNAmount * listing.priceBandBasisPoint) /
          (10000 * (1 ether) * (10**(tbnTokenDecimals - paymentTokenDecimals)));
      } else {
        fullCost =
          (paymentTokensPerTBNToken * TBNAmount * listing.priceBandBasisPoint) /
          (10000 * (1 ether));
      }

      if (fullCost < listing.fixedPrice) {
        fullCost = listing.fixedPrice;
      }
    }

    require(
      expectedPaymentAmount <
        ((fullCost * (10000 + errorMarginBasisPoint)) / 10000),
      "Oracle price above error margin"
    );
    require(
      expectedPaymentAmount >
        ((fullCost * (10000 - errorMarginBasisPoint)) / 10000),
      "Oracle price below error margin"
    );

    uint256 payoutToTreasury = (fullCost.mul(basisPointFee)).div(10000);
    uint256 payoutToSeller = fullCost.sub(payoutToTreasury);

    IERC20 paymentToken = IERC20(listing.paymentTokenAddress);

    if (listing.paymentTokenAddress == address(0)) {
      require(msg.value >= fullCost, "Incorrect transaction value.");
      if (msg.value > fullCost) {
        payable(msg.sender).transfer(msg.value - fullCost);
      }
      payable(listing.ownerAddress).transfer(payoutToSeller);
      payable(treasuryWallet).transfer(payoutToTreasury);
    } else {
      paymentToken.safeTransferFrom(
        msg.sender,
        listing.ownerAddress,
        payoutToSeller
      );
      paymentToken.safeTransferFrom(
        msg.sender,
        treasuryWallet,
        payoutToTreasury
      );
    }
    token.safeTransferFrom(address(this), msg.sender, listing.nftTokenId);

    listingIds.remove(listingId);
    _removeFromSellersListings(listingId);
    emit ListingSold(
      listingId,
      listing.nftTokenId,
      TBNAmount,
      fullCost,
      TBNAddress,
      listing.paymentTokenAddress,
      msg.sender,
      listing.ownerAddress
    );
  }

  function generateListingId() internal returns (uint256) {
    return nextListingId++;
  }

  function _removeFromSellersListings(uint256 listingId) internal {
    for (uint256 i = 0; i < sellerListings[msg.sender].length; i++) {
      if (sellerListings[msg.sender][i] == listingId) {
        delete sellerListings[msg.sender][i];
        return;
      }
    }
  }
}