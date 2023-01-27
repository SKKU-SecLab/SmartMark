
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
}// AGPL-3.0-or-later

pragma solidity =0.8.9;
pragma abicoder v2;


interface INFTKEYMarketplaceV2 {

    struct Listing {
        uint256 tokenId;
        uint256 value;
        address seller;
        uint256 expireTimestamp;
    }

    struct Bid {
        uint256 tokenId;
        uint256 value;
        address bidder;
        uint256 expireTimestamp;
    }

    struct TokenBids {
        EnumerableSet.AddressSet bidders;
        mapping(address => Bid) bids;
    }

    struct ERC721Market {
        EnumerableSet.UintSet tokenIdWithListing;
        mapping(uint256 => Listing) listings;
        EnumerableSet.UintSet tokenIdWithBid;
        mapping(uint256 => TokenBids) bids;
    }

    event TokenListed(
        address indexed erc721Address,
        uint256 indexed tokenId,
        Listing listing
    );
    event TokenDelisted(
        address indexed erc721Address,
        uint256 indexed tokenId,
        Listing listing
    );
    event TokenBidEntered(
        address indexed erc721Address,
        uint256 indexed tokenId,
        Bid bid
    );
    event TokenBidWithdrawn(
        address indexed erc721Address,
        uint256 indexed tokenId,
        Bid bid
    );
    event TokenBought(
        address indexed erc721Address,
        uint256 indexed tokenId,
        address indexed buyer,
        Listing listing,
        uint256 serviceFee,
        uint256 royaltyFee
    );
    event TokenBidAccepted(
        address indexed erc721Address,
        uint256 indexed tokenId,
        address indexed seller,
        Bid bid,
        uint256 serviceFee,
        uint256 royaltyFee
    );

    function listToken(
        address erc721Address,
        uint256 tokenId,
        uint256 value,
        uint256 expireTimestamp
    ) external;


    function delistToken(address erc721Address, uint256 tokenId) external;


    function buyToken(address erc721Address, uint256 tokenId) external payable;


    function enterBidForToken(
        address erc721Address,
        uint256 tokenId,
        uint256 value,
        uint256 expireTimestamp
    ) external;


    function withdrawBidForToken(address erc721Address, uint256 tokenId)
        external;


    function acceptBidForToken(
        address erc721Address,
        uint256 tokenId,
        address bidder,
        uint256 value
    ) external;


    function isTradingEnabled() external view returns (bool);


    function getTokenListing(address erc721Address, uint256 tokenId)
        external
        view
        returns (Listing memory);


    function numTokenListings(address erc721Address)
        external
        view
        returns (uint256);


    function getTokenListings(
        address erc721Address,
        uint256 from,
        uint256 size
    ) external view returns (Listing[] memory);


    function getBidderTokenBid(
        address erc721Address,
        uint256 tokenId,
        address bidder
    ) external view returns (Bid memory);


    function getTokenBids(address erc721Address, uint256 tokenId)
        external
        view
        returns (Bid[] memory);


    function numTokenWithBids(address erc721Address)
        external
        view
        returns (uint256);


    function getTokenHighestBid(address erc721Address, uint256 tokenId)
        external
        view
        returns (Bid memory);


    function getTokenHighestBids(
        address erc721Address,
        uint256 from,
        uint256 size
    ) external view returns (Bid[] memory);


    function getBidderBids(
        address erc721Address,
        address bidder,
        uint256 from,
        uint256 size
    ) external view returns (Bid[] memory);


    function actionTimeOutRangeMin() external view returns (uint256);


    function actionTimeOutRangeMax() external view returns (uint256);


    function paymentToken() external view returns (address);


    function serviceFee() external view returns (uint8);

}// AGPL-3.0-or-later

pragma solidity =0.8.9;

interface INFTKEYMarketplaceRoyalty {

    struct ERC721CollectionRoyalty {
        address recipient;
        uint256 feeFraction;
        address setBy;
    }

