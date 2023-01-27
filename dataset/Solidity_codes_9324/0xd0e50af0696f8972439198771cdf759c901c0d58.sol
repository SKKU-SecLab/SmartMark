

pragma solidity 0.8.9;




interface IBasicRewards {

    function stakeFor(address, uint256) external returns (bool);


    function balanceOf(address) external view returns (uint256);


    function earned(address) external view returns (uint256);


    function withdrawAll(bool) external returns (bool);


    function withdraw(uint256, bool) external returns (bool);


    function withdrawAndUnwrap(uint256 amount, bool claim)
        external
        returns (bool);


    function getReward() external returns (bool);


    function stake(uint256) external returns (bool);


    function extraRewards(uint256) external view returns (address);

}


interface ICVXLocker {

    function lock(
        address _account,
        uint256 _amount,
        uint256 _spendRatio
    ) external;


    function balances(address _user)
        external
        view
        returns (
            uint112 locked,
            uint112 boosted,
            uint32 nextUnlockIndex
        );

}


interface ICurveTriCrypto {

    function exchange(
        uint256 i,
        uint256 j,
        uint256 dx,
        uint256 min_dy,
        bool use_eth
    ) external payable;


    function get_dy(
        uint256 i,
        uint256 j,
        uint256 dx
    ) external view returns (uint256);

}


interface ICurveV2Pool {

    function get_dy(
        uint256 i,
        uint256 j,
        uint256 dx
    ) external view returns (uint256);


    function exchange_underlying(
        uint256 i,
        uint256 j,
        uint256 dx,
        uint256 min_dy
    ) external payable returns (uint256);


    function add_liquidity(uint256[2] calldata amounts, uint256 min_mint_amount)
        external
        returns (uint256);


    function lp_price() external view returns (uint256);


    function price_oracle() external view returns (uint256);


    function remove_liquidity_one_coin(
        uint256 token_amount,
        uint256 i,
        uint256 min_amount,
        bool use_eth,
        address receiver
    ) external returns (uint256);

}


interface IGenericVault {

    function withdraw(address _to, uint256 _shares)
        external
        returns (uint256 withdrawn);


    function withdrawAll(address _to) external returns (uint256 withdrawn);


    function depositAll(address _to) external returns (uint256 _shares);


    function deposit(address _to, uint256 _amount)
        external
        returns (uint256 _shares);


    function harvest() external;


    function balanceOfUnderlying(address user)
        external
        view
        returns (uint256 amount);


    function totalUnderlying() external view returns (uint256 total);


    function totalSupply() external view returns (uint256 total);


    function underlying() external view returns (address);


    function setPlatform(address _platform) external;


    function setPlatformFee(uint256 _fee) external;


    function setCallIncentive(uint256 _incentive) external;


    function setWithdrawalPenalty(uint256 _penalty) external;


    function setApprovals() external;


    function callIncentive() external view returns (uint256);


    function platformFee() external view returns (uint256);


    function platform() external view returns (address);

}


interface IUniV2Router {

    function swapExactTokensForETH(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);


    function swapExactETHForTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);


    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);


    function getAmountsOut(uint256 amountIn, address[] memory path)
        external
        view
        returns (uint256[] memory amounts);

}


interface IUniV3Router {

    struct ExactInputSingleParams {
        address tokenIn;
        address tokenOut;
        uint24 fee;
        address recipient;
        uint256 deadline;
        uint256 amountIn;
        uint256 amountOutMinimum;
        uint160 sqrtPriceLimitX96;
    }

    function exactInputSingle(ExactInputSingleParams calldata params)
        external
        payable
        returns (uint256 amountOut);


    struct ExactInputParams {
        bytes path;
        address recipient;
        uint256 deadline;
        uint256 amountIn;
        uint256 amountOutMinimum;
    }

    function exactInput(ExactInputParams calldata params)
        external
        payable
        returns (uint256 amountOut);

}


interface IWETH {

    function deposit() external payable;


    function transfer(address to, uint256 value) external returns (bool);


    function withdraw(uint256) external;

}


