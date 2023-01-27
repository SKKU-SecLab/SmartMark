

pragma solidity ^0.5.0;

interface IERC20 {

    function transfer(address to, uint256 value) external returns (bool);


    function approve(address spender, uint256 value) external returns (bool);


    function transferFrom(address from, address to, uint256 value) external returns (bool);


    function totalSupply() external view returns (uint256);


    function balanceOf(address who) external view returns (uint256);


    function allowance(address owner, address spender) external view returns (uint256);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}


pragma solidity ^0.5.7;


contract IBrokerRegistry {

    event BrokerRegistered(
        address owner,
        address broker,
        address interceptor
    );

    event BrokerUnregistered(
        address owner,
        address broker,
        address interceptor
    );

    event AllBrokersUnregistered(
        address owner
    );

    function getBroker(
        address owner,
        address broker
        )
        external
        view
        returns(
            bool registered,
            address interceptor
        );


    function getBrokers(
        address owner,
        uint    start,
        uint    count
        )
        external
        view
        returns (
            address[] memory brokers,
            address[] memory interceptors
        );


    function registerBroker(
        address broker,
        address interceptor
        )
        external;


    function unregisterBroker(
        address broker
        )
        external;


    function unregisterAllBrokers(
        )
        external;

}


pragma solidity ^0.5.7;


contract IBurnRateTable {


    struct TokenData {
        uint    tier;
        uint    validUntil;
    }

    mapping(address => TokenData) public tokens;

    uint public constant YEAR_TO_SECONDS = 31556952;

    uint8 public constant TIER_4 = 0;
    uint8 public constant TIER_3 = 1;
    uint8 public constant TIER_2 = 2;
    uint8 public constant TIER_1 = 3;

    uint16 public constant BURN_BASE_PERCENTAGE           =                 100 * 10; // 100%

    uint16 public constant TIER_UPGRADE_COST_PERCENTAGE   =                        1; // 0.1%

    uint16 public constant BURN_MATCHING_TIER1            =                       25; // 2.5%
    uint16 public constant BURN_MATCHING_TIER2            =                  15 * 10; //  15%
    uint16 public constant BURN_MATCHING_TIER3            =                  30 * 10; //  30%
    uint16 public constant BURN_MATCHING_TIER4            =                  50 * 10; //  50%
    uint16 public constant BURN_P2P_TIER1                 =                       25; // 2.5%
    uint16 public constant BURN_P2P_TIER2                 =                  15 * 10; //  15%
    uint16 public constant BURN_P2P_TIER3                 =                  30 * 10; //  30%
    uint16 public constant BURN_P2P_TIER4                 =                  50 * 10; //  50%

    event TokenTierUpgraded(
        address indexed addr,
        uint            tier
    );

    function getBurnRate(
        address token
        )
        external
        view
        returns (uint32 burnRate);


    function getTokenTier(
        address token
        )
        public
        view
        returns (uint);


    function upgradeTokenTier(
        address token
        )
        external
        returns (bool);


}


pragma solidity ^0.5.7;


contract IFeeHolder {


    event TokenWithdrawn(
        address owner,
        address token,
        uint value
    );

    mapping(address => mapping(address => uint)) public feeBalances;

    mapping(address => uint) public nonces;

    function withdrawBurned(
        address token,
        uint value
        )
        external
        returns (bool success);


    function withdrawToken(
        address token,
        uint value
        )
        external
        returns (bool success);


    function withdrawTokenFor(
      address owner,
      address token,
      uint value,
      address recipient,
      uint feeValue,
      address feeRecipient,
      uint nonce,
      bytes calldata signature
      )
      external
      returns (bool success);


    function batchAddFeeBalances(
        bytes32[] calldata batch
        )
        external;

}


pragma solidity ^0.5.7;


contract IOrderBook {

    mapping(bytes32 => bool) public orderSubmitted;

    event OrderSubmitted(
        bytes32 orderHash,
        bytes   orderData
    );

    function submitOrder(
        bytes calldata orderData
        )
        external
        returns (bytes32);

}


pragma solidity ^0.5.7;


contract IOrderRegistry {


    function isOrderHashRegistered(
        address broker,
        bytes32 orderHash
        )
        external
        view
        returns (bool);


    function registerOrderHash(
        bytes32 orderHash
        )
        external;

}


pragma solidity ^0.5.7;

