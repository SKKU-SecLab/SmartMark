

pragma solidity 0.6.12;

contract TokenBarAdminStorage {

    address public admin;
    address public governance;

    address public implementation;
}

contract xSHDStorage {

    string public name = "ShardingBar";
    string public symbol = "xSHD";
    uint8 public constant decimals = 18;
    uint256 public totalSupply;
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;
}

contract ITokenBarStorge is TokenBarAdminStorage {

    uint256 public lockPeriod = 604800;
    address public SHDToken;
    mapping(address => mapping(address => address)) public routerMap;
    address public marketRegulator;
    address public weth;
    mapping(address => uint256) public lockDeadline;
}




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
}




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
}


pragma solidity 0.6.12;



contract xSHDToken is xSHDStorage {

    using SafeMath for uint256;

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
    event Transfer(address indexed from, address indexed to, uint256 value);

    function _mint(address to, uint256 value) internal {

        totalSupply = totalSupply.add(value);
        balanceOf[to] = balanceOf[to].add(value);
        emit Transfer(address(0), to, value);
    }

    function _burn(address from, uint256 value) internal {

        balanceOf[from] = balanceOf[from].sub(value);
        totalSupply = totalSupply.sub(value);
        emit Transfer(from, address(0), value);
    }

    function _approve(
        address owner,
        address spender,
        uint256 value
    ) private {

        allowance[owner][spender] = value;
        emit Approval(owner, spender, value);
    }

    function _transfer(
        address from,
        address to,
        uint256 value
    ) private {

        balanceOf[from] = balanceOf[from].sub(value);
        balanceOf[to] = balanceOf[to].add(value);
        emit Transfer(from, to, value);
    }

    function approve(address spender, uint256 value) external returns (bool) {

        _approve(msg.sender, spender, value);
        return true;
    }

    function transfer(address to, uint256 value) external returns (bool) {

        _transfer(msg.sender, to, value);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool) {

        if (allowance[from][msg.sender] != uint256(-1)) {
            allowance[from][msg.sender] = allowance[from][msg.sender].sub(
                value
            );
        }
        _transfer(from, to, value);
        return true;
    }
}


pragma solidity >=0.6.2;

interface IUniswapV2Router01 {

    function factory() external pure returns (address);


    function WETH() external pure returns (address);


    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    )
        external
        returns (
            uint256 amountA,
            uint256 amountB,
            uint256 liquidity
        );


    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB);


    function quote(
        uint256 amountA,
        uint256 reserveA,
        uint256 reserveB
    ) external pure returns (uint256 amountB);


    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);


    function getAmountsOut(uint256 amountIn, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);

}


pragma solidity >=0.6.2;


interface IUniswapV2Router02 is IUniswapV2Router01 {}



pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

interface IMarketRegulator {

    function IsInWhiteList(address wantToken)
        external
        view
        returns (bool inTheList);


    function IsInBlackList(uint256 _shardPoolId)
        external
        view
        returns (bool inTheList);


    function getWantTokenWhiteList()
        external
        view
        returns (whiteListToken[] memory _wantTokenWhiteList);


    struct whiteListToken {
        address token;
        string symbol;
    }
}


pragma solidity 0.6.12;







