
pragma solidity ^0.8.0;

interface IERC20Upgradeable {

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

pragma solidity ^0.8.0;

library AddressUpgradeable {

    function isContract(address account) internal view returns (bool) {


        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {

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
        uint256 value
    ) internal returns (bytes memory) {

        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {

        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {

        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {

        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {

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
}// MIT

pragma solidity ^0.8.0;


library SafeERC20Upgradeable {

    using AddressUpgradeable for address;

    function safeTransfer(
        IERC20Upgradeable token,
        address to,
        uint256 value
    ) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20Upgradeable token,
        address from,
        address to,
        uint256 value
    ) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(
        IERC20Upgradeable token,
        address spender,
        uint256 value
    ) internal {

        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20Upgradeable token,
        address spender,
        uint256 value
    ) internal {

        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20Upgradeable token,
        address spender,
        uint256 value
    ) internal {

        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    function _callOptionalReturn(IERC20Upgradeable token, bytes memory data) private {


        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}// MIT

pragma solidity ^0.8.0;

abstract contract Initializable {
    bool private _initialized;

    bool private _initializing;

    modifier initializer() {
        require(_initializing || !_initialized, "Initializable: contract is already initialized");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }
}// MIT

pragma solidity ^0.8.0;

abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal initializer {
        __Context_init_unchained();
    }

    function __Context_init_unchained() internal initializer {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
    uint256[50] private __gap;
}// MIT

pragma solidity ^0.8.0;


abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function __Ownable_init() internal initializer {
        __Context_init_unchained();
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal initializer {
        _setOwner(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
    uint256[49] private __gap;
}// MIT
pragma solidity 0.8.7;


interface IRouter {

    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);


    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);


    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);


    function getAmountsOut(uint amountIn, address[] memory path) external view returns (uint[] memory amounts);

}

interface IPair is IERC20Upgradeable {

    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);

}

interface IUniV3Router {

    struct ExactInputSingleParams {
        address tokenIn;
        address tokenOut;
        uint24 fee;
        address recipient;
        uint deadline;
        uint amountIn;
        uint amountOutMinimum;
        uint160 sqrtPriceLimitX96;
    }
    function exactInputSingle(
        ExactInputSingleParams calldata params
    ) external returns (uint amountOut);


    struct IncreaseLiquidityParams {
        uint256 tokenId;
        uint256 amount0Desired;
        uint256 amount1Desired;
        uint256 amount0Min;
        uint256 amount1Min;
        uint256 deadline;
    }
    function increaseLiquidity(
       IncreaseLiquidityParams calldata params
    ) external returns (uint128 liquidity, uint256 amount0, uint256 amount1);


    struct DecreaseLiquidityParams {
        uint256 tokenId;
        uint128 liquidity;
        uint256 amount0Min;
        uint256 amount1Min;
        uint256 deadline;
    }
    function decreaseLiquidity(
        DecreaseLiquidityParams calldata params
    ) external returns (uint256 amount0, uint256 amount1);


    function positions(
        uint256 tokenId
    ) external view returns (uint96, address, address, address, uint24, int24, int24, uint128, uint256, uint256, uint128, uint128);

}

interface IDaoL1Vault is IERC20Upgradeable {

    function deposit(uint amount) external;

    function withdraw(uint share) external returns (uint);

    function getAllPoolInUSD() external view returns (uint);

    function getAllPoolInETH() external view returns (uint);

    function getAllPoolInETHExcludeVestedILV() external view returns (uint);

}

interface IDaoL1VaultUniV3 is IERC20Upgradeable {

    function deposit(uint amount0, uint amount1) external;

    function withdraw(uint share) external returns (uint, uint);

    function getAllPoolInUSD() external view returns (uint);

    function getAllPoolInETH() external view returns (uint);

}

interface IChainlink {

    function latestAnswer() external view returns (int256);

}

contract MVFStrategy is Initializable, OwnableUpgradeable {

    using SafeERC20Upgradeable for IERC20Upgradeable;
    using SafeERC20Upgradeable for IPair;

    IERC20Upgradeable constant WETH = IERC20Upgradeable(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
    IERC20Upgradeable constant AXS = IERC20Upgradeable(0xBB0E17EF65F82Ab018d8EDd776e8DD940327B28b);
    IERC20Upgradeable constant SLP = IERC20Upgradeable(0xCC8Fa225D80b9c7D42F96e9570156c65D6cAAa25);
    IERC20Upgradeable constant ILV = IERC20Upgradeable(0x767FE9EDC9E0dF98E07454847909b5E959D7ca0E);
    IERC20Upgradeable constant GHST = IERC20Upgradeable(0x3F382DbD960E3a9bbCeaE22651E88158d2791550);
    IERC20Upgradeable constant REVV = IERC20Upgradeable(0x557B933a7C2c45672B610F8954A3deB39a51A8Ca);
    IERC20Upgradeable constant MVI = IERC20Upgradeable(0x72e364F2ABdC788b7E918bc238B21f109Cd634D7);

    IERC20Upgradeable constant AXSETH = IERC20Upgradeable(0x0C365789DbBb94A29F8720dc465554c587e897dB);
    IERC20Upgradeable constant SLPETH = IERC20Upgradeable(0x8597fa0773888107E2867D36dd87Fe5bAFeAb328);
    IERC20Upgradeable constant ILVETH = IERC20Upgradeable(0x6a091a3406E0073C3CD6340122143009aDac0EDa);
    IERC20Upgradeable constant GHSTETH = IERC20Upgradeable(0xFbA31F01058DB09573a383F26a088f23774d4E5d);
    IPair constant REVVETH = IPair(0x724d5c9c618A2152e99a45649a3B8cf198321f46);

    IRouter constant uniV2Router = IRouter(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
    IUniV3Router constant uniV3Router = IUniV3Router(0xE592427A0AEce92De3Edee1F18E0157C05861564);
    IRouter constant sushiRouter = IRouter(0xd9e1cE17f2641f24aE83637ab66a2cca9C378B9F); // Sushi

    IDaoL1Vault public AXSETHVault;
    IDaoL1Vault public SLPETHVault;
    IDaoL1Vault public ILVETHVault;
    IDaoL1VaultUniV3 public GHSTETHVault;

    uint constant AXSETHTargetPerc = 2000;
    uint constant SLPETHTargetPerc = 1500;
    uint constant ILVETHTargetPerc = 2000;
    uint constant GHSTETHTargetPerc = 1000;
    uint constant REVVETHTargetPerc = 1000;
    uint constant MVITargetPerc = 2500;

    address public vault;
    uint public watermark; // In USD (18 decimals)
    uint public profitFeePerc;

    event TargetComposition (uint AXSETHTargetPool, uint SLPETHTargetPool, uint ILVETHTargetPool, uint GHSTETHTargetPool, uint REVVETHTargetPool, uint MVITargetPool);
    event CurrentComposition (uint AXSETHCurrentPool, uint SLPETHCurrentPool, uint ILVETHCurrentPool, uint GHSTETHCurrentPool, uint REVVETHCurrentPool, uint MVICurrentPool);
    event InvestAXSETH(uint WETHAmt, uint AXSETHAmt);
    event InvestSLPETH(uint WETHAmt, uint SLPETHAmt);
    event InvestILVETH(uint WETHAmt, uint ILVETHAmt);
    event InvestGHSTETH(uint WETHAmt, uint GHSTAmt);
    event InvestREVVETH(uint WETHAmt, uint REVVETHAmt);
    event InvestMVI(uint WETHAmt, uint MVIAmt);
    event Withdraw(uint amount, uint WETHAmt);
    event WithdrawAXSETH(uint lpTokenAmt, uint WETHAmt);
    event WithdrawSLPETH(uint lpTokenAmt, uint WETHAmt);
    event WithdrawILVETH(uint lpTokenAmt, uint WETHAmt);
    event WithdrawGHSTETH(uint GHSTAmt, uint WETHAmt);
    event WithdrawREVVETH(uint lpTokenAmt, uint WETHAmt);
    event WithdrawMVI(uint lpTokenAmt, uint WETHAmt);
    event CollectProfitAndUpdateWatermark(uint currentWatermark, uint lastWatermark, uint fee);
    event AdjustWatermark(uint currentWatermark, uint lastWatermark);
    event Reimburse(uint WETHAmt);
    event EmergencyWithdraw(uint WETHAmt);

    modifier onlyVault {

        require(msg.sender == vault, "Only vault");
        _;
    }

    function initialize(
        address _AXSETHVault, address _SLPETHVault, address _ILVETHVault, address _GHSTETHVault
    ) external initializer {

        __Ownable_init();

        AXSETHVault = IDaoL1Vault(_AXSETHVault);
        SLPETHVault = IDaoL1Vault(_SLPETHVault);
        ILVETHVault = IDaoL1Vault(_ILVETHVault);
        GHSTETHVault = IDaoL1VaultUniV3(_GHSTETHVault);

        profitFeePerc = 2000;

        WETH.safeApprove(address(sushiRouter), type(uint).max);
        WETH.safeApprove(address(uniV2Router), type(uint).max);
        WETH.safeApprove(address(uniV3Router), type(uint).max);

        AXS.safeApprove(address(sushiRouter), type(uint).max);
        SLP.safeApprove(address(sushiRouter), type(uint).max);
        ILV.safeApprove(address(sushiRouter), type(uint).max);
        GHST.safeApprove(address(uniV3Router), type(uint).max);
        REVV.safeApprove(address(uniV2Router), type(uint).max);
        MVI.safeApprove(address(uniV2Router), type(uint).max);

        AXSETH.safeApprove(address(sushiRouter), type(uint).max);
        AXSETH.safeApprove(address(AXSETHVault), type(uint).max);
        SLPETH.safeApprove(address(sushiRouter), type(uint).max);
        SLPETH.safeApprove(address(SLPETHVault), type(uint).max);
        ILVETH.safeApprove(address(sushiRouter), type(uint).max);
        ILVETH.safeApprove(address(ILVETHVault), type(uint).max);
        GHST.safeApprove(address(GHSTETHVault), type(uint).max);
        WETH.safeApprove(address(GHSTETHVault), type(uint).max);
        REVVETH.safeApprove(address(uniV2Router), type(uint).max);
    }

    function invest(uint WETHAmt) external onlyVault {

        WETH.safeTransferFrom(vault, address(this), WETHAmt);

        uint[] memory pools = getEachPool(false);
        uint pool = pools[0] + pools[1] + pools[2] + pools[3] + pools[4] + pools[5] + WETHAmt;
        uint AXSETHTargetPool = pool * 2000 / 10000; // 20%
        uint SLPETHTargetPool = pool * 1500 / 10000; // 15%
        uint ILVETHTargetPool = AXSETHTargetPool; // 20%
        uint GHSTETHTargetPool = pool * 1000 / 10000; // 10%
        uint REVVETHTargetPool = GHSTETHTargetPool; // 10%
        uint MVITargetPool = pool * 2500 / 10000; // 25%

        if (
            AXSETHTargetPool > pools[0] &&
            SLPETHTargetPool > pools[1] &&
            ILVETHTargetPool > pools[2] &&
            GHSTETHTargetPool > pools[3] &&
            REVVETHTargetPool > pools[4] &&
            MVITargetPool > pools[5]
        ) {
            investAXSETH(AXSETHTargetPool - pools[0]);
            investSLPETH(SLPETHTargetPool - pools[1]);
            investILVETH(ILVETHTargetPool - pools[2]);
            investGHSTETH(GHSTETHTargetPool - pools[3]);
            investREVVETH(REVVETHTargetPool - pools[4]);
            investMVI(MVITargetPool - pools[5]);
        } else {
            uint furthest;
            uint farmIndex;
            uint diff;

            if (AXSETHTargetPool > pools[0]) {
                diff = AXSETHTargetPool - pools[0];
                furthest = diff;
                farmIndex = 0;
            }
            if (SLPETHTargetPool > pools[1]) {
                diff = SLPETHTargetPool - pools[1];
                if (diff > furthest) {
                    furthest = diff;
                    farmIndex = 1;
                }
            }
            if (ILVETHTargetPool > pools[2]) {
                diff = ILVETHTargetPool - pools[2];
                if (diff > furthest) {
                    furthest = diff;
                    farmIndex = 2;
                }
            }
            if (GHSTETHTargetPool > pools[3]) {
                diff = GHSTETHTargetPool - pools[3];
                if (diff > furthest) {
                    furthest = diff;
                    farmIndex = 3;
                }
            }
            if (REVVETHTargetPool > pools[4]) {
                diff = AXSETHTargetPool - pools[4];
                if (diff > furthest) {
                    furthest = diff;
                    farmIndex = 4;
                }
            }
            if (MVITargetPool > pools[5]) {
                diff = MVITargetPool - pools[5];
                if (diff > furthest) {
                    furthest = diff;
                    farmIndex = 5;
                }
            }

            if (farmIndex == 0) investAXSETH(WETHAmt);
            else if (farmIndex == 1) investSLPETH(WETHAmt);
            else if (farmIndex == 2) investILVETH(WETHAmt);
            else if (farmIndex == 3) investGHSTETH(WETHAmt);
            else if (farmIndex == 4) investREVVETH(WETHAmt);
            else investMVI(WETHAmt);
        }

        emit TargetComposition(AXSETHTargetPool, SLPETHTargetPool, ILVETHTargetPool, GHSTETHTargetPool, REVVETHTargetPool, MVITargetPool);
        emit CurrentComposition(pools[0], pools[1], pools[2], pools[3], pools[4], pools[5]);
    }

    function investAXSETH(uint WETHAmt) private {

        uint halfWETH = WETHAmt / 2;
        uint AXSAmt = sushiSwap(address(WETH), address(AXS), halfWETH, 0);
        (,,uint AXSETHAmt) = sushiRouter.addLiquidity(address(AXS), address(WETH), AXSAmt, halfWETH, 0, 0, address(this), block.timestamp);
        AXSETHVault.deposit(AXSETHAmt);
        emit InvestAXSETH(WETHAmt, AXSETHAmt);
    }

    function investSLPETH(uint WETHAmt) private {

        uint halfWETH = WETHAmt / 2;
        uint SLPAmt = sushiSwap(address(WETH), address(SLP), halfWETH, 0);
        (,,uint SLPETHAmt) = sushiRouter.addLiquidity(address(SLP), address(WETH), SLPAmt, halfWETH, 0, 0, address(this), block.timestamp);
        SLPETHVault.deposit(SLPETHAmt);
        emit InvestSLPETH(WETHAmt, SLPETHAmt);
    }

    function investILVETH(uint WETHAmt) private {

        uint halfWETH = WETHAmt / 2;
        uint ILVAmt = sushiSwap(address(WETH), address(ILV), halfWETH, 0);
        (,,uint ILVETHAmt) = sushiRouter.addLiquidity(address(ILV), address(WETH), ILVAmt, halfWETH, 0, 0, address(this), block.timestamp);
        ILVETHVault.deposit(ILVETHAmt);
        emit InvestILVETH(WETHAmt, ILVETHAmt);
    }

    function investGHSTETH(uint WETHAmt) private {

        uint halfWETH = WETHAmt / 2;
        uint GHSTAmt = uniV3Swap(address(WETH), address(GHST), 10000, halfWETH, 0);
        GHSTETHVault.deposit(GHSTAmt, halfWETH);
        emit InvestGHSTETH(WETHAmt, GHSTAmt);
    }

    function investREVVETH(uint WETHAmt) private {

        uint halfWETH = WETHAmt / 2;
        uint REVVAmt = uniV2Swap(address(WETH), address(REVV), halfWETH, 0);
        (,,uint REVVETHAmt) = uniV2Router.addLiquidity(address(REVV), address(WETH), REVVAmt, halfWETH, 0, 0, address(this), block.timestamp);
        emit InvestREVVETH(WETHAmt, REVVETHAmt);
    }

    function investMVI(uint WETHAmt) private {

        uint MVIAmt = uniV2Swap(address(WETH), address(MVI), WETHAmt, 0);
        emit InvestMVI(WETHAmt, MVIAmt);
    }

    function withdraw(uint amount, uint[] calldata tokenPrice) external onlyVault returns (uint WETHAmt) {

        uint sharePerc = amount * 1e18 / getAllPoolInUSD(false);
        uint WETHAmtBefore = WETH.balanceOf(address(this));
        withdrawAXSETH(sharePerc, tokenPrice[1]);
        withdrawSLPETH(sharePerc, tokenPrice[2]);
        withdrawILVETH(sharePerc, tokenPrice[3]);
        withdrawGHSTETH(sharePerc, tokenPrice[4]);
        withdrawREVVETH(sharePerc, tokenPrice[5]);
        withdrawMVI(sharePerc, tokenPrice[6]);
        WETHAmt = WETH.balanceOf(address(this)) - WETHAmtBefore;
        WETH.safeTransfer(vault, WETHAmt);
        emit Withdraw(amount, WETHAmt);
    }

    function withdrawAXSETH(uint sharePerc, uint AXSPriceInWETHMin) private {

        uint AXSETHAmt = AXSETHVault.withdraw(AXSETHVault.balanceOf(address(this)) * sharePerc / 1e18);
        (uint AXSAmt, uint WETHAmt) = sushiRouter.removeLiquidity(address(AXS), address(WETH), AXSETHAmt, 0, 0, address(this), block.timestamp);
        uint _WETHAmt = sushiSwap(address(AXS), address(WETH), AXSAmt, AXSAmt * AXSPriceInWETHMin / 1e18);
        emit WithdrawAXSETH(AXSETHAmt, WETHAmt + _WETHAmt);
    }

    function withdrawSLPETH(uint sharePerc, uint SLPPriceInWETHMin) private {

        uint SLPETHAmt = SLPETHVault.withdraw(SLPETHVault.balanceOf(address(this)) * sharePerc / 1e18);
        (uint SLPAmt, uint WETHAmt) = sushiRouter.removeLiquidity(address(SLP), address(WETH), SLPETHAmt, 0, 0, address(this), block.timestamp);
        uint _WETHAmt = sushiSwap(address(SLP), address(WETH), SLPAmt, SLPAmt * SLPPriceInWETHMin);
        emit WithdrawSLPETH(SLPETHAmt, WETHAmt + _WETHAmt);
    }

    function withdrawILVETH(uint sharePerc, uint ILVPriceInWETHMin) private {

        uint ILVETHAmt = ILVETHVault.withdraw(ILVETHVault.balanceOf(address(this)) * sharePerc / 1e18);
        (uint ILVAmt, uint WETHAmt) = sushiRouter.removeLiquidity(address(ILV), address(WETH), ILVETHAmt, 0, 0, address(this), block.timestamp);
        uint _WETHAmt = sushiSwap(address(ILV), address(WETH), ILVAmt, ILVAmt * ILVPriceInWETHMin / 1e18);
        emit WithdrawILVETH(ILVETHAmt, WETHAmt + _WETHAmt);
    }

    function withdrawGHSTETH(uint sharePerc, uint GHSTPriceInWETHMin) private {

        (uint GHSTAmt, uint WETHAmt) = GHSTETHVault.withdraw(GHSTETHVault.balanceOf(address(this)) * sharePerc / 1e18);
        uniV3Swap(address(GHST), address(WETH), 10000, GHSTAmt, GHSTAmt * GHSTPriceInWETHMin / 1e18);
        emit WithdrawGHSTETH(GHSTAmt, WETHAmt);
    }

    function withdrawREVVETH(uint sharePerc, uint REVVPriceInWETHMin) private {

        uint REVVETHAmt = REVVETH.balanceOf(address(this)) * sharePerc / 1e18;
        (uint REVVAmt, uint WETHAmt) = uniV2Router.removeLiquidity(address(REVV), address(WETH), REVVETHAmt, 0, 0, address(this), block.timestamp);
        uint _WETHAmt = uniV2Swap(address(REVV), address(WETH), REVVAmt, REVVAmt * REVVPriceInWETHMin / 1e18);
        emit WithdrawREVVETH(REVVETHAmt, WETHAmt + _WETHAmt);
    }

    function withdrawMVI(uint sharePerc, uint MVIPriceInWETHMin) private {

        uint MVIAmt = MVI.balanceOf(address(this)) * sharePerc / 1e18;
        uint WETHAmt = uniV2Swap(address(MVI), address(WETH), MVIAmt, MVIAmt * MVIPriceInWETHMin / 1e18);
        emit WithdrawMVI(MVIAmt, WETHAmt);
    }

    function collectProfitAndUpdateWatermark() external onlyVault returns (uint fee) {

        uint currentWatermark = getAllPoolInUSD(false);
        uint lastWatermark = watermark;
        if (currentWatermark > lastWatermark) {
            uint profit = currentWatermark - lastWatermark;
            fee = profit * profitFeePerc / 10000;
            watermark = currentWatermark;
        }
        emit CollectProfitAndUpdateWatermark(currentWatermark, lastWatermark, fee);
    }

    function adjustWatermark(uint amount, bool signs) external onlyVault {

        uint lastWatermark = watermark;
        watermark = signs == true ? watermark + amount : watermark - amount;
        emit AdjustWatermark(watermark, lastWatermark);
    }

    function reimburse(uint farmIndex, uint amount) external onlyVault returns (uint WETHAmt) {

        if (farmIndex == 0) withdrawAXSETH(amount * 1e18 / getAXSETHPool(), 0);
        else if (farmIndex == 1) withdrawSLPETH(amount * 1e18 / getSLPETHPool(), 0);
        else if (farmIndex == 2) withdrawILVETH(amount * 1e18 / getILVETHPool(false), 0);
        else if (farmIndex == 3) withdrawGHSTETH(amount * 1e18 / getGHSTETHPool(), 0);
        else if (farmIndex == 4) withdrawREVVETH(amount * 1e18 / getREVVETHPool(), 0);
        else if (farmIndex == 5) withdrawMVI(amount * 1e18 / getMVIPool(), 0);
        WETHAmt = WETH.balanceOf(address(this));
        WETH.safeTransfer(vault, WETHAmt);
        emit Reimburse(WETHAmt);
    }

    function emergencyWithdraw() external onlyVault {

        withdrawAXSETH(1e18, 0);
        withdrawSLPETH(1e18, 0);
        withdrawILVETH(1e18, 0);
        withdrawGHSTETH(1e18, 0);
        withdrawREVVETH(1e18, 0);
        withdrawMVI(1e18, 0);
        uint WETHAmt = WETH.balanceOf(address(this));
        WETH.safeTransfer(vault, WETHAmt);
        watermark = 0;
        emit EmergencyWithdraw(WETHAmt);
    }

    function sushiSwap(address from, address to, uint amount, uint amountOutMin) private returns (uint) {

        address[] memory path = new address[](2);
        path[0] = from;
        path[1] = to;
        return sushiRouter.swapExactTokensForTokens(amount, amountOutMin, path, address(this), block.timestamp)[1];
    }

    function uniV2Swap(address from, address to, uint amount, uint amountOutMin) private returns (uint) {

        address[] memory path = new address[](2);
        path[0] = from;
        path[1] = to;
        return uniV2Router.swapExactTokensForTokens(amount, amountOutMin, path, address(this), block.timestamp)[1];
    }

    function uniV3Swap(address tokenIn, address tokenOut, uint24 fee, uint amountIn, uint amountOutMin) private returns (uint amountOut) {

        IUniV3Router.ExactInputSingleParams memory params =
            IUniV3Router.ExactInputSingleParams({
                tokenIn: tokenIn,
                tokenOut: tokenOut,
                fee: fee,
                recipient: address(this),
                deadline: block.timestamp,
                amountIn: amountIn,
                amountOutMinimum: amountOutMin,
                sqrtPriceLimitX96: 0
            });
        amountOut = uniV3Router.exactInputSingle(params);
    }

    function setVault(address _vault) external onlyOwner {

        require(vault == address(0), "Vault set");
        vault = _vault;
    }

    function setProfitFeePerc(uint _profitFeePerc) external onlyVault {

        profitFeePerc = _profitFeePerc;
    }

    function getPath(address tokenA, address tokenB) private pure returns (address[] memory path) {

        path = new address[](2);
        path[0] = tokenA;
        path[1] = tokenB;
    }

    function getAXSETHPool() private view returns (uint) {

        uint AXSETHVaultPool = AXSETHVault.getAllPoolInETH();
        if (AXSETHVaultPool == 0) return 0;
        return AXSETHVaultPool * AXSETHVault.balanceOf(address(this)) / AXSETHVault.totalSupply();
    }

    function getSLPETHPool() private view returns (uint) {

        uint SLPETHVaultPool = SLPETHVault.getAllPoolInETH();
        if (SLPETHVaultPool == 0) return 0;
        return SLPETHVaultPool * SLPETHVault.balanceOf(address(this)) / SLPETHVault.totalSupply();
    }

    function getILVETHPool(bool includeVestedILV) private view returns (uint) {

        uint ILVETHVaultPool =  includeVestedILV ? 
            ILVETHVault.getAllPoolInETH(): 
            ILVETHVault.getAllPoolInETHExcludeVestedILV();
        if (ILVETHVaultPool == 0) return 0;
        return ILVETHVaultPool * ILVETHVault.balanceOf(address(this)) / ILVETHVault.totalSupply();
    }

    function getGHSTETHPool() private view returns (uint) {

        uint GHSTETHVaultPool = GHSTETHVault.getAllPoolInETH();
        if (GHSTETHVaultPool == 0) return 0;
        return GHSTETHVaultPool * GHSTETHVault.balanceOf(address(this)) / GHSTETHVault.totalSupply();
    }

    function getREVVETHPool() private view returns (uint) {

        uint REVVETHAmt = REVVETH.balanceOf(address(this));
        if (REVVETHAmt == 0) return 0;
        uint REVVPrice = uniV2Router.getAmountsOut(1e18, getPath(address(REVV), address(WETH)))[1];
        (uint112 reserveREVV, uint112 reserveWETH,) = REVVETH.getReserves();
        uint totalReserve = reserveREVV * REVVPrice / 1e18 + reserveWETH;
        uint pricePerFullShare = totalReserve * 1e18 / REVVETH.totalSupply();
        return REVVETHAmt * pricePerFullShare / 1e18;
    }

    function getMVIPool() private view returns (uint) {

        uint MVIAmt = MVI.balanceOf(address(this));
        if (MVIAmt == 0) return 0;
        uint MVIPrice = uniV2Router.getAmountsOut(1e18, getPath(address(MVI), address(WETH)))[1];
        return MVIAmt * MVIPrice / 1e18;
    }

    function getEachPool(bool includeVestedILV) private view returns (uint[] memory pools) {

        pools = new uint[](6);
        pools[0] = getAXSETHPool();
        pools[1] = getSLPETHPool();
        pools[2] = getILVETHPool(includeVestedILV);
        pools[3] = getGHSTETHPool();
        pools[4] = getREVVETHPool();
        pools[5] = getMVIPool();
    }

    function getAllPool(bool includeVestedILV) public view returns (uint) {

        uint[] memory pools = getEachPool(includeVestedILV);
        return pools[0] + pools[1] + pools[2] + pools[3] + pools[4] + pools[5]; 
    }

    function getAllPoolInUSD(bool includeVestedILV) public view returns (uint) {

        uint ETHPriceInUSD = uint(IChainlink(0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419).latestAnswer()); // 8 decimals
        require(ETHPriceInUSD > 0, "ChainLink error");
        return getAllPool(includeVestedILV) * ETHPriceInUSD / 1e8;
    }

    function getCurrentCompositionPerc() external view returns (uint[] memory percentages) {

        uint[] memory pools = getEachPool(false);
        uint allPool = pools[0] + pools[1] + pools[2] + pools[3] + pools[4] + pools[5];
        percentages = new uint[](6);
        percentages[0] = pools[0] * 10000 / allPool;
        percentages[1] = pools[1] * 10000 / allPool;
        percentages[2] = pools[2] * 10000 / allPool;
        percentages[3] = pools[3] * 10000 / allPool;
        percentages[4] = pools[4] * 10000 / allPool;
        percentages[5] = pools[5] * 10000 / allPool;
    }
}