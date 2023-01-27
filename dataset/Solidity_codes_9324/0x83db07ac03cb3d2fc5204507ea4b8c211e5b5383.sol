
pragma solidity 0.6.11;


interface IERC20 {

    function totalSupply() external view returns (uint);


    function balanceOf(address account) external view returns (uint);


    function transfer(address recipient, uint amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint);


    function approve(address spender, uint amount) external returns (bool);


    function transferFrom(
        address sender,
        address recipient,
        uint amount
    ) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint value);

    event Approval(address indexed owner, address indexed spender, uint value);
}


library SafeMath {

    function tryAdd(uint a, uint b) internal pure returns (bool, uint) {

        uint c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }

    function trySub(uint a, uint b) internal pure returns (bool, uint) {

        if (b > a) return (false, 0);
        return (true, a - b);
    }

    function tryMul(uint a, uint b) internal pure returns (bool, uint) {

        if (a == 0) return (true, 0);
        uint c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }

    function tryDiv(uint a, uint b) internal pure returns (bool, uint) {

        if (b == 0) return (false, 0);
        return (true, a / b);
    }

    function tryMod(uint a, uint b) internal pure returns (bool, uint) {

        if (b == 0) return (false, 0);
        return (true, a % b);
    }

    function add(uint a, uint b) internal pure returns (uint) {

        uint c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint a, uint b) internal pure returns (uint) {

        require(b <= a, "SafeMath: subtraction overflow");
        return a - b;
    }

    function mul(uint a, uint b) internal pure returns (uint) {

        if (a == 0) return 0;
        uint c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function div(uint a, uint b) internal pure returns (uint) {

        require(b > 0, "SafeMath: division by zero");
        return a / b;
    }

    function mod(uint a, uint b) internal pure returns (uint) {

        require(b > 0, "SafeMath: modulo by zero");
        return a % b;
    }

    function sub(
        uint a,
        uint b,
        string memory errorMessage
    ) internal pure returns (uint) {

        require(b <= a, errorMessage);
        return a - b;
    }

    function div(
        uint a,
        uint b,
        string memory errorMessage
    ) internal pure returns (uint) {

        require(b > 0, errorMessage);
        return a / b;
    }

    function mod(
        uint a,
        uint b,
        string memory errorMessage
    ) internal pure returns (uint) {

        require(b > 0, errorMessage);
        return a % b;
    }
}


library Address {

    function isContract(address account) internal view returns (bool) {


        uint size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    function sendValue(address payable recipient, uint amount) internal {

        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data)
        internal
        returns (bytes memory)
    {

        return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {

        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint value
    ) internal returns (bytes memory) {

        return
            functionCallWithValue(
                target,
                data,
                value,
                "Address: low-level call with value failed"
            );
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint value,
        string memory errorMessage
    ) internal returns (bytes memory) {

        require(
            address(this).balance >= value,
            "Address: insufficient balance for call"
        );
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data)
        internal
        view
        returns (bytes memory)
    {

        return
            functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {

        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionDelegateCall(address target, bytes memory data)
        internal
        returns (bytes memory)
    {

        return
            functionDelegateCall(
                target,
                data,
                "Address: low-level delegate call failed"
            );
    }

    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {

        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) private pure returns (bytes memory) {

        if (success) {
            return returndata;
        } else {
            if (returndata.length > 0) {

                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}


library SafeERC20 {

    using SafeMath for uint;
    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint value
    ) internal {

        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.transfer.selector, to, value)
        );
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint value
    ) internal {

        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.transferFrom.selector, from, to, value)
        );
    }

    function safeApprove(
        IERC20 token,
        address spender,
        uint value
    ) internal {

        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.approve.selector, spender, value)
        );
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint value
    ) internal {

        uint newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.approve.selector, spender, newAllowance)
        );
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint value
    ) internal {

        uint newAllowance =
            token.allowance(address(this), spender).sub(
                value,
                "SafeERC20: decreased allowance below zero"
            );
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.approve.selector, spender, newAllowance)
        );
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {


        bytes memory returndata =
            address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            require(
                abi.decode(returndata, (bool)),
                "SafeERC20: ERC20 operation did not succeed"
            );
        }
    }
}



interface IStrategy {

    function admin() external view returns (address);


    function controller() external view returns (address);


    function vault() external view returns (address);


    function underlying() external view returns (address);