library BrokerData {


  struct BrokerOrder {
    address owner;
    bytes32 orderHash;
    uint fillAmountB;
    uint requestedAmountS;
    uint requestedFeeAmount;
    address tokenRecipient;
    bytes extraData;
  }

  struct BrokerApprovalRequest {
    BrokerOrder[] orders;
    address tokenS;
    address tokenB;
    address feeToken;
    uint totalFillAmountB;
    uint totalRequestedAmountS;
    uint totalRequestedFeeAmount;
  }

  struct BrokerInterceptorReport {
    address owner;
    address broker;
    bytes32 orderHash;
    address tokenB;
    address tokenS;
    address feeToken;
    uint fillAmountB;
    uint spentAmountS;
    uint spentFeeAmount;
    address tokenRecipient;
    bytes extraData;
  }

}


pragma solidity ^0.5.7;
pragma experimental ABIEncoderV2;


contract ILoopringTradeDelegate {


    function isTrustedSubmitter(address submitter) public view returns (bool);


    function addTrustedSubmitter(address submitter) public;


    function removeTrustedSubmitter(address submitter) public;


    function batchTransfer(
        bytes32[] calldata batch
    ) external;


    function brokerTransfer(
        address token,
        address broker,
        address recipient,
        uint amount
    ) external;


    function proxyBrokerRequestAllowance(
        BrokerData.BrokerApprovalRequest memory request,
        address broker
    ) public returns (bool);



    function authorizeAddress(
        address addr
        )
        external;


    function deauthorizeAddress(
        address addr
        )
        external;


    function isAddressAuthorized(
        address addr
        )
        public
        view
        returns (bool);



    function suspend()
        external;


    function resume()
        external;


    function kill()
        external;

}


pragma solidity ^0.5.7;


contract ITradeHistory {


    mapping (bytes32 => uint) public filled;

    mapping (address => mapping (bytes32 => bool)) public cancelled;

    mapping (address => uint) public cutoffs;

    mapping (address => mapping (bytes20 => uint)) public tradingPairCutoffs;

    mapping (address => mapping (address => uint)) public cutoffsOwner;

    mapping (address => mapping (address => mapping (bytes20 => uint))) public tradingPairCutoffsOwner;


    function batchUpdateFilled(
        bytes32[] calldata filledInfo
        )
        external;


    function setCancelled(
        address broker,
        bytes32 orderHash
        )
        external;


    function setCutoffs(
        address broker,
        uint cutoff
        )
        external;


    function setTradingPairCutoffs(
        address broker,
        bytes20 tokenPair,
        uint cutoff
        )
        external;


    function setCutoffsOfOwner(
        address broker,
        address owner,
        uint cutoff
        )
        external;


    function setTradingPairCutoffsOfOwner(
        address broker,
        address owner,
        bytes20 tokenPair,
        uint cutoff
        )
        external;


    function batchGetFilledAndCheckCancelled(
        bytes32[] calldata orderInfo
        )
        external
        view
        returns (uint[] memory fills);



    function authorizeAddress(
        address addr
        )
        external;


    function deauthorizeAddress(
        address addr
        )
        external;


    function isAddressAuthorized(
        address addr
        )
        public
        view
        returns (bool);



    function suspend()
        external;


    function resume()
        external;


    function kill()
        external;

}


pragma solidity ^0.5.7;









