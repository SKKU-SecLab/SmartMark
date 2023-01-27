
pragma solidity >=0.6.0 <0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}// MIT

pragma solidity >=0.6.0 <0.8.0;

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}// MIT

pragma solidity >=0.6.0 <0.8.0;

library SafeMath {

    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b > a) return (false, 0);
        return (true, a - b);
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b == 0) return (false, 0);
        return (true, a / b);
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b == 0) return (false, 0);
        return (true, a % b);
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b <= a, "SafeMath: subtraction overflow");
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0, "SafeMath: division by zero");
        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0, "SafeMath: modulo by zero");
        return a % b;
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b <= a, errorMessage);
        return a - b;
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        return a / b;
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        return a % b;
    }
}// MIT

pragma solidity >=0.6.2 <0.8.0;

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

pragma solidity >=0.6.0 <0.8.0;

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
            set._indexes[lastvalue] = toDeleteIndex + 1; // All indexes are 1-based

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

pragma solidity >=0.6.0 <0.8.0;

abstract contract ReentrancyGuard {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor () internal {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
    }
}// MIT

pragma solidity >=0.6.0 <0.8.0;

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}// MIT

pragma solidity >=0.6.2 <0.8.0;


interface IERC721 is IERC165 {

    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    function balanceOf(address owner) external view returns (uint256 balance);


    function ownerOf(uint256 tokenId) external view returns (address owner);


    function safeTransferFrom(address from, address to, uint256 tokenId) external;


    function transferFrom(address from, address to, uint256 tokenId) external;


    function approve(address to, uint256 tokenId) external;


    function getApproved(uint256 tokenId) external view returns (address operator);


    function setApprovalForAll(address operator, bool _approved) external;


    function isApprovedForAll(address owner, address operator) external view returns (bool);


    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;

}// MIT

pragma solidity >=0.6.0 <0.8.0;

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

pragma solidity >=0.6.0 <0.8.0;


