pragma solidity >=0.5.0;

interface IERC20Template {

    function initialize(
        string calldata name,
        string calldata symbol,
        address minter,
        uint256 cap,
        string calldata blob,
        address collector
    ) external returns (bool);


    function mint(address account, uint256 value) external;

    function minter() external view returns(address);    

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);

    function cap() external view returns (uint256);

    function isMinter(address account) external view returns (bool);

    function isInitialized() external view returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address to, uint256 value) external returns (bool);

    function proposeMinter(address newMinter) external;

    function approveMinter() external;

}pragma solidity 0.5.7;


library SafeMath {


  function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {

    if (a == 0) {
      return 0;
    }
    c = a * b;
    assert(c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {

    return a / b;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {

    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256 c) {

    c = a + b;
    assert(c >= a);
    return c;
  }
}pragma solidity 0.5.7;


contract FixedRateExchange {

    using SafeMath for uint256;
    uint256 private constant BASE = 10 ** 18;
    struct Exchange {
        bool active;
        address exchangeOwner;
        address dataToken;
        address baseToken;
        uint256 fixedRate;
    }

    mapping(bytes32 => Exchange) private exchanges;
    bytes32[] private exchangeIds;

    modifier onlyActiveExchange(
        bytes32 exchangeId
    )
    {

        require(
            exchanges[exchangeId].fixedRate != 0 &&
            exchanges[exchangeId].active == true,
            'FixedRateExchange: Exchange does not exist!'
        );
        _;
    }

    modifier onlyExchangeOwner(
        bytes32 exchangeId
    )
    {

        require(
            exchanges[exchangeId].exchangeOwner == msg.sender,
            'FixedRateExchange: invalid exchange owner'
        );
        _;
    }

    event ExchangeCreated(
        bytes32 indexed exchangeId,
        address indexed baseToken,
        address indexed dataToken,
        address exchangeOwner,
        uint256 fixedRate
    );

    event ExchangeRateChanged(
        bytes32 indexed exchangeId,
        address indexed exchangeOwner,
        uint256 newRate
    );

    event ExchangeActivated(
        bytes32 indexed exchangeId,
        address indexed exchangeOwner
    );

    event ExchangeDeactivated(
        bytes32 indexed exchangeId,
        address indexed exchangeOwner
    );

    event Swapped(
        bytes32 indexed exchangeId,
        address indexed by,
        uint256 baseTokenSwappedAmount,
        uint256 dataTokenSwappedAmount
    );

    function create(
        address baseToken,
        address dataToken,
        uint256 fixedRate
    )
        external
    {

        require(
            baseToken != address(0),
            'FixedRateExchange: Invalid basetoken,  zero address'
        );
        require(
            dataToken != address(0),
            'FixedRateExchange: Invalid datatoken,  zero address'
        );
        require(
            baseToken != dataToken,
            'FixedRateExchange: Invalid datatoken,  equals basetoken'
        );
        require(
            fixedRate != 0, 
            'FixedRateExchange: Invalid exchange rate value'
        );
        bytes32 exchangeId = generateExchangeId(
            baseToken,
            dataToken,
            msg.sender
        );
        require(
            exchanges[exchangeId].fixedRate == 0,
            'FixedRateExchange: Exchange already exists!'
        );
        exchanges[exchangeId] = Exchange({
            active: true,
            exchangeOwner: msg.sender,
            dataToken: dataToken,
            baseToken: baseToken,
            fixedRate: fixedRate
        });
        exchangeIds.push(exchangeId);

        emit ExchangeCreated(
            exchangeId,
            baseToken,
            dataToken,
            msg.sender,
            fixedRate
        );

        emit ExchangeActivated(
            exchangeId,
            msg.sender
        );
    }

    function generateExchangeId(
        address baseToken,
        address dataToken,
        address exchangeOwner
    )
        public
        pure
        returns (bytes32)
    {

        return keccak256(
            abi.encode(
                baseToken,
                dataToken,
                exchangeOwner
            )
        );
    }
    
    function CalcInGivenOut(
        bytes32 exchangeId,
        uint256 dataTokenAmount
    )
        public
        view
        onlyActiveExchange(
            exchangeId
        )
        returns (uint256 baseTokenAmount)
    {

        baseTokenAmount = dataTokenAmount.mul(
            exchanges[exchangeId].fixedRate).div(BASE);
    }
    
    function swap(
        bytes32 exchangeId,
        uint256 dataTokenAmount
    )
        external
        onlyActiveExchange(
            exchangeId
        )
    {

        require(
            dataTokenAmount != 0,
            'FixedRateExchange: zero data token amount'
        );
        uint256 baseTokenAmount = CalcInGivenOut(exchangeId,dataTokenAmount);
        require(
            IERC20Template(exchanges[exchangeId].baseToken).transferFrom(
                msg.sender,
                exchanges[exchangeId].exchangeOwner,
                baseTokenAmount
            ),
            'FixedRateExchange: transferFrom failed in the baseToken contract'
        );
        require(
            IERC20Template(exchanges[exchangeId].dataToken).transferFrom(
                exchanges[exchangeId].exchangeOwner,
                msg.sender,
                dataTokenAmount
            ),
            'FixedRateExchange: transferFrom failed in the dataToken contract'
        );

        emit Swapped(
            exchangeId,
            msg.sender,
            baseTokenAmount,
            dataTokenAmount
        );
    }

    function getNumberOfExchanges()
        external
        view
        returns (uint256)
    {

        return exchangeIds.length;
    }

    function setRate(
        bytes32 exchangeId,
        uint256 newRate
    )
        external
        onlyExchangeOwner(exchangeId)
    {

        require(
            newRate != 0,
            'FixedRateExchange: Ratio must be >0'
        );

        exchanges[exchangeId].fixedRate = newRate;
        emit ExchangeRateChanged(
            exchangeId,
            msg.sender,
            newRate
        );
    }

    function toggleExchangeState(
        bytes32 exchangeId
    )
        external
        onlyExchangeOwner(exchangeId)
    {

        if(exchanges[exchangeId].active){
            exchanges[exchangeId].active = false;
            emit ExchangeDeactivated(
                exchangeId,
                msg.sender
            );
        } else {
            exchanges[exchangeId].active = true;
            emit ExchangeActivated(
                exchangeId,
                msg.sender
            );
        }
    }

    function getRate(
        bytes32 exchangeId
    )
        external
        view
        returns(uint256)
    {

        return exchanges[exchangeId].fixedRate;
    }

    function getSupply(bytes32 exchangeId)
        public
        view
        returns (uint256 supply)
    {

        if(exchanges[exchangeId].active == false)
            supply = 0;
        else {
            uint256 balance = IERC20Template(exchanges[exchangeId].dataToken)
                .balanceOf(exchanges[exchangeId].exchangeOwner);
            uint256 allowance = IERC20Template(exchanges[exchangeId].dataToken)
                .allowance(exchanges[exchangeId].exchangeOwner, address(this));
            if(balance < allowance)
                supply = balance;
            else
                supply = allowance;
        }
    }

    function getExchange(
        bytes32 exchangeId
    )
        external
        view
        returns (
            address exchangeOwner,
            address dataToken,
            address baseToken,
            uint256 fixedRate,
            bool active,
            uint256 supply
        )
    {

        Exchange memory exchange = exchanges[exchangeId];
        exchangeOwner = exchange.exchangeOwner;
        dataToken = exchange.dataToken;
        baseToken = exchange.baseToken;
        fixedRate = exchange.fixedRate;
        active = exchange.active;
        supply = getSupply(exchangeId);
    }

    function getExchanges()
        external 
        view 
        returns (bytes32[] memory)
    {

        return exchangeIds;
    }

    function isActive(
        bytes32 exchangeId
    )
        external
        view
        returns (bool)
    {

        return exchanges[exchangeId].active;
    }
}