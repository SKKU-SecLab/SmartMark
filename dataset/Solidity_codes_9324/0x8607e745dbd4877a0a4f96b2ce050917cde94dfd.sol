pragma solidity ^0.7.0;

abstract contract AdminStorage {
    address public admin;
}
pragma solidity ^0.7.0;


abstract contract AdminInterface is AdminStorage {
    function _renounceAdmin() external virtual;

    function _transferAdmin(address newAdmin) external virtual;

    event TransferAdmin(address indexed oldAdmin, address indexed newAdmin);
}
pragma solidity ^0.7.0;


abstract contract Admin is AdminInterface {
    modifier onlyAdmin() {
        require(admin == msg.sender, "ERR_NOT_ADMIN");
        _;
    }

    constructor() {
        address msgSender = msg.sender;
        admin = msgSender;
        emit TransferAdmin(address(0x00), msgSender);
    }

    function _renounceAdmin() external virtual override onlyAdmin {
        emit TransferAdmin(admin, address(0x00));
        admin = address(0x00);
    }

    function _transferAdmin(address newAdmin) external virtual override onlyAdmin {
        require(newAdmin != address(0x00), "ERR_SET_ADMIN_ZERO_ADDRESS");
        emit TransferAdmin(admin, newAdmin);
        admin = newAdmin;
    }
}
pragma solidity ^0.7.0;

enum MathError { NO_ERROR, DIVISION_BY_ZERO, INTEGER_OVERFLOW, INTEGER_UNDERFLOW, MODULO_BY_ZERO }

abstract contract CarefulMath {
    function addUInt(uint256 a, uint256 b) internal pure returns (MathError, uint256) {
        uint256 c = a + b;

        if (c >= a) {
            return (MathError.NO_ERROR, c);
        } else {
            return (MathError.INTEGER_OVERFLOW, 0);
        }
    }

    function addThenSubUInt(
        uint256 a,
        uint256 b,
        uint256 c
    ) internal pure returns (MathError, uint256) {
        (MathError err0, uint256 sum) = addUInt(a, b);

        if (err0 != MathError.NO_ERROR) {
            return (err0, 0);
        }

        return subUInt(sum, c);
    }

    function divUInt(uint256 a, uint256 b) internal pure returns (MathError, uint256) {
        if (b == 0) {
            return (MathError.DIVISION_BY_ZERO, 0);
        }

        return (MathError.NO_ERROR, a / b);
    }

    function modUInt(uint256 a, uint256 b) internal pure returns (MathError, uint256) {
        if (b == 0) {
            return (MathError.MODULO_BY_ZERO, 0);
        }

        return (MathError.NO_ERROR, a % b);
    }

    function mulUInt(uint256 a, uint256 b) internal pure returns (MathError, uint256) {
        if (a == 0) {
            return (MathError.NO_ERROR, 0);
        }

        uint256 c = a * b;

        if (c / a != b) {
            return (MathError.INTEGER_OVERFLOW, 0);
        } else {
            return (MathError.NO_ERROR, c);
        }
    }

    function subUInt(uint256 a, uint256 b) internal pure returns (MathError, uint256) {
        if (b <= a) {
            return (MathError.NO_ERROR, a - b);
        } else {
            return (MathError.INTEGER_UNDERFLOW, 0);
        }
    }
}
pragma solidity ^0.7.0;

abstract contract Erc20Storage {
    uint8 public decimals;

    string public name;

    string public symbol;

    uint256 public totalSupply;

    mapping(address => mapping(address => uint256)) internal allowances;

    mapping(address => uint256) internal balances;
}
pragma solidity ^0.7.0;


abstract contract Erc20Interface is Erc20Storage {
    function allowance(address owner, address spender) external view virtual returns (uint256);

    function balanceOf(address account) external view virtual returns (uint256);

    function approve(address spender, uint256 amount) external virtual returns (bool);

    function transfer(address recipient, uint256 amount) external virtual returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external virtual returns (bool);

    event Approval(address indexed owner, address indexed spender, uint256 amount);

    event Burn(address indexed holder, uint256 burnAmount);

    event Mint(address indexed beneficiary, uint256 mintAmount);

    event Transfer(address indexed from, address indexed to, uint256 amount);
}
pragma solidity ^0.7.0;

interface AggregatorV3Interface {

    function decimals() external view returns (uint8);


    function description() external view returns (string memory);


    function version() external view returns (uint256);


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
pragma solidity ^0.7.0;



abstract contract ChainlinkOperatorStorage {
    struct Feed {
        Erc20Interface asset;
        AggregatorV3Interface id;
        bool isSet;
    }

    mapping(string => Feed) internal feeds;

    uint256 public constant pricePrecision = 8;

    uint256 public constant pricePrecisionScalar = 1.0e10;
}
pragma solidity ^0.7.0;



abstract contract ChainlinkOperatorInterface is ChainlinkOperatorStorage {
    event DeleteFeed(Erc20Interface indexed asset, AggregatorV3Interface indexed feed);

    event SetFeed(Erc20Interface indexed asset, AggregatorV3Interface indexed feed);

    function getAdjustedPrice(string memory symbol) external view virtual returns (uint256);

    function getFeed(string memory symbol)
        external
        view
        virtual
        returns (
            Erc20Interface,
            AggregatorV3Interface,
            bool
        );

    function getPrice(string memory symbol) public view virtual returns (uint256);

    function deleteFeed(string memory symbol) external virtual returns (bool);

    function setFeed(Erc20Interface asset, AggregatorV3Interface feed) external virtual returns (bool);
}
pragma solidity ^0.7.0;



contract ChainlinkOperator is
    CarefulMath, /* no dependency */
    ChainlinkOperatorInterface, /* no dependency */
    Admin /* two dependencies */
{

    constructor() Admin() {}


    function getAdjustedPrice(string memory symbol) external view override returns (uint256) {

        uint256 price = getPrice(symbol);
        (MathError mathErr, uint256 adjustedPrice) = mulUInt(price, pricePrecisionScalar);
        require(mathErr == MathError.NO_ERROR, "ERR_GET_ADJUSTED_PRICE_MATH_ERROR");
        return adjustedPrice;
    }

    function getFeed(string memory symbol)
        external
        view
        override
        returns (
            Erc20Interface,
            AggregatorV3Interface,
            bool
        )
    {

        return (feeds[symbol].asset, feeds[symbol].id, feeds[symbol].isSet);
    }

    function getPrice(string memory symbol) public view override returns (uint256) {

        require(feeds[symbol].isSet, "ERR_FEED_NOT_SET");
        (, int256 intPrice, , , ) = AggregatorV3Interface(feeds[symbol].id).latestRoundData();
        uint256 price = uint256(intPrice);
        require(price > 0, "ERR_PRICE_ZERO");
        return price;
    }


    function deleteFeed(string memory symbol) external override onlyAdmin returns (bool) {

        require(feeds[symbol].isSet, "ERR_FEED_NOT_SET");

        AggregatorV3Interface feed = feeds[symbol].id;
        Erc20Interface asset = feeds[symbol].asset;
        delete feeds[symbol];

        emit DeleteFeed(asset, feed);
        return true;
    }

    function setFeed(Erc20Interface asset, AggregatorV3Interface feed) external override onlyAdmin returns (bool) {

        string memory symbol = asset.symbol();

        uint8 decimals = feed.decimals();
        require(decimals == pricePrecision, "ERR_FEED_INCORRECT_DECIMALS");

        feeds[symbol] = Feed({ asset: asset, id: feed, isSet: true });

        emit SetFeed(asset, feed);
        return true;
    }
}