    event SetRoyalty(
        address indexed erc721Address,
        address indexed recipient,
        uint256 feeFraction
    );

    function royalty(address erc721Address)
        external
        view
        returns (ERC721CollectionRoyalty memory);


    function setRoyalty(
        address erc721Address,
        address recipient,
        uint256 feeFraction
    ) external;

}// AGPL-3.0-or-later

pragma solidity =0.8.9;


contract NFTKEYMarketplaceRoyalty is INFTKEYMarketplaceRoyalty, Ownable {

    uint256 public defaultRoyaltyFraction = 20; // By the factor of 1000, 2%
    uint256 public royaltyUpperLimit = 80; // By the factor of 1000, 8%

    mapping(address => ERC721CollectionRoyalty) private _collectionRoyalty;

    function _erc721Owner(address erc721Address)
        private
        view
        returns (address)
    {

        try Ownable(erc721Address).owner() returns (address _contractOwner) {
            return _contractOwner;
        } catch {
            return address(0);
        }
    }

    function royalty(address erc721Address)
        public
        view
        override
        returns (ERC721CollectionRoyalty memory)
    {

        if (_collectionRoyalty[erc721Address].setBy != address(0)) {
            return _collectionRoyalty[erc721Address];
        }

        address erc721Owner = _erc721Owner(erc721Address);
        if (erc721Owner != address(0)) {
            return
                ERC721CollectionRoyalty({
                    recipient: erc721Owner,
                    feeFraction: defaultRoyaltyFraction,
                    setBy: address(0)
                });
        }

        return
            ERC721CollectionRoyalty({
                recipient: address(0),
                feeFraction: 0,
                setBy: address(0)
            });
    }

    function setRoyalty(
        address erc721Address,
        address newRecipient,
        uint256 feeFraction
    ) external override {

        require(
            feeFraction <= royaltyUpperLimit,
            "Please set the royalty percentange below allowed range"
        );

        require(
            msg.sender == royalty(erc721Address).recipient,
            "Only ERC721 royalty recipient is allowed to set Royalty"
        );

        _collectionRoyalty[erc721Address] = ERC721CollectionRoyalty({
            recipient: newRecipient,
            feeFraction: feeFraction,
            setBy: msg.sender
        });

        emit SetRoyalty({
            erc721Address: erc721Address,
            recipient: newRecipient,
            feeFraction: feeFraction
        });
    }

    function setRoyaltyForCollection(
        address erc721Address,
        address newRecipient,
        uint256 feeFraction
    ) external onlyOwner {

        require(
            feeFraction <= royaltyUpperLimit,
            "Please set the royalty percentange below allowed range"
        );

        require(
            royalty(erc721Address).setBy == address(0),
            "Collection royalty recipient already set"
        );

        _collectionRoyalty[erc721Address] = ERC721CollectionRoyalty({
            recipient: newRecipient,
            feeFraction: feeFraction,
            setBy: msg.sender
        });

        emit SetRoyalty({
            erc721Address: erc721Address,
            recipient: newRecipient,
            feeFraction: feeFraction
        });
    }

    function updateRoyaltyUpperLimit(uint256 _newUpperLimit)
        external
        onlyOwner
    {

        royaltyUpperLimit = _newUpperLimit;
    }
}// AGPL-3.0-or-later

pragma solidity =0.8.9;


