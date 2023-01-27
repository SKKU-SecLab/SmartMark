

pragma solidity >=0.5.0;

interface IUniswapV2Factory {

  event PairCreated(address indexed token0, address indexed token1, address pair, uint);

  function getPair(address tokenA, address tokenB) external view returns (address pair);

  function allPairs(uint) external view returns (address pair);

  function allPairsLength() external view returns (uint);


  function feeTo() external view returns (address);

  function feeToSetter() external view returns (address);


  function createPair(address tokenA, address tokenB) external returns (address pair);

}

interface IUniswapV2Router02 {

    function factory() external pure returns (address);


    function WETH() external pure returns (address);


    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);


}

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

interface IUniswapV2ERC20 {

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

}


interface IUniswapV2Callee {

    function uniswapV2Call(address sender, uint amount0, uint amount1, bytes calldata data) external;

}



pragma solidity >=0.5.0;
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

library UQ112x112 {

    uint224 constant Q112 = 2**112;

    function encode(uint112 y) internal pure returns (uint224 z) {

        z = uint224(y) * Q112; // never overflows
    }

    function uqdiv(uint224 x, uint112 y) internal pure returns (uint224 z) {

        z = x / uint224(y);
    }
}

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


pragma solidity >=0.5.0;



library UniswapV2OracleLibrary {

    using FixedPoint for *;

    function currentBlockTimestamp() internal view returns (uint32) {

        return uint32(block.timestamp % 2 ** 32);
    }

    function currentCumulativePrices(
        address pair
    ) internal view returns (uint price0Cumulative, uint price1Cumulative, uint32 blockTimestamp) {

        blockTimestamp = currentBlockTimestamp();
        price0Cumulative = IUniswapV2Pair(pair).price0CumulativeLast();
        price1Cumulative = IUniswapV2Pair(pair).price1CumulativeLast();

        (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast) = IUniswapV2Pair(pair).getReserves();
        if (blockTimestampLast != blockTimestamp) {
            uint32 timeElapsed = blockTimestamp - blockTimestampLast;
            price0Cumulative += uint(FixedPoint.fraction(reserve1, reserve0)._x) * timeElapsed;
            price1Cumulative += uint(FixedPoint.fraction(reserve0, reserve1)._x) * timeElapsed;
        }
    }
}


pragma solidity ^0.5.0;

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b <= a, "SafeMath: subtraction overflow");
        uint256 c = a - b;

        return c;
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

        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
}

