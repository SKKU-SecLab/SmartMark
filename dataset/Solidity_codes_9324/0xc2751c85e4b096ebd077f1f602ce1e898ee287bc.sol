
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

pragma solidity ^0.8.1;

library Address {

    function isContract(address account) internal view returns (bool) {


        return account.code.length > 0;
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
}// UNLICENSED
pragma solidity >=0.8.0;


contract MogulMarketplaceERC721 is
    ERC721Holder,
    AccessControl,
    ReentrancyGuard
{

    using EnumerableSet for EnumerableSet.UintSet;
    using EnumerableSet for EnumerableSet.AddressSet;
    using SafeERC20 for IERC20;

    bytes32 public constant ROLE_ADMIN = keccak256("ROLE_ADMIN");
    address payable public treasuryWallet;
    IERC20 stars;
    uint256 public nextListingId;
    uint256 public nextAuctionId;
    uint256 public starsFeeBasisPoint; //4 decimals, applies to auctions and listings. Fees collected are held in contract
    uint256 public ethFeeBasisPoint; //4 decimals, applies to auctions and listings. Fees collected are held in contract
    uint256 public adminEth; //Total Ether available for withdrawal
    uint256 public adminStars; //Total Stars available for withdrawal
    uint256 private highestCommissionBasisPoint; //Used to determine what the maximum fee
    uint256 public starsAvailableForCashBack; //STARS available for cashback
    uint256 public starsCashBackBasisPoint = 500;
    bool public starsAllowed = true;
    bool public ethAllowed = true;

    struct Listing {
        address payable seller;
        address tokenAddress;
        uint256 tokenId;
        uint256 starsPrice;
        uint256 ethPrice;
        bool isStarsListing;
        bool isEthListing;
    }

    struct Auction {
        address payable seller;
        address tokenAddress;
        uint256 tokenId;
        uint256 startingPrice;
        uint256 startTime;
        uint256 endTime;
        uint256 reservePrice;
        bool isStarsAuction;
        Bid highestBid;
    }

    struct Bid {
        address payable bidder;
        uint256 amount;
    }

    struct TokenCommissionInfo {
        address payable artistAddress;
        uint256 commissionBasisPoint; //4 decimals
    }

    EnumerableSet.AddressSet private mogulNFTs;
    EnumerableSet.UintSet private listingIds;
    EnumerableSet.UintSet private auctionIds;

    mapping(uint256 => Listing) public listings;
    mapping(uint256 => Auction) public auctions;
    mapping(address => TokenCommissionInfo) public commissions; //NFT address to TokenCommissionInfo

    event ListingCreated(
        uint256 listingId,
        address seller,
        address tokenAddress,
        uint256 tokenId,
        uint256 tokenAmount,
        uint256 starsPrice,
        uint256 ethPrice,
        bool isStarsListing,
        bool isEthListing
    );
    event ListingCancelled(uint256 listingId);
    event ListingPriceChanged(
        uint256 listingId,
        uint256 newPrice,
        bool isStarsPrice
    );
    event AuctionCreated(
        uint256 auctionId,
        address seller,
        address tokenAddress,
        uint256 tokenId,
        uint256 tokenAmount,
        uint256 startingPrice,
        uint256 startTime,
        uint256 endTime,
        uint256 reservePrice,
        bool isStarsAuction
    );
    event SaleMade(
        address buyer,
        uint256 listingId,
        uint256 amount,
        bool isStarsPurchase
    );
    event BidPlaced(
        address bidder,
        uint256 auctionId,
        uint256 amount,
        bool isStarsBid
    );
    event AuctionClaimed(address winner, uint256 auctionId);
    event AuctionCancelled(uint256 auctionId);
    event AuctionReservePriceChanged(
        uint256 auctionId,
        uint256 newReservePrice
    );
    event TokenCommissionAdded(
        address tokenAddress,
        address artistAddress,
        uint256 commissionBasisPoint
    );
    event StarsCashBackBasisPointSet(uint256 newStarsCashBackBasisPoint);
    event StarsFeeBasisPointSet(uint256 newStarsFeeBasisPoint);
    event EthFeeBasisPointSet(uint256 newEthFeeBasisPoint);

    modifier onlyAdmin {

        require(hasRole(ROLE_ADMIN, msg.sender), "Sender is not admin");
        _;
    }

    modifier sellerOrAdmin(address seller) {

        require(
            msg.sender == seller || hasRole(ROLE_ADMIN, msg.sender),
            "Sender is not seller or admin"
        );
        _;
    }

    constructor(
        address starsAddress,
        address _admin,
        address payable _treasuryWallet,
        address _mogulNFTAddress
    ) {
        require(
            _treasuryWallet != address(0),
            "Treasury wallet cannot be 0 address"
        );
        _setupRole(ROLE_ADMIN, _admin);
        _setRoleAdmin(ROLE_ADMIN, ROLE_ADMIN);

        treasuryWallet = _treasuryWallet;
        stars = IERC20(starsAddress);

        mogulNFTs.add(_mogulNFTAddress);
    }

    function getNumListings() external view returns (uint256) {

        return listingIds.length();
    }

    function getListingIds(uint256[] memory indices)
        external
        view
        returns (uint256[] memory)
    {

        uint256[] memory output = new uint256[](indices.length);
        for (uint256 i = 0; i < indices.length; i++) {
            output[i] = listingIds.at(indices[i]);
        }
        return output;
    }

    function getListingsAtIndices(uint256[] memory indices)
        external
        view
        returns (Listing[] memory)
    {

        Listing[] memory output = new Listing[](indices.length);
        for (uint256 i = 0; i < indices.length; i++) {
            output[i] = listings[listingIds.at(indices[i])];
        }
        return output;
    }

    function getNumAuctions() external view returns (uint256) {

        return auctionIds.length();
    }

    function getAuctionIds(uint256[] memory indices)
        external
        view
        returns (uint256[] memory)
    {

        uint256[] memory output = new uint256[](indices.length);
        for (uint256 i = 0; i < indices.length; i++) {
            output[i] = auctionIds.at(indices[i]);
        }
        return output;
    }

    function getAuctionsAtIndices(uint256[] memory indices)
        external
        view
        returns (Auction[] memory)
    {

        Auction[] memory output = new Auction[](indices.length);
        for (uint256 i = 0; i < indices.length; i++) {
            output[i] = auctions[auctionIds.at(indices[i])];
        }
        return output;
    }

    function createListing(
        address tokenAddress,
        uint256 tokenId,
        uint256 tokenAmount,
        uint256 starsPrice,
        uint256 ethPrice,
        bool isStarsListing,
        bool isEthListing
    ) public nonReentrant() {

        require(
            mogulNFTs.contains(tokenAddress),
            "Only Mogul NFTs can be listed"
        );
        if (isStarsListing) {
            require(starsPrice != 0, "Price cannot be 0");
        }
        if (isEthListing) {
            require(ethPrice != 0, "Price cannot be 0");
        }

        if (isStarsListing) {
            require(starsAllowed, "STARS listings are not allowed");
        }
        if (isEthListing) {
            require(ethAllowed, "ETH listings are not allowed");
        }

        IERC721 token = IERC721(tokenAddress);
        token.safeTransferFrom(msg.sender, address(this), tokenId);
        uint256 listingId = generateListingId();
        listings[listingId] = Listing(
            payable(msg.sender),
            tokenAddress,
            tokenId,
            starsPrice,
            ethPrice,
            isStarsListing,
            isEthListing
        );
        listingIds.add(listingId);

        emit ListingCreated(
            listingId,
            msg.sender,
            tokenAddress,
            tokenId,
            1,
            starsPrice,
            ethPrice,
            isStarsListing,
            isEthListing
        );
    }

    function batchCreateListings(
        address[] calldata tokenAddresses,
        uint256[] calldata tokenIds,
        uint256[] calldata starsPrices,
        uint256[] calldata ethPrices,
        bool[] memory areStarsListings,
        bool[] memory areEthListings
    ) external onlyAdmin {

        require(
            tokenAddresses.length == tokenIds.length &&
                tokenIds.length == starsPrices.length &&
                starsPrices.length == ethPrices.length &&
                ethPrices.length == areStarsListings.length &&
                areStarsListings.length == areEthListings.length,
            "Incorrect input lengths"
        );
        for (uint256 i = 0; i < tokenAddresses.length; i++) {
            createListing(
                tokenAddresses[i],
                tokenIds[i],
                1,
                starsPrices[i],
                ethPrices[i],
                areStarsListings[i],
                areEthListings[i]
            );
        }
    }

    function cancelListing(uint256 listingId)
        public
        sellerOrAdmin(listings[listingId].seller)
        nonReentrant()
    {

        require(listingIds.contains(listingId), "Listing does not exist");
        Listing storage listing = listings[listingId];

        listingIds.remove(listingId);

        IERC721 token = IERC721(listing.tokenAddress);
        token.safeTransferFrom(address(this), listing.seller, listing.tokenId);
        emit ListingCancelled(listingId);
    }

    function batchCancelListing(uint256[] calldata _listingIds)
        external
        onlyAdmin
    {

        for (uint256 i = 0; i < _listingIds.length; i++) {
            cancelListing(_listingIds[i]);
        }
    }

    function changeListingPrice(
        uint256 listingId,
        uint256 newPrice,
        bool isStarsPrice
    ) external sellerOrAdmin(listings[listingId].seller) {

        require(listingIds.contains(listingId), "Listing does not exist.");

        require(newPrice != 0, "Price cannot be 0");
        if (isStarsPrice) {
            listings[listingId].starsPrice = newPrice;
        } else {
            listings[listingId].ethPrice = newPrice;
        }

        emit ListingPriceChanged(listingId, newPrice, isStarsPrice);
    }

    function buyTokens(
        uint256 listingId,
        uint256 amount,
        uint256 expectedPrice,
        bool isStarsPurchase
    ) external payable nonReentrant() {

        require(listingIds.contains(listingId), "Listing does not exist.");

        Listing storage listing = listings[listingId];

        if (isStarsPurchase) {
            require(listing.isStarsListing, "Listing does not accept STARS");
            uint256 fullAmount = listing.starsPrice;
            require(fullAmount == expectedPrice, "Incorrect expected price");

            uint256 fee = (fullAmount * starsFeeBasisPoint) / 10000;
            uint256 commission =
                (fullAmount *
                    commissions[listing.tokenAddress].commissionBasisPoint) /
                    10000;

            if (fee != 0) {
                stars.safeTransferFrom(msg.sender, address(this), fee);
            }

            if (commissions[listing.tokenAddress].artistAddress != address(0)) {
                stars.safeTransferFrom(
                    msg.sender,
                    commissions[listing.tokenAddress].artistAddress,
                    commission
                );
            }

            stars.safeTransferFrom(
                msg.sender,
                listing.seller,
                fullAmount - fee - commission
            );

            if (starsCashBackBasisPoint != 0) {
                uint256 totalStarsCashBack =
                    (fullAmount * starsCashBackBasisPoint) / 10000;

                if (starsAvailableForCashBack >= totalStarsCashBack) {
                    starsAvailableForCashBack -= totalStarsCashBack;
                    stars.safeTransfer(msg.sender, totalStarsCashBack);
                }
            }

            adminStars += fee;
        } else {
            require(listing.isEthListing, "Listing does not accept ETH");
            uint256 fullAmount = listing.ethPrice;
            require(fullAmount == expectedPrice, "Incorrect expected price");

            uint256 fee = (fullAmount * ethFeeBasisPoint) / 10000;
            uint256 commission =
                (fullAmount *
                    commissions[listing.tokenAddress].commissionBasisPoint) /
                    10000;

            require(msg.value == fullAmount, "Incorrect transaction value");

            (bool success, ) =
                listing.seller.call{value: fullAmount - fee - commission}("");
            require(success, "Payment failure");

            if (commissions[listing.tokenAddress].artistAddress != address(0)) {
                (success, ) = commissions[listing.tokenAddress]
                    .artistAddress
                    .call{value: commission}("");

                require(success, "Payment failure");
            }

            adminEth += fee;
        }

        listingIds.remove(listingId);

        IERC721 token = IERC721(listing.tokenAddress);
        token.safeTransferFrom(address(this), msg.sender, listing.tokenId);

        emit SaleMade(msg.sender, listingId, 1, isStarsPurchase);
    }

    function createAuction(
        address tokenAddress,
        uint256 tokenId,
        uint256 tokenAmount,
        uint256 startingPrice,
        uint256 startTime,
        uint256 endTime,
        uint256 reservePrice,
        bool isStarsAuction
    ) public nonReentrant() {

        require(startTime < endTime, "End time must be after start time");
        require(
            startTime > block.timestamp,
            "Auction must start in the future"
        );
        require(
            mogulNFTs.contains(tokenAddress),
            "Only Mogul NFTs can be listed"
        );
        if (isStarsAuction) {
            require(starsAllowed, "STARS auctions are not allowed");
        } else {
            require(ethAllowed, "ETH auctions are not allowed.");
        }

        IERC721 token = IERC721(tokenAddress);
        token.safeTransferFrom(msg.sender, address(this), tokenId);

        uint256 auctionId = generateAuctionId();
        auctions[auctionId] = Auction(
            payable(msg.sender),
            tokenAddress,
            tokenId,
            startingPrice,
            startTime,
            endTime,
            reservePrice,
            isStarsAuction,
            Bid(payable(msg.sender), 0)
        );
        auctionIds.add(auctionId);
        emit AuctionCreated(
            auctionId,
            payable(msg.sender),
            tokenAddress,
            tokenId,
            1,
            startingPrice,
            startTime,
            endTime,
            reservePrice,
            isStarsAuction
        );
    }

    function batchCreateAuctions(
        address[] calldata tokenAddresses,
        uint256[] calldata tokenIds,
        uint256[] calldata startingPrices,
        uint256[] memory startTimes,
        uint256[] memory endTimes,
        uint256[] memory reservePrices,
        bool[] memory areStarsAuctions
    ) external onlyAdmin {

        require(
            tokenAddresses.length == tokenIds.length &&
                tokenIds.length == startingPrices.length &&
                startingPrices.length == startTimes.length &&
                startTimes.length == endTimes.length &&
                endTimes.length == reservePrices.length &&
                reservePrices.length == areStarsAuctions.length,
            "Incorrect input lengths"
        );
        for (uint256 i = 0; i < tokenAddresses.length; i++) {
            createAuction(
                tokenAddresses[i],
                tokenIds[i],
                1,
                startingPrices[i],
                startTimes[i],
                endTimes[i],
                reservePrices[i],
                areStarsAuctions[i]
            );
        }
    }

    function placeBid(uint256 auctionId, uint256 amount)
        external
        payable
        nonReentrant()
    {

        require(auctionIds.contains(auctionId), "Auction does not exist.");

        Auction storage auction = auctions[auctionId];
        require(
            block.timestamp >= auction.startTime,
            "Auction has not started yet"
        );

        require(block.timestamp <= auction.endTime, "Auction has ended");

        require(
            amount > auction.highestBid.amount,
            "Bid is lower than highest bid"
        );

        require(
            amount > auction.startingPrice,
            "Bid must be higher than starting price"
        );

        if (auction.isStarsAuction) {
            stars.safeTransferFrom(msg.sender, address(this), amount);
            stars.safeTransfer(
                auction.highestBid.bidder,
                auction.highestBid.amount
            );
            auction.highestBid = Bid(payable(msg.sender), amount);
        } else {
            require(amount == msg.value, "Amount does not match message value");
            (bool success, ) =
                auction.highestBid.bidder.call{
                    value: auction.highestBid.amount
                }("");
            require(success, "Payment failure");
            auction.highestBid = Bid(payable(msg.sender), amount);
        }

        emit BidPlaced(msg.sender, auctionId, amount, auction.isStarsAuction);
    }

    function claimAuction(uint256 auctionId) public nonReentrant() {

        require(auctionIds.contains(auctionId), "Auction does not exist");
        Auction memory auction = auctions[auctionId];
        require(block.timestamp >= auction.endTime, "Auction is ongoing");

        if (msg.sender != auction.seller && !hasRole(ROLE_ADMIN, msg.sender)) {
            require(
                auction.highestBid.amount >= auction.reservePrice,
                "Highest bid did not meet the reserve price."
            );
        }

        address winner;
        uint256 fee;
        if (auction.isStarsAuction) {
            fee = (auction.highestBid.amount * starsFeeBasisPoint) / 10000;
        } else {
            fee = (auction.highestBid.amount * ethFeeBasisPoint) / 10000;
        }
        uint256 commission =
            (auction.highestBid.amount *
                commissions[auction.tokenAddress].commissionBasisPoint) / 10000;

        winner = auction.highestBid.bidder;
        if (auction.isStarsAuction) {
            stars.safeTransfer(
                auction.seller,
                auction.highestBid.amount - fee - commission
            );

            if (commissions[auction.tokenAddress].artistAddress != address(0)) {
                stars.safeTransfer(
                    commissions[auction.tokenAddress].artistAddress,
                    commission
                );
            }

            if (starsCashBackBasisPoint != 0) {
                uint256 totalStarsCashBack =
                    (auction.highestBid.amount * starsCashBackBasisPoint) /
                        10000;

                if (starsAvailableForCashBack >= totalStarsCashBack) {
                    starsAvailableForCashBack -= totalStarsCashBack;
                    stars.safeTransfer(
                        auction.highestBid.bidder,
                        totalStarsCashBack
                    );
                }
            }

            adminStars += fee;
        } else {
            (bool success, ) =
                auction.seller.call{
                    value: auction.highestBid.amount - fee - commission
                }("");

            require(success, "Payment failure");

            if (commissions[auction.tokenAddress].artistAddress != address(0)) {
                (success, ) = commissions[auction.tokenAddress]
                    .artistAddress
                    .call{value: commission}("");

                require(success, "Payment failure");
            }

            adminEth += fee;
        }

        IERC721(auction.tokenAddress).safeTransferFrom(
            address(this),
            winner,
            auction.tokenId
        );
        auctionIds.remove(auctionId);
        emit AuctionClaimed(winner, auctionId);
    }

    function batchClaimAuction(uint256[] calldata _auctionIds)
        external
        onlyAdmin
    {

        for (uint256 i = 0; i < _auctionIds.length; i++) {
            claimAuction(_auctionIds[i]);
        }
    }

    function cancelAuction(uint256 auctionId)
        public
        nonReentrant()
        sellerOrAdmin(auctions[auctionId].seller)
    {

        require(auctionIds.contains(auctionId), "Auction does not exist");
        Auction memory auction = auctions[auctionId];

        require(
            block.timestamp <= auction.endTime ||
                auction.highestBid.amount < auction.reservePrice,
            "Cannot cancel auction after it has ended unless the highest bid did not meet the reserve price."
        );

        IERC721(auction.tokenAddress).safeTransferFrom(
            address(this),
            auction.seller,
            auction.tokenId
        );

        if (auction.isStarsAuction) {
            stars.safeTransfer(
                auction.highestBid.bidder,
                auction.highestBid.amount
            );
        } else {
            (bool success, ) =
                auction.highestBid.bidder.call{
                    value: auction.highestBid.amount
                }("");
            require(success, "Payment failure");
        }

        auctionIds.remove(auctionId);
        emit AuctionCancelled(auctionId);
    }

    function batchCancelAuction(uint256[] calldata _auctionIds)
        external
        onlyAdmin
    {

        for (uint256 i = 0; i < _auctionIds.length; i++) {
            cancelAuction(_auctionIds[i]);
        }
    }

    function changeReservePrice(uint256 auctionId, uint256 newReservePrice)
        external
        nonReentrant()
        sellerOrAdmin(auctions[auctionId].seller)
    {

        require(auctionIds.contains(auctionId), "Auction does not exist");
        auctions[auctionId].reservePrice = newReservePrice;

        emit AuctionReservePriceChanged(auctionId, newReservePrice);
    }

    function generateListingId() internal returns (uint256) {

        return nextListingId++;
    }

    function generateAuctionId() internal returns (uint256) {

        return nextAuctionId++;
    }

    function withdrawETH() external onlyAdmin {

        (bool success, ) = treasuryWallet.call{value: adminEth}("");
        require(success, "Payment failure");
        adminEth = 0;
    }

    function withdrawStars() external onlyAdmin {

        stars.safeTransfer(treasuryWallet, adminStars);
        adminStars = 0;
    }

    function addMogulNFTAddress(address _mogulNFTAddress) external onlyAdmin {

        mogulNFTs.add(_mogulNFTAddress);
    }

    function removeMogulNFTAddress(address _mogulNFTAddress)
        external
        onlyAdmin
    {

        mogulNFTs.remove(_mogulNFTAddress);
    }

    function setStarsFee(uint256 _feeBasisPoint) external onlyAdmin {

        require(
            _feeBasisPoint + highestCommissionBasisPoint < 10000,
            "Fee plus commission must be less than 100%"
        );
        starsFeeBasisPoint = _feeBasisPoint;
        emit StarsFeeBasisPointSet(_feeBasisPoint);
    }

    function setEthFee(uint256 _feeBasisPoint) external onlyAdmin {

        require(
            _feeBasisPoint + highestCommissionBasisPoint < 10000,
            "Fee plus commission must be less than 100%"
        );
        ethFeeBasisPoint = _feeBasisPoint;
        emit EthFeeBasisPointSet(_feeBasisPoint);
    }

    function setStarsCashBack(uint256 _starsCashBackBasisPoint)
        external
        onlyAdmin
    {

        starsCashBackBasisPoint = _starsCashBackBasisPoint;
    }

    function setCommission(
        address NFTAddress,
        address payable artistAddress,
        uint256 commissionBasisPoint
    ) external onlyAdmin {

        if (commissionBasisPoint > highestCommissionBasisPoint) {
            require(
                commissionBasisPoint + starsFeeBasisPoint < 10000 &&
                    commissionBasisPoint + ethFeeBasisPoint < 10000,
                "Fee plus commission must be less than 100%"
            );

            highestCommissionBasisPoint = commissionBasisPoint;
        }

        commissions[NFTAddress] = TokenCommissionInfo(
            artistAddress,
            commissionBasisPoint
        );

        emit TokenCommissionAdded(
            NFTAddress,
            artistAddress,
            commissionBasisPoint
        );
    }

    function setStarsAllowed(bool _starsAllowed) external onlyAdmin {

        starsAllowed = _starsAllowed;
    }

    function setEthAllowed(bool _ethAllowed) external onlyAdmin {

        ethAllowed = _ethAllowed;
    }

    function depositStarsForCashBack(uint256 amount) public {

        stars.safeTransferFrom(msg.sender, address(this), amount);
        starsAvailableForCashBack += amount;
    }

    function withdrawStarsForCashBack(uint256 amount)
        external
        onlyAdmin
        nonReentrant()
    {

        require(
            amount <= starsAvailableForCashBack,
            "Withdraw amount exceeds available balance"
        );
        starsAvailableForCashBack -= amount;
        stars.safeTransfer(treasuryWallet, amount);
    }
}