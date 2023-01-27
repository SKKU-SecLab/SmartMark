pragma solidity >=0.7.0;

interface INFTGemFeeManager {


    event DefaultFeeDivisorChanged(address indexed operator, uint256 oldValue, uint256 value);
    event FeeDivisorChanged(address indexed operator, address indexed token, uint256 oldValue, uint256 value);
    event ETHReceived(address indexed manager, address sender, uint256 value);
    event LiquidityChanged(address indexed manager, uint256 oldValue, uint256 value);

    function liquidity(address token) external view returns (uint256);


    function defaultLiquidity() external view returns (uint256);


    function setDefaultLiquidity(uint256 _liquidityMult) external returns (uint256);


    function feeDivisor(address token) external view returns (uint256);


    function defaultFeeDivisor() external view returns (uint256);


    function setFeeDivisor(address token, uint256 _feeDivisor) external returns (uint256);


    function setDefaultFeeDivisor(uint256 _feeDivisor) external returns (uint256);


    function ethBalanceOf() external view returns (uint256);


    function balanceOF(address token) external view returns (uint256);


    function transferEth(address payable recipient, uint256 amount) external;


    function transferToken(
        address token,
        address recipient,
        uint256 amount
    ) external;


}// MIT

pragma solidity >=0.7.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}// MIT
pragma solidity >=0.7.0;


contract NFTGemFeeManager is INFTGemFeeManager {

    address private operator;

    uint256 private constant MINIMUM_LIQUIDITY = 100;
    uint256 private constant FEE_DIVISOR = 1000;

    mapping(address => uint256) private feeDivisors;
    uint256 private _defaultFeeDivisor;

    mapping(address => uint256) private _liquidity;
    uint256 private _defaultLiquidity;

    constructor() {
        _defaultFeeDivisor = FEE_DIVISOR;
        _defaultLiquidity = MINIMUM_LIQUIDITY;
    }

    receive() external payable {
    }

    function setOperator(address _operator) external {

        require(operator == address(0), "IMMUTABLE");
        operator = _operator;
    }

    function liquidity(address token) external view override returns (uint256) {

        return _liquidity[token] != 0 ? _liquidity[token] : _defaultLiquidity;
    }

    function defaultLiquidity() external view override returns (uint256 multiplier) {

        return _defaultLiquidity;
    }

    function setDefaultLiquidity(uint256 _liquidityMult) external override returns (uint256 oldLiquidity) {

        require(operator == msg.sender, "UNAUTHORIZED");
        require(_liquidityMult != 0, "INVALID");
        oldLiquidity = _defaultLiquidity;
        _defaultLiquidity = _liquidityMult;
        emit LiquidityChanged(operator, oldLiquidity, _defaultLiquidity);
    }

    function feeDivisor(address token) external view override returns (uint256 divisor) {

        divisor = feeDivisors[token];
        divisor = divisor == 0 ? FEE_DIVISOR : divisor;
    }

    function defaultFeeDivisor() external view override returns (uint256 multiplier) {

        return _defaultFeeDivisor;
    }

    function setDefaultFeeDivisor(uint256 _feeDivisor) external override returns (uint256 oldDivisor) {

        require(operator == msg.sender, "UNAUTHORIZED");
        require(_feeDivisor != 0, "DIVISIONBYZERO");
        oldDivisor = _defaultFeeDivisor;
        _defaultFeeDivisor = _feeDivisor;
        emit DefaultFeeDivisorChanged(operator, oldDivisor, _defaultFeeDivisor);
    }

    function setFeeDivisor(address token, uint256 _feeDivisor) external override returns (uint256 oldDivisor) {

        require(operator == msg.sender, "UNAUTHORIZED");
        require(_feeDivisor != 0, "DIVISIONBYZERO");
        oldDivisor = feeDivisors[token];
        feeDivisors[token] = _feeDivisor;
        emit FeeDivisorChanged(operator, token, oldDivisor, _feeDivisor);
    }

    function ethBalanceOf() external view override returns (uint256) {

        return address(this).balance;
    }

    function balanceOF(address token) external view override returns (uint256) {

        return IERC20(token).balanceOf(address(this));
    }

    function transferEth(address payable recipient, uint256 amount) external override {

        require(operator == msg.sender, "UNAUTHORIZED");
        require(address(this).balance >= amount, "INSUFFICIENT_BALANCE");
        recipient.transfer(amount);
    }

    function transferToken(
        address token,
        address recipient,
        uint256 amount
    ) external override {

        require(operator == msg.sender, "UNAUTHORIZED");
        require(IERC20(token).balanceOf(address(this)) >= amount, "INSUFFICIENT_BALANCE");
        IERC20(token).transfer(recipient, amount);
    }
}