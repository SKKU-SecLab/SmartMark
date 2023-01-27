
pragma solidity 0.8.7;

interface IERC20 {

	function approve(address spender, uint256 amount) external returns (bool);

	function allowance(address owner, address spender) external returns (uint256);

	function transfer(address to, uint256 value) external returns (bool);

	function balanceOf(address owner) external view returns (uint256);

	function totalSupply() external view returns (uint256);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

}

library SafeERC20 {

	using Address for address;

	function safeTransfer(IERC20 token, address to, uint256 value) internal {

		_callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
	}

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

	function safeApprove(IERC20 token, address spender, uint256 value) internal {

		require((value == 0) || (token.allowance(address(this), spender) == 0),
			"SafeERC20: approve from non-zero to non-zero allowance"
		);
		_callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
	}

	function _callOptionalReturn(IERC20 token, bytes memory data) private {


		bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
		if (returndata.length > 0) { // Return data is optional
			require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
		}
	}
}

library Address {

	function isContract(address account) internal view returns (bool) {


		uint256 size;
		assembly { size := extcodesize(account) }
		return size > 0;
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

interface IUniswapV3Pair {

	function flash(
        address recipient,
        uint256 amount0,
        uint256 amount1,
        bytes calldata data
    ) external;

}

struct FundManagement {
	address sender;
	bool fromInternalBalance;
	address payable recipient;
	bool toInternalBalance;
}

enum SwapKind { GIVEN_IN, GIVEN_OUT }

struct SingleSwap {
	bytes32 poolId;
	SwapKind kind;
	address assetIn;
	address assetOut;
	uint256 amount;
	bytes userData;
}

interface IVault {

    function getPoolTokens(bytes32 poolD) external view returns (address[] memory, uint256[] memory);

	function swap(SingleSwap memory singleSwap, FundManagement memory funds, uint256 limit, uint256 deadline) external payable returns (uint256);

}

interface WAToken {

	function staticToDynamicAmount(uint256) external view returns (uint256);

	function deposit(address, uint256, uint16, bool) external returns (uint256);

	function withdraw(address, uint256, bool) external returns (uint256, uint256);

}

interface LinearPool {

	function getPoolId() external view returns (bytes32);

	function getSwapFeePercentage() external view returns (uint256);

	function getScalingFactors() external view returns (uint256[] memory);


	function getMainToken() external view returns (address);

	function getWrappedToken() external view returns (address);

	function getBptIndex() external view returns (uint256);

	function getMainIndex() external view returns (uint256);

	function getWrappedIndex() external view returns (uint256);

	function getRate() external view returns (uint256);

	function getWrappedTokenRate() external view returns (uint256);

	function getTargets() external view returns (uint256 lowerTarget, uint256 upperTarget);

}

contract Rebalancer {

    using SafeERC20 for IERC20;

    uint256 private constant MAX_UINT = 2 ** 256 - 1;

    IVault constant private VAULT = IVault(0xBA12222222228d8Ba445958a75a0704d566BF2C8);

    IUniswapV3Pair constant private DAI_POOL = IUniswapV3Pair(0x5777d92f208679DB4b9778590Fa3CAB3aC9e2168);
	IUniswapV3Pair constant private USDC_USDT_POOL = IUniswapV3Pair(0x3416cF6C708Da44DB2624D63ea0AAef7113527C6);

	address constant private DAI = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
	address constant private USDC = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
	address constant private USDT = 0xdAC17F958D2ee523a2206206994597C13D831ec7;

	address constant private WDAI = 0x02d60b84491589974263d922D9cC7a3152618Ef6;
	address constant private WUSDC = 0xd093fA4Fb80D09bB30817FDcd442d4d02eD3E5de;
	address constant private WUSDT = 0xf8Fd466F12e236f4c96F7Cce6c79EAdB819abF58;

    uint256 constant private ONE = 10**18;

    address public owner;

	constructor(address _owner) {
		IERC20(DAI).approve(address(WDAI), MAX_UINT);
		IERC20(USDC).approve(address(WUSDC), MAX_UINT);
		IERC20(USDT).safeApprove(address(WUSDT), MAX_UINT);

		IERC20(DAI).approve(address(VAULT), MAX_UINT);
		IERC20(USDC).approve(address(VAULT), MAX_UINT);
		IERC20(USDT).safeApprove(address(VAULT), MAX_UINT);

		IERC20(WDAI).approve(address(VAULT), MAX_UINT);
		IERC20(WUSDC).approve(address(VAULT), MAX_UINT);
		IERC20(WUSDT).approve(address(VAULT), MAX_UINT);

        owner = _owner;
	}

    function setNewOwner(address _newOwner) external {

        require( msg.sender == owner);
        owner = _newOwner;
    }

    function balanceOf(IERC20 _token) public view returns (uint){

        return _token.balanceOf(address(this));
    }

    function sweep(address _to) external {

        require( msg.sender == owner);
        IERC20(DAI).safeTransfer(_to, IERC20(DAI).balanceOf(address(this)));
        IERC20(USDC).safeTransfer(_to, IERC20(USDC).balanceOf(address(this)));
        IERC20(USDT).safeTransfer(_to, IERC20(USDT).balanceOf(address(this)));
    }

    function rebalance(LinearPool _pool, uint256 _desiredBalance) public payable {

        (SingleSwap memory _swap, uint256 _amountInNeededForSwap) = getSwapAndAmountInNeeded(_pool, _desiredBalance);
        address _mainToken = _swap.kind == SwapKind.GIVEN_IN ? _swap.assetIn : _swap.assetOut;

        IUniswapV3Pair _uniswapPool = _mainToken == DAI ? DAI_POOL : USDC_USDT_POOL;
        uint256 _amountNeededForFlashLoan = _swap.kind == SwapKind.GIVEN_IN ? _amountInNeededForSwap : WAToken(address(_swap.assetIn)).staticToDynamicAmount(_amountInNeededForSwap);
        bytes memory _swapData = abi.encode(_swap, _amountNeededForFlashLoan, _amountInNeededForSwap, msg.sender);
        if (_mainToken == USDT) _uniswapPool.flash(address(this), 0, _amountNeededForFlashLoan, _swapData);
        else _uniswapPool.flash(address(this), _amountNeededForFlashLoan, 0, _swapData);
    }

    function getSwapAndAmountInNeeded(LinearPool _pool, uint256 _desiredBalance) public view returns (SingleSwap memory _swap, uint256 _amountInNeededForSwap) {

        LinearMath.Params memory _params = LinearMath.Params({
            fee: _pool.getSwapFeePercentage(),
            lowerTarget: 0,
            upperTarget: 0
        });
        (_params.lowerTarget, _params.upperTarget) = _pool.getTargets();
        uint256[] memory _scalingFactors = _pool.getScalingFactors();
        uint256 _mainTokenIndex = _pool.getMainIndex();
        (address[] memory _tokenAddresses, uint256[] memory _tokenBalances) = VAULT.getPoolTokens(_pool.getPoolId());
        uint256 _mainTokenBalance = _tokenBalances[_mainTokenIndex];

        if (_desiredBalance == 0) {
			uint256 _scaledUpperTarget = _params.upperTarget * ONE / _scalingFactors[_mainTokenIndex];
			uint256 _scaledLowerTarget = _params.upperTarget * ONE / _scalingFactors[_mainTokenIndex];

            if (_mainTokenBalance > _scaledUpperTarget) {
                _desiredBalance = _scaledUpperTarget;
            } else if (_mainTokenBalance < _scaledLowerTarget) {
                _desiredBalance = _scaledLowerTarget;
            } else {
				revert("Already in range and no desired balance specified");
			}
        }

        uint256 _swapAmount = _mainTokenBalance < _desiredBalance ? _desiredBalance - _mainTokenBalance : _mainTokenBalance - _desiredBalance;
        _amountInNeededForSwap = _mainTokenBalance < _desiredBalance ? _swapAmount : getWrappedInForMainOut(_swapAmount, _mainTokenBalance * _scalingFactors[_mainTokenIndex] / ONE, _scalingFactors[_mainTokenIndex], _scalingFactors[_pool.getWrappedIndex()], _params);
        _swap = SingleSwap(
			_pool.getPoolId(),
			_mainTokenBalance > _desiredBalance ? SwapKind.GIVEN_OUT : SwapKind.GIVEN_IN,
			_mainTokenBalance > _desiredBalance ? _tokenAddresses[_pool.getWrappedIndex()] : _tokenAddresses[_mainTokenIndex],
			_mainTokenBalance > _desiredBalance ? _tokenAddresses[_mainTokenIndex] : _tokenAddresses[_pool.getWrappedIndex()],
			_swapAmount,
			new bytes(0)
		);
        return (_swap, _amountInNeededForSwap);
    }

	function uniswapV3FlashCallback(uint256, uint256, bytes calldata _data) external payable {

		(SingleSwap memory _swap, uint256 _initialAmount, uint256 _requiredBalance, address _msgSender) = abi.decode(_data, (SingleSwap, uint256, uint256, address));
		address mainToken = address(_swap.kind == SwapKind.GIVEN_IN ? _swap.assetIn : _swap.assetOut);
		require(msg.sender == address(DAI_POOL) || msg.sender == address(USDC_USDT_POOL), "bad 3. no");
		require(IERC20(mainToken).balanceOf(address(this)) >= _initialAmount, "Flash loan didnt do it");

		doSwap(_swap, _initialAmount, _requiredBalance);

		uint256 _repayment = _initialAmount + (_initialAmount / 10000) + 1;

        uint256 _balance = IERC20(mainToken).balanceOf(address(this));
        if (_balance < _repayment) {
            uint256 _deficit = _repayment - _balance;
            IERC20(mainToken).safeTransferFrom(_msgSender, address(this), _deficit);
        }

		IERC20(mainToken).safeTransfer(msg.sender, _repayment);
	}

    function getWrappedInForMainOut(uint256 _mainOut, uint256 _mainBalance, uint256 _mainScalingFactor, uint256 _wrappedScalingFactor, LinearMath.Params memory _params) public pure returns (uint256) {

        _mainOut = _mainOut * _mainScalingFactor / ONE;

        uint256 amountIn = LinearMath._calcWrappedInPerMainOut(_mainOut, _mainBalance, _params);

        return (((amountIn * ONE) - 1) /  _wrappedScalingFactor) + 1;
    }

    function getWrappedOutForMainIn(uint256 _mainIn, uint256 _mainBalance, uint256 _mainScalingFactor, uint256 _wrappedScalingFactor, LinearMath.Params memory _params) public pure returns (uint256) {

        _mainIn = _mainIn * _mainScalingFactor / ONE;

        uint256 amountOut = LinearMath._calcWrappedOutPerMainIn(_mainIn, _mainBalance, _params);

        return amountOut * ONE / _wrappedScalingFactor;
    }

    function estimateDeficitRequirement(LinearPool _pool, uint256 _desiredBalance) external view returns (uint256) {

        (SingleSwap memory _swap, uint256 _amountInNeededForSwap) = getSwapAndAmountInNeeded(_pool, _desiredBalance);

        uint256 _amountNeededForFlashLoan = _swap.kind == SwapKind.GIVEN_IN ? _amountInNeededForSwap : WAToken(address(_swap.assetIn)).staticToDynamicAmount(_amountInNeededForSwap);
		_amountNeededForFlashLoan += (_amountNeededForFlashLoan / 10000) + 1;

		uint256 _amountOut =  _swap.amount;
		if (_swap.kind == SwapKind.GIVEN_IN) {
			LinearMath.Params memory _params = LinearMath.Params({
				fee: _pool.getSwapFeePercentage(),
				lowerTarget: 0,
				upperTarget: 0
			});
			(_params.lowerTarget, _params.upperTarget) = _pool.getTargets();
			uint256[] memory _scalingFactors = _pool.getScalingFactors();
			uint256 _mainTokenIndex = _pool.getMainIndex();
			uint256 _wrappedTokenIndex = _pool.getWrappedIndex();
			(, uint256[] memory _tokenBalances) = VAULT.getPoolTokens(_pool.getPoolId());
			uint256 _mainTokenBalance = _tokenBalances[_mainTokenIndex];
			_amountOut = getWrappedOutForMainIn(_swap.amount, _mainTokenBalance, _scalingFactors[_mainTokenIndex], _scalingFactors[_wrappedTokenIndex], _params);
			_amountOut = WAToken(address(_swap.assetOut)).staticToDynamicAmount(_amountOut);
		}

		return _amountOut >= _amountNeededForFlashLoan ? 0 : _amountNeededForFlashLoan - _amountOut;
    }

    function doSwap(SingleSwap memory swap, uint256 _initialAmount, uint256 _requiredBalance) private {

		uint256 limit = swap.kind == SwapKind.GIVEN_IN ? 0 : MAX_UINT;
		FundManagement memory fundManagement = FundManagement(address(this), false, payable(address(this)), false);
		if (swap.kind == SwapKind.GIVEN_OUT) wrapToken(address(swap.assetIn), _initialAmount);
		require(IERC20(swap.assetIn).balanceOf(address(this)) >= _requiredBalance, "Not enough asset in balance");
		VAULT.swap(swap, fundManagement, limit, block.timestamp);
		if (swap.kind == SwapKind.GIVEN_IN) unwrapToken(address(swap.assetOut), IERC20(swap.assetOut).balanceOf(address(this)));
	}

	function wrapToken(address _wrappedToken, uint256 _amount) private {

		WAToken(_wrappedToken).deposit(address(this), _amount, 0, true);
	}

	function unwrapToken(address _wrappedToken, uint256 _amount) private {

		WAToken(_wrappedToken).withdraw(address(this), _amount, true);
	}

	receive() payable external {}
}



library LinearMath {

    using FixedPoint for uint256;



    struct Params {
        uint256 fee;
        uint256 lowerTarget;
        uint256 upperTarget;
    }

    function _calcWrappedOutPerMainIn(
        uint256 mainIn,
        uint256 mainBalance,
        Params memory params
    ) internal pure returns (uint256) {


        uint256 previousNominalMain = _toNominal(mainBalance, params);
        uint256 afterNominalMain = _toNominal(mainBalance.add(mainIn), params);
        return afterNominalMain.sub(previousNominalMain);
    }

    function _calcWrappedInPerMainOut(
        uint256 mainOut,
        uint256 mainBalance,
        Params memory params
    ) internal pure returns (uint256) {


        uint256 previousNominalMain = _toNominal(mainBalance, params);
        uint256 afterNominalMain = _toNominal(mainBalance.sub(mainOut), params);
        return previousNominalMain.sub(afterNominalMain);
    }

    function _toNominal(uint256 real, Params memory params) internal pure returns (uint256) {


        if (real < params.lowerTarget) {
            uint256 fees = (params.lowerTarget - real).mulDown(params.fee);
            return real.sub(fees);
        } else if (real <= params.upperTarget) {
            return real;
        } else {
            uint256 fees = (real - params.upperTarget).mulDown(params.fee);
            return real.sub(fees);
        }
    }

    function _fromNominal(uint256 nominal, Params memory params) internal pure returns (uint256) {


        if (nominal < params.lowerTarget) {
            return (nominal.add(params.fee.mulDown(params.lowerTarget))).divDown(FixedPoint.ONE.add(params.fee));
        } else if (nominal <= params.upperTarget) {
            return nominal;
        } else {
            return (nominal.sub(params.fee.mulDown(params.upperTarget)).divDown(FixedPoint.ONE.sub(params.fee)));
        }
    }
}


library FixedPoint {

    uint256 internal constant ONE = 1e18; // 18 decimal places
    uint256 internal constant MAX_POW_RELATIVE_ERROR = 10000; // 10^(-14)

    uint256 internal constant MIN_POW_BASE_FREE_EXPONENT = 0.7e18;

    function add(uint256 a, uint256 b) internal pure returns (uint256) {


        uint256 c = a + b;
        _require(c >= a, Errors.ADD_OVERFLOW);
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {


        _require(b <= a, Errors.SUB_OVERFLOW);
        uint256 c = a - b;
        return c;
    }

    function mulDown(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 product = a * b;
        _require(a == 0 || product / a == b, Errors.MUL_OVERFLOW);

        return product / ONE;
    }

    function mulUp(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 product = a * b;
        _require(a == 0 || product / a == b, Errors.MUL_OVERFLOW);

        if (product == 0) {
            return 0;
        } else {

            return ((product - 1) / ONE) + 1;
        }
    }

    function divDown(uint256 a, uint256 b) internal pure returns (uint256) {

        _require(b != 0, Errors.ZERO_DIVISION);

        if (a == 0) {
            return 0;
        } else {
            uint256 aInflated = a * ONE;
            _require(aInflated / a == ONE, Errors.DIV_INTERNAL); // mul overflow

            return aInflated / b;
        }
    }

    function divUp(uint256 a, uint256 b) internal pure returns (uint256) {

        _require(b != 0, Errors.ZERO_DIVISION);

        if (a == 0) {
            return 0;
        } else {
            uint256 aInflated = a * ONE;
            _require(aInflated / a == ONE, Errors.DIV_INTERNAL); // mul overflow


            return ((aInflated - 1) / b) + 1;
        }
    }

    function powDown(uint256 x, uint256 y) internal pure returns (uint256) {

        uint256 raw = LogExpMath.pow(x, y);
        uint256 maxError = add(mulUp(raw, MAX_POW_RELATIVE_ERROR), 1);

        if (raw < maxError) {
            return 0;
        } else {
            return sub(raw, maxError);
        }
    }

    function powUp(uint256 x, uint256 y) internal pure returns (uint256) {

        uint256 raw = LogExpMath.pow(x, y);
        uint256 maxError = add(mulUp(raw, MAX_POW_RELATIVE_ERROR), 1);

        return add(raw, maxError);
    }

    function complement(uint256 x) internal pure returns (uint256) {

        return (x < ONE) ? (ONE - x) : 0;
    }
}


library Math {

    function abs(int256 a) internal pure returns (uint256) {

        return a > 0 ? uint256(a) : uint256(-a);
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        _require(c >= a, Errors.ADD_OVERFLOW);
        return c;
    }

    function add(int256 a, int256 b) internal pure returns (int256) {

        int256 c = a + b;
        _require((b >= 0 && c >= a) || (b < 0 && c < a), Errors.ADD_OVERFLOW);
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        _require(b <= a, Errors.SUB_OVERFLOW);
        uint256 c = a - b;
        return c;
    }

    function sub(int256 a, int256 b) internal pure returns (int256) {

        int256 c = a - b;
        _require((b >= 0 && c <= a) || (b < 0 && c > a), Errors.SUB_OVERFLOW);
        return c;
    }

    function max(uint256 a, uint256 b) internal pure returns (uint256) {

        return a >= b ? a : b;
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {

        return a < b ? a : b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a * b;
        _require(a == 0 || c / a == b, Errors.MUL_OVERFLOW);
        return c;
    }

    function div(
        uint256 a,
        uint256 b,
        bool roundUp
    ) internal pure returns (uint256) {

        return roundUp ? divUp(a, b) : divDown(a, b);
    }

    function divDown(uint256 a, uint256 b) internal pure returns (uint256) {

        _require(b != 0, Errors.ZERO_DIVISION);
        return a / b;
    }

    function divUp(uint256 a, uint256 b) internal pure returns (uint256) {

        _require(b != 0, Errors.ZERO_DIVISION);

        if (a == 0) {
            return 0;
        } else {
            return 1 + (a - 1) / b;
        }
    }
}


function _require(bool condition, uint256 errorCode) pure {
    if (!condition) _revert(errorCode);
}

function _revert(uint256 errorCode) pure {
    assembly {

        let units := add(mod(errorCode, 10), 0x30)

        errorCode := div(errorCode, 10)
        let tenths := add(mod(errorCode, 10), 0x30)

        errorCode := div(errorCode, 10)
        let hundreds := add(mod(errorCode, 10), 0x30)


        let revertReason := shl(200, add(0x42414c23000000, add(add(units, shl(8, tenths)), shl(16, hundreds))))


        mstore(0x0, 0x08c379a000000000000000000000000000000000000000000000000000000000)
        mstore(0x04, 0x0000000000000000000000000000000000000000000000000000000000000020)
        mstore(0x24, 7)
        mstore(0x44, revertReason)

        revert(0, 100)
    }
}

library Errors {

    uint256 internal constant ADD_OVERFLOW = 0;
    uint256 internal constant SUB_OVERFLOW = 1;
    uint256 internal constant SUB_UNDERFLOW = 2;
    uint256 internal constant MUL_OVERFLOW = 3;
    uint256 internal constant ZERO_DIVISION = 4;
    uint256 internal constant DIV_INTERNAL = 5;
    uint256 internal constant X_OUT_OF_BOUNDS = 6;
    uint256 internal constant Y_OUT_OF_BOUNDS = 7;
    uint256 internal constant PRODUCT_OUT_OF_BOUNDS = 8;
    uint256 internal constant INVALID_EXPONENT = 9;

    uint256 internal constant OUT_OF_BOUNDS = 100;
    uint256 internal constant UNSORTED_ARRAY = 101;
    uint256 internal constant UNSORTED_TOKENS = 102;
    uint256 internal constant INPUT_LENGTH_MISMATCH = 103;
    uint256 internal constant ZERO_TOKEN = 104;

    uint256 internal constant MIN_TOKENS = 200;
    uint256 internal constant MAX_TOKENS = 201;
    uint256 internal constant MAX_SWAP_FEE_PERCENTAGE = 202;
    uint256 internal constant MIN_SWAP_FEE_PERCENTAGE = 203;
    uint256 internal constant MINIMUM_BPT = 204;
    uint256 internal constant CALLER_NOT_VAULT = 205;
    uint256 internal constant UNINITIALIZED = 206;
    uint256 internal constant BPT_IN_MAX_AMOUNT = 207;
    uint256 internal constant BPT_OUT_MIN_AMOUNT = 208;
    uint256 internal constant EXPIRED_PERMIT = 209;
    uint256 internal constant NOT_TWO_TOKENS = 210;

    uint256 internal constant MIN_AMP = 300;
    uint256 internal constant MAX_AMP = 301;
    uint256 internal constant MIN_WEIGHT = 302;
    uint256 internal constant MAX_STABLE_TOKENS = 303;
    uint256 internal constant MAX_IN_RATIO = 304;
    uint256 internal constant MAX_OUT_RATIO = 305;
    uint256 internal constant MIN_BPT_IN_FOR_TOKEN_OUT = 306;
    uint256 internal constant MAX_OUT_BPT_FOR_TOKEN_IN = 307;
    uint256 internal constant NORMALIZED_WEIGHT_INVARIANT = 308;
    uint256 internal constant INVALID_TOKEN = 309;
    uint256 internal constant UNHANDLED_JOIN_KIND = 310;
    uint256 internal constant ZERO_INVARIANT = 311;
    uint256 internal constant ORACLE_INVALID_SECONDS_QUERY = 312;
    uint256 internal constant ORACLE_NOT_INITIALIZED = 313;
    uint256 internal constant ORACLE_QUERY_TOO_OLD = 314;
    uint256 internal constant ORACLE_INVALID_INDEX = 315;
    uint256 internal constant ORACLE_BAD_SECS = 316;
    uint256 internal constant AMP_END_TIME_TOO_CLOSE = 317;
    uint256 internal constant AMP_ONGOING_UPDATE = 318;
    uint256 internal constant AMP_RATE_TOO_HIGH = 319;
    uint256 internal constant AMP_NO_ONGOING_UPDATE = 320;
    uint256 internal constant STABLE_INVARIANT_DIDNT_CONVERGE = 321;
    uint256 internal constant STABLE_GET_BALANCE_DIDNT_CONVERGE = 322;
    uint256 internal constant RELAYER_NOT_CONTRACT = 323;
    uint256 internal constant BASE_POOL_RELAYER_NOT_CALLED = 324;
    uint256 internal constant REBALANCING_RELAYER_REENTERED = 325;
    uint256 internal constant GRADUAL_UPDATE_TIME_TRAVEL = 326;
    uint256 internal constant SWAPS_DISABLED = 327;
    uint256 internal constant CALLER_IS_NOT_LBP_OWNER = 328;
    uint256 internal constant PRICE_RATE_OVERFLOW = 329;
    uint256 internal constant INVALID_JOIN_EXIT_KIND_WHILE_SWAPS_DISABLED = 330;
    uint256 internal constant WEIGHT_CHANGE_TOO_FAST = 331;
    uint256 internal constant LOWER_GREATER_THAN_UPPER_TARGET = 332;
    uint256 internal constant UPPER_TARGET_TOO_HIGH = 333;
    uint256 internal constant UNHANDLED_BY_LINEAR_POOL = 334;
    uint256 internal constant OUT_OF_TARGET_RANGE = 335;
    uint256 internal constant UNHANDLED_EXIT_KIND = 336;
    uint256 internal constant UNAUTHORIZED_EXIT = 337;
    uint256 internal constant MAX_MANAGEMENT_SWAP_FEE_PERCENTAGE = 338;
    uint256 internal constant UNHANDLED_BY_MANAGED_POOL = 339;
    uint256 internal constant UNHANDLED_BY_PHANTOM_POOL = 340;
    uint256 internal constant TOKEN_DOES_NOT_HAVE_RATE_PROVIDER = 341;
    uint256 internal constant INVALID_INITIALIZATION = 342;
    uint256 internal constant OUT_OF_NEW_TARGET_RANGE = 343;
    uint256 internal constant UNAUTHORIZED_OPERATION = 344;
    uint256 internal constant UNINITIALIZED_POOL_CONTROLLER = 345;

    uint256 internal constant REENTRANCY = 400;
    uint256 internal constant SENDER_NOT_ALLOWED = 401;
    uint256 internal constant PAUSED = 402;
    uint256 internal constant PAUSE_WINDOW_EXPIRED = 403;
    uint256 internal constant MAX_PAUSE_WINDOW_DURATION = 404;
    uint256 internal constant MAX_BUFFER_PERIOD_DURATION = 405;
    uint256 internal constant INSUFFICIENT_BALANCE = 406;
    uint256 internal constant INSUFFICIENT_ALLOWANCE = 407;
    uint256 internal constant ERC20_TRANSFER_FROM_ZERO_ADDRESS = 408;
    uint256 internal constant ERC20_TRANSFER_TO_ZERO_ADDRESS = 409;
    uint256 internal constant ERC20_MINT_TO_ZERO_ADDRESS = 410;
    uint256 internal constant ERC20_BURN_FROM_ZERO_ADDRESS = 411;
    uint256 internal constant ERC20_APPROVE_FROM_ZERO_ADDRESS = 412;
    uint256 internal constant ERC20_APPROVE_TO_ZERO_ADDRESS = 413;
    uint256 internal constant ERC20_TRANSFER_EXCEEDS_ALLOWANCE = 414;
    uint256 internal constant ERC20_DECREASED_ALLOWANCE_BELOW_ZERO = 415;
    uint256 internal constant ERC20_TRANSFER_EXCEEDS_BALANCE = 416;
    uint256 internal constant ERC20_BURN_EXCEEDS_ALLOWANCE = 417;
    uint256 internal constant SAFE_ERC20_CALL_FAILED = 418;
    uint256 internal constant ADDRESS_INSUFFICIENT_BALANCE = 419;
    uint256 internal constant ADDRESS_CANNOT_SEND_VALUE = 420;
    uint256 internal constant SAFE_CAST_VALUE_CANT_FIT_INT256 = 421;
    uint256 internal constant GRANT_SENDER_NOT_ADMIN = 422;
    uint256 internal constant REVOKE_SENDER_NOT_ADMIN = 423;
    uint256 internal constant RENOUNCE_SENDER_NOT_ALLOWED = 424;
    uint256 internal constant BUFFER_PERIOD_EXPIRED = 425;
    uint256 internal constant CALLER_IS_NOT_OWNER = 426;
    uint256 internal constant NEW_OWNER_IS_ZERO = 427;
    uint256 internal constant CODE_DEPLOYMENT_FAILED = 428;
    uint256 internal constant CALL_TO_NON_CONTRACT = 429;
    uint256 internal constant LOW_LEVEL_CALL_FAILED = 430;
    uint256 internal constant NOT_PAUSED = 431;
    uint256 internal constant ADDRESS_ALREADY_ALLOWLISTED = 432;
    uint256 internal constant ADDRESS_NOT_ALLOWLISTED = 433;

    uint256 internal constant INVALID_POOL_ID = 500;
    uint256 internal constant CALLER_NOT_POOL = 501;
    uint256 internal constant SENDER_NOT_ASSET_MANAGER = 502;
    uint256 internal constant USER_DOESNT_ALLOW_RELAYER = 503;
    uint256 internal constant INVALID_SIGNATURE = 504;
    uint256 internal constant EXIT_BELOW_MIN = 505;
    uint256 internal constant JOIN_ABOVE_MAX = 506;
    uint256 internal constant SWAP_LIMIT = 507;
    uint256 internal constant SWAP_DEADLINE = 508;
    uint256 internal constant CANNOT_SWAP_SAME_TOKEN = 509;
    uint256 internal constant UNKNOWN_AMOUNT_IN_FIRST_SWAP = 510;
    uint256 internal constant MALCONSTRUCTED_MULTIHOP_SWAP = 511;
    uint256 internal constant INTERNAL_BALANCE_OVERFLOW = 512;
    uint256 internal constant INSUFFICIENT_INTERNAL_BALANCE = 513;
    uint256 internal constant INVALID_ETH_INTERNAL_BALANCE = 514;
    uint256 internal constant INVALID_POST_LOAN_BALANCE = 515;
    uint256 internal constant INSUFFICIENT_ETH = 516;
    uint256 internal constant UNALLOCATED_ETH = 517;
    uint256 internal constant ETH_TRANSFER = 518;
    uint256 internal constant CANNOT_USE_ETH_SENTINEL = 519;
    uint256 internal constant TOKENS_MISMATCH = 520;
    uint256 internal constant TOKEN_NOT_REGISTERED = 521;
    uint256 internal constant TOKEN_ALREADY_REGISTERED = 522;
    uint256 internal constant TOKENS_ALREADY_SET = 523;
    uint256 internal constant TOKENS_LENGTH_MUST_BE_2 = 524;
    uint256 internal constant NONZERO_TOKEN_BALANCE = 525;
    uint256 internal constant BALANCE_TOTAL_OVERFLOW = 526;
    uint256 internal constant POOL_NO_TOKENS = 527;
    uint256 internal constant INSUFFICIENT_FLASH_LOAN_BALANCE = 528;

    uint256 internal constant SWAP_FEE_PERCENTAGE_TOO_HIGH = 600;
    uint256 internal constant FLASH_LOAN_FEE_PERCENTAGE_TOO_HIGH = 601;
    uint256 internal constant INSUFFICIENT_FLASH_LOAN_FEE_AMOUNT = 602;
}



library LogExpMath {


    int256 constant ONE_18 = 1e18;

    int256 constant ONE_20 = 1e20;
    int256 constant ONE_36 = 1e36;

    int256 constant MAX_NATURAL_EXPONENT = 130e18;
    int256 constant MIN_NATURAL_EXPONENT = -41e18;

    int256 constant LN_36_LOWER_BOUND = ONE_18 - 1e17;
    int256 constant LN_36_UPPER_BOUND = ONE_18 + 1e17;

    uint256 constant MILD_EXPONENT_BOUND = 2**254 / uint256(ONE_20);

    int256 constant x0 = 128000000000000000000; // 2ˆ7
    int256 constant a0 = 38877084059945950922200000000000000000000000000000000000; // eˆ(x0) (no decimals)
    int256 constant x1 = 64000000000000000000; // 2ˆ6
    int256 constant a1 = 6235149080811616882910000000; // eˆ(x1) (no decimals)

    int256 constant x2 = 3200000000000000000000; // 2ˆ5
    int256 constant a2 = 7896296018268069516100000000000000; // eˆ(x2)
    int256 constant x3 = 1600000000000000000000; // 2ˆ4
    int256 constant a3 = 888611052050787263676000000; // eˆ(x3)
    int256 constant x4 = 800000000000000000000; // 2ˆ3
    int256 constant a4 = 298095798704172827474000; // eˆ(x4)
    int256 constant x5 = 400000000000000000000; // 2ˆ2
    int256 constant a5 = 5459815003314423907810; // eˆ(x5)
    int256 constant x6 = 200000000000000000000; // 2ˆ1
    int256 constant a6 = 738905609893065022723; // eˆ(x6)
    int256 constant x7 = 100000000000000000000; // 2ˆ0
    int256 constant a7 = 271828182845904523536; // eˆ(x7)
    int256 constant x8 = 50000000000000000000; // 2ˆ-1
    int256 constant a8 = 164872127070012814685; // eˆ(x8)
    int256 constant x9 = 25000000000000000000; // 2ˆ-2
    int256 constant a9 = 128402541668774148407; // eˆ(x9)
    int256 constant x10 = 12500000000000000000; // 2ˆ-3
    int256 constant a10 = 113314845306682631683; // eˆ(x10)
    int256 constant x11 = 6250000000000000000; // 2ˆ-4
    int256 constant a11 = 106449445891785942956; // eˆ(x11)

    function pow(uint256 x, uint256 y) internal pure returns (uint256) {

        if (y == 0) {
            return uint256(ONE_18);
        }

        if (x == 0) {
            return 0;
        }


        _require(x < 2**255, Errors.X_OUT_OF_BOUNDS);
        int256 x_int256 = int256(x);


        _require(y < MILD_EXPONENT_BOUND, Errors.Y_OUT_OF_BOUNDS);
        int256 y_int256 = int256(y);

        int256 logx_times_y;
        if (LN_36_LOWER_BOUND < x_int256 && x_int256 < LN_36_UPPER_BOUND) {
            int256 ln_36_x = _ln_36(x_int256);

            logx_times_y = ((ln_36_x / ONE_18) * y_int256 + ((ln_36_x % ONE_18) * y_int256) / ONE_18);
        } else {
            logx_times_y = _ln(x_int256) * y_int256;
        }
        logx_times_y /= ONE_18;

        _require(
            MIN_NATURAL_EXPONENT <= logx_times_y && logx_times_y <= MAX_NATURAL_EXPONENT,
            Errors.PRODUCT_OUT_OF_BOUNDS
        );

        return uint256(exp(logx_times_y));
    }

    function exp(int256 x) internal pure returns (int256) {

        _require(x >= MIN_NATURAL_EXPONENT && x <= MAX_NATURAL_EXPONENT, Errors.INVALID_EXPONENT);

        if (x < 0) {
            return ((ONE_18 * ONE_18) / exp(-x));
        }




        int256 firstAN;
        if (x >= x0) {
            x -= x0;
            firstAN = a0;
        } else if (x >= x1) {
            x -= x1;
            firstAN = a1;
        } else {
            firstAN = 1; // One with no decimal places
        }

        x *= 100;

        int256 product = ONE_20;

        if (x >= x2) {
            x -= x2;
            product = (product * a2) / ONE_20;
        }
        if (x >= x3) {
            x -= x3;
            product = (product * a3) / ONE_20;
        }
        if (x >= x4) {
            x -= x4;
            product = (product * a4) / ONE_20;
        }
        if (x >= x5) {
            x -= x5;
            product = (product * a5) / ONE_20;
        }
        if (x >= x6) {
            x -= x6;
            product = (product * a6) / ONE_20;
        }
        if (x >= x7) {
            x -= x7;
            product = (product * a7) / ONE_20;
        }
        if (x >= x8) {
            x -= x8;
            product = (product * a8) / ONE_20;
        }
        if (x >= x9) {
            x -= x9;
            product = (product * a9) / ONE_20;
        }



        int256 seriesSum = ONE_20; // The initial one in the sum, with 20 decimal places.
        int256 term; // Each term in the sum, where the nth term is (x^n / n!).

        term = x;
        seriesSum += term;


        term = ((term * x) / ONE_20) / 2;
        seriesSum += term;

        term = ((term * x) / ONE_20) / 3;
        seriesSum += term;

        term = ((term * x) / ONE_20) / 4;
        seriesSum += term;

        term = ((term * x) / ONE_20) / 5;
        seriesSum += term;

        term = ((term * x) / ONE_20) / 6;
        seriesSum += term;

        term = ((term * x) / ONE_20) / 7;
        seriesSum += term;

        term = ((term * x) / ONE_20) / 8;
        seriesSum += term;

        term = ((term * x) / ONE_20) / 9;
        seriesSum += term;

        term = ((term * x) / ONE_20) / 10;
        seriesSum += term;

        term = ((term * x) / ONE_20) / 11;
        seriesSum += term;

        term = ((term * x) / ONE_20) / 12;
        seriesSum += term;



        return (((product * seriesSum) / ONE_20) * firstAN) / 100;
    }

    function log(int256 arg, int256 base) internal pure returns (int256) {



        int256 logBase;
        if (LN_36_LOWER_BOUND < base && base < LN_36_UPPER_BOUND) {
            logBase = _ln_36(base);
        } else {
            logBase = _ln(base) * ONE_18;
        }

        int256 logArg;
        if (LN_36_LOWER_BOUND < arg && arg < LN_36_UPPER_BOUND) {
            logArg = _ln_36(arg);
        } else {
            logArg = _ln(arg) * ONE_18;
        }

        return (logArg * ONE_18) / logBase;
    }

    function ln(int256 a) internal pure returns (int256) {

        _require(a > 0, Errors.OUT_OF_BOUNDS);
        if (LN_36_LOWER_BOUND < a && a < LN_36_UPPER_BOUND) {
            return _ln_36(a) / ONE_18;
        } else {
            return _ln(a);
        }
    }

    function _ln(int256 a) private pure returns (int256) {

        if (a < ONE_18) {
            return (-_ln((ONE_18 * ONE_18) / a));
        }



        int256 sum = 0;
        if (a >= a0 * ONE_18) {
            a /= a0; // Integer, not fixed point division
            sum += x0;
        }

        if (a >= a1 * ONE_18) {
            a /= a1; // Integer, not fixed point division
            sum += x1;
        }

        sum *= 100;
        a *= 100;


        if (a >= a2) {
            a = (a * ONE_20) / a2;
            sum += x2;
        }

        if (a >= a3) {
            a = (a * ONE_20) / a3;
            sum += x3;
        }

        if (a >= a4) {
            a = (a * ONE_20) / a4;
            sum += x4;
        }

        if (a >= a5) {
            a = (a * ONE_20) / a5;
            sum += x5;
        }

        if (a >= a6) {
            a = (a * ONE_20) / a6;
            sum += x6;
        }

        if (a >= a7) {
            a = (a * ONE_20) / a7;
            sum += x7;
        }

        if (a >= a8) {
            a = (a * ONE_20) / a8;
            sum += x8;
        }

        if (a >= a9) {
            a = (a * ONE_20) / a9;
            sum += x9;
        }

        if (a >= a10) {
            a = (a * ONE_20) / a10;
            sum += x10;
        }

        if (a >= a11) {
            a = (a * ONE_20) / a11;
            sum += x11;
        }


        int256 z = ((a - ONE_20) * ONE_20) / (a + ONE_20);
        int256 z_squared = (z * z) / ONE_20;

        int256 num = z;

        int256 seriesSum = num;

        num = (num * z_squared) / ONE_20;
        seriesSum += num / 3;

        num = (num * z_squared) / ONE_20;
        seriesSum += num / 5;

        num = (num * z_squared) / ONE_20;
        seriesSum += num / 7;

        num = (num * z_squared) / ONE_20;
        seriesSum += num / 9;

        num = (num * z_squared) / ONE_20;
        seriesSum += num / 11;


        seriesSum *= 2;


        return (sum + seriesSum) / 100;
    }

    function _ln_36(int256 x) private pure returns (int256) {


        x *= ONE_18;


        int256 z = ((x - ONE_36) * ONE_36) / (x + ONE_36);
        int256 z_squared = (z * z) / ONE_36;

        int256 num = z;

        int256 seriesSum = num;

        num = (num * z_squared) / ONE_36;
        seriesSum += num / 3;

        num = (num * z_squared) / ONE_36;
        seriesSum += num / 5;

        num = (num * z_squared) / ONE_36;
        seriesSum += num / 7;

        num = (num * z_squared) / ONE_36;
        seriesSum += num / 9;

        num = (num * z_squared) / ONE_36;
        seriesSum += num / 11;

        num = (num * z_squared) / ONE_36;
        seriesSum += num / 13;

        num = (num * z_squared) / ONE_36;
        seriesSum += num / 15;


        return seriesSum * 2;
    }
}