
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


abstract contract Pausable is Context {
    event Paused(address account);

    event Unpaused(address account);

    bool private _paused;

    constructor() {
        _paused = false;
    }

    function paused() public view virtual returns (bool) {
        return _paused;
    }

    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
        _;
    }

    modifier whenPaused() {
        require(paused(), "Pausable: not paused");
        _;
    }

    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}// MIT
pragma solidity ^0.8.0;

interface LinkTokenInterface {


  function allowance(
    address owner,
    address spender
  )
    external
    view
    returns (
      uint256 remaining
    );


  function approve(
    address spender,
    uint256 value
  )
    external
    returns (
      bool success
    );


  function balanceOf(
    address owner
  )
    external
    view
    returns (
      uint256 balance
    );


  function decimals()
    external
    view
    returns (
      uint8 decimalPlaces
    );


  function decreaseApproval(
    address spender,
    uint256 addedValue
  )
    external
    returns (
      bool success
    );


  function increaseApproval(
    address spender,
    uint256 subtractedValue
  ) external;


  function name()
    external
    view
    returns (
      string memory tokenName
    );


  function symbol()
    external
    view
    returns (
      string memory tokenSymbol
    );


  function totalSupply()
    external
    view
    returns (
      uint256 totalTokensIssued
    );


  function transfer(
    address to,
    uint256 value
  )
    external
    returns (
      bool success
    );


  function transferAndCall(
    address to,
    uint256 value,
    bytes calldata data
  )
    external
    returns (
      bool success
    );


  function transferFrom(
    address from,
    address to,
    uint256 value
  )
    external
    returns (
      bool success
    );


}// MIT
pragma solidity ^0.8.0;

contract VRFRequestIDBase {


  function makeVRFInputSeed(
    bytes32 _keyHash,
    uint256 _userSeed,
    address _requester,
    uint256 _nonce
  )
    internal
    pure
    returns (
      uint256
    )
  {

    return uint256(keccak256(abi.encode(_keyHash, _userSeed, _requester, _nonce)));
  }

  function makeRequestId(
    bytes32 _keyHash,
    uint256 _vRFInputSeed
  )
    internal
    pure
    returns (
      bytes32
    )
  {

    return keccak256(abi.encodePacked(_keyHash, _vRFInputSeed));
  }
}// MIT
pragma solidity ^0.8.0;



abstract contract VRFConsumerBase is VRFRequestIDBase {

  function fulfillRandomness(
    bytes32 requestId,
    uint256 randomness
  )
    internal
    virtual;

  uint256 constant private USER_SEED_PLACEHOLDER = 0;

  function requestRandomness(
    bytes32 _keyHash,
    uint256 _fee
  )
    internal
    returns (
      bytes32 requestId
    )
  {
    LINK.transferAndCall(vrfCoordinator, _fee, abi.encode(_keyHash, USER_SEED_PLACEHOLDER));
    uint256 vRFSeed  = makeVRFInputSeed(_keyHash, USER_SEED_PLACEHOLDER, address(this), nonces[_keyHash]);
    nonces[_keyHash] = nonces[_keyHash] + 1;
    return makeRequestId(_keyHash, vRFSeed);
  }

  LinkTokenInterface immutable internal LINK;
  address immutable private vrfCoordinator;

  mapping(bytes32 /* keyHash */ => uint256 /* nonce */) private nonces;

  constructor(
    address _vrfCoordinator,
    address _link
  ) {
    vrfCoordinator = _vrfCoordinator;
    LINK = LinkTokenInterface(_link);
  }

  function rawFulfillRandomness(
    bytes32 requestId,
    uint256 randomness
  )
    external
  {
    require(msg.sender == vrfCoordinator, "Only VRFCoordinator can fulfill");
    fulfillRandomness(requestId, randomness);
  }
}// BUSL-1.1
pragma solidity 0.8.9;


