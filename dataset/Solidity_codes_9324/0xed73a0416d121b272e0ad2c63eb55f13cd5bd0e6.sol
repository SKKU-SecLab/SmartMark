
pragma solidity ^0.6.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

pragma solidity ^0.6.0;

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b != 0, errorMessage);
        return a % b;
    }
}
pragma solidity ^0.6.0;

interface IUniswapV2Pair {

    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);

    function symbol() external pure returns (string memory);

    function decimals() external pure returns (uint8);

    function totalSupply() external view returns (uint);

    function balanceOf(address owner) external view returns (uint);

    function allowance(address owner, address spender) external view returns (uint);


    function approve(address spender, uint value) external returns (bool);

    function transfer(address to, uint value) external returns (bool);

    function transferFrom(address from, address to, uint value) external returns (bool);


    function DOMAIN_SEPARATOR() external view returns (bytes32);

    function PERMIT_TYPEHASH() external pure returns (bytes32);

    function nonces(address owner) external view returns (uint);


    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;


    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);

    function factory() external view returns (address);

    function token0() external view returns (address);

    function token1() external view returns (address);

    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);

    function price0CumulativeLast() external view returns (uint);

    function price1CumulativeLast() external view returns (uint);

    function kLast() external view returns (uint);


    function mint(address to) external returns (uint liquidity);

    function burn(address to) external returns (uint amount0, uint amount1);

    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;

    function skim(address to) external;

    function sync() external;


    function initialize(address, address) external;

}

pragma solidity ^0.6.0;

