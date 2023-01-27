
pragma solidity 0.4.24;
pragma experimental "v0.5.0";



library SafeMath {


  function mul(uint256 _a, uint256 _b) internal pure returns (uint256 c) {

    if (_a == 0) {
      return 0;
    }

    c = _a * _b;
    assert(c / _a == _b);
    return c;
  }

  function div(uint256 _a, uint256 _b) internal pure returns (uint256) {

    return _a / _b;
  }

  function sub(uint256 _a, uint256 _b) internal pure returns (uint256) {

    assert(_b <= _a);
    return _a - _b;
  }

  function add(uint256 _a, uint256 _b) internal pure returns (uint256 c) {

    c = _a + _b;
    assert(c >= _a);
    return c;
  }
}


contract ZeroExExchangeInterfaceV1 {

    enum Errors {
        ORDER_EXPIRED,                    // Order has already expired
        ORDER_FULLY_FILLED_OR_CANCELLED,  // Order has already been fully filled or cancelled
        ROUNDING_ERROR_TOO_LARGE,         // Rounding error too large
        INSUFFICIENT_BALANCE_OR_ALLOWANCE // Insufficient balance or allowance for token transfer
    }

    string constant public VERSION = "1.0.0";
    uint16 constant public EXTERNAL_QUERY_GAS_LIMIT = 4999;    // Changes to state require at least 5000 gas

    address public ZRX_TOKEN_CONTRACT;
    address public TOKEN_TRANSFER_PROXY_CONTRACT;

    mapping (bytes32 => uint256) public filled;
    mapping (bytes32 => uint256) public cancelled;


    function fillOrder(
        address[5] orderAddresses,
        uint256[6] orderValues,
        uint256 fillTakerTokenAmount,
        bool shouldThrowOnInsufficientBalanceOrAllowance,
        uint8 v,
        bytes32 r,
        bytes32 s)
        public
        returns (uint256 filledTakerTokenAmount);


    function cancelOrder(
        address[5] orderAddresses,
        uint256[6] orderValues,
        uint256 cancelTakerTokenAmount)
        public
        returns (uint256);



    function fillOrKillOrder(
        address[5] orderAddresses,
        uint256[6] orderValues,
        uint256 fillTakerTokenAmount,
        uint8 v,
        bytes32 r,
        bytes32 s)
        public;


    function batchFillOrders(
        address[5][] orderAddresses,
        uint256[6][] orderValues,
        uint256[] fillTakerTokenAmounts,
        bool shouldThrowOnInsufficientBalanceOrAllowance,
        uint8[] v,
        bytes32[] r,
        bytes32[] s)
        public;


    function batchFillOrKillOrders(
        address[5][] orderAddresses,
        uint256[6][] orderValues,
        uint256[] fillTakerTokenAmounts,
        uint8[] v,
        bytes32[] r,
        bytes32[] s)
        public;


    function fillOrdersUpTo(
        address[5][] orderAddresses,
        uint256[6][] orderValues,
        uint256 fillTakerTokenAmount,
        bool shouldThrowOnInsufficientBalanceOrAllowance,
        uint8[] v,
        bytes32[] r,
        bytes32[] s)
        public
        returns (uint256);


    function batchCancelOrders(
        address[5][] orderAddresses,
        uint256[6][] orderValues,
        uint256[] cancelTakerTokenAmounts)
        public;



    function getOrderHash(address[5] orderAddresses, uint256[6] orderValues)
        public
        view
        returns (bytes32);


    function isValidSignature(
        address signer,
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s)
        public
        pure
        returns (bool);


    function isRoundingError(uint256 numerator, uint256 denominator, uint256 target)
        public
        pure
        returns (bool);


    function getPartialAmount(uint256 numerator, uint256 denominator, uint256 target)
        public
        pure
        returns (uint256);


    function getUnavailableTakerTokenAmount(bytes32 orderHash)
        public
        view
        returns (uint256);

}


