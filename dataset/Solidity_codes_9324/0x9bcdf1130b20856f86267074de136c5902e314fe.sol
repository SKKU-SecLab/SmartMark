
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

pragma solidity ^0.8.0;

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
}// MIT

pragma solidity ^0.8.0;


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
}// MIT

pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}pragma solidity >=0.6.2;

interface IUniswapV2Router01 {

    function factory() external pure returns (address);

    function WETH() external pure returns (address);


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

    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);

    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);

    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);

    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);

    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);

    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);

    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);

    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);

    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);


    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);

    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);

    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);

    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);

    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);

}pragma solidity >=0.6.2;


interface IUniswapV2Router02 is IUniswapV2Router01 {

    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);

    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);


    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;

}// MIT

pragma solidity 0.8.3;


contract Governed is Context, Initializable {

    address public governor;
    address private proposedGovernor;

    event UpdatedGovernor(address indexed previousGovernor, address indexed proposedGovernor);

    constructor() {
        address msgSender = _msgSender();
        governor = msgSender;
        emit UpdatedGovernor(address(0), msgSender);
    }

    function _initializeGoverned() internal initializer {

        address msgSender = _msgSender();
        governor = msgSender;
        emit UpdatedGovernor(address(0), msgSender);
    }

    modifier onlyGovernor {

        require(governor == _msgSender(), "not-the-governor");
        _;
    }

    function transferGovernorship(address _proposedGovernor) external onlyGovernor {

        require(_proposedGovernor != address(0), "proposed-governor-is-zero");
        proposedGovernor = _proposedGovernor;
    }

    function acceptGovernorship() external {

        require(proposedGovernor == _msgSender(), "not-the-proposed-governor");
        emit UpdatedGovernor(governor, proposedGovernor);
        governor = proposedGovernor;
        proposedGovernor = address(0);
    }
}// MIT

pragma solidity 0.8.3;

interface IAddressList {

    function add(address a) external returns (bool);


    function addValue(address a, uint256 v) external returns (bool);


    function addMulti(address[] calldata addrs) external returns (uint256);


    function addValueMulti(address[] calldata addrs, uint256[] calldata values) external returns (uint256);


    function remove(address a) external returns (bool);


    function removeMulti(address[] calldata addrs) external returns (uint256);


    function get(address a) external view returns (uint256);


    function contains(address a) external view returns (bool);


    function at(uint256 index) external view returns (address, uint256);


    function length() external view returns (uint256);

}// MIT

pragma solidity 0.8.3;

interface IAddressListFactory {

    function ours(address a) external view returns (bool);


    function listCount() external view returns (uint256);


    function listAt(uint256 idx) external view returns (address);


    function createList() external returns (address listaddr);

}// MIT

pragma solidity 0.8.3;



interface ISwapManager {

    event OracleCreated(address indexed _sender, address indexed _newOracle, uint256 _period);

    function N_DEX() external view returns (uint256);


    function ROUTERS(uint256 i) external view returns (IUniswapV2Router02);


    function bestOutputFixedInput(
        address _from,
        address _to,
        uint256 _amountIn
    )
        external
        view
        returns (
            address[] memory path,
            uint256 amountOut,
            uint256 rIdx
        );


    function bestPathFixedInput(
        address _from,
        address _to,
        uint256 _amountIn,
        uint256 _i
    ) external view returns (address[] memory path, uint256 amountOut);


    function bestInputFixedOutput(
        address _from,
        address _to,
        uint256 _amountOut
    )
        external
        view
        returns (
            address[] memory path,
            uint256 amountIn,
            uint256 rIdx
        );


    function bestPathFixedOutput(
        address _from,
        address _to,
        uint256 _amountOut,
        uint256 _i
    ) external view returns (address[] memory path, uint256 amountIn);


    function safeGetAmountsOut(
        uint256 _amountIn,
        address[] memory _path,
        uint256 _i
    ) external view returns (uint256[] memory result);


    function unsafeGetAmountsOut(
        uint256 _amountIn,
        address[] memory _path,
        uint256 _i
    ) external view returns (uint256[] memory result);


    function safeGetAmountsIn(
        uint256 _amountOut,
        address[] memory _path,
        uint256 _i
    ) external view returns (uint256[] memory result);


    function unsafeGetAmountsIn(
        uint256 _amountOut,
        address[] memory _path,
        uint256 _i
    ) external view returns (uint256[] memory result);


    function comparePathsFixedInput(
        address[] memory pathA,
        address[] memory pathB,
        uint256 _amountIn,
        uint256 _i
    ) external view returns (address[] memory path, uint256 amountOut);


