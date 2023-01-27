


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
}


pragma solidity >=0.6.0 <0.8.0;

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}


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

}

pragma solidity >=0.6.0 <0.8.0;

interface IERC721Receiver {

    function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data) external returns (bytes4);

}

pragma solidity 0.7.4;


interface IERC1155 {



  event TransferSingle(address indexed _operator, address indexed _from, address indexed _to, uint256 _id, uint256 _amount);

  event TransferBatch(address indexed _operator, address indexed _from, address indexed _to, uint256[] _ids, uint256[] _amounts);

  event ApprovalForAll(address indexed _owner, address indexed _operator, bool _approved);



  function safeTransferFrom(address _from, address _to, uint256 _id, uint256 _amount, bytes calldata _data) external;


  function safeBatchTransferFrom(address _from, address _to, uint256[] calldata _ids, uint256[] calldata _amounts, bytes calldata _data) external;


  function balanceOf(address _owner, uint256 _id) external view returns (uint256);


  function balanceOfBatch(address[] calldata _owners, uint256[] calldata _ids) external view returns (uint256[] memory);


  function setApprovalForAll(address _operator, bool _approved) external;


  function isApprovedForAll(address _owner, address _operator) external view returns (bool isOperator);

}


pragma solidity 0.7.4;

interface IERC1155TokenReceiver {


  function onERC1155Received(address _operator, address _from, uint256 _id, uint256 _amount, bytes calldata _data) external returns(bytes4);


  function onERC1155BatchReceived(address _operator, address _from, uint256[] calldata _ids, uint256[] calldata _amounts, bytes calldata _data) external returns(bytes4);

}


pragma solidity ^0.7.4;

contract PortionAuction is IERC721Receiver, IERC1155TokenReceiver {

  modifier onlyOwner {

    require(msg.sender == owner);
    _;
  }

  address public owner;
  address public controller;
  address public beneficiary;
  address public highestBidder;

  uint public tokenId;
  uint public quantity;
  uint public highestBid;

  bool public cancelled;
  bool public itemClaimed;
  bool public controllerClaimedFunds;
  bool public beneficiaryClaimedFunds;
  bool public acceptPRT;
  bool public isErc1155;

  IERC20 portionTokenContract;
  IERC721 artTokenContract;
  IERC1155 artToken1155Contract;

  mapping(address => uint256) public fundsByBidder;

  constructor(
    address _controller,
    address _beneficiary,
    bool _acceptPRT,
    bool _isErc1155,
    uint _tokenId,
    uint _quantity,
    address portionTokenAddress,
    address artTokenAddress,
    address artToken1155Address
  ) {
    owner = msg.sender;
    controller = _controller;
    beneficiary = _beneficiary;
    acceptPRT = _acceptPRT;
    isErc1155 = _isErc1155;
    tokenId = _tokenId;
    quantity = _quantity;

    if (acceptPRT) {
      portionTokenContract = IERC20(portionTokenAddress);
    }

    if (isErc1155) {
      artToken1155Contract = IERC1155(artToken1155Address);
    } else {
      artTokenContract = IERC721(artTokenAddress);
    }
  }

  function placeBid(address bidder, uint totalAmount)
  onlyOwner
  external
  {

    fundsByBidder[bidder] = totalAmount;

    if (bidder != highestBidder) {
      highestBidder = bidder;
    }

    highestBid = totalAmount;
  }

  function handlePayment()
  payable
  onlyOwner
  external
  {}


  function withdrawFunds(
    address claimer,
    address withdrawalAccount,
    uint withdrawalAmount,
    bool _beneficiaryClaimedFunds,
    bool _controllerClaimedFunds
  )
  onlyOwner
  external
  {

    if (acceptPRT) {
      require(portionTokenContract.transfer(claimer, withdrawalAmount));
    } else {
      (bool sent, ) = claimer.call{value: withdrawalAmount}("");
      require(sent);
    }

    fundsByBidder[withdrawalAccount] -= withdrawalAmount;
    if (_beneficiaryClaimedFunds) {
      beneficiaryClaimedFunds = true;
    }
    if (_controllerClaimedFunds) {
      controllerClaimedFunds = true;
    }
  }

  function transferItem(
    address claimer
  )
  onlyOwner
  external
  {

    if (isErc1155) {
      artToken1155Contract.safeTransferFrom(address(this), claimer, tokenId, quantity, "");
    } else {
      artTokenContract.safeTransferFrom(address(this), claimer, tokenId);
    }

    itemClaimed = true;
  }

  function cancelAuction()
  onlyOwner
  external
  {

    cancelled = true;
  }

  function onERC721Received(address _operator, address _from, uint256 _tokenId, bytes calldata data)
  external
  pure
  override
  returns (bytes4)
  {

    return this.onERC721Received.selector;
  }

  function onERC1155Received(address _operator, address _from, uint256 _id, uint256 _amount, bytes calldata _data)
  external
  pure
  override
  returns(bytes4)
  {

    return this.onERC1155Received.selector;
  }

  function onERC1155BatchReceived(address _operator, address _from, uint256[] calldata _ids, uint256[] calldata _values, bytes calldata _data)
  external
  pure
  override
  returns(bytes4)
  {

    return this.onERC1155BatchReceived.selector;
  }
}