library SafeERC20 {

    using SafeMath for uint256;
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

        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {


        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}// AGPL-3.0-or-later

pragma solidity =0.6.12;
pragma experimental ABIEncoderV2;

interface INFTKEYMarketPlaceV1 {

    struct Bid {
        uint256 tokenId;
        uint256 bidPrice;
        address bidder;
        uint256 expireTimestamp;
    }

    struct Listing {
        uint256 tokenId;
        uint256 listingPrice;
        address seller;
        uint256 expireTimestamp;
    }

    event TokenListed(uint256 indexed tokenId, address indexed fromAddress, uint256 minValue);
    event TokenDelisted(uint256 indexed tokenId, address indexed fromAddress);
    event TokenBidEntered(uint256 indexed tokenId, address indexed fromAddress, uint256 value);
    event TokenBidWithdrawn(uint256 indexed tokenId, address indexed fromAddress, uint256 value);
    event TokenBought(
        uint256 indexed tokenId,
        address indexed fromAddress,
        address indexed toAddress,
        uint256 total,
        uint256 value,
        uint256 fees
    );
    event TokenBidAccepted(
        uint256 indexed tokenId,
        address indexed owner,
        address indexed bidder,
        uint256 total,
        uint256 value,
        uint256 fees
    );

    function tokenAddress() external view returns (address);


    function paymentTokenAddress() external view returns (address);


    function getTokenListing(uint256 tokenId) external view returns (Listing memory);


    function getTokenListings(uint256 from, uint256 size) external view returns (Listing[] memory);


    function getAllTokenListings() external view returns (Listing[] memory);


    function getBidderTokenBid(uint256 tokenId, address bidder) external view returns (Bid memory);


    function getTokenBids(uint256 tokenId) external view returns (Bid[] memory);


    function getTokenHighestBid(uint256 tokenId) external view returns (Bid memory);


    function getTokenHighestBids(uint256 from, uint256 size) external view returns (Bid[] memory);


    function getAllTokenHighestBids() external view returns (Bid[] memory);


    function listToken(
        uint256 tokenId,
        uint256 value,
        uint256 expireTimestamp
    ) external;


    function delistToken(uint256 tokenId) external;


    function buyToken(uint256 tokenId) external payable;


    function enterBidForToken(
        uint256 tokenId,
        uint256 bidPrice,
        uint256 expireTimestamp
    ) external;


    function withdrawBidForToken(uint256 tokenId) external;


    function acceptBidForToken(uint256 tokenId, address bidder) external;


    function getInvalidListingCount() external view returns (uint256);


    function getInvalidBidCount() external view returns (uint256);


    function cleanAllInvalidListings() external;


    function cleanAllInvalidBids() external;


    function erc721Name() external view returns (string memory);


    function isListingAndBidEnabled() external view returns (bool);


    function actionTimeOutRangeMin() external view returns (uint256);


    function actionTimeOutRangeMax() external view returns (uint256);


    function serviceFee() external view returns (uint8, uint8);

}// AGPL-3.0-or-later

pragma solidity =0.6.12;


contract NFTKEYMarketPlaceV1_1 is INFTKEYMarketPlaceV1, Ownable, ReentrancyGuard {

    using SafeMath for uint256;
    using Address for address;
    using EnumerableSet for EnumerableSet.UintSet;
    using EnumerableSet for EnumerableSet.AddressSet;

    struct TokenBid {
        EnumerableSet.AddressSet bidders;
        mapping(address => Bid) bids;
    }

    constructor(
        string memory erc721Name_,
        address _erc721Address,
        address _paymentTokenAddress
    ) public {
        _erc721Name = erc721Name_;
        _erc721 = IERC721(_erc721Address);
        _paymentToken = IERC20(_paymentTokenAddress);
    }

    string private _erc721Name;
    IERC721 private immutable _erc721;
    IERC20 private immutable _paymentToken;

    bool private _isListingAndBidEnabled = true;
    uint8 private _feeFraction = 1;
    uint8 private _feeBase = 100;
    uint256 private _actionTimeOutRangeMin = 86400; // 24 hours
    uint256 private _actionTimeOutRangeMax = 31536000; // One year - This can extend by owner is contract is working smoothly

    mapping(uint256 => Listing) private _tokenListings;
    EnumerableSet.UintSet private _tokenIdWithListing;

    mapping(uint256 => TokenBid) private _tokenBids;
    EnumerableSet.UintSet private _tokenIdWithBid;

    address public partnerAddress;
    uint8 public partnerSharePercentage = 0;
    bool public hasSharePercentageProposal;
    uint8 public partnerSharePercentageProposal;

    EnumerableSet.AddressSet private _emptyBidders; // Help initiate TokenBid struct
    uint256[] private _tempTokenIdStorage; // Storage to assist cleaning
    address[] private _tempBidderStorage; // Storage to assist cleaning bids

    modifier onlyMarketplaceOpen() {

        require(_isListingAndBidEnabled, "Listing and bid are not enabled");
        _;
    }

    modifier onlyAllowedExpireTimestamp(uint256 expireTimestamp) {

        require(
            expireTimestamp.sub(block.timestamp) >= _actionTimeOutRangeMin,
            "Please enter a longer period of time"
        );
        require(
            expireTimestamp.sub(block.timestamp) <= _actionTimeOutRangeMax,
            "Please enter a shorter period of time"
        );
        _;
    }

    function _isTokenOwner(uint256 tokenId, address account) private view returns (bool) {

        try _erc721.ownerOf(tokenId) returns (address tokenOwner) {
            return tokenOwner == account;
        } catch {
            return false;
        }
    }

    function _isTokenApproved(uint256 tokenId) private view returns (bool) {

        try _erc721.getApproved(tokenId) returns (address tokenOperator) {
            return tokenOperator == address(this);
        } catch {
            return false;
        }
    }

    function _isAllTokenApproved(address owner) private view returns (bool) {

        return _erc721.isApprovedForAll(owner, address(this));
    }

    function tokenAddress() external view override returns (address) {

        return address(_erc721);
    }

    function paymentTokenAddress() external view override returns (address) {

        return address(_paymentToken);
    }

    function _isListingValid(Listing memory listing) private view returns (bool) {

        if (
            _isTokenOwner(listing.tokenId, listing.seller) &&
            (_isTokenApproved(listing.tokenId) || _isAllTokenApproved(listing.seller)) &&
            listing.listingPrice > 0 &&
            listing.expireTimestamp > block.timestamp
        ) {
            return true;
        }
    }

    function getTokenListing(uint256 tokenId) public view override returns (Listing memory) {

        Listing memory listing = _tokenListings[tokenId];
        if (_isListingValid(listing)) {
            return listing;
        }
    }

    function getTokenListings(uint256 from, uint256 size)
        public
        view
        override
        returns (Listing[] memory)
    {

        if (from < _tokenIdWithListing.length() && size > 0) {
            uint256 querySize = size;
            if ((from + size) > _tokenIdWithListing.length()) {
                querySize = _tokenIdWithListing.length() - from;
            }
            Listing[] memory listings = new Listing[](querySize);
            for (uint256 i = 0; i < querySize; i++) {
                Listing memory listing = _tokenListings[_tokenIdWithListing.at(i + from)];
                if (_isListingValid(listing)) {
                    listings[i] = listing;
                }
            }
            return listings;
        }
    }

    function getAllTokenListings() external view override returns (Listing[] memory) {

        return getTokenListings(0, _tokenIdWithListing.length());
    }

    function _isBidValid(Bid memory bid) private view returns (bool) {

        if (
            !_isTokenOwner(bid.tokenId, bid.bidder) &&
            _paymentToken.allowance(bid.bidder, address(this)) >= bid.bidPrice &&
            bid.bidPrice > 0 &&
            bid.expireTimestamp > block.timestamp
        ) {
            return true;
        }
    }

    function getBidderTokenBid(uint256 tokenId, address bidder)
        public
        view
        override
        returns (Bid memory)
    {

        Bid memory bid = _tokenBids[tokenId].bids[bidder];
        if (_isBidValid(bid)) {
            return bid;
        }
    }

    function getTokenBids(uint256 tokenId) external view override returns (Bid[] memory) {

        Bid[] memory bids = new Bid[](_tokenBids[tokenId].bidders.length());
        for (uint256 i; i < _tokenBids[tokenId].bidders.length(); i++) {
            address bidder = _tokenBids[tokenId].bidders.at(i);
            Bid memory bid = _tokenBids[tokenId].bids[bidder];
            if (_isBidValid(bid)) {
                bids[i] = bid;
            }
        }
        return bids;
    }

    function getTokenHighestBid(uint256 tokenId) public view override returns (Bid memory) {

        Bid memory highestBid = Bid(tokenId, 0, address(0), 0);
        for (uint256 i; i < _tokenBids[tokenId].bidders.length(); i++) {
            address bidder = _tokenBids[tokenId].bidders.at(i);
            Bid memory bid = _tokenBids[tokenId].bids[bidder];
            if (_isBidValid(bid) && bid.bidPrice > highestBid.bidPrice) {
                highestBid = bid;
            }
        }
        return highestBid;
    }

    function getTokenHighestBids(uint256 from, uint256 size)
        public
        view
        override
        returns (Bid[] memory)
    {

        if (from < _tokenIdWithBid.length() && size > 0) {
            uint256 querySize = size;
            if ((from + size) > _tokenIdWithBid.length()) {
                querySize = _tokenIdWithBid.length() - from;
            }
            Bid[] memory highestBids = new Bid[](querySize);
            for (uint256 i = 0; i < querySize; i++) {
                highestBids[i] = getTokenHighestBid(_tokenIdWithBid.at(i + from));
            }
            return highestBids;
        }
    }

    function getAllTokenHighestBids() external view override returns (Bid[] memory) {

        return getTokenHighestBids(0, _tokenIdWithBid.length());
    }

    function _delistToken(uint256 tokenId) private {

        if (_tokenIdWithListing.contains(tokenId)) {
            delete _tokenListings[tokenId];
            _tokenIdWithListing.remove(tokenId);
        }
    }

    function _removeBidOfBidder(uint256 tokenId, address bidder) private {

        if (_tokenBids[tokenId].bidders.contains(bidder)) {
            delete _tokenBids[tokenId].bids[bidder];
            _tokenBids[tokenId].bidders.remove(bidder);

            if (_tokenBids[tokenId].bidders.length() == 0) {
                _tokenIdWithBid.remove(tokenId);
            }
        }
    }

    function listToken(
        uint256 tokenId,
        uint256 value,
        uint256 expireTimestamp
    ) external override onlyMarketplaceOpen onlyAllowedExpireTimestamp(expireTimestamp) {

        require(value > 0, "Please list for more than 0 or use the transfer function");
        require(_isTokenOwner(tokenId, msg.sender), "Only token owner can list token");
        require(
            _isTokenApproved(tokenId) || _isAllTokenApproved(msg.sender),
            "This token is not allowed to transfer by this contract"
        );

        _tokenListings[tokenId] = Listing(tokenId, value, msg.sender, expireTimestamp);
        _tokenIdWithListing.add(tokenId);

        emit TokenListed(tokenId, msg.sender, value);
    }

    function delistToken(uint256 tokenId) external override {

        require(_tokenListings[tokenId].seller == msg.sender, "Only token seller can delist token");
        emit TokenDelisted(tokenId, _tokenListings[tokenId].seller);
        _delistToken(tokenId);
    }

    function buyToken(uint256 tokenId) external payable override nonReentrant {

        Listing memory listing = getTokenListing(tokenId); // Get valid listing
        require(listing.seller != address(0), "Token is not for sale"); // Listing not valid
        require(!_isTokenOwner(tokenId, msg.sender), "Token owner can't buy their own token");

        uint256 fees = listing.listingPrice.mul(_feeFraction).div(_feeBase);
        require(
            msg.value >= listing.listingPrice + fees,
            "The value send is below sale price plus fees"
        );

        uint256 valueWithoutFees = msg.value.sub(fees);
        uint256 partnerFeesShare = fees.mul(partnerSharePercentage).div(100);
        Address.sendValue(payable(listing.seller), valueWithoutFees);
        Address.sendValue(payable(owner()), fees.sub(partnerFeesShare));
        if (partnerAddress != address(0) && partnerFeesShare > 0) {
            Address.sendValue(payable(partnerAddress), partnerFeesShare);
        }

        emit TokenBought(tokenId, listing.seller, msg.sender, msg.value, valueWithoutFees, fees);
        _erc721.safeTransferFrom(listing.seller, msg.sender, tokenId);

        _delistToken(tokenId);
        _removeBidOfBidder(tokenId, msg.sender);
    }

    function enterBidForToken(
        uint256 tokenId,
        uint256 bidPrice,
        uint256 expireTimestamp
    ) external override onlyMarketplaceOpen onlyAllowedExpireTimestamp(expireTimestamp) {

        require(bidPrice > 0, "Please bid for more than 0");
        require(!_isTokenOwner(tokenId, msg.sender), "This Token belongs to this address");
        require(
            _paymentToken.allowance(msg.sender, address(this)) >= bidPrice,
            "Need to have enough token holding to bid on this token"
        );

        Bid memory bid = Bid(tokenId, bidPrice, msg.sender, expireTimestamp);

        if (!_tokenIdWithBid.contains(tokenId)) {
            _tokenIdWithBid.add(tokenId);
            _tokenBids[tokenId] = TokenBid(_emptyBidders);
        }

        _tokenBids[tokenId].bidders.add(msg.sender);
        _tokenBids[tokenId].bids[msg.sender] = bid;

        emit TokenBidEntered(tokenId, msg.sender, bidPrice);
    }

    function withdrawBidForToken(uint256 tokenId) external override {

        Bid memory bid = _tokenBids[tokenId].bids[msg.sender];
        require(bid.bidder == msg.sender, "This address doesn't have bid on this token");

        emit TokenBidWithdrawn(tokenId, bid.bidder, bid.bidPrice);
        _removeBidOfBidder(tokenId, msg.sender);
    }

    function acceptBidForToken(uint256 tokenId, address bidder) external override nonReentrant {

        require(_isTokenOwner(tokenId, msg.sender), "Only token owner can accept bid of token");
        require(
            _isTokenApproved(tokenId) || _isAllTokenApproved(msg.sender),
            "The token is not approved to transfer by the contract"
        );

        Bid memory existingBid = getBidderTokenBid(tokenId, bidder);
        require(
            existingBid.bidPrice > 0 && existingBid.bidder == bidder,
            "This token doesn't have a matching bid"
        );

        uint256 fees = existingBid.bidPrice.mul(_feeFraction).div(_feeBase + _feeFraction);
        uint256 tokenValue = existingBid.bidPrice.sub(fees);
        uint256 partnerFeesShare = fees.mul(partnerSharePercentage).div(100);

        SafeERC20.safeTransferFrom(_paymentToken, existingBid.bidder, msg.sender, tokenValue);
        SafeERC20.safeTransferFrom(
            _paymentToken,
            existingBid.bidder,
            owner(),
            fees.sub(partnerFeesShare)
        );
        if (partnerAddress != address(0) && partnerFeesShare > 0) {
            SafeERC20.safeTransferFrom(
                _paymentToken,
                existingBid.bidder,
                partnerAddress,
                partnerFeesShare
            );
        }

        _erc721.safeTransferFrom(msg.sender, existingBid.bidder, tokenId);

        emit TokenBidAccepted(
            tokenId,
            msg.sender,
            existingBid.bidder,
            existingBid.bidPrice,
            tokenValue,
            fees
        );

        _delistToken(tokenId);
        _removeBidOfBidder(tokenId, existingBid.bidder);
    }

    function getInvalidListingCount() external view override returns (uint256) {

        uint256 count = 0;
        for (uint256 i = 0; i < _tokenIdWithListing.length(); i++) {
            if (!_isListingValid(_tokenListings[_tokenIdWithListing.at(i)])) {
                count = count.add(1);
            }
        }
        return count;
    }

    function _getInvalidBidOfTokenCount(uint256 tokenId) private view returns (uint256) {

        uint256 count = 0;
        for (uint256 i = 0; i < _tokenBids[tokenId].bidders.length(); i++) {
            address bidder = _tokenBids[tokenId].bidders.at(i);
            Bid memory bid = _tokenBids[tokenId].bids[bidder];
            if (!_isBidValid(bid)) {
                count = count.add(1);
            }
        }
        return count;
    }

    function getInvalidBidCount() external view override returns (uint256) {

        uint256 count = 0;
        for (uint256 i = 0; i < _tokenIdWithBid.length(); i++) {
            count = count.add(_getInvalidBidOfTokenCount(_tokenIdWithBid.at(i)));
        }
        return count;
    }

    function cleanAllInvalidListings() external override {

        for (uint256 i = 0; i < _tokenIdWithListing.length(); i++) {
            uint256 tokenId = _tokenIdWithListing.at(i);
            if (!_isListingValid(_tokenListings[tokenId])) {
                _tempTokenIdStorage.push(tokenId);
            }
        }
        for (uint256 i = 0; i < _tempTokenIdStorage.length; i++) {
            _delistToken(_tempTokenIdStorage[i]);
        }
        delete _tempTokenIdStorage;
    }

    function _cleanInvalidBidsOfToken(uint256 tokenId) private {

        for (uint256 i = 0; i < _tokenBids[tokenId].bidders.length(); i++) {
            address bidder = _tokenBids[tokenId].bidders.at(i);
            Bid memory bid = _tokenBids[tokenId].bids[bidder];
            if (!_isBidValid(bid)) {
                _tempBidderStorage.push(_tokenBids[tokenId].bidders.at(i));
            }
        }
        for (uint256 i = 0; i < _tempBidderStorage.length; i++) {
            address bidder = _tempBidderStorage[i];
            _removeBidOfBidder(tokenId, bidder);
        }
        delete _tempBidderStorage;
    }

    function cleanAllInvalidBids() external override {

        for (uint256 i = 0; i < _tokenIdWithBid.length(); i++) {
            uint256 tokenId = _tokenIdWithBid.at(i);
            uint256 invalidCount = _getInvalidBidOfTokenCount(tokenId);
            if (invalidCount > 0) {
                _tempTokenIdStorage.push(tokenId);
            }
        }
        for (uint256 i = 0; i < _tempTokenIdStorage.length; i++) {
            _cleanInvalidBidsOfToken(_tempTokenIdStorage[i]);
        }
        delete _tempTokenIdStorage;
    }

    function erc721Name() external view override returns (string memory) {

        return _erc721Name;
    }

    function isListingAndBidEnabled() external view override returns (bool) {

        return _isListingAndBidEnabled;
    }

    function changeMarketplaceStatus(bool enabled) external onlyOwner {

        _isListingAndBidEnabled = enabled;
    }

    function actionTimeOutRangeMin() external view override returns (uint256) {

        return _actionTimeOutRangeMin;
    }

    function actionTimeOutRangeMax() external view override returns (uint256) {

        return _actionTimeOutRangeMax;
    }

    function changeMinActionTimeLimit(uint256 timeInSec) external onlyOwner {

        _actionTimeOutRangeMin = timeInSec;
    }

    function changeMaxActionTimeLimit(uint256 timeInSec) external onlyOwner {

        _actionTimeOutRangeMax = timeInSec;
    }

    function serviceFee() external view override returns (uint8, uint8) {

        return (_feeFraction, _feeBase);
    }

    function changeSeriveFee(uint8 feeFraction_, uint8 feeBase_) external onlyOwner {

        require(feeFraction_ <= feeBase_, "Fee fraction exceeded base.");
        uint256 percentage = (feeFraction_ * 1000) / feeBase_;
        require(percentage <= 25, "Attempt to set percentage higher than 2.5%.");

        _feeFraction = feeFraction_;
        _feeBase = feeBase_;
    }

    function setPartnerAddressAndProfitShare(address _partnerAddress, uint8 _partnerSharePercentage)
        external
        onlyOwner
    {

        require(partnerAddress == address(0), "Owner can't change partner address once it's set");
        require(_partnerAddress != address(0), "Can't set to address 0x0");
        require(
            _partnerSharePercentage > 0 && _partnerSharePercentage <= 100,
            "Allowed percentage range is 1 to 100"
        );

        partnerAddress = _partnerAddress;
        partnerSharePercentage = _partnerSharePercentage;
    }

    function changePartnerAddress(address _partnerAddress) external {

        require(msg.sender == partnerAddress, "Only partner can change partner address");

        partnerAddress = _partnerAddress;

        if (_partnerAddress == address(0)) {
            partnerSharePercentage = 0;
        }
    }

    function proposePartnerShareChange(uint8 _partnerSharePercentage) external {

        require(msg.sender == partnerAddress, "Only partner can propose share change");
        require(_partnerSharePercentage <= 100, "Allowed percentage range is 0 to 100");
        require(
            _partnerSharePercentage != partnerSharePercentage,
            "Attempting to set propose same value again"
        );

        hasSharePercentageProposal = true;
        partnerSharePercentageProposal = _partnerSharePercentage;
    }

    function acceptPartnerShareChange() external onlyOwner {

        require(hasSharePercentageProposal, "There is no change share proposal");
        partnerSharePercentage = partnerSharePercentageProposal;
        hasSharePercentageProposal = false;
        partnerSharePercentageProposal = 0;
    }

    function rejectPartnerShareChange() external onlyOwner {

        require(hasSharePercentageProposal, "There is no change share proposal");
        hasSharePercentageProposal = false;
        partnerSharePercentageProposal = 0;
    }
}