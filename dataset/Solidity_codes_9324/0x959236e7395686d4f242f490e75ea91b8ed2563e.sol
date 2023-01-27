

pragma solidity ^0.4.24;

interface ERC721 {


  event Transfer(
    address indexed _from,
    address indexed _to,
    uint256 indexed _tokenId
  );

  event Approval(
    address indexed _owner,
    address indexed _approved,
    uint256 indexed _tokenId
  );

  event ApprovalForAll(
    address indexed _owner,
    address indexed _operator,
    bool _approved
  );

  function balanceOf(
    address _owner
  )
    external
    view
    returns (uint256);


  function ownerOf(
    uint256 _tokenId
  )
    external
    view
    returns (address);


  function safeTransferFrom(
    address _from,
    address _to,
    uint256 _tokenId,
    bytes _data
  )
    external;


  function safeTransferFrom(
    address _from,
    address _to,
    uint256 _tokenId
  )
    external;


  function transferFrom(
    address _from,
    address _to,
    uint256 _tokenId
  )
    external;


  function approve(
    address _approved,
    uint256 _tokenId
  )
    external;


  function setApprovalForAll(
    address _operator,
    bool _approved
  )
    external;


  function getApproved(
    uint256 _tokenId
  )
    external
    view
    returns (address);


  function isApprovedForAll(
    address _owner,
    address _operator
  )
    external
    view
    returns (bool);


}


pragma solidity ^0.4.24;

interface ERC165 {


  function supportsInterface(
    bytes4 _interfaceID
  )
    external
    view
    returns (bool);


}


pragma solidity ^0.4.24;

library SafeMath {


  function mul(
    uint256 _a,
    uint256 _b
  )
    internal
    pure
    returns (uint256)
  {

    if (_a == 0) {
      return 0;
    }
    uint256 c = _a * _b;
    assert(c / _a == _b);
    return c;
  }

  function div(
    uint256 _a,
    uint256 _b
  )
    internal
    pure
    returns (uint256)
  {

    uint256 c = _a / _b;
    return c;
  }

  function sub(
    uint256 _a,
    uint256 _b
  )
    internal
    pure
    returns (uint256)
  {

    assert(_b <= _a);
    return _a - _b;
  }

  function add(
    uint256 _a,
    uint256 _b
  )
    internal
    pure
    returns (uint256)
  {

    uint256 c = _a + _b;
    assert(c >= _a);
    return c;
  }

}


pragma solidity ^0.4.24;


contract SupportsInterface is
  ERC165
{


  mapping(bytes4 => bool) internal supportedInterfaces;

  constructor()
    public
  {
    supportedInterfaces[0x01ffc9a7] = true; // ERC165
  }

  function supportsInterface(
    bytes4 _interfaceID
  )
    external
    view
    returns (bool)
  {

    return supportedInterfaces[_interfaceID];
  }

}


pragma solidity ^0.4.24;

library AddressUtils {


  function isContract(
    address _addr
  )
    internal
    view
    returns (bool)
  {

    uint256 size;

    assembly { size := extcodesize(_addr) } // solium-disable-line security/no-inline-assembly
    return size > 0;
  }

}


pragma solidity ^0.4.24;