contract TokenBarDelegate is ITokenBarStorge, xSHDToken {

    using SafeMath for uint256;

    event Deposit(address user, uint256 SHDAmountIn, uint256 xSHDAmountOut);

    event Withdraw(
        address user,
        uint256 xSHDAmountIn,
        uint256 SHDAmountOut,
        bool isUpdateSHDInBar
    );

    constructor() public {}

    function initialize(
        address _SHDToken,
        address _marketRegulator,
        address _weth
    ) public {

        require(weth == address(0), "already initialize");
        require(msg.sender == admin, "unauthorized");
        SHDToken = _SHDToken;
        marketRegulator = _marketRegulator;
        weth = _weth;
    }

    function deposit(uint256 _SHDAmountIn) public {

        require(_SHDAmountIn > 0, "Insufficient SHDToken");

        uint256 totalSHD = IERC20(SHDToken).balanceOf(address(this));
        uint256 totalShares = totalSupply;

        lockDeadline[msg.sender] = now.add(lockPeriod);

        uint256 xSHDAmountOut;
        if (totalShares == 0 || totalSHD == 0) {
            xSHDAmountOut = _SHDAmountIn;
            _mint(msg.sender, _SHDAmountIn);
        } else {
            xSHDAmountOut = _SHDAmountIn.mul(totalShares).div(totalSHD);
            _mint(msg.sender, xSHDAmountOut);
        }
        IERC20(SHDToken).transferFrom(msg.sender, address(this), _SHDAmountIn);
        emit Deposit(msg.sender, _SHDAmountIn, xSHDAmountOut);
    }

    function withdraw(uint256 _xSHDAmountIn, bool _isUpdateSHDInBar) public {

        require(_xSHDAmountIn > 0, "Insufficient xSHDToken");
        if (_isUpdateSHDInBar) {
            swapAllForSHD();
        }
        uint256 timeForWithdraw = lockDeadline[msg.sender];
        require(now > timeForWithdraw, "still locked");
        uint256 totalShares = totalSupply;
        uint256 SHDBalance = IERC20(SHDToken).balanceOf(address(this));
        uint256 SHDAmountOut = _xSHDAmountIn.mul(SHDBalance).div(totalShares);
        _burn(msg.sender, _xSHDAmountIn);
        IERC20(SHDToken).transfer(msg.sender, SHDAmountOut);
        emit Withdraw(
            msg.sender,
            _xSHDAmountIn,
            SHDAmountOut,
            _isUpdateSHDInBar
        );
    }

    function swapAllForSHD() public {

        IMarketRegulator.whiteListToken[] memory wantTokenWhiteList =
            IMarketRegulator(marketRegulator).getWantTokenWhiteList();
        for (uint256 i = 0; i < wantTokenWhiteList.length; i++) {
            address wantToken = wantTokenWhiteList[i].token;
            if (wantToken != weth) {
                swap(wantToken, weth);
            }
        }
        swap(weth, SHDToken);
    }

    function swapExactTokenForSHD(address wantToken) public {

        if (wantToken != weth) {
            swap(wantToken, weth);
        }
        swap(weth, SHDToken);
    }

    function swap(address from, address to) internal {

        uint256 balance = IERC20(from).balanceOf(address(this));
        if (balance > 0) {
            address router = routerMap[from][to];
            require(router != address(0), "router hasn't been set");
            address[] memory path = new address[](2);
            path[0] = from;
            path[1] = to;
            IERC20(from).approve(router, balance);
            IUniswapV2Router02(router).swapExactTokensForTokens(
                balance,
                0,
                path,
                address(this),
                now.add(60)
            );
        }
    }

    function setRouter(
        address fromToken,
        address ToToken,
        address router
    ) public {

        require(msg.sender == admin, "unauthorized");
        routerMap[fromToken][ToToken] = router;
    }

    function setMarketRegulator(address _marketRegulator) public {

        require(msg.sender == admin, "unauthorized");
        marketRegulator = _marketRegulator;
    }

    function setLockPeriod(uint256 _lockPeriod) public {

        require(msg.sender == governance, "unauthorized");
        lockPeriod = _lockPeriod;
    }

    function getxSHDAmountOut(uint256 SHDAmountIn)
        public
        view
        returns (uint256 xSHDAmountOut)
    {

        uint256 totalSHD = IERC20(SHDToken).balanceOf(address(this));
        uint256 totalShares = totalSupply;
        if (totalShares == 0 || totalSHD == 0) {
            xSHDAmountOut = SHDAmountIn;
        } else {
            xSHDAmountOut = SHDAmountIn.mul(totalShares).div(totalSHD);
        }
    }

    function getSHDAmountOut(uint256 xSHDAmountIn)
        public
        view
        returns (uint256 SHDAmountOut)
    {

        uint256 totalShares = totalSupply;
        uint256 SHDBalance = IERC20(SHDToken).balanceOf(address(this));
        SHDAmountOut = xSHDAmountIn.mul(SHDBalance).div(totalShares);
    }

    function getSHDAmountOutAfterSwap(uint256 xSHDAmountIn)
        public
        view
        returns (uint256 SHDAmountOut)
    {

        IMarketRegulator.whiteListToken[] memory wantTokenWhiteList =
            IMarketRegulator(marketRegulator).getWantTokenWhiteList();

        uint256 balanceOfWeth = IERC20(weth).balanceOf(address(this));

        for (uint256 i = 0; i < wantTokenWhiteList.length; i++) {
            address wantToken = wantTokenWhiteList[i].token;
            if (wantToken != weth) {
                uint256 balance = IERC20(wantToken).balanceOf(address(this));
                uint256 wethAmountOut = getSwapAmount(wantToken, weth, balance);
                balanceOfWeth = balanceOfWeth.add(wethAmountOut);
            }
        }

        uint256 SHDBalance = IERC20(SHDToken).balanceOf(address(this));
        uint256 SHDTokenAmountOut =
            getSwapAmount(weth, SHDToken, balanceOfWeth);
        SHDBalance = SHDBalance.add(SHDTokenAmountOut);

        uint256 totalShares = totalSupply;
        SHDAmountOut = xSHDAmountIn.mul(SHDBalance).div(totalShares);
    }

    function getSwapAmount(
        address from,
        address to,
        uint256 fromAmountIn
    ) internal view returns (uint256 amountOut) {

        if (fromAmountIn > 0) {
            address router = routerMap[from][to];
            require(router != address(0), "router hasn't been set");
            address[] memory path = new address[](2);
            path[0] = from;
            path[1] = to;
            uint256[] memory amounts =
                IUniswapV2Router02(router).getAmountsOut(fromAmountIn, path);
            amountOut = amounts[1];
        }
    }
}