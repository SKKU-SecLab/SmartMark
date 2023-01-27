
pragma solidity ^0.8.0;

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}// MIT

pragma solidity ^0.8.0;


interface IERC1155 is IERC165 {

    event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value);

    event TransferBatch(address indexed operator, address indexed from, address indexed to, uint256[] ids, uint256[] values);

    event ApprovalForAll(address indexed account, address indexed operator, bool approved);

    event URI(string value, uint256 indexed id);

    function balanceOf(address account, uint256 id) external view returns (uint256);


    function balanceOfBatch(address[] calldata accounts, uint256[] calldata ids) external view returns (uint256[] memory);


    function setApprovalForAll(address operator, bool approved) external;


    function isApprovedForAll(address account, address operator) external view returns (bool);


    function safeTransferFrom(address from, address to, uint256 id, uint256 amount, bytes calldata data) external;


    function safeBatchTransferFrom(address from, address to, uint256[] calldata ids, uint256[] calldata amounts, bytes calldata data) external;

}// MIT

pragma solidity ^0.8.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}// MIT

pragma solidity ^0.8.0;

library Address {

    function isContract(address account) internal view returns (bool) {


        uint256 size;
        assembly { size := extcodesize(account) }
        return size > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {

      return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {

        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {

        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {

        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {

        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {

        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {

        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {

        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {

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

    function safeTransfer(IERC20 token, address to, uint256 value) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint256 value) internal {

        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {


        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}// MIT

pragma solidity ^0.8.0;


interface IERC1155Receiver is IERC165 {


    function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes calldata data
    )
        external
        returns(bytes4);


    function onERC1155BatchReceived(
        address operator,
        address from,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    )
        external
        returns(bytes4);

}// MIT

pragma solidity ^0.8.0;


abstract contract ERC165 is IERC165 {
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}// MIT

pragma solidity ^0.8.0;


abstract contract ERC1155Receiver is ERC165, IERC1155Receiver {
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return interfaceId == type(IERC1155Receiver).interfaceId
            || super.supportsInterface(interfaceId);
    }
}// MIT

pragma solidity ^0.8.0;


contract ERC1155Holder is ERC1155Receiver {

    function onERC1155Received(address, address, uint256, uint256, bytes memory) public virtual override returns (bytes4) {

        return this.onERC1155Received.selector;
    }

    function onERC1155BatchReceived(address, address, uint256[] memory, uint256[] memory, bytes memory) public virtual override returns (bytes4) {

        return this.onERC1155BatchReceived.selector;
    }
}// MIT

pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}// MIT

pragma solidity ^0.8.0;

library Strings {

    bytes16 private constant alphabet = "0123456789abcdef";

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
            buffer[i] = alphabet[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }

}// MIT

pragma solidity ^0.8.0;


interface IAccessControl {

    function hasRole(bytes32 role, address account) external view returns (bool);

    function getRoleAdmin(bytes32 role) external view returns (bytes32);

    function grantRole(bytes32 role, address account) external;

    function revokeRole(bytes32 role, address account) external;

    function renounceRole(bytes32 role, address account) external;

}

abstract contract AccessControl is Context, IAccessControl, ERC165 {
    struct RoleData {
        mapping (address => bool) members;
        bytes32 adminRole;
    }

    mapping (bytes32 => RoleData) private _roles;

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);

    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    modifier onlyRole(bytes32 role) {
        _checkRole(role, _msgSender());
        _;
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IAccessControl).interfaceId
            || super.supportsInterface(interfaceId);
    }

    function hasRole(bytes32 role, address account) public view override returns (bool) {
        return _roles[role].members[account];
    }

    function _checkRole(bytes32 role, address account) internal view {
        if(!hasRole(role, account)) {
            revert(string(abi.encodePacked(
                "AccessControl: account ",
                Strings.toHexString(uint160(account), 20),
                " is missing role ",
                Strings.toHexString(uint256(role), 32)
            )));
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
        emit RoleAdminChanged(role, getRoleAdmin(role), adminRole);
        _roles[role].adminRole = adminRole;
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

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

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

        mapping (bytes32 => uint256) _indexes;
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

        if (valueIndex != 0) { // Equivalent to contains(set, value)

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;


            bytes32 lastvalue = set._values[lastIndex];

            set._values[toDeleteIndex] = lastvalue;
            set._indexes[lastvalue] = valueIndex; // Replace lastvalue's index to valueIndex

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

        require(set._values.length > index, "EnumerableSet: index out of bounds");
        return set._values[index];
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
}// MIT

pragma solidity ^0.8.0;

abstract contract ReentrancyGuard {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor () {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
    }
}// MIT
pragma solidity >=0.6.0;

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


}pragma solidity >=0.8.0;


contract MogulMarketplace is ERC1155Holder, AccessControl, ReentrancyGuard {

    using EnumerableSet for EnumerableSet.UintSet;
    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    AggregatorV3Interface priceOracle;

    bytes32 public constant ROLE_ADMIN = keccak256("ROLE_ADMIN");
    address payable public treasuryWallet;
    IERC20 stars;
    uint256 nextListingId = 0;
    uint256 listingFee = 0; //4 decimals
    address mogulNFTAddress;

    struct Listing {
        address payable seller;
        string label;
        string description;
        address tokenAddress;
        uint256 tokenId;
        uint256 numTokens;
        uint256 price;
        bool isStarsListing;
    }

    struct Auction {
        string label;
        address tokenAddress;
        uint256 tokenId;
        uint256 numTokens;
        uint256 startingStarsPrice;
        uint256 startingEthPrice;
        uint256 startTime;
        uint256 endTime;
        bool allowStarsBids;
        bool allowEthBids;
        Bid highestStarsBid;
        Bid highestEthBid;
    }

    struct Bid {
        address payable bidder;
        uint256 amount;
    }

    mapping(uint256 => Listing) public listings;
    EnumerableSet.UintSet private listingIds;

    mapping(uint256 => Auction) public auctions;
    EnumerableSet.UintSet private auctionIds;

    event ListingCreated(
        string label,
        string description,
        address tokenAddress,
        uint256 tokenId,
        uint256 numTokens,
        uint256 price,
        bool isStarsListing
    );
    event Sale(address buyer, uint256 listingId, uint256 amount);
    event AuctionEnded(address winner, uint256 auctionId);
    event AuctionCancelled(uint256 auctionId);

    modifier onlyAdmin {

        require(hasRole(ROLE_ADMIN, msg.sender), "Sender is not admin");
        _;
    }

    constructor(
        address starsAddress,
        address _admin,
        address payable _treasuryWallet,
        address _mogulNFTAddress
    ) public ReentrancyGuard() {
        require(
            _treasuryWallet != address(0),
            "Treasury wallet cannot be 0 address"
        );
        _setupRole(ROLE_ADMIN, _admin);
        _setRoleAdmin(ROLE_ADMIN, ROLE_ADMIN);

        treasuryWallet = _treasuryWallet;
        stars = IERC20(starsAddress);

        mogulNFTAddress = _mogulNFTAddress;
    }

    function setPriceOracle(address priceOracleAddress) external onlyAdmin {

        priceOracle = AggregatorV3Interface(priceOracleAddress);
    }

    function getStarsPrice() public view returns (uint256) {

        (
            uint80 roundID,
            int256 price,
            uint256 startedAt,
            uint256 timeStamp,
            uint80 answeredInRound
        ) = priceOracle.latestRoundData();
        return uint256(price);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(ERC1155Receiver, AccessControl)
        returns (bool)
    {

        return super.supportsInterface(interfaceId);
    }

    function getNumListings() external view returns (uint256) {

        return listingIds.length();
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

    function getNumAuctions() external view returns (uint256) {

        return auctionIds.length();
    }

    function getAuctionIds(uint256 index) external view returns (uint256) {

        return auctionIds.at(index);
    }

    function getAuctionAtIndex(uint256 index)
        external
        view
        returns (Auction memory)
    {

        return auctions[auctionIds.at(index)];
    }

    function listTokens(
        string memory label,
        string memory description,
        address tokenAddress,
        uint256 tokenId,
        uint256 numTokens,
        uint256 price,
        bool isStarsListing
    ) external nonReentrant() {

        require(
            tokenAddress == mogulNFTAddress,
            "Only Mogul NFTs can be listed"
        );

        IERC1155 token = IERC1155(tokenAddress);
        token.safeTransferFrom(
            msg.sender,
            address(this),
            tokenId,
            numTokens,
            ""
        );
        uint256 listingId = generateListingId();
        listings[listingId] = Listing(
            payable(msg.sender),
            label,
            description,
            tokenAddress,
            tokenId,
            numTokens,
            price,
            isStarsListing
        );
        listingIds.add(listingId);

        emit ListingCreated(
            label,
            description,
            tokenAddress,
            tokenId,
            numTokens,
            price,
            isStarsListing
        );
    }

    function removeListing(uint256 listingId) external {

        Listing storage listing = listings[listingId];
        require(
            msg.sender == listing.seller || hasRole(ROLE_ADMIN, msg.sender),
            "Sender is not seller or admin"
        );

        IERC1155 token = IERC1155(listing.tokenAddress);
        token.safeTransferFrom(
            address(this),
            treasuryWallet,
            listing.tokenId,
            listing.numTokens,
            ""
        );
        listingIds.remove(listingId);
    }

    function buyTokens(uint256 listingId, uint256 amount)
        external
        payable
        nonReentrant()
    {

        require(listingIds.contains(listingId), "Listing does not exist.");

        Listing storage listing = listings[listingId];

        require(listing.numTokens >= amount, "Not enough tokens remaining");

        uint256 fullAmount = listing.price.mul(amount);
        uint256 fee = fullAmount.mul(listingFee).div(10000);

        if (listing.isStarsListing) {
            if (fee > 0) {
                stars.safeTransferFrom(msg.sender, address(this), fee);
            }

            stars.safeTransferFrom(
                msg.sender,
                listing.seller,
                fullAmount.sub(fee)
            );
        } else {
            require(msg.value == fullAmount, "Incorrect transaction value");

            listing.seller.transfer(fullAmount.sub(fee));
        }

        listing.numTokens -= amount;

        if (listing.numTokens == 0) {
            listingIds.remove(listingId);
        }

        IERC1155 token = IERC1155(listing.tokenAddress);
        token.safeTransferFrom(
            address(this),
            msg.sender,
            listing.tokenId,
            amount,
            ""
        );

        emit Sale(msg.sender, listingId, amount);
    }

    function startAuction(
        string memory label,
        address tokenAddress,
        uint256 tokenId,
        uint256 numTokens,
        uint256 startingStarsPrice,
        uint256 startingEthPrice,
        uint256 startTime,
        uint256 endTime,
        bool allowStarsBids,
        bool allowEthBids
    ) external onlyAdmin nonReentrant() {

        require(
            allowStarsBids || allowEthBids,
            "One of ETH bids or Stars bids must be allowed"
        );

        IERC1155 token = IERC1155(tokenAddress);
        token.safeTransferFrom(
            msg.sender,
            address(this),
            tokenId,
            numTokens,
            ""
        );

        uint256 auctionId = generateAuctionId();
        auctions[auctionId] = Auction(
            label,
            tokenAddress,
            tokenId,
            numTokens,
            startingStarsPrice,
            startingEthPrice,
            startTime,
            endTime,
            allowStarsBids,
            allowEthBids,
            Bid(payable(address(msg.sender)), 0),
            Bid(payable(address(msg.sender)), 0)
        );
        auctionIds.add(auctionId);
    }

    function bid(
        uint256 auctionId,
        bool isStarsBid,
        uint256 amount
    ) external payable nonReentrant() {

        Auction storage auction = auctions[auctionId];
        require(
            block.timestamp >= auction.startTime &&
                block.timestamp <= auction.endTime,
            "Cannot place bids at this time"
        );
        if (isStarsBid) {
            require(auction.allowStarsBids, "Auction does not accept Stars");
            require(
                amount > auction.highestStarsBid.amount &&
                    amount > auction.startingStarsPrice,
                "Bid is too low"
            );
            stars.safeTransferFrom(msg.sender, address(this), amount);
            stars.safeTransfer(
                auction.highestStarsBid.bidder,
                auction.highestStarsBid.amount
            );
            auction.highestStarsBid = Bid(payable(address(msg.sender)), amount);
        } else {
            require(auction.allowEthBids, "Auction does not accept ether");
            require(
                amount > auction.highestEthBid.amount &&
                    amount > auction.startingEthPrice,
                "Bid is too low"
            );
            require(amount == msg.value, "Amount does not match message value");
            auction.highestEthBid.bidder.transfer(auction.highestEthBid.amount);
            auction.highestEthBid = Bid(payable(address(msg.sender)), amount);
        }
    }

    function endAuctionWithoutOracle(uint256 auctionId, bool didStarsBidWin)
        external
        onlyAdmin
        nonReentrant()
    {

        require(auctionIds.contains(auctionId), "Auction does not exist");
        Auction memory auction = auctions[auctionId];
        require(block.timestamp >= auction.endTime, "Auction is ongoing");
        address winner;

        if (didStarsBidWin) {
            require(
                auction.allowStarsBids,
                "Auction did not support Stars bids"
            );
            winner = auction.highestStarsBid.bidder;
        } else {
            require(auction.allowEthBids, "Auction did not support Stars bids");
            winner = auction.highestEthBid.bidder;
        }

        IERC1155(auction.tokenAddress).safeTransferFrom(
            address(this),
            winner,
            auction.tokenId,
            auction.numTokens,
            ""
        );
        auctionIds.remove(auctionId);
        emit AuctionEnded(winner, auctionId);
    }

    function endAuction(uint256 auctionId) external onlyAdmin nonReentrant() {

        require(auctionIds.contains(auctionId), "Auction does not exist");
        Auction memory auction = auctions[auctionId];
        require(block.timestamp >= auction.endTime, "Auction is ongoing");
        address winner;

        if (auction.allowEthBids && auction.allowStarsBids) {
            uint256 ethToStars =
                auction.highestEthBid.amount.mul(getStarsPrice()).div(1e8);
            if (ethToStars > auction.highestStarsBid.amount) {
                winner = auction.highestEthBid.bidder;
                stars.safeTransfer(
                    auction.highestStarsBid.bidder,
                    auction.highestStarsBid.amount
                );
            } else {
                winner = auction.highestStarsBid.bidder;
                auction.highestEthBid.bidder.transfer(
                    auction.highestEthBid.amount
                );
            }
        } else if (auction.allowEthBids) {
            winner = auction.highestEthBid.bidder;
        } else {
            winner = auction.highestStarsBid.bidder;
        }

        IERC1155(auction.tokenAddress).safeTransferFrom(
            address(this),
            winner,
            auction.tokenId,
            auction.numTokens,
            ""
        );
        auctionIds.remove(auctionId);
        emit AuctionEnded(winner, auctionId);
    }

    function cancelAuction(uint256 auctionId)
        external
        onlyAdmin
        nonReentrant()
    {

        require(auctionIds.contains(auctionId), "Auction does not exist");
        Auction memory auction = auctions[auctionId];

        auction.highestEthBid.bidder.transfer(auction.highestEthBid.amount);
        stars.safeTransfer(
            auction.highestStarsBid.bidder,
            auction.highestStarsBid.amount
        );
        auctionIds.remove(auctionId);
        emit AuctionCancelled(auctionId);
    }

    function generateListingId() internal returns (uint256) {

        return nextListingId++;
    }

    function generateAuctionId() internal returns (uint256) {

        return nextListingId++;
    }

    function withdrawETH() external onlyAdmin {

        require(auctionIds.length() == 0, "Auctions are ongoing");
        treasuryWallet.transfer(address(this).balance);
    }

    function withdrawStars() external onlyAdmin {

        require(auctionIds.length() == 0, "Auctions are ongoing");
        stars.safeTransfer(treasuryWallet, stars.balanceOf(address(this)));
    }

    function setMogulNFTAddress(address _mogulNFTAddress) external onlyAdmin {

        mogulNFTAddress = _mogulNFTAddress;
    }
}