contract DutchAuctionBase is
  SupportsInterface
{


  using SafeMath for uint128;
  using SafeMath for uint256;
  using AddressUtils for address;

  struct Auction {
      address seller;

      uint128 startingPrice;

      uint128 endingPrice;

      uint64 duration;

      uint256 startedAt;

      bool delayedCancel;

  }

  uint16 public auctioneerCut;

  uint16 public auctioneerDelayedCancelCut;

  ERC721 public nftContract;

  mapping (uint256 => Auction) public tokenIdToAuction;

  event AuctionCreated(uint256 tokenId, address seller, uint256 startingPrice, uint256 endingPrice, uint256 duration, bool delayedCancel);
  event AuctionSuccessful(uint256 tokenId, uint256 totalPrice, address winner);
  event AuctionCancelled(uint256 tokenId);

  function _addAuction(uint256 _tokenId, Auction _auction) internal {

    require(_auction.duration >= 1 minutes);

    tokenIdToAuction[_tokenId] = _auction;

    emit AuctionCreated(
        _tokenId,
        _auction.seller,
        uint256(_auction.startingPrice),
        uint256(_auction.endingPrice),
        uint256(_auction.duration),
        _auction.delayedCancel
    );
  }

  function _cancelAuction(uint256 _tokenId) internal {

    Auction storage auction = tokenIdToAuction[_tokenId];
    address _seller = auction.seller;
    _removeAuction(_tokenId);

    nftContract.transferFrom(address(this), _seller, _tokenId);
    emit AuctionCancelled(_tokenId);
  }

  function _bid(uint256 _tokenId, uint256 _offer)
      internal
  {

      Auction storage auction = tokenIdToAuction[_tokenId];
      require(_isOnAuction(auction), "Can not place bid. NFT is not on auction!");

      uint256 price = _currentPrice(auction);
      require(_offer >= price, "Bid amount has to be higher or equal than current price!");

      address seller = auction.seller;

      bool isCancelDelayed = auction.delayedCancel;

      _removeAuction(_tokenId);

      if (price > 0) {
          uint256 computedCut = _computeCut(price, isCancelDelayed);
          uint256 sellerRevenue = price.sub(computedCut);

          seller.transfer(sellerRevenue);
      }

      uint256 bidExcess = _offer.sub(price);

      msg.sender.transfer(bidExcess);

      emit AuctionSuccessful(_tokenId, price, msg.sender);
  }

  function _isOnAuction(Auction storage _auction)
    internal
    view
    returns (bool)
  {

      return (_auction.seller != address(0));
  }

  function _durationIsOver(Auction storage _auction)
    internal
    view
    returns (bool)
  {

      uint256 secondsPassed = 0;
      secondsPassed = now.sub(_auction.startedAt);

      return (secondsPassed >= _auction.duration);
  }

  function _currentPrice(Auction storage _auction)
    internal
    view
    returns (uint256)
  {

    uint256 secondsPassed = 0;

    if (now > _auction.startedAt) {
        secondsPassed = now.sub(_auction.startedAt);
    }

    if (secondsPassed >= _auction.duration) {
        return _auction.endingPrice;
    } else {
        int256 totalPriceChange = int256(_auction.endingPrice) - int256(_auction.startingPrice);
        int256 currentPriceChange = totalPriceChange * int256(secondsPassed) / int256(_auction.duration);
        int256 currentPrice = int256(_auction.startingPrice) + currentPriceChange;

        return uint256(currentPrice);
    }
  }

  function _computeCut(uint256 _price, bool _isCancelDelayed)
    internal
    view
    returns (uint256)
  {


      if (_isCancelDelayed) {
        return _price * auctioneerDelayedCancelCut / 10000;
      }

      return _price * auctioneerCut / 10000;
  }

   function _removeAuction(uint256 _tokenId)
     internal
   {

     delete tokenIdToAuction[_tokenId];
   }
}


pragma solidity ^0.4.24;


contract DutchAuctionEnumerable
  is DutchAuctionBase
{


  uint256[] public tokens;

  mapping(uint256 => uint256) public tokenToIndex;

  mapping(address => uint256[]) public sellerToTokens;

  mapping(uint256 => uint256) public tokenToSellerIndex;

  function _addAuction(uint256 _token, Auction _auction)
    internal
  {

    super._addAuction(_token, _auction);

    uint256 length = tokens.push(_token);
    tokenToIndex[_token] = length - 1;

    length = sellerToTokens[_auction.seller].push(_token);
    tokenToSellerIndex[_token] = length - 1;
  }

  function _removeAuction(uint256 _token)
    internal
  {

    assert(tokens.length > 0);

    Auction memory auction = tokenIdToAuction[_token];
    assert(auction.seller != address(0));
    assert(sellerToTokens[auction.seller].length > 0);

    uint256 sellersIndexOfTokenToRemove = tokenToSellerIndex[_token];

    uint256 lastSellersTokenIndex = sellerToTokens[auction.seller].length - 1;
    uint256 lastSellerToken = sellerToTokens[auction.seller][lastSellersTokenIndex];

    sellerToTokens[auction.seller][sellersIndexOfTokenToRemove] = lastSellerToken;
    sellerToTokens[auction.seller].length--;

    tokenToSellerIndex[lastSellerToken] = sellersIndexOfTokenToRemove;
    tokenToSellerIndex[_token] = 0;

    uint256 tokenIndex = tokenToIndex[_token];
    assert(tokens[tokenIndex] == _token);

    uint256 lastTokenIndex = tokens.length - 1;
    uint256 lastToken = tokens[lastTokenIndex];

    tokens[tokenIndex] = lastToken;
    tokens.length--;

    tokenToIndex[lastToken] = tokenIndex;
    tokenToIndex[_token] = 0;

    super._removeAuction(_token);
  }


  function totalAuctions()
    external
    view
    returns (uint256)
  {

    return tokens.length;
  }

  function tokenInAuctionByIndex(
    uint256 _index
  )
    external
    view
    returns (uint256)
  {

    require(_index < tokens.length);
    assert(tokenToIndex[tokens[_index]] == _index);
    return tokens[_index];
  }

  function tokenOfSellerByIndex(
    address _seller,
    uint256 _index
  )
    external
    view
    returns (uint256)
  {

    require(_index < sellerToTokens[_seller].length);
    return sellerToTokens[_seller][_index];
  }

  function totalAuctionsBySeller(
    address _seller
  )
    external
    view
    returns (uint256)
  {

    return sellerToTokens[_seller].length;
  }
}