library Babylonian {

    function sqrt(uint y) internal pure returns (uint z) {

        if (y > 3) {
            z = y;
            uint x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
    }
}

pragma solidity ^0.6.0;


library FixedPoint {

    struct uq112x112 {
        uint224 _x;
    }

    struct uq144x112 {
        uint _x;
    }

    uint8 private constant RESOLUTION = 112;
    uint private constant Q112 = uint(1) << RESOLUTION;
    uint private constant Q224 = Q112 << RESOLUTION;

    function encode(uint112 x) internal pure returns (uq112x112 memory) {

        return uq112x112(uint224(x) << RESOLUTION);
    }

    function encode144(uint144 x) internal pure returns (uq144x112 memory) {

        return uq144x112(uint256(x) << RESOLUTION);
    }

    function div(uq112x112 memory self, uint112 x) internal pure returns (uq112x112 memory) {

        require(x != 0, 'FixedPoint: DIV_BY_ZERO');
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

    function reciprocal(uq112x112 memory self) internal pure returns (uq112x112 memory) {

        require(self._x != 0, 'FixedPoint: ZERO_RECIPROCAL');
        return uq112x112(uint224(Q224 / self._x));
    }

    function sqrt(uq112x112 memory self) internal pure returns (uq112x112 memory) {

        return uq112x112(uint224(Babylonian.sqrt(uint256(self._x)) << 56));
    }
}

pragma solidity ^0.6.0;


library UniswapV2OracleLibrary {

    using FixedPoint for *;

    function currentBlockTimestamp() internal view returns (uint32) {

        return uint32(block.timestamp % 2 ** 32);
    }

    function currentCumulativePrices(
        address pair,
        bool isToken0
    ) internal view returns (uint priceCumulative, uint32 blockTimestamp) {

        blockTimestamp = currentBlockTimestamp();
        (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast) = IUniswapV2Pair(pair).getReserves();
        if (isToken0) {
          priceCumulative = IUniswapV2Pair(pair).price0CumulativeLast();

          if (blockTimestampLast != blockTimestamp) {
              uint32 timeElapsed = blockTimestamp - blockTimestampLast;
              priceCumulative += uint(FixedPoint.fraction(reserve1, reserve0)._x) * timeElapsed;
          }
        } else {
          priceCumulative = IUniswapV2Pair(pair).price1CumulativeLast();
          if (blockTimestampLast != blockTimestamp) {
              uint32 timeElapsed = blockTimestamp - blockTimestampLast;
              priceCumulative += uint(FixedPoint.fraction(reserve0, reserve1)._x) * timeElapsed;
          }
        }

    }
}

pragma solidity ^0.6.0;

contract Context {

    constructor () internal { }

    function _msgSender() internal view returns (address payable) {

        return payable(msg.sender);
    }

    function _msgData() internal view returns (bytes memory) {

        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

pragma solidity ^0.6.0;


contract Ownable is Context {

    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {

        return _owner;
    }

    modifier onlyOwner() {

        require(_owner == _msgSender(), "Ownable: caller is not the owner");
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
}

pragma solidity ^0.6.0;

interface IXAUToken {


    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);


    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
    function totalSupply() external view returns (uint256);

    function balanceOf(address who) external view returns(uint256);

    function transfer(address to, uint256 value) external returns(bool);

    function transferFrom(address from, address to, uint256 value) external returns(bool);

    function allowance(address owner_, address spender) external view returns(uint256);

    function approve(address spender, uint256 value) external returns (bool);


    function increaseAllowance(address spender, uint256 addedValue) external returns (bool);

    function decreaseAllowance(address spender, uint256 subtractedValue) external returns (bool);


    event Rebase(uint256 epoch, uint256 oldScalingFactor, uint256 newScalingFactor);
    event NewRebaser(address oldRebaser, address newRebaser);
    function maxScalingFactor() external view returns (uint256);

    function scalingFactor() external view returns (uint256);

    function rebase(uint256 epoch, uint256 indexDelta, bool positive) external returns (uint256);  // onlyRebaser

    function fromUnderlying(uint256 underlying) external view returns (uint256);

    function toUnderlying(uint256 value) external view returns (uint256);

    function balanceOfUnderlying(address who) external view returns(uint256);

    function rebaser() external view returns (address);

    function setRebaser(address _rebaser) external;  // onlyOwner


    event NewTransferHandler(address oldTransferHandler, address newTransferHandler);
    event NewFeeDistributor(address oldFeeDistributor, address newFeeDistributor);
    function transferHandler() external view returns (address);

    function setTransferHandler(address _transferHandler) external;  // onlyOwner

    function feeDistributor() external view returns (address);

    function setFeeDistributor(address _feeDistributor) external;  // onlyOwner


    function recoverERC20(address token, address to, uint256 amount) external returns (bool);  // onlyOwner

}
pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;

interface AggregatorV3Interface {


  function decimals() external view returns (uint8);

  function description() external view returns (string memory);

  function version() external view returns (uint256);


  function getRoundData(uint80 _roundId)
    external
    view
    returns (
      uint80 roundId,
      uint256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );

  function latestRoundData()
    external
    view
    returns (
      uint80 roundId,
      uint256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );


}// MIT

pragma solidity ^0.6.0;


interface BAL {

    function gulp(address token) external;

}

contract Rebaser is Context, Ownable {


    using SafeMath for uint256;

    AggregatorV3Interface public targetRateOracle1;
    AggregatorV3Interface public targetRateOracle2;
    uint256 public targetRateOracleScale;
    
    struct Transaction {
        bool enabled;
        address destination;
        bytes data;
    }

    event TransactionFailed(address indexed destination, uint index, bytes data);

    event NewDeviationThreshold(uint256 oldDeviationThreshold, uint256 newDeviationThreshold);

    event NewMaxRebaseRatio(uint256 oldMaxRebaseRatio, uint256 newMaxRebaseRatio);

    Transaction[] public transactions;

    uint256 public rebaseLag;

    uint256 public targetRate;

    uint256 public deviationThreshold;

    uint256 public maxRebaseRatio;

    uint256 public minRebaseTimeIntervalSec;

    uint256 public lastRebaseTimestampSec;

    uint256 public rebaseWindowOffsetSec;

    uint256 public rebaseWindowLengthSec;

    uint256 public epoch;

    bool public rebasingActive;

    uint256 public rebaseDelay; 

    uint256 public timeOfTWAPInit;

    address public xauToken;

    address public reserveToken;

    address public uniswapPair;

    address[] public uniSyncPairs;

    address[] public balGulpPairs;

    uint32 public blockTimestampLast;

    uint256 public priceCumulativeLast;

    bool public isToken0;

    uint256 public constant BASE = 10**18;

    constructor(
        address xauToken_,
        address reserveToken_,
        address uniswapPair_,
        address targetRateOracle1Address_,
        address targetRateOracle2Address_,
        uint256 targetRateOracleDecimals_,
        uint256 _minRebaseTimeIntervalSec,
        uint256 _rebaseWindowOffsetSec,
        uint256 _rebaseWindowLengthSec,
        uint256 _rebaseDelay
    )
        public
    {
          minRebaseTimeIntervalSec = _minRebaseTimeIntervalSec;
          rebaseWindowOffsetSec = _rebaseWindowOffsetSec; // 8am/8pm UTC rebases

          (address token0, ) = sortTokens(xauToken_, reserveToken_);

          targetRateOracle1 = AggregatorV3Interface(targetRateOracle1Address_);
          targetRateOracle2 = AggregatorV3Interface(targetRateOracle2Address_);
          targetRateOracleScale = 10**targetRateOracleDecimals_;

          if (token0 == xauToken_) {
              isToken0 = true;
          } else {
              isToken0 = false;
          }

          uniswapPair = uniswapPair_;

          uniSyncPairs.push(uniswapPair);

          xauToken = xauToken_;

          reserveToken = reserveToken_;

          targetRate = BASE;

          rebaseLag = 5;

          deviationThreshold = 5 * 10**16;

          maxRebaseRatio = 2 * 10**18;

          rebaseWindowLengthSec = _rebaseWindowLengthSec;

          rebaseDelay = _rebaseDelay;
    }

    function removeUniPair(uint256 index) public onlyOwner {

        if (index >= uniSyncPairs.length) return;

        uint256 totalUniPairs = uniSyncPairs.length;

        for (uint256 i = index; i < totalUniPairs - 1; i++) {
            uniSyncPairs[i] = uniSyncPairs[i + 1];
        }
        delete uniSyncPairs[totalUniPairs.sub(1)];
    }

    function removeBalPair(uint256 index) public onlyOwner {

        if (index >= balGulpPairs.length) return;

        uint256 totalGulpPairs = balGulpPairs.length;

        for (uint256 i = index; i < totalGulpPairs - 1; i++) {
            balGulpPairs[i] = balGulpPairs[i + 1];
        }
        delete balGulpPairs[totalGulpPairs.sub(1)];
    }

    function addUniSyncPairs(address[] memory uniSyncPairs_)
        public
        onlyOwner
    {

        for (uint256 i = 0; i < uniSyncPairs_.length; i++) {
            uniSyncPairs.push(uniSyncPairs_[i]);
        }
    }

    function addGulpSyncPairs(address[] memory balGulpPairs_)
        public
        onlyOwner
    {

        for (uint256 i = 0; i < balGulpPairs_.length; i++) {
            balGulpPairs.push(balGulpPairs_[i]);
        }
    }

    function getUniSyncPairs()
        public
        view
        returns (address[] memory)
    {

        address[] memory pairs = uniSyncPairs;
        return pairs;
    }

    function getBalGulpPairs()
        public
        view
        returns (address[] memory)
    {

        address[] memory pairs = balGulpPairs;
        return pairs;
    }

    function initTWAP()
        public
    {

        require(timeOfTWAPInit == 0, "already activated");
        (uint priceCumulative, uint32 blockTimestamp) =
           UniswapV2OracleLibrary.currentCumulativePrices(uniswapPair, isToken0);
        require(blockTimestamp > 0, "no trades");
        blockTimestampLast = blockTimestamp;
        priceCumulativeLast = priceCumulative;
        timeOfTWAPInit = blockTimestamp;
    }

    function activateRebasing()
        public
    {

        require(timeOfTWAPInit > 0, "twap wasnt intitiated, call initTWAP()");
        require(now >= timeOfTWAPInit + rebaseDelay, "!end_delay");

        rebasingActive = true;
    }

    function rebase()
        public
    {

        require(msg.sender == tx.origin || msg.sender == owner()); 

        _inRebaseWindow(); 

        require(lastRebaseTimestampSec.add(minRebaseTimeIntervalSec) <= now);  // FIX: [<] -> [<=] to allow rebase from 0th second of each window

        require(updateTargetRate(), "Target rate was not defined");

        
        lastRebaseTimestampSec = now.sub( 
            now.mod(minRebaseTimeIntervalSec)).add(rebaseWindowOffsetSec); 

        epoch = epoch.add(1); 

        uint256 exchangeRate = getTWAP();

        (uint256 offPegPerc, bool positive) = computeOffPegPerc(exchangeRate); // 999999452912662667

        uint256 indexDelta = offPegPerc;

        indexDelta = indexDelta.div(rebaseLag);

        indexDelta = obeyMaxRebaseRatio(indexDelta, positive);

        IXAUToken xau = IXAUToken(xauToken);

        if (positive) {
            require(xau.scalingFactor().mul(BASE.add(indexDelta)).div(BASE) < xau.maxScalingFactor(), "new scaling factor will be too big");
        }

        xau.rebase(epoch, indexDelta, positive);

        afterRebase(offPegPerc); 
    }

    function afterRebase(
        uint256 /* offPegPerc */
    )
        internal
    {

        for (uint256 i = 0; i < uniSyncPairs.length; i++) {
            IUniswapV2Pair(uniSyncPairs[i]).sync();
        }

        for (uint256 i = 0; i < balGulpPairs.length; i++) {
            BAL(balGulpPairs[i]).gulp(xauToken);
        }

        for (uint i = 0; i < transactions.length; i++) {
            Transaction storage t = transactions[i];
            if (t.enabled) {
                bool result =
                    externalCall(t.destination, t.data);
                if (!result) {
                    emit TransactionFailed(t.destination, i, t.data);
                    revert("Transaction Failed");
                }
            }
        }
    }

    function getTWAP()
        internal
        returns (uint256)
    {

        (uint priceCumulative, uint32 blockTimestamp) =
            UniswapV2OracleLibrary.currentCumulativePrices(uniswapPair, isToken0);
        uint32 timeElapsed = blockTimestamp - blockTimestampLast; // overflow is desired



        uint256 priceAverage = uint256(uint224((priceCumulative - priceCumulativeLast) / timeElapsed));

        priceCumulativeLast = priceCumulative;
        blockTimestampLast = blockTimestamp;

        if (priceAverage > uint192(-1)) {
           return (priceAverage >> 112) * BASE;
        }
        return (priceAverage * BASE) >> 112;
    }

    function getCurrentTWAP()
        public
        view
        returns (uint256)
    {

        (uint priceCumulative, uint32 blockTimestamp) =
            UniswapV2OracleLibrary.currentCumulativePrices(uniswapPair, isToken0);
        uint32 timeElapsed = blockTimestamp - blockTimestampLast; // overflow is desired


        uint256 priceAverage = uint256(uint224((priceCumulative - priceCumulativeLast) / timeElapsed));

        if (priceAverage > uint192(-1)) {
            return (priceAverage >> 112) * BASE;
        }
        return (priceAverage * BASE) >> 112;
    }

    function setDeviationThreshold(uint256 deviationThreshold_)
        external
        onlyOwner
    {

        require(deviationThreshold_ > 0);  // FIX: fixed YAM bug: require should validate argument, not member
        uint256 oldDeviationThreshold = deviationThreshold;
        deviationThreshold = deviationThreshold_;
        emit NewDeviationThreshold(oldDeviationThreshold, deviationThreshold_);
    }

    function setMaxRebaseRatio(uint256 maxRebaseRatio_)
        external
        onlyOwner
    {

        require(maxRebaseRatio_ > 1 * 10**18);
        uint256 oldMaxRebaseRatio = maxRebaseRatio;
        maxRebaseRatio = maxRebaseRatio_;
        emit NewMaxRebaseRatio(oldMaxRebaseRatio, maxRebaseRatio_);
    }

    function obeyMaxRebaseRatio(uint256 indexDelta, bool positive)
        internal
        view
        returns (uint256)
    {

        uint256 maxIndexDelta = (positive ? maxRebaseRatio.sub(BASE) : BASE.sub((BASE*BASE).div(maxRebaseRatio)));
        return (indexDelta <= maxIndexDelta ? indexDelta : maxIndexDelta);
    }

    function setRebaseLag(uint256 rebaseLag_)
        external
        onlyOwner
    {

        require(rebaseLag_ > 0);
        rebaseLag = rebaseLag_;
    }

    function setTargetRate(uint256 targetRate_)
        external
        onlyOwner
    {

        require(targetRate_ > 0);
        targetRate = targetRate_;
    }

    function setRebaseTimingParameters(
        uint256 minRebaseTimeIntervalSec_,
        uint256 rebaseWindowOffsetSec_,
        uint256 rebaseWindowLengthSec_)
        external
        onlyOwner
    {

        require(minRebaseTimeIntervalSec_ > 0);
        require(rebaseWindowOffsetSec_ < minRebaseTimeIntervalSec_);
        require(rebaseWindowOffsetSec_ + rebaseWindowLengthSec_ <= minRebaseTimeIntervalSec_);  // FIX: [<] -> [<=] to allow window length to span whole interval if needed
        minRebaseTimeIntervalSec = minRebaseTimeIntervalSec_;
        rebaseWindowOffsetSec = rebaseWindowOffsetSec_;
        rebaseWindowLengthSec = rebaseWindowLengthSec_;
    }

    function inRebaseWindow() public view returns (bool) {


        _inRebaseWindow();
        return true;
    }

    function _inRebaseWindow() internal view {


        require(rebasingActive, "rebasing not active");

        require(now.mod(minRebaseTimeIntervalSec) >= rebaseWindowOffsetSec, "too early");
        require(now.mod(minRebaseTimeIntervalSec) < (rebaseWindowOffsetSec.add(rebaseWindowLengthSec)), "too late");
    }

    function isRebaseEffective() external view returns (bool) {

        return        
            rebasingActive && 
            now.mod(minRebaseTimeIntervalSec) >= rebaseWindowOffsetSec &&
            now.mod(minRebaseTimeIntervalSec) < (rebaseWindowOffsetSec.add(rebaseWindowLengthSec)) &&
            lastRebaseTimestampSec.add(minRebaseTimeIntervalSec) <= now &&
            !withinDeviationThreshold(getCurrentTWAP(), getCurrentTargetRate())
            ;
    }

    function computeOffPegPerc(uint256 rate)
        internal
        view
        returns (uint256, bool)
    {

        if (withinDeviationThreshold(rate, targetRate)) {
            return (0, false);
        }

        if (rate > targetRate) {
            return (rate.sub(targetRate).mul(BASE).div(targetRate), true);
        } else {
            return (targetRate.sub(rate).mul(BASE).div(targetRate), false);
        }
    }

    function withinDeviationThreshold(uint256 _currentRate, uint256 _targetRate)
        internal
        view
        returns (bool)
    {

        uint256 absoluteDeviationThreshold = _targetRate.mul(deviationThreshold)
            .div(10 ** 18);

        return (_currentRate >= _targetRate && _currentRate.sub(_targetRate) < absoluteDeviationThreshold)
            || (_currentRate < _targetRate && _targetRate.sub(_currentRate) < absoluteDeviationThreshold);
    }


    function pairFor(
        address factory,
        address token0,
        address token1
    )
        internal
        pure
        returns (address pair)
    {

        pair = address(uint(keccak256(abi.encodePacked(
                hex'ff',
                factory,
                keccak256(abi.encodePacked(token0, token1)),
                hex'96e8ac4277198ff8b6f785478aa9a39f403cb768dd02cbee326c3e7da348845f' // init code hash
            ))));
    }

    function sortTokens(
        address tokenA,
        address tokenB
    )
        internal
        pure
        returns (address token0, address token1)
    {

        require(tokenA != tokenB, 'UniswapV2Library: IDENTICAL_ADDRESSES');
        (token0, token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        require(token0 != address(0), 'UniswapV2Library: ZERO_ADDRESS');
    }


    function addTransaction(address destination, bytes calldata data)
        external
        onlyOwner
    {

        transactions.push(Transaction({
            enabled: true,
            destination: destination,
            data: data
        }));
    }


    function removeTransaction(uint index)
        external
        onlyOwner
    {

        require(index < transactions.length, "index out of bounds");

        if (index < transactions.length - 1) {
            transactions[index] = transactions[transactions.length - 1];
        }

        transactions.pop();
    }

    function setTransactionEnabled(uint index, bool enabled)
        external
        onlyOwner
    {

        require(index < transactions.length, "index must be in range of stored tx list");
        transactions[index].enabled = enabled;
    }

    function externalCall(address destination, bytes memory data)
        internal
        returns (bool)
    {

        bool result;
        assembly {  // solhint-disable-line no-inline-assembly
            let outputAddress := mload(0x40)

            let dataAddress := add(data, 32)

            result := call(
                sub(gas(), 34710),


                destination,
                0, // transfer value in wei
                dataAddress,
                mload(data),  // Size of the input, in bytes. Stored in position 0 of the array.
                outputAddress,
                0  // Output is ignored, therefore the output size is zero
            )
        }
        return result;
    }
    
    function recoverERC20(
        address token,
        address to,
        uint256 amount
    )
        external
        onlyOwner
        returns (bool)
    {

        return IERC20(token).transfer(to, amount);
    }

    function setTargetRateOracle1(AggregatorV3Interface oracleAddress_) public onlyOwner {

        targetRateOracle1 = oracleAddress_;
    }

    function setTargetRateOracle2(AggregatorV3Interface oracleAddress_) public onlyOwner {

        targetRateOracle2 = oracleAddress_;
    }

    function setTargetRateOracleDecimals(uint256 targetRateOracleDecimals_) public onlyOwner {

        targetRateOracleScale = 10**targetRateOracleDecimals_;
    }

    function getTargetRateOracle1Price() public view returns (uint256) {

        return getChainLinkOraclePrice(targetRateOracle1);
    }

    function getTargetRateOracle2Price() public view returns (uint256) {

        return getChainLinkOraclePrice(targetRateOracle2);
    }

    function getUniswapPairAddress() public view returns (address) {

        return uniswapPair;
    }

    function getChainLinkOraclePrice(AggregatorV3Interface chainLinkOracle) internal view returns (uint256) {

        (
            , // uint80 roundID, 
            uint price,
            , // uint startedAt,
            uint timeStamp,
        ) = chainLinkOracle.latestRoundData();        
        require(timeStamp > 0, "Round not complete");  // If the round is not complete yet, timestamp is 0
        return price;
    }

    function getCurrentTargetRate() public view returns (uint256) {

        if (address(targetRateOracle1) != address(0)) {
            if (address(targetRateOracle2) != address(0)) {
                return getChainLinkOraclePrice(targetRateOracle1).mul(BASE).div(getChainLinkOraclePrice(targetRateOracle2));  // [comodity/USD] / [ETH/USD] = [comodity/USD] * [USD/ETH] = [comodity/ETH])
            } else {
                return getChainLinkOraclePrice(targetRateOracle1).mul(BASE).div(targetRateOracleScale);
            }
        } else if (address(targetRateOracle2) != address(0)) {
            return BASE.mul(targetRateOracleScale).div(getChainLinkOraclePrice(targetRateOracle2));
        } else {
            return targetRate;
        }
    }
    
    function updateTargetRate() public returns (bool) {

        AggregatorV3Interface _targetRateOracle1 = targetRateOracle1;  // cache storage values to save duplicit SLOAD gas
        AggregatorV3Interface _targetRateOracle2 = targetRateOracle2;
        if (address(_targetRateOracle1) != address(0)) {
            if (address(_targetRateOracle2) != address(0)) {
                targetRate = getChainLinkOraclePrice(_targetRateOracle1).mul(BASE).div(getChainLinkOraclePrice(_targetRateOracle2));  // [comodity/USD] / [ETH/USD] = [comodity/USD] * [USD/ETH] = [comodity/ETH])
            } else {
                targetRate = getChainLinkOraclePrice(_targetRateOracle1).mul(BASE).div(targetRateOracleScale);
            }
        } else if (address(_targetRateOracle2) != address(0)) {
            targetRate = BASE.mul(targetRateOracleScale).div(getChainLinkOraclePrice(_targetRateOracle2));
        } else {
        }
        return true;
    }

}