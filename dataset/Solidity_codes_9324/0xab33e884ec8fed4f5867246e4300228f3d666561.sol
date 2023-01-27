
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


contract ISimpleMarketV1 {



    struct OfferInfo {
        uint256     pay_amt;
        address  pay_gem;
        uint256     buy_amt;
        address  buy_gem;
        address  owner;
        uint64   timestamp;
    }


    uint256 public last_offer_id;

    mapping (uint256 => OfferInfo) public offers;


    function isActive(
        uint256 id
    )
        public
        view
        returns (bool active );


    function getOwner(
        uint256 id
    )
        public
        view
        returns (address owner);


    function getOffer(
        uint256 id
    )
        public
        view
        returns (uint, address, uint, address);


    function bump(
        bytes32 id_
    )
        public;


    function buy(
        uint256 id,
        uint256 quantity
    )
        public
        returns (bool);


    function cancel(
        uint256 id
    )
        public
        returns (bool success);


    function kill(
        bytes32 id
    )
        public;


    function make(
        address  pay_gem,
        address  buy_gem,
        uint128  pay_amt,
        uint128  buy_amt
    )
        public
        returns (bytes32 id);


    function offer(
        uint256 pay_amt,
        address pay_gem,
        uint256 buy_amt,
        address buy_gem
    )
        public
        returns (uint256 id);


    function take(
        bytes32 id,
        uint128 maxTakeAmount
    )
        public;

}


