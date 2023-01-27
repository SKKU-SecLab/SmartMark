

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
        uint256 pay_amt;
        address pay_gem;
        uint256 buy_amt;
        address buy_gem;
        address owner;
        uint64 timestamp;
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


contract OasisV2SimpleExchangeWrapper is
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


    address public SIMPLE_MARKET;


    constructor(
        address simpleMarket
    )
        public
    {
        SIMPLE_MARKET = simpleMarket;
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

        ISimpleMarketV1 market = ISimpleMarketV1(SIMPLE_MARKET);
        uint256 offerId = bytesToOfferId(orderData);
        Offer memory offer = getOffer(market, offerId);

        verifyOfferTokens(offer, makerToken, takerToken);

        uint256 makerAmount = getInversePartialAmount(
            offer.takerAmount,
            offer.makerAmount,
            requestedFillAmount
        );

        verifyOfferAmount(offer, makerAmount);

        takerToken.ensureAllowance(address(market), requestedFillAmount);

        assert(makerAmount == uint128(makerAmount));
        market.take(bytes32(offerId), uint128(makerAmount));

        makerToken.ensureAllowance(receiver, makerAmount);

        return makerAmount;
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

        ISimpleMarketV1 market = ISimpleMarketV1(SIMPLE_MARKET);
        Offer memory offer = getOffer(market, bytesToOfferId(orderData));
        verifyOfferTokens(offer, makerToken, takerToken);
        verifyOfferAmount(offer, desiredMakerToken);

        return MathHelpers.getPartialAmount(
            desiredMakerToken,
            offer.makerAmount,
            offer.takerAmount
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

        ISimpleMarketV1 market = ISimpleMarketV1(SIMPLE_MARKET);
        Offer memory offer = getOffer(market, bytesToOfferId(orderData));
        verifyOfferTokens(offer, makerToken, takerToken);

        return offer.makerAmount;
    }


    function getInversePartialAmount(
        uint256 numerator,
        uint256 denominator,
        uint256 result
    )
        private
        pure
        returns (uint256)
    {

        uint256 temp = result.add(1).mul(denominator);
        uint256 target = temp.div(numerator);

        if (target.mul(numerator) == temp) {
            target = target.sub(1);
        }

        return target;
    }

    function getOffer(
        ISimpleMarketV1 market,
        uint256 offerId
    )
        private
        view
        returns (Offer memory)
    {

        (
            uint256 makerAmount,
            address makerToken,
            uint256 takerAmount,
            address takerToken
        ) = market.getOffer(offerId);

        return Offer({
            makerAmount: makerAmount,
            makerToken: makerToken,
            takerAmount: takerAmount,
            takerToken: takerToken
        });
    }

    function verifyOfferTokens(
        Offer memory offer,
        address makerToken,
        address takerToken
    )
        private
        pure
    {

        require(
            offer.makerToken != address(0),
            "OasisV2SimpleExchangeWrapper#verifyOfferTokens: offer does not exist"
        );
        require(
            makerToken == offer.makerToken,
            "OasisV2SimpleExchangeWrapper#verifyOfferTokens: makerToken mismatch"
        );
        require(
            takerToken == offer.takerToken,
            "OasisV2SimpleExchangeWrapper#verifyOfferTokens: takerToken mismatch"
        );
    }

    function verifyOfferAmount(
        Offer memory offer,
        uint256 fillAmount
    )
        private
        pure
    {

        require(
            fillAmount != 0,
            "OasisV2SimpleExchangeWrapper#verifyOfferAmount: cannot trade zero makerAmount"
        );
        require(
            fillAmount <= offer.makerAmount,
            "OasisV2SimpleExchangeWrapper#verifyOfferAmount: offer is not large enough"
        );
        uint256 spend = MathHelpers.getPartialAmount(
            fillAmount,
            offer.makerAmount,
            offer.takerAmount
        );
        require(
            spend != 0,
            "OasisV2SimpleExchangeWrapper#verifyOfferAmount: cannot trade zero takerAmount"
        );
    }

    function bytesToOfferId(
        bytes orderData
    )
        private
        pure
        returns (uint256)
    {

        require(
            orderData.length == 32,
            "OasisV2SimpleExchangeWrapper:#bytesToOfferId: invalid orderData"
        );

        uint256 offerId;

        assembly {
            offerId := mload(add(orderData, 32))
        }

        return offerId;
    }
}