    function comparePathsFixedOutput(
        address[] memory pathA,
        address[] memory pathB,
        uint256 _amountOut,
        uint256 _i
    ) external view returns (address[] memory path, uint256 amountIn);


    function ours(address a) external view returns (bool);


    function oracleCount() external view returns (uint256);


    function oracleAt(uint256 idx) external view returns (address);


    function getOracle(
        address _tokenA,
        address _tokenB,
        uint256 _period,
        uint256 _i
    ) external view returns (address);


    function createOrUpdateOracle(
        address _tokenA,
        address _tokenB,
        uint256 _period,
        uint256 _i
    ) external returns (address oracleAddr);


    function consultForFree(
        address _from,
        address _to,
        uint256 _amountIn,
        uint256 _period,
        uint256 _i
    ) external view returns (uint256 amountOut, uint256 lastUpdatedAt);


    function consult(
        address _from,
        address _to,
        uint256 _amountIn,
        uint256 _period,
        uint256 _i
    )
        external
        returns (
            uint256 amountOut,
            uint256 lastUpdatedAt,
            bool updated
        );


    function updateOracles() external returns (uint256 updated, uint256 expected);


    function updateOracles(address[] memory _oracleAddrs) external returns (uint256 updated, uint256 expected);

}// MIT

pragma solidity 0.8.3;

interface IVesperPool is IERC20 {

    function deposit() external payable;


    function deposit(uint256 _share) external;


    function multiTransfer(address[] memory _recipients, uint256[] memory _amounts) external returns (bool);


    function excessDebt(address _strategy) external view returns (uint256);


    function permit(
        address,
        address,
        uint256,
        uint256,
        uint8,
        bytes32,
        bytes32
    ) external;


    function poolRewards() external returns (address);


    function reportEarning(
        uint256 _profit,
        uint256 _loss,
        uint256 _payback
    ) external;


    function reportLoss(uint256 _loss) external;


    function resetApproval() external;


    function sweepERC20(address _fromToken) external;


    function withdraw(uint256 _amount) external;


    function withdrawETH(uint256 _amount) external;


    function whitelistedWithdraw(uint256 _amount) external;


    function governor() external view returns (address);


    function keepers() external view returns (IAddressList);


    function maintainers() external view returns (IAddressList);


    function feeCollector() external view returns (address);


    function pricePerShare() external view returns (uint256);


    function strategy(address _strategy)
        external
        view
        returns (
            bool _active,
            uint256 _interestFee,
            uint256 _debtRate,
            uint256 _lastRebalance,
            uint256 _totalDebt,
            uint256 _totalLoss,
            uint256 _totalProfit,
            uint256 _debtRatio
        );


    function stopEverything() external view returns (bool);


    function token() external view returns (IERC20);


    function tokensHere() external view returns (uint256);


    function totalDebtOf(address _strategy) external view returns (uint256);


    function totalValue() external view returns (uint256);


    function withdrawFee() external view returns (uint256);

}// MIT
pragma solidity 0.8.3;

library Errors {

    string public constant INVALID_COLLATERAL_AMOUNT = "1"; // Collateral must be greater than 0
    string public constant INVALID_SHARE_AMOUNT = "2"; // Share must be greater than 0
    string public constant INVALID_INPUT_LENGTH = "3"; // Input array length must be greater than 0
    string public constant INPUT_LENGTH_MISMATCH = "4"; // Input array length mismatch with another array length
    string public constant NOT_WHITELISTED_ADDRESS = "5"; // Caller is not whitelisted to withdraw without fee
    string public constant MULTI_TRANSFER_FAILED = "6"; // Multi transfer of tokens has failed
    string public constant FEE_COLLECTOR_NOT_SET = "7"; // Fee Collector is not set
    string public constant NOT_ALLOWED_TO_SWEEP = "8"; // Token is not allowed to sweep
    string public constant INSUFFICIENT_BALANCE = "9"; // Insufficient balance to performs operations to follow
    string public constant INPUT_ADDRESS_IS_ZERO = "10"; // Input address is zero
    string public constant FEE_LIMIT_REACHED = "11"; // Fee must be less than MAX_BPS
    string public constant ALREADY_INITIALIZED = "12"; // Data structure, contract, or logic already initialized and can not be called again
    string public constant ADD_IN_LIST_FAILED = "13"; // Cannot add address in address list
    string public constant REMOVE_FROM_LIST_FAILED = "14"; // Cannot remove address from address list
    string public constant STRATEGY_IS_ACTIVE = "15"; // Strategy is already active, an inactive strategy is required
    string public constant STRATEGY_IS_NOT_ACTIVE = "16"; // Strategy is not active, an active strategy is required
    string public constant INVALID_STRATEGY = "17"; // Given strategy is not a strategy of this pool
    string public constant DEBT_RATIO_LIMIT_REACHED = "18"; // Debt ratio limit reached. It must be less than MAX_BPS
    string public constant TOTAL_DEBT_IS_NOT_ZERO = "19"; // Strategy total debt must be 0
    string public constant LOSS_TOO_HIGH = "20"; // Strategy reported loss must be less than current debt
}// MIT