contract NFTKEYMarketplaceV2 is
    INFTKEYMarketplaceV2,
    Ownable,
    NFTKEYMarketplaceRoyalty,
    ReentrancyGuard
{

    using Address for address;
    using EnumerableSet for EnumerableSet.UintSet;
    using EnumerableSet for EnumerableSet.AddressSet;
    using SafeERC20 for IERC20;

    constructor(address _paymentTokenAddress) {
        _paymentToken = IERC20(_paymentTokenAddress);
    }

    IERC20 private immutable _paymentToken;

    bool private _isTradingEnabled = true;
    uint8 private _serviceFeeFraction = 20;
    uint256 private _actionTimeOutRangeMin = 1800; // 30 mins
    uint256 private _actionTimeOutRangeMax = 31536000; // One year - This can extend by owner is contract is working smoothly

    mapping(address => ERC721Market) private _erc721Market;

    modifier onlyTradingOpen() {

        require(_isTradingEnabled, "Listing and bid are not enabled");
        _;
    }

    modifier onlyAllowedExpireTimestamp(uint256 expireTimestamp) {

        require(
            expireTimestamp - block.timestamp >= _actionTimeOutRangeMin,
            "Please enter a longer period of time"
        );
        require(
            expireTimestamp - block.timestamp <= _actionTimeOutRangeMax,
            "Please enter a shorter period of time"
        );
        _;
    }

    function listToken(
        address erc721Address,
        uint256 tokenId,
        uint256 value,
        uint256 expireTimestamp
    )
        external
        override
        onlyTradingOpen
        onlyAllowedExpireTimestamp(expireTimestamp)
    {

        Listing memory listing = Listing({
            tokenId: tokenId,
            value: value,
            seller: msg.sender,
            expireTimestamp: expireTimestamp
        });

        require(
            _isListingValid(erc721Address, listing),
            "Listing is not valid"
        );

        _erc721Market[erc721Address].listings[tokenId] = listing;
        _erc721Market[erc721Address].tokenIdWithListing.add(tokenId);

        emit TokenListed(erc721Address, tokenId, listing);
    }

    function delistToken(address erc721Address, uint256 tokenId)
        external
        override
    {

        require(
            _erc721Market[erc721Address].listings[tokenId].seller == msg.sender,
            "Only token seller can delist token"
        );

        emit TokenDelisted(
            erc721Address,
            tokenId,
            _erc721Market[erc721Address].listings[tokenId]
        );

        _delistToken(erc721Address, tokenId);
    }

    function buyToken(address erc721Address, uint256 tokenId)
        external
        payable
        override
        nonReentrant
    {

        Listing memory listing = _erc721Market[erc721Address].listings[tokenId];
        require(
            _isListingValid(erc721Address, listing),
            "Token is not for sale"
        );
        require(
            !_isTokenOwner(erc721Address, tokenId, msg.sender),
            "Token owner can't buy their own token"
        );
        require(
            msg.value >= listing.value,
            "The value send is below sale price"
        );

        (uint256 _serviceFee, uint256 _royaltyFee) = _calculateFees(
            erc721Address,
            listing.value
        );

        Address.sendValue(
            payable(listing.seller),
            msg.value - _serviceFee - _royaltyFee
        );
        Address.sendValue(payable(owner()), _serviceFee);

        address _royaltyRecipient = royalty(erc721Address).recipient;
        if (_royaltyRecipient != address(0) && _royaltyFee > 0) {
            Address.sendValue(payable(_royaltyRecipient), _royaltyFee);
        }

        emit TokenBought({
            erc721Address: erc721Address,
            tokenId: tokenId,
            buyer: msg.sender,
            listing: listing,
            serviceFee: _serviceFee,
            royaltyFee: _royaltyFee
        });

        IERC721(erc721Address).safeTransferFrom(
            listing.seller,
            msg.sender,
            tokenId
        );

        _delistToken(erc721Address, tokenId);
        _removeBidOfBidder(erc721Address, tokenId, msg.sender);
    }

    function enterBidForToken(
        address erc721Address,
        uint256 tokenId,
        uint256 value,
        uint256 expireTimestamp
    )
        external
        override
        onlyTradingOpen
        onlyAllowedExpireTimestamp(expireTimestamp)
    {

        Bid memory bid = Bid(tokenId, value, msg.sender, expireTimestamp);

        require(_isBidValid(erc721Address, bid), "Bid is not valid");

        _erc721Market[erc721Address].tokenIdWithBid.add(tokenId);
        _erc721Market[erc721Address].bids[tokenId].bidders.add(msg.sender);
        _erc721Market[erc721Address].bids[tokenId].bids[msg.sender] = bid;

        emit TokenBidEntered(erc721Address, tokenId, bid);
    }

    function withdrawBidForToken(address erc721Address, uint256 tokenId)
        external
        override
    {

        Bid memory bid = _erc721Market[erc721Address].bids[tokenId].bids[
            msg.sender
        ];
        require(
            bid.bidder == msg.sender,
            "This address doesn't have bid on this token"
        );

        emit TokenBidWithdrawn(erc721Address, tokenId, bid);
        _removeBidOfBidder(erc721Address, tokenId, msg.sender);
    }

    function acceptBidForToken(
        address erc721Address,
        uint256 tokenId,
        address bidder,
        uint256 value
    ) external override nonReentrant {

        require(
            _isTokenOwner(erc721Address, tokenId, msg.sender),
            "Only token owner can accept bid of token"
        );
        require(
            _isTokenApproved(erc721Address, tokenId) ||
                _isAllTokenApproved(erc721Address, msg.sender),
            "The token is not approved to transfer by the contract"
        );

        Bid memory existingBid = getBidderTokenBid(
            erc721Address,
            tokenId,
            bidder
        );
        require(
            existingBid.tokenId == tokenId &&
                existingBid.value == value &&
                existingBid.bidder == bidder,
            "This token doesn't have a matching bid"
        );

        address _royaltyRecipient = royalty(erc721Address).recipient;
        (uint256 _serviceFee, uint256 _royaltyFee) = _calculateFees(
            erc721Address,
            existingBid.value
        );

        _paymentToken.safeTransferFrom({
            from: existingBid.bidder,
            to: msg.sender,
            value: existingBid.value - _serviceFee - _royaltyFee
        });
        _paymentToken.safeTransferFrom({
            from: existingBid.bidder,
            to: owner(),
            value: _serviceFee
        });
        if (_royaltyRecipient != address(0) && _royaltyFee > 0) {
            _paymentToken.safeTransferFrom({
                from: existingBid.bidder,
                to: _royaltyRecipient,
                value: _royaltyFee
            });
        }

        IERC721(erc721Address).safeTransferFrom({
            from: msg.sender,
            to: existingBid.bidder,
            tokenId: tokenId
        });

        emit TokenBidAccepted({
            erc721Address: erc721Address,
            tokenId: tokenId,
            seller: msg.sender,
            bid: existingBid,
            serviceFee: _serviceFee,
            royaltyFee: _royaltyFee
        });

        _delistToken(erc721Address, tokenId);
        _removeBidOfBidder(erc721Address, tokenId, existingBid.bidder);
    }

    function isTradingEnabled() external view override returns (bool) {

        return _isTradingEnabled;
    }

    function getTokenListing(address erc721Address, uint256 tokenId)
        public
        view
        override
        returns (Listing memory validListing)
    {

        Listing memory listing = _erc721Market[erc721Address].listings[tokenId];
        if (_isListingValid(erc721Address, listing)) {
            validListing = listing;
        }
    }

    function numTokenListings(address erc721Address)
        public
        view
        override
        returns (uint256)
    {

        return _erc721Market[erc721Address].tokenIdWithListing.length();
    }

    function getTokenListings(
        address erc721Address,
        uint256 from,
        uint256 size
    ) public view override returns (Listing[] memory listings) {

        uint256 listingsCount = numTokenListings(erc721Address);

        if (from < listingsCount && size > 0) {
            uint256 querySize = size;
            if ((from + size) > listingsCount) {
                querySize = listingsCount - from;
            }
            listings = new Listing[](querySize);
            for (uint256 i = 0; i < querySize; i++) {
                uint256 tokenId = _erc721Market[erc721Address]
                    .tokenIdWithListing
                    .at(i + from);
                Listing memory listing = _erc721Market[erc721Address].listings[
                    tokenId
                ];
                if (_isListingValid(erc721Address, listing)) {
                    listings[i] = listing;
                }
            }
        }
    }

    function getBidderTokenBid(
        address erc721Address,
        uint256 tokenId,
        address bidder
    ) public view override returns (Bid memory validBid) {

        Bid memory bid = _erc721Market[erc721Address].bids[tokenId].bids[
            bidder
        ];
        if (_isBidValid(erc721Address, bid)) {
            validBid = bid;
        }
    }

    function getTokenBids(address erc721Address, uint256 tokenId)
        external
        view
        override
        returns (Bid[] memory bids)
    {

        uint256 bidderCount = _erc721Market[erc721Address]
            .bids[tokenId]
            .bidders
            .length();

        bids = new Bid[](bidderCount);
        for (uint256 i; i < bidderCount; i++) {
            address bidder = _erc721Market[erc721Address]
                .bids[tokenId]
                .bidders
                .at(i);
            Bid memory bid = _erc721Market[erc721Address].bids[tokenId].bids[
                bidder
            ];
            if (_isBidValid(erc721Address, bid)) {
                bids[i] = bid;
            }
        }
    }

    function getTokenHighestBid(address erc721Address, uint256 tokenId)
        public
        view
        override
        returns (Bid memory highestBid)
    {

        highestBid = Bid(tokenId, 0, address(0), 0);
        uint256 bidderCount = _erc721Market[erc721Address]
            .bids[tokenId]
            .bidders
            .length();
        for (uint256 i; i < bidderCount; i++) {
            address bidder = _erc721Market[erc721Address]
                .bids[tokenId]
                .bidders
                .at(i);
            Bid memory bid = _erc721Market[erc721Address].bids[tokenId].bids[
                bidder
            ];
            if (
                _isBidValid(erc721Address, bid) && bid.value > highestBid.value
            ) {
                highestBid = bid;
            }
        }
    }

    function numTokenWithBids(address erc721Address)
        public
        view
        override
        returns (uint256)
    {

        return _erc721Market[erc721Address].tokenIdWithBid.length();
    }

    function getTokenHighestBids(
        address erc721Address,
        uint256 from,
        uint256 size
    ) public view override returns (Bid[] memory highestBids) {

        uint256 tokenCount = numTokenWithBids(erc721Address);

        if (from < tokenCount && size > 0) {
            uint256 querySize = size;
            if ((from + size) > tokenCount) {
                querySize = tokenCount - from;
            }
            highestBids = new Bid[](querySize);
            for (uint256 i = 0; i < querySize; i++) {
                highestBids[i] = getTokenHighestBid({
                    erc721Address: erc721Address,
                    tokenId: _erc721Market[erc721Address].tokenIdWithBid.at(
                        i + from
                    )
                });
            }
        }
    }

    function getBidderBids(
        address erc721Address,
        address bidder,
        uint256 from,
        uint256 size
    ) external view override returns (Bid[] memory bidderBids) {

        uint256 tokenCount = numTokenWithBids(erc721Address);

        if (from < tokenCount && size > 0) {
            uint256 querySize = size;
            if ((from + size) > tokenCount) {
                querySize = tokenCount - from;
            }
            bidderBids = new Bid[](querySize);
            for (uint256 i = 0; i < querySize; i++) {
                bidderBids[i] = getBidderTokenBid({
                    erc721Address: erc721Address,
                    tokenId: _erc721Market[erc721Address].tokenIdWithBid.at(
                        i + from
                    ),
                    bidder: bidder
                });
            }
        }
    }

    function _isTokenOwner(
        address erc721Address,
        uint256 tokenId,
        address account
    ) private view returns (bool) {

        IERC721 _erc721 = IERC721(erc721Address);
        try _erc721.ownerOf(tokenId) returns (address tokenOwner) {
            return tokenOwner == account;
        } catch {
            return false;
        }
    }

    function _isTokenApproved(address erc721Address, uint256 tokenId)
        private
        view
        returns (bool)
    {

        IERC721 _erc721 = IERC721(erc721Address);
        try _erc721.getApproved(tokenId) returns (address tokenOperator) {
            return tokenOperator == address(this);
        } catch {
            return false;
        }
    }

    function _isAllTokenApproved(address erc721Address, address owner)
        private
        view
        returns (bool)
    {

        IERC721 _erc721 = IERC721(erc721Address);
        return _erc721.isApprovedForAll(owner, address(this));
    }

    function _isListingValid(address erc721Address, Listing memory listing)
        private
        view
        returns (bool isValid)
    {

        if (
            _isTokenOwner(erc721Address, listing.tokenId, listing.seller) &&
            (_isTokenApproved(erc721Address, listing.tokenId) ||
                _isAllTokenApproved(erc721Address, listing.seller)) &&
            listing.value > 0 &&
            listing.expireTimestamp > block.timestamp
        ) {
            isValid = true;
        }
    }

    function _isBidValid(address erc721Address, Bid memory bid)
        private
        view
        returns (bool isValid)
    {

        if (
            !_isTokenOwner(erc721Address, bid.tokenId, bid.bidder) &&
            _paymentToken.allowance(bid.bidder, address(this)) >= bid.value &&
            _paymentToken.balanceOf(bid.bidder) >= bid.value &&
            bid.value > 0 &&
            bid.expireTimestamp > block.timestamp
        ) {
            isValid = true;
        }
    }

    function _delistToken(address erc721Address, uint256 tokenId) private {

        if (_erc721Market[erc721Address].tokenIdWithListing.contains(tokenId)) {
            delete _erc721Market[erc721Address].listings[tokenId];
            _erc721Market[erc721Address].tokenIdWithListing.remove(tokenId);
        }
    }

    function _removeBidOfBidder(
        address erc721Address,
        uint256 tokenId,
        address bidder
    ) private {

        if (
            _erc721Market[erc721Address].bids[tokenId].bidders.contains(bidder)
        ) {
            delete _erc721Market[erc721Address].bids[tokenId].bids[bidder];
            _erc721Market[erc721Address].bids[tokenId].bidders.remove(bidder);

            if (
                _erc721Market[erc721Address].bids[tokenId].bidders.length() == 0
            ) {
                _erc721Market[erc721Address].tokenIdWithBid.remove(tokenId);
            }
        }
    }

    function _calculateFees(address erc721Address, uint256 value)
        private
        view
        returns (uint256 _serviceFee, uint256 _royaltyFee)
    {

        uint256 _royaltyFeeFraction = royalty(erc721Address).feeFraction;
        uint256 _baseFractions = 1000 +
            _serviceFeeFraction +
            _royaltyFeeFraction;

        _serviceFee = (value * _serviceFeeFraction) / _baseFractions;
        _royaltyFee = (value * _royaltyFeeFraction) / _baseFractions;
    }

    function changeMarketplaceStatus(bool enabled) external onlyOwner {

        _isTradingEnabled = enabled;
    }

    function actionTimeOutRangeMin() external view override returns (uint256) {

        return _actionTimeOutRangeMin;
    }

    function actionTimeOutRangeMax() external view override returns (uint256) {

        return _actionTimeOutRangeMax;
    }

    function paymentToken() external view override returns (address) {

        return address(_paymentToken);
    }

    function changeMinActionTimeLimit(uint256 timeInSec) external onlyOwner {

        _actionTimeOutRangeMin = timeInSec;
    }

    function changeMaxActionTimeLimit(uint256 timeInSec) external onlyOwner {

        _actionTimeOutRangeMax = timeInSec;
    }

    function serviceFee() external view override returns (uint8) {

        return _serviceFeeFraction;
    }

    function changeSeriveFee(uint8 serviceFeeFraction_) external onlyOwner {

        require(
            serviceFeeFraction_ <= 25,
            "Attempt to set percentage higher than 2.5%."
        );

        _serviceFeeFraction = serviceFeeFraction_;
    }
}