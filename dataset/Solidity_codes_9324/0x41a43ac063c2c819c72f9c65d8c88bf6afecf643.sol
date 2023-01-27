

pragma solidity 0.8.6;
pragma abicoder v2; // solhint-disable-line

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
}

abstract contract SendValueWithFallbackWithdraw is ReentrancyGuard {
  using Address for address payable;

  mapping(address => uint256) private pendingWithdrawals;

  event WithdrawPending(address indexed user, uint256 amount);
  event Withdrawal(address indexed user, uint256 amount);

  function getPendingWithdrawal(address user) public view returns (uint256) {
    return pendingWithdrawals[user];
  }

  function withdraw() public {
    withdrawFor(payable(msg.sender));
  }

  function withdrawFor(address payable user) public nonReentrant {
    uint256 amount = pendingWithdrawals[user];
    require(amount > 0, "No funds are pending withdrawal");
    pendingWithdrawals[user] = 0;
    user.sendValue(amount);
    emit Withdrawal(user, amount);
  }

  function _sendValueWithFallbackWithdrawWithLowGasLimit(address user, uint256 amount) internal {
    _sendValueWithFallbackWithdraw(user, amount, 20000);
  }

  function _sendValueWithFallbackWithdrawWithMediumGasLimit(address user, uint256 amount) internal {
    _sendValueWithFallbackWithdraw(user, amount, 210000);
  }

  function _sendValueWithFallbackWithdraw(
    address user,
    uint256 amount,
    uint256 gasLimit
  ) private {
    if (amount == 0) {
      return;
    }
    (bool success, ) = payable(user).call{ value: amount, gas: gasLimit }("");
    if (!success) {
      pendingWithdrawals[user] = pendingWithdrawals[user] + amount;
      emit WithdrawPending(user, amount);
    }
  }
}


interface ICAAsset {


  function ownerOf(uint256 _tokenId) external view returns (address _owner);

  function exists(uint256 _tokenId) external view returns (bool _exists);

  
  function transferFrom(address _from, address _to, uint256 _tokenId) external;

  function safeTransferFrom(address _from, address _to, uint256 _tokenId) external;

  function safeTransferFrom(address _from , address _to, uint256 _tokenId, bytes memory _data) external;


  function editionOfTokenId(uint256 _tokenId) external view returns (uint256 tokenId);


  function artistCommission(uint256 _tokenId) external view returns (address _artistAccount, uint256 _artistCommission);


  function editionOptionalCommission(uint256 _tokenId) external view returns (uint256 _rate, address _recipient);


  function mint(address _to, uint256 _editionNumber) external returns (uint256);


  function approve(address _to, uint256 _tokenId) external;




  function createActiveEdition(
    uint256 _editionNumber,
    bytes32 _editionData,
    uint256 _editionType,
    uint256 _startDate,
    uint256 _endDate,
    address _artistAccount,
    uint256 _artistCommission,
    uint256 _priceInWei,
    string memory _tokenUri,
    uint256 _totalAvailable
  ) external returns (bool);


  function artistsEditions(address _artistsAccount) external returns (uint256[] memory _editionNumbers);


  function totalAvailableEdition(uint256 _editionNumber) external returns (uint256);


  function highestEditionNumber() external returns (uint256);


  function updateOptionalCommission(uint256 _editionNumber, uint256 _rate, address _recipient) external;


  function updateStartDate(uint256 _editionNumber, uint256 _startDate) external;


  function updateEndDate(uint256 _editionNumber, uint256 _endDate) external;


  function updateEditionType(uint256 _editionNumber, uint256 _editionType) external;

}


abstract contract Constants {
  uint32 internal constant BASIS_POINTS = 10000;
}



