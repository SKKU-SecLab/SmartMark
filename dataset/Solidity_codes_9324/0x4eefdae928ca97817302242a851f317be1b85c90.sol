


pragma solidity 0.6.7;

abstract contract SAFEEngineLike {
    function transferInternalCoins(address,address,uint256) virtual external;
    function coinBalance(address) virtual external view returns (uint256);
    function approveSAFEModification(address) virtual external;
    function denySAFEModification(address) virtual external;
}
abstract contract TokenLike {
    function approve(address, uint256) virtual public returns (bool);
    function balanceOf(address) virtual public view returns (uint256);
    function move(address,address,uint256) virtual external;
    function burn(address,uint256) virtual external;
}


contract MixedStratSurplusAuctionHouse {

    mapping (address => uint256) public authorizedAccounts;
    function addAuthorization(address account) external isAuthorized {

        authorizedAccounts[account] = 1;
        emit AddAuthorization(account);
    }
    function removeAuthorization(address account) external isAuthorized {

        authorizedAccounts[account] = 0;
        emit RemoveAuthorization(account);
    }
    modifier isAuthorized {

        require(authorizedAccounts[msg.sender] == 1, "MixedStratSurplusAuctionHouse/account-not-authorized");
        _;
    }

    struct Bid {
        uint256 bidAmount;                                                            // [wad]
        uint256 amountToSell;                                                         // [rad]
        address highBidder;
        uint48  bidExpiry;                                                            // [unix epoch time]
        uint48  auctionDeadline;                                                      // [unix epoch time]
    }

    mapping (uint256 => Bid) public bids;

    SAFEEngineLike public safeEngine;
    TokenLike      public protocolToken;
    address        public protocolTokenBidReceiver;

    uint256  constant ONE = 1.00E18;                                                  // [wad]
    uint256  public   bidIncrease = 1.05E18;                                          // [wad]
    uint48   public   bidDuration = 3 hours;                                          // [seconds]
    uint48   public   totalAuctionLength = 2 days;                                    // [seconds]
    uint256  public   auctionsStarted = 0;
    uint256  public   contractEnabled;

    bytes32 public constant AUCTION_HOUSE_TYPE = bytes32("SURPLUS");
    bytes32 public constant SURPLUS_AUCTION_TYPE = bytes32("MIXED-STRAT");

    event AddAuthorization(address account);
    event RemoveAuthorization(address account);
    event ModifyParameters(bytes32 parameter, uint256 data);
    event ModifyParameters(bytes32 parameter, address addr);
    event RestartAuction(uint256 id, uint256 auctionDeadline);
    event IncreaseBidSize(uint256 id, address highBidder, uint256 amountToBuy, uint256 bid, uint256 bidExpiry);
    event StartAuction(
        uint256 indexed id,
        uint256 auctionsStarted,
        uint256 amountToSell,
        uint256 initialBid,
        uint256 auctionDeadline
    );
    event SettleAuction(uint256 indexed id);
    event DisableContract();
    event TerminateAuctionPrematurely(uint256 indexed id, address sender, address highBidder, uint256 bidAmount);

    constructor(address safeEngine_, address protocolToken_) public {
        authorizedAccounts[msg.sender] = 1;
        safeEngine = SAFEEngineLike(safeEngine_);
        protocolToken = TokenLike(protocolToken_);
        contractEnabled = 1;
        emit AddAuthorization(msg.sender);
    }

    uint256 public constant FIFTY   = 50;
    uint256 public constant HUNDRED = 100;
    function addUint48(uint48 x, uint48 y) internal pure returns (uint48 z) {

        require((z = x + y) >= x, "MixedStratSurplusAuctionHouse/add-uint48-overflow");
    }
    function subtract(uint256 x, uint256 y) internal pure returns (uint256 z) {

        require((z = x - y) <= x, "MixedStratSurplusAuctionHouse/sub-underflow");
    }
    function multiply(uint256 x, uint256 y) internal pure returns (uint256 z) {

        require(y == 0 || (z = x * y) / y == x, "MixedStratSurplusAuctionHouse/mul-overflow");
    }

    function modifyParameters(bytes32 parameter, uint256 data) external isAuthorized {

        if (parameter == "bidIncrease") bidIncrease = data;
        else if (parameter == "bidDuration") bidDuration = uint48(data);
        else if (parameter == "totalAuctionLength") totalAuctionLength = uint48(data);
        else revert("MixedStratSurplusAuctionHouse/modify-unrecognized-param");
        emit ModifyParameters(parameter, data);
    }
    function modifyParameters(bytes32 parameter, address addr) external isAuthorized {

        require(addr != address(0), "MixedStratSurplusAuctionHouse/invalid-address");
        if (parameter == "protocolTokenBidReceiver") protocolTokenBidReceiver = addr;
        else revert("MixedStratSurplusAuctionHouse/modify-unrecognized-param");
        emit ModifyParameters(parameter, addr);
    }

    function startAuction(uint256 amountToSell, uint256 initialBid) external isAuthorized returns (uint256 id) {

        require(contractEnabled == 1, "MixedStratSurplusAuctionHouse/contract-not-enabled");
        require(auctionsStarted < uint256(-1), "MixedStratSurplusAuctionHouse/overflow");
        require(protocolTokenBidReceiver != address(0), "MixedStratSurplusAuctionHouse/null-prot-token-receiver");
        id = ++auctionsStarted;

        bids[id].bidAmount = initialBid;
        bids[id].amountToSell = amountToSell;
        bids[id].highBidder = msg.sender;
        bids[id].auctionDeadline = addUint48(uint48(now), totalAuctionLength);

        safeEngine.transferInternalCoins(msg.sender, address(this), amountToSell);

        emit StartAuction(id, auctionsStarted, amountToSell, initialBid, bids[id].auctionDeadline);
    }
    function restartAuction(uint256 id) external {

        require(bids[id].auctionDeadline < now, "MixedStratSurplusAuctionHouse/not-finished");
        require(bids[id].bidExpiry == 0, "MixedStratSurplusAuctionHouse/bid-already-placed");
        bids[id].auctionDeadline = addUint48(uint48(now), totalAuctionLength);
        emit RestartAuction(id, bids[id].auctionDeadline);
    }
    function increaseBidSize(uint256 id, uint256 amountToBuy, uint256 bid) external {

        require(contractEnabled == 1, "MixedStratSurplusAuctionHouse/contract-not-enabled");
        require(bids[id].highBidder != address(0), "MixedStratSurplusAuctionHouse/high-bidder-not-set");
        require(bids[id].bidExpiry > now || bids[id].bidExpiry == 0, "MixedStratSurplusAuctionHouse/bid-already-expired");
        require(bids[id].auctionDeadline > now, "MixedStratSurplusAuctionHouse/auction-already-expired");

        require(amountToBuy == bids[id].amountToSell, "MixedStratSurplusAuctionHouse/amounts-not-matching");
        require(bid > bids[id].bidAmount, "MixedStratSurplusAuctionHouse/bid-not-higher");
        require(multiply(bid, ONE) >= multiply(bidIncrease, bids[id].bidAmount), "MixedStratSurplusAuctionHouse/insufficient-increase");

        if (msg.sender != bids[id].highBidder) {
            protocolToken.move(msg.sender, bids[id].highBidder, bids[id].bidAmount);
            bids[id].highBidder = msg.sender;
        }
        protocolToken.move(msg.sender, address(this), bid - bids[id].bidAmount);

        bids[id].bidAmount = bid;
        bids[id].bidExpiry = addUint48(uint48(now), bidDuration);

        emit IncreaseBidSize(id, msg.sender, amountToBuy, bid, bids[id].bidExpiry);
    }
    function settleAuction(uint256 id) external {

        require(contractEnabled == 1, "MixedStratSurplusAuctionHouse/contract-not-enabled");
        require(bids[id].bidExpiry != 0 && (bids[id].bidExpiry < now || bids[id].auctionDeadline < now), "MixedStratSurplusAuctionHouse/not-finished");
        safeEngine.transferInternalCoins(address(this), bids[id].highBidder, bids[id].amountToSell);

        uint256 amountToSend = multiply(bids[id].bidAmount, FIFTY) / HUNDRED;
        if (amountToSend > 0) {
          protocolToken.move(address(this), protocolTokenBidReceiver, amountToSend);
        }

        uint256 amountToBurn = subtract(bids[id].bidAmount, amountToSend);
        if (amountToBurn > 0) {
          protocolToken.burn(address(this), amountToBurn);
        }

        delete bids[id];
        emit SettleAuction(id);
    }
    function disableContract() external isAuthorized {

        contractEnabled = 0;
        safeEngine.transferInternalCoins(address(this), msg.sender, safeEngine.coinBalance(address(this)));
        emit DisableContract();
    }
    function terminateAuctionPrematurely(uint256 id) external {

        require(contractEnabled == 0, "MixedStratSurplusAuctionHouse/contract-still-enabled");
        require(bids[id].highBidder != address(0), "MixedStratSurplusAuctionHouse/high-bidder-not-set");
        protocolToken.move(address(this), bids[id].highBidder, bids[id].bidAmount);
        emit TerminateAuctionPrematurely(id, msg.sender, bids[id].highBidder, bids[id].bidAmount);
        delete bids[id];
    }
}