pragma solidity 0.8.3;

contract Batchable {

    function _getRevertMsg(bytes memory _returnData) internal pure returns (string memory) {

        if (_returnData.length < 68) return "Transaction reverted silently";

        assembly {
            _returnData := add(_returnData, 0x04)
        }
        return abi.decode(_returnData, (string)); // All that remains is the revert string
    }

    function batch(bytes[] calldata calls, bool revertOnFail) external payable {

        for (uint256 i = 0; i < calls.length; i++) {
            (bool success, bytes memory result) = address(this).delegatecall(calls[i]);
            if (!success && revertOnFail) {
                revert(_getRevertMsg(result));
            }
        }
    }
}// MIT

pragma solidity 0.8.3;


abstract contract UsingSwapManager is Governed {
    using SafeERC20 for IERC20;

    address weth; // Native token
    ISwapManager public swapManager;
    uint256 public oraclePeriod = 3600; // 1h;
    uint256 public oracleRouterIdx = 0; // Uniswap V2;
    uint256 public swapSlippage = 1000; // 10%

    event UpdatedSwapManager(address indexed oldSwapManager, address indexed newSwapManager);
    event UpdatedSwapSlippage(uint256 oldSwapSlippage, uint256 newSwapSlippage);
    event UpdatedOracleConfig(uint256 oldPeriod, uint256 newPeriod, uint256 oldRouterIdx, uint256 newRouterIdx);

    constructor(address _weth, ISwapManager _swapManager) {
        require(address(_weth) != address(0), "weth-is-null");
        require(address(_swapManager) != address(0), "swap-manager-is-null");

        weth = _weth;
        swapManager = _swapManager;
    }


    function updateSwapManager(address _swapManager) external onlyGovernor {
        require(_swapManager != address(0), "sm-address-is-zero");
        require(_swapManager != address(swapManager), "sm-is-same");
        emit UpdatedSwapManager(address(swapManager), _swapManager);
        swapManager = ISwapManager(_swapManager);
    }

    function updateSwapSlippage(uint256 _newSwapSlippage) external onlyGovernor {
        require(_newSwapSlippage <= 10000, "invalid-slippage-value");
        emit UpdatedSwapSlippage(swapSlippage, _newSwapSlippage);
        swapSlippage = _newSwapSlippage;
    }

    function updateOracleConfig(uint256 _newPeriod, uint256 _newRouterIdx) external onlyGovernor {
        require(_newRouterIdx < swapManager.N_DEX(), "invalid-router-index");
        if (_newPeriod == 0) _newPeriod = oraclePeriod;
        require(_newPeriod > 59, "invalid-oracle-period");
        emit UpdatedOracleConfig(oraclePeriod, _newPeriod, oracleRouterIdx, _newRouterIdx);
        oraclePeriod = _newPeriod;
        oracleRouterIdx = _newRouterIdx;
    }


    function _safeSwap(
        address _tokenIn,
        address _tokenOut,
        uint256 _amountIn,
        uint256 _minAmountOut,
        address _to
    ) internal {
        (address[] memory path, uint256 amountOut, uint256 rIdx) =
            swapManager.bestOutputFixedInput(_tokenIn, _tokenOut, _amountIn);
        if (_minAmountOut == 0) _minAmountOut = 1;
        if (amountOut != 0) {
            swapManager.ROUTERS(rIdx).swapExactTokensForTokens(_amountIn, _minAmountOut, path, _to, block.timestamp);
        }
    }

    function _calcAmtOutAfterSlippage(uint256 _amount, uint256 _slippage) internal pure returns (uint256) {
        return (_amount * (10000 - _slippage)) / (10000);
    }

    function _getOracleRate(address[] memory path, uint256 _amountIn) internal returns (uint256 amountOut) {
        require(path.length > 1, "invalid-oracle-path");
        amountOut = _amountIn;
        bool isValid;
        for (uint256 i = 0; i < path.length - 1; i++) {
            (amountOut, isValid) = _consultOracle(path[i], path[i + 1], amountOut);
            require(isValid, "invalid-oracle-rate");
        }
    }

    function _simpleOraclePath(address _from, address _to) internal view returns (address[] memory path) {
        if (_from == weth || _to == weth) {
            path = new address[](2);
            path[0] = _from;
            path[1] = _to;
        } else {
            path = new address[](3);
            path[0] = _from;
            path[1] = weth;
            path[2] = _to;
        }
    }

    function _consultOracle(
        address _from,
        address _to,
        uint256 _amt
    ) internal returns (uint256, bool) {
        (uint256 rate, uint256 lastUpdate, ) = swapManager.consult(_from, _to, _amt, oraclePeriod, oracleRouterIdx);
        if ((lastUpdate > (block.timestamp - oraclePeriod)) && (rate != 0)) return (rate, true);
        return (0, false);
    }

    function _doInfinityApprovalIfNeeded(IERC20 _asset, uint256 _amountToSwap) internal {
        for (uint256 i = 0; i < swapManager.N_DEX(); i++) {
            if (IERC20(_asset).allowance(address(this), address(swapManager.ROUTERS(i))) < _amountToSwap) {
                IERC20(_asset).safeApprove(address(swapManager.ROUTERS(i)), type(uint256).max);
            }
        }
    }
}// MIT