pragma solidity ^0.4.24;

interface MarbleNFTInterface {


  function mint(
    uint256 _tokenId,
    address _owner,
    address _creator,
    string _uri,
    string _metadataUri,
    uint256 _created
  )
    external;


  function burn(
    uint256 _tokenId
  )
    external;


  function forceApproval(
    uint256 _tokenId,
    address _approved
  )
    external;


  function tokenSource(uint256 _tokenId)
    external
    view
    returns (
      string uri,
      address creator,
      uint256 created
    );


  function tokenBySourceUri(string _uri)
    external
    view
    returns (uint256 tokenId);


  function getNFT(uint256 _tokenId)
    external
    view
    returns(
      uint256 id,
      string uri,
      string metadataUri,
      address owner,
      address creator,
      uint256 created
    );



    function getSourceUriHash(string _uri)
      external
      view
      returns(uint256 hash);

}


pragma solidity ^0.4.24;

contract Ownable {

  address public owner;

  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );

  constructor()
    public
  {
    owner = msg.sender;
  }

  modifier onlyOwner() {

    require(msg.sender == owner);
    _;
  }

  function transferOwnership(
    address _newOwner
  )
    onlyOwner
    public
  {

    require(_newOwner != address(0));
    emit OwnershipTransferred(owner, _newOwner);
    owner = _newOwner;
  }

}


pragma solidity ^0.4.24;


contract Claimable is Ownable {

  address public pendingOwner;

  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );

  function transferOwnership(
    address _newOwner
  )
    onlyOwner
    public
  {

    pendingOwner = _newOwner;
  }

  function claimOwnership()
    public
  {

    require(msg.sender == pendingOwner);
    address previousOwner = owner;
    owner = pendingOwner;
    pendingOwner = 0;
    emit OwnershipTransferred(previousOwner, owner);
  }
}


pragma solidity ^0.4.24;


contract Adminable is Claimable {

  mapping(address => uint) public adminsMap;
  address[] public adminList;

  function isAdmin(address adminAddress)
    public
    view
    returns(bool isIndeed)
  {

    if (adminAddress == owner) return true;

    if (adminList.length == 0) return false;
    return (adminList[adminsMap[adminAddress]] == adminAddress);
  }

  function addAdmin(address adminAddress)
    public
    onlyOwner
    returns(uint index)
  {

    require(!isAdmin(adminAddress), "Address already has admin rights!");

    adminsMap[adminAddress] = adminList.push(adminAddress)-1;

    return adminList.length-1;
  }

  function removeAdmin(address adminAddress)
    public
    onlyOwner
    returns(uint index)
  {

    require(owner != adminAddress, "Owner can not be removed from admin role!");
    require(isAdmin(adminAddress), "Provided address is not admin.");

    uint rowToDelete = adminsMap[adminAddress];
    address keyToMove = adminList[adminList.length-1];
    adminList[rowToDelete] = keyToMove;
    adminsMap[keyToMove] = rowToDelete;
    adminList.length--;

    return rowToDelete;
  }

  modifier onlyAdmin() {

    require(isAdmin(msg.sender), "Can be executed only by admin accounts!");
    _;
  }
}


pragma solidity ^0.4.24;



