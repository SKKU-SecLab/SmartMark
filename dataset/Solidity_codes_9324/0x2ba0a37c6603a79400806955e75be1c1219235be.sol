


pragma solidity 0.6.7;

abstract contract SAFEEngineLike {
    function transferInternalCoins(address,address,uint256) virtual external;
    function createUnbackedDebt(address,address,uint256) virtual external;
}
abstract contract TokenLike {
    function transferFrom(address,address,uint256) virtual external returns (bool);
    function transfer(address,uint) virtual external returns (bool);
}
abstract contract AccountingEngineLike {
    function totalOnAuctionDebt() virtual external returns (uint256);
    function cancelAuctionedDebtWithSurplus(uint256) virtual external;
}

contract StakedTokenAuctionHouse {

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

        require(authorizedAccounts[msg.sender] == 1, "StakedTokenAuctionHouse/account-not-authorized");
        _;
    }

    struct Bid {
        uint256 bidAmount;                                                        // [rad]
        uint256 amountToSell;                                                     // [wad]
        address highBidder;
        uint48  bidExpiry;                                                        // [unix epoch time]
        uint48  auctionDeadline;                                                  // [unix epoch time]
    }

    mapping (uint256 => Bid) public bids;

    SAFEEngineLike public safeEngine;
    TokenLike public stakedToken;
    address public accountingEngine;
    address public tokenBurner;

    uint256  constant ONE = 1.00E18;                                              // [wad]
    uint256  public   bidIncrease = 1.05E18;                                      // [wad]
    uint256  public   minBidDecrease = 0.95E18;                                   // [wad]
    uint256  public   minBid = 1;                                                 // [rad]
    uint48   public   bidDuration = 3 hours;                                      // [seconds]
    uint48   public   totalAuctionLength = 2 days;                                // [seconds]
    uint256  public   auctionsStarted = 0;
    uint256  public   activeStakedTokenAuctions;
    uint256  public   contractEnabled;

    bytes32 public constant AUCTION_HOUSE_TYPE = bytes32("STAKED_TOKEN");

    event AddAuthorization(address account);
    event RemoveAuthorization(address account);
    event StartAuction(
      uint256 indexed id,
      uint256 auctionsStarted,
      uint256 amountToSell,
      uint256 amountToBid,
      address indexed incomeReceiver,
      uint256 indexed auctionDeadline,
      uint256 activeStakedTokenAuctions
    );
    event ModifyParameters(bytes32 parameter, uint256 data);
    event ModifyParameters(bytes32 parameter, address data);
    event RestartAuction(uint256 indexed id, uint256 minBid, uint256 auctionDeadline);
    event IncreaseBidSize(uint256 id, address highBidder, uint256 amountToBuy, uint256 bid, uint256 bidExpiry);
    event SettleAuction(uint256 indexed id, uint256 bid);
    event TerminateAuctionPrematurely(uint256 indexed id, address sender, address highBidder, uint256 bidAmount, uint256 activeStakedTokenAuctions);
    event DisableContract(address sender);

    constructor(address safeEngine_, address stakedToken_) public {
        require(safeEngine_ != address(0x0), "StakedTokenAuctionHouse/invalid_safe_engine");
        require(stakedToken_ != address(0x0), "StakedTokenAuctionHouse/invalid_token");
        authorizedAccounts[msg.sender] = 1;
        safeEngine      = SAFEEngineLike(safeEngine_);
        stakedToken     = TokenLike(stakedToken_);
        contractEnabled = 1;
        emit AddAuthorization(msg.sender);
    }

    function both(bool x, bool y) internal pure returns (bool z) {

        assembly{ z := and(x, y)}
    }
    function either(bool x, bool y) internal pure returns (bool z) {

        assembly{ z := or(x, y)}
    }

    function addUint48(uint48 x, uint48 y) internal pure returns (uint48 z) {

        require((z = x + y) >= x, "StakedTokenAuctionHouse/add-uint48-overflow");
    }
    function addUint256(uint256 x, uint256 y) internal pure returns (uint256 z) {

        require((z = x + y) >= x, "StakedTokenAuctionHouse/add-uint256-overflow");
    }
    function subtract(uint256 x, uint256 y) internal pure returns (uint256 z) {

        require((z = x - y) <= x, "StakedTokenAuctionHouse/sub-underflow");
    }
    function multiply(uint256 x, uint256 y) internal pure returns (uint256 z) {

        require(y == 0 || (z = x * y) / y == x, "StakedTokenAuctionHouse/mul-overflow");
    }
    function minimum(uint256 x, uint256 y) internal pure returns (uint256 z) {

        if (x > y) { z = y; } else { z = x; }
    }

    function modifyParameters(bytes32 parameter, uint256 data) external isAuthorized {

        require(data > 0, "StakedTokenAuctionHouse/null-data");
        require(contractEnabled == 1, "StakedTokenAuctionHouse/contract-not-enabled");

        if (parameter == "bidIncrease") {
          require(data > ONE, "StakedTokenAuctionHouse/invalid-bid-increase");
          bidIncrease = data;
        }
        else if (parameter == "bidDuration") bidDuration = uint48(data);
        else if (parameter == "totalAuctionLength") totalAuctionLength = uint48(data);
        else if (parameter == "minBidDecrease") {
          require(data < ONE, "StakedTokenAuctionHouse/invalid-min-bid-decrease");
          minBidDecrease = data;
        }
        else if (parameter == "minBid") {
          minBid = data;
        }
        else revert("StakedTokenAuctionHouse/modify-unrecognized-param");
        emit ModifyParameters(parameter, data);
    }
    function modifyParameters(bytes32 parameter, address addr) external isAuthorized {

        require(addr != address(0), "StakedTokenAuctionHouse/null-addr");
        require(contractEnabled == 1, "StakedTokenAuctionHouse/contract-not-enabled");
        if (parameter == "accountingEngine") accountingEngine = addr;
        else if (parameter == "tokenBurner") tokenBurner = addr;
        else revert("StakedTokenAuctionHouse/modify-unrecognized-param");
        emit ModifyParameters(parameter, addr);
    }

    function startAuction(
        uint256 amountToSell,
        uint256 systemCoinsRequested
    ) external isAuthorized returns (uint256 id) {

        require(contractEnabled == 1, "StakedTokenAuctionHouse/contract-not-enabled");
        require(auctionsStarted < uint256(-1), "StakedTokenAuctionHouse/overflow");
        require(accountingEngine != address(0), "StakedTokenAuctionHouse/null-accounting-engine");
        require(both(amountToSell > 0, systemCoinsRequested > 0), "StakedTokenAuctionHouse/null-amounts");
        require(systemCoinsRequested <= uint256(-1) / ONE, "StakedTokenAuctionHouse/large-sys-coin-request");

        id = ++auctionsStarted;

        bids[id].amountToSell     = amountToSell;
        bids[id].bidAmount        = systemCoinsRequested;
        bids[id].highBidder       = address(0);
        bids[id].auctionDeadline  = addUint48(uint48(now), totalAuctionLength);

        activeStakedTokenAuctions = addUint256(activeStakedTokenAuctions, 1);

        require(stakedToken.transferFrom(msg.sender, address(this), amountToSell), "StakedTokenAuctionHouse/cannot-transfer-staked-tokens");

        emit StartAuction(
          id, auctionsStarted, amountToSell, systemCoinsRequested, accountingEngine, bids[id].auctionDeadline, activeStakedTokenAuctions
        );
    }
    function restartAuction(uint256 id) external {

        require(id <= auctionsStarted, "StakedTokenAuctionHouse/auction-never-started");
        require(bids[id].auctionDeadline < now, "StakedTokenAuctionHouse/not-finished");
        require(bids[id].bidExpiry == 0, "StakedTokenAuctionHouse/bid-already-placed");

        uint256 newMinBid        = multiply(minBidDecrease, bids[id].bidAmount) / ONE;
        newMinBid                = (newMinBid < minBid) ? minBid : newMinBid;

        bids[id].bidAmount       = newMinBid;
        bids[id].auctionDeadline = addUint48(uint48(now), totalAuctionLength);

        emit RestartAuction(id, newMinBid, bids[id].auctionDeadline);
    }
    function increaseBidSize(uint256 id, uint256 amountToBuy, uint256 bid) external {

        require(contractEnabled == 1, "StakedTokenAuctionHouse/contract-not-enabled");
        require(bids[id].bidExpiry > now || bids[id].bidExpiry == 0, "StakedTokenAuctionHouse/bid-already-expired");
        require(bids[id].auctionDeadline > now, "StakedTokenAuctionHouse/auction-already-expired");

        require(amountToBuy == bids[id].amountToSell, "StakedTokenAuctionHouse/not-matching-amount-bought");
        require(bid > bids[id].bidAmount, "StakedTokenAuctionHouse/bid-not-higher");
        require(multiply(bid, ONE) > multiply(bidIncrease, bids[id].bidAmount), "StakedTokenAuctionHouse/insufficient-increase");

        if (bids[id].highBidder == msg.sender) {
            safeEngine.transferInternalCoins(msg.sender, address(this), subtract(bid, bids[id].bidAmount));
        } else {
            safeEngine.transferInternalCoins(msg.sender, address(this), bid);
            if (bids[id].highBidder != address(0)) // not first bid
                safeEngine.transferInternalCoins(address(this), bids[id].highBidder, bids[id].bidAmount);

            bids[id].highBidder = msg.sender;
        }

        bids[id].bidAmount  = bid;
        bids[id].bidExpiry  = addUint48(uint48(now), bidDuration);

        emit IncreaseBidSize(id, msg.sender, amountToBuy, bid, bids[id].bidExpiry);
    }
    function settleAuction(uint256 id) external {

        require(contractEnabled == 1, "StakedTokenAuctionHouse/not-live");
        require(both(bids[id].bidExpiry != 0, either(bids[id].bidExpiry < now, bids[id].auctionDeadline < now)), "StakedTokenAuctionHouse/not-finished");

        uint256 bid          = bids[id].bidAmount;
        uint256 amountToSell = bids[id].amountToSell;
        address highBidder   = bids[id].highBidder;

        activeStakedTokenAuctions = subtract(activeStakedTokenAuctions, 1);
        delete bids[id];

        safeEngine.transferInternalCoins(address(this), accountingEngine, bid);

        uint256 totalOnAuctionDebt = AccountingEngineLike(accountingEngine).totalOnAuctionDebt();
        AccountingEngineLike(accountingEngine).cancelAuctionedDebtWithSurplus(minimum(bid, totalOnAuctionDebt));

        require(stakedToken.transfer(highBidder, amountToSell), "StakedTokenAuctionHouse/failed-transfer");

        emit SettleAuction(id, activeStakedTokenAuctions);
    }

    function disableContract() external isAuthorized {

        contractEnabled  = 0;
        emit DisableContract(msg.sender);
    }
    function terminateAuctionPrematurely(uint256 id) external {

        require(contractEnabled == 0, "StakedTokenAuctionHouse/contract-still-enabled");
        require(bids[id].highBidder != address(0), "StakedTokenAuctionHouse/high-bidder-not-set");

        activeStakedTokenAuctions = subtract(activeStakedTokenAuctions, 1);

        safeEngine.transferInternalCoins(address(this), bids[id].highBidder, bids[id].bidAmount);

        require(stakedToken.transfer(tokenBurner, bids[id].amountToSell), "StakedTokenAuctionHouse/failed-transfer");

        emit TerminateAuctionPrematurely(id, msg.sender, bids[id].highBidder, bids[id].bidAmount, activeStakedTokenAuctions);
        delete bids[id];
    }
}