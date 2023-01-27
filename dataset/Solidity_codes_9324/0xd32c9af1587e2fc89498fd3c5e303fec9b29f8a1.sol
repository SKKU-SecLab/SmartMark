

pragma solidity 0.4.26;

contract Utils {

    modifier greaterThanZero(uint256 _value) {

        _greaterThanZero(_value);
        _;
    }

    function _greaterThanZero(uint256 _value) internal pure {

        require(_value > 0, "ERR_ZERO_VALUE");
    }

    modifier validAddress(address _address) {

        _validAddress(_address);
        _;
    }

    function _validAddress(address _address) internal pure {

        require(_address != address(0), "ERR_INVALID_ADDRESS");
    }

    modifier notThis(address _address) {

        _notThis(_address);
        _;
    }

    function _notThis(address _address) internal view {

        require(_address != address(this), "ERR_ADDRESS_IS_SELF");
    }
}


pragma solidity 0.4.26;

library SafeMath {

    function add(uint256 _x, uint256 _y) internal pure returns (uint256) {

        uint256 z = _x + _y;
        require(z >= _x, "ERR_OVERFLOW");
        return z;
    }

    function sub(uint256 _x, uint256 _y) internal pure returns (uint256) {

        require(_x >= _y, "ERR_UNDERFLOW");
        return _x - _y;
    }

    function mul(uint256 _x, uint256 _y) internal pure returns (uint256) {

        if (_x == 0)
            return 0;

        uint256 z = _x * _y;
        require(z / _x == _y, "ERR_OVERFLOW");
        return z;
    }

    function div(uint256 _x, uint256 _y) internal pure returns (uint256) {

        require(_y > 0, "ERR_DIVIDE_BY_ZERO");
        uint256 c = _x / _y;
        return c;
    }
}


pragma solidity 0.4.26;

interface IChainlinkPriceOracle {

    function latestAnswer() external view returns (int256);

    function latestTimestamp() external view returns (uint256);

}


pragma solidity 0.4.26;

contract IERC20Token {

    function name() public view returns (string) {this;}

    function symbol() public view returns (string) {this;}

    function decimals() public view returns (uint8) {this;}

    function totalSupply() public view returns (uint256) {this;}

    function balanceOf(address _owner) public view returns (uint256) {_owner; this;}

    function allowance(address _owner, address _spender) public view returns (uint256) {_owner; _spender; this;}


    function transfer(address _to, uint256 _value) public returns (bool success);

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);

    function approve(address _spender, uint256 _value) public returns (bool success);

}


pragma solidity 0.4.26;



contract IPriceOracle {

    function latestRate(IERC20Token _tokenA, IERC20Token _tokenB) public view returns (uint256, uint256);

    function lastUpdateTime() public view returns (uint256);

    function latestRateAndUpdateTime(IERC20Token _tokenA, IERC20Token _tokenB) public view returns (uint256, uint256, uint256);


    function tokenAOracle() public view returns (IChainlinkPriceOracle) {this;}

    function tokenBOracle() public view returns (IChainlinkPriceOracle) {this;}

}


pragma solidity 0.4.26;





contract PriceOracle is IPriceOracle, Utils {

    using SafeMath for uint256;

    address private constant ETH_ADDRESS = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;
    uint8 private constant ETH_DECIMALS = 18;

    IERC20Token public tokenA;                  // token A the oracle supports
    IERC20Token public tokenB;                  // token B the oracle supports
    mapping (address => uint8) public tokenDecimals; // token -> token decimals

    IChainlinkPriceOracle public tokenAOracle;  // token A chainlink price oracle
    IChainlinkPriceOracle public tokenBOracle;  // token B chainlink price oracle
    mapping (address => IChainlinkPriceOracle) public tokensToOracles;  // token -> price oracle for easier access

    constructor(IERC20Token _tokenA, IERC20Token _tokenB, IChainlinkPriceOracle _tokenAOracle, IChainlinkPriceOracle _tokenBOracle)
        public
        validUniqueAddresses(_tokenA, _tokenB)
        validUniqueAddresses(_tokenAOracle, _tokenBOracle)
    {
        tokenA = _tokenA;
        tokenB = _tokenB;
        tokenDecimals[_tokenA] = decimals(_tokenA);
        tokenDecimals[_tokenB] = decimals(_tokenB);

        tokenAOracle = _tokenAOracle;
        tokenBOracle = _tokenBOracle;
        tokensToOracles[_tokenA] = _tokenAOracle;
        tokensToOracles[_tokenB] = _tokenBOracle;
    }

    modifier validUniqueAddresses(address _address1, address _address2) {

        _validUniqueAddresses(_address1, _address2);
        _;
    }

    function _validUniqueAddresses(address _address1, address _address2) internal pure {

        _validAddress(_address1);
        _validAddress(_address2);
        require(_address1 != _address2, "ERR_SAME_ADDRESS");
    }

    modifier supportedTokens(IERC20Token _tokenA, IERC20Token _tokenB) {

        _supportedTokens(_tokenA, _tokenB);
        _;
    }

    function _supportedTokens(IERC20Token _tokenA, IERC20Token _tokenB) internal view {

        _validUniqueAddresses(_tokenA, _tokenB);
        require(tokensToOracles[_tokenA] != address(0) && tokensToOracles[_tokenB] != address(0), "ERR_UNSUPPORTED_TOKEN");
    }

    function latestRate(IERC20Token _tokenA, IERC20Token _tokenB)
        public
        view
        supportedTokens(_tokenA, _tokenB)
        returns (uint256, uint256)
    {

        uint256 rateTokenA = uint256(tokensToOracles[_tokenA].latestAnswer());
        uint256 rateTokenB = uint256(tokensToOracles[_tokenB].latestAnswer());
        uint8 decimalsTokenA = tokenDecimals[_tokenA];
        uint8 decimalsTokenB = tokenDecimals[_tokenB];


        if (decimalsTokenA > decimalsTokenB) {
            rateTokenB = rateTokenB.mul(uint256(10) ** (decimalsTokenA - decimalsTokenB));
        }
        else if (decimalsTokenA < decimalsTokenB) {
            rateTokenA = rateTokenA.mul(uint256(10) ** (decimalsTokenB - decimalsTokenA));
        }

        return (rateTokenA, rateTokenB);
    }

    function lastUpdateTime()
        public
        view
        returns (uint256) {

        uint256 timestampA = tokenAOracle.latestTimestamp();
        uint256 timestampB = tokenBOracle.latestTimestamp();

        return  timestampA < timestampB ? timestampA : timestampB;
    }

    function latestRateAndUpdateTime(IERC20Token _tokenA, IERC20Token _tokenB)
        public
        view
        returns (uint256, uint256, uint256)
    {

        (uint256 numerator, uint256 denominator) = latestRate(_tokenA, _tokenB);

        return (numerator, denominator, lastUpdateTime());
    }

    function decimals(IERC20Token _token) private view returns (uint8) {

        if (_token == ETH_ADDRESS) {
            return ETH_DECIMALS;
        }

        return _token.decimals();
    }
}