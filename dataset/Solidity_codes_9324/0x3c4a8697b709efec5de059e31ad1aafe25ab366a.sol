
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

pragma solidity >=0.6.2 <0.8.0;

library AddressUpgradeable {

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

pragma solidity >=0.4.24 <0.8.0;


abstract contract Initializable {

    bool private _initialized;

    bool private _initializing;

    modifier initializer() {
        require(_initializing || _isConstructor() || !_initialized, "Initializable: contract is already initialized");

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

    function _isConstructor() private view returns (bool) {
        return !AddressUpgradeable.isContract(address(this));
    }
}// MIT

pragma solidity >=0.6.0 <0.8.0;

abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal initializer {
        __Context_init_unchained();
    }

    function __Context_init_unchained() internal initializer {
    }
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
    uint256[50] private __gap;
}// MIT

pragma solidity >=0.6.0 <0.8.0;

abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function __Ownable_init() internal initializer {
        __Context_init_unchained();
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal initializer {
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
    uint256[49] private __gap;
}// MIT

pragma solidity >=0.6.0 <0.8.0;

abstract contract ReentrancyGuardUpgradeable is Initializable {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    function __ReentrancyGuard_init() internal initializer {
        __ReentrancyGuard_init_unchained();
    }

    function __ReentrancyGuard_init_unchained() internal initializer {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
    }
    uint256[49] private __gap;
}// MIT

pragma solidity 0.6.12;


interface IAddressRegistry {

    function xyz() external view returns (address);


    function marketplace() external view returns (address);


    function bundleMarketplace() external view returns (address);


    function tokenRegistry() external view returns (address);

}

interface IMarketplace {

    function minters(address, uint256) external view returns (address);


    function royalties(address, uint256) external view returns (uint16);


    function collectionRoyalties(address)
        external
        view
        returns (
            uint16,
            address,
            address
        );


    function getPrice(address) external view returns (int256);

}

interface IBundleMarketplace {

    function validateItemSold(
        address,
        uint256,
        uint256
    ) external;

}

interface ITokenRegistry {

    function enabled(address) external returns (bool);

}

interface IMarketplaceFeeEngine {

    function getMarketplaceFee(
        bytes32,
        address,
        uint256
    ) external view returns (address payable[] memory, uint256[] memory);

}

contract Auction is OwnableUpgradeable, ReentrancyGuardUpgradeable {

    using SafeMath for uint256;
    using AddressUpgradeable for address payable;
    using SafeERC20 for IERC20;

    event AuctionContractDeployed();

    event PauseToggled(bool isPaused);

    event AuctionCreated(
        address indexed nftAddress,
        uint256 indexed tokenId,
        address payToken
    );

    event UpdateAuctionEndTime(
        address indexed nftAddress,
        uint256 indexed tokenId,
        uint256 endTime
    );

    event UpdateAuctionStartTime(
        address indexed nftAddress,
        uint256 indexed tokenId,
        uint256 startTime
    );

    event UpdateAuctionReservePrice(
        address indexed nftAddress,
        uint256 indexed tokenId,
        address payToken,
        uint256 reservePrice
    );

    event UpdatePlatformFee(uint256 platformFee);

    event UpdatePlatformFeeRecipient(address payable platformFeeRecipient);

    event UpdateMinBidIncrement(uint256 minBidIncrement);

    event UpdateBidWithdrawalLockTime(uint256 bidWithdrawalLockTime);

    event BidPlaced(
        address indexed nftAddress,
        uint256 indexed tokenId,
        address indexed bidder,
        uint256 bid
    );

    event BidWithdrawn(
        address indexed nftAddress,
        uint256 indexed tokenId,
        address indexed bidder,
        uint256 bid
    );

    event BidRefunded(
        address indexed nftAddress,
        uint256 indexed tokenId,
        address indexed bidder,
        uint256 bid
    );

    event AuctionResulted(
        address oldOwner,
        address indexed nftAddress,
        uint256 indexed tokenId,
        address indexed winner,
        address payToken,
        int256 unitPrice,
        uint256 winningBid
    );

    event AuctionCancelled(address indexed nftAddress, uint256 indexed tokenId);

    struct Auction_ {
        address owner;
        address payToken;
        uint256 reservePrice;
        uint256 startTime;
        uint256 endTime;
        bool resulted;
    }

    struct HighestBid {
        address payable bidder;
        uint256 bid;
        uint256 lastBidTime;
    }

    mapping(address => mapping(uint256 => Auction_)) public auctions;

    mapping(address => mapping(uint256 => HighestBid)) public highestBids;

    uint256 public minBidIncrement = 0.05 ether;

    uint256 public bidWithdrawalLockTime = 20 minutes;

    uint256 public platformFee = 25;

    address payable public platformFeeRecipient;

    IAddressRegistry public addressRegistry;

    bool public isPaused;

    IMarketplaceFeeEngine public marketplaceFeeEngine;

    modifier whenNotPaused() {

        require(!isPaused, "contract paused");
        _;
    }

    modifier onlyMarketplace() {

        require(
            addressRegistry.marketplace() == _msgSender() ||
                addressRegistry.bundleMarketplace() == _msgSender(),
            "not marketplace contract"
        );
        _;
    }

    function initialize(address payable _platformFeeRecipient)
        public
        initializer
    {

        require(
            _platformFeeRecipient != address(0),
            "Auction: Invalid Platform Fee Recipient"
        );

        platformFeeRecipient = _platformFeeRecipient;
        emit AuctionContractDeployed();

        __Ownable_init();
        __ReentrancyGuard_init();
    }

    function createAuction(
        address _nftAddress,
        uint256 _tokenId,
        address _payToken,
        uint256 _reservePrice,
        uint256 _startTimestamp,
        uint256 _endTimestamp
    ) external whenNotPaused {

        require(
            IERC721(_nftAddress).ownerOf(_tokenId) == _msgSender() &&
                IERC721(_nftAddress).isApprovedForAll(
                    _msgSender(),
                    address(this)
                ),
            "not owner and or contract not approved"
        );

        require(
            _payToken == address(0) ||
                (addressRegistry.tokenRegistry() != address(0) &&
                    ITokenRegistry(addressRegistry.tokenRegistry())
                        .enabled(_payToken)),
            "invalid pay token"
        );

        _createAuction(
            _nftAddress,
            _tokenId,
            _payToken,
            _reservePrice,
            _startTimestamp,
            _endTimestamp
        );
    }

    function placeBid(address _nftAddress, uint256 _tokenId)
        external
        payable
        nonReentrant
        whenNotPaused
    {

        require(_msgSender().isContract() == false, "no contracts permitted");

        Auction_ memory auction = auctions[_nftAddress][_tokenId];

        require(
            _getNow() >= auction.startTime && _getNow() <= auction.endTime,
            "bidding outside of the auction window"
        );
        require(auction.payToken == address(0), "invalid pay token");

        _placeBid(_nftAddress, _tokenId, msg.value);
    }

    function placeBid(
        address _nftAddress,
        uint256 _tokenId,
        uint256 _bidAmount
    ) external nonReentrant whenNotPaused {

        require(_msgSender().isContract() == false, "no contracts permitted");

        Auction_ memory auction = auctions[_nftAddress][_tokenId];

        require(
            _getNow() >= auction.startTime && _getNow() <= auction.endTime,
            "bidding outside of the auction window"
        );
        require(
            auction.payToken != address(0),
            "ERC20 method used for FTM auction"
        );

        _placeBid(_nftAddress, _tokenId, _bidAmount);
    }

    function _placeBid(
        address _nftAddress,
        uint256 _tokenId,
        uint256 _bidAmount
    ) internal whenNotPaused {

        Auction_ storage auction = auctions[_nftAddress][_tokenId];
        HighestBid storage highestBid = highestBids[_nftAddress][_tokenId];
        uint256 minBidRequired = highestBid.bid.add(minBidIncrement);
        require(
            _bidAmount >= minBidRequired,
            "failed to outbid highest bidder"
        );
        if (auction.payToken != address(0)) {
            IERC20 payToken = IERC20(auction.payToken);
            require(
                payToken.transferFrom(_msgSender(), address(this), _bidAmount),
                "insufficient balance or not approved"
            );
        }

        if (highestBid.bidder != address(0)) {
            _refundHighestBidder(
                _nftAddress,
                _tokenId,
                highestBid.bidder,
                highestBid.bid
            );
        }

        highestBid.bidder = _msgSender();
        highestBid.bid = _bidAmount;
        highestBid.lastBidTime = _getNow();

        emit BidPlaced(_nftAddress, _tokenId, _msgSender(), _bidAmount);
    }

    function withdrawBid(address _nftAddress, uint256 _tokenId)
        external
        nonReentrant
        whenNotPaused
    {

        HighestBid storage highestBid = highestBids[_nftAddress][_tokenId];

        require(
            highestBid.bidder == _msgSender(),
            "you are not the highest bidder"
        );

        uint256 _endTime = auctions[_nftAddress][_tokenId].endTime;

        require(
            _getNow() > _endTime && (_getNow() - _endTime >= 43200),
            "can withdraw only after 12 hours (after auction ended)"
        );

        uint256 previousBid = highestBid.bid;

        delete highestBids[_nftAddress][_tokenId];

        _refundHighestBidder(_nftAddress, _tokenId, _msgSender(), previousBid);

        emit BidWithdrawn(_nftAddress, _tokenId, _msgSender(), previousBid);
    }


    function resultAuction(address _nftAddress, uint256 _tokenId, string memory _source)
        external
        nonReentrant
    {

        _resultAuction(_nftAddress, _tokenId, _source);
    }

    function resultAuction(address _nftAddress, uint256 _tokenId)
        external
        nonReentrant
    {

        _resultAuction(_nftAddress, _tokenId, "");
    }

    function _resultAuction(address _nftAddress, uint256 _tokenId, string memory _source) private {

        Auction_ storage auction = auctions[_nftAddress][_tokenId];

        require(
            IERC721(_nftAddress).ownerOf(_tokenId) == _msgSender() &&
                _msgSender() == auction.owner,
            "sender must be item owner"
        );

        require(auction.endTime > 0, "no auction exists");

        require(_getNow() > auction.endTime, "auction not ended");

        require(!auction.resulted, "auction already resulted");

        HighestBid storage highestBid = highestBids[_nftAddress][_tokenId];
        address winner = highestBid.bidder;
        uint256 winningBid = highestBid.bid;

        require(winner != address(0), "no open bids");
        require(
            winningBid >= auction.reservePrice,
            "highest bid is below reservePrice"
        );

        require(
            IERC721(_nftAddress).isApprovedForAll(_msgSender(), address(this)),
            "auction not approved"
        );

        auction.resulted = true;

        delete highestBids[_nftAddress][_tokenId];


        uint256 feeAmount = _distributeMarketplaceFee(_source, _nftAddress, winningBid, auction.payToken);

        IMarketplace marketplace = IMarketplace(
            addressRegistry.marketplace()
        );
        address minter = marketplace.minters(_nftAddress, _tokenId);
        uint16 royalty = marketplace.royalties(_nftAddress, _tokenId);
        if (minter != address(0) && royalty != 0) {
            uint256 royaltyFee = winningBid.mul(royalty).div(10000);
            if (auction.payToken == address(0)) {
                (bool royaltyTransferSuccess, ) = payable(minter).call{
                    value: royaltyFee
                }("");
                require(
                    royaltyTransferSuccess,
                    "failed to send the owner their royalties"
                );
            } else {
                IERC20 payToken = IERC20(auction.payToken);
                require(
                    payToken.transfer(minter, royaltyFee),
                    "failed to send the owner their royalties"
                );
            }
            feeAmount = feeAmount.add(royaltyFee);
        } else {
            (royalty, , minter) = marketplace.collectionRoyalties(_nftAddress);
            if (minter != address(0) && royalty != 0) {
                uint256 royaltyFee = winningBid.mul(royalty).div(10000);
                if (auction.payToken == address(0)) {
                    (bool royaltyTransferSuccess, ) = payable(minter).call{
                        value: royaltyFee
                    }("");
                    require(
                        royaltyTransferSuccess,
                        "failed to send the royalties"
                    );
                } else {
                    IERC20 payToken = IERC20(auction.payToken);
                    require(
                        payToken.transfer(minter, royaltyFee),
                        "failed to send the royalties"
                    );
                }
                feeAmount = feeAmount.add(royaltyFee);
            }
        }
        {
            uint256 payAmount = winningBid.sub(feeAmount);
            if (payAmount > 0) {
                if (auction.payToken == address(0)) {
                    (bool ownerTransferSuccess, ) = auction.owner.call{
                        value: payAmount
                    }("");
                    require(
                        ownerTransferSuccess,
                        "failed to send the owner the auction balance"
                    );
                } else {
                    IERC20 payToken = IERC20(auction.payToken);
                    require(
                        payToken.transfer(auction.owner, payAmount),
                        "failed to send the owner the auction balance"
                    );
                }
            }
        }

        IERC721(_nftAddress).safeTransferFrom(
            IERC721(_nftAddress).ownerOf(_tokenId),
            winner,
            _tokenId
        );

        IBundleMarketplace(addressRegistry.bundleMarketplace())
            .validateItemSold(_nftAddress, _tokenId, uint256(1));

        emit AuctionResulted(
            _msgSender(),
            _nftAddress,
            _tokenId,
            winner,
            auction.payToken,
            IMarketplace(addressRegistry.marketplace()).getPrice(
                auction.payToken
            ),
            winningBid
        );

        delete auctions[_nftAddress][_tokenId];
    }

    function cancelAuction(address _nftAddress, uint256 _tokenId)
        external
        nonReentrant
    {

        Auction_ memory auction = auctions[_nftAddress][_tokenId];

        require(
            IERC721(_nftAddress).ownerOf(_tokenId) == _msgSender() &&
                _msgSender() == auction.owner,
            "sender must be owner"
        );
        require(auction.endTime > 0, "no auction exists");
        require(!auction.resulted, "auction already resulted");

        _cancelAuction(_nftAddress, _tokenId);
    }

    function toggleIsPaused() external onlyOwner {

        isPaused = !isPaused;
        emit PauseToggled(isPaused);
    }

    function updateMinBidIncrement(uint256 _minBidIncrement)
        external
        onlyOwner
    {

        minBidIncrement = _minBidIncrement;
        emit UpdateMinBidIncrement(_minBidIncrement);
    }

    function updateBidWithdrawalLockTime(uint256 _bidWithdrawalLockTime)
        external
        onlyOwner
    {

        bidWithdrawalLockTime = _bidWithdrawalLockTime;
        emit UpdateBidWithdrawalLockTime(_bidWithdrawalLockTime);
    }

    function updateAuctionReservePrice(
        address _nftAddress,
        uint256 _tokenId,
        uint256 _reservePrice
    ) external {

        Auction_ storage auction = auctions[_nftAddress][_tokenId];

        require(_msgSender() == auction.owner, "sender must be item owner");

        require(!auction.resulted, "auction already resulted");

        require(auction.endTime > 0, "no auction exists");

        auction.reservePrice = _reservePrice;
        emit UpdateAuctionReservePrice(
            _nftAddress,
            _tokenId,
            auction.payToken,
            _reservePrice
        );
    }

    function updateAuctionStartTime(
        address _nftAddress,
        uint256 _tokenId,
        uint256 _startTime
    ) external {

        Auction_ storage auction = auctions[_nftAddress][_tokenId];

        require(_msgSender() == auction.owner, "sender must be owner");

        require(_startTime > 0, "invalid start time");

        require(auction.startTime + 60 > _getNow(), "auction already started");

        require(
            _startTime + 300 < auction.endTime,
            "start time should be less than end time (by 5 minutes)"
        );

        require(!auction.resulted, "auction already resulted");

        require(auction.endTime > 0, "no auction exists");

        auction.startTime = _startTime;
        emit UpdateAuctionStartTime(_nftAddress, _tokenId, _startTime);
    }

    function updateAuctionEndTime(
        address _nftAddress,
        uint256 _tokenId,
        uint256 _endTimestamp
    ) external {

        Auction_ storage auction = auctions[_nftAddress][_tokenId];

        require(_msgSender() == auction.owner, "sender must be owner");

        require(_getNow() < auction.endTime, "auction already ended");

        require(auction.endTime > 0, "no auction exists");
        require(
            auction.startTime < _endTimestamp,
            "end time must be greater than start"
        );
        require(
            _endTimestamp > _getNow() + 300,
            "auction should end after 5 minutes"
        );

        auction.endTime = _endTimestamp;
        emit UpdateAuctionEndTime(_nftAddress, _tokenId, _endTimestamp);
    }

    function updatePlatformFee(uint256 _platformFee) external onlyOwner {

        platformFee = _platformFee;
        emit UpdatePlatformFee(_platformFee);
    }

    function updatePlatformFeeRecipient(address payable _platformFeeRecipient)
        external
        onlyOwner
    {

        require(_platformFeeRecipient != address(0), "zero address");

        platformFeeRecipient = _platformFeeRecipient;
        emit UpdatePlatformFeeRecipient(_platformFeeRecipient);
    }

    function updateAddressRegistry(address _registry) external onlyOwner {

        addressRegistry = IAddressRegistry(_registry);
    }


    function getAuction(address _nftAddress, uint256 _tokenId)
        external
        view
        returns (
            address _owner,
            address _payToken,
            uint256 _reservePrice,
            uint256 _startTime,
            uint256 _endTime,
            bool _resulted
        )
    {

        Auction_ storage auction = auctions[_nftAddress][_tokenId];
        return (
            auction.owner,
            auction.payToken,
            auction.reservePrice,
            auction.startTime,
            auction.endTime,
            auction.resulted
        );
    }

    function getHighestBidder(address _nftAddress, uint256 _tokenId)
        external
        view
        returns (
            address payable _bidder,
            uint256 _bid,
            uint256 _lastBidTime
        )
    {

        HighestBid storage highestBid = highestBids[_nftAddress][_tokenId];
        return (highestBid.bidder, highestBid.bid, highestBid.lastBidTime);
    }


    function _getNow() internal view virtual returns (uint256) {

        return block.timestamp;
    }

    function _createAuction(
        address _nftAddress,
        uint256 _tokenId,
        address _payToken,
        uint256 _reservePrice,
        uint256 _startTimestamp,
        uint256 _endTimestamp
    ) private {

        require(
            auctions[_nftAddress][_tokenId].endTime == 0,
            "auction already started"
        );

        require(
            _endTimestamp >= _startTimestamp + 300,
            "end time must be greater than start (by 5 minutes)"
        );

        require(_startTimestamp > _getNow(), "invalid start time");

        auctions[_nftAddress][_tokenId] = Auction_({
            owner: _msgSender(),
            payToken: _payToken,
            reservePrice: _reservePrice,
            startTime: _startTimestamp,
            endTime: _endTimestamp,
            resulted: false
        });

        emit AuctionCreated(_nftAddress, _tokenId, _payToken);
    }

    function _cancelAuction(address _nftAddress, uint256 _tokenId) private {

        HighestBid storage highestBid = highestBids[_nftAddress][_tokenId];
        if (highestBid.bidder != address(0)) {
            _refundHighestBidder(
                _nftAddress,
                _tokenId,
                highestBid.bidder,
                highestBid.bid
            );

            delete highestBids[_nftAddress][_tokenId];
        }

        delete auctions[_nftAddress][_tokenId];

        emit AuctionCancelled(_nftAddress, _tokenId);
    }

    function _refundHighestBidder(
        address _nftAddress,
        uint256 _tokenId,
        address payable _currentHighestBidder,
        uint256 _currentHighestBid
    ) private {

        Auction_ memory auction = auctions[_nftAddress][_tokenId];
        if (auction.payToken == address(0)) {
            (bool successRefund, ) = _currentHighestBidder.call{
                value: _currentHighestBid
            }("");
            require(successRefund, "failed to refund previous bidder");
        } else {
            IERC20 payToken = IERC20(auction.payToken);
            require(
                payToken.transfer(_currentHighestBidder, _currentHighestBid),
                "failed to refund previous bidder"
            );
        }
        emit BidRefunded(
            _nftAddress,
            _tokenId,
            _currentHighestBidder,
            _currentHighestBid
        );
    }

    function reclaimERC20(address _tokenContract) external onlyOwner {

        require(_tokenContract != address(0), "Invalid address");
        IERC20 token = IERC20(_tokenContract);
        uint256 balance = token.balanceOf(address(this));
        require(token.transfer(_msgSender(), balance), "Transfer failed");
    }

    function initializeMarketplaceFeeEngine(address _marketplaceFeeEngine) public {

        require(address(marketplaceFeeEngine) == address(0x0), "non zero");
        marketplaceFeeEngine = IMarketplaceFeeEngine(_marketplaceFeeEngine);
    }

    function setMarketplaceFeeEngine(address _marketplaceFeeEngine)
        external
        onlyOwner
    {

        marketplaceFeeEngine = IMarketplaceFeeEngine(_marketplaceFeeEngine);
    }

    function _distributeMarketplaceFee(
        string memory _source,
        address _collection,
        uint256 _value,
        address _payToken
    ) private returns (uint256) {

        bytes32 id = keccak256(abi.encodePacked(_source));
        (
            address payable[] memory recipients,
            uint256[] memory fees
        ) = marketplaceFeeEngine.getMarketplaceFee(
                id,
                _collection,
                _value
            );
        uint256 feeAmount = 0;
        for (uint256 i = 0; i < recipients.length; i++) {
            if (fees[i] == 0) {
                continue;
            }
            if (_payToken == address(0)) {
                (bool feeTransferSuccess, ) = recipients[i].call{
                    value: fees[i]
                }("");
                require(feeTransferSuccess, "fee transfer failed");
            } else {
                IERC20 payToken = IERC20(_payToken);
                require(
                    payToken.transfer(
                        recipients[i],
                        fees[i]
                    ),
                    "failed to send platform fee"
                );
            }
            feeAmount = feeAmount.add(fees[i]);
        }
        return feeAmount;
    }
}