library Address {

    function isContract(address account) internal view returns (bool) {


        uint256 size;
        assembly { size := extcodesize(account) }
        return size > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {

      return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {

        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {

        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {

        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {

        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {

        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {

        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {

        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {

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


abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}


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


abstract contract ReentrancyGuard {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor () {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
    }
}


contract CvxFxsStrategyBase {

    address public constant CVXFXS_STAKING_CONTRACT =
        0xf27AFAD0142393e4b3E5510aBc5fe3743Ad669Cb;
    address public constant CURVE_CRV_ETH_POOL =
        0x8301AE4fc9c624d1D396cbDAa1ed877821D7C511;
    address public constant CURVE_CVX_ETH_POOL =
        0xB576491F1E6e5E62f1d8F26062Ee822B40B0E0d4;
    address public constant CURVE_FXS_ETH_POOL =
        0x941Eb6F616114e4Ecaa85377945EA306002612FE;
    address public constant CURVE_CVXFXS_FXS_POOL =
        0xd658A338613198204DCa1143Ac3F01A722b5d94A;
    address public constant UNISWAP_ROUTER =
        0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
    address public constant UNIV3_ROUTER =
        0xE592427A0AEce92De3Edee1F18E0157C05861564;

    address public constant CRV_TOKEN =
        0xD533a949740bb3306d119CC777fa900bA034cd52;
    address public constant CVXFXS_TOKEN =
        0xFEEf77d3f69374f66429C91d732A244f074bdf74;
    address public constant FXS_TOKEN =
        0x3432B6A60D23Ca0dFCa7761B7ab56459D9C964D0;
    address public constant CVX_TOKEN =
        0x4e3FBD56CD56c3e72c1403e103b45Db9da5B9D2B;
    address public constant WETH_TOKEN =
        0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    address public constant CURVE_CVXFXS_FXS_LP_TOKEN =
        0xF3A43307DcAFa93275993862Aae628fCB50dC768;
    address public constant USDT_TOKEN =
        0xdAC17F958D2ee523a2206206994597C13D831ec7;
    address public constant USDC_TOKEN =
        0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
    address public constant FRAX_TOKEN =
        0x853d955aCEf822Db058eb8505911ED77F175b99e;

    uint256 public constant CRVETH_ETH_INDEX = 0;
    uint256 public constant CRVETH_CRV_INDEX = 1;
    uint256 public constant CVXETH_ETH_INDEX = 0;
    uint256 public constant CVXETH_CVX_INDEX = 1;

    enum SwapOption {
        Curve,
        Uniswap,
        Unistables
    }
    SwapOption public swapOption = SwapOption.Curve;
    event OptionChanged(SwapOption oldOption, SwapOption newOption);

    IBasicRewards cvxFxsStaking = IBasicRewards(CVXFXS_STAKING_CONTRACT);
    ICurveV2Pool cvxEthSwap = ICurveV2Pool(CURVE_CVX_ETH_POOL);

    ICurveV2Pool crvEthSwap = ICurveV2Pool(CURVE_CRV_ETH_POOL);
    ICurveV2Pool fxsEthSwap = ICurveV2Pool(CURVE_FXS_ETH_POOL);
    ICurveV2Pool cvxFxsFxsSwap = ICurveV2Pool(CURVE_CVXFXS_FXS_POOL);

    function _swapCrvToEth(uint256 amount) internal returns (uint256) {

        return _crvToEth(amount, 0);
    }

    function _swapCrvToEth(uint256 amount, uint256 minAmountOut)
        internal
        returns (uint256)
    {

        return _crvToEth(amount, minAmountOut);
    }

    function _crvToEth(uint256 amount, uint256 minAmountOut)
        internal
        returns (uint256)
    {

        return
            crvEthSwap.exchange_underlying{value: 0}(
                CRVETH_CRV_INDEX,
                CRVETH_ETH_INDEX,
                amount,
                minAmountOut
            );
    }

    function _swapEthToCrv(uint256 amount) internal returns (uint256) {

        return _ethToCrv(amount, 0);
    }

    function _swapEthToCrv(uint256 amount, uint256 minAmountOut)
        internal
        returns (uint256)
    {

        return _ethToCrv(amount, minAmountOut);
    }

    function _ethToCrv(uint256 amount, uint256 minAmountOut)
        internal
        returns (uint256)
    {

        return
            crvEthSwap.exchange_underlying{value: amount}(
                CRVETH_ETH_INDEX,
                CRVETH_CRV_INDEX,
                amount,
                minAmountOut
            );
    }

    function _swapEthToCvx(uint256 amount) internal returns (uint256) {

        return _ethToCvx(amount, 0);
    }

    function _swapEthToCvx(uint256 amount, uint256 minAmountOut)
        internal
        returns (uint256)
    {

        return _ethToCvx(amount, minAmountOut);
    }

    function _swapCvxToEth(uint256 amount) internal returns (uint256) {

        return _cvxToEth(amount, 0);
    }

    function _swapCvxToEth(uint256 amount, uint256 minAmountOut)
        internal
        returns (uint256)
    {

        return _cvxToEth(amount, minAmountOut);
    }

    function _ethToCvx(uint256 amount, uint256 minAmountOut)
        internal
        returns (uint256)
    {

        return
            cvxEthSwap.exchange_underlying{value: amount}(
                CVXETH_ETH_INDEX,
                CVXETH_CVX_INDEX,
                amount,
                minAmountOut
            );
    }

    function _cvxToEth(uint256 amount, uint256 minAmountOut)
        internal
        returns (uint256)
    {

        return
            cvxEthSwap.exchange_underlying{value: 0}(
                1,
                0,
                amount,
                minAmountOut
            );
    }

    function _swapEthForFxs(uint256 _ethAmount, SwapOption _option)
        internal
        returns (uint256)
    {

        return _swapEthFxs(_ethAmount, _option, true);
    }

    function _swapFxsForEth(uint256 _fxsAmount, SwapOption _option)
        internal
        returns (uint256)
    {

        return _swapEthFxs(_fxsAmount, _option, false);
    }

    function _curveEthFxsSwap(uint256 _amount, bool _ethToFxs)
        internal
        returns (uint256)
    {

        return
            fxsEthSwap.exchange_underlying{value: _ethToFxs ? _amount : 0}(
                _ethToFxs ? 0 : 1,
                _ethToFxs ? 1 : 0,
                _amount,
                0
            );
    }

    function _uniV3EthFxsSwap(uint256 _amount, bool _ethToFxs)
        internal
        returns (uint256)
    {

        IUniV3Router.ExactInputSingleParams memory _params = IUniV3Router
            .ExactInputSingleParams(
                _ethToFxs ? WETH_TOKEN : FXS_TOKEN,
                _ethToFxs ? FXS_TOKEN : WETH_TOKEN,
                10000,
                address(this),
                block.timestamp + 1,
                _amount,
                1,
                0
            );

        uint256 _receivedAmount = IUniV3Router(UNIV3_ROUTER).exactInputSingle{
            value: _ethToFxs ? _amount : 0
        }(_params);
        if (!_ethToFxs) {
            IWETH(WETH_TOKEN).withdraw(_receivedAmount);
        }
        return _receivedAmount;
    }

    function _uniStableEthToFxsSwap(uint256 _amount)
        internal
        returns (uint256)
    {

        uint24 fee = 500;
        IUniV3Router.ExactInputParams memory _params = IUniV3Router
            .ExactInputParams(
                abi.encodePacked(WETH_TOKEN, fee, USDC_TOKEN, fee, FRAX_TOKEN),
                address(this),
                block.timestamp + 1,
                _amount,
                0
            );

        uint256 _fraxAmount = IUniV3Router(UNIV3_ROUTER).exactInput{
            value: _amount
        }(_params);
        address[] memory _path = new address[](2);
        _path[0] = FRAX_TOKEN;
        _path[1] = FXS_TOKEN;
        uint256[] memory amounts = IUniV2Router(UNISWAP_ROUTER)
            .swapExactTokensForTokens(
                _fraxAmount,
                1,
                _path,
                address(this),
                block.timestamp + 1
            );
        return amounts[1];
    }

    function _uniStableFxsToEthSwap(uint256 _amount)
        internal
        returns (uint256)
    {

        address[] memory _path = new address[](2);
        _path[0] = FXS_TOKEN;
        _path[1] = FRAX_TOKEN;
        uint256[] memory amounts = IUniV2Router(UNISWAP_ROUTER)
            .swapExactTokensForTokens(
                _amount,
                1,
                _path,
                address(this),
                block.timestamp + 1
            );

        uint256 _fraxAmount = amounts[1];
        uint24 fee = 500;

        IUniV3Router.ExactInputParams memory _params = IUniV3Router
            .ExactInputParams(
                abi.encodePacked(FRAX_TOKEN, fee, USDC_TOKEN, fee, WETH_TOKEN),
                address(this),
                block.timestamp + 1,
                _fraxAmount,
                0
            );

        uint256 _ethAmount = IUniV3Router(UNIV3_ROUTER).exactInput{value: 0}(
            _params
        );
        IWETH(WETH_TOKEN).withdraw(_ethAmount);
        return _ethAmount;
    }

    function _swapEthFxs(
        uint256 _amount,
        SwapOption _option,
        bool _ethToFxs
    ) internal returns (uint256) {

        if (_option == SwapOption.Curve) {
            return _curveEthFxsSwap(_amount, _ethToFxs);
        } else if (_option == SwapOption.Uniswap) {
            return _uniV3EthFxsSwap(_amount, _ethToFxs);
        } else {
            return
                _ethToFxs
                    ? _uniStableEthToFxsSwap(_amount)
                    : _uniStableFxsToEthSwap(_amount);
        }
    }

    receive() external payable {}
}


abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
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
}


library SafeERC20 {

    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint256 value) internal {

        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {


        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}


contract CvxFxsZaps is Ownable, CvxFxsStrategyBase, ReentrancyGuard {

    using SafeERC20 for IERC20;

    address public immutable vault;

    address private constant CONVEX_LOCKER =
        0x72a19342e8F1838460eBFCCEf09F6585e32db86E;
    address private constant TRICRYPTO =
        0xD51a44d3FaE010294C616388b506AcdA1bfAAE46;
    ICurveTriCrypto triCryptoSwap = ICurveTriCrypto(TRICRYPTO);
    ICVXLocker locker = ICVXLocker(CONVEX_LOCKER);

    constructor(address _vault) {
        vault = _vault;
    }

    function setSwapOption(SwapOption _newOption) external onlyOwner {

        SwapOption _oldOption = swapOption;
        swapOption = _newOption;
        emit OptionChanged(_oldOption, swapOption);
    }

    function setApprovals() external {

        IERC20(CURVE_CVXFXS_FXS_LP_TOKEN).safeApprove(vault, 0);
        IERC20(CURVE_CVXFXS_FXS_LP_TOKEN).safeApprove(vault, type(uint256).max);

        IERC20(CVX_TOKEN).safeApprove(CURVE_CVX_ETH_POOL, 0);
        IERC20(CVX_TOKEN).safeApprove(CURVE_CVX_ETH_POOL, type(uint256).max);

        IERC20(FXS_TOKEN).safeApprove(CURVE_CVXFXS_FXS_POOL, 0);
        IERC20(FXS_TOKEN).safeApprove(CURVE_CVXFXS_FXS_POOL, type(uint256).max);

        IERC20(FXS_TOKEN).safeApprove(CURVE_FXS_ETH_POOL, 0);
        IERC20(FXS_TOKEN).safeApprove(CURVE_FXS_ETH_POOL, type(uint256).max);

        IERC20(FXS_TOKEN).safeApprove(UNISWAP_ROUTER, 0);
        IERC20(FXS_TOKEN).safeApprove(UNISWAP_ROUTER, type(uint256).max);

        IERC20(FXS_TOKEN).safeApprove(UNIV3_ROUTER, 0);
        IERC20(FXS_TOKEN).safeApprove(UNIV3_ROUTER, type(uint256).max);

        IERC20(FRAX_TOKEN).safeApprove(UNIV3_ROUTER, 0);
        IERC20(FRAX_TOKEN).safeApprove(UNIV3_ROUTER, type(uint256).max);

        IERC20(CVXFXS_TOKEN).safeApprove(CURVE_CVXFXS_FXS_POOL, 0);
        IERC20(CVXFXS_TOKEN).safeApprove(
            CURVE_CVXFXS_FXS_POOL,
            type(uint256).max
        );

        IERC20(CVX_TOKEN).safeApprove(CONVEX_LOCKER, 0);
        IERC20(CVX_TOKEN).safeApprove(CONVEX_LOCKER, type(uint256).max);

        IERC20(CRV_TOKEN).safeApprove(CURVE_CRV_ETH_POOL, 0);
        IERC20(CRV_TOKEN).safeApprove(CURVE_CRV_ETH_POOL, type(uint256).max);
    }

    function depositFromUnderlyingAssets(
        uint256[2] calldata amounts,
        uint256 minAmountOut,
        address to
    ) external notToZeroAddress(to) {

        if (amounts[0] > 0) {
            IERC20(FXS_TOKEN).safeTransferFrom(
                msg.sender,
                address(this),
                amounts[0]
            );
        }
        if (amounts[1] > 0) {
            IERC20(CVXFXS_TOKEN).safeTransferFrom(
                msg.sender,
                address(this),
                amounts[1]
            );
        }
        _addAndDeposit(amounts, minAmountOut, to);
    }

    function _addAndDeposit(
        uint256[2] memory amounts,
        uint256 minAmountOut,
        address to
    ) internal {

        cvxFxsFxsSwap.add_liquidity(amounts, minAmountOut);
        IGenericVault(vault).depositAll(to);
    }

    function depositWithRewards(
        uint256 lpTokenAmount,
        uint256 crvAmount,
        uint256 cvxAmount,
        uint256 minAmountOut,
        address to
    ) external notToZeroAddress(to) {

        require(lpTokenAmount + crvAmount + cvxAmount > 0, "cheap");
        if (lpTokenAmount > 0) {
            IERC20(CURVE_CVXFXS_FXS_LP_TOKEN).safeTransferFrom(
                msg.sender,
                address(this),
                lpTokenAmount
            );
        }
        if (crvAmount > 0) {
            IERC20(CRV_TOKEN).safeTransferFrom(
                msg.sender,
                address(this),
                crvAmount
            );
            _swapCrvToEth(crvAmount);
        }
        if (cvxAmount > 0) {
            IERC20(CVX_TOKEN).safeTransferFrom(
                msg.sender,
                address(this),
                cvxAmount
            );
            _swapCvxToEth(cvxAmount);
        }
        if (address(this).balance > 0) {
            uint256 fxsBalance = _swapEthForFxs(
                address(this).balance,
                swapOption
            );
            cvxFxsFxsSwap.add_liquidity([fxsBalance, 0], minAmountOut);
        }
        IGenericVault(vault).depositAll(to);
    }

    function depositFromEth(uint256 minAmountOut, address to)
        external
        payable
        notToZeroAddress(to)
    {

        require(msg.value > 0, "cheap");
        _depositFromEth(msg.value, minAmountOut, to);
    }

    function _depositFromEth(
        uint256 amount,
        uint256 minAmountOut,
        address to
    ) internal {

        uint256 fxsBalance = _swapEthForFxs(amount, swapOption);
        _addAndDeposit([fxsBalance, 0], minAmountOut, to);
    }

    function depositViaUniV2EthPair(
        uint256 amount,
        uint256 minAmountOut,
        address router,
        address inputToken,
        address to
    ) external notToZeroAddress(to) {

        require(router != address(0));

        IERC20(inputToken).safeTransferFrom(msg.sender, address(this), amount);
        address[] memory _path = new address[](2);
        _path[0] = inputToken;
        _path[1] = WETH_TOKEN;

        IERC20(inputToken).safeApprove(router, 0);
        IERC20(inputToken).safeApprove(router, amount);

        IUniV2Router(router).swapExactTokensForETH(
            amount,
            1,
            _path,
            address(this),
            block.timestamp + 1
        );
        _depositFromEth(address(this).balance, minAmountOut, to);
    }

    function _claimAsUnderlying(
        uint256 _amount,
        uint256 _assetIndex,
        uint256 _minAmountOut,
        address _to
    ) internal returns (uint256) {

        return
            cvxFxsFxsSwap.remove_liquidity_one_coin(
                _amount,
                _assetIndex,
                _minAmountOut,
                false,
                _to
            );
    }

    function _claimAndWithdraw(uint256 _amount) internal {

        IERC20(vault).safeTransferFrom(msg.sender, address(this), _amount);
        IGenericVault(vault).withdrawAll(address(this));
    }

    function claimFromVaultAsUnderlying(
        uint256 amount,
        uint256 assetIndex,
        uint256 minAmountOut,
        address to
    ) public notToZeroAddress(to) returns (uint256) {

        _claimAndWithdraw(amount);
        return
            _claimAsUnderlying(
                IERC20(CURVE_CVXFXS_FXS_LP_TOKEN).balanceOf(address(this)),
                assetIndex,
                minAmountOut,
                to
            );
    }

    function claimFromVaultAsEth(
        uint256 amount,
        uint256 minAmountOut,
        address to
    ) public notToZeroAddress(to) returns (uint256) {

        uint256 _ethAmount = _claimAsEth(amount);
        require(_ethAmount >= minAmountOut, "Slippage");
        (bool success, ) = to.call{value: _ethAmount}("");
        require(success, "ETH transfer failed");
        return _ethAmount;
    }

    function _claimAsEth(uint256 amount) public nonReentrant returns (uint256) {

        _claimAndWithdraw(amount);
        uint256 _fxsAmount = _claimAsUnderlying(
            IERC20(CURVE_CVXFXS_FXS_LP_TOKEN).balanceOf(address(this)),
            0,
            0,
            address(this)
        );
        return _swapFxsForEth(_fxsAmount, swapOption);
    }

    function claimFromVaultViaUniV2EthPair(
        uint256 amount,
        uint256 minAmountOut,
        address router,
        address outputToken,
        address to
    ) public notToZeroAddress(to) {

        require(router != address(0));
        _claimAsEth(amount);
        address[] memory _path = new address[](2);
        _path[0] = WETH_TOKEN;
        _path[1] = outputToken;
        IUniV2Router(router).swapExactETHForTokens{
            value: address(this).balance
        }(minAmountOut, _path, to, block.timestamp + 1);
    }

    function claimFromVaultAsUsdt(
        uint256 amount,
        uint256 minAmountOut,
        address to
    ) public notToZeroAddress(to) returns (uint256) {

        uint256 _ethAmount = _claimAsEth(amount);
        _swapEthToUsdt(_ethAmount, minAmountOut);
        uint256 _usdtAmount = IERC20(USDT_TOKEN).balanceOf(address(this));
        IERC20(USDT_TOKEN).safeTransfer(to, _usdtAmount);
        return _usdtAmount;
    }

    function _swapEthToUsdt(uint256 _amount, uint256 _minAmountOut) internal {

        triCryptoSwap.exchange{value: _amount}(
            2, // ETH
            0, // USDT
            _amount,
            _minAmountOut,
            true
        );
    }

    function claimFromVaultAsCvx(
        uint256 amount,
        uint256 minAmountOut,
        address to,
        bool lock
    ) public notToZeroAddress(to) returns (uint256) {

        uint256 _ethAmount = _claimAsEth(amount);
        uint256 _cvxAmount = _swapEthToCvx(_ethAmount, minAmountOut);
        if (lock) {
            locker.lock(to, _cvxAmount, 0);
        } else {
            IERC20(CVX_TOKEN).safeTransfer(to, _cvxAmount);
        }
        return _cvxAmount;
    }

    function execute(
        address _to,
        uint256 _value,
        bytes calldata _data
    ) external onlyOwner returns (bool, bytes memory) {

        (bool success, bytes memory result) = _to.call{value: _value}(_data);
        return (success, result);
    }

    modifier notToZeroAddress(address _to) {

        require(_to != address(0), "Invalid address!");
        _;
    }
}