contract IMatchingMarketV1 is ISimpleMarketV1 {



    struct sortInfo {
        uint256 next;  //points to id of next higher offer
        uint256 prev;  //points to id of previous lower offer
        uint256 delb;  //the blocknumber where this entry was marked for delete
    }


    uint64 public close_time;

    bool public stopped;

    bool public buyEnabled;

    bool public matchingEnabled;

    mapping(uint256 => sortInfo) public _rank;

    mapping(address => mapping(address => uint)) public _best;

    mapping(address => mapping(address => uint)) public _span;

    mapping(address => uint) public _dust;

    mapping(uint256 => uint) public _near;

    mapping(bytes32 => bool) public _menu;


    function make(
        address  pay_gem,
        address  buy_gem,
        uint128  pay_amt,
        uint128  buy_amt
    )
        public
        returns (bytes32);


    function take(
        bytes32 id,
        uint128 maxTakeAmount
    )
        public;


    function kill(
        bytes32 id
    )
        public;


    function offer(
        uint256 pay_amt,
        address pay_gem,
        uint256 buy_amt,
        address buy_gem
    )
        public
        returns (uint);


    function offer(
        uint256 pay_amt,
        address pay_gem,
        uint256 buy_amt,
        address buy_gem,
        uint256 pos
    )
        public
        returns (uint);


    function offer(
        uint256 pay_amt,
        address pay_gem,
        uint256 buy_amt,
        address buy_gem,
        uint256 pos,
        bool rounding
    )
        public
        returns (uint);


    function buy(
        uint256 id,
        uint256 amount
    )
        public
        returns (bool);


    function cancel(
        uint256 id
    )
        public
        returns (bool success);


    function insert(
        uint256 id,
        uint256 pos
    )
        public
        returns (bool);


    function del_rank(
        uint256 id
    )
        public
        returns (bool);


    function sellAllAmount(
        address pay_gem,
        uint256 pay_amt,
        address buy_gem,
        uint256 min_fill_amount
    )
        public
        returns (uint256 fill_amt);


    function buyAllAmount(
        address buy_gem,
        uint256 buy_amt,
        address pay_gem,
        uint256 max_fill_amount
    )
        public
        returns (uint256 fill_amt);



    function isTokenPairWhitelisted(
        address baseToken,
        address quoteToken
    )
        public
        view
        returns (bool);


    function getMinSell(
        address pay_gem
    )
        public
        view
        returns (uint);


    function getBestOffer(
        address sell_gem,
        address buy_gem
    )
        public
        view
        returns(uint);


    function getWorseOffer(
        uint256 id
    )
        public
        view
        returns(uint);


    function getBetterOffer(
        uint256 id
    )
        public
        view
        returns(uint);


    function getOfferCount(
        address sell_gem,
        address buy_gem
    )
        public
        view
        returns(uint);


    function getFirstUnsortedOffer()
        public
        view
        returns(uint);


    function getNextUnsortedOffer(
        uint256 id
    )
        public
        view
        returns(uint);


    function isOfferSorted(
        uint256 id
    )
        public
        view
        returns(bool);


    function getBuyAmount(
        address buy_gem,
        address pay_gem,
        uint256 pay_amt
    )
        public
        view
        returns (uint256 fill_amt);


    function getPayAmount(
        address pay_gem,
        address buy_gem,
        uint256 buy_amt
    )
        public
        view
        returns (uint256 fill_amt);


    function isClosed()
        public
        view
        returns (bool closed);


    function getTime()
        public
        view
        returns (uint64);

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


library AdvancedTokenInteract {

    using TokenInteract for address;

    function ensureAllowance(
        address token,
        address spender,
        uint256 amount
    )
        internal
    {

        if (token.allowance(address(this), spender) < amount) {
            token.approve(spender, MathHelpers.maxUint256());
        }
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


contract OasisV3MatchingExchangeWrapper is
    ExchangeWrapper,
    ExchangeReader
{

    using SafeMath for uint256;
    using TokenInteract for address;
    using AdvancedTokenInteract for address;


    struct Offer {
        uint256 makerAmount;
        address makerToken;
        uint256 takerAmount;
        address takerToken;
    }


    IMatchingMarketV1 public MATCHING_MARKET;


    constructor(
        IMatchingMarketV1 matchingMarket
    )
        public
    {
        MATCHING_MARKET = matchingMarket;
    }


    function exchange(
        address /*tradeOriginator*/,
        address receiver,
        address makerToken,
        address takerToken,
        uint256 requestedFillAmount,
        bytes orderData
    )
        external
        returns (uint256)
    {

        IMatchingMarketV1 market = MATCHING_MARKET;

        takerToken.ensureAllowance(address(market), requestedFillAmount);

        uint256 receivedMakerAmount = market.sellAllAmount(
            takerToken,
            requestedFillAmount,
            makerToken,
            0
        );

        requireBelowMaximumPrice(requestedFillAmount, receivedMakerAmount, orderData);

        makerToken.ensureAllowance(receiver, receivedMakerAmount);

        return receivedMakerAmount;
    }

    function getExchangeCost(
        address makerToken,
        address takerToken,
        uint256 desiredMakerToken,
        bytes orderData
    )
        external
        view
        returns (uint256)
    {

        IMatchingMarketV1 market = MATCHING_MARKET;

        uint256 costInTakerToken = market.getPayAmount(
            takerToken,
            makerToken,
            desiredMakerToken.add(1)
        ).add(1);

        requireBelowMaximumPrice(costInTakerToken, desiredMakerToken, orderData);

        return costInTakerToken;
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

        (uint256 takerAmountRatio, uint256 makerAmountRatio) = getMaximumPrice(orderData);
        require(
            makerAmountRatio != 0,
            "OasisV3MatchingExchangeWrapper#getMaxMakerAmount: No maximum price given"
        );

        IMatchingMarketV1 market = MATCHING_MARKET;
        uint256 offerId = market.getBestOffer(makerToken, takerToken);
        uint256 totalMakerAmount = 0;

        while (offerId != 0) {
            Offer memory offer = getOffer(market, offerId);

            assert(makerToken == offer.makerToken);
            assert(takerToken == offer.takerToken);

            if (offer.makerAmount.mul(takerAmountRatio) < offer.takerAmount.mul(makerAmountRatio)) {
                break;
            } else {
                totalMakerAmount = totalMakerAmount.add(offer.makerAmount);
            }
            offerId = market.getWorseOffer(offerId);
        }

        return totalMakerAmount;
    }


    function requireBelowMaximumPrice(
        uint256 takerAmount,
        uint256 makerAmount,
        bytes memory orderData
    )
        private
        pure
    {

        (uint256 takerAmountRatio, uint256 makerAmountRatio) = getMaximumPrice(orderData);
        if (makerAmountRatio != 0) {
            require(
                takerAmount.mul(makerAmountRatio) <= makerAmount.mul(takerAmountRatio),
                "OasisV3MatchingExchangeWrapper#requireBelowMaximumPrice: price is too high"
            );
        }
    }

    function getOffer(
        IMatchingMarketV1 market,
        uint256 offerId
    )
        private
        view
        returns (Offer memory)
    {

        (
            uint256 offerMakerAmount,
            address offerMakerToken,
            uint256 offerTakerAmount,
            address offerTakerToken
        ) = market.getOffer(offerId);

        return Offer({
            makerAmount: offerMakerAmount,
            makerToken: offerMakerToken,
            takerAmount: offerTakerAmount,
            takerToken: offerTakerToken
        });
    }


    function getMaximumPrice(
        bytes memory orderData
    )
        private
        pure
        returns (uint256, uint256)
    {

        if (orderData.length == 0) {
            return (0, 0);
        }

        uint256 takerAmountRatio = 0;
        uint256 makerAmountRatio = 0;

        require(
            orderData.length == 64,
            "OasisV3MatchingExchangeWrapper#getMaximumPrice: orderData is not the right length"
        );

        assembly {
            takerAmountRatio := mload(add(orderData, 32))
            makerAmountRatio := mload(add(orderData, 64))
        }

        require(
            uint128(takerAmountRatio) == takerAmountRatio,
            "OasisV3MatchingExchangeWrapper#getMaximumPrice: takerAmountRatio > 128 bits"
        );
        require(
            uint128(makerAmountRatio) == makerAmountRatio,
            "OasisV3MatchingExchangeWrapper#getMaximumPrice: makerAmountRatio > 128 bits"
        );

        require(
            makerAmountRatio > 0,
            "OasisV3MatchingExchangeWrapper#getMaximumPrice: makerAmountRatio cannot be zero"
        );

        return (takerAmountRatio, makerAmountRatio);
    }
}