

pragma solidity ^0.5.11;

contract ITokenPriceProvider
{

    function usd2lrc(uint usd)
        external
        view
        returns (uint);

}


pragma solidity ^0.5.11;


library MathUint
{

    function mul(
        uint a,
        uint b
        )
        internal
        pure
        returns (uint c)
    {

        c = a * b;
        require(a == 0 || c / a == b, "MUL_OVERFLOW");
    }

    function sub(
        uint a,
        uint b
        )
        internal
        pure
        returns (uint)
    {

        require(b <= a, "SUB_UNDERFLOW");
        return a - b;
    }

    function add(
        uint a,
        uint b
        )
        internal
        pure
        returns (uint c)
    {

        c = a + b;
        require(c >= a, "ADD_OVERFLOW");
    }

    function decodeFloat(
        uint f
        )
        internal
        pure
        returns (uint value)
    {

        uint numBitsMantissa = 23;
        uint exponent = f >> numBitsMantissa;
        uint mantissa = f & ((1 << numBitsMantissa) - 1);
        value = mantissa * (10 ** exponent);
    }
}


pragma solidity ^0.5.11;




contract MovingAveragePriceProvider is ITokenPriceProvider
{

    using MathUint    for uint;

    ITokenPriceProvider public provider;

    uint public movingAverageTimePeriod;
    uint public numMovingAverageDataPoints;
    uint public defaultValue;

    uint public lastUpdateTime;

    uint[] internal history;
    uint internal movingAverage;
    uint internal updateIndex;

    event MovingAverageUpdated(
        uint timestamp,
        uint defaultValueUSD,
        uint movingAverageLRC
    );

    constructor(
        ITokenPriceProvider _provider,
        uint                _movingAverageTimePeriod,
        uint                _numMovingAverageDataPoints,
        uint                _defaultValue
        )
        public
    {
        require(_movingAverageTimePeriod > 0, "INVALID_INPUT");
        require(_numMovingAverageDataPoints > 0, "INVALID_INPUT");
        require(_defaultValue > 0, "INVALID_INPUT");

        provider = _provider;
        movingAverageTimePeriod = _movingAverageTimePeriod;
        numMovingAverageDataPoints = _numMovingAverageDataPoints;
        defaultValue = _defaultValue;

        uint currentConversion = provider.usd2lrc(defaultValue);
        for (uint i = 0; i < numMovingAverageDataPoints; i++) {
            history.push(currentConversion);
        }
        movingAverage = currentConversion;
        lastUpdateTime = now;
    }

    function usd2lrc(uint usd)
        external
        view
        returns (uint)
    {

        return usd.mul(movingAverage) / defaultValue;
    }

    function updateMovingAverage()
        external
    {

        require(now >= lastUpdateTime.add(movingAverageTimePeriod), "TOO_SOON");

        history[updateIndex] = provider.usd2lrc(defaultValue);
        updateIndex = (updateIndex + 1) % numMovingAverageDataPoints;

        uint newMovingAverage = 0;
        for (uint i = 0; i < numMovingAverageDataPoints; i++) {
            newMovingAverage = newMovingAverage.add(history[i]);
        }
        movingAverage = newMovingAverage / numMovingAverageDataPoints;

        lastUpdateTime = now;

        emit MovingAverageUpdated(now, defaultValue, movingAverage);
    }
}