library MathHelpers {

    using SafeMath for uint256;

    function getPartialAmount(
        uint256 numerator,
        uint256 denominator,
        uint256 target
    )
        internal
        pure
        returns (uint256)
    {

        return numerator.mul(target).div(denominator);
    }

    function getPartialAmountRoundedUp(
        uint256 numerator,
        uint256 denominator,
        uint256 target
    )
        internal
        pure
        returns (uint256)
    {

        return divisionRoundedUp(numerator.mul(target), denominator);
    }

    function divisionRoundedUp(
        uint256 numerator,
        uint256 denominator
    )
        internal
        pure
        returns (uint256)
    {

        assert(denominator != 0); // coverage-enable-line
        if (numerator == 0) {
            return 0;
        }
        return numerator.sub(1).div(denominator).add(1);
    }

    function maxUint256(
    )
        internal
        pure
        returns (uint256)
    {

        return 2 ** 256 - 1;
    }

    function maxUint32(
    )
        internal
        pure
        returns (uint32)
    {

        return 2 ** 32 - 1;
    }

    function getNumBits(
        uint256 n
    )
        internal
        pure
        returns (uint256)
    {

        uint256 first = 0;
        uint256 last = 256;
        while (first < last) {
            uint256 check = (first + last) / 2;
            if ((n >> check) == 0) {
                last = check;
            } else {
                first = check + 1;
            }
        }
        assert(first <= 256);
        return first;
    }
}


interface GeneralERC20 {

    function totalSupply(
    )
        external
        view
        returns (uint256);


    function balanceOf(
        address who
    )
        external
        view
        returns (uint256);


    function allowance(
        address owner,
        address spender
    )
        external
        view
        returns (uint256);


    function transfer(
        address to,
        uint256 value
    )
        external;



    function transferFrom(
        address from,
        address to,
        uint256 value
    )
        external;


    function approve(
        address spender,
        uint256 value
    )
        external;

}


library TokenInteract {

    function balanceOf(
        address token,
        address owner
    )
        internal
        view
        returns (uint256)
    {

        return GeneralERC20(token).balanceOf(owner);
    }

    function allowance(
        address token,
        address owner,
        address spender
    )
        internal
        view
        returns (uint256)
    {

        return GeneralERC20(token).allowance(owner, spender);
    }

    function approve(
        address token,
        address spender,
        uint256 amount
    )
        internal
    {

        GeneralERC20(token).approve(spender, amount);

        require(
            checkSuccess(),
            "TokenInteract#approve: Approval failed"
        );
    }

    function transfer(
        address token,
        address to,
        uint256 amount
    )
        internal
    {

        address from = address(this);
        if (
            amount == 0
            || from == to
        ) {
            return;
        }

        GeneralERC20(token).transfer(to, amount);

        require(
            checkSuccess(),
            "TokenInteract#transfer: Transfer failed"
        );
    }

    function transferFrom(
        address token,
        address from,
        address to,
        uint256 amount
    )
        internal
    {

        if (
            amount == 0
            || from == to
        ) {
            return;
        }

        GeneralERC20(token).transferFrom(from, to, amount);

        require(
            checkSuccess(),
            "TokenInteract#transferFrom: TransferFrom failed"
        );
    }


    function checkSuccess(
    )
        private
        pure
        returns (bool)
    {

        uint256 returnValue = 0;

        assembly {
            switch returndatasize

            case 0x0 {
                returnValue := 1
            }

            case 0x20 {
                returndatacopy(0x0, 0x0, 0x20)

                returnValue := mload(0x0)
            }

            default { }
        }

        return returnValue != 0;
    }
}


interface ExchangeReader {



    function getMaxMakerAmount(
        address makerToken,
        address takerToken,
        bytes orderData
    )
        external
        view
        returns (uint256);

}


interface ExchangeWrapper {



