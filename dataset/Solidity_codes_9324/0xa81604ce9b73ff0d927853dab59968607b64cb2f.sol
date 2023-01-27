


pragma solidity ^0.5.7;
pragma experimental ABIEncoderV2;


interface IDepositContractRegistry {


    function depositAddressOf(address owner) external view returns (address payable);


    function operatorOf(address owner, address operator) external view returns (bool);


    function versionOf(address owner) external view returns (address);


    function isDepositContractCreatedFor(address owner) external view returns (bool);


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



pragma solidity ^0.5.7;


interface IDolomiteDirect {

    function brokerMarginRequestApproval(address owner, address token, uint amount) external;

}


library DyDxTypes {

    enum AssetDenomination {Wei, Par}
    enum AssetReference {Delta, Target}

    struct AssetAmount {
        bool sign;
        AssetDenomination denomination;
        AssetReference ref;
        uint256 value;
    }

    struct Price {
        uint256 value;
    }

    struct Value {
        uint256 value;
    }

    struct Wei {
        bool sign; // true if positive
        uint256 value;
    }

}

library DyDxPosition {

    struct Info {
        address owner;
        uint256 number;
    }
}

library DyDxActions {

    enum ActionType {Deposit, Withdraw, Transfer, Buy, Sell, Trade, Liquidate, Vaporize, Call}

    struct ActionArgs {
        ActionType actionType;
        uint256 accountId;
        DyDxTypes.AssetAmount amount;
        uint256 primaryMarketId;
        uint256 secondaryMarketId;
        address otherAddress;
        uint256 otherAccountId;
        bytes data;
    }
}

interface IDyDxExchangeWrapper {

    function exchange(
        address tradeOriginator,
        address receiver,
        address makerToken,
        address takerToken,
        uint256 requestedFillAmount,
        bytes calldata orderData
    ) external returns (uint256);


}

interface IDyDxCallee {