contract Priceable is Claimable {


  using SafeMath for uint256;

  event Withdraw(uint256 balance);

  modifier minimalPrice(uint256 _minimalAmount) {

    require(msg.value >= _minimalAmount, "Not enough Ether provided.");
    _;
  }

  modifier price(uint256 _amount) {

    require(msg.value >= _amount, "Not enough Ether provided.");
    _;
    if (msg.value > _amount) {
      msg.sender.transfer(msg.value.sub(_amount));
    }
  }

  function withdrawBalance()
    external
    onlyOwner
  {

    uint256 balance = address(this).balance;
    msg.sender.transfer(balance);

    emit Withdraw(balance);
  }

  function () public payable {}
}


pragma solidity ^0.4.24;


contract Pausable is Ownable {

  event Pause();
  event Unpause();

  bool public paused = false;


  modifier whenNotPaused() {

    require(!paused);
    _;
  }

  modifier whenPaused {

    require(paused);
    _;
  }

  function pause()
    external
    onlyOwner
    whenNotPaused
    returns (bool)
  {

    paused = true;
    emit Pause();
    return true;
  }

  function unpause()
    external
    onlyOwner
    whenPaused
    returns (bool)
  {

    paused = false;
    emit Unpause();
    return true;
  }
}


pragma solidity ^0.4.24;

interface MarbleDutchAuctionInterface {


  function setAuctioneerCut(
    uint256 _cut
  )
   external;


  function setAuctioneerDelayedCancelCut(
    uint256 _cut
  )
   external;


  function setNFTContract(address _nftAddress)
    external;



  function createAuction(
    uint256 _tokenId,
    uint256 _startingPrice,
    uint256 _endingPrice,
    uint256 _duration
  )
    external;


  function createMintingAuction(
    uint256 _tokenId,
    uint256 _startingPrice,
    uint256 _endingPrice,
    uint256 _duration,
    address _seller
  )
    external;


  function cancelAuction(
    uint256 _tokenId
  )
    external;


  function cancelAuctionWhenPaused(
    uint256 _tokenId
  )
    external;


  function bid(
    uint256 _tokenId
  )
    external
    payable;


  function getCurrentPrice(uint256 _tokenId)
    external
    view
    returns (uint256);


  function totalAuctions()
    external
    view
    returns (uint256);


  function tokenInAuctionByIndex(
    uint256 _index
  )
    external
    view
    returns (uint256);


  function tokenOfSellerByIndex(
    address _seller,
    uint256 _index
  )
    external
    view
    returns (uint256);


  function totalAuctionsBySeller(
    address _seller
  )
    external
    view
    returns (uint256);


  function isOnAuction(uint256 _tokenId)
    external
    view
    returns (bool isIndeed);


  function getAuction(uint256 _tokenId)
    external
    view
    returns
  (
    address seller,
    uint256 startingPrice,
    uint256 endingPrice,
    uint256 duration,
    uint256 startedAt,
    bool canBeCanceled
  );


  function removeAuction(
    uint256 _tokenId
  )
    external;

}


pragma solidity ^0.4.24;