    function exchange(
        address tradeOriginator,
        address receiver,
        address makerToken,
        address takerToken,
        uint256 requestedFillAmount,
        bytes orderData
    )
        external
        returns (uint256);


    function getExchangeCost(
        address makerToken,
        address takerToken,
        uint256 desiredMakerToken,
        bytes orderData
    )
        external
        view
        returns (uint256);

}


contract ZeroExV1ExchangeWrapper is
    ExchangeWrapper,
    ExchangeReader
{

    using SafeMath for uint256;
    using TokenInteract for address;


    struct Order {
        address maker;
        address taker;
        address feeRecipient;
        uint256 makerTokenAmount;
        uint256 takerTokenAmount;
        uint256 makerFee;
        uint256 takerFee;
        uint256 expirationUnixTimestampSec;
        uint256 salt;
        uint8 v;
        bytes32 r;
        bytes32 s;
    }


    mapping (address => bool) public TRUSTED_MSG_SENDER;

    address public ZERO_EX_EXCHANGE;

    address public ZERO_EX_TOKEN_PROXY;

    address public ZRX;


    constructor(
        address zeroExExchange,
        address zeroExProxy,
        address zrxToken,
        address[] trustedMsgSenders
    )
        public
    {
        ZERO_EX_EXCHANGE = zeroExExchange;
        ZERO_EX_TOKEN_PROXY = zeroExProxy;
        ZRX = zrxToken;

        for (uint256 i = 0; i < trustedMsgSenders.length; i++) {
            TRUSTED_MSG_SENDER[trustedMsgSenders[i]] = true;
        }

        ZRX.approve(ZERO_EX_TOKEN_PROXY, MathHelpers.maxUint256());
    }


    function exchange(
        address tradeOriginator,
        address receiver,
        address makerToken,
        address takerToken,
        uint256 requestedFillAmount,
        bytes orderData
    )
        external
        returns (uint256)
    {

        Order memory order = parseOrder(orderData);

        require(
            requestedFillAmount <= order.takerTokenAmount,
            "ZeroExV1ExchangeWrapper#exchange: Requested fill amount larger than order size"
        );

        require(
            requestedFillAmount <= takerToken.balanceOf(address(this)),
            "ZeroExV1ExchangeWrapper#exchange: Requested fill amount larger than tokens held"
        );

        transferTakerFee(
            order,
            tradeOriginator,
            requestedFillAmount
        );

        ensureAllowance(
            takerToken,
            ZERO_EX_TOKEN_PROXY,
            requestedFillAmount
        );

        uint256 receivedMakerTokenAmount = doTrade(
            order,
            makerToken,
            takerToken,
            requestedFillAmount
        );

        ensureAllowance(
            makerToken,
            receiver,
            receivedMakerTokenAmount
        );

        return receivedMakerTokenAmount;
    }

    function getExchangeCost(
        address /* makerToken */,
        address /* takerToken */,
        uint256 desiredMakerToken,
        bytes orderData
    )
        external
        view
        returns (uint256)
    {

        Order memory order = parseOrder(orderData);

        return MathHelpers.getPartialAmountRoundedUp(
            order.takerTokenAmount,
            order.makerTokenAmount,
            desiredMakerToken
        );
    }

    function getMaxMakerAmount(
        address makerToken,
        address takerToken,
        bytes orderData
    )
        external
        view
        returns (uint256)
    {

        address zeroExExchange = ZERO_EX_EXCHANGE;
        Order memory order = parseOrder(orderData);

        if (block.timestamp >= order.expirationUnixTimestampSec) {
            return 0;
        }

        bytes32 orderHash = getOrderHash(
            zeroExExchange,
            makerToken,
            takerToken,
            order
        );

        uint256 unavailableTakerAmount =
            ZeroExExchangeInterfaceV1(zeroExExchange).getUnavailableTakerTokenAmount(orderHash);
        uint256 takerAmount = order.takerTokenAmount.sub(unavailableTakerAmount);
        uint256 makerAmount = MathHelpers.getPartialAmount(
            takerAmount,
            order.takerTokenAmount,
            order.makerTokenAmount
        );

        return makerAmount;
    }


    function transferTakerFee(
        Order memory order,
        address tradeOriginator,
        uint256 requestedFillAmount
    )
        private
    {

        if (order.feeRecipient == address(0)) {
            return;
        }

        uint256 takerFee = MathHelpers.getPartialAmount(
            requestedFillAmount,
            order.takerTokenAmount,
            order.takerFee
        );

        if (takerFee == 0) {
            return;
        }

        require(
            TRUSTED_MSG_SENDER[msg.sender],
            "ZeroExV1ExchangeWrapper#transferTakerFee: Only trusted senders can dictate the fee payer"
        );

        ZRX.transferFrom(
            tradeOriginator,
            address(this),
            takerFee
        );
    }

    function doTrade(
        Order memory order,
        address makerToken,
        address takerToken,
        uint256 requestedFillAmount
    )
        private
        returns (uint256)
    {

        uint256 filledTakerTokenAmount = ZeroExExchangeInterfaceV1(ZERO_EX_EXCHANGE).fillOrder(
            [
                order.maker,
                order.taker,
                makerToken,
                takerToken,
                order.feeRecipient
            ],
            [
                order.makerTokenAmount,
                order.takerTokenAmount,
                order.makerFee,
                order.takerFee,
                order.expirationUnixTimestampSec,
                order.salt
            ],
            requestedFillAmount,
            true,
            order.v,
            order.r,
            order.s
        );

        require(
            filledTakerTokenAmount == requestedFillAmount,
            "ZeroExV1ExchangeWrapper#doTrade: Could not fill requested amount"
        );

        uint256 receivedMakerTokenAmount = MathHelpers.getPartialAmount(
            filledTakerTokenAmount,
            order.takerTokenAmount,
            order.makerTokenAmount
        );

        return receivedMakerTokenAmount;
    }

    function ensureAllowance(
        address token,
        address spender,
        uint256 requiredAmount
    )
        private
    {

        if (token.allowance(address(this), spender) >= requiredAmount) {
            return;
        }

        token.approve(
            spender,
            MathHelpers.maxUint256()
        );
    }

    function getOrderHash(
        address exchangeAddress,
        address makerToken,
        address takerToken,
        Order memory order
    )
        private
        pure
        returns (bytes32)
    {

        return keccak256(
            abi.encodePacked(
                exchangeAddress,
                order.maker,
                order.taker,
                makerToken,
                takerToken,
                order.feeRecipient,
                order.makerTokenAmount,
                order.takerTokenAmount,
                order.makerFee,
                order.takerFee,
                order.expirationUnixTimestampSec,
                order.salt
            )
        );
    }

    function parseOrder(
        bytes orderData
    )
        private
        pure
        returns (Order memory)
    {

        Order memory order;

        assembly {
            mstore(order,           mload(add(orderData, 32)))  // maker
            mstore(add(order, 32),  mload(add(orderData, 64)))  // taker
            mstore(add(order, 64),  mload(add(orderData, 96)))  // feeRecipient
            mstore(add(order, 96),  mload(add(orderData, 128))) // makerTokenAmount
            mstore(add(order, 128), mload(add(orderData, 160))) // takerTokenAmount
            mstore(add(order, 160), mload(add(orderData, 192))) // makerFee
            mstore(add(order, 192), mload(add(orderData, 224))) // takerFee
            mstore(add(order, 224), mload(add(orderData, 256))) // expirationUnixTimestampSec
            mstore(add(order, 256), mload(add(orderData, 288))) // salt
            mstore(add(order, 288), mload(add(orderData, 320))) // v
            mstore(add(order, 320), mload(add(orderData, 352))) // r
            mstore(add(order, 352), mload(add(orderData, 384))) // s
        }

        return order;
    }
}