pragma solidity >=0.6.0 <0.8.0;

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

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

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b != 0, errorMessage);
        return a % b;
    }
}


pragma solidity ^0.7.4;

contract PortionAuctionFactory {

  using SafeMath for uint;

  struct AuctionParameters {
    uint startingBid;
    uint bidStep;
    uint startBlock;
    uint endBlock;
    uint overtimeBlocksSize;
    uint feeRate;
  }

  modifier onlyOwner {

    require(msg.sender == owner);
    _;
  }

  bytes32 public name = "PortionAuctionFactory";
  address owner;
  IERC20 public portionTokenContract;
  IERC721 public artTokenContract;
  IERC1155 public artToken1155Contract;
  mapping(address => AuctionParameters) public auctionParameters;

  event AuctionCreated(address indexed auctionContract, address indexed beneficiary, uint indexed tokenId);
  event BidPlaced (address indexed bidder, uint bid);
  event FundsClaimed (address indexed claimer, address withdrawalAccount, uint withdrawalAmount);
  event ItemClaimed (address indexed claimer);
  event AuctionCancelled ();

  constructor(address portionTokenAddress, address artTokenAddress, address artToken1155Address) {
    owner = msg.sender;
    portionTokenContract = IERC20(portionTokenAddress);
    artTokenContract = IERC721(artTokenAddress);
    artToken1155Contract = IERC1155(artToken1155Address);
  }

  function createAuction(
    address beneficiary,
    uint tokenId,
    uint bidStep,
    uint startingBid,
    uint startBlock,
    uint endBlock,
    bool acceptPRT,
    bool isErc1155,
    uint quantity,
    uint feeRate,
    uint overtimeBlocksSize
  )
  onlyOwner
  external
  {

    require(beneficiary != address(0));
    require(bidStep > 0);
    require(startingBid >= 0);
    require(startBlock < endBlock);
    require(startBlock >= block.number);
    require(feeRate <= 100);
    if (isErc1155) {
      require(quantity > 0);
    }

    PortionAuction newAuction = new PortionAuction(
      msg.sender,
      beneficiary,
      acceptPRT,
      isErc1155,
      tokenId,
      quantity,
      address(portionTokenContract),
      address(artTokenContract),
      address(artToken1155Contract)
    );

    auctionParameters[address(newAuction)] = AuctionParameters(
      startingBid,
      bidStep,
      startBlock,
      endBlock,
      overtimeBlocksSize,
      feeRate
    );

    if (isErc1155) {
      artToken1155Contract.safeTransferFrom(msg.sender, address(newAuction), tokenId, quantity, "");
    } else {
      artTokenContract.safeTransferFrom(msg.sender, address(newAuction), tokenId);
    }

    emit AuctionCreated(address(newAuction), beneficiary, tokenId);
  }

  function placeBid(
    address auctionAddress
  )
  payable
  external
  {

    PortionAuction auction = PortionAuction(auctionAddress);
    AuctionParameters memory parameters = auctionParameters[auctionAddress];

    require(block.number >= parameters.startBlock);
    require(block.number < parameters.endBlock);
    require(!auction.cancelled());
    require(!auction.acceptPRT());
    require(msg.sender != auction.controller());
    require(msg.sender != auction.beneficiary());
    require(msg.value > 0);

    uint totalBid = auction.fundsByBidder(msg.sender) + msg.value;

    if (auction.highestBid() == 0) {
      require(totalBid >= parameters.startingBid);
    } else {
      require(totalBid >= auction.highestBid() + parameters.bidStep);
    }

    auction.handlePayment{value:msg.value}();
    auction.placeBid(msg.sender, totalBid);

    if (parameters.overtimeBlocksSize > parameters.endBlock - block.number) {
      auctionParameters[auctionAddress].endBlock += parameters.overtimeBlocksSize;
    }

    emit BidPlaced(msg.sender, totalBid);
  }

  function placeBidPRT(address auctionAddress, uint amount)
  external
  {

    PortionAuction auction = PortionAuction(auctionAddress);
    AuctionParameters memory parameters = auctionParameters[auctionAddress];

    require(block.number >= parameters.startBlock);
    require(block.number < parameters.endBlock);
    require(!auction.cancelled());
    require(auction.acceptPRT());
    require(msg.sender != auction.controller());
    require(msg.sender != auction.beneficiary());
    require(amount > 0);

    uint totalBid = auction.fundsByBidder(msg.sender) + amount;

    if (auction.highestBid() == 0) {
      require(totalBid >= parameters.startingBid);
    } else {
      require(totalBid >= auction.highestBid() + parameters.bidStep);
    }

    require(portionTokenContract.transferFrom(msg.sender, auctionAddress, amount));
    auction.placeBid(msg.sender, totalBid);

    if (parameters.overtimeBlocksSize > parameters.endBlock - block.number) {
      auctionParameters[auctionAddress].endBlock += parameters.overtimeBlocksSize;
    }

    emit BidPlaced(msg.sender, totalBid);
  }

  function claimFunds(address auctionAddress)
  external
  {

    PortionAuction auction = PortionAuction(auctionAddress);
    AuctionParameters memory parameters = auctionParameters[auctionAddress];

    require(auction.cancelled() || block.number >= parameters.endBlock);

    address withdrawalAccount;
    uint withdrawalAmount;
    bool beneficiaryClaimedFunds;
    bool controllerClaimedFunds;

    if (auction.cancelled()) {
      withdrawalAccount = msg.sender;
      withdrawalAmount = auction.fundsByBidder(withdrawalAccount);
    } else {

      require(msg.sender != auction.highestBidder());

      if (msg.sender == auction.beneficiary()) {
        require(parameters.feeRate < 100 && !auction.beneficiaryClaimedFunds());
        withdrawalAccount = auction.highestBidder();
        withdrawalAmount = auction.fundsByBidder(withdrawalAccount).mul(100 - parameters.feeRate).div(100);
        beneficiaryClaimedFunds = true;
      } else if (msg.sender == auction.controller()) {
        require(parameters.feeRate > 0 && !auction.controllerClaimedFunds());
        withdrawalAccount = auction.highestBidder();
        withdrawalAmount = auction.fundsByBidder(withdrawalAccount).mul(parameters.feeRate).div(100);
        controllerClaimedFunds = true;
      } else {
        withdrawalAccount = msg.sender;
        withdrawalAmount = auction.fundsByBidder(withdrawalAccount);
      }
    }

    require(withdrawalAmount != 0);

    auction.withdrawFunds(msg.sender, withdrawalAccount, withdrawalAmount, beneficiaryClaimedFunds, controllerClaimedFunds);

    emit FundsClaimed(msg.sender, withdrawalAccount, withdrawalAmount);
  }

  function claimItem(address auctionAddress)
  external
  {

    PortionAuction auction = PortionAuction(auctionAddress);
    AuctionParameters memory parameters = auctionParameters[auctionAddress];

    require(!auction.itemClaimed());
    require(auction.cancelled() || block.number >= parameters.endBlock);

    if (auction.cancelled()
      || (auction.highestBidder() == address(0) && block.number >= parameters.endBlock)) {
      require(msg.sender == auction.beneficiary());
    } else {
      require(msg.sender == auction.highestBidder());
    }

    auction.transferItem(msg.sender);

    emit ItemClaimed(msg.sender);
  }

  function cancelAuction(address auctionAddress)
  onlyOwner
  external
  {

    PortionAuction auction = PortionAuction(auctionAddress);
    AuctionParameters memory parameters = auctionParameters[auctionAddress];

    require(!auction.cancelled());
    require(block.number < parameters.endBlock);

    auction.cancelAuction();
    emit AuctionCancelled();
  }
}