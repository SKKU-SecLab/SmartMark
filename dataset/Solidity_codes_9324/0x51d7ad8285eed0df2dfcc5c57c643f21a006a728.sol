
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
}



pragma solidity ^0.8.0;

interface IERC721Receiver {

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);

}

pragma solidity ^0.8.0;

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}

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

}

    abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}


abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}


library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        return div(a, b, "SafeMath: division by zero");
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        require(b != 0, errorMessage);
        return a % b;
    }
}

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
}


contract NFTAuction is Ownable, ReentrancyGuard {

    using SafeMath for uint256;
    uint256 public settlePenalty= 5;    // 5%

    mapping(address => mapping(uint256 => Auction)) public nftContractAuctions;
    mapping(address => mapping(uint256 => Sale)) public nftContractSale;
    mapping(address => mapping(uint256 => address)) public nftOwner;
    mapping(address => uint256) failedTransferCredits;
    mapping(address => mapping(uint256 => Royalty)) public nftRoyalty;

 
    struct Auction {
        uint256 minPrice;
        uint256 auctionBidPeriod; //Increments the length of time the auction is open in which a new bid can be made after each bid.
        uint256 auctionEnd;
        uint256 nftHighestBid;
        uint256 bidIncreasePercentage;
        uint256 ownerPercentage;
        uint256 auctionStartTime;
        address nftHighestBidder;
        address nftSeller;
        address nftRecipient; //The bidder can specify a recipient for the NFT if their bid is successful.
        address ERC20Token; // The seller can specify an ERC20 token that can be used to bid or purchase the NFT
    }

    struct Sale{
        address nftSeller;
        address ERC20Token;
        uint256 buyNowPrice;
    }

    struct Royalty{
        address royaltyOwner;
        uint256 royaltyPercentage;
    }

    modifier minimumBidNotMade(address _nftContractAddress, uint256 _tokenId) {

        require(
            !_isMinimumBidMade(_nftContractAddress, _tokenId),
            "The auction has a valid bid made"
        );
        _;
    }

    modifier auctionOngoing(address _nftContractAddress, uint256 _tokenId) {

        require(
            _isAuctionOngoing(_nftContractAddress, _tokenId),
            "Auction has ended"
        );
        _;
    }

    modifier isAuctionOver(address _nftContractAddress, uint256 _tokenId) {

        require(
            !_isAuctionOngoing(_nftContractAddress, _tokenId),
            "Auction is not yet over"
        );
        _;
    }

    modifier priceGreaterThanZero(uint256 _price) {

        require(_price > 0, "Price cannot be 0");
        _;
    }
    
    modifier paymentAccepted(
        address _nftContractAddress,
        uint256 _tokenId,
        address _erc20Token,
        uint256 _tokenAmount
    ) {

        require(
            _isPaymentAccepted(
                _nftContractAddress,
                _tokenId,
                _erc20Token,
                _tokenAmount
            ),
            "Bid to be made in quantities of specified token or eth"
        );
        _;
    }

    modifier notZeroAddress(address _address) {

        require(_address != address(0), "cannot specify 0 address");
        _;
    }

    modifier increasePercentageAboveMinimum(uint256 _bidIncreasePercentage) {

        require(
            _bidIncreasePercentage >= 0,
            "Bid increase percentage must be greater than minimum settable increase percentage"
        );
        _;
    }

    modifier notNftSeller(address _nftContractAddress, uint256 _tokenId) {

        require(
            msg.sender !=
                nftContractAuctions[_nftContractAddress][_tokenId].nftSeller,
            "Owner cannot bid on own NFT"
        );
        _;
    }

    modifier biddingPeriodMinimum(
        uint256 _auctionBidPeriod
    ){

        require(_auctionBidPeriod> 600,"Minimum bidding beriod is 10 minutes");
        _;
    }

    modifier bidAmountMeetsBidRequirements(
        address _nftContractAddress,
        uint256 _tokenId,
        uint256 _tokenAmount
    ) {

        require(
            _doesBidMeetBidRequirements(
                _nftContractAddress,
                _tokenId,
                _tokenAmount
            ),
            "Not enough funds to bid on NFT"
        );
        _;
    }

    modifier onlyNftSeller(address _nftContractAddress, uint256 _tokenId) {

        require(
            msg.sender ==
                nftContractAuctions[_nftContractAddress][_tokenId].nftSeller,
            "Only the owner can call this function"
        );
        _;
    }
    

    function _isPaymentAccepted(
        address _nftContractAddress,
        uint256 _tokenId,
        address _bidERC20Token,
        uint256 _tokenAmount
    ) internal view returns (bool) {

        address auctionERC20Token = nftContractAuctions[_nftContractAddress][
            _tokenId
        ].ERC20Token;
        if (_isERC20Auction(auctionERC20Token)) {
            return
                msg.value == 0 &&
                auctionERC20Token == _bidERC20Token &&
                _tokenAmount > 0;
        } else {
            return
                msg.value != 0 &&
                _bidERC20Token == address(0) &&
                _tokenAmount == 0;
        }
    }

    function _isERC20Auction(address _auctionERC20Token)
        internal
        pure
        returns (bool)
    {

        return _auctionERC20Token != address(0);
    }

    function _getBidIncreasePercentage(
        address _nftContractAddress,
        uint256 _tokenId
    ) internal view returns (uint256) {

        uint256 bidIncreasePercentage = nftContractAuctions[
            _nftContractAddress
        ][_tokenId].bidIncreasePercentage;
        return bidIncreasePercentage;
    }

    function _doesBidMeetBidRequirements(
        address _nftContractAddress,
        uint256 _tokenId,
        uint256 _tokenAmount
    ) internal view returns (bool) {

        uint256 bidIncreaseAmount= (nftContractAuctions[_nftContractAddress][
            _tokenId
        ].nftHighestBid).mul(100 +_getBidIncreasePercentage(_nftContractAddress, _tokenId))/100;
        return (msg.value >= bidIncreaseAmount ||
            _tokenAmount >= bidIncreaseAmount);
    }

    modifier batchWithinLimits(uint256 _batchTokenIdsLength) {

        require(
            _batchTokenIdsLength > 1 && _batchTokenIdsLength <= 10000,
            "Number of NFTs not applicable for batch sale/auction"
        );
        _;
    }

    function _isAuctionOngoing(address _nftContractAddress, uint256 _tokenId)
        internal
        view
        returns (bool)
    {

        uint256 auctionEndTimestamp = nftContractAuctions[_nftContractAddress][
            _tokenId
        ].auctionEnd;
        return (auctionEndTimestamp == 0 ||
            block.timestamp < auctionEndTimestamp);
    }

    function createBatchNftAuction(
        address _nftContractAddress,
        uint256[] memory _batchTokenIds,
        uint256[] memory _batchTokenPrices,
        uint256[] memory _royaltyPercentage,
        address _erc20Token,
        uint256 _auctionStartTime,
        uint256 _ownerPercentage,
        uint256 _auctionBidPeriod, 
        uint256 _bidIncreasePercentage
    )
        external
        batchWithinLimits(_batchTokenIds.length)
        biddingPeriodMinimum(_auctionBidPeriod)
        increasePercentageAboveMinimum(_bidIncreasePercentage)
    {

        _auctionStartTime=_auctionStartTime + block.timestamp;
        require((_batchTokenIds.length == _batchTokenPrices.length) && 
        (_batchTokenIds.length == _royaltyPercentage.length),
            "Number of tokens and prices don't match"
        );
        require(_auctionStartTime > block.timestamp, "start time cannot be in past");
        
        for(uint i=0; i<_batchTokenIds.length; i++){
            require(_batchTokenPrices[i]>0, "Price must be greater than 0");
            nftContractAuctions[_nftContractAddress][_batchTokenIds[i]]
                .auctionBidPeriod = _auctionBidPeriod;
            
            nftContractAuctions[_nftContractAddress][_batchTokenIds[i]]
                .bidIncreasePercentage = _bidIncreasePercentage;
            
            nftContractAuctions[_nftContractAddress][_batchTokenIds[i]]
                .ownerPercentage = _ownerPercentage;
            
            if(nftRoyalty[_nftContractAddress][_batchTokenIds[i]]
            .royaltyOwner==address(0)){
                nftRoyalty[_nftContractAddress][_batchTokenIds[i]]
                .royaltyOwner= msg.sender;
                nftRoyalty[_nftContractAddress][_batchTokenIds[i]]
                .royaltyPercentage= _royaltyPercentage[i];
            }
            _createNewNftAuction(
                _nftContractAddress,
                _batchTokenIds[i],
                _erc20Token,
                _ownerPercentage,
                _batchTokenPrices[i],
                _auctionStartTime
            );
        }
    }
    
    function createNewNFTAuction(
        address _nftContractAddress,
        uint256 _tokenId,
        address _erc20Token,
        uint256 _minPrice,
        uint256 _royaltyPercentage,
        uint256 _ownerPercentage,
        uint256 _auctionBidPeriod, 
        uint256 _bidIncreasePercentage,
        uint256 _auctionStartTime
    ) external
        priceGreaterThanZero(_minPrice)
        biddingPeriodMinimum(_auctionBidPeriod)
        increasePercentageAboveMinimum(_bidIncreasePercentage)
    {

        _auctionStartTime=_auctionStartTime + block.timestamp;
        require(_auctionStartTime > block.timestamp, "start time cannot be in past");

        nftContractAuctions[_nftContractAddress][_tokenId]
            .auctionBidPeriod = _auctionBidPeriod;
        
        nftContractAuctions[_nftContractAddress][_tokenId]
            .bidIncreasePercentage = _bidIncreasePercentage;

        nftContractAuctions[_nftContractAddress][_tokenId]
            .ownerPercentage = _ownerPercentage;
        
        if(nftRoyalty[_nftContractAddress][_tokenId]
            .royaltyOwner==address(0)){
                nftRoyalty[_nftContractAddress][_tokenId]
                .royaltyOwner= msg.sender;
                nftRoyalty[_nftContractAddress][_tokenId]
                .royaltyPercentage= _royaltyPercentage;
        }

        _createNewNftAuction(
            _nftContractAddress,
            _tokenId,
            _erc20Token,
            _ownerPercentage,
            _minPrice,
            _auctionStartTime
        );
    }  

    function _setupAuction(
        address _nftContractAddress,
        uint256 _tokenId,
        address _erc20Token,
        uint256 _ownerPercentage,
        uint256 _minPrice,
        uint256 _auctionStartTime
    )
        internal
    { 

        if (_erc20Token != address(0)) {
            nftContractAuctions[_nftContractAddress][_tokenId]
                .ERC20Token = _erc20Token;
        }
        nftContractAuctions[_nftContractAddress][_tokenId].minPrice = _minPrice;
        nftContractAuctions[_nftContractAddress][_tokenId].nftSeller = msg
            .sender;
        nftContractAuctions[_nftContractAddress][_tokenId].auctionEnd= 
        nftContractAuctions[_nftContractAddress][_tokenId]
        .auctionBidPeriod.add(block.timestamp);  
        nftContractAuctions[_nftContractAddress][_tokenId]
        .auctionStartTime= _auctionStartTime;
        nftContractAuctions[_nftContractAddress][_tokenId]
        .ownerPercentage= _ownerPercentage;
    }

    function _createNewNftAuction(
        address _nftContractAddress,
        uint256 _tokenId,
        address _erc20Token,
        uint256 _ownerPercentage,
        uint256 _minPrice,
        uint256 _auctionStartTime
    ) internal{

        IERC721(_nftContractAddress).transferFrom(
            msg.sender,
            address(this),
            _tokenId
        );
        _setupAuction(
            _nftContractAddress,
            _tokenId,
            _erc20Token,
            _ownerPercentage,
            _minPrice,
            _auctionStartTime
        );
    }

    function _reverseAndResetPreviousBid(
        address _nftContractAddress,
        uint256 _tokenId
    ) internal {

        address nftHighestBidder = nftContractAuctions[_nftContractAddress][
            _tokenId
        ].nftHighestBidder;

        uint256 nftHighestBid = nftContractAuctions[_nftContractAddress][
            _tokenId
        ].nftHighestBid;
        _resetBids(_nftContractAddress, _tokenId);

        _payout(_nftContractAddress, _tokenId, nftHighestBidder, nftHighestBid);
    }

    function updateMinimumPrice(
        address _nftContractAddress,
        uint256 _tokenId,
        uint256 _newMinPrice
    )
        external
        onlyNftSeller(_nftContractAddress, _tokenId)
        minimumBidNotMade(_nftContractAddress, _tokenId)
        priceGreaterThanZero(_newMinPrice)
    {

        nftContractAuctions[_nftContractAddress][_tokenId]
            .minPrice = _newMinPrice;
    }

    function _updateHighestBid(
        address _nftContractAddress,
        uint256 _tokenId,
        uint256 _tokenAmount
    ) internal {

        address auctionERC20Token = nftContractAuctions[_nftContractAddress][
            _tokenId
        ].ERC20Token;
        nftContractAuctions[_nftContractAddress][_tokenId]
            .nftHighestBidder = msg.sender;

        if (_isERC20Auction(auctionERC20Token)) {
            nftContractAuctions[_nftContractAddress][_tokenId]
                .nftHighestBid = _tokenAmount;
            IERC20(auctionERC20Token).transferFrom(
                msg.sender,
                address(this),
                _tokenAmount
            );
            nftContractAuctions[_nftContractAddress][_tokenId]
                .nftHighestBid = _tokenAmount;
        } else {
            nftContractAuctions[_nftContractAddress][_tokenId]
                .nftHighestBid = msg.value;
        }
    }

    function _reversePreviousBidAndUpdateHighestBid(
        address _nftContractAddress,
        uint256 _tokenId,
        uint256 _tokenAmount
    ) internal {

        address prevNftHighestBidder = nftContractAuctions[_nftContractAddress][
            _tokenId
        ].nftHighestBidder;

        uint256 prevNftHighestBid = nftContractAuctions[_nftContractAddress][
            _tokenId
        ].nftHighestBid;
        _updateHighestBid(_nftContractAddress, _tokenId, _tokenAmount);

        if (prevNftHighestBidder != address(0)) {
            _payout(
                _nftContractAddress,
                _tokenId,
                prevNftHighestBidder,
                prevNftHighestBid
            );
        }
    }
    
    function _isMinimumBidMade(address _nftContractAddress, uint256 _tokenId)
        internal
        view
        returns (bool)
    {

        uint256 minPrice = nftContractAuctions[_nftContractAddress][_tokenId]
            .minPrice;
        return
            minPrice > 0 &&
            (nftContractAuctions[_nftContractAddress][_tokenId].nftHighestBid >=
                minPrice);
    }

    function _setupSale(
        address _nftContractAddress,
        uint256 _tokenId,
        address _erc20Token,
        uint256 _buyNowPrice
    )
        internal
    {

        if (_erc20Token != address(0)) {
            nftContractSale[_nftContractAddress][_tokenId]
                .ERC20Token = _erc20Token;
        }
        nftContractSale[_nftContractAddress][_tokenId]
            .buyNowPrice = _buyNowPrice;
        nftContractSale[_nftContractAddress][_tokenId].nftSeller = msg
            .sender;
    }

    function createSale(
        address _nftContractAddress,
        uint256 _tokenId,
        address _erc20Token,
        uint256 _buyNowPrice
    ) external priceGreaterThanZero(_buyNowPrice) {

        IERC721(_nftContractAddress).transferFrom(
            msg.sender,
            address(this),
            _tokenId
        );
        _setupSale(
            _nftContractAddress,
            _tokenId,
            _erc20Token,
            _buyNowPrice
        );
    }

    function createBatchSale(
        address _nftContractAddress,
        uint256[] memory _batchTokenIds,
        uint256[] memory _batchTokenPrice,
        address _erc20Token
    )
        external
        batchWithinLimits(_batchTokenIds.length)
    {

        require(_batchTokenIds.length == _batchTokenPrice.length, "Number of tokens and prices do not match"); 
        for(uint i=0; i< _batchTokenIds.length; i++){
            require(_batchTokenPrice[i]>0, "price cannot be 0 or less");
            IERC721(_nftContractAddress).transferFrom(
            msg.sender,
            address(this),
            _batchTokenIds[i]
        );
            _setupSale(
                _nftContractAddress,
                _batchTokenIds[i],
                _erc20Token,
                _batchTokenPrice[i]
            );
        }
    }

    function buyNFT(
        address _nftContractAddress,
        uint256 _tokenId,
        uint256 _ownerPercentage
    )
        external
        payable
        nonReentrant
    {

        address seller= nftContractSale[_nftContractAddress][_tokenId].nftSeller;
        require(msg.sender!=seller, "Seller cannot buy own NFT");
        uint256 buyNowPrice= nftContractSale[_nftContractAddress][_tokenId].buyNowPrice;
        address erc20Token= nftContractSale[_nftContractAddress][_tokenId].ERC20Token;
        if(_isERC20Auction(erc20Token)){
            require(
                IERC20(erc20Token).balanceOf(msg.sender) >= buyNowPrice, 
                "Must be greater than NFT cost"
            );
        }
        else{
            require(
                msg.value >= buyNowPrice, 
                "Must be greater than NFT cost"
            );
        }
        _buyNFT(
            _nftContractAddress,
            _tokenId,
            _ownerPercentage                             
        );
    }
    
    function _buyNFT(
        address _nftContractAddress,
        uint256 _tokenId,
        uint256 _ownerPercentage
    )
        internal
    {   

        address seller= nftContractSale[_nftContractAddress][_tokenId].nftSeller;
        address erc20Token= nftContractSale[_nftContractAddress][_tokenId].ERC20Token;
        if(_isERC20Auction(erc20Token)){    // if sale is ERC20
            uint totalAmount= nftContractSale[_nftContractAddress][_tokenId].buyNowPrice;
            uint256 ownerAmount= totalAmount.mul(_ownerPercentage).div(10000);
            uint royaltyAmount;
            _resetSale(_nftContractAddress, _tokenId);
            if(nftRoyalty[_nftContractAddress][_tokenId].royaltyOwner != address(0)){
                address royaltyOwner= nftRoyalty[_nftContractAddress][_tokenId].royaltyOwner;
                uint _royaltyPercentage= nftRoyalty[_nftContractAddress][_tokenId].royaltyPercentage;
                royaltyAmount= totalAmount.mul(_royaltyPercentage).div(10000);
                IERC20(erc20Token).transferFrom(msg.sender, royaltyOwner, royaltyAmount);
            }
            uint sellerAmount= totalAmount.sub(royaltyAmount.add(ownerAmount));
            address owner= owner();

            IERC20(erc20Token).transferFrom(msg.sender, owner, ownerAmount);
            IERC20(erc20Token).transferFrom(msg.sender, seller, sellerAmount);
        }
        else{
            uint totalAmount= msg.value;
            uint256 ownerAmount= totalAmount.mul(_ownerPercentage).div(10000);
            _resetSale(_nftContractAddress, _tokenId);
            uint royaltyAmount;
            if(nftRoyalty[_nftContractAddress][_tokenId].royaltyOwner != address(0)){
                address royaltyOwner= nftRoyalty[_nftContractAddress][_tokenId].royaltyOwner;
                uint _royaltyPercentage= nftRoyalty[_nftContractAddress][_tokenId].royaltyPercentage;
                royaltyAmount= totalAmount.mul(_royaltyPercentage).div(10000);
                payable(royaltyOwner).transfer(royaltyAmount);
            }
            uint sellerAmount= totalAmount.sub(royaltyAmount.add(ownerAmount));
            address owner= owner();
            payable(owner).transfer(ownerAmount);
            (bool success, ) = payable(seller).call{value: sellerAmount}("");
            if (!success) {
                failedTransferCredits[seller] =
                    failedTransferCredits[seller].add(sellerAmount);
            }
        }
        IERC721(_nftContractAddress).transferFrom(
                address(this),
                msg.sender,
                _tokenId
        );
    }

    function _resetSale(address _nftContractAddress, uint256 _tokenId)
        internal
    {

        nftContractSale[_nftContractAddress][_tokenId]
            .buyNowPrice = 0;
        nftContractSale[_nftContractAddress][_tokenId]
            .nftSeller = address(
            0
        );
        nftContractSale[_nftContractAddress][_tokenId]
            .ERC20Token = address(
            0
        );
    }

    function _makeBid(
        address _nftContractAddress,
        uint256 _tokenId,
        address _erc20Token,
        uint256 _tokenAmount
    )
        internal
        notNftSeller(_nftContractAddress, _tokenId)
        paymentAccepted(
            _nftContractAddress,
            _tokenId,
            _erc20Token,
            _tokenAmount
        )
        bidAmountMeetsBidRequirements(
            _nftContractAddress,
            _tokenId,
            _tokenAmount
        )
    {

        _reversePreviousBidAndUpdateHighestBid(
            _nftContractAddress,
            _tokenId,
            _tokenAmount
        );
    }

    function _isABidMade(address _nftContractAddress, uint256 _tokenId)
        internal
        view
        returns (bool)
    {

        return (nftContractAuctions[_nftContractAddress][_tokenId]
            .nftHighestBid > 0);
    }

    function makeBid(
        address _nftContractAddress,
        uint256 _tokenId,
        address _erc20Token,
        uint256 _tokenAmount
    )
        external
        payable
        nonReentrant
        auctionOngoing(_nftContractAddress, _tokenId)
    {

        require(
            nftContractAuctions[_nftContractAddress][_tokenId]
            .auctionStartTime < block.timestamp,
            "Auction hasn't begun yet"
        );
        require(
            (_tokenAmount>=
            nftContractAuctions[_nftContractAddress][_tokenId].minPrice)            
            || 
            (msg.value >= nftContractAuctions[_nftContractAddress][_tokenId].minPrice)
            ,
            "Must be greater than minimum amount"
        );
        _makeBid(_nftContractAddress, _tokenId, _erc20Token, _tokenAmount);
    }

    function _resetAuction(address _nftContractAddress, uint256 _tokenId)
        internal
    {

        nftContractAuctions[_nftContractAddress][_tokenId].minPrice = 0;
        nftContractAuctions[_nftContractAddress][_tokenId].auctionEnd = 0;
        nftContractAuctions[_nftContractAddress][_tokenId].auctionBidPeriod = 0;
        nftContractAuctions[_nftContractAddress][_tokenId].ownerPercentage = 0;
        nftContractAuctions[_nftContractAddress][_tokenId]
            .bidIncreasePercentage = 0;
        nftContractAuctions[_nftContractAddress][_tokenId].nftSeller = address(
            0
        );
        nftContractAuctions[_nftContractAddress][_tokenId].ERC20Token = address(
            0
        );
    }

    function _payout(
        address _nftContractAddress,
        uint256 _tokenId,
        address _recipient,
        uint256 _amount
    ) internal{

        address auctionERC20Token = nftContractAuctions[_nftContractAddress][
            _tokenId
        ].ERC20Token;
        if (_isERC20Auction(auctionERC20Token)) {
            IERC20(auctionERC20Token).transfer(_recipient, _amount);
        } else {
            (bool success, ) = payable(_recipient).call{value: _amount}("");
            if (!success) {
                failedTransferCredits[_recipient] =
                    failedTransferCredits[_recipient].add(_amount);
            }
        }
    }

    function withdrawAllFailedCredits() external {

        uint256 amount = failedTransferCredits[msg.sender];

        require(amount != 0, "no credits to withdraw");

        failedTransferCredits[msg.sender] = 0;

        (bool successfulWithdraw, ) = msg.sender.call{value: amount}("");
        require(successfulWithdraw, "withdraw failed");
    }


    function _resetBids(address _nftContractAddress, uint256 _tokenId)
        internal
    {

        nftContractAuctions[_nftContractAddress][_tokenId]
            .nftHighestBidder = address(0);
        nftContractAuctions[_nftContractAddress][_tokenId].nftHighestBid = 0;
        nftContractAuctions[_nftContractAddress][_tokenId]
            .nftRecipient = address(0);
    }

    function _getNftRecipient(address _nftContractAddress, uint256 _tokenId)
        internal
        view
        returns (address)
    {

        address nftRecipient = nftContractAuctions[_nftContractAddress][
            _tokenId
        ].nftRecipient;

        if (nftRecipient == address(0)) {
            return
                nftContractAuctions[_nftContractAddress][_tokenId]
                    .nftHighestBidder;
        } else {
            return nftRecipient;
        }
    }
    
    function _payFeesAndSeller(
        address _nftContractAddress,
        uint256 _tokenId,
        address _nftSeller,
        uint256 _highestBid
    ) internal {

        address erc20Token= nftContractAuctions[_nftContractAddress][_tokenId].ERC20Token;
        uint256 _ownerPercentage = nftContractAuctions[_nftContractAddress][_tokenId].ownerPercentage;
        uint256 ownerAmount= _highestBid.mul(_ownerPercentage).div(10000);
        uint256 sellerAmount= _highestBid.sub(ownerAmount);
        _resetAuction(_nftContractAddress, _tokenId);
        if(_isERC20Auction(erc20Token)){    // if sale is ERC20 
            if(nftRoyalty[_nftContractAddress][_tokenId].royaltyOwner != address(0)){
                address royaltyOwner= nftRoyalty[_nftContractAddress][_tokenId].royaltyOwner;
                uint _royaltyPercentage= nftRoyalty[_nftContractAddress][_tokenId].royaltyPercentage;
                uint royaltyAmount= _highestBid.mul(_royaltyPercentage).div(10000);
                sellerAmount= sellerAmount.sub(royaltyAmount);
                IERC20(erc20Token).transfer(royaltyOwner, royaltyAmount);
            }
            address owner= owner();
            IERC20(erc20Token).transfer(owner, ownerAmount);
        }
        else{
            
            if(nftRoyalty[_nftContractAddress][_tokenId].royaltyOwner != address(0)){
                address royaltyOwner= nftRoyalty[_nftContractAddress][_tokenId].royaltyOwner;
                uint _royaltyPercentage= nftRoyalty[_nftContractAddress][_tokenId].royaltyPercentage;
                uint royaltyAmount= _highestBid.mul(_royaltyPercentage).div(10000);
                sellerAmount= sellerAmount.sub(royaltyAmount);
                payable(royaltyOwner).transfer(royaltyAmount);
            }
            address owner= owner();
            payable(owner).transfer(ownerAmount);
        }

        _payout(
            _nftContractAddress,
            _tokenId,
            _nftSeller,
            sellerAmount
        );
    }

    function ownerOfNFT(address _nftContractAddress, uint256 _tokenId)
        external
        view
        returns (address)
    {

        address nftSeller = nftContractAuctions[_nftContractAddress][_tokenId]
            .nftSeller;
        if (nftSeller != address(0)) {
            return nftSeller;
        }
        address owner = nftOwner[_nftContractAddress][_tokenId];

        require(owner != address(0), "NFT not deposited");
        return owner;
    }

    function _transferNftAndPaySeller(
        address _nftContractAddress,
        uint256 _tokenId
    ) internal {

        address _nftSeller = nftContractAuctions[_nftContractAddress][_tokenId]
            .nftSeller;
        address _nftRecipient = _getNftRecipient(_nftContractAddress, _tokenId);
        uint256 _nftHighestBid = nftContractAuctions[_nftContractAddress][
            _tokenId
        ].nftHighestBid;
        _resetBids(_nftContractAddress, _tokenId);
        _payFeesAndSeller(
            _nftContractAddress,
            _tokenId,
            _nftSeller,
            _nftHighestBid
        );
        
        IERC721(_nftContractAddress).transferFrom(
            address(this),
            _nftRecipient,
            _tokenId
        );
    }

    function takeHighestBid(address _nftContractAddress, uint256 _tokenId)
        external
        onlyNftSeller(_nftContractAddress, _tokenId)
    {

        require(
            _isABidMade(_nftContractAddress, _tokenId),
            "cannot payout 0 bid"
        );
        _transferNftAndPaySeller(_nftContractAddress, _tokenId);
    }

    function settleAuction(address _nftContractAddress, uint256 _tokenId)
        external
        nonReentrant
        isAuctionOver(_nftContractAddress, _tokenId)
    {

        uint256 _nftHighestBid = nftContractAuctions[_nftContractAddress][
            _tokenId
        ].nftHighestBid;
        require(_nftHighestBid > 0, "No bid has been made");

        _transferNftAndPaySeller(_nftContractAddress, _tokenId);
    }


    function settleAuctionOnlyOwner(address _nftContractAddress, uint256 _tokenId)
        external
        onlyOwner
        nonReentrant
        isAuctionOver(_nftContractAddress, _tokenId)
    {

        require(block.timestamp> (nftContractAuctions[_nftContractAddress][_tokenId]
        .auctionEnd.add(
            86400)), 
            "Can't settle before 1 day of grace period has passed"
        );
        uint totalAmt= nftContractAuctions[_nftContractAddress][_tokenId].nftHighestBid;
        address erc20Token= nftContractAuctions[_nftContractAddress][_tokenId].ERC20Token;
        nftContractAuctions[_nftContractAddress][_tokenId].nftHighestBid=
            totalAmt.mul(100-settlePenalty).div(100);
        uint penaltyAmt= totalAmt.mul(settlePenalty).div(100);
        address owner = owner();
        if(_isERC20Auction(erc20Token)){
            IERC20(erc20Token).transfer(owner, penaltyAmt);
        }
        else{
            (bool success, ) = payable(owner).call{value: penaltyAmt}("");
            if (!success) {
                failedTransferCredits[owner] =
                    failedTransferCredits[owner].add(penaltyAmt);
            }
        }
        
        _transferNftAndPaySeller(_nftContractAddress, _tokenId);
    }

    function withdrawSale(address _nftContractAddress, uint256 _tokenId)
        external
        nonReentrant
    {

        address nftSeller= nftContractSale[_nftContractAddress][_tokenId].nftSeller;
        require(nftSeller== msg.sender, "Only the owner can call this function");
        _resetSale(_nftContractAddress, _tokenId);
        IERC721(_nftContractAddress).transferFrom(
            address(this),
            nftSeller,
            _tokenId
        );
    }

    function withdrawAuction(address _nftContractAddress, uint256 _tokenId)
        external
        nonReentrant
        onlyNftSeller(_nftContractAddress, _tokenId)
    {

        address _nftRecipient= nftContractAuctions[_nftContractAddress][_tokenId].nftSeller;
        address prevNftHighestBidder = nftContractAuctions[_nftContractAddress][
            _tokenId
        ].nftHighestBidder;
        uint256 prevNftHighestBid = nftContractAuctions[_nftContractAddress][
            _tokenId
        ].nftHighestBid;

        _resetBids(_nftContractAddress, _tokenId);
        _resetAuction(_nftContractAddress, _tokenId);
        IERC721(_nftContractAddress).transferFrom(
            address(this),
            _nftRecipient,
            _tokenId
        );
        
        if (prevNftHighestBidder != address(0)) {
            _payout(
                _nftContractAddress,
                _tokenId,
                prevNftHighestBidder,
                prevNftHighestBid
            );
        }
    }

    function setSettlePenalty(uint256 _settlePenalty) external onlyOwner{

        settlePenalty= _settlePenalty;
    }

}