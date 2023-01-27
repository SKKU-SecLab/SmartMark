
pragma solidity >=0.6.0 <0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}// MIT

pragma solidity >=0.6.0 <0.8.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}// MIT

pragma solidity >=0.6.0 <0.8.0;

library SafeMath {

    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b > a) return (false, 0);
        return (true, a - b);
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b == 0) return (false, 0);
        return (true, a / b);
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b == 0) return (false, 0);
        return (true, a % b);
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b <= a, "SafeMath: subtraction overflow");
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0, "SafeMath: division by zero");
        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0, "SafeMath: modulo by zero");
        return a % b;
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b <= a, errorMessage);
        return a - b;
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        return a / b;
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        return a % b;
    }
}// MIT

pragma solidity >=0.6.0 <0.8.0;


contract ERC20 is Context, IERC20 {

    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor (string memory name_, string memory symbol_) public {
        _name = name_;
        _symbol = symbol_;
        _decimals = 18;
    }

    function name() public view virtual returns (string memory) {

        return _name;
    }

    function symbol() public view virtual returns (string memory) {

        return _symbol;
    }

    function decimals() public view virtual returns (uint8) {

        return _decimals;
    }

    function totalSupply() public view virtual override returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address account) public view virtual override returns (uint256) {

        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {

        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {

        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {

        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {

        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal virtual {

        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal virtual {

        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _setupDecimals(uint8 decimals_) internal virtual {

        _decimals = decimals_;
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }

}pragma solidity 0.6.12;

interface IdleToken {
  function totalSupply() external view returns (uint256);
  function tokenPrice() external view returns (uint256 price);
  function token() external view returns (address);
  function getAvgAPR() external view returns (uint256 apr);
  function balanceOf(address) external view returns (uint256 apr);
  function getAPRs() external view returns (address[] memory addresses, uint256[] memory aprs);
  function mintIdleToken(uint256 _amount, bool _skipRebalance, address _referral) external returns (uint256 mintedTokens);
  function redeemIdleToken(uint256 _amount) external returns (uint256 redeemedTokens);
  function redeemInterestBearingTokens(uint256 _amount) external;
  function rebalance() external returns (bool);
}pragma solidity 0.6.12;

contract CarefulMath {

    enum MathError {
        NO_ERROR,
        DIVISION_BY_ZERO,
        INTEGER_OVERFLOW,
        INTEGER_UNDERFLOW
    }

    function mulUInt(uint a, uint b) internal pure returns (MathError, uint) {
        if (a == 0) {
            return (MathError.NO_ERROR, 0);
        }

        uint c = a * b;

        if (c / a != b) {
            return (MathError.INTEGER_OVERFLOW, 0);
        } else {
            return (MathError.NO_ERROR, c);
        }
    }

    function divUInt(uint a, uint b) internal pure returns (MathError, uint) {
        if (b == 0) {
            return (MathError.DIVISION_BY_ZERO, 0);
        }

        return (MathError.NO_ERROR, a / b);
    }

    function subUInt(uint a, uint b) internal pure returns (MathError, uint) {
        if (b <= a) {
            return (MathError.NO_ERROR, a - b);
        } else {
            return (MathError.INTEGER_UNDERFLOW, 0);
        }
    }

    function addUInt(uint a, uint b) internal pure returns (MathError, uint) {
        uint c = a + b;

        if (c >= a) {
            return (MathError.NO_ERROR, c);
        } else {
            return (MathError.INTEGER_OVERFLOW, 0);
        }
    }

    function addThenSubUInt(uint a, uint b, uint c) internal pure returns (MathError, uint) {
        (MathError err0, uint sum) = addUInt(a, b);

        if (err0 != MathError.NO_ERROR) {
            return (err0, 0);
        }

        return subUInt(sum, c);
    }
}pragma solidity 0.6.12;


contract Exponential is CarefulMath {
    uint constant expScale = 1e18;
    uint constant doubleScale = 1e36;
    uint constant halfExpScale = expScale/2;
    uint constant mantissaOne = expScale;

    struct Exp {
        uint mantissa;
    }

    struct Double {
        uint mantissa;
    }

    function getExp(uint num, uint denom) pure internal returns (MathError, Exp memory) {
        (MathError err0, uint scaledNumerator) = mulUInt(num, expScale);
        if (err0 != MathError.NO_ERROR) {
            return (err0, Exp({mantissa: 0}));
        }

        (MathError err1, uint rational) = divUInt(scaledNumerator, denom);
        if (err1 != MathError.NO_ERROR) {
            return (err1, Exp({mantissa: 0}));
        }

        return (MathError.NO_ERROR, Exp({mantissa: rational}));
    }

    function addExp(Exp memory a, Exp memory b) pure internal returns (MathError, Exp memory) {
        (MathError error, uint result) = addUInt(a.mantissa, b.mantissa);

        return (error, Exp({mantissa: result}));
    }

    function subExp(Exp memory a, Exp memory b) pure internal returns (MathError, Exp memory) {
        (MathError error, uint result) = subUInt(a.mantissa, b.mantissa);

        return (error, Exp({mantissa: result}));
    }

    function mulScalar(Exp memory a, uint scalar) pure internal returns (MathError, Exp memory) {
        (MathError err0, uint scaledMantissa) = mulUInt(a.mantissa, scalar);
        if (err0 != MathError.NO_ERROR) {
            return (err0, Exp({mantissa: 0}));
        }

        return (MathError.NO_ERROR, Exp({mantissa: scaledMantissa}));
    }

    function mulScalarTruncate(Exp memory a, uint scalar) pure internal returns (MathError, uint) {
        (MathError err, Exp memory product) = mulScalar(a, scalar);
        if (err != MathError.NO_ERROR) {
            return (err, 0);
        }

        return (MathError.NO_ERROR, truncate(product));
    }

    function mulScalarTruncateAddUInt(Exp memory a, uint scalar, uint addend) pure internal returns (MathError, uint) {
        (MathError err, Exp memory product) = mulScalar(a, scalar);
        if (err != MathError.NO_ERROR) {
            return (err, 0);
        }

        return addUInt(truncate(product), addend);
    }

    function divScalar(Exp memory a, uint scalar) pure internal returns (MathError, Exp memory) {
        (MathError err0, uint descaledMantissa) = divUInt(a.mantissa, scalar);
        if (err0 != MathError.NO_ERROR) {
            return (err0, Exp({mantissa: 0}));
        }

        return (MathError.NO_ERROR, Exp({mantissa: descaledMantissa}));
    }

    function divScalarByExp(uint scalar, Exp memory divisor) pure internal returns (MathError, Exp memory) {
        (MathError err0, uint numerator) = mulUInt(expScale, scalar);
        if (err0 != MathError.NO_ERROR) {
            return (err0, Exp({mantissa: 0}));
        }
        return getExp(numerator, divisor.mantissa);
    }

    function divScalarByExpTruncate(uint scalar, Exp memory divisor) pure internal returns (MathError, uint) {
        (MathError err, Exp memory fraction) = divScalarByExp(scalar, divisor);
        if (err != MathError.NO_ERROR) {
            return (err, 0);
        }

        return (MathError.NO_ERROR, truncate(fraction));
    }

    function mulExp(Exp memory a, Exp memory b) pure internal returns (MathError, Exp memory) {

        (MathError err0, uint doubleScaledProduct) = mulUInt(a.mantissa, b.mantissa);
        if (err0 != MathError.NO_ERROR) {
            return (err0, Exp({mantissa: 0}));
        }

        (MathError err1, uint doubleScaledProductWithHalfScale) = addUInt(halfExpScale, doubleScaledProduct);
        if (err1 != MathError.NO_ERROR) {
            return (err1, Exp({mantissa: 0}));
        }

        (MathError err2, uint product) = divUInt(doubleScaledProductWithHalfScale, expScale);
        assert(err2 == MathError.NO_ERROR);

        return (MathError.NO_ERROR, Exp({mantissa: product}));
    }

    function mulExp(uint a, uint b) pure internal returns (MathError, Exp memory) {
        return mulExp(Exp({mantissa: a}), Exp({mantissa: b}));
    }

    function mulExp3(Exp memory a, Exp memory b, Exp memory c) pure internal returns (MathError, Exp memory) {
        (MathError err, Exp memory ab) = mulExp(a, b);
        if (err != MathError.NO_ERROR) {
            return (err, ab);
        }
        return mulExp(ab, c);
    }

    function divExp(Exp memory a, Exp memory b) pure internal returns (MathError, Exp memory) {
        return getExp(a.mantissa, b.mantissa);
    }

    function truncate(Exp memory exp) pure internal returns (uint) {
        return exp.mantissa / expScale;
    }

    function lessThanExp(Exp memory left, Exp memory right) pure internal returns (bool) {
        return left.mantissa < right.mantissa;
    }

    function lessThanOrEqualExp(Exp memory left, Exp memory right) pure internal returns (bool) {
        return left.mantissa <= right.mantissa;
    }

    function greaterThanExp(Exp memory left, Exp memory right) pure internal returns (bool) {
        return left.mantissa > right.mantissa;
    }

    function isZeroExp(Exp memory value) pure internal returns (bool) {
        return value.mantissa == 0;
    }

    function safe224(uint n, string memory errorMessage) pure internal returns (uint224) {
        require(n < 2**224, errorMessage);
        return uint224(n);
    }

    function safe32(uint n, string memory errorMessage) pure internal returns (uint32) {
        require(n < 2**32, errorMessage);
        return uint32(n);
    }

    function add_(Exp memory a, Exp memory b) pure internal returns (Exp memory) {
        return Exp({mantissa: add_(a.mantissa, b.mantissa)});
    }

    function add_(Double memory a, Double memory b) pure internal returns (Double memory) {
        return Double({mantissa: add_(a.mantissa, b.mantissa)});
    }

    function add_(uint a, uint b) pure internal returns (uint) {
        return add_(a, b, "addition overflow");
    }

    function add_(uint a, uint b, string memory errorMessage) pure internal returns (uint) {
        uint c = a + b;
        require(c >= a, errorMessage);
        return c;
    }

    function sub_(Exp memory a, Exp memory b) pure internal returns (Exp memory) {
        return Exp({mantissa: sub_(a.mantissa, b.mantissa)});
    }

    function sub_(Double memory a, Double memory b) pure internal returns (Double memory) {
        return Double({mantissa: sub_(a.mantissa, b.mantissa)});
    }

    function sub_(uint a, uint b) pure internal returns (uint) {
        return sub_(a, b, "subtraction underflow");
    }

    function sub_(uint a, uint b, string memory errorMessage) pure internal returns (uint) {
        require(b <= a, errorMessage);
        return a - b;
    }

    function mul_(Exp memory a, Exp memory b) pure internal returns (Exp memory) {
        return Exp({mantissa: mul_(a.mantissa, b.mantissa) / expScale});
    }

    function mul_(Exp memory a, uint b) pure internal returns (Exp memory) {
        return Exp({mantissa: mul_(a.mantissa, b)});
    }

    function mul_(uint a, Exp memory b) pure internal returns (uint) {
        return mul_(a, b.mantissa) / expScale;
    }

    function mul_(Double memory a, Double memory b) pure internal returns (Double memory) {
        return Double({mantissa: mul_(a.mantissa, b.mantissa) / doubleScale});
    }

    function mul_(Double memory a, uint b) pure internal returns (Double memory) {
        return Double({mantissa: mul_(a.mantissa, b)});
    }

    function mul_(uint a, Double memory b) pure internal returns (uint) {
        return mul_(a, b.mantissa) / doubleScale;
    }

    function mul_(uint a, uint b) pure internal returns (uint) {
        return mul_(a, b, "multiplication overflow");
    }

    function mul_(uint a, uint b, string memory errorMessage) pure internal returns (uint) {
        if (a == 0 || b == 0) {
            return 0;
        }
        uint c = a * b;
        require(c / a == b, errorMessage);
        return c;
    }

    function div_(Exp memory a, Exp memory b) pure internal returns (Exp memory) {
        return Exp({mantissa: div_(mul_(a.mantissa, expScale), b.mantissa)});
    }

    function div_(Exp memory a, uint b) pure internal returns (Exp memory) {
        return Exp({mantissa: div_(a.mantissa, b)});
    }

    function div_(uint a, Exp memory b) pure internal returns (uint) {
        return div_(mul_(a, expScale), b.mantissa);
    }

    function div_(Double memory a, Double memory b) pure internal returns (Double memory) {
        return Double({mantissa: div_(mul_(a.mantissa, doubleScale), b.mantissa)});
    }

    function div_(Double memory a, uint b) pure internal returns (Double memory) {
        return Double({mantissa: div_(a.mantissa, b)});
    }

    function div_(uint a, Double memory b) pure internal returns (uint) {
        return div_(mul_(a, doubleScale), b.mantissa);
    }

    function div_(uint a, uint b) pure internal returns (uint) {
        return div_(a, b, "divide by zero");
    }

    function div_(uint a, uint b, string memory errorMessage) pure internal returns (uint) {
        require(b > 0, errorMessage);
        return a / b;
    }

    function fraction(uint a, uint b) pure internal returns (Double memory) {
        return Double({mantissa: div_(mul_(a, doubleScale), b)});
    }
}// MIT

pragma solidity >=0.6.0 <0.8.0;

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}pragma solidity 0.6.12;

interface CERC20 {
  function comptroller() external view returns (address);
  function exchangeRateStored() external view returns (uint256);
}pragma solidity 0.6.12;

interface Comptroller {
  function claimComp(address) external;
  function compSpeeds(address _cToken) external view returns (uint256);
  function compSupplySpeeds(address _cToken) external view returns (uint256);
  function claimComp(address[] calldata holders, address[] calldata cTokens, bool borrowers, bool suppliers) external;
}pragma solidity 0.6.12;

interface ChainLinkOracle {
  function latestAnswer() external view returns (uint256);
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
}pragma solidity 0.6.12;



contract PriceOracle is Ownable {
  using SafeMath for uint256;

  uint256 constant private ONE_18 = 10**18;
  address constant public WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
  address constant public COMP = 0xc00e94Cb662C3520282E6f5717214004A7f26888;
  address constant public WBTC = 0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599;
  address constant public DAI = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
  address constant public SUSD = 0x57Ab1ec28D129707052df4dF418D58a2D46d5f51;
  address constant public TUSD = 0x0000000000085d4780B73119b644AE5ecd22b376;
  address constant public USDC = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
  address constant public USDT = 0xdAC17F958D2ee523a2206206994597C13D831ec7;

  uint256 public blocksPerYear = 2371428; // -> blocks per year with ~13.3s block time
  mapping (address => address) public priceFeedsUSD;
  mapping (address => address) public priceFeedsETH;

  constructor() public {
    priceFeedsUSD[WETH] = 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419; // WETH
    priceFeedsUSD[COMP] = 0xdbd020CAeF83eFd542f4De03e3cF0C28A4428bd5; // COMP
    priceFeedsUSD[WBTC] = 0xF4030086522a5bEEa4988F8cA5B36dbC97BeE88c; // wBTC
    priceFeedsUSD[DAI] = 0xAed0c38402a5d19df6E4c03F4E2DceD6e29c1ee9; // DAI

    priceFeedsETH[WBTC] = 0xdeb288F737066589598e9214E782fa5A8eD689e8; // wBTC
    priceFeedsETH[DAI] = 0x773616E4d11A78F511299002da57A0a94577F1f4; // DAI
    priceFeedsETH[SUSD] = 0x8e0b7e6062272B5eF4524250bFFF8e5Bd3497757; // SUSD
    priceFeedsETH[TUSD] = 0x3886BA987236181D98F2401c507Fb8BeA7871dF2; // TUSD
    priceFeedsETH[USDC] = 0x986b5E1e1755e3C2440e960477f25201B0a8bbD4; // USDC
    priceFeedsETH[USDT] = 0xEe9F2375b4bdF6387aa8265dD4FB8F16512A1d46; // USDT
  }

  function getPriceUSD(address _asset) public view returns (uint256) {
    return _getPriceUSD(_asset); // 1e18
  }
  function getPriceETH(address _asset) public view returns (uint256) {
    return _getPriceETH(_asset); // 1e18
  }
  function getPriceToken(address _asset, address _token) public view returns (uint256) {
    return _getPriceToken(_asset, _token); // 1e(_token.decimals())
  }
  function getUnderlyingPrice(address _idleToken) external view returns (uint256) {
    return getPriceUSD(IdleToken(_idleToken).token()); // 1e18
  }
  function getCompApr(address _cToken, address _token) external view returns (uint256) {
    CERC20 _ctoken = CERC20(_cToken);
    uint256 compSpeeds = Comptroller(_ctoken.comptroller()).compSpeeds(_cToken);
    uint256 cTokenNAV = _ctoken.exchangeRateStored().mul(IERC20(_cToken).totalSupply()).div(ONE_18);
    uint256 compUnderlyingPrice = getPriceToken(COMP, _token);
    return compSpeeds.mul(compUnderlyingPrice).mul(blocksPerYear).mul(100).div(cTokenNAV);
  }

  function _getPriceUSD(address _asset) internal view returns (uint256 price) {
    if (priceFeedsUSD[_asset] != address(0)) {
      price = ChainLinkOracle(priceFeedsUSD[_asset]).latestAnswer().mul(10**10); // scale it to 1e18
    } else if (priceFeedsETH[_asset] != address(0)) {
      price = ChainLinkOracle(priceFeedsETH[_asset]).latestAnswer();
      price = price.mul(ChainLinkOracle(priceFeedsUSD[WETH]).latestAnswer().mul(10**10)).div(ONE_18);
    }
  }
  function _getPriceETH(address _asset) internal view returns (uint256 price) {
    if (priceFeedsETH[_asset] != address(0)) {
      price = ChainLinkOracle(priceFeedsETH[_asset]).latestAnswer();
    }
  }
  function _getPriceToken(address _asset, address _token) internal view returns (uint256 price) {
    uint256 assetUSD = getPriceUSD(_asset);
    uint256 tokenUSD = getPriceUSD(_token);
    if (tokenUSD == 0) {
      return price;
    }
    return assetUSD.mul(10**(uint256(ERC20(_token).decimals()))).div(tokenUSD); // 1e(tokenDecimals)
  }

  function setBlocksPerYear(uint256 _blocksPerYear) external onlyOwner {
    blocksPerYear = _blocksPerYear;
  }
  function updateFeedETH(address _asset, address _feed) external onlyOwner {
    priceFeedsETH[_asset] = _feed;
  }
  function updateFeedUSD(address _asset, address _feed) external onlyOwner {
    priceFeedsUSD[_asset] = _feed;
  }
}// Permit pattern copied from BAL https://etherscan.io/address/0xba100000625a3754423978a60c9317c58a424e3d#code
pragma solidity 0.6.12;


contract ERC20Permit is ERC20 {
  string public constant version = "1";
  bytes32 public immutable DOMAIN_SEPARATOR;
  bytes32 public immutable PERMIT_TYPEHASH = 0x6e71edae12b1b97f4d1f60370fef10105fa2faae0126114a169c64845d6126c9;
  mapping(address => uint256) public permitNonces;

  constructor(string memory name, string memory symbol)
    public ERC20(name, symbol) {
    uint256 chainId = getChainId();
    DOMAIN_SEPARATOR = keccak256(
      abi.encode(
        keccak256('EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)'),
        keccak256(bytes(name)),
        keccak256(bytes(version)),
        chainId,
        address(this)
      )
    );
  }

  function getChainId() internal pure returns (uint256) {
    uint256 chainID;
    assembly {
      chainID := chainid()
    }
    return chainID;
  }

  function permit(address owner, address spender, uint256 value, uint256 deadline, uint8 v, bytes32 r, bytes32 s) external {
    require(block.timestamp <= deadline, "ERR_EXPIRED_SIG");
    bytes32 digest = keccak256(
      abi.encodePacked(
        uint16(0x1901),
        DOMAIN_SEPARATOR,
        keccak256(abi.encode(PERMIT_TYPEHASH, owner, spender, value, permitNonces[owner]++, deadline))
      )
    );
    require(owner == _recover(digest, v, r, s), "ERR_INVALID_SIG");
    _approve(owner, spender, value);
  }

  function _recover(bytes32 hash, uint8 v, bytes32 r, bytes32 s) private pure returns (address) {
    if (uint256(s) > 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0) {
        revert("ECDSA: invalid signature 's' value");
    }

    if (v != 27 && v != 28) {
        revert("ECDSA: invalid signature 'v' value");
    }

    address signer = ecrecover(hash, v, r, s);
    require(signer != address(0), "ECDSA: invalid signature");

    return signer;
  }
}pragma solidity 0.6.12;


contract Idle is ERC20Permit {
    constructor() public ERC20Permit("Idle", "IDLE") {
      _mint(msg.sender, 13000000 * 10**18); // 13M
    }


    mapping (address => address) internal _delegates;

    struct Checkpoint {
        uint32 fromBlock;
        uint256 votes;
    }

    mapping (address => mapping (uint32 => Checkpoint)) public checkpoints;

    mapping (address => uint32) public numCheckpoints;

    bytes32 public constant DOMAIN_TYPEHASH = keccak256("EIP712Domain(string name,uint256 chainId,address verifyingContract)");

    bytes32 public constant DELEGATION_TYPEHASH = keccak256("Delegation(address delegatee,uint256 nonce,uint256 expiry)");

    mapping (address => uint) public nonces;

    event DelegateChanged(address indexed delegator, address indexed fromDelegate, address indexed toDelegate);

    event DelegateVotesChanged(address indexed delegate, uint previousBalance, uint newBalance);

    function delegates(address delegator)
        external
        view
        returns (address)
    {
        return _delegates[delegator];
    }

    function delegate(address delegatee) external {
        return _delegate(msg.sender, delegatee);
    }

    function delegateBySig(
        address delegatee,
        uint nonce,
        uint expiry,
        uint8 v,
        bytes32 r,
        bytes32 s
    )
        external
    {
        require(uint256(s) <= 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0, "ECDSA: invalid signature 's' value");
        require(v == 27 || v == 28, "ECDSA: invalid signature 'v' value");

        bytes32 domainSeparator = keccak256(
            abi.encode(
                DOMAIN_TYPEHASH,
                keccak256(bytes(name())),
                getChainId(),
                address(this)
            )
        );

        bytes32 structHash = keccak256(
            abi.encode(
                DELEGATION_TYPEHASH,
                delegatee,
                nonce,
                expiry
            )
        );

        bytes32 digest = keccak256(
            abi.encodePacked(
                "\x19\x01",
                domainSeparator,
                structHash
            )
        );

        address signatory = ecrecover(digest, v, r, s);
        require(signatory != address(0), "IDLE::delegateBySig: invalid signature");
        require(nonce == nonces[signatory]++, "IDLE::delegateBySig: invalid nonce");
        require(now <= expiry, "IDLE::delegateBySig: signature expired");
        return _delegate(signatory, delegatee);
    }

    function getCurrentVotes(address account)
        external
        view
        returns (uint256)
    {
        uint32 nCheckpoints = numCheckpoints[account];
        return nCheckpoints > 0 ? checkpoints[account][nCheckpoints - 1].votes : 0;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
      _transfer(sender, recipient, amount);
      _approve(sender, msg.sender, allowance(sender, msg.sender).sub(amount, "ERC20: transfer amount exceeds allowance"));
      _moveDelegates(_delegates[sender], _delegates[recipient], amount);
      return true;
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
      _transfer(msg.sender, recipient, amount);
      _moveDelegates(_delegates[msg.sender], _delegates[recipient], amount);
      return true;
    }

    function getPriorVotes(address account, uint blockNumber)
        external
        view
        returns (uint256)
    {
        require(blockNumber < block.number, "IDLE::getPriorVotes: not yet determined");

        uint32 nCheckpoints = numCheckpoints[account];
        if (nCheckpoints == 0) {
            return 0;
        }

        if (checkpoints[account][nCheckpoints - 1].fromBlock <= blockNumber) {
            return checkpoints[account][nCheckpoints - 1].votes;
        }

        if (checkpoints[account][0].fromBlock > blockNumber) {
            return 0;
        }

        uint32 lower = 0;
        uint32 upper = nCheckpoints - 1;
        while (upper > lower) {
            uint32 center = upper - (upper - lower) / 2; // ceil, avoiding overflow
            Checkpoint memory cp = checkpoints[account][center];
            if (cp.fromBlock == blockNumber) {
                return cp.votes;
            } else if (cp.fromBlock < blockNumber) {
                lower = center;
            } else {
                upper = center - 1;
            }
        }
        return checkpoints[account][lower].votes;
    }

    function _delegate(address delegator, address delegatee)
        internal
    {
        address currentDelegate = _delegates[delegator];
        uint256 delegatorBalance = balanceOf(delegator); // balance of underlying IDLEs (not scaled);
        _delegates[delegator] = delegatee;

        emit DelegateChanged(delegator, currentDelegate, delegatee);

        _moveDelegates(currentDelegate, delegatee, delegatorBalance);
    }

    function _moveDelegates(address srcRep, address dstRep, uint256 amount) internal {
        if (srcRep != dstRep && amount > 0) {
            if (srcRep != address(0)) {
                uint32 srcRepNum = numCheckpoints[srcRep];
                uint256 srcRepOld = srcRepNum > 0 ? checkpoints[srcRep][srcRepNum - 1].votes : 0;
                uint256 srcRepNew = srcRepOld.sub(amount);
                _writeCheckpoint(srcRep, srcRepNum, srcRepOld, srcRepNew);
            }

            if (dstRep != address(0)) {
                uint32 dstRepNum = numCheckpoints[dstRep];
                uint256 dstRepOld = dstRepNum > 0 ? checkpoints[dstRep][dstRepNum - 1].votes : 0;
                uint256 dstRepNew = dstRepOld.add(amount);
                _writeCheckpoint(dstRep, dstRepNum, dstRepOld, dstRepNew);
            }
        }
    }

    function _writeCheckpoint(
        address delegatee,
        uint32 nCheckpoints,
        uint256 oldVotes,
        uint256 newVotes
    )
        internal
    {
        uint32 blockNumber = safe32(block.number, "IDLE::_writeCheckpoint: block number exceeds 32 bits");

        if (nCheckpoints > 0 && checkpoints[delegatee][nCheckpoints - 1].fromBlock == blockNumber) {
            checkpoints[delegatee][nCheckpoints - 1].votes = newVotes;
        } else {
            checkpoints[delegatee][nCheckpoints] = Checkpoint(blockNumber, newVotes);
            numCheckpoints[delegatee] = nCheckpoints + 1;
        }

        emit DelegateVotesChanged(delegatee, oldVotes, newVotes);
    }

    function safe32(uint n, string memory errorMessage) internal pure returns (uint32) {
        require(n < 2**32, errorMessage);
        return uint32(n);
    }
}pragma solidity 0.6.12;


contract UnitrollerAdminStorage {
    address public admin;

    address public pendingAdmin;

    address public comptrollerImplementation;

    address public pendingComptrollerImplementation;
}

contract IdleControllerStorage is UnitrollerAdminStorage {
  struct Market {
    bool isListed;
    bool isIdled;
  }

  struct IdleMarketState {
    uint256 index;
    uint256 block;
  }

  mapping(address => Market) public markets;

  IdleToken[] public allMarkets;
  uint256 public idleRate;

  mapping(address => uint256) public idleSpeeds;

  mapping(address => IdleMarketState) public idleSupplyState;
  mapping(address => mapping(address => uint256)) public idleSupplierIndex;

  mapping(address => uint256) public idleAccrued;

  PriceOracle public oracle;

  address public idleAddress;

  uint256 public bonusEnd;

  uint256 public bonusMultiplier;
}pragma solidity 0.6.12;


contract IdleController is IdleControllerStorage, Exponential {
  event MarketListed(address idleToken);

  event MarketIdled(address idleToken, bool isIdled);

  event NewIdleRate(uint256 oldIdleRate, uint256 newIdleRate);

  event NewIdleOracle(address oldIdleOracle, address newIdleOracle);

  event IdleSpeedUpdated(address indexed idleToken, uint256 newSpeed);

  event DistributedIdle(address indexed idleToken, address indexed supplier, uint256 idleDelta, uint256 idleSupplyIndex);

  uint256 public constant idleClaimThreshold = 0.001e18;

  uint256 public constant idleInitialIndex = 1e36;

  constructor() public {
    admin = msg.sender;
  }

  function adminOrInitializing() internal view returns (bool) {
      return msg.sender == admin || msg.sender == comptrollerImplementation;
  }

  function refreshIdleSpeeds() public {
      require(msg.sender == tx.origin, "only externally owned accounts may refresh speeds");
      refreshIdleSpeedsInternal();
  }

  function refreshIdleSpeedsInternal() internal {
      IdleToken[] memory allMarkets_ = allMarkets;

      for (uint256 i = 0; i < allMarkets_.length; i++) {
          IdleToken idleToken = allMarkets_[i];
          updateIdleSupplyIndex(address(idleToken));
      }

      Exp memory totalUtility = Exp({mantissa: 0});
      Exp[] memory utilities = new Exp[](allMarkets_.length);
      for (uint256 i = 0; i < allMarkets_.length; i++) {
          IdleToken idleToken = allMarkets_[i];
          if (markets[address(idleToken)].isIdled) {
              uint256 tokenDecimals = ERC20(idleToken.token()).decimals();
              Exp memory tokenPriceNorm = mul_(Exp({mantissa: idleToken.tokenPrice()}), 10**(sub256(18, tokenDecimals))); // norm to 1e18 always
              Exp memory tokenSupply = Exp({mantissa: idleToken.totalSupply()}); // 1e18 always
              Exp memory tvl = mul_(tokenPriceNorm, tokenSupply); // 1e18
              Exp memory assetPrice = Exp({mantissa: oracle.getUnderlyingPrice(address(idleToken))}); // Must return a normalized price to 1e18
              Exp memory tvlUnderlying = mul_(tvl, assetPrice); // 1e18
              Exp memory utility = mul_(tvlUnderlying, Exp({mantissa: idleToken.getAvgAPR()})); // avgAPR 1e18 always

              utilities[i] = utility;
              totalUtility = add_(totalUtility, utility);
          }
      }

      for (uint256 i = 0; i < allMarkets_.length; i++) {
          IdleToken idleToken = allMarkets[i];
          uint256 idleRate_ = block.timestamp < bonusEnd ? mul_(idleRate, bonusMultiplier) : idleRate;
          uint256 newSpeed = totalUtility.mantissa > 0 ? mul_(idleRate_, div_(utilities[i], totalUtility)) : 0;
          idleSpeeds[address(idleToken)] = newSpeed;
          emit IdleSpeedUpdated(address(idleToken), newSpeed);
      }
  }

  function updateIdleSupplyIndex(address idleToken) internal {
      IdleMarketState storage supplyState = idleSupplyState[idleToken];
      uint256 supplySpeed = idleSpeeds[idleToken];
      uint256 blockNumber = block.number;
      uint256 deltaBlocks = sub_(blockNumber, supplyState.block);
      if (deltaBlocks > 0 && supplySpeed > 0) {
          uint256 supplyTokens = IdleToken(idleToken).totalSupply();
          uint256 idleAccrued = mul_(deltaBlocks, supplySpeed);
          Double memory ratio = supplyTokens > 0 ? fraction(idleAccrued, supplyTokens) : Double({mantissa: 0});
          Double memory index = add_(Double({mantissa: supplyState.index}), ratio);
          idleSupplyState[idleToken] = IdleMarketState({
              index: index.mantissa,
              block: blockNumber
          });
      } else if (deltaBlocks > 0) {
          supplyState.block = blockNumber;
      }
  }

  function distributeIdle(address idleToken, bool distributeAll) internal {
      address supplier = idleToken;
      IdleMarketState storage supplyState = idleSupplyState[idleToken];
      Double memory supplyIndex = Double({mantissa: supplyState.index});
      Double memory supplierIndex = Double({mantissa: idleSupplierIndex[idleToken][supplier]});
      idleSupplierIndex[idleToken][supplier] = supplyIndex.mantissa;

      if (supplierIndex.mantissa == 0 && supplyIndex.mantissa > 0) {
          supplierIndex.mantissa = idleInitialIndex;
      }

      Double memory deltaIndex = sub_(supplyIndex, supplierIndex);
      uint256 supplierTokens = IdleToken(idleToken).totalSupply();
      uint256 supplierDelta = mul_(supplierTokens, deltaIndex);
      uint256 supplierAccrued = add_(idleAccrued[supplier], supplierDelta);
      idleAccrued[supplier] = transferIdle(supplier, supplierAccrued, distributeAll ? 0 : idleClaimThreshold);
      emit DistributedIdle(idleToken, supplier, supplierDelta, supplyIndex.mantissa);
  }

  function transferIdle(address user, uint256 userAccrued, uint256 threshold) internal returns (uint256) {
      if (userAccrued >= threshold && userAccrued > 0) {
          Idle idle = Idle(idleAddress);
          uint256 idleRemaining = idle.balanceOf(address(this));
          if (userAccrued <= idleRemaining) {
              idle.transfer(user, userAccrued);
              return 0;
          }
      }
      return userAccrued;
  }

  function claimIdle(address[] memory, IdleToken[] memory idleTokens) public {
      for (uint256 i = 0; i < idleTokens.length; i++) {
          IdleToken idleToken = idleTokens[i];
          require(markets[address(idleToken)].isListed, "market must be listed");
          updateIdleSupplyIndex(address(idleToken));
          distributeIdle(address(idleToken), true);
      }
  }

  function _setIdleRate(uint256 idleRate_) public {
      require(adminOrInitializing(), "only admin can change idle rate");
      uint256 oldRate = idleRate;
      idleRate = idleRate_;
      emit NewIdleRate(oldRate, idleRate_);

      refreshIdleSpeedsInternal();
  }

  function _setPriceOracle(address priceOracle_) public {
      require(msg.sender == admin, "only admin can change price oracle");
      require(priceOracle_ != address(0), "address is 0");
      address oldOracle = address(oracle);
      oracle = PriceOracle(priceOracle_);
      emit NewIdleOracle(oldOracle, priceOracle_);

      refreshIdleSpeedsInternal();
  }

  function _addIdleMarkets(address[] memory idleTokens) public {
      require(adminOrInitializing(), "only admin can change idle rate");
      for (uint256 i = 0; i < idleTokens.length; i++) {
          _addIdleMarketInternal(idleTokens[i]);
      }

      refreshIdleSpeedsInternal();
  }

  function _addIdleMarketInternal(address idleToken) internal {
      Market storage market = markets[idleToken];
      require(market.isListed == true, "idle market is not listed");
      require(market.isIdled == false, "idle market already added");

      market.isIdled = true;
      emit MarketIdled(idleToken, true);

      if (idleSupplyState[idleToken].index == 0 && idleSupplyState[idleToken].block == 0) {
          idleSupplyState[idleToken] = IdleMarketState({
              index: idleInitialIndex,
              block: block.number
          });
      }
  }

  function _dropIdleMarket(address idleToken) public {
      require(msg.sender == admin, "only admin can drop idle market");

      Market storage market = markets[idleToken];
      require(market.isIdled == true, "market is not a idle market");

      market.isIdled = false;
      emit MarketIdled(idleToken, false);

      refreshIdleSpeedsInternal();
  }

  function _supportMarkets(address[] memory idleTokens) public returns (uint256) {
      require(msg.sender == admin, "only admin can change idle markets");
      address idleToken;
      for (uint256 j = 0; j < idleTokens.length; j++) {
          idleToken = idleTokens[j];
          if (markets[address(idleToken)].isListed) {
              return 10;
          }

          markets[idleToken] = Market({isListed: true, isIdled: false});

          _addMarketInternal(idleToken);

          emit MarketListed(idleToken);
      }

      return 0;
  }

  function _addMarketInternal(address idleToken) internal {
      for (uint i = 0; i < allMarkets.length; i ++) {
          require(allMarkets[i] != IdleToken(idleToken), "market already added");
      }
      allMarkets.push(IdleToken(idleToken));
  }

  function _become(address _unitroller) public {
      IUnitroller unitroller = IUnitroller(_unitroller);
      require(msg.sender == unitroller.admin(), "only unitroller admin can change brains");
      require(unitroller._acceptImplementation() == 0, "change not authorized");
  }

  function _setIdleAddress(address _idleAddress) external {
    require(msg.sender == admin, "Not authorized");
    require(idleAddress == address(0), "already initialized");
    require(_idleAddress != address(0), "address is 0");

    idleAddress = _idleAddress;
  }

  function _setBonusDistribution(uint256 _bonusMultiplier) external {
    require(msg.sender == admin, "Not authorized");
    require(bonusEnd == 0, "already initialized");
    bonusEnd = now + 30 days;
    bonusMultiplier = _bonusMultiplier;
  }

  function _withdrawToken(address _token, address _to, uint256 _amount) external {
    require(msg.sender == admin, "Not authorized");
    ERC20(_token).transfer(_to, _amount);
  }

  function _resetMarkets() public returns (uint256) {
      require(msg.sender == admin, "only admin can change idle markets");
      address idleToken;
      for (uint256 j = 0; j < allMarkets.length; j++) {
          idleToken = address(allMarkets[j]);
          markets[idleToken] = Market({isListed: false, isIdled: false});
          idleSupplyState[idleToken] = IdleMarketState({index: 0, block: 0});
          idleSupplierIndex[idleToken][idleToken] = 0;
          idleAccrued[idleToken] = 0;
      }

      delete allMarkets;

      return 0;
  }

  function getAllMarkets() public view returns (IdleToken[] memory) {
      return allMarkets;
  }

  function sub256(uint256 a, uint256 b) internal pure returns (uint) {
      require(b <= a, "subtraction underflow");
      return a - b;
  }
}

interface IUnitroller {
  function admin() external returns (address);
  function _acceptImplementation() external returns (uint256);
}