library Data {


    enum TokenType { ERC20 }

    struct Header {
        uint version;
        uint numOrders;
        uint numRings;
        uint numSpendables;
    }

    struct BrokerAction {
        bytes32 hash;
        address broker;
        uint[] orderIndices;
        uint numOrders;
        uint[] transferIndices;
        uint numTransfers;
        address tokenS;
        address tokenB;
        address feeToken;
        address delegate;
    }

    struct BrokerTransfer {
        bytes32 hash;
        address token;
        uint amount;
        address recipient;
    }

    struct Context {
        address lrcTokenAddress;
        ILoopringTradeDelegate delegate;
        ITradeHistory   tradeHistory;
        IBrokerRegistry orderBrokerRegistry;
        IOrderRegistry  orderRegistry;
        IFeeHolder feeHolder;
        IOrderBook orderBook;
        IBurnRateTable burnRateTable;
        uint64 ringIndex;
        uint feePercentageBase;
        bytes32[] tokenBurnRates;
        uint feeData;
        uint feePtr;
        uint transferData;
        uint transferPtr;
        BrokerData.BrokerOrder[] brokerOrders;
        BrokerAction[] brokerActions;
        BrokerTransfer[] brokerTransfers;
        uint numBrokerOrders;
        uint numBrokerActions;
        uint numBrokerTransfers;
    }

    struct Mining {
        address feeRecipient;

        address miner;
        bytes   sig;

        bytes32 hash;
        address interceptor;
    }

    struct Spendable {
        bool initialized;
        uint amount;
        uint reserved;
    }

    struct Order {
        uint      version;

        address   owner;
        address   tokenS;
        address   tokenB;
        uint      amountS;
        uint      amountB;
        uint      validSince;
        Spendable tokenSpendableS;
        Spendable tokenSpendableFee;

        address   dualAuthAddr;
        address   broker;
        Spendable brokerSpendableS;
        Spendable brokerSpendableFee;
        address   orderInterceptor;
        address   wallet;
        uint      validUntil;
        bytes     sig;
        bytes     dualAuthSig;
        bool      allOrNone;
        address   feeToken;
        uint      feeAmount;
        int16     waiveFeePercentage;
        uint16    tokenSFeePercentage;    // Pre-trading
        uint16    tokenBFeePercentage;   // Post-trading
        address   tokenRecipient;
        uint16    walletSplitPercentage;

        bool    P2P;
        bytes32 hash;
        address brokerInterceptor;
        uint    filledAmountS;
        uint    initialFilledAmountS;
        bool    valid;

        TokenType tokenTypeS;
        TokenType tokenTypeB;
        TokenType tokenTypeFee;
        bytes32 trancheS;
        bytes32 trancheB;
        uint    maxPrimaryFillAmount;
        bool    transferFirstAsMaker;
        bytes   transferDataS;
    }

    struct Participation {
        Order order;

        uint splitS;
        uint feeAmount;
        uint feeAmountS;
        uint feeAmountB;
        uint rebateFee;
        uint rebateS;
        uint rebateB;
        uint fillAmountS;
        uint fillAmountB;
    }

    struct Ring {
        uint size;
        Participation[] participations;
        bytes32 hash;
        uint minerFeesToOrdersPercentage;
        bool valid;
    }

    struct RingIndices {
        uint index0;
        uint index1;
    }

    struct FeeContext {
        Data.Ring ring;
        Data.Context ctx;
        address feeRecipient;
        uint walletPercentage;
        int16 waiveFeePercentage;
        address owner;
        address wallet;
        bool P2P;
    }


}


pragma solidity ^0.5.0;

library SafeMath {

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b);

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0);
        uint256 c = a / b;

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b <= a);
        uint256 c = a - b;

        return c;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a);

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b != 0);
        return a % b;
    }
}


pragma solidity ^0.5.0;