library SafeMath128 {

    function add(uint128 a, uint128 b) internal pure returns (uint128) {

        uint128 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint128 a, uint128 b) internal pure returns (uint128) {

        require(b <= a, "SafeMath: subtraction overflow");
        uint128 c = a - b;

        return c;
    }

    function sub(uint128 a, uint128 b, string memory errorMessage) internal pure returns (uint128) {

        require(b <= a, errorMessage);
        uint128 c = a - b;

        return c;
    }

    function mul(uint128 a, uint128 b) internal pure returns (uint128) {

        if (a == 0) {
            return 0;
        }

        uint128 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint128 a, uint128 b) internal pure returns (uint128) {

        require(b > 0, "SafeMath: division by zero");
        uint128 c = a / b;

        return c;
    }

    function mod(uint128 a, uint128 b) internal pure returns (uint128) {

        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
}

library SafeMath64 {

    function add(uint64 a, uint64 b) internal pure returns (uint64) {

        uint64 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint64 a, uint64 b) internal pure returns (uint64) {

        require(b <= a, "SafeMath: subtraction overflow");
        uint64 c = a - b;

        return c;
    }

    function sub(uint64 a, uint64 b, string memory errorMessage) internal pure returns (uint64) {

        require(b <= a, errorMessage);
        uint64 c = a - b;

        return c;
    }

    function mul(uint64 a, uint64 b) internal pure returns (uint64) {

        if (a == 0) {
            return 0;
        }

        uint64 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint64 a, uint64 b) internal pure returns (uint64) {

        require(b > 0, "SafeMath: division by zero");
        uint64 c = a / b;

        return c;
    }

    function mod(uint64 a, uint64 b) internal pure returns (uint64) {

        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
}

library SafeMath32 {

    function add(uint32 a, uint32 b) internal pure returns (uint32) {

        uint32 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint32 a, uint32 b) internal pure returns (uint32) {

        require(b <= a, "SafeMath: subtraction overflow");
        uint32 c = a - b;

        return c;
    }

    function sub(uint32 a, uint32 b, string memory errorMessage) internal pure returns (uint32) {

        require(b <= a, errorMessage);
        uint32 c = a - b;

        return c;
    }

    function mul(uint32 a, uint32 b) internal pure returns (uint32) {

        if (a == 0) {
            return 0;
        }

        uint32 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint32 a, uint32 b) internal pure returns (uint32) {

        require(b > 0, "SafeMath: division by zero");
        uint32 c = a / b;

        return c;
    }

    function mod(uint32 a, uint32 b) internal pure returns (uint32) {

        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
}


pragma solidity 0.5.7;


contract Proxy {

    function () external payable {
        address _impl = implementation();
        require(_impl != address(0));

        assembly {
            let ptr := mload(0x40)
            calldatacopy(ptr, 0, calldatasize)
            let result := delegatecall(gas, _impl, ptr, calldatasize, 0, 0)
            let size := returndatasize
            returndatacopy(ptr, 0, size)

            switch result
            case 0 { revert(ptr, size) }
            default { return(ptr, size) }
            }
    }

    function implementation() public view returns (address);

}


pragma solidity 0.5.7;



contract UpgradeabilityProxy is Proxy {

    event Upgraded(address indexed implementation);

    bytes32 private constant IMPLEMENTATION_POSITION = keccak256("org.govblocks.proxy.implementation");

    constructor() public {}

    function implementation() public view returns (address impl) {

        bytes32 position = IMPLEMENTATION_POSITION;
        assembly {
            impl := sload(position)
        }
    }

    function _setImplementation(address _newImplementation) internal {

        bytes32 position = IMPLEMENTATION_POSITION;
        assembly {
        sstore(position, _newImplementation)
        }
    }

    function _upgradeTo(address _newImplementation) internal {

        address currentImplementation = implementation();
        require(currentImplementation != _newImplementation);
        _setImplementation(_newImplementation);
        emit Upgraded(_newImplementation);
    }
}


pragma solidity 0.5.7;



contract OwnedUpgradeabilityProxy is UpgradeabilityProxy {

    event ProxyOwnershipTransferred(address previousOwner, address newOwner);

    bytes32 private constant PROXY_OWNER_POSITION = keccak256("org.govblocks.proxy.owner");

    constructor(address _implementation) public {
        _setUpgradeabilityOwner(msg.sender);
        _upgradeTo(_implementation);
    }

    modifier onlyProxyOwner() {

        require(msg.sender == proxyOwner());
        _;
    }

    function proxyOwner() public view returns (address owner) {

        bytes32 position = PROXY_OWNER_POSITION;
        assembly {
            owner := sload(position)
        }
    }

    function transferProxyOwnership(address _newOwner) public onlyProxyOwner {

        require(_newOwner != address(0));
        _setUpgradeabilityOwner(_newOwner);
        emit ProxyOwnershipTransferred(proxyOwner(), _newOwner);
    }

    function upgradeTo(address _implementation) public onlyProxyOwner {

        _upgradeTo(_implementation);
    }

    function _setUpgradeabilityOwner(address _newProxyOwner) internal {

        bytes32 position = PROXY_OWNER_POSITION;
        assembly {
            sstore(position, _newProxyOwner)
        }
    }
}


pragma solidity 0.5.7;

contract ITokenController {

	address public token;
    address public bLOTToken;

    function swapBLOT(address _of, address _to, uint256 amount) public;


    function totalBalanceOf(address _of)
        public
        view
        returns (uint256 amount);


    function transferFrom(address _token, address _of, address _to, uint256 amount) public;


    function tokensLockedAtTime(address _of, bytes32 _reason, uint256 _time)
        public
        view
        returns (uint256 amount);


    function burnCommissionTokens(uint256 amount) external returns(bool);

 
    function initiateVesting(address _vesting) external;


    function lockForGovernanceVote(address _of, uint _days) public;


    function totalSupply() public view returns (uint256);


    function mint(address _member, uint _amount) public;


}


pragma solidity 0.5.7;

contract IMarketRegistry {


    enum MarketType {
      HourlyMarket,
      DailyMarket,
      WeeklyMarket
    }
    address public owner;
    address public tokenController;
    address public marketUtility;
    bool public marketCreationPaused;

    mapping(address => bool) public isMarket;
    function() external payable{}

    function marketDisputeStatus(address _marketAddress) public view returns(uint _status);


    function burnDisputedProposalTokens(uint _proposaId) external;


    function isWhitelistedSponsor(address _address) public view returns(bool);


    function transferAssets(address _asset, address _to, uint _amount) external;


    function initiate(address _defaultAddress, address _marketConfig, address _plotToken, address payable[] memory _configParams) public;


    function createGovernanceProposal(string memory proposalTitle, string memory description, string memory solutionHash, bytes memory actionHash, uint256 stakeForDispute, address user, uint256 ethSentToPool, uint256 tokenSentToPool, uint256 proposedValue) public {

    }

    function setUserGlobalPredictionData(address _user,uint _value, uint _predictionPoints, address _predictionAsset, uint _prediction,uint _leverage) public{

    }

    function callClaimedEvent(address _user , uint[] memory _reward, address[] memory predictionAssets, uint incentives, address incentiveToken) public {

    }

    function callMarketResultEvent(uint[] memory _totalReward, uint _winningOption, uint _closeValue, uint roundId) public {

    }
}


pragma solidity 0.5.7;

interface IChainLinkOracle
{

	function latestAnswer() external view returns (int256);

	function decimals() external view returns (uint8);

	function getRoundData(uint80 _roundId)
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );


  	function latestRoundData()
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    ); 

}


pragma solidity 0.5.7;

contract IToken {


    function decimals() external view returns(uint8);


    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function mint(address account, uint256 amount) external returns (bool);

    
    function burn(uint256 amount) external;


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


}



pragma solidity 0.5.7;










contract MarketUtility {

    using SafeMath for uint256;
    using FixedPoint for *;

    address constant ETH_ADDRESS = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;
    uint256 constant updatePeriod = 1 hours;

    uint256 internal STAKE_WEIGHTAGE;
    uint256 internal STAKE_WEIGHTAGE_MIN_AMOUNT;
    uint256 internal minTimeElapsedDivisor;
    uint256 internal minPredictionAmount;
    uint256 internal maxPredictionAmount;
    uint256 internal positionDecimals;
    uint256 internal minStakeForMultiplier;
    uint256 internal riskPercentage;
    uint256 internal tokenStakeForDispute;
    address internal plotToken;
    address internal plotETHpair;
    address internal weth;
    address internal initiater;
    address public authorizedAddress;
    bool public initialized;


    struct UniswapPriceData {
        FixedPoint.uq112x112 price0Average;
        uint256 price0CumulativeLast;
        FixedPoint.uq112x112 price1Average;
        uint256 price1CumulativeLast;
        uint32 blockTimestampLast;
        bool initialized;
    }

    mapping(address => UniswapPriceData) internal uniswapPairData;
    IUniswapV2Factory uniswapFactory;

    ITokenController internal tokenController;
    modifier onlyAuthorized() {

        require(msg.sender == authorizedAddress, "Not authorized");
        _;
    }

    function initialize(address payable[] memory _addressParams, address _initiater) public {

        OwnedUpgradeabilityProxy proxy = OwnedUpgradeabilityProxy(
            address(uint160(address(this)))
        );
        require(msg.sender == proxy.proxyOwner(), "Sender is not proxy owner.");
        require(!initialized, "Already initialized");
        initialized = true;
        _setInitialParameters();
        authorizedAddress = msg.sender;
        tokenController = ITokenController(IMarketRegistry(msg.sender).tokenController());
        plotToken = _addressParams[1];
        initiater = _initiater;
        weth = IUniswapV2Router02(_addressParams[0]).WETH();
        uniswapFactory = IUniswapV2Factory(_addressParams[2]);
    }

    function _setInitialParameters() internal {

        STAKE_WEIGHTAGE = 40; //
        STAKE_WEIGHTAGE_MIN_AMOUNT = 20 ether;
        minTimeElapsedDivisor = 6;
        minPredictionAmount = 1e15;
        maxPredictionAmount = 28 ether;
        positionDecimals = 1e2;
        minStakeForMultiplier = 5e17;
        riskPercentage = 20;
        tokenStakeForDispute = 500 ether;
    }

    function checkMultiplier(address _asset, address _user, uint _predictionStake, uint predictionPoints, uint _stakeValue) public view returns(uint, bool) {

      bool multiplierApplied;
      uint _stakedBalance = tokenController.tokensLockedAtTime(_user, "SM", now);
      uint _predictionValueInToken;
      (, _predictionValueInToken) = getValueAndMultiplierParameters(_asset, _predictionStake);
      if(_stakeValue < minStakeForMultiplier) {
        return (predictionPoints,multiplierApplied);
      }
      uint _muliplier = 100;
      if(_stakedBalance.div(_predictionValueInToken) > 0) {
        _muliplier = _muliplier + _stakedBalance.mul(100).div(_predictionValueInToken.mul(10));
        multiplierApplied = true;
      }
      return (predictionPoints.mul(_muliplier).div(100),multiplierApplied);
    }

    function updateUintParameters(bytes8 code, uint256 value)
        external
        onlyAuthorized
    {

        if (code == "SW") { // Stake weightage
            require(value <= 100, "Value must be less or equal to 100");
            STAKE_WEIGHTAGE = value;
        } else if (code == "SWMA") { // Minimum amount required for stake weightage
            STAKE_WEIGHTAGE_MIN_AMOUNT = value;
        } else if (code == "MTED") { // Minimum time elapsed divisor
            minTimeElapsedDivisor = value;
        } else if (code == "MINPRD") { // Minimum predictionamount
            minPredictionAmount = value;
        } else if (code == "MAXPRD") { // Minimum predictionamount
            maxPredictionAmount = value;
        } else if (code == "PDEC") { // Position's Decimals
            positionDecimals = value;
        } else if (code == "MINSTM") { // Min stake required for applying multiplier
            minStakeForMultiplier = value;
        } else if (code == "RPERC") { // Risk percentage
            riskPercentage = value;
        } else if (code == "TSDISP") { // Amount of tokens to be staked for raising a dispute
            tokenStakeForDispute = value;
        } else {
            revert("Invalid code");
        }
    }

    function updateAddressParameters(bytes8 code, address payable value)
        external
        onlyAuthorized
    {

        require(value != address(0), "Value cannot be address(0)");
        if (code == "UNIFAC") { // Uniswap factory address
            uniswapFactory = IUniswapV2Factory(value);
            plotETHpair = uniswapFactory.getPair(plotToken, weth);
        } else {
            revert("Invalid code");
        }
    }

    function update() external onlyAuthorized {

        require(plotETHpair != address(0), "Uniswap pair not set");
        UniswapPriceData storage _priceData = uniswapPairData[plotETHpair];
        (
            uint256 price0Cumulative,
            uint256 price1Cumulative,
            uint32 blockTimestamp
        ) = UniswapV2OracleLibrary.currentCumulativePrices(plotETHpair);
        uint32 timeElapsed = blockTimestamp - _priceData.blockTimestampLast; // overflow is desired

        if (timeElapsed >= updatePeriod || !_priceData.initialized) {
            _priceData.price0Average = FixedPoint.uq112x112(
                uint224(
                    (price0Cumulative - _priceData.price0CumulativeLast) /
                        timeElapsed
                )
            );
            _priceData.price1Average = FixedPoint.uq112x112(
                uint224(
                    (price1Cumulative - _priceData.price1CumulativeLast) /
                        timeElapsed
                )
            );

            _priceData.price0CumulativeLast = price0Cumulative;
            _priceData.price1CumulativeLast = price1Cumulative;
            _priceData.blockTimestampLast = blockTimestamp;
            if(!_priceData.initialized) {
              _priceData.initialized = true;
            }
        }
    }

    function setInitialCummulativePrice() public {

      require(msg.sender == initiater);
      require(plotETHpair == address(0),"Already initialised");
      plotETHpair = uniswapFactory.getPair(plotToken, weth);
      UniswapPriceData storage _priceData = uniswapPairData[plotETHpair];
      (
          uint256 price0Cumulative,
          uint256 price1Cumulative,
          uint32 blockTimestamp
      ) = UniswapV2OracleLibrary.currentCumulativePrices(plotETHpair);
      _priceData.price0CumulativeLast = price0Cumulative;
      _priceData.price1CumulativeLast = price1Cumulative;
      _priceData.blockTimestampLast = blockTimestamp;
    }

    function getPriceFeedDecimals(address _priceFeed) public view returns(uint8) {

      return IChainLinkOracle(_priceFeed).decimals();
    }

    function getBasicMarketDetails()
        public
        view
        returns (
            uint256,
            uint256,
            uint256,
            uint256
        )
    {

        return (minPredictionAmount, riskPercentage, positionDecimals, maxPredictionAmount);
    }

    function getPriceCalculationParams(
        address _marketFeedAddress
    )
        public
        view
        returns (
            uint256,
            uint256,
            uint256,
            uint256
        )
    {

        uint256 _currencyPrice = getAssetPriceUSD(
            _marketFeedAddress
        );
        return (
            STAKE_WEIGHTAGE,
            STAKE_WEIGHTAGE_MIN_AMOUNT,
            _currencyPrice,
            minTimeElapsedDivisor
        );
    }

    function getAssetPriceUSD(
        address _currencyFeedAddress
    ) public view returns (uint256 latestAnswer) {

        return uint256(IChainLinkOracle(_currencyFeedAddress).latestAnswer());
    }

    function getSettlemetPrice(
        address _currencyFeedAddress,
        uint256 _settleTime
    ) public view returns (uint256 latestAnswer, uint256 roundId) {

        uint80 currentRoundId;
        uint256 currentRoundTime;
        int256 currentRoundAnswer;
        (currentRoundId, currentRoundAnswer, , currentRoundTime, )= IChainLinkOracle(_currencyFeedAddress).latestRoundData();
        while(currentRoundTime > _settleTime) {
            currentRoundId--;
            (currentRoundId, currentRoundAnswer, , currentRoundTime, )= IChainLinkOracle(_currencyFeedAddress).getRoundData(currentRoundId);
            if(currentRoundTime <= _settleTime) {
                break;
            }
        }
        return
            (uint256(currentRoundAnswer), currentRoundId);
    }

    function getAssetValueETH(address _currencyAddress, uint256 _amount)
        public
        view
        returns (uint256 tokenEthValue)
    {

        tokenEthValue = _amount;
        if (_currencyAddress != ETH_ADDRESS) {
            tokenEthValue = getPrice(plotETHpair, _amount);
        }
    }

    function getAssetPriceInETH(address _currencyAddress)
        public
        view
        returns (uint256 tokenEthValue, uint256 decimals)
    {

        tokenEthValue = 1;
        if (_currencyAddress != ETH_ADDRESS) {
            decimals = IToken(_currencyAddress).decimals();
            tokenEthValue = getPrice(plotETHpair, 10**decimals);
        }
    }

    function getDisputeResolutionParams() public view returns (uint256) {

        return tokenStakeForDispute;
    }

    function getValueAndMultiplierParameters(address _asset, uint256 _amount)
        public
        view
        returns (uint256, uint256)
    {

        uint256 _value = _amount;
        if (_asset == ETH_ADDRESS) {
            _value = (uniswapPairData[plotETHpair].price1Average)
                .mul(_amount)
                .decode144();
        }
        return (minStakeForMultiplier, _value);
    }

    function getFeedAddresses() public view returns (address) {

        return (address(uniswapFactory));
    }

    function getPrice(address pair, uint256 amountIn)
        public
        view
        returns (uint256 amountOut)
    {

        amountOut = (uniswapPairData[pair].price0Average)
            .mul(amountIn)
            .decode144();
    }

    function sqrt(uint x) internal pure returns (uint y) {

      uint z = (x + 1) / 2;
      y = x;
      while (z < y) {
          y = z;
          z = (x / z + z) / 2;
      }
    }

    function calculatePredictionValue(uint[] memory params, address asset, address user, address marketFeedAddress, bool _checkMultiplier) public view returns(uint _predictionValue, bool _multiplierApplied) {

      uint _stakeValue = getAssetValueETH(asset, params[9]);
      if(_stakeValue < minPredictionAmount || _stakeValue > maxPredictionAmount) {
        return (_predictionValue, _multiplierApplied);
      }
      uint optionPrice;
      
      optionPrice = calculateOptionPrice(params, marketFeedAddress);
      _predictionValue = _calculatePredictionPoints(_stakeValue.mul(positionDecimals), optionPrice, params[10]);
      if(_checkMultiplier) {
        return checkMultiplier(asset, user, params[9],  _predictionValue, _stakeValue);
      }
      return (_predictionValue, _multiplierApplied);
    }

    function _calculatePredictionPoints(uint value, uint optionPrice, uint _leverage) internal pure returns(uint) {

      uint leverageMultiplier = 1000 + (_leverage-1)*50;
      value = value.mul(2500).div(1e18);
      return value.mul(sqrt(value.mul(10000))).mul(_leverage*100*leverageMultiplier).div(optionPrice.mul(1250000000));
    }

    function calculateOptionPrice(uint[] memory params, address marketFeedAddress) public view returns(uint _optionPrice) {

      uint _totalStaked = params[5].add(getAssetValueETH(plotToken, params[6]));
      uint _assetStakedOnOption = params[7]
                                .add(
                                  (getAssetValueETH(plotToken, params[8])));
      _optionPrice = 0;
      uint currentPriceOption = 0;
      uint256 currentPrice = getAssetPriceUSD(
          marketFeedAddress
      );
      uint stakeWeightage = STAKE_WEIGHTAGE;
      uint predictionWeightage = 100 - stakeWeightage;
      uint predictionTime = params[4].sub(params[3]);
      uint minTimeElapsed = (predictionTime).div(minTimeElapsedDivisor);
      if(now > params[4]) {
        return 0;
      }
      if(_totalStaked > STAKE_WEIGHTAGE_MIN_AMOUNT) {
        _optionPrice = (_assetStakedOnOption).mul(1000000).div(_totalStaked.mul(stakeWeightage));
      }

      uint maxDistance;
      if(currentPrice < params[1]) {
        currentPriceOption = 1;
        maxDistance = 2;
      } else if(currentPrice > params[2]) {
        currentPriceOption = 3;
        maxDistance = 2;
      } else {
        currentPriceOption = 2;
        maxDistance = 1;
      }
      uint distance = _getAbsoluteDifference(currentPriceOption, params[0]);
      uint timeElapsed = now > params[3] ? now.sub(params[3]) : 0;
      timeElapsed = timeElapsed > minTimeElapsed ? timeElapsed: minTimeElapsed;
      _optionPrice = _optionPrice.add((((maxDistance+1).sub(distance)).mul(1000000).mul(timeElapsed)).div((maxDistance+1).mul(predictionWeightage).mul(predictionTime)));
      _optionPrice = _optionPrice.div(100);
    }

    function _getAbsoluteDifference(uint value1, uint value2) internal pure returns(uint) {

      return value1 > value2 ? value1.sub(value2) : value2.sub(value1);
    }
}



pragma solidity 0.5.7;


contract MarketUtilityV2 is MarketUtility {


  using SafeMath64 for uint64;

  function setAuthorizedAddress(address _allMarketsContract) external {

    require(msg.sender == initiater);
    authorizedAddress = _allMarketsContract;
  }

  function calculateOptionRange(uint _optionRangePerc, uint64 _decimals, uint8 _roundOfToNearest, address _marketFeed) external view returns(uint64 _minValue, uint64 _maxValue) {

    uint currentPrice = getAssetPriceUSD(_marketFeed);
    uint optionRangePerc = currentPrice.mul(_optionRangePerc.div(2)).div(10000);
    _minValue = uint64((ceil(currentPrice.sub(optionRangePerc).div(_roundOfToNearest), 10**_decimals)).mul(_roundOfToNearest));
    _maxValue = uint64((ceil(currentPrice.add(optionRangePerc).div(_roundOfToNearest), 10**_decimals)).mul(_roundOfToNearest));
  }

  function calculatePredictionPoints(address _user, bool multiplierApplied, uint _predictionStake, address _asset, uint64 totalPredictionPoints, uint64 predictionPointsOnOption) external view returns(uint64 predictionPoints, bool isMultiplierApplied) {

      uint _stakeValue = getAssetValueETH(_asset, _predictionStake.mul(1e10));
      if(_stakeValue < minPredictionAmount || _stakeValue > maxPredictionAmount) {
        return (0, isMultiplierApplied);
      }
      uint64 _optionPrice = getOptionPrice(totalPredictionPoints, predictionPointsOnOption);
      predictionPoints = uint64(_stakeValue.div(1e10)).div(_optionPrice);
      if(!multiplierApplied) {
        uint256 _predictionPoints;
        (_predictionPoints, isMultiplierApplied) = checkMultiplier(_asset, _user, _predictionStake.mul(1e10),  predictionPoints, _stakeValue);
        predictionPoints = uint64(_predictionPoints);
      }
    }

    function getOptionPrice(uint64 totalPredictionPoints, uint64 predictionPointsOnOption) public view returns(uint64 _optionPrice) {

      if(totalPredictionPoints > 0) {
        _optionPrice = (predictionPointsOnOption.mul(100)).div(totalPredictionPoints) + 100;
      } else {
        _optionPrice = 100;
      }
    }

    function ceil(uint256 a, uint256 m) internal pure returns (uint256) {

        return ((a + m - 1) / m) * m;
    }

}



pragma solidity 0.5.7;


contract MarketUtilityV2_1 is MarketUtilityV2 {

    function getSettlemetPriceByRoundId(
        address _currencyFeedAddress,
        uint256 _settleTime,
        uint80 _roundId
    ) public view returns (uint256 latestAnswer, uint256 roundId) {

        uint80 roundIdToCheck;
        uint256 currentRoundTime;
        int256 currentRoundAnswer;
        (roundIdToCheck, currentRoundAnswer, , currentRoundTime, )= IChainLinkOracle(_currencyFeedAddress).latestRoundData();
        if(roundIdToCheck == _roundId) {
          if(currentRoundTime <= _settleTime) {
            return (uint256(currentRoundAnswer), roundIdToCheck);
          }
        } else {
          (roundIdToCheck, currentRoundAnswer, , currentRoundTime, )= IChainLinkOracle(_currencyFeedAddress).getRoundData(_roundId + 1);
          require(currentRoundTime > _settleTime);
          roundIdToCheck = _roundId + 1;
        }
        while(currentRoundTime > _settleTime) {
            roundIdToCheck--;
            (roundIdToCheck, currentRoundAnswer, , currentRoundTime, )= IChainLinkOracle(_currencyFeedAddress).getRoundData(roundIdToCheck);
        }
        return
            (uint256(currentRoundAnswer), roundIdToCheck);
    }
}