abstract contract NFTMarketFees is
  Constants,
  SendValueWithFallbackWithdraw
{

  event MarketFeesUpdated(
    uint32 caPoints,
    uint32 artistPoints,
    uint32 sellerPoints,
    uint32 auctionAwardPoints,
    uint32 sharePoints
  );

  ICAAsset immutable caAsset;
  uint32 private caPoints;
  uint32 private sharePoints;
  uint32 private artistPoints;
  uint32 private sellerPoints;

  uint32 private auctionAwardPoints;
  
  uint256 public withdrawThreshold;

  address payable private treasury;


  mapping(address => uint256) public awards;

  mapping(uint256 => bool) private nftContractToTokenIdToFirstSaleCompleted;


  event AuctionAwardUpdated(uint256 indexed auctionId, address indexed bidder, uint256 award);
  event ShareAwardUpdated(address indexed share, uint256 award);

  constructor(
    ICAAsset _caAsset,
    address payable _treasury) {
    require(_treasury != address(0), "NFTMarketFees: Address not zero");
    caAsset = _caAsset;
    treasury = _treasury;

    caPoints = 150;
    sharePoints = 100;
    artistPoints = 1000;
    sellerPoints = 8250;
    auctionAwardPoints = 500;

    withdrawThreshold = 0.1 ether;
  }

  function setCATreasury(address payable _treasury) external {
    require(_treasury != msg.sender, "NFTMarketFees: no permission");
    require(_treasury != address(0), "NFTMarketFees: Address not zero");
    treasury = _treasury;
  }

  function getCATreasury() public view returns (address payable) {
    return treasury;
  }

  function getIsPrimary(uint256 tokenId) public view returns (bool) {
    return !nftContractToTokenIdToFirstSaleCompleted[tokenId];
  }

  function getArtist(uint256 tokenId) public view returns (address artist) {
      uint256 editionNumber = caAsset.editionOfTokenId(tokenId);
      (artist,) = caAsset.artistCommission(editionNumber);
  }


  function getFees(uint tokenId, uint256 price)
    public
    view
    returns (
      uint256 caFee,
      uint256 artistFee,
      uint256 sellerFee,
      uint256 auctionFee,
      uint256 shareFee
    )
  {
    sellerFee = sellerPoints * price / BASIS_POINTS;
    if (!nftContractToTokenIdToFirstSaleCompleted[tokenId]) {
        caFee = (caPoints + artistPoints) * price / BASIS_POINTS;
        artistFee = sellerFee;
        sellerFee = 0;
    } else {
        caFee = caPoints * price / BASIS_POINTS;
        artistFee = artistPoints * price / BASIS_POINTS;
    }

    auctionFee = auctionAwardPoints * price / BASIS_POINTS;
    shareFee = sharePoints * price / BASIS_POINTS;
  }

  function withdrawFunds(address to) external {
    require(awards[msg.sender] >= withdrawThreshold, "NFTMarketFees: under withdrawThreshold");
    uint wdAmount= awards[msg.sender];
    awards[msg.sender] = 0;
    _sendValueWithFallbackWithdrawWithMediumGasLimit(to, wdAmount);
  }

  function _distributeBidFunds(
      uint256 lastPrice,
      uint256 auctionId,
      uint256 price,
      address bidder
  ) internal {
      uint award = auctionAwardPoints * (price - lastPrice) / BASIS_POINTS;
      awards[bidder] += award;

      emit AuctionAwardUpdated(auctionId, bidder, award);
  }

  function _distributeFunds(
    uint256 tokenId,
    address seller,
    address shareUser,
    uint256 price
  ) internal {
    (uint caFee, uint artistFee, uint sellerFee, ,uint shareFee) = getFees(tokenId, price);
    
    if (shareUser == address(0)) {
      _sendValueWithFallbackWithdrawWithLowGasLimit(treasury, caFee + shareFee);
    } else {
      _sendValueWithFallbackWithdrawWithLowGasLimit(treasury, caFee);
      awards[shareUser] += shareFee;

      emit ShareAwardUpdated(shareUser, shareFee);
    }

      uint256 editionNumber = caAsset.editionOfTokenId(tokenId);
      (address artist, uint256 artistRate) = caAsset.artistCommission(editionNumber);
      (uint256 optionalRate, address optionalRecipient) = caAsset.editionOptionalCommission(editionNumber);
    
      if (optionalRecipient == address(0)) { 
        if (artist == seller) {
          _sendValueWithFallbackWithdrawWithMediumGasLimit(seller, artistFee + sellerFee);
        } else {
          _sendValueWithFallbackWithdrawWithMediumGasLimit(seller, sellerFee);
          _sendValueWithFallbackWithdrawWithMediumGasLimit(artist, artistFee);
        }
      } else {
        uint optionalFee = artistFee * optionalRate / (optionalRate + artistRate);
        if (optionalFee > 0) {
          _sendValueWithFallbackWithdrawWithMediumGasLimit(optionalRecipient, optionalFee);
        }

        if (artist == seller) {
          _sendValueWithFallbackWithdrawWithMediumGasLimit(seller, artistFee + sellerFee - optionalFee);
        } else {
          _sendValueWithFallbackWithdrawWithMediumGasLimit(seller, sellerFee);
          _sendValueWithFallbackWithdrawWithMediumGasLimit(artist, artistFee - optionalFee);
        }
      }

    nftContractToTokenIdToFirstSaleCompleted[tokenId] = true;
  }


  function getFeeConfig()
    public
    view
    returns (
      uint32 ,
      uint32 ,
      uint32 ,
      uint32 ,
      uint32) {
    return (caPoints, artistPoints, sellerPoints, auctionAwardPoints, sharePoints);
  }

  function _updateWithdrawThreshold(uint256 _withdrawalThreshold) internal {
    withdrawThreshold = _withdrawalThreshold;
  }

  function _updateMarketFees(
    uint32 _caPoints,
    uint32 _artistPoints,
    uint32 _sellerPoints,
    uint32 _auctionAwardPoints,
    uint32 _sharePoints
  ) internal {
    require(_caPoints + _artistPoints + _sellerPoints + _auctionAwardPoints + _sharePoints < BASIS_POINTS, "NFTMarketFees: Fees >= 100%");

    caPoints = caPoints;
    artistPoints = _artistPoints;
    sellerPoints = _sellerPoints;
    auctionAwardPoints = _auctionAwardPoints;
    sharePoints = _sharePoints;

    emit MarketFeesUpdated(
      _caPoints,
      _artistPoints,
      _sellerPoints,
      _auctionAwardPoints,
      _sharePoints
    );
  }

}