    function totalDebt() external view returns (uint);


    function performanceFee() external view returns (uint);


    function slippage() external view returns (uint);


    function delta() external view returns (uint);


    function forceExit() external view returns (bool);


    function setAdmin(address _admin) external;


    function setController(address _controller) external;


    function setPerformanceFee(uint _fee) external;


    function setSlippage(uint _slippage) external;


    function setDelta(uint _delta) external;


    function setForceExit(bool _forceExit) external;


    function totalAssets() external view returns (uint);


    function withdraw(uint _amount) external;


    function withdrawAll() external;


    function harvest() external;


    function skim() external;


    function exit() external;


    function sweep(address _token) external;

}


interface IStrategyERC20 is IStrategy {

    function deposit(uint _amount) external;

}


interface IController {

    function ADMIN_ROLE() external view returns (bytes32);


    function HARVESTER_ROLE() external view returns (bytes32);


    function admin() external view returns (address);


    function treasury() external view returns (address);


    function setAdmin(address _admin) external;


    function setTreasury(address _treasury) external;


    function grantRole(bytes32 _role, address _addr) external;


    function revokeRole(bytes32 _role, address _addr) external;


    function setStrategy(
        address _vault,
        address _strategy,
        uint _min
    ) external;


    function invest(address _vault) external;


    function harvest(address _strategy) external;


    function skim(address _strategy) external;


    function withdraw(
        address _strategy,
        uint _amount,
        uint _min
    ) external;


    function withdrawAll(address _strategy, uint _min) external;


    function exit(address _strategy, uint _min) external;

}