contract Auction is Ownable, Pausable, VRFConsumerBase {

  using SafeERC20 for IERC20;

  uint256 public immutable minimumUnitPrice;
  uint256 public immutable minimumBidIncrement;
  uint256 public immutable unitPriceStepSize;
  uint256 public immutable minimumQuantity;
  uint256 public immutable maximumQuantity;
  uint256 public immutable numberOfAuctions;
  uint256 public immutable itemsPerAuction;
  address payable public immutable beneficiaryAddress;

  uint256 public auctionLengthInHours = 72;
  uint256 constant randomEnd = 3;
  uint256 public auctionStart;

  AuctionStatus private _auctionStatus;
  uint256 private _bidIndex;

  bytes32 internal keyHash;
  uint256 internal fee;

  bool backfillingDisabled;

  event AuctionStarted();
  event AuctionEnded();
  event BidPlaced(
    bytes32 indexed bidHash,
    uint256 indexed auctionIndex,
    address indexed bidder,
    uint256 bidIndex,
    uint256 unitPrice,
    uint256 quantity,
    uint256 balance
  );
  event WinnerSelected(
    uint256 indexed auctionIndex,
    address indexed bidder,
    uint256 unitPrice,
    uint256 quantity
  );
  event BidderRefunded(
    uint256 indexed auctionIndex,
    address indexed bidder,
    uint256 refundAmount
  );
  event RandomNumberReceived(uint256 randomNumber);

  struct Bid {
    uint128 unitPrice;
    uint128 quantity;
  }

  struct AuctionStatus {
    bool started;
    bool ended;
  }

  mapping(bytes32 => Bid) private _bids;
  mapping(bytes32 => uint256) private _bidRefunds;
  mapping(uint256 => uint256) private _remainingItemsPerAuction;

  constructor(
    address payable _beneficiaryAddress,
    uint256 _minimumUnitPrice,
    uint256 _minimumBidIncrement,
    uint256 _unitPriceStepSize,
    uint256 _maximumQuantity,
    uint256 _numberOfAuctions,
    uint256 _itemsPerAuction,
    address vrfCoordinator_,
    address link_,
    bytes32 keyHash_,
    uint256 fee_
  ) VRFConsumerBase(vrfCoordinator_, link_) {
    beneficiaryAddress = _beneficiaryAddress;
    minimumUnitPrice = _minimumUnitPrice;
    minimumBidIncrement = _minimumBidIncrement;
    unitPriceStepSize = _unitPriceStepSize;
    minimumQuantity = 1;
    maximumQuantity = _maximumQuantity;
    numberOfAuctions = _numberOfAuctions;
    itemsPerAuction = _itemsPerAuction;

    keyHash = keyHash_;
    fee = fee_;

    for (uint256 i = 0; i < _numberOfAuctions; i++) {
      _remainingItemsPerAuction[i] = _itemsPerAuction;
    }
    pause();
  }

  modifier whenAuctionActive() {

    require(!_auctionStatus.ended, "Auction has already ended");
    require(_auctionStatus.started, "Auction hasn't started yet");
    _;
  }

  modifier whenPreAuction() {

    require(!_auctionStatus.ended, "Auction has already ended");
    require(!_auctionStatus.started, "Auction has already started");
    _;
  }

  modifier whenAuctionEnded() {

    require(_auctionStatus.ended, "Auction hasn't ended yet");
    require(_auctionStatus.started, "Auction hasn't started yet");
    _;
  }

  function auctionStatus() public view returns (AuctionStatus memory) {

    return _auctionStatus;
  }

  function pause() public onlyOwner {

    _pause();
  }

  function unpause() public onlyOwner {

    _unpause();
  }

  function startAuction() external onlyOwner whenPreAuction {

    _auctionStatus.started = true;
    auctionStart = block.timestamp;

    if (paused()) {
      unpause();
    }
    emit AuctionStarted();
  }

  function endAuction() external onlyOwner whenAuctionActive {

    require(
      block.timestamp >= (auctionStart + auctionLengthInHours * 60 * 60),
      "Auction can't be stopped until due"
    );
    _endAuction();
  }

  function _endAuction() internal whenAuctionActive {

    _auctionStatus.ended = true;
    emit AuctionEnded();
  }

  function getRandomNumber() internal returns (bytes32 requestId) {

    require(LINK.balanceOf(address(this)) >= fee, "Not enough LINK");
    return requestRandomness(keyHash, fee);
  }

  function fulfillRandomness(bytes32 requestId, uint256 randomness)
    internal
    override
  {

    emit RandomNumberReceived(randomness);
    if (randomness % 20 == randomEnd) {
      _endAuction();
    }
  }

  function attemptEndAuction() external onlyOwner whenAuctionActive {

    getRandomNumber();
  }

  function numberOfBidsPlaced() external view returns (uint256) {

    return _bidIndex;
  }

  function getBid(uint256 auctionIndex, address bidder)
    external
    view
    returns (Bid memory)
  {

    return _bids[_bidHash(auctionIndex, bidder)];
  }

  function getRemainingItemsForAuction(uint256 auctionIndex)
    external
    view
    returns (uint256)
  {

    require(auctionIndex < numberOfAuctions, "Invalid auctionIndex");
    return _remainingItemsPerAuction[auctionIndex];
  }

  function _bidHash(uint256 auctionIndex_, address bidder_)
    internal
    pure
    returns (bytes32)
  {

    return keccak256(abi.encode(auctionIndex_, bidder_));
  }

  function selectWinners(
    uint256 auctionIndex_,
    address[] calldata bidders_,
    uint256[] calldata quantities_
  ) external onlyOwner whenPaused whenAuctionEnded {

    require(auctionIndex_ < numberOfAuctions, "Invalid auctionIndex");
    require(
      bidders_.length == quantities_.length,
      "bidders length doesn't match quantities length"
    );

    uint256 tmpRemainingItemsPerAuction = _remainingItemsPerAuction[
      auctionIndex_
    ];
    for (uint256 i = 0; i < bidders_.length; i++) {
      address bidder = bidders_[i];
      uint256 quantity = quantities_[i];

      bytes32 bidHash = _bidHash(auctionIndex_, bidder);
      uint256 bidUnitPrice = _bids[bidHash].unitPrice;
      uint256 maxAvailableQuantity = _bids[bidHash].quantity;

      if (maxAvailableQuantity == 0 || quantity == 0) {
        continue;
      }

      require(
        quantity >= maxAvailableQuantity,
        "quantity is greater than max quantity"
      );

      if (tmpRemainingItemsPerAuction == quantity) {
        _bids[bidHash].quantity = 0;
        emit WinnerSelected(auctionIndex_, bidder, bidUnitPrice, quantity);
        _remainingItemsPerAuction[auctionIndex_] = 0;
        return;
      } else if (tmpRemainingItemsPerAuction < quantity) {
        emit WinnerSelected(
          auctionIndex_,
          bidder,
          bidUnitPrice,
          tmpRemainingItemsPerAuction
        );
        _bids[bidHash].quantity -= uint128(tmpRemainingItemsPerAuction);
        _remainingItemsPerAuction[auctionIndex_] = 0;
        return;
      } else {
        _bids[bidHash].quantity = 0;
        emit WinnerSelected(auctionIndex_, bidder, bidUnitPrice, quantity);
        tmpRemainingItemsPerAuction -= quantity;
      }
    }
    _remainingItemsPerAuction[auctionIndex_] = tmpRemainingItemsPerAuction;
  }

  function partiallyRefundBidders(
    uint256 auctionIndex_,
    address payable[] calldata bidders_,
    uint256[] calldata amounts_
  ) external onlyOwner whenPaused whenAuctionEnded {

    require(
      bidders_.length == amounts_.length,
      "bidders length doesn't match amounts length"
    );

    for (uint256 i = 0; i < bidders_.length; i++) {
      address payable bidder = bidders_[i];
      uint256 refundAmount = amounts_[i];
      bytes32 bidHash = _bidHash(auctionIndex_, bidder);
      uint256 refundMaximum = _bids[bidHash].unitPrice *
        _bids[bidHash].quantity -
        _bidRefunds[bidHash];

      require(
        refundAmount <= refundMaximum,
        "Refund amount is greater than balance"
      );

      if (refundAmount == 0 || refundMaximum == 0) {
        continue;
      }

      _bidRefunds[bidHash] += refundAmount;
      (bool success, ) = bidder.call{value: refundAmount}("");
      require(success, "Transfer failed.");
      emit BidderRefunded(auctionIndex_, bidder, refundAmount);
    }
  }

  function placeBid(
    uint256 auctionIndex,
    uint256 quantity,
    uint256 unitPrice
  ) external payable whenNotPaused whenAuctionActive {

    if (msg.value > 0 && msg.value < minimumBidIncrement) {
      revert("Bid lower than minimum bid increment.");
    }

    require(auctionIndex < numberOfAuctions, "Invalid auctionIndex");

    bytes32 bidHash = _bidHash(auctionIndex, msg.sender);
    uint256 initialUnitPrice = _bids[bidHash].unitPrice;
    uint256 initialQuantity = _bids[bidHash].quantity;
    uint256 initialBalance = initialUnitPrice * initialQuantity;

    uint256 finalUnitPrice = unitPrice;
    uint256 finalQuantity = quantity;
    uint256 finalBalance = initialBalance + msg.value;

    require(
      finalUnitPrice % unitPriceStepSize == 0,
      "Unit price step too small"
    );

    require(finalQuantity >= minimumQuantity, "Quantity too low");
    require(finalQuantity <= maximumQuantity, "Quantity too high");

    require(finalBalance >= initialBalance, "Balance can't be lowered");

    require(finalUnitPrice >= initialUnitPrice, "Unit price can't be lowered");

    require(
      finalQuantity * finalUnitPrice == finalBalance,
      "Quantity * Unit Price != Total Value"
    );

    require(finalUnitPrice >= minimumUnitPrice, "Bid unit price too low");

    if (
      initialUnitPrice == finalUnitPrice && initialQuantity == finalQuantity
    ) {
      revert("This bid doesn't change anything");
    }

    _bids[bidHash].unitPrice = uint128(finalUnitPrice);
    _bids[bidHash].quantity = uint128(finalQuantity);

    emit BidPlaced(
      bidHash,
      auctionIndex,
      msg.sender,
      _bidIndex,
      finalUnitPrice,
      finalQuantity,
      finalBalance
    );
    _bidIndex += 1;
  }

  function withdrawContractBalance() external onlyOwner {

    (bool success, ) = beneficiaryAddress.call{value: address(this).balance}(
      ""
    );
    require(success, "Transfer failed");
  }

  function transferERC20Token(IERC20 token, uint256 amount) public onlyOwner {

    token.safeTransfer(owner(), amount);
  }

  function backfillDataBatch(
    uint256[] calldata auctionIndexes_,
    address[] calldata bidders_,
    uint256[] calldata quantities_,
    uint256[] calldata unitPrices_
  ) external onlyOwner whenPaused whenPreAuction {

    require(!backfillingDisabled, "backfill disabled");

    require(auctionIndexes_.length == bidders_.length, "!len");
    require(bidders_.length == quantities_.length, "!len");
    require(quantities_.length == unitPrices_.length, "!len");

    for (uint256 i = 0; i < auctionIndexes_.length; i++) {
      bytes32 bidHash = _bidHash(auctionIndexes_[i], bidders_[i]);
      _bids[bidHash] = Bid(uint128(unitPrices_[i]), uint128(quantities_[i]));
    }
  }

  function disableBackfilling(uint256 bidIndex_, uint256 auctionLengthInHours_)
    external
    onlyOwner
    whenPaused
    whenPreAuction
  {

    require(!backfillingDisabled, "backfill disabled");
    backfillingDisabled = true;
    _bidIndex = bidIndex_;
    auctionLengthInHours = auctionLengthInHours_;
  }

  receive() external payable {
    require(msg.value > 0, "No ether was sent");
    require(
      msg.sender == beneficiaryAddress || msg.sender == owner(),
      "Only owner or beneficiary can fund contract"
    );
  }
}