abstract contract NFTMarketAuction {
  uint256 private nextAuctionId = 1;


  function _getNextAndIncrementAuctionId() internal returns (uint256) {
    return nextAuctionId++;
  }

}


interface IAccessControl {


  function isCAAdmin(address _operator) external view returns (bool);

  function hasRole(address _operator, uint8 _role) external view returns (bool);

  function canPlayRole(address _operator, uint8 _role) external view returns (bool);

}




abstract contract NFTMarketReserveAuction is
  Constants,
  ReentrancyGuard,
  SendValueWithFallbackWithdraw,
  NFTMarketFees,
  NFTMarketAuction
{

  struct ReserveAuction {
    uint256 tokenId;
    address seller;
    uint32 duration;
    uint32 extensionDuration;
    uint32 endTime;
    address bidder;
    uint256 amount;
    address shareUser;
  }

  mapping(uint256 => uint256) private nftTokenIdToAuctionId;
  mapping(uint256 => ReserveAuction) private auctionIdToAuction;

  IAccessControl public immutable accessControl;

  uint32 private _minPercentIncrementInBasisPoints;

  uint32 private _duration;

  uint32 private constant MAX_MAX_DURATION = 1000 days;

  uint32 private constant EXTENSION_DURATION = 15 minutes;

  event ReserveAuctionConfigUpdated(
    uint32 minPercentIncrementInBasisPoints,
    uint256 maxBidIncrementRequirement,
    uint256 duration,
    uint256 extensionDuration,
    uint256 goLiveDate
  );

  event ReserveAuctionCreated(
    address indexed seller,
    uint256 indexed tokenId,
    uint256 indexed auctionId,
    uint256 duration,
    uint256 extensionDuration,
    uint256 reservePrice
    
  );
  event ReserveAuctionUpdated(uint256 indexed auctionId, uint256 reservePrice);
  event ReserveAuctionCanceled(uint256 indexed auctionId);
  event ReserveAuctionBidPlaced(uint256 indexed auctionId, address indexed bidder, uint256 amount, uint256 endTime);
  event ReserveAuctionFinalized(
    uint256 indexed auctionId,
    address indexed seller,
    address indexed bidder,
    uint256 tokenId,
    uint256 amount
  );
  event ReserveAuctionCanceledByAdmin(uint256 indexed auctionId, string reason);
  event ReserveAuctionSellerMigrated(
    uint256 indexed auctionId,
    address indexed originalSellerAddress,
    address indexed newSellerAddress
  );

  modifier onlyValidAuctionConfig(uint256 reservePrice) {
    require(reservePrice > 0, "NFTMarketReserveAuction: Reserve price must be at least 1 wei");
    _;
  }

  modifier onlyCAAdmin(address user) {
    require(accessControl.isCAAdmin(user), "CAAdminRole: caller does not have the Admin role");
    _;
  }

  constructor(IAccessControl access) {
    _duration = 24 hours; // A sensible default value
    accessControl = access;
    _minPercentIncrementInBasisPoints = 1000;
  }

  function getReserveAuction(uint256 auctionId) public view returns (ReserveAuction memory) {
    return auctionIdToAuction[auctionId];
  }

  function getReserveAuctionIdFor(uint256 tokenId) public view returns (uint256) {
    return nftTokenIdToAuctionId[tokenId];
  }

  function getSellerFor(uint256 tokenId)
    internal
    view
    virtual
    returns (address)
  {
    address seller = auctionIdToAuction[nftTokenIdToAuctionId[tokenId]].seller;
    if (seller == address(0)) {
      return caAsset.ownerOf(tokenId);
    }
    return seller;
  }

  function getReserveAuctionConfig() public view returns (uint256 minPercentIncrementInBasisPoints, uint256 duration) {
    minPercentIncrementInBasisPoints = _minPercentIncrementInBasisPoints;
    duration = _duration;
  }



  function _updateReserveAuctionConfig(uint32 minPercentIncrementInBasisPoints, uint32 duration) internal {
    require(minPercentIncrementInBasisPoints <= BASIS_POINTS, "NFTMarketReserveAuction: Min increment must be <= 100%");
    require(duration <= MAX_MAX_DURATION, "NFTMarketReserveAuction: Duration must be <= 1000 days");
    require(duration >= EXTENSION_DURATION, "NFTMarketReserveAuction: Duration must be >= EXTENSION_DURATION");
    _minPercentIncrementInBasisPoints = minPercentIncrementInBasisPoints;
    _duration = duration;

    emit ReserveAuctionConfigUpdated(minPercentIncrementInBasisPoints, 0, duration, EXTENSION_DURATION, 0);
  }

  function createReserveAuction(
    uint256 tokenId,
    address seller,
    uint256 reservePrice
  ) public onlyValidAuctionConfig(reservePrice) nonReentrant {
    
    uint256 auctionId = _getNextAndIncrementAuctionId();
    nftTokenIdToAuctionId[tokenId] = auctionId;
    auctionIdToAuction[auctionId] = ReserveAuction(
      tokenId,
      seller,
      _duration,
      EXTENSION_DURATION,
      0, // endTime is only known once the reserve price is met
      address(0), // bidder is only known once a bid has been placed
      reservePrice,
      address(0)
    );

    caAsset.transferFrom(msg.sender, address(this), tokenId);

    emit ReserveAuctionCreated(
      seller,
      tokenId,
      auctionId,
      _duration,
      EXTENSION_DURATION,
      reservePrice
    );
  }

  function updateReserveAuction(uint256 auctionId, uint256 reservePrice) public onlyValidAuctionConfig(reservePrice) {
    ReserveAuction storage auction = auctionIdToAuction[auctionId];
    require(auction.seller == msg.sender, "NFTMarketReserveAuction: Not your auction");
    require(auction.endTime == 0, "NFTMarketReserveAuction: Auction in progress");

    auction.amount = reservePrice;

    emit ReserveAuctionUpdated(auctionId, reservePrice);
  }

  function cancelReserveAuction(uint256 auctionId) public nonReentrant {
    ReserveAuction memory auction = auctionIdToAuction[auctionId];
    require(auction.seller == msg.sender, "NFTMarketReserveAuction: Not your auction");
    require(auction.endTime == 0, "NFTMarketReserveAuction: Auction in progress");

    delete nftTokenIdToAuctionId[auction.tokenId];
    delete auctionIdToAuction[auctionId];

    caAsset.transferFrom(address(this), auction.seller, auction.tokenId);

    emit ReserveAuctionCanceled(auctionId);
  }

  function placeBid(uint256 auctionId, address shareUser) public payable nonReentrant {
    ReserveAuction storage auction = auctionIdToAuction[auctionId];
    require(auction.amount != 0, "NFTMarketReserveAuction: Auction not found");

    if (auction.endTime == 0) {
      require(auction.amount <= msg.value, "NFTMarketReserveAuction: Bid must be at least the reserve price");
    } else {
      require(auction.endTime >= block.timestamp, "NFTMarketReserveAuction: Auction is over");
      require(auction.bidder != msg.sender, "NFTMarketReserveAuction: You already have an outstanding bid");
      uint256 minAmount = _getMinBidAmountForReserveAuction(auction.amount);
      require(msg.value >= minAmount, "NFTMarketReserveAuction: Bid amount too low");
    }

    if (auction.endTime == 0) {
      auction.amount = msg.value;
      auction.bidder = msg.sender;
      auction.endTime = uint32(block.timestamp) + auction.duration;
      auction.shareUser = shareUser;

      _distributeBidFunds(0, auctionId, msg.value, msg.sender);
    } else {
      uint256 originalAmount = auction.amount;
      address originalBidder = auction.bidder;
      auction.amount = msg.value;
      auction.bidder = msg.sender;
      auction.shareUser = shareUser;

      if (auction.endTime - uint32(block.timestamp) < auction.extensionDuration) {
        auction.endTime = uint32(block.timestamp) + auction.extensionDuration;
      }
      
      _distributeBidFunds(originalAmount, auctionId, msg.value, msg.sender);

      _sendValueWithFallbackWithdrawWithLowGasLimit(originalBidder, originalAmount);
    }

    emit ReserveAuctionBidPlaced(auctionId, msg.sender, msg.value, auction.endTime);
  }

  function finalizeReserveAuction(uint256 auctionId) public nonReentrant {
    ReserveAuction memory auction = auctionIdToAuction[auctionId];
    require(auction.endTime > 0, "NFTMarketReserveAuction: Auction was already settled");
    require(auction.endTime < uint32(block.timestamp), "NFTMarketReserveAuction: Auction still in progress");

    delete nftTokenIdToAuctionId[auction.tokenId];
    delete auctionIdToAuction[auctionId];

    caAsset.transferFrom(address(this), auction.bidder, auction.tokenId);

    _distributeFunds(auction.tokenId, auction.seller, auction.shareUser, auction.amount);

    emit ReserveAuctionFinalized(auctionId, auction.seller, auction.bidder, auction.tokenId, auction.amount);
  }


  function getMinBidAmount(uint256 auctionId) public view returns (uint256) {
    ReserveAuction storage auction = auctionIdToAuction[auctionId];
    if (auction.endTime == 0) {
      return auction.amount;
    }
    return _getMinBidAmountForReserveAuction(auction.amount);
  }

  function _getMinBidAmountForReserveAuction(uint256 currentBidAmount) private view returns (uint256) {
    uint256 minIncrement = currentBidAmount * _minPercentIncrementInBasisPoints / BASIS_POINTS;
    if (minIncrement == 0) {
      return currentBidAmount + 1;
    }
    return minIncrement + currentBidAmount;
  }

  function adminCancelReserveAuction(uint256 auctionId, string memory reason) public onlyCAAdmin(msg.sender) {
    require(bytes(reason).length > 0, "NFTMarketReserveAuction: Include a reason for this cancellation");
    ReserveAuction memory auction = auctionIdToAuction[auctionId];
    require(auction.amount > 0, "NFTMarketReserveAuction: Auction not found");

    delete nftTokenIdToAuctionId[auction.tokenId];
    delete auctionIdToAuction[auctionId];

    caAsset.transferFrom(address(this), auction.seller, auction.tokenId);
    if (auction.bidder != address(0)) {
      _sendValueWithFallbackWithdrawWithMediumGasLimit(auction.bidder, auction.amount);
    }

    emit ReserveAuctionCanceledByAdmin(auctionId, reason);
  }
}