contract MarbleDutchAuction is
  MarbleDutchAuctionInterface,
  Priceable,
  Adminable,
  Pausable,
  DutchAuctionEnumerable
{


  bytes4 constant InterfaceSignature_ERC721 = 0x80ac58cd;

  event AuctioneerCutChanged(uint256 _auctioneerCut);

  event AuctioneerDelayedCancelCutChanged(uint256 _auctioneerDelayedCancelCut);

  event AuctionRemoved(uint256 _tokenId);

  function _createAuction(
      uint256 _tokenId,
      uint256 _startingPrice,
      uint256 _endingPrice,
      uint256 _duration,
      bool _delayedCancel,
      address _seller
  )
      internal
      whenNotPaused
  {

      MarbleNFTInterface marbleNFT = MarbleNFTInterface(address(nftContract));

      require(_startingPrice == uint256(uint128(_startingPrice)), "Starting price is too high!");
      require(_endingPrice == uint256(uint128(_endingPrice)), "Ending price is too high!");
      require(_duration == uint256(uint64(_duration)), "Duration exceeds allowed limit!");

      marbleNFT.forceApproval(_tokenId, address(this));

      nftContract.transferFrom(_seller, address(this), _tokenId);

      Auction memory auction = Auction(
        _seller,
        uint128(_startingPrice),
        uint128(_endingPrice),
        uint64(_duration),
        uint256(now),
        bool(_delayedCancel)
      );

      _addAuction(_tokenId, auction);
  }

  function setAuctioneerCut(uint256 _cut)
    external
    onlyAdmin
  {

    require(_cut <= 10000, "Cut should be in interval of 0-10000");
    auctioneerCut = uint16(_cut);

    emit AuctioneerCutChanged(auctioneerCut);
  }

  function setAuctioneerDelayedCancelCut(uint256 _cut)
    external
    onlyAdmin
  {

    require(_cut <= 10000, "Delayed cut should be in interval of 0-10000");
    auctioneerDelayedCancelCut = uint16(_cut);

    emit AuctioneerDelayedCancelCutChanged(auctioneerDelayedCancelCut);
  }

  function setNFTContract(address _nftAddress)
    external
    onlyAdmin
  {

    ERC165 nftContractToCheck = ERC165(_nftAddress);
    require(nftContractToCheck.supportsInterface(InterfaceSignature_ERC721)); // ERC721 == 0x80ac58cd
    nftContract = ERC721(_nftAddress);
  }

  function createMintingAuction(
      uint256 _tokenId,
      uint256 _startingPrice,
      uint256 _endingPrice,
      uint256 _duration,
      address _seller
  )
      external
      whenNotPaused
      onlyAdmin
  {


      _createAuction(
        _tokenId,
        _startingPrice,
        _endingPrice,
        _duration,
        true, // seller can NOT cancel auction only after time is up! and bidders can be just over duration
        _seller
      );
  }

  function createAuction(
      uint256 _tokenId,
      uint256 _startingPrice,
      uint256 _endingPrice,
      uint256 _duration
  )
      external
      whenNotPaused
  {

      require(nftContract.ownerOf(_tokenId) == msg.sender, "Only owner of the token can create auction!");
      _createAuction(
        _tokenId,
        _startingPrice,
        _endingPrice,
        _duration,
        false, // seller can cancel auction any time
        msg.sender
      );
  }

  function bid(uint256 _tokenId)
      external
      payable
      whenNotPaused
  {

    Auction storage auction = tokenIdToAuction[_tokenId];
    require(_isOnAuction(auction), "NFT is not on this auction!");
    require(!auction.delayedCancel || !_durationIsOver(auction), "You can not bid on this auction, because it has delayed cancel policy actived and after times up it belongs once again to seller!");

    _bid(_tokenId, msg.value);

    nftContract.transferFrom(address(this), msg.sender, _tokenId);
  }

  function cancelAuction(uint256 _tokenId)
    external
    whenNotPaused
  {

      Auction storage auction = tokenIdToAuction[_tokenId];
      require(_isOnAuction(auction), "NFT is not auctioned over our contract!");
      require((!auction.delayedCancel || _durationIsOver(auction)) && msg.sender == auction.seller, "You have no rights to cancel this auction!");

      _cancelAuction(_tokenId);
  }

  function cancelAuctionWhenPaused(uint256 _tokenId)
    external
    whenPaused
    onlyAdmin
  {

      Auction storage auction = tokenIdToAuction[_tokenId];
      require(_isOnAuction(auction), "NFT is not auctioned over our contract!");
      _cancelAuction(_tokenId);
  }

  function isOnAuction(uint256 _tokenId)
    external
    view
    returns (bool isIndeed)
  {

    Auction storage auction = tokenIdToAuction[_tokenId];
    return _isOnAuction(auction);
  }

  function getAuction(uint256 _tokenId)
    external
    view
    returns
  (
    address seller,
    uint256 startingPrice,
    uint256 endingPrice,
    uint256 duration,
    uint256 startedAt,
    bool delayedCancel
  ) {

      Auction storage auction = tokenIdToAuction[_tokenId];
      require(_isOnAuction(auction), "NFT is not auctioned over our contract!");

      return (
          auction.seller,
          auction.startingPrice,
          auction.endingPrice,
          auction.duration,
          auction.startedAt,
          auction.delayedCancel
      );
  }

  function getCurrentPrice(uint256 _tokenId)
      external
      view
      returns (uint256)
  {

      Auction storage auction = tokenIdToAuction[_tokenId];
      require(_isOnAuction(auction), "NFT is not auctioned over our contract!");
      return _currentPrice(auction);

  }

  function removeAuction(
    uint256 _tokenId
  )
    external
    whenPaused
    onlyAdmin
  {

    _removeAuction(_tokenId);

    emit AuctionRemoved(_tokenId);
  }
}