library SafeERC20 {

    using SafeMath for uint256;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {

        require(token.transfer(to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {

        require(token.transferFrom(from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint256 value) internal {

        require((value == 0) || (token.allowance(address(this), spender) == 0));
        require(token.approve(spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        require(token.approve(spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).sub(value);
        require(token.approve(spender, newAllowance));
    }
}



pragma solidity ^0.5.0;

library SafeEther {


    function safeTransferEther(address recipient, uint amount) internal {

        safeTransferEther(recipient, amount, "CANNOT_TRANSFER_ETHER");
    }

    function safeTransferEther(address recipient, uint amount, string memory errorMessage) internal {

        (bool success,) = address(uint160(recipient)).call.value(amount)("");
        require(success, errorMessage);
    }

}



pragma solidity ^0.5.7;




contract MakerBrokerBase {


    using SafeEther for address payable;
    using SafeERC20 for IERC20;

    address public owner;

    constructor() public {
        owner = msg.sender;
    }

    modifier onlyOwner() {

        require(msg.sender == owner, "NOT_OWNER");
        _;
    }

    function transferOwnership(address newOwner) public onlyOwner {

        require(newOwner != address(0x0), "ZERO_ADDRESS");
        owner = newOwner;
    }

    function withdrawDust(address token) external {

        _withdrawDust(token, msg.sender);
    }

    function withdrawDust(address token, address recipient) external {

        _withdrawDust(token, recipient);
    }

    function withdrawEthDust() external {

        _withdrawEthDust(msg.sender);
    }

    function withdrawEthDust(address payable recipient) external {

        _withdrawEthDust(recipient);
    }

    function _withdrawDust(address token, address recipient) internal {

        require(msg.sender == owner, "UNAUTHORIZED");
        IERC20(token).safeTransfer(
            msg.sender,
            IERC20(token).balanceOf(address(this))
        );
    }

    function _withdrawEthDust(address payable recipient) internal {

        require(msg.sender == owner, "UNAUTHORIZED");
        recipient.safeTransferEther(address(this).balance);
    }

}



pragma solidity ^0.5.7;





interface Oasis {

    struct OfferInfo {
        uint pay_amt;
        IERC20 pay_gem;
        uint buy_amt;
        IERC20 buy_gem;
        address owner;
        uint64 timestamp;
    }


    function offers(uint id) external view returns (uint, IERC20, uint, IERC20, address, uint64);


    function getOfferCount(IERC20 sell_gem, IERC20 buy_gem) external view returns (uint);


    function getBestOffer(IERC20 sell_gem, IERC20 buy_gem) external view returns (uint);


    function getWorseOffer(uint id) external view returns (uint);


    function isActive(uint id) external view returns (bool active);


    function buy(uint id, uint amount) external returns (bool);


    function sellAllAmount(IERC20 pay_gem, uint pay_amt, IERC20 buy_gem, uint min_fill_amount) external returns (uint);

}

contract OasisMakerBroker is MakerBrokerBase {


    Oasis public oasis;
    address public loopringProtocol;

    constructor(address _loopringProtocol, address _oasis) public {
        oasis = Oasis(_oasis);
        loopringProtocol = _loopringProtocol;
    }

    function setLoopringProtocol(address _loopringProtocol) external onlyOwner {

        loopringProtocol = _loopringProtocol;
    }

    function setOasis(address _oasis) external onlyOwner {

        oasis = Oasis(_oasis);
    }


    function enableToken(address token) public {

        IERC20(token).approve(address(loopringProtocol), uint(- 1));
        IERC20(token).approve(address(oasis), uint(- 1));
    }

    function enableTokens(address[] calldata tokens) external {

        for (uint i = 0; i < tokens.length; i++) {
            enableToken(tokens[i]);
        }
    }


    function brokerRequestAllowance(BrokerData.BrokerApprovalRequest memory request) public returns (bool) {

        require(msg.sender == loopringProtocol, "Oasis MakerBroker: Unauthorized caller");
        require(request.totalRequestedFeeAmount == 0, "Oasis MakerBroker: Cannot be charged a fee");

        for (uint i = 0; i < request.orders.length; i++) {
            BrokerData.BrokerOrder memory order = request.orders[i];
            require(order.tokenRecipient == address(this), "Oasis MakerBroker: Order tokenRecipient must be this broker");
            require(order.owner == owner, "Oasis MakerBroker: Order owner must be the owner of this contract");
        }

        (bool success,) = address(oasis).call(
            abi.encodePacked(
                oasis.sellAllAmount.selector,
                abi.encode(request.tokenB, request.totalFillAmountB, request.tokenS, request.totalRequestedAmountS)
            )
        );
        require(success, "Oasis MakerBroker: Oasis matching failed");

        return false;
    }

    function onOrderFillReport(BrokerData.BrokerInterceptorReport memory fillReport) public {

    }

    function brokerBalanceOf(address owner, address tokenAddress) public view returns (uint) {

        return uint(- 1);
    }


    uint public constant PAGE_SIZE = 20;

    function getOrderBookRowCount(address tokenS, address tokenB) public view returns (uint) {

        return oasis.getOfferCount(IERC20(tokenS), IERC20(tokenB));
    }

    function getOrderBookPageCount(address tokenS, address tokenB) public view returns (uint) {

        uint numRows = getOrderBookRowCount(tokenS, tokenB);
        if (numRows % PAGE_SIZE == 0) return numRows / PAGE_SIZE;
        return (numRows / PAGE_SIZE) + 1;
    }

    function getOrderBookRows(address tokenS, address tokenB, uint pointer)
    public
    view
    returns (
        uint[] memory ids,
        uint[] memory sellAmounts,
        uint[] memory buyAmounts,
        bool[] memory isActives
    )
    {

        IERC20 sellToken = IERC20(tokenS);
        IERC20 buyToken = IERC20(tokenB);

        uint lastOfferId = pointer == 0
        ? oasis.getBestOffer(sellToken, buyToken)
        : oasis.getWorseOffer(pointer);

        ids = new uint[](PAGE_SIZE);
        sellAmounts = new uint[](PAGE_SIZE);
        buyAmounts = new uint[](PAGE_SIZE);
        isActives = new bool[](PAGE_SIZE);

        for (uint i = 0; i < PAGE_SIZE; i++) {
            ids[i] = lastOfferId;
            (sellAmounts[i], , buyAmounts[i],,,) = oasis.offers(lastOfferId);
            isActives[i] = oasis.isActive(lastOfferId);
            lastOfferId = oasis.getWorseOffer(lastOfferId);
        }
    }

    function getOrderBookRowById(uint id) public view returns (uint, uint) {

        (uint sellAmount,, uint buyAmount,,,) = oasis.offers(id);
        return (sellAmount, buyAmount);
    }
}