contract CANFTMarket is
  ReentrancyGuard,
  SendValueWithFallbackWithdraw,
  NFTMarketFees,
  NFTMarketAuction,
  NFTMarketReserveAuction
{

  constructor (IAccessControl access,
    ICAAsset caAsset,
    address payable treasury)
    NFTMarketFees(caAsset, treasury)
    NFTMarketReserveAuction(access) {
  }


  function adminUpdateConfig(
    uint32 minPercentIncrementInBasisPoints,
    uint32 duration,
    uint32 _caPoints,
    uint32 _artistPoints,
    uint32 _sellerPoints,
    uint32 _auctionAwardPoints,
    uint32 _sharePoints
  ) public onlyCAAdmin(msg.sender) {

    _updateReserveAuctionConfig(minPercentIncrementInBasisPoints, duration);
    _updateMarketFees(_caPoints, _artistPoints, _sellerPoints, _auctionAwardPoints, _sharePoints);
  }

  function adminUpdateWithdrawThreshold(uint256 _withdrawalThreshold) public onlyCAAdmin(msg.sender) {

    _updateWithdrawThreshold(_withdrawalThreshold);
  }

  function withdrawStuckEther(address _withdrawalAccount) onlyCAAdmin(msg.sender) public {

    require(_withdrawalAccount != address(0), "Invalid address provided");
    payable(_withdrawalAccount).transfer(address(this).balance);
  }

}