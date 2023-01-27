pragma solidity >=0.6.2;

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

}pragma solidity >=0.5.0;

interface IUniswapV2Pair {

    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);

    function symbol() external pure returns (string memory);

    function decimals() external pure returns (uint8);

    function totalSupply() external view returns (uint);

    function balanceOf(address owner) external view returns (uint);

    function allowance(address owner, address spender) external view returns (uint);


    function approve(address spender, uint value) external returns (bool);

    function transfer(address to, uint value) external returns (bool);

    function transferFrom(address from, address to, uint value) external returns (bool);


    function DOMAIN_SEPARATOR() external view returns (bytes32);

    function PERMIT_TYPEHASH() external pure returns (bytes32);

    function nonces(address owner) external view returns (uint);


    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;


    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);

    function factory() external view returns (address);

    function token0() external view returns (address);

    function token1() external view returns (address);

    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);

    function price0CumulativeLast() external view returns (uint);

    function price1CumulativeLast() external view returns (uint);

    function kLast() external view returns (uint);


    function mint(address to) external returns (uint liquidity);

    function burn(address to) external returns (uint amount0, uint amount1);

    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;

    function skim(address to) external;

    function sync() external;


    function initialize(address, address) external;

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
}pragma solidity >=0.5.0;



library UniswapV2Library {

    using SafeMath for uint;

    function sortTokens(address tokenA, address tokenB) internal pure returns (address token0, address token1) {

        require(tokenA != tokenB, 'UniswapV2Library: IDENTICAL_ADDRESSES');
        (token0, token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        require(token0 != address(0), 'UniswapV2Library: ZERO_ADDRESS');
    }

    function pairFor(address factory, address tokenA, address tokenB) internal pure returns (address pair) {

        (address token0, address token1) = sortTokens(tokenA, tokenB);
        pair = address(uint160(uint(keccak256(abi.encodePacked(
                hex'ff',
                factory,
                keccak256(abi.encodePacked(token0, token1)),
                hex'96e8ac4277198ff8b6f785478aa9a39f403cb768dd02cbee326c3e7da348845f' // init code hash
            )))));
    }

    function getReserves(address factory, address tokenA, address tokenB) internal view returns (uint reserveA, uint reserveB) {

        (address token0,) = sortTokens(tokenA, tokenB);
        (uint reserve0, uint reserve1,) = IUniswapV2Pair(pairFor(factory, tokenA, tokenB)).getReserves();
        (reserveA, reserveB) = tokenA == token0 ? (reserve0, reserve1) : (reserve1, reserve0);
    }

    function quote(uint amountA, uint reserveA, uint reserveB) internal pure returns (uint amountB) {

        require(amountA > 0, 'UniswapV2Library: INSUFFICIENT_AMOUNT');
        require(reserveA > 0 && reserveB > 0, 'UniswapV2Library: INSUFFICIENT_LIQUIDITY');
        amountB = amountA.mul(reserveB) / reserveA;
    }
}// MIT
pragma solidity >=0.5.0 <0.8.0;

library ZeroLib {

	enum LoanStatusCode {
		UNINITIALIZED,
		UNPAID,
		PAID
	}
	struct LoanParams {
		address to;
		address asset;
		uint256 amount;
		uint256 nonce;
		address module;
		bytes data;
	}
	struct MetaParams {
		address from;
		uint256 nonce;
		bytes data;
		address module;
		address asset;
	}
	struct LoanStatus {
		address underwriter;
		LoanStatusCode status;
	}
	struct BalanceSheet {
		uint128 loaned;
		uint128 required;
		uint256 repaid;
	}
}interface IERC2612Permit {
	function permit(
		address holder,
		address spender,
		uint256 nonce,
		uint256 expiry,
		bool allowed,
		uint8 v,
		bytes32 r,
		bytes32 s
	) external;

	function permit(
		address holder,
		address spender,
		uint256 value,
                uint256 deadline,
		uint8 v,
		bytes32 r,
		bytes32 s
	) external;


	function nonces(address owner) external view returns (uint256);

	function DOMAIN_SEPARATOR() external view returns (bytes32);

}interface IRenCrv {
  function exchange(int128 i, int128 j, uint256 dx, uint256 min_dy) external;

}// MIT

pragma solidity >=0.6.0;

library SplitSignatureLib {

	function splitSignature(bytes memory signature)
		internal
		pure
		returns (
			uint8 v,
			bytes32 r,
			bytes32 s
		)
	{

		if (signature.length == 65) {
			assembly {
				r := mload(add(signature, 0x20))
				s := mload(add(signature, 0x40))
				v := byte(0, mload(add(signature, 0x60)))
			}
		} else if (signature.length == 64) {
			assembly {
				r := mload(add(signature, 0x20))
				let vs := mload(add(signature, 0x40))
				s := and(vs, 0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff)
				v := add(shr(255, vs), 27)
			}
		}
	}
}// MIT

pragma solidity >=0.6.0;

interface IBadgerSettPeak {

  function mint(uint256, uint256, bytes32[] calldata) external returns (uint256);

  function redeem(uint256, uint256) external returns (uint256);

}// MIT
pragma solidity >=0.6.0;

interface ICurveFi {

  function add_liquidity(uint256[2] calldata amounts, uint256 idx) external;

  function remove_liquidity_one_coin(uint256, int128, uint256) external;

}// MIT
pragma solidity >=0.6.0 <0.8.0;

interface IMintGateway {

	function mint(
		bytes32 _pHash,
		uint256 _amount,
		bytes32 _nHash,
		bytes calldata _sig
	) external returns (uint256);


	function mintFee() external view returns (uint256);

}

interface IBurnGateway {

	function burn(bytes memory _to, uint256 _amountScaled) external returns (uint256);


	function burnFee() external view returns (uint256);

}

interface IGateway is IMintGateway, IBurnGateway {


}


interface ICurveETHUInt256 {

	function exchange(
		uint256 i,
		uint256 j,
		uint256 dx,
		uint256 min_dy,
		bool use_eth
	) external payable returns (uint256);

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
}pragma solidity >=0.6.0<0.8.0;


abstract contract IyVault is IERC20 {
	function pricePerShare() external view virtual returns (uint256);

	function getPricePerFullShare() external view virtual returns (uint256);

	function totalAssets() external view virtual returns (uint256);

	function deposit(uint256 _amount) external virtual returns (uint256);

	function withdraw(uint256 maxShares) external virtual returns (uint256);

	function want() external virtual returns (address);

	function decimals() external view virtual returns (uint8);
}// MIT

pragma solidity >=0.6.0;

interface ISett {

  function deposit(uint256) external;

  function withdraw(uint256) external;

}// MIT

pragma solidity >=0.6.0 <0.8.0;

library Math {

    function max(uint256 a, uint256 b) internal pure returns (uint256) {

        return a >= b ? a : b;
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {

        return a < b ? a : b;
    }

    function average(uint256 a, uint256 b) internal pure returns (uint256) {

        return (a / 2) + (b / 2) + ((a % 2 + b % 2) / 2);
    }
}// MIT

pragma solidity >=0.6.2 <0.8.0;

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

pragma solidity >=0.6.0 <0.8.0;


library SafeERC20 {

    using SafeMath for uint256;
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

        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {


        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}// MIT

pragma solidity >=0.6.0 <0.8.0;

library ECDSA {

    function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {

        if (signature.length != 65) {
            revert("ECDSA: invalid signature length");
        }

        bytes32 r;
        bytes32 s;
        uint8 v;

        assembly {
            r := mload(add(signature, 0x20))
            s := mload(add(signature, 0x40))
            v := byte(0, mload(add(signature, 0x60)))
        }

        return recover(hash, v, r, s);
    }

    function recover(bytes32 hash, uint8 v, bytes32 r, bytes32 s) internal pure returns (address) {

        require(uint256(s) <= 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0, "ECDSA: invalid signature 's' value");
        require(v == 27 || v == 28, "ECDSA: invalid signature 'v' value");

        address signer = ecrecover(hash, v, r, s);
        require(signer != address(0), "ECDSA: invalid signature");

        return signer;
    }

    function toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32) {

        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }
}// MIT

pragma solidity ^0.7.0;

library AddressUpgradeable {

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

pragma solidity >=0.4.24 <0.8.0;


abstract contract Initializable {

    bool private _initialized;

    bool private _initializing;

    modifier initializer() {
        require(_initializing || _isConstructor() || !_initialized, "Initializable: contract is already initialized");

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

    function _isConstructor() private view returns (bool) {
        return !AddressUpgradeable.isContract(address(this));
    }
}// MIT

pragma solidity >=0.6.0 <0.8.0;

abstract contract EIP712Upgradeable is Initializable {
    bytes32 private _HASHED_NAME;
    bytes32 private _HASHED_VERSION;
    bytes32 private constant _TYPE_HASH = keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)");

    function __EIP712_init(string memory name, string memory version) internal initializer {
        __EIP712_init_unchained(name, version);
    }

    function __EIP712_init_unchained(string memory name, string memory version) internal initializer {
        bytes32 hashedName = keccak256(bytes(name));
        bytes32 hashedVersion = keccak256(bytes(version));
        _HASHED_NAME = hashedName;
        _HASHED_VERSION = hashedVersion;
    }

    function _domainSeparatorV4() internal view returns (bytes32) {
        return _buildDomainSeparator(_TYPE_HASH, _EIP712NameHash(), _EIP712VersionHash());
    }

    function _buildDomainSeparator(bytes32 typeHash, bytes32 name, bytes32 version) private view returns (bytes32) {
        return keccak256(
            abi.encode(
                typeHash,
                name,
                version,
                _getChainId(),
                address(this)
            )
        );
    }

    function _hashTypedDataV4(bytes32 structHash) internal view virtual returns (bytes32) {
        return keccak256(abi.encodePacked("\x19\x01", _domainSeparatorV4(), structHash));
    }

    function _getChainId() private view returns (uint256 chainId) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        assembly {
            chainId := chainid()
        }
    }

    function _EIP712NameHash() internal virtual view returns (bytes32) {
        return _HASHED_NAME;
    }

    function _EIP712VersionHash() internal virtual view returns (bytes32) {
        return _HASHED_VERSION;
    }
    uint256[50] private __gap;
}// MIT
pragma solidity >=0.6.0;


contract BadgerBridgeZeroController is EIP712Upgradeable {

	using SafeERC20 for IERC20;
	using SafeMath for *;
	uint256 public fee;
	address public governance;
	address public strategist;

	address constant btcGateway = 0xe4b679400F0f267212D5D812B95f58C83243EE71;
	address constant router = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
	address constant factory = 0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f;
	address constant usdc = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
	address constant weth = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
	address constant wbtc = 0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599;
	address constant renbtc = 0xEB4C2781e4ebA804CE9a9803C67d0893436bB27D;
	address constant renCrv = 0x93054188d876f558f4a66B2EF1d97d16eDf0895B;
	address constant tricrypto = 0x80466c64868E1ab14a1Ddf27A676C3fcBE638Fe5;
	address constant renCrvLp = 0x49849C98ae39Fff122806C06791Fa73784FB3675;
	address constant bCrvRen = 0x6dEf55d2e18486B9dDfaA075bc4e4EE0B28c1545;
	address constant settPeak = 0x41671BA1abcbA387b9b2B752c205e22e916BE6e3;
	address constant ibbtc = 0xc4E15973E6fF2A35cC804c2CF9D2a1b817a8b40F;
	uint256 public governanceFee;
	bytes32 constant PERMIT_TYPEHASH = 0xea2aa0a1be11a07ed86d755c93467f4f82362b452371d1ba94d1715123511acb;
	bytes32 constant LOCK_SLOT = keccak256('upgrade-lock');
	uint256 constant GAS_COST = uint256(37e4);
	uint256 constant IBBTC_GAS_COST = uint256(7e5);
	uint256 constant ETH_RESERVE = uint256(5 ether);
	uint256 internal renbtcForOneETHPrice;
	uint256 internal burnFee;
	uint256 public keeperReward;
	uint256 public constant REPAY_GAS_DIFF = 41510;
	uint256 public constant BURN_GAS_DIFF = 41118;
	mapping(address => uint256) public nonces;
	bytes32 internal PERMIT_DOMAIN_SEPARATOR_WBTC;
	bytes32 internal PERMIT_DOMAIN_SEPARATOR_IBBTC;

	function setStrategist(address _strategist) public {

		require(msg.sender == governance, '!governance');
		strategist = _strategist;
	}

	function setGovernance(address _governance) public {

		require(msg.sender == governance, '!governance');
		governance = _governance;
	}

	function approveUpgrade(bool lock) public {

		bool isLocked;
		bytes32 lock_slot = LOCK_SLOT;

		assembly {
			isLocked := sload(lock_slot)
		}
		require(!isLocked, 'cannot run upgrade function');
		assembly {
			sstore(lock_slot, lock)
		}

		IERC20(wbtc).safeApprove(router, ~uint256(0) >> 2);
	}

	function computeCalldataGasDiff() internal pure returns (uint256 diff) {

		if (true) return 0; // TODO: implement exact gas metering
		uint256 sz;
		assembly {
			sz := calldatasize()
		}
		diff = sz.mul(uint256(68));
		bytes memory slice;
		for (uint256 i = 0; i < sz; i += 0x20) {
			uint256 word;
			assembly {
				word := calldataload(i)
			}
			for (uint256 i = 0; i < 256 && ((uint256(~0) << i) & word) != 0; i += 8) {
				if ((word >> i) & 0xff != 0) diff -= 64;
			}
		}
	}

	function getChainId() internal pure returns (uint256 result) {

		assembly {
			result := chainid()
		}
	}

	function setParameters(
		uint256 _governanceFee,
		uint256 _fee,
		uint256 _burnFee,
		uint256 _keeperReward
	) public {

		require(governance == msg.sender, '!governance');
		governanceFee = _governanceFee;
		fee = _fee;
		burnFee = _burnFee;
		keeperReward = _keeperReward;
	}

	function initialize(address _governance, address _strategist) public initializer {

		fee = uint256(25e14);
		burnFee = uint256(4e15);
		governanceFee = uint256(5e17);
		governance = _governance;
		strategist = _strategist;
		keeperReward = uint256(1 ether).div(1000);
		IERC20(renbtc).safeApprove(btcGateway, ~uint256(0) >> 2);
		IERC20(renbtc).safeApprove(renCrv, ~uint256(0) >> 2);
		IERC20(wbtc).safeApprove(renCrv, ~uint256(0) >> 2);
		IERC20(wbtc).safeApprove(tricrypto, ~uint256(0) >> 2);
		IERC20(renCrvLp).safeApprove(bCrvRen, ~uint256(0) >> 2);
		IERC20(bCrvRen).safeApprove(settPeak, ~uint256(0) >> 2);
		IERC20(renbtc).safeApprove(router, ~uint256(0) >> 2);
		IERC20(usdc).safeApprove(router, ~uint256(0) >> 2);
		PERMIT_DOMAIN_SEPARATOR_WBTC = keccak256(
			abi.encode(
				keccak256('EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)'),
				keccak256('WBTC'),
				keccak256('1'),
				getChainId(),
				wbtc
			)
		);
		PERMIT_DOMAIN_SEPARATOR_IBBTC = keccak256(
			abi.encode(
				keccak256('EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)'),
				keccak256('ibBTC'),
				keccak256('1'),
				getChainId(),
				ibbtc
			)
		);
	}

	function applyRatio(uint256 v, uint256 n) internal pure returns (uint256 result) {

		result = v.mul(n).div(uint256(1 ether));
	}

	function toWBTC(uint256 amount) internal returns (uint256 amountOut) {

		uint256 amountStart = IERC20(wbtc).balanceOf(address(this));
		(bool success, ) = renCrv.call(abi.encodeWithSelector(IRenCrv.exchange.selector, 0, 1, amount));
		amountOut = IERC20(wbtc).balanceOf(address(this)).sub(amountStart);
	}

	function fromWBTC(uint256 amount) internal returns (uint256 amountOut) {

		uint256 amountStart = IERC20(renbtc).balanceOf(address(this));
		(bool success, ) = renCrv.call(abi.encodeWithSelector(IRenCrv.exchange.selector, 1, 0, amount));
		amountOut = IERC20(renbtc).balanceOf(address(this)).sub(amountStart);
	}

	function toIBBTC(uint256 amountIn) internal returns (uint256 amountOut) {

		uint256[2] memory amounts;
		amounts[0] = amountIn;
		(bool success, ) = renCrv.call(abi.encodeWithSelector(ICurveFi.add_liquidity.selector, amounts, 0));
		require(success, '!curve');
		ISett(bCrvRen).deposit(IERC20(renCrvLp).balanceOf(address(this)));
		amountOut = IBadgerSettPeak(settPeak).mint(0, IERC20(bCrvRen).balanceOf(address(this)), new bytes32[](0));
	}

	function toUSDC(uint256 amountIn, address out) internal returns (uint256 amountOut) {

		uint256 wbtcAmountIn = toWBTC(amountIn);
		address[] memory path = new address[](2);
		path[0] = wbtc;
		path[1] = usdc;
		uint256[] memory amountsOut = IUniswapV2Router02(router).swapExactTokensForTokens(
			wbtcAmountIn,
			1,
			path,
			out,
			block.timestamp + 1
		);
		amountOut = amountsOut[1];
	}

	function quote() internal {

		(uint256 amountWeth, uint256 amountRenBTC) = UniswapV2Library.getReserves(factory, weth, renbtc);
		renbtcForOneETHPrice = UniswapV2Library.quote(uint256(1 ether), amountWeth, amountRenBTC);
	}

	function renBTCtoETH(uint256 amountIn, address out) internal returns (uint256 amountOut) {

		uint256 wbtcAmountOut = toWBTC(amountIn);
		address[] memory path = new address[](2);
		path[0] = wbtc;
		path[1] = weth;
		uint256[] memory amountsOut = IUniswapV2Router02(router).swapExactTokensForTokens(
			wbtcAmountOut,
			1,
			path,
			out,
			block.timestamp + 1
		);
		amountOut = amountsOut[1];
	}

	function fromIBBTC(uint256 amountIn) internal returns (uint256 amountOut) {

		uint256 amountStart = IERC20(renbtc).balanceOf(address(this));
		IBadgerSettPeak(settPeak).redeem(0, amountIn);
		ISett(bCrvRen).withdraw(IERC20(bCrvRen).balanceOf(address(this)));
		(bool success, ) = renCrv.call(
			abi.encodeWithSelector(
				ICurveFi.remove_liquidity_one_coin.selector,
				IERC20(renCrvLp).balanceOf(address(this)),
				0,
				0
			)
		);
		require(success, '!curve');
		amountOut = IERC20(renbtc).balanceOf(address(this)).sub(amountStart);
	}

	function fromUSDC(uint256 amountIn) internal returns (uint256 amountOut) {

		address[] memory path = new address[](2);
		path[0] = usdc;
		path[1] = wbtc;
		uint256[] memory amountsOut = IUniswapV2Router02(router).swapExactTokensForTokens(
			amountIn,
			1,
			path,
			address(this),
			block.timestamp + 1
		);
		amountOut = fromWBTC(amountsOut[1]);
	}

	function toRenBTC(uint256 amountIn) internal returns (uint256 amountOut) {

		uint256 balanceStart = IERC20(renbtc).balanceOf(address(this));
		(bool success, ) = renCrv.call(abi.encodeWithSelector(IRenCrv.exchange.selector, 1, 0, amountIn));
		amountOut = IERC20(renbtc).balanceOf(address(this)).sub(balanceStart);
	}

	function fromETHToRenBTC(uint256 amountIn) internal returns (uint256 amountOut) {

		uint256 amountStart = IERC20(renbtc).balanceOf(address(this));
		address[] memory path = new address[](2);
		path[0] = weth;
		path[1] = wbtc;
		uint256[] memory amountsOut = IUniswapV2Router02(router).swapExactETHForTokens{value: amountIn}(
			1,
			path,
			address(this),
			block.timestamp + 1
		);
		(bool success, ) = renCrv.call(abi.encodeWithSelector(IRenCrv.exchange.selector, 1, 0, amountsOut[1], 1));
		require(success, '!curve');
		amountOut = IERC20(renbtc).balanceOf(address(this)).sub(amountStart);
	}

	function toETH() internal returns (uint256 amountOut) {

		uint256 wbtcStart = IERC20(wbtc).balanceOf(address(this));

		uint256 amountStart = address(this).balance;
		(bool success, ) = tricrypto.call(
			abi.encodeWithSelector(ICurveETHUInt256.exchange.selector, 1, 2, wbtcStart, 0, true)
		);
		amountOut = address(this).balance.sub(amountStart);
	}

	receive() external payable {
	}

	function earn() public {

		quote();
		toWBTC(IERC20(renbtc).balanceOf(address(this)));
		toETH();
		uint256 balance = address(this).balance;
		if (balance > ETH_RESERVE) {
			uint256 output = balance - ETH_RESERVE;
			uint256 toGovernance = applyRatio(output, governanceFee);
			address payable governancePayable = address(uint160(governance));
			governancePayable.transfer(toGovernance);
			address payable strategistPayable = address(uint160(strategist));
			strategistPayable.transfer(output.sub(toGovernance));
		}
	}

	function computeRenBTCGasFee(uint256 gasCost, uint256 gasPrice) internal view returns (uint256 result) {

		result = gasCost.mul(tx.gasprice).mul(renbtcForOneETHPrice).div(uint256(1 ether));
	}

	function deductMintFee(uint256 amountIn, uint256 multiplier) internal view returns (uint256 amount) {

		amount = amountIn.sub(applyFee(amountIn, fee, multiplier));
	}

	function deductIBBTCMintFee(uint256 amountIn, uint256 multiplier) internal view returns (uint256 amount) {

		amount = amountIn.sub(applyIBBTCFee(amountIn, fee, multiplier));
	}

	function deductBurnFee(uint256 amountIn, uint256 multiplier) internal view returns (uint256 amount) {

		amount = amountIn.sub(applyFee(amountIn, burnFee, multiplier));
	}

	function deductIBBTCBurnFee(uint256 amountIn, uint256 multiplier) internal view returns (uint256 amount) {

		amount = amountIn.sub(applyIBBTCFee(amountIn, burnFee, multiplier));
	}

	function applyFee(
		uint256 amountIn,
		uint256 _fee,
		uint256 multiplier
	) internal view returns (uint256 amount) {

		amount = computeRenBTCGasFee(GAS_COST.add(keeperReward.div(tx.gasprice)), tx.gasprice).add(
			applyRatio(amountIn, _fee)
		);
	}

	function applyIBBTCFee(
		uint256 amountIn,
		uint256 _fee,
		uint256 multiplier
	) internal view returns (uint256 amount) {

		amount = computeRenBTCGasFee(IBBTC_GAS_COST.add(keeperReward.div(tx.gasprice)), tx.gasprice).add(
			applyRatio(amountIn, _fee)
		);
	}

	struct LoanParams {
		address to;
		address asset;
		uint256 nonce;
		uint256 amount;
		address module;
		address underwriter;
		bytes data;
		uint256 _mintAmount;
		uint256 gasDiff;
	}

	function toTypedDataHash(LoanParams memory params) internal view returns (bytes32 result) {

		bytes32 digest = _hashTypedDataV4(
			keccak256(
				abi.encode(
					keccak256(
						'TransferRequest(address asset,uint256 amount,address underwriter,address module,uint256 nonce,bytes data)'
					),
					params.asset,
					params.amount,
					params.underwriter,
					params.module,
					params.nonce,
					keccak256(params.data)
				)
			)
		);
		return digest;
	}

	function repay(
		address underwriter,
		address to,
		address asset,
		uint256 amount,
		uint256 actualAmount,
		uint256 nonce,
		address module,
		bytes32 nHash,
		bytes memory data,
		bytes memory signature
	) public returns (uint256 amountOut) {

		uint256 _gasBefore = gasleft();
		LoanParams memory params;
		{
			require(
				module == wbtc || module == usdc || module == ibbtc || module == renbtc || module == address(0x0),
				'!approved-module'
			);
			params = LoanParams({
				to: to,
				asset: asset,
				amount: amount,
				nonce: nonce,
				module: module,
				underwriter: underwriter,
				data: data,
				_mintAmount: 0,
				gasDiff: computeCalldataGasDiff()
			});
		}
		bytes32 digest = toTypedDataHash(params);

		params._mintAmount = IGateway(btcGateway).mint(
			keccak256(abi.encode(params.to, params.nonce, params.module, params.data)),
			actualAmount,
			nHash,
			signature
		);

		{
			amountOut = module == wbtc ? toWBTC(deductMintFee(params._mintAmount, 1)) : module == address(0x0)
				? renBTCtoETH(deductMintFee(params._mintAmount, 1), to)
				: module == usdc
				? toUSDC(deductMintFee(params._mintAmount, 1), to)
				: module == ibbtc
				? toIBBTC(deductIBBTCMintFee(params._mintAmount, 3))
				: deductMintFee(params._mintAmount, 1);
		}
		{
			if (module != usdc && module != address(0x0)) IERC20(module).safeTransfer(to, amountOut);
		}
		{
			tx.origin.transfer(
				Math.min(
					_gasBefore.sub(gasleft()).add(REPAY_GAS_DIFF).add(params.gasDiff).mul(tx.gasprice).add(
						keeperReward
					),
					address(this).balance
				)
			);
		}
	}

	function computeBurnNonce(BurnLocals memory params) internal view returns (uint256 result) {

		result = uint256(
			keccak256(abi.encodePacked(params.asset, params.amount, params.deadline, params.nonce, params.destination))
		);
		while (result < block.timestamp) {
			result = uint256(keccak256(abi.encodePacked(result)));
		}
	}

	function computeERC20PermitDigest(bytes32 domainSeparator, BurnLocals memory params)
		internal
		view
		returns (bytes32 result)
	{

		result = keccak256(
			abi.encodePacked(
				'\x19\x01',
				domainSeparator,
				keccak256(
					abi.encode(PERMIT_TYPEHASH, params.to, address(this), params.nonce, computeBurnNonce(params), true)
				)
			)
		);
	}

	struct BurnLocals {
		address to;
		address asset;
		uint256 amount;
		uint256 deadline;
		uint256 nonce;
		uint256 burnNonce;
		uint256 gasBefore;
		uint256 gasDiff;
		uint8 v;
		bytes32 r;
		bytes32 s;
		bytes destination;
		bytes signature;
	}

	function burn(
		address to,
		address asset,
		uint256 amount,
		uint256 deadline,
		bytes memory destination,
		bytes memory signature
	) public returns (uint256 amountToBurn) {

		BurnLocals memory params = BurnLocals({
			to: to,
			asset: asset,
			amount: amount,
			deadline: deadline,
			nonce: 0,
			burnNonce: 0,
			v: uint8(0),
			r: bytes32(0),
			s: bytes32(0),
			destination: destination,
			signature: signature,
			gasBefore: gasleft(),
			gasDiff: 0
		});
		{
			params.gasDiff = computeCalldataGasDiff();
		}
		require(block.timestamp < params.deadline, '!deadline');
		if (params.asset == wbtc) {
			params.nonce = nonces[to];
			nonces[params.to]++;
			require(
				params.to ==
					ECDSA.recover(computeERC20PermitDigest(PERMIT_DOMAIN_SEPARATOR_WBTC, params), params.signature),
				'!signature'
			); //  wbtc does not implement ERC20Permit
			{
				IERC20(params.asset).transferFrom(params.to, address(this), params.amount);
				amountToBurn = toRenBTC(deductBurnFee(params.amount, 1));
			}
		} else if (asset == ibbtc) {
			params.nonce = nonces[to];
			nonces[to]++;
			require(
				params.to ==
					ECDSA.recover(computeERC20PermitDigest(PERMIT_DOMAIN_SEPARATOR_IBBTC, params), params.signature),
				'!signature'
			); //  wbtc ibbtc do not implement ERC20Permit
			{
				IERC20(params.asset).transferFrom(params.to, address(this), params.amount);
				amountToBurn = deductIBBTCBurnFee(fromIBBTC(params.amount), 3);
			}
		} else if (params.asset == renbtc) {
			{
				params.nonce = IERC2612Permit(params.asset).nonces(params.to);
				params.burnNonce = computeBurnNonce(params);
			}
			{
				(params.v, params.r, params.s) = SplitSignatureLib.splitSignature(params.signature);
				IERC2612Permit(params.asset).permit(
					params.to,
					address(this),
					params.nonce,
					params.burnNonce,
					true,
					params.v,
					params.r,
					params.s
				);
			}
			{
				IERC20(params.asset).transferFrom(params.to, address(this), params.amount);
			}
			amountToBurn = deductBurnFee(params.amount, 1);
		} else if (params.asset == usdc) {
			{
				params.nonce = IERC2612Permit(params.asset).nonces(params.to);
				params.burnNonce = computeBurnNonce(params);
			}
			{
				(params.v, params.r, params.s) = SplitSignatureLib.splitSignature(params.signature);
				IERC2612Permit(params.asset).permit(
					params.to,
					address(this),
					params.amount,
					params.burnNonce,
					params.v,
					params.r,
					params.s
				);
			}
			{
				IERC20(params.asset).transferFrom(params.to, address(this), params.amount);
			}
			amountToBurn = deductBurnFee(fromUSDC(params.amount), 1);
		} else revert('!supported-asset');
		{
			IGateway(btcGateway).burn(params.destination, amountToBurn);
		}
		{
			tx.origin.transfer(
				Math.min(
					params.gasBefore.sub(gasleft()).add(BURN_GAS_DIFF).add(params.gasDiff).mul(tx.gasprice).add(
						keeperReward
					),
					address(this).balance
				)
			);
		}
	}

	function burnETH(bytes memory destination) public payable returns (uint256 amountToBurn) {

		amountToBurn = fromETHToRenBTC(msg.value.sub(applyRatio(msg.value, burnFee)));
		IGateway(btcGateway).burn(destination, amountToBurn);
	}

	function fallbackMint(
		address underwriter,
		address to,
		address asset,
		uint256 amount,
		uint256 actualAmount,
		uint256 nonce,
		address module,
		bytes32 nHash,
		bytes memory data,
		bytes memory signature
	) public {

		LoanParams memory params = LoanParams({
			to: to,
			asset: asset,
			amount: amount,
			nonce: nonce,
			module: module,
			underwriter: underwriter,
			data: data,
			_mintAmount: 0,
			gasDiff: 0
		});
		bytes32 digest = toTypedDataHash(params);
		uint256 _actualAmount = IGateway(btcGateway).mint(
			keccak256(abi.encode(params.to, params.nonce, params.module, params.data)),
			actualAmount,
			nHash,
			signature
		);
		IERC20(asset).safeTransfer(to, _actualAmount);
	}
}