abstract contract StrategyERC20 is IStrategyERC20 {
    using SafeERC20 for IERC20;
    using SafeMath for uint;

    address public override admin;
    address public override controller;
    address public immutable override vault;
    address public immutable override underlying;

    uint public override totalDebt;

    uint public override performanceFee = 500;
    uint private constant PERFORMANCE_FEE_CAP = 2000; // upper limit to performance fee
    uint internal constant PERFORMANCE_FEE_MAX = 10000;

    uint public override slippage = 100;
    uint internal constant SLIPPAGE_MAX = 10000;

    uint public override delta = 10050;
    uint private constant DELTA_MIN = 10000;

    bool public override forceExit;

    constructor(
        address _controller,
        address _vault,
        address _underlying
    ) public {
        require(_controller != address(0), "controller = zero address");
        require(_vault != address(0), "vault = zero address");
        require(_underlying != address(0), "underlying = zero address");

        admin = msg.sender;
        controller = _controller;
        vault = _vault;
        underlying = _underlying;
    }

    modifier onlyAdmin() {
        require(msg.sender == admin, "!admin");
        _;
    }

    modifier onlyAuthorized() {
        require(
            msg.sender == admin || msg.sender == controller || msg.sender == vault,
            "!authorized"
        );
        _;
    }

    function setAdmin(address _admin) external override onlyAdmin {
        require(_admin != address(0), "admin = zero address");
        admin = _admin;
    }

    function setController(address _controller) external override onlyAdmin {
        require(_controller != address(0), "controller = zero address");
        controller = _controller;
    }

    function setPerformanceFee(uint _fee) external override onlyAdmin {
        require(_fee <= PERFORMANCE_FEE_CAP, "performance fee > cap");
        performanceFee = _fee;
    }

    function setSlippage(uint _slippage) external override onlyAdmin {
        require(_slippage <= SLIPPAGE_MAX, "slippage > max");
        slippage = _slippage;
    }

    function setDelta(uint _delta) external override onlyAdmin {
        require(_delta >= DELTA_MIN, "delta < min");
        delta = _delta;
    }

    function setForceExit(bool _forceExit) external override onlyAdmin {
        forceExit = _forceExit;
    }

    function _increaseDebt(uint _underlyingAmount) private {
        uint balBefore = IERC20(underlying).balanceOf(address(this));
        IERC20(underlying).safeTransferFrom(vault, address(this), _underlyingAmount);
        uint balAfter = IERC20(underlying).balanceOf(address(this));

        totalDebt = totalDebt.add(balAfter.sub(balBefore));
    }

    function _decreaseDebt(uint _underlyingAmount) private {
        uint balBefore = IERC20(underlying).balanceOf(address(this));
        IERC20(underlying).safeTransfer(vault, _underlyingAmount);
        uint balAfter = IERC20(underlying).balanceOf(address(this));

        uint diff = balBefore.sub(balAfter);
        if (diff > totalDebt) {
            totalDebt = 0;
        } else {
            totalDebt -= diff;
        }
    }

    function _totalAssets() internal view virtual returns (uint);

    function totalAssets() external view override returns (uint) {
        return _totalAssets();
    }

    function _deposit() internal virtual;

    function deposit(uint _underlyingAmount) external override onlyAuthorized {
        require(_underlyingAmount > 0, "deposit = 0");

        _increaseDebt(_underlyingAmount);
        _deposit();
    }

    function _getTotalShares() internal view virtual returns (uint);

    function _getShares(uint _underlyingAmount, uint _totalUnderlying)
        internal
        view
        returns (uint)
    {
        if (_totalUnderlying > 0) {
            uint totalShares = _getTotalShares();
            return _underlyingAmount.mul(totalShares) / _totalUnderlying;
        }
        return 0;
    }

    function _withdraw(uint _shares) internal virtual;

    function withdraw(uint _underlyingAmount) external override onlyAuthorized {
        require(_underlyingAmount > 0, "withdraw = 0");
        uint totalUnderlying = _totalAssets();
        require(_underlyingAmount <= totalUnderlying, "withdraw > total");

        uint shares = _getShares(_underlyingAmount, totalUnderlying);
        if (shares > 0) {
            _withdraw(shares);
        }

        uint underlyingBal = IERC20(underlying).balanceOf(address(this));
        if (underlyingBal > 0) {
            _decreaseDebt(underlyingBal);
        }
    }

    function _withdrawAll() internal {
        uint totalShares = _getTotalShares();
        if (totalShares > 0) {
            _withdraw(totalShares);
        }

        uint underlyingBal = IERC20(underlying).balanceOf(address(this));
        if (underlyingBal > 0) {
            _decreaseDebt(underlyingBal);
            totalDebt = 0;
        }
    }

    function withdrawAll() external override onlyAuthorized {
        _withdrawAll();
    }

    function harvest() external virtual override;

    function skim() external override onlyAuthorized {
        uint totalUnderlying = _totalAssets();
        require(totalUnderlying > totalDebt, "total underlying < debt");

        uint profit = totalUnderlying - totalDebt;

        uint max = totalDebt.mul(delta) / DELTA_MIN;
        if (totalUnderlying <= max) {

            totalDebt = totalDebt.add(profit);
        } else {
            uint shares = _getShares(profit, totalUnderlying);
            if (shares > 0) {
                uint balBefore = IERC20(underlying).balanceOf(address(this));
                _withdraw(shares);
                uint balAfter = IERC20(underlying).balanceOf(address(this));

                uint diff = balAfter.sub(balBefore);
                if (diff > 0) {
                    IERC20(underlying).safeTransfer(vault, diff);
                }
            }
        }
    }

    function exit() external virtual override;

    function sweep(address) external virtual override;
}


interface Uniswap {

    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);


    function swapExactTokensForETH(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);

}


interface StableSwapSBTC {

    function add_liquidity(uint[3] memory amounts, uint min) external;


    function remove_liquidity_one_coin(
        uint amount,
        int128 index,
        uint min
    ) external;


    function get_virtual_price() external view returns (uint);


    function balances(int128 index) external view returns (uint);

}


interface StableSwapOBTC {

    function get_virtual_price() external view returns (uint);


    function balances(uint index) external view returns (uint);

}


interface DepositOBTC {

    function add_liquidity(uint[4] memory amounts, uint min) external returns (uint);


    function remove_liquidity_one_coin(
        uint amount,
        int128 index,
        uint min
    ) external returns (uint);

}


interface LiquidityGaugeV2 {

    function deposit(uint) external;


    function balanceOf(address) external view returns (uint);


    function withdraw(uint) external;


    function claim_rewards() external;

}


interface Minter {

    function mint(address) external;

}


