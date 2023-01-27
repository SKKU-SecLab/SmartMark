pragma solidity ^0.5.16;

library SafeMath {

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {


        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b <= a, "SafeMath: subtraction overflow");
        uint256 c = a - b;

        return c;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }
}// MIT

pragma solidity ^0.5.16;

contract Ownable {

    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), msg.sender);
    }

    function owner() public view returns (address) {

        return _owner;
    }

    modifier onlyOwner() {

        require(_owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public onlyOwner {

        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {

        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}// MIT

pragma solidity ^0.5.16;
pragma experimental ABIEncoderV2;

library FixedPoint {

    struct uq112x112 {
        uint224 _x;
    }

    struct uq144x112 {
        uint _x;
    }

    uint8 private constant RESOLUTION = 112;

    function encode(uint112 x) internal pure returns (uq112x112 memory) {

        return uq112x112(uint224(x) << RESOLUTION);
    }

    function encode144(uint144 x) internal pure returns (uq144x112 memory) {

        return uq144x112(uint256(x) << RESOLUTION);
    }

    function div(uq112x112 memory self, uint112 x) internal pure returns (uq112x112 memory) {

        require(x != 0, "FixedPoint: DIV_BY_ZERO");
        return uq112x112(self._x / uint224(x));
    }

    function mul(uq112x112 memory self, uint y) internal pure returns (uq144x112 memory) {

        uint z;
        require(y == 0 || (z = uint(self._x) * y) / y == uint(self._x), "FixedPoint: MULTIPLICATION_OVERFLOW");
        return uq144x112(z);
    }

    function fraction(uint112 numerator, uint112 denominator) internal pure returns (uq112x112 memory) {

        require(denominator > 0, "FixedPoint: DIV_BY_ZERO");
        return uq112x112((uint224(numerator) << RESOLUTION) / denominator);
    }

    function decode(uq112x112 memory self) internal pure returns (uint112) {

        return uint112(self._x >> RESOLUTION);
    }

    function decode144(uq144x112 memory self) internal pure returns (uint144) {

        return uint144(self._x >> RESOLUTION);
    }
}// MIT

pragma solidity ^0.5.16;

interface IKeep3rV1 {


    function isKeeper(address) external returns (bool);


    function worked(address keeper) external;


    function bond(address bonding, uint amount) external;


    function activate(address bonding) external;

}// MIT

pragma solidity ^0.5.16;

interface IUniswapV2Pair {


    function getReserves()
        external
        view
        returns (
            uint112 reserve0,
            uint112 reserve1,
            uint32 blockTimestampLast
        );


    function price0CumulativeLast() external view returns (uint);


    function price1CumulativeLast() external view returns (uint);

}// MIT

pragma solidity ^0.5.16;



library UniswapV2OracleLibrary {

    using FixedPoint for *;

    function currentBlockTimestamp() internal view returns (uint32) {

        return uint32(block.timestamp % 2**32);
    }

    function currentCumulativePrices(address _pair)
        internal
        view
        returns (
            uint price0Cumulative,
            uint price1Cumulative,
            uint32 blockTimestamp
        )
    {

        blockTimestamp = currentBlockTimestamp();
        price0Cumulative = IUniswapV2Pair(_pair).price0CumulativeLast();
        price1Cumulative = IUniswapV2Pair(_pair).price1CumulativeLast();

        (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast) = IUniswapV2Pair(_pair).getReserves();

        if (blockTimestampLast != blockTimestamp) {
            uint32 timeElapsed = blockTimestamp - blockTimestampLast;

            price0Cumulative += uint(FixedPoint.fraction(reserve1, reserve0)._x) * timeElapsed;
            price1Cumulative += uint(FixedPoint.fraction(reserve0, reserve1)._x) * timeElapsed;
        }
    }
}// MIT

pragma solidity ^0.5.16;


library UniswapV2Library {

    using SafeMath for uint;

    function sortTokens(
        address tokenA,
        address tokenB
    )
        internal
        pure
        returns (address token0, address token1)
    {

        require(tokenA != tokenB, "UniswapV2Library: IDENTICAL_ADDRESSES");

        (token0, token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);

        require(token0 != address(0), "UniswapV2Library: ZERO_ADDRESS");
    }

    function pairFor(
        address factory,
        address tokenA,
        address tokenB
    )
        internal
        pure
        returns (address pair)
    {

        (address token0, address token1) = sortTokens(tokenA, tokenB);

        pair = address(
            uint(
                keccak256(
                    abi.encodePacked(
                        hex"ff",
                        factory,
                        keccak256(abi.encodePacked(token0, token1)),
                        hex"96e8ac4277198ff8b6f785478aa9a39f403cb768dd02cbee326c3e7da348845f" // init code hash
                    )
                )
            )
        );
    }
}// MIT

pragma solidity ^0.5.16;



contract ArcUniswapV2Oracle is Ownable {


    using SafeMath for uint;


    IKeep3rV1 public KP3R;

    address public uniV2Factory;

    uint public periodWindow = 1 hours;

    mapping(address => Observation[]) public pairObservations;

    address[] internal _pairs;

    mapping(address => bool) internal _known;


    struct Observation {
        uint timestamp;
        uint price0Cumulative;
        uint price1Cumulative;
    }


    event WorkDone(address keeper);

    event UpdatedAll(address caller);

    event PairUpdated(address pair);

    event PairAdded(address pair);

    event PairRemoved(address pair);

    event Keep3rV1AddressSet(address kp3r);

    event PeriodWindowSet(uint newPeriodWindow);

    event UniV2FactorySet(address newUniV2Factory);


    modifier keeper() {

        require(
            KP3R.isKeeper(msg.sender),
            "isKeeper(): keeper is not registered"
        );
        _;
    }


    constructor(
        address _kp3r,
        address _uniV2Factory
    )
        public
    {
        require(
            _kp3r != address(0) && _uniV2Factory != address(0),
            "ArcUniswapV2Oracle: Keeper and univ2Factory address must not be null"
        );

        KP3R = IKeep3rV1(_kp3r);
        uniV2Factory = _uniV2Factory;
    }


    function work() external keeper {

        bool worked = _updateAll();

        require(
            worked,
            "ArcUniswapV2Oracle:work: the work was not completed!"
        );

        KP3R.worked(msg.sender);

        emit WorkDone(msg.sender);
    }


    function updateTokensPair(
        address _token0,
        address _token1
    )
        external
        returns (bool)
    {

        address pair = UniswapV2Library.pairFor(uniV2Factory, _token0, _token1);
        return updatePair(pair);
    }

    function updatePair(address _pair)
        public
        returns (bool)
    {

        require(
            _known[_pair],
            "ArcUniswapV2Oracle:updatePair(): The pair is not known"
        );

        bool updated = _update(_pair);

        if (updated) {
            emit PairUpdated(_pair);
        }

        return updated;
    }

    function updateAll() external returns (bool) {

        bool worked = _updateAll();

        if (worked) {
            emit UpdatedAll(msg.sender);
        }

        return worked;
    }


    function getPairObservations(address _pair)
        external
        view
        returns (Observation[] memory)
    {

        return pairObservations[_pair];
    }

    function getPairs()
        external
        view
        returns (address[] memory)
    {

        return _pairs;
    }

    function lastObservation(address _pair)
        public
        view
        returns (Observation memory)
    {

        require(
            _known[_pair],
            "ArcUniswapV2Oracle:lastObservation(): The pair is not known"
        );

        Observation[] memory foundPairObservations = pairObservations[_pair];
        return pairObservations[_pair][foundPairObservations.length - 1];
    }

    function lastObservationTokens(
        address _token0,
        address _token1
    )
        external
        view
        returns (Observation memory)
    {

        address pair = UniswapV2Library.pairFor(uniV2Factory, _token0, _token1);

        require(
            _known[pair],
            "ArcUniswapV2Oracle:lastObservationTokens(): The pair is not known"
        );

        Observation[] memory foundPairObservations = pairObservations[pair];
        return pairObservations[pair][foundPairObservations.length - 1];
    }

    function workablePair(address _pair)
        public
        view
        returns (bool)
    {

        require(
            _known[_pair],
            "ArcUniswapV2Oracle:workablePair(): pair is not known"
        );

        Observation memory observation = lastObservation(_pair);
        uint timeElapsed = block.timestamp.sub(observation.timestamp);

        return timeElapsed > periodWindow;
    }

    function workableTokens(
        address _token0,
        address _token1
    )
        external
        view
        returns (bool)
    {

        address pair = UniswapV2Library.pairFor(uniV2Factory, _token0, _token1);

        require(
            _known[pair],
            "ArcUniswapV2Oracle:workableTokens(): pair is not known"
        );

        Observation memory observation = lastObservation(pair);
        uint timeElapsed = block.timestamp.sub(observation.timestamp);

        return timeElapsed > periodWindow;
    }

    function workable()
        external
        view
        returns (bool)
    {

        for (uint i = 0; i < _pairs.length; i++) {
            if (workablePair(_pairs[i])) {
                return true;
            }
        }

        return false;
    }

    function pairFor(address _token0, address _token1)
        external
        view
        returns (address)
    {

        return UniswapV2Library.pairFor(uniV2Factory, _token0, _token1);
    }

    function current(
        address _tokenIn,
        uint _amountIn,
        address _tokenOut
    )
        external
        view
        returns (uint)
    {

        address pair = UniswapV2Library.pairFor(uniV2Factory, _tokenIn, _tokenOut);

        require(
            _valid(pair, periodWindow.mul(2)),
            "ArcUniswapV2Oracle:current(): stale prices"
        );

        (address token0, ) = UniswapV2Library.sortTokens(_tokenIn, _tokenOut);
        Observation memory observation = lastObservation(pair);
        (uint price0Cumulative, uint price1Cumulative, ) = UniswapV2OracleLibrary.currentCumulativePrices(pair);

        if (block.timestamp == observation.timestamp) {
            Observation[] memory observationsForPair = pairObservations[pair];
            observation = pairObservations[pair][observationsForPair.length.sub(2)];
        }

        uint timeElapsed = block.timestamp.sub(observation.timestamp);
        timeElapsed = timeElapsed == 0 ? 1 : timeElapsed;

        if (token0 == _tokenIn) {
            return _computeAmountOut(
                observation.price0Cumulative,
                price0Cumulative,
                timeElapsed,
                _amountIn
            );
        } else {
            return _computeAmountOut(
                observation.price1Cumulative,
                price1Cumulative,
                timeElapsed,
                _amountIn
            );
        }
    }

    function quote(
        address _tokenIn,
        uint _amountIn,
        address _tokenOut,
        uint _granularity
    )
        external
        view
        returns (uint)
    {

        address pair = UniswapV2Library.pairFor(uniV2Factory, _tokenIn, _tokenOut);

        require(
            _valid(pair, periodWindow.mul(_granularity)),
            "ArcUniswapV2Oracle:quote(): stale prices"
        );

        (address token0, ) = UniswapV2Library.sortTokens(_tokenIn, _tokenOut);

        uint priceAverageCumulative = 0;
        uint length = pairObservations[pair].length - 1;
        uint i = length.sub(_granularity);

        uint nextIndex = 0;
        if (token0 == _tokenIn) {
            for (; i < length; i++) {
                nextIndex = i + 1;
                priceAverageCumulative += _computeAmountOut(
                    pairObservations[pair][i].price0Cumulative,
                    pairObservations[pair][nextIndex].price0Cumulative,
                    pairObservations[pair][nextIndex].timestamp.sub(pairObservations[pair][i].timestamp),
                    _amountIn
                );
            }
        } else {
            for (; i < length; i++) {
                nextIndex = i + 1;
                priceAverageCumulative += _computeAmountOut(
                    pairObservations[pair][i].price1Cumulative,
                    pairObservations[pair][nextIndex].price1Cumulative,
                    pairObservations[pair][nextIndex].timestamp.sub(pairObservations[pair][i].timestamp),
                    _amountIn
                );
            }
        }

        return priceAverageCumulative.div(_granularity);
    }


    function setPeriodWindow(uint _periodWindow) external onlyOwner {


        require(
            _periodWindow != 0,
            "ArcUniswapV2Oracle:setPeriodWindow(): period window cannot be 0!"
        );

        periodWindow = _periodWindow;
        emit PeriodWindowSet(_periodWindow);
    }

    function setKeep3rAddress(address _kp3r) external onlyOwner {

        require(
            _kp3r != address(0),
            "ArcUniswapV2Oracle:setKeep3rAddress(): _kp3r must not be null"
        );

        KP3R = IKeep3rV1(_kp3r);
        emit Keep3rV1AddressSet(_kp3r);
    }

    function addPair(
        address _token0,
        address _token1
    )
        external
        onlyOwner
    {

        address pair = UniswapV2Library.pairFor(uniV2Factory, _token0, _token1);

        require(!_known[pair], "ArcUniswapV2Oracle:addPair(): already known");

        _known[pair] = true;
        _pairs.push(pair);

        (uint price0Cumulative, uint price1Cumulative, ) = UniswapV2OracleLibrary.currentCumulativePrices(pair);
        pairObservations[pair].push(Observation(block.timestamp, price0Cumulative, price1Cumulative));

        emit PairAdded(pair);
        emit PairUpdated(pair);
    }

    function removePair(
        address _tokenA,
        address _tokenB
    )
        external
        onlyOwner
    {

        address pair = UniswapV2Library.pairFor(uniV2Factory, _tokenA, _tokenB);

        require(
            _known[pair],
            "ArcUniswapV2Oracle:removePair(): pair not added"
        );

        for (uint i = 0; i < _pairs.length; i++) {
            if (_pairs[i] == pair) {
                delete _pairs[i];
                _pairs[i] = _pairs[_pairs.length - 1];
                _pairs.length--;

                break;
            }
        }

        delete _known[pair];
        delete pairObservations[pair];

        emit PairRemoved(pair);
    }

    function setUniV2FactoryAddress(address _uniV2Factory)
        external
        onlyOwner
    {

        require(
            _uniV2Factory != address(0),
            "ArcUniswapV2Oracle:setUniV2FactoryAddress(): _uniV2Factory cannot be 0"
        );

        uniV2Factory = _uniV2Factory;
        emit UniV2FactorySet(_uniV2Factory);
    }


    function _update(address _pair)
        internal
        returns (bool)
    {

        uint timeElapsed = block.timestamp - lastObservation(_pair).timestamp;

        if (timeElapsed > periodWindow) {
            (uint price0Cumulative, uint price1Cumulative, ) = UniswapV2OracleLibrary.currentCumulativePrices(_pair);

            pairObservations[_pair].push(Observation(block.timestamp, price0Cumulative, price1Cumulative));

            return true;
        }

        return false;
    }

    function _updateAll()
        internal
        returns (bool updated)
    {

        for (uint i = 0; i < _pairs.length; i++) {
            if (_update(_pairs[i])) {
                updated = true;
            }
        }
    }

    function _valid(
        address _pair,
        uint _age
    )
        internal
        view
        returns (bool)
    {

        return block.timestamp.sub(lastObservation(_pair).timestamp) <= _age;
    }

    function _computeAmountOut(
        uint _priceCumulativeStart,
        uint _priceCumulativeEnd,
        uint _timeElapsed,
        uint _amountIn
    )
        private
        pure
        returns (uint amountOut)
    {

        FixedPoint.uq112x112 memory priceAverage =
            FixedPoint.uq112x112(uint224((_priceCumulativeEnd - _priceCumulativeStart) / _timeElapsed));
        FixedPoint.uq144x112 memory priceAverageMultiplied = FixedPoint.mul(priceAverage, _amountIn);

        return FixedPoint.decode144(priceAverageMultiplied);
    }
}