    function callFunction(address sender, DyDxPosition.Info calldata accountInfo, bytes calldata data) external;

}

contract IDyDxProtocol {

    struct OperatorArg {
        address operator;
        bool trusted;
    }

    function operate(
        DyDxPosition.Info[] calldata accounts,
        DyDxActions.ActionArgs[] calldata actions
    ) external;


    function getNumMarkets() public view returns (uint256);


    function getMarketTokenAddress(uint256 marketId) external view returns (address);


    function getMarketPrice(uint256 marketId) external view returns (DyDxTypes.Price memory);


    function getAccountWei(DyDxPosition.Info calldata account, uint256 marketId) external view returns (DyDxTypes.Wei memory);


}


library LoopringTypes {

    struct BrokerApprovalRequest {
        BrokerOrder[] orders;
        address tokenS;
        address tokenB;
        address feeToken;
        uint totalFillAmountB;
        uint totalRequestedAmountS;
        uint totalRequestedFeeAmount;
    }

    struct BrokerOrder {
        address owner;
        bytes32 orderHash;
        uint fillAmountB;
        uint requestedAmountS;
        uint requestedFeeAmount;
        address tokenRecipient;
        bytes extraData;
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



pragma solidity ^0.5.13;



library LoopringTradeDelegateHelper {


    function transferTokenFrom(
        ILoopringTradeDelegate self,
        address token,
        address from,
        address to,
        uint256 amount
    ) internal {

        bytes32[] memory transferData = new bytes32[](4);
        transferData[0] = addressToBytes32(token);
        transferData[1] = addressToBytes32(from);
        transferData[2] = addressToBytes32(to);
        transferData[3] = bytes32(amount);

        self.batchTransfer(transferData);
    }

    function addressToBytes32(address addr) private pure returns (bytes32) {

        return bytes32(uint256(addr));
    }
}



pragma solidity ^0.5.7;


library Logger {

    function revertAddress(address addr) internal pure {

        revert(_addressToString(addr));
    }

    function revertUint(uint num) internal pure {

        revert(_uintToString(num));
    }


    function _addressToString(address _addr) private pure returns (string memory) {

        bytes32 value = bytes32(uint256(_addr));
        bytes memory alphabet = "0123456789abcdef";

        bytes memory str = new bytes(51);
        str[0] = '0';
        str[1] = 'x';
        for (uint i = 0; i < 20; i++) {
            str[2 + i * 2] = alphabet[uint(uint8(value[i + 12] >> 4))];
            str[3 + i * 2] = alphabet[uint(uint8(value[i + 12] & 0x0f))];
        }
        return string(str);
    }

    function _uintToString(uint num) internal pure returns (string memory) {

        if (num == 0) {
            return "0";
        }
        uint j = num;
        uint len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint k = len - 1;
        while (num != 0) {
            bstr[k--] = byte(uint8(48 + num % 10));
            num /= 10;
        }
        return string(bstr);
    }

}

library DyDxActionBuilder {


    function Deposit(uint positionIndex, uint marketId, uint amount, address from)
    internal
    pure
    returns (DyDxActions.ActionArgs memory depositAction)
    {

        depositAction.actionType = DyDxActions.ActionType.Deposit;
        depositAction.accountId = positionIndex;
        depositAction.primaryMarketId = marketId;
        depositAction.otherAddress = from;
        depositAction.amount = DyDxTypes.AssetAmount({
            sign : true,
            denomination : DyDxTypes.AssetDenomination.Wei,
            ref : DyDxTypes.AssetReference.Delta,
            value : amount
            });
    }

    function DepositAll(uint positionIndex, uint marketId, uint burnMarketId, address controller, bytes32 orderHash)
    internal
    pure
    returns (DyDxActions.ActionArgs memory action)
    {

        action.actionType = DyDxActions.ActionType.Sell;
        action.accountId = positionIndex;
        action.otherAddress = controller;
        action.data = abi.encode(orderHash);
        action.primaryMarketId = burnMarketId;
        action.secondaryMarketId = marketId;
        action.amount = DyDxTypes.AssetAmount({
            sign : false,
            denomination : DyDxTypes.AssetDenomination.Wei,
            ref : DyDxTypes.AssetReference.Delta,
            value : 0
            });
    }


    function Withdraw(uint positionIndex, uint marketId, uint amount, address to)
    internal
    pure
    returns (DyDxActions.ActionArgs memory withdrawAction)
    {

        withdrawAction.actionType = DyDxActions.ActionType.Withdraw;
        withdrawAction.accountId = positionIndex;
        withdrawAction.primaryMarketId = marketId;
        withdrawAction.otherAddress = to;
        withdrawAction.amount = DyDxTypes.AssetAmount({
            sign : false,
            denomination : DyDxTypes.AssetDenomination.Wei,
            ref : DyDxTypes.AssetReference.Delta,
            value : amount
            });
    }

    function WithdrawAll(uint positionIndex, uint marketId, address to)
    internal
    pure
    returns (DyDxActions.ActionArgs memory withdrawAction)
    {

        withdrawAction.actionType = DyDxActions.ActionType.Withdraw;
        withdrawAction.accountId = positionIndex;
        withdrawAction.primaryMarketId = marketId;
        withdrawAction.otherAddress = to;
        withdrawAction.amount = DyDxTypes.AssetAmount({
            sign : true,
            denomination : DyDxTypes.AssetDenomination.Wei,
            ref : DyDxTypes.AssetReference.Target,
            value : 0
            });
    }





    function SetExpiry(uint positionIndex, address expiry, uint marketId, uint expiryTime)
    internal
    pure
    returns (DyDxActions.ActionArgs memory)
    {

        return ExternalCall({
            positionIndex : positionIndex,
            callee : expiry,
            data : abi.encode(marketId, expiryTime)
            });
    }

    function LoopringSettlement(
        bytes memory settlementData,
        address settlementCaller,
        uint positionIndex
    )
    internal
    pure
    returns (DyDxActions.ActionArgs memory)
    {

        return ExternalCall({
            positionIndex : positionIndex,
            callee : settlementCaller,
            data : settlementData
            });
    }

    function ExternalCall(uint positionIndex, address callee, bytes memory data)
    internal
    pure
    returns (DyDxActions.ActionArgs memory callAction)
    {

        callAction.actionType = DyDxActions.ActionType.Call;
        callAction.accountId = positionIndex;
        callAction.otherAddress = callee;
        callAction.data = data;
    }
}

library LoopringOrderDecoder {


    function decodeLoopringOrders(bytes memory ringData, uint[] memory indices) internal pure returns (Data.Order[] memory orders) {

        uint numOrders = bytesToUint16(ringData, 2);
        uint numRings = bytesToUint16(ringData, 4);
        uint numSpendables = bytesToUint16(ringData, 6);

        uint dataPtr;
        assembly {dataPtr := ringData}
        uint orderDataPtr = (dataPtr + 8) + 3 * 2;
        uint ringDataPtr = orderDataPtr + (32 * numOrders) * 2;
        uint dataBlobPtr = ringDataPtr + (numRings * 9) + 32;

        orders = new Data.Order[](indices.length);

        for (uint i = 0; i < indices.length; i++) {
            orders[i] = _decodeLoopringOrderAtIndex(dataBlobPtr, orderDataPtr + 2, numSpendables, indices[i]);
        }
    }


    function _decodeLoopringOrderAtIndex(uint data, uint tablesPtr, uint numSpendables, uint orderIndex) private pure returns (Data.Order memory order) {

        tablesPtr += 64 * orderIndex;

        uint offset;
        bytes memory emptyBytes = new bytes(0);
        address lrcTokenAddress = address(0);
        Data.Spendable[] memory spendableList = new Data.Spendable[](numSpendables);
        uint orderStructSize = 40 * 32;

        assembly {
            order := mload(0x40)
            mstore(0x40, add(order, orderStructSize)) // Reserve memory for the order struct

            offset := and(mload(add(tablesPtr, 0)), 0xFFFF)
            mstore(
            add(order, 0),
            offset
            )

            offset := mul(and(mload(add(tablesPtr, 2)), 0xFFFF), 4)
            mstore(
            add(order, 32),
            and(mload(add(add(data, 20), offset)), 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF)
            )

            offset := mul(and(mload(add(tablesPtr, 4)), 0xFFFF), 4)
            mstore(
            add(order, 64),
            and(mload(add(add(data, 20), offset)), 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF)
            )

            offset := mul(and(mload(add(tablesPtr, 6)), 0xFFFF), 4)
            mstore(
            add(order, 96),
            and(mload(add(add(data, 20), offset)), 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF)
            )

            offset := mul(and(mload(add(tablesPtr, 8)), 0xFFFF), 4)
            mstore(
            add(order, 128),
            mload(add(add(data, 32), offset))
            )

            offset := mul(and(mload(add(tablesPtr, 10)), 0xFFFF), 4)
            mstore(
            add(order, 160),
            mload(add(add(data, 32), offset))
            )

            offset := mul(and(mload(add(tablesPtr, 12)), 0xFFFF), 4)
            mstore(
            add(order, 192),
            and(mload(add(add(data, 4), offset)), 0xFFFFFFFF)
            )

            offset := and(mload(add(tablesPtr, 14)), 0xFFFF)
            offset := mul(offset, lt(offset, numSpendables))
            mstore(
            add(order, 224),
            mload(add(spendableList, mul(add(offset, 1), 32)))
            )

            offset := and(mload(add(tablesPtr, 16)), 0xFFFF)
            offset := mul(offset, lt(offset, numSpendables))
            mstore(
            add(order, 256),
            mload(add(spendableList, mul(add(offset, 1), 32)))
            )

            offset := mul(and(mload(add(tablesPtr, 18)), 0xFFFF), 4)
            mstore(
            add(order, 288),
            and(mload(add(add(data, 20), offset)), 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF)
            )

            offset := mul(and(mload(add(tablesPtr, 20)), 0xFFFF), 4)
            mstore(
            add(order, 320),
            and(mload(add(add(data, 20), offset)), 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF)
            )

            offset := mul(and(mload(add(tablesPtr, 22)), 0xFFFF), 4)
            mstore(
            add(order, 416),
            and(mload(add(add(data, 20), offset)), 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF)
            )

            offset := mul(and(mload(add(tablesPtr, 24)), 0xFFFF), 4)
            mstore(
            add(order, 448),
            and(mload(add(add(data, 20), offset)), 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF)
            )

            offset := mul(and(mload(add(tablesPtr, 26)), 0xFFFF), 4)
            mstore(
            add(order, 480),
            and(mload(add(add(data, 4), offset)), 0xFFFFFFFF)
            )

            mstore(add(data, 32), emptyBytes)

            offset := mul(and(mload(add(tablesPtr, 28)), 0xFFFF), 4)
            mstore(
            add(order, 512),
            add(data, add(offset, 32))
            )

            offset := mul(and(mload(add(tablesPtr, 30)), 0xFFFF), 4)
            mstore(
            add(order, 544),
            add(data, add(offset, 32))
            )

            mstore(add(data, 32), 0)

            offset := and(mload(add(tablesPtr, 32)), 0xFFFF)
            mstore(
            add(order, 576),
            gt(offset, 0)
            )

            mstore(add(data, 20), lrcTokenAddress)

            offset := mul(and(mload(add(tablesPtr, 34)), 0xFFFF), 4)
            mstore(
            add(order, 608),
            and(mload(add(add(data, 20), offset)), 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF)
            )

            mstore(add(data, 20), 0)

            offset := mul(and(mload(add(tablesPtr, 36)), 0xFFFF), 4)
            mstore(
            add(order, 640),
            mload(add(add(data, 32), offset))
            )

            offset := and(mload(add(tablesPtr, 38)), 0xFFFF)
            mstore(
            add(order, 672),
            offset
            )

            offset := and(mload(add(tablesPtr, 40)), 0xFFFF)
            mstore(
            add(order, 704),
            offset
            )

            offset := and(mload(add(tablesPtr, 42)), 0xFFFF)
            mstore(
            add(order, 736),
            offset
            )

            mstore(add(data, 20), mload(add(order, 32)))

            offset := mul(and(mload(add(tablesPtr, 44)), 0xFFFF), 4)
            mstore(
            add(order, 768),
            and(mload(add(add(data, 20), offset)), 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF)
            )

            mstore(add(data, 20), 0)

            offset := and(mload(add(tablesPtr, 46)), 0xFFFF)
            mstore(
            add(order, 800),
            offset
            )

            offset := and(mload(add(tablesPtr, 48)), 0xFFFF)
            mstore(
            add(order, 1024),
            offset
            )

            offset := and(mload(add(tablesPtr, 50)), 0xFFFF)
            mstore(
            add(order, 1056),
            offset
            )

            offset := and(mload(add(tablesPtr, 52)), 0xFFFF)
            mstore(
            add(order, 1088),
            offset
            )

            offset := mul(and(mload(add(tablesPtr, 54)), 0xFFFF), 4)
            mstore(
            add(order, 1120),
            mload(add(add(data, 32), offset))
            )

            offset := mul(and(mload(add(tablesPtr, 56)), 0xFFFF), 4)
            mstore(
            add(order, 1152),
            mload(add(add(data, 32), offset))
            )

            mstore(add(data, 20), 0)

            offset := mul(and(mload(add(tablesPtr, 58)), 0xFFFF), 4)
            mstore(
            add(order, 1184),
            mload(add(add(data, 32), offset))
            )

            offset := and(mload(add(tablesPtr, 60)), 0xFFFF)
            mstore(
            add(order, 1216),
            gt(offset, 0)
            )

            mstore(add(data, 32), emptyBytes)

            offset := mul(and(mload(add(tablesPtr, 62)), 0xFFFF), 4)
            mstore(
            add(order, 1248),
            add(data, add(offset, 32))
            )

            mstore(add(data, 32), 0)

            mstore(add(order, 832), 0)         // order.P2P
            mstore(add(order, 864), 0)         // order.hash
            mstore(add(order, 896), 0)         // order.brokerInterceptor
            mstore(add(order, 928), 0)         // order.filledAmountS
            mstore(add(order, 960), 0)         // order.initialFilledAmountS
            mstore(add(order, 992), 1)         // order.valid

        }
    }

    function bytesToUintX(bytes memory b, uint offset, uint numBytes) private pure returns (uint data) {

        require(b.length >= offset + numBytes, "INVALID_SIZE");
        assembly {data := mload(add(add(b, numBytes), offset))}
    }

    function bytesToUint16(bytes memory b, uint offset) private pure returns (uint16) {

        return uint16(bytesToUintX(b, offset, 2) & 0xFFFF);
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

interface IBrokerDelegate {


  function brokerRequestAllowance(BrokerData.BrokerApprovalRequest calldata request) external returns (bool);


  function onOrderFillReport(BrokerData.BrokerInterceptorReport calldata fillReport) external;


  function brokerBalanceOf(address owner, address token) external view returns (uint);

}



pragma solidity ^0.5.7;

interface IDepositContract {


    function perform(
        address addr,
        string calldata signature,
        bytes calldata encodedParams,
        uint value
    ) external returns (bytes memory);


}



pragma solidity ^0.5.7;

interface IVersionable {


  function versionBeginUsage(
    address owner,
    address payable depositAddress,
    address oldVersion,
    bytes calldata additionalData
  ) external;


  function versionEndUsage(
    address owner,
    address payable depositAddress,
    address newVersion,
    bytes calldata additionalData
  ) external;


}



pragma solidity ^0.5.7;

interface IDolomiteMarginTradingBroker {


    function brokerMarginRequestApproval(address owner, address token, uint amount) external;


    function brokerMarginGetTrader(address owner, bytes calldata orderData) external view returns (address);

}



pragma solidity ^0.5.7;


library DepositContractImpl {


    function wrapAndTransferToken(
        IDepositContract self,
        address token,
        address recipient,
        uint amount,
        address wethAddress
    ) internal {

        if (token == wethAddress) {
            uint etherBalance = address(self).balance;
            if (etherBalance > 0) {
                wrapEth(self, token, etherBalance);
            }
        }
        transferToken(self, token, recipient, amount);
    }

    function transferToken(IDepositContract self, address token, address recipient, uint amount) internal {

        self.perform(token, "transfer(address,uint256)", abi.encode(recipient, amount), 0);
    }

    function transferEth(IDepositContract self, address recipient, uint amount) internal {

        self.perform(recipient, "", abi.encode(), amount);
    }

    function approveToken(IDepositContract self, address token, address broker, uint amount) internal {

        self.perform(token, "approve(address,uint256)", abi.encode(broker, amount), 0);
    }

    function wrapEth(IDepositContract self, address wethToken, uint amount) internal {

        self.perform(wethToken, "deposit()", abi.encode(), amount);
    }

    function unwrapWeth(IDepositContract self, address wethToken, uint amount) internal {

        self.perform(wethToken, "withdraw(uint256)", abi.encode(amount), 0);
    }

    function setDyDxOperator(IDepositContract self, address dydxContract, address operator) internal {

        bytes memory encodedParams = abi.encode(
            bytes32(0x0000000000000000000000000000000000000000000000000000000000000020),
            bytes32(0x0000000000000000000000000000000000000000000000000000000000000001),
            operator,
            bytes32(0x0000000000000000000000000000000000000000000000000000000000000001)
        );
        self.perform(dydxContract, "setOperators((address,bool)[])", encodedParams, 0);
    }
}



pragma solidity ^0.5.7;
library Types {


    struct RequestFee {
        address feeRecipient;
        address feeToken;
        uint feeAmount;
    }

    struct RequestSignature {
        uint8 v;
        bytes32 r;
        bytes32 s;
    }

    enum RequestType {Update, Transfer, Approve, Perform, DepositCollateral, WithdrawCollateral}

    struct Request {
        address owner;
        address target;
        RequestType requestType;
        bytes payload;
        uint nonce;
        RequestFee fee;
        RequestSignature signature;
    }

    struct TransferRequest {
        address token;
        address recipient;
        uint amount;
        bool unwrap;
    }

    struct UpdateRequest {
        address version;
        bytes additionalData;
    }

    struct ApproveRequest {
        address operator;
        bool canOperate;
    }

    struct PerformRequest {
        address to;
        string functionSignature;
        bytes encodedParams;
        uint value;
    }

    struct DepositCollateralRequest {
        uint positionId;
        uint tokenId;
        uint amount;
    }

    struct WithdrawCollateralRequest {
        uint positionId;
        uint tokenId;
        uint amount;
    }

}



pragma solidity ^0.5.7;


library RequestImpl {


    bytes constant personalPrefix = "\x19Ethereum Signed Message:\n32";

    function getSigner(Types.Request memory self) internal pure returns (address) {

        bytes32 messageHash = keccak256(abi.encode(
                self.owner,
                self.target,
                self.requestType,
                self.payload,
                self.nonce,
                abi.encode(self.fee.feeRecipient, self.fee.feeToken, self.fee.feeAmount)
            ));

        bytes32 prefixedHash = keccak256(abi.encodePacked(personalPrefix, messageHash));
        return ecrecover(prefixedHash, self.signature.v, self.signature.r, self.signature.s);
    }

    function decodeTransferRequest(Types.Request memory self)
    internal
    pure
    returns (Types.TransferRequest memory){

        require(self.requestType == Types.RequestType.Transfer, "INVALID_REQUEST_TYPE");

        (
        address token,
        address recipient,
        uint amount,
        bool unwrap
        ) = abi.decode(self.payload, (address, address, uint, bool));

        return Types.TransferRequest({
        token : token,
        recipient : recipient,
        amount : amount,
        unwrap : unwrap
        });
    }

    function decodeDepositCollateralRequest(Types.Request memory self)
    internal
    pure
    returns (Types.DepositCollateralRequest memory){

        require(self.requestType == Types.RequestType.DepositCollateral, "INVALID_REQUEST_TYPE");

        (
        uint positionId,
        uint tokenId,
        uint amount
        ) = abi.decode(self.payload, (uint, uint, uint));

        return Types.DepositCollateralRequest({
        positionId: positionId,
        tokenId: tokenId,
        amount: amount
        });
    }

    function decodeWithdrawCollateralRequest(Types.Request memory self)
    internal
    pure
    returns (Types.WithdrawCollateralRequest memory){

        require(self.requestType == Types.RequestType.WithdrawCollateral, "INVALID_REQUEST_TYPE");

        (
        uint positionId,
        uint tokenId,
        uint amount
        ) = abi.decode(self.payload, (uint, uint, uint));

        return Types.WithdrawCollateralRequest({
        positionId: positionId,
        tokenId: tokenId,
        amount: amount
        });
    }

    function decodeUpdateRequest(Types.Request memory self)
    internal
    pure
    returns (Types.UpdateRequest memory updateRequest)
    {

        require(self.requestType == Types.RequestType.Update, "INVALID_REQUEST_TYPE");

        (
        updateRequest.version,
        updateRequest.additionalData
        ) = abi.decode(self.payload, (address, bytes));
    }

    function decodeApproveRequest(Types.Request memory self)
    internal
    pure
    returns (Types.ApproveRequest memory approveRequest)
    {

        require(self.requestType == Types.RequestType.Approve, "INVALID_REQUEST_TYPE");

        (
        approveRequest.operator,
        approveRequest.canOperate
        ) = abi.decode(self.payload, (address, bool));
    }

    function decodePerformRequest(Types.Request memory self)
    internal
    pure
    returns (Types.PerformRequest memory performRequest)
    {

        require(self.requestType == Types.RequestType.Perform, "INVALID_REQUEST_TYPE");

        (
        performRequest.to,
        performRequest.functionSignature,
        performRequest.encodedParams,
        performRequest.value
        ) = abi.decode(self.payload, (address, string, bytes, uint));
    }

}


contract Requestable {


    using RequestImpl for Types.Request;

    mapping(address => uint) nonces;

    function validateRequest(Types.Request memory request) internal {

        require(request.target == address(this), "INVALID_TARGET");
        require(request.getSigner() == request.owner, "INVALID_SIGNATURE");
        require(nonces[request.owner] + 1 == request.nonce, "INVALID_NONCE");

        if (request.fee.feeAmount > 0) {
            require(balanceOf(request.owner, request.fee.feeToken) >= request.fee.feeAmount, "INSUFFICIENT_FEE_BALANCE");
        }

        nonces[request.owner] += 1;
    }

    function completeRequest(Types.Request memory request) internal {

        if (request.fee.feeAmount > 0) {
            _payRequestFee(request.owner, request.fee.feeToken, request.fee.feeRecipient, request.fee.feeAmount);
        }
    }

    function nonceOf(address owner) public view returns (uint) {

        return nonces[owner];
    }

    function balanceOf(address owner, address token) public view returns (uint);

    function _payRequestFee(address owner, address feeToken, address feeRecipient, uint feeAmount) internal;

}


pragma solidity ^0.5.7;












contract DolomiteDirectV1 is Requestable, IVersionable, IDolomiteMarginTradingBroker {

    using DepositContractImpl for IDepositContract;
    using SafeMath for uint;

    IDepositContractRegistry public registry;
    address public loopringDelegate;
    address public dolomiteMarginProtocolAddress;
    address public dydxProtocolAddress;
    address public wethTokenAddress;

    constructor(
        address _depositContractRegistry,
        address _loopringDelegate,
        address _dolomiteMarginProtocol,
        address _dydxProtocolAddress,
        address _wethTokenAddress
    ) public {
        registry = IDepositContractRegistry(_depositContractRegistry);
        loopringDelegate = _loopringDelegate;
        dolomiteMarginProtocolAddress = _dolomiteMarginProtocol;
        dydxProtocolAddress = _dydxProtocolAddress;
        wethTokenAddress = _wethTokenAddress;
    }

    function balanceOf(address owner, address token) public view returns (uint) {

        address depositAddress = registry.depositAddressOf(owner);
        uint tokenBalance = IERC20(token).balanceOf(depositAddress);
        if (token == wethTokenAddress) tokenBalance = tokenBalance.add(depositAddress.balance);
        return tokenBalance;
    }

    function transfer(Types.Request memory request) public {

        validateRequest(request);

        Types.TransferRequest memory transferRequest = request.decodeTransferRequest();
        address payable depositAddress = registry.depositAddressOf(request.owner);

        _transfer(
            transferRequest.token,
            depositAddress,
            transferRequest.recipient,
            transferRequest.amount,
            transferRequest.unwrap
        );

        completeRequest(request);
    }


    function _transfer(address token, address payable depositAddress, address recipient, uint amount, bool unwrap) internal {

        IDepositContract depositContract = IDepositContract(depositAddress);

        if (token == wethTokenAddress && unwrap) {
            if (depositAddress.balance < amount) {
                depositContract.unwrapWeth(wethTokenAddress, amount.sub(depositAddress.balance));
            }

            depositContract.transferEth(recipient, amount);
            return;
        }

        depositContract.wrapAndTransferToken(token, recipient, amount, wethTokenAddress);
    }


    function brokerRequestAllowance(BrokerData.BrokerApprovalRequest memory request) public returns (bool) {

        require(msg.sender == loopringDelegate);

        BrokerData.BrokerOrder[] memory mergedOrders = new BrokerData.BrokerOrder[](request.orders.length);
        uint numMergedOrders = 1;

        mergedOrders[0] = request.orders[0];

        if (request.orders.length > 1) {
            for (uint i = 1; i < request.orders.length; i++) {
                bool isDuplicate = false;

                for (uint b = 0; b < numMergedOrders; b++) {
                    if (request.orders[i].owner == mergedOrders[b].owner) {
                        mergedOrders[b].requestedAmountS += request.orders[i].requestedAmountS;
                        mergedOrders[b].requestedFeeAmount += request.orders[i].requestedFeeAmount;
                        isDuplicate = true;
                        break;
                    }
                }

                if (!isDuplicate) {
                    mergedOrders[numMergedOrders] = request.orders[i];
                    numMergedOrders += 1;
                }
            }
        }

        for (uint j = 0; j < numMergedOrders; j++) {
            BrokerData.BrokerOrder memory order = mergedOrders[j];
            address payable depositAddress = registry.depositAddressOf(order.owner);

            _transfer(request.tokenS, depositAddress, address(this), order.requestedAmountS, false);
            if (order.requestedFeeAmount > 0) _transfer(request.feeToken, depositAddress, address(this), order.requestedFeeAmount, false);
        }

        return false;
    }

    function onOrderFillReport(BrokerData.BrokerInterceptorReport memory fillReport) public {

    }

    function brokerBalanceOf(address owner, address tokenAddress) public view returns (uint) {

        return balanceOf(owner, tokenAddress);
    }


    function brokerMarginRequestApproval(address owner, address token, uint amount) public {

        require(msg.sender == dolomiteMarginProtocolAddress || msg.sender == loopringDelegate, "brokerMarginRequestApproval: INVALID_SENDER");

        address payable depositAddress = registry.depositAddressOf(owner);
        _transfer(token, depositAddress, address(this), amount, false);
    }

    function brokerMarginGetTrader(address owner, bytes memory orderData) public view returns (address) {

        return registry.depositAddressOf(owner);
    }


    function _payRequestFee(address owner, address feeToken, address feeRecipient, uint feeAmount) internal {

        _transfer(feeToken, registry.depositAddressOf(owner), feeRecipient, feeAmount, false);
    }


    function versionBeginUsage(
        address owner,
        address payable depositAddress,
        address oldVersion,
        bytes calldata additionalData
    ) external {

        IDepositContract(depositAddress).setDyDxOperator(dydxProtocolAddress, dolomiteMarginProtocolAddress);
    }

    function versionEndUsage(
        address owner,
        address payable depositAddress,
        address newVersion,
        bytes calldata additionalData
    ) external {/* do nothing */}




    function enableTrading(address token) public {

        IERC20(token).approve(loopringDelegate, uint(- 1));
        IERC20(token).approve(dolomiteMarginProtocolAddress, uint(- 1));
    }

    function enableTrading(address[] calldata tokens) external {

        for (uint i = 0; i < tokens.length; i++) {
            enableTrading(tokens[i]);
        }
    }

}



pragma solidity ^0.5.7;




contract DolomiteDirectV2 is DolomiteDirectV1 {


    constructor(
        address _depositContractRegistry,
        address _loopringDelegate,
        address _dolomiteMarginProtocol,
        address _dydxProtocolAddress,
        address _wethTokenAddress
    ) public DolomiteDirectV1(
        _depositContractRegistry,
        _loopringDelegate,
        _dolomiteMarginProtocol,
        _dydxProtocolAddress,
        _wethTokenAddress
    ) {
    }

    function depositCollateral(Types.Request memory request) public {

        validateRequest(request);

        Types.DepositCollateralRequest memory depositCollateralRequest = request.decodeDepositCollateralRequest();
        address payable depositAddress = registry.depositAddressOf(request.owner);

        address token = IDyDxProtocol(dydxProtocolAddress).getMarketTokenAddress(depositCollateralRequest.tokenId);

        uint amount;
        if (depositCollateralRequest.amount == uint(- 1)) {
            amount = IERC20(token).balanceOf(depositAddress);
        } else {
            amount = depositCollateralRequest.amount;
        }

        _transfer(
            token,
            depositAddress,
            address(this),
            amount,
            false
        );

        _depositCollateralIntoDyDx(
            depositAddress,
            depositCollateralRequest.positionId,
            depositCollateralRequest.tokenId,
            amount
        );

        completeRequest(request);
    }

    function withdrawCollateral(Types.Request memory request) public {

        validateRequest(request);

        Types.WithdrawCollateralRequest memory withdrawCollateralRequest = request.decodeWithdrawCollateralRequest();
        address payable depositAddress = registry.depositAddressOf(request.owner);

        _withdrawCollateralFromDyDx(
            depositAddress,
            withdrawCollateralRequest.positionId,
            withdrawCollateralRequest.tokenId,
            withdrawCollateralRequest.amount
        );

        completeRequest(request);
    }

    function versionBeginUsage(
        address owner,
        address payable depositAddress,
        address oldVersion,
        bytes calldata additionalData
    ) external {

        IDepositContract(depositAddress).setDyDxOperator(dydxProtocolAddress, address(this));
    }


    function _depositCollateralIntoDyDx(
        address depositAddress,
        uint positionId,
        uint tokenId,
        uint amount
    ) internal {

        DyDxPosition.Info[] memory infos = new DyDxPosition.Info[](1);
        infos[0] = DyDxPosition.Info(depositAddress, positionId);

        DyDxActions.ActionArgs[] memory args = new DyDxActions.ActionArgs[](1);
        args[0] = DyDxActionBuilder.Deposit(0, tokenId, amount, /* from */ address(this));

        IDyDxProtocol(dydxProtocolAddress).operate(infos, args);
    }

    function _withdrawCollateralFromDyDx(
        address depositAddress,
        uint positionId,
        uint tokenId,
        uint amount
    ) internal {

        DyDxPosition.Info[] memory infos = new DyDxPosition.Info[](1);
        infos[0] = DyDxPosition.Info(depositAddress, positionId);

        DyDxActions.ActionArgs[] memory args = new DyDxActions.ActionArgs[](1);
        if (amount == uint(- 1)) {
            args[0] = DyDxActionBuilder.WithdrawAll(0, tokenId, /* to */ depositAddress);
        } else {
            args[0] = DyDxActionBuilder.Withdraw(0, tokenId, amount, /* to */ depositAddress);
        }

        IDyDxProtocol(dydxProtocolAddress).operate(infos, args);
    }

}