contract StrategyObtc is StrategyERC20 {

    address private constant UNISWAP = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
    address private constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    address private constant SUSHI = 0xd9e1cE17f2641f24aE83637ab66a2cca9C378B9F;

    address internal constant OBTC = 0x8064d9Ae6cDf087b1bcd5BDf3531bD5d8C537a68;
    address internal constant REN_BTC = 0xEB4C2781e4ebA804CE9a9803C67d0893436bB27D;
    address internal constant WBTC = 0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599;
    address internal constant SBTC = 0xfE18be6b3Bd88A2D2A7f928d00292E7a9963CfC6;

    uint internal underlyingIndex;
    uint[4] private PRECISION_DIV = [1, 1e10, 1e10, 1];

    address private constant LP = 0x2fE94ea3d5d4a175184081439753DE15AeF9d614;
    address private constant BASE_POOL = 0x7fC77b5c7614E1533320Ea6DDc2Eb61fa00A9714;
    address private constant SWAP = 0xd81dA8D904b52208541Bade1bD6595D8a251F8dd;
    address private constant DEPOSIT = 0xd5BCf53e2C81e1991570f33Fa881c49EEa570C8D;
    address private constant GAUGE = 0x11137B10C210b579405c21A07489e28F3c040AB1;
    address private constant MINTER = 0xd061D61a4d941c39E5453435B6345Dc261C2fcE0;
    address private constant CRV = 0xD533a949740bb3306d119CC777fa900bA034cd52;

    address private constant BOR = 0x3c9d6c1C73b31c837832c72E04D3152f051fc1A9;
    bool public shouldSellBor = true;

    bool public disableSbtc = true;
    address[2] private ROUTERS = [UNISWAP, SUSHI];
    uint[4] public wethBtcRouter = [1, 0, 0, 0];

    constructor(
        address _controller,
        address _vault,
        address _underlying
    ) public StrategyERC20(_controller, _vault, _underlying) {
        IERC20(CRV).safeApprove(UNISWAP, uint(-1));
        IERC20(CRV).safeApprove(SUSHI, uint(-1));

        IERC20(WETH).safeApprove(UNISWAP, uint(-1));
        IERC20(WETH).safeApprove(SUSHI, uint(-1));

        IERC20(BOR).safeApprove(SUSHI, uint(-1));
    }

    function setShouldSellBor(bool _shouldSellBor) external onlyAdmin {

        shouldSellBor = _shouldSellBor;
    }

    function setDisableSbtc(bool _disable) external onlyAdmin {

        disableSbtc = _disable;
    }

    function setWethBtcRouter(uint[4] calldata _wethBtcRouter) external onlyAdmin {

        for (uint i = 0; i < _wethBtcRouter.length; i++) {
            require(_wethBtcRouter[i] <= 1, "router index > 1");
            wethBtcRouter[i] = _wethBtcRouter[i];
        }
    }

    function _totalAssets() internal view override returns (uint) {

        uint lpBal = LiquidityGaugeV2(GAUGE).balanceOf(address(this));
        uint pricePerShare = StableSwapOBTC(SWAP).get_virtual_price();

        return lpBal.mul(pricePerShare).div(PRECISION_DIV[underlyingIndex]) / 1e18;
    }

    function _depositIntoCurve(address _token, uint _index) private {

        uint bal = IERC20(_token).balanceOf(address(this));
        if (bal > 0) {
            IERC20(_token).safeApprove(DEPOSIT, 0);
            IERC20(_token).safeApprove(DEPOSIT, bal);

            uint[4] memory amounts;
            amounts[_index] = bal;

            uint pricePerShare = StableSwapOBTC(SWAP).get_virtual_price();
            uint shares = bal.mul(PRECISION_DIV[_index]).mul(1e18).div(pricePerShare);
            uint min = shares.mul(SLIPPAGE_MAX - slippage) / SLIPPAGE_MAX;

            DepositOBTC(DEPOSIT).add_liquidity(amounts, min);
        }

        uint lpBal = IERC20(LP).balanceOf(address(this));
        if (lpBal > 0) {
            IERC20(LP).safeApprove(GAUGE, 0);
            IERC20(LP).safeApprove(GAUGE, lpBal);
            LiquidityGaugeV2(GAUGE).deposit(lpBal);
        }
    }

    function _deposit() internal override {

        _depositIntoCurve(underlying, underlyingIndex);
    }

    function _getTotalShares() internal view override returns (uint) {

        return LiquidityGaugeV2(GAUGE).balanceOf(address(this));
    }

    function _withdraw(uint _lpAmount) internal override {

        LiquidityGaugeV2(GAUGE).withdraw(_lpAmount);

        uint lpBal = IERC20(LP).balanceOf(address(this));

        IERC20(LP).safeApprove(DEPOSIT, 0);
        IERC20(LP).safeApprove(DEPOSIT, lpBal);

        uint pricePerShare = StableSwapOBTC(SWAP).get_virtual_price();
        uint underlyingAmount =
            lpBal.mul(pricePerShare).div(PRECISION_DIV[underlyingIndex]) / 1e18;
        uint min = underlyingAmount.mul(SLIPPAGE_MAX - slippage) / SLIPPAGE_MAX;
        DepositOBTC(DEPOSIT).remove_liquidity_one_coin(
            lpBal,
            int128(underlyingIndex),
            min
        );
    }

    function _getMostPremiumToken() private view returns (address, uint) {

        uint[2] memory balances;
        balances[0] = StableSwapOBTC(SWAP).balances(0).mul(1e10); // OBTC
        balances[1] = StableSwapOBTC(SWAP).balances(1); // SBTC pool

        if (balances[0] <= balances[1]) {
            return (OBTC, 0);
        } else {
            uint[3] memory baseBalances;
            baseBalances[0] = StableSwapSBTC(BASE_POOL).balances(0).mul(1e10); // REN_BTC
            baseBalances[1] = StableSwapSBTC(BASE_POOL).balances(1).mul(1e10); // WBTC
            baseBalances[2] = StableSwapSBTC(BASE_POOL).balances(2); // SBTC

            uint minIndex = 0;
            for (uint i = 1; i < baseBalances.length; i++) {
                if (baseBalances[i] <= baseBalances[minIndex]) {
                    minIndex = i;
                }
            }


            if (minIndex == 0) {
                return (REN_BTC, 1);
            }
            if (minIndex == 1) {
                return (WBTC, 2);
            }
            if (!disableSbtc) {
                return (SBTC, 3);
            }
            return (WBTC, 2);
        }
    }

    function _swap(
        address _router,
        address _from,
        address _to,
        uint _amount
    ) private {

        address[] memory path;

        if (_from == WETH || _to == WETH) {
            path = new address[](2);
            path[0] = _from;
            path[1] = _to;
        } else {
            path = new address[](3);
            path[0] = _from;
            path[1] = WETH;
            path[2] = _to;
        }

        Uniswap(_router).swapExactTokensForTokens(
            _amount,
            1,
            path,
            address(this),
            block.timestamp
        );
    }

    function _claimRewards(address _token, uint _tokenIndex) private {

        Minter(MINTER).mint(GAUGE);

        uint routerIndex = wethBtcRouter[_tokenIndex];
        address router = ROUTERS[routerIndex];

        if (shouldSellBor) {
            LiquidityGaugeV2(GAUGE).claim_rewards();

            uint borBal = IERC20(BOR).balanceOf(address(this));
            if (borBal > 0) {
                _swap(SUSHI, BOR, WETH, borBal);

                uint wethBal = IERC20(WETH).balanceOf(address(this));
                if (wethBal > 0) {
                    _swap(router, WETH, _token, wethBal);
                }
            }
        }

        uint crvBal = IERC20(CRV).balanceOf(address(this));
        if (crvBal > 0) {
            _swap(router, CRV, _token, crvBal);
        }
    }

    function harvest() external override onlyAuthorized {

        (address token, uint index) = _getMostPremiumToken();

        _claimRewards(token, index);

        uint bal = IERC20(token).balanceOf(address(this));
        if (bal > 0) {
            uint fee = bal.mul(performanceFee) / PERFORMANCE_FEE_MAX;
            if (fee > 0) {
                address treasury = IController(controller).treasury();
                require(treasury != address(0), "treasury = zero address");

                IERC20(token).safeTransfer(treasury, fee);
            }

            _depositIntoCurve(token, index);
        }
    }

    function exit() external override onlyAuthorized {

        if (forceExit) {
            return;
        }
        _claimRewards(underlying, underlyingIndex);
        _withdrawAll();
    }

    function sweep(address _token) external override onlyAdmin {

        require(_token != underlying, "protected token");
        require(_token != GAUGE, "protected token");
        IERC20(_token).safeTransfer(admin, IERC20(_token).balanceOf(address(this)));
    }
}


contract StrategyObtcWbtc is StrategyObtc {

    constructor(address _controller, address _vault)
        public
        StrategyObtc(_controller, _vault, WBTC)
    {
        underlyingIndex = 2;
    }
}