pragma solidity 0.8.3;


contract BuyBack is UsingSwapManager, Batchable {

    using SafeERC20 for IERC20;

    IERC20 public vsp;
    IVesperPool public vVSP; // vVSP pool will received buyed back VSPs
    address public keepers; // sol-address-list address which contains addresses of keepers

    event MigratedAsset(IERC20 asset, uint256 amount);

    constructor(
        address _governor,
        address _weth,
        IVesperPool _vVSP,
        IAddressListFactory _listFactory,
        ISwapManager _swapManager
    ) UsingSwapManager(_weth, _swapManager) {
        require(address(_vVSP) != address(0), "vvsp-is-null");
        require(address(_listFactory) != address(0), "address-list-factory-is-null");

        governor = _governor;
        vVSP = _vVSP;
        vsp = vVSP.token();
        keepers = _listFactory.createList();
        require(IAddressList(keepers).add(_msgSender()), Errors.ADD_IN_LIST_FAILED);
    }

    modifier onlyKeeper() {

        require(IAddressList(keepers).contains(_msgSender()), "not-a-keeper");
        _;
    }


    function migrateAssets(address[] memory _assets, address _to) external onlyGovernor {

        require(_assets.length > 0, "assets-list-is-empty");
        require(_to != address(this), "new-contract-is-invalid");

        for (uint256 i = 0; i < _assets.length; ++i) {
            IERC20 _asset = IERC20(_assets[i]);
            uint256 _balance = _asset.balanceOf(address(this));
            _asset.safeTransfer(_to, _balance);
            emit MigratedAsset(_asset, _balance);
        }
    }


    function swapForVspAndTransferToVVSP(address _tokenIn, uint256 _amountIn) external onlyKeeper {

        if (_amountIn > 0) {
            uint256 _minAmtOut =
                (swapSlippage != 10000)
                    ? _calcAmtOutAfterSlippage(
                        _getOracleRate(_simpleOraclePath(_tokenIn, address(vsp)), _amountIn),
                        swapSlippage
                    )
                    : 1;
            _safeSwap(_tokenIn, address(vsp), _amountIn, _minAmtOut, address(vVSP));
        }
    }

    function depositAndUnwrap(IVesperPool _vPool, uint256 _amount) external onlyKeeper {

        _vPool.transferFrom(_msgSender(), address(this), _amount);
        _vPool.withdraw(_amount);
    }

    function unwrap(IVesperPool _vPool, uint256 _amount) public onlyKeeper {

        _vPool.withdraw(_amount);
    }

    function unwrapAll(IVesperPool _vPool) external onlyKeeper {

        unwrap(_vPool, _vPool.balanceOf(address(this)));
    }

    function transferVspToVVSP(uint256 _amount) public onlyKeeper {

        vsp.safeTransfer(address(vVSP), _amount);
    }

    function transferAllVspToVVSP() external onlyKeeper {

        transferVspToVVSP(vsp.balanceOf(address(this)));
    }

    function doInfinityApproval(IERC20 _unwrapped) external onlyKeeper {

        _doInfinityApprovalIfNeeded(_unwrapped, type(uint256).max);
    }

    function addInKeepersList(address _addressToAdd) external onlyKeeper {

        require(IAddressList(keepers).add(_addressToAdd), Errors.ADD_IN_LIST_FAILED);
    }

    function removeFromKeepersList(address _addressToRemove) external onlyKeeper {

        require(IAddressList(keepers).remove(_addressToRemove), Errors.REMOVE_FROM_LIST_FAILED);
    }

}