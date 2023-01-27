
pragma solidity ^0.7.0;

interface IERC20Upgradeable {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}// MIT

pragma solidity ^0.7.0;

library SafeMathUpgradeable {

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

pragma solidity ^0.7.0;


library SafeERC20Upgradeable {

    using SafeMathUpgradeable for uint256;
    using AddressUpgradeable for address;

    function safeTransfer(IERC20Upgradeable token, address to, uint256 value) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20Upgradeable token, address from, address to, uint256 value) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20Upgradeable token, address spender, uint256 value) internal {

        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20Upgradeable token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20Upgradeable token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function _callOptionalReturn(IERC20Upgradeable token, bytes memory data) private {


        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
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

abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal initializer {
        __Context_init_unchained();
    }

    function __Context_init_unchained() internal initializer {
    }
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
    uint256[50] private __gap;
}// MIT

pragma solidity ^0.7.0;

abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function __Ownable_init() internal initializer {
        __Context_init_unchained();
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal initializer {
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
    uint256[49] private __gap;
}// MIT

pragma solidity 0.7.6;

interface IZap {

  function zap(
    address _fromToken,
    uint256 _amountIn,
    address _toToken,
    uint256 _minOut
  ) external payable returns (uint256);

}// MIT

pragma solidity ^0.7.6;
pragma abicoder v2;

interface IBalancerVault {

    enum SwapKind {
        GIVEN_IN,
        GIVEN_OUT
    }

    struct SingleSwap {
        bytes32 poolId;
        SwapKind kind;
        address assetIn;
        address assetOut;
        uint256 amount;
        bytes userData;
    }

    struct FundManagement {
        address sender;
        bool fromInternalBalance;
        address payable recipient;
        bool toInternalBalance;
    }

    function getPoolTokens(bytes32 poolId)
        external
        view
        returns (
            address[] memory tokens,
            uint256[] memory balances,
            uint256 lastChangeBlock
        );


    function swap(
        SingleSwap memory singleSwap,
        FundManagement memory funds,
        uint256 limit,
        uint256 deadline
    ) external payable returns (uint256 amountCalculated);

}// MIT

pragma solidity ^0.7.6;

interface IBalancerPool {

  function getPoolId() external view returns (bytes32);

}// MIT

pragma solidity 0.7.6;

interface IConvexCRVDepositor {

  function deposit(
    uint256 _amount,
    bool _lock,
    address _stakeAddress
  ) external;


  function deposit(uint256 _amount, bool _lock) external;


  function lockIncentive() external view returns (uint256);

}// MIT

pragma solidity ^0.7.6;


interface ICurveAPool {

    function remove_liquidity_one_coin(
        uint256 _token_amount,
        int128 i,
        uint256 _min_amount,
        bool _use_underlying
    ) external returns (uint256);


    function calc_withdraw_one_coin(uint256 _token_amount, int128 i)
        external
        view
        returns (uint256);


    function exchange(
        int128 i,
        int128 j,
        uint256 dx,
        uint256 min_dy
    ) external returns (uint256);


    function exchange_underlying(
        int128 i,
        int128 j,
        uint256 dx,
        uint256 min_dy
    ) external returns (uint256);


    function get_dy(
        int128 i,
        int128 j,
        uint256 dx
    ) external view returns (uint256);


    function get_dy_underlying(
        int128 i,
        int128 j,
        uint256 dx
    ) external view returns (uint256);


    function coins(uint256 index) external view returns (address);


    function underlying_coins(uint256 index) external view returns (address);


    function lp_token() external view returns (address);

}

interface ICurveA2Pool is ICurveAPool {

    function add_liquidity(
        uint256[2] memory _amounts,
        uint256 _min_mint_amount,
        bool _use_underlying
    ) external returns (uint256);


    function calc_token_amount(uint256[2] memory amounts, bool is_deposit)
        external
        view
        returns (uint256);

}

interface ICurveA3Pool is ICurveAPool {

    function add_liquidity(
        uint256[3] memory _amounts,
        uint256 _min_mint_amount,
        bool _use_underlying
    ) external returns (uint256);


    function calc_token_amount(uint256[3] memory amounts, bool is_deposit)
        external
        view
        returns (uint256);

}

interface ICurveA4Pool is ICurveAPool {

    function add_liquidity(
        uint256[4] memory _amounts,
        uint256 _min_mint_amount,
        bool _use_underlying
    ) external returns (uint256);


    function calc_token_amount(uint256[4] memory amounts, bool is_deposit)
        external
        view
        returns (uint256);

}// MIT

pragma solidity ^0.7.6;


interface ICurveBasePool {

  function remove_liquidity_one_coin(
    uint256 _token_amount,
    int128 i,
    uint256 min_amount
  ) external;


  function calc_withdraw_one_coin(uint256 _token_amount, int128 i) external view returns (uint256);


  function exchange(
    int128 i,
    int128 j,
    uint256 dx,
    uint256 min_dy
  ) external;


  function get_dy(
    int128 i,
    int128 j,
    uint256 dx
  ) external view returns (uint256);


  function get_dy_underlying(
    int128 i,
    int128 j,
    uint256 dx
  ) external view returns (uint256);


  function coins(uint256 index) external view returns (address);


  function coins(int128 index) external view returns (address);

}

interface ICurveBase2Pool {

  function add_liquidity(uint256[2] memory amounts, uint256 min_mint_amount) external;


  function calc_token_amount(uint256[2] memory amounts, bool deposit) external view returns (uint256);

}

interface ICurveBase3Pool {

  function add_liquidity(uint256[3] memory amounts, uint256 min_mint_amount) external;


  function calc_token_amount(uint256[3] memory amounts, bool deposit) external view returns (uint256);

}

interface ICurveBase4Pool {

  function add_liquidity(uint256[4] memory amounts, uint256 min_mint_amount) external;


  function calc_token_amount(uint256[4] memory amounts, bool deposit) external view returns (uint256);

}// MIT

pragma solidity ^0.7.6;



interface ICurveCryptoPool {

  function add_liquidity(uint256[2] memory amounts, uint256 min_mint_amount) external payable returns (uint256);


  function calc_token_amount(uint256[2] memory amounts) external view returns (uint256);


  function remove_liquidity_one_coin(
    uint256 token_amount,
    uint256 i,
    uint256 min_amount
  ) external returns (uint256);


  function calc_withdraw_one_coin(uint256 token_amount, uint256 i) external view returns (uint256);


  function exchange(
    uint256 i,
    uint256 j,
    uint256 dx,
    uint256 min_dy
  ) external payable returns (uint256);


  function exchange_underlying(
    uint256 i,
    uint256 j,
    uint256 dx,
    uint256 min_dy
  ) external payable returns (uint256);


  function get_dy(
    uint256 i,
    uint256 j,
    uint256 dx
  ) external view returns (uint256);


  function coins(uint256 index) external view returns (address);

}

interface IZapCurveMetaCryptoPool {

  function add_liquidity(uint256[4] memory amounts, uint256 min_mint_amount) external returns (uint256);


  function calc_token_amount(uint256[4] memory amounts) external view returns (uint256);


  function remove_liquidity_one_coin(
    uint256 token_amount,
    uint256 i,
    uint256 min_amount
  ) external returns (uint256);


  function calc_withdraw_one_coin(uint256 token_amount, uint256 i) external view returns (uint256);


  function exchange_underlying(
    uint256 i,
    uint256 j,
    uint256 dx,
    uint256 min_dy
  ) external returns (uint256);


  function get_dy_underlying(
    uint256 i,
    uint256 j,
    uint256 dx
  ) external view returns (uint256);


  function coins(uint256 index) external view returns (address);


  function underlying_coins(uint256 index) external view returns (address);


  function token() external view returns (address);


  function base_pool() external view returns (address);


  function pool() external view returns (address);

}

interface ICurveTriCryptoPool {

  function add_liquidity(uint256[3] memory amounts, uint256 min_mint_amount) external;


  function calc_token_amount(uint256[3] memory amounts, bool deposit) external view returns (uint256);


  function remove_liquidity_one_coin(
    uint256 token_amount,
    uint256 i,
    uint256 min_amount
  ) external;


  function calc_withdraw_one_coin(uint256 token_amount, uint256 i) external view returns (uint256);


  function exchange(
    uint256 i,
    uint256 j,
    uint256 dx,
    uint256 min_dy,
    bool use_eth
  ) external;


  function get_dy(
    uint256 i,
    uint256 j,
    uint256 dx
  ) external view returns (uint256);


  function token() external view returns (address);


  function coins(uint256 index) external returns (address);

}// MIT

pragma solidity ^0.7.6;


interface ICurveETHPool {

    function add_liquidity(uint256[2] memory amounts, uint256 min_mint_amount)
        external
        payable
        returns (uint256);


    function calc_token_amount(uint256[2] memory amounts, bool is_deposit)
        external
        view
        returns (uint256);


    function remove_liquidity_one_coin(
        uint256 _token_amount,
        int128 i,
        uint256 _min_amount
    ) external returns (uint256);


    function calc_withdraw_one_coin(uint256 _token_amount, int128 i)
        external
        view
        returns (uint256);


    function exchange(
        int128 i,
        int128 j,
        uint256 dx,
        uint256 min_dy
    ) external payable returns (uint256);


    function get_dy(
        int128 i,
        int128 j,
        uint256 dx
    ) external view returns (uint256);


    function coins(uint256 index) external view returns (address);

}// MIT

pragma solidity ^0.7.6;


interface ICurveFactoryMetaPool {

  function add_liquidity(uint256[2] memory _amounts, uint256 _min_mint_amount) external returns (uint256);


  function calc_token_amount(uint256[2] memory amounts, bool is_deposit) external view returns (uint256);


  function remove_liquidity_one_coin(
    uint256 token_amount,
    int128 i,
    uint256 min_amount
  ) external returns (uint256);


  function calc_withdraw_one_coin(uint256 token_amount, int128 i) external view returns (uint256);


  function exchange(
    int128 i,
    int128 j,
    uint256 dx,
    uint256 min_dy
  ) external returns (uint256);


  function exchange_underlying(
    int128 i,
    int128 j,
    uint256 dx,
    uint256 min_dy
  ) external returns (uint256);


  function get_dy(
    int128 i,
    int128 j,
    uint256 dx
  ) external view returns (uint256);


  function get_dy_underlying(
    int128 i,
    int128 j,
    uint256 dx
  ) external view returns (uint256);


  function coins(uint256 index) external view returns (address);

}

interface ICurveDepositZap {

  function add_liquidity(
    address _pool,
    uint256[4] memory _deposit_amounts,
    uint256 _min_mint_amount
  ) external returns (uint256);


  function calc_token_amount(
    address _pool,
    uint256[4] memory _amounts,
    bool _is_deposit
  ) external view returns (uint256);


  function remove_liquidity_one_coin(
    address _pool,
    uint256 _burn_amount,
    int128 i,
    uint256 _min_amount
  ) external returns (uint256);


  function calc_withdraw_one_coin(
    address _pool,
    uint256 _token_amount,
    int128 i
  ) external view returns (uint256);

}// MIT

pragma solidity ^0.7.6;

interface ICurveFactoryPlainPool {

  function remove_liquidity_one_coin(
    uint256 token_amount,
    int128 i,
    uint256 min_amount
  ) external returns (uint256);


  function calc_withdraw_one_coin(uint256 _token_amount, int128 i) external view returns (uint256);


  function exchange(
    int128 i,
    int128 j,
    uint256 _dx,
    uint256 _min_dy,
    address _receiver
  ) external returns (uint256);


  function get_dy(
    int128 i,
    int128 j,
    uint256 dx
  ) external view returns (uint256);


  function coins(uint256 index) external view returns (address);

}

interface ICurveFactoryPlain2Pool is ICurveFactoryPlainPool {

  function add_liquidity(uint256[2] memory amounts, uint256 min_mint_amount) external returns (uint256);


  function calc_token_amount(uint256[2] memory amounts, bool _is_deposit) external view returns (uint256);

}

interface ICurveFactoryPlain3Pool is ICurveFactoryPlainPool {

  function add_liquidity(uint256[3] memory amounts, uint256 min_mint_amount) external returns (uint256);


  function calc_token_amount(uint256[3] memory amounts, bool _is_deposit) external view returns (uint256);

}

interface ICurveFactoryPlain4Pool is ICurveFactoryPlainPool {

  function add_liquidity(uint256[4] memory amounts, uint256 min_mint_amount) external returns (uint256);


  function calc_token_amount(uint256[4] memory amounts, bool _is_deposit) external view returns (uint256);

}// MIT

pragma solidity ^0.7.6;


interface ICurveMetaPoolSwap {

    function add_liquidity(uint256[2] memory _amounts, uint256 _min_mint_amount)
        external
        returns (uint256);


    function calc_token_amount(uint256[2] memory amounts, bool is_deposit)
        external
        view
        returns (uint256);


    function remove_liquidity_one_coin(
        uint256 token_amount,
        int128 i,
        uint256 min_amount
    ) external returns (uint256);


    function calc_withdraw_one_coin(uint256 token_amount, int128 i)
        external
        view
        returns (uint256);


    function exchange(
        int128 i,
        int128 j,
        uint256 dx,
        uint256 min_dy
    ) external returns (uint256);


    function exchange_underlying(
        int128 i,
        int128 j,
        uint256 dx,
        uint256 min_dy
    ) external returns (uint256);


    function get_dy(
        int128 i,
        int128 j,
        uint256 dx
    ) external view returns (uint256);


    function get_dy_underlying(
        int128 i,
        int128 j,
        uint256 dx
    ) external view returns (uint256);


    function base_pool() external view returns (address);


    function base_coins(uint256 index) external view returns (address);


    function coins(uint256 index) external view returns (address);


    function token() external view returns (address);

}

interface ICurveMetaPoolDeposit {

    function add_liquidity(uint256[4] memory amounts, uint256 min_mint_amount)
        external
        returns (uint256);


    function calc_token_amount(uint256[4] memory amounts, bool is_deposit)
        external
        view
        returns (uint256);


    function remove_liquidity_one_coin(
        uint256 token_amount,
        int128 i,
        uint256 min_amount
    ) external returns (uint256);


    function calc_withdraw_one_coin(uint256 token_amount, int128 i)
        external
        view
        returns (uint256);


    function token() external view returns (address);


    function base_pool() external view returns (address);


    function pool() external view returns (address);


    function coins(uint256 index) external view returns (address);


    function base_coins(uint256 index) external view returns (address);

}// MIT

pragma solidity ^0.7.6;


interface ICurveYPoolSwap {

    function exchange(
        int128 i,
        int128 j,
        uint256 dx,
        uint256 min_dy
    ) external;


    function exchange_underlying(
        int128 i,
        int128 j,
        uint256 dx,
        uint256 min_dy
    ) external;


    function get_dy(
        int128 i,
        int128 j,
        uint256 dx
    ) external view returns (uint256);


    function get_dy_underlying(
        int128 i,
        int128 j,
        uint256 dx
    ) external view returns (uint256);


    function coins(uint256 index) external view returns (address);


    function underlying_coins(uint256 index) external view returns (address);

}

interface ICurveYPoolDeposit {

    function remove_liquidity_one_coin(
        uint256 _token_amount,
        int128 i,
        uint256 _min_amount
    ) external;


    function calc_withdraw_one_coin(uint256 _token_amount, int128 i)
        external
        view
        returns (uint256);


    function token() external returns (address);


    function curve() external returns (address);


    function coins(uint256 index) external view returns (address);


    function underlying_coins(uint256 index) external view returns (address);

}

interface ICurveY2PoolDeposit is ICurveYPoolDeposit {

    function add_liquidity(uint256[2] memory _amounts, uint256 _min_mint_amount)
        external;

}

interface ICurveY2PoolSwap is ICurveYPoolSwap {

    function add_liquidity(uint256[2] memory _amounts, uint256 _min_mint_amount)
        external;

}

interface ICurveY3PoolDeposit is ICurveYPoolDeposit {

    function add_liquidity(uint256[3] memory _amounts, uint256 _min_mint_amount)
        external;

}

interface ICurveY3PoolSwap is ICurveYPoolSwap {

    function add_liquidity(uint256[3] memory _amounts, uint256 _min_mint_amount)
        external;

}

interface ICurveY4PoolDeposit is ICurveYPoolDeposit {

    function add_liquidity(uint256[4] memory _amounts, uint256 _min_mint_amount)
        external;

}

interface ICurveY4PoolSwap is ICurveYPoolSwap {

    function add_liquidity(uint256[4] memory _amounts, uint256 _min_mint_amount)
        external;

}// MIT

pragma solidity ^0.7.6;

interface ILidoStETH {

  function submit(address _referral) external payable returns (uint256);

}// MIT

pragma solidity ^0.7.6;

interface ILidoWstETH {

  function wrap(uint256 _stETHAmount) external returns (uint256);


  function unwrap(uint256 _wstETHAmount) external returns (uint256);

}// MIT

pragma solidity 0.7.6;

interface IUniswapV2Pair {

  function token0() external returns (address);


  function token1() external returns (address);


  function getReserves()
    external
    view
    returns (
      uint112 _reserve0,
      uint112 _reserve1,
      uint32 _blockTimestampLast
    );


  function swap(
    uint256 amount0Out,
    uint256 amount1Out,
    address to,
    bytes calldata data
  ) external;

}// MIT

pragma solidity 0.7.6;

interface IUniswapV3Pool {

  function token0() external returns (address);


  function token1() external returns (address);


  function fee() external returns (uint24);

}// MIT

pragma solidity 0.7.6;

interface IUniswapV3Router {

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

  function exactInputSingle(ExactInputSingleParams calldata params) external returns (uint256 amountOut);

}// MIT

pragma solidity 0.7.6;

interface IWETH {

  function deposit() external payable;


  function withdraw(uint256 wad) external;

}// MIT

pragma solidity ^0.7.6;




contract LendFlareZap is OwnableUpgradeable, IZap {

    using SafeERC20Upgradeable for IERC20Upgradeable;
    using SafeMathUpgradeable for uint256;

    event UpdateRoute(address indexed _fromToken, address indexed _toToken, uint256[] route);

    address private constant ETH = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;
    address private constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    address private constant UNIV3_ROUTER = 0xE592427A0AEce92De3Edee1F18E0157C05861564;
    address private constant BALANCER_VAULT = 0xBA12222222228d8Ba445958a75a0704d566BF2C8;
    address private constant CURVE_3POOL_DEPOSIT_ZAP = 0xA79828DF1850E8a3A3064576f380D90aECDD3359;
    address private constant DAI = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
    address private constant USDC = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
    address private constant USDT = 0xdAC17F958D2ee523a2206206994597C13D831ec7;
    address private constant CURVE_SBTC_DEPOSIT_ZAP = 0x7AbDBAf29929e7F8621B757D2a7c04d78d633834;
    address private constant RENBTC = 0xEB4C2781e4ebA804CE9a9803C67d0893436bB27D;
    address private constant WBTC = 0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599;
    address private constant SBTC = 0xfE18be6b3Bd88A2D2A7f928d00292E7a9963CfC6;
    address private constant stETH = 0xae7ab96520DE3A18E5e111B5EaAb095312D7fE84;
    address private constant wstETH = 0x7f39C581F595B53c5cb19bD0b3f8dA6c935E2Ca0;

    enum PoolType {
        UniswapV2, // with fee 0.3%, add/remove liquidity not supported
        UniswapV3, // add/remove liquidity not supported
        BalancerV2, // add/remove liquidity not supported
        CurveETHPool, // including Factory Pool
        CurveCryptoPool, // including Factory Pool
        CurveMetaCryptoPool,
        CurveTriCryptoPool,
        CurveBasePool,
        CurveAPool,
        CurveAPoolUnderlying,
        CurveYPool,
        CurveYPoolUnderlying,
        CurveMetaPool,
        CurveMetaPoolUnderlying,
        CurveFactoryPlainPool,
        CurveFactoryMetaPool,
        CurveFactoryUSDMetaPoolUnderlying,
        CurveFactoryBTCMetaPoolUnderlying,
        LidoStake, // eth to stETH
        LidoWrap // stETH to wstETH or wstETH to stETH
    }

    mapping(address => mapping(address => uint256[])) public routes;

    mapping(address => address) public pool2token;

    function initialize() external initializer {

        OwnableUpgradeable.__Ownable_init();
    }


    function zapFrom(
        address _fromToken,
        uint256 _amountIn,
        address _toToken,
        uint256 _minOut
    ) external payable returns (uint256) {

        if (_isETH(_fromToken)) {
            require(_amountIn == msg.value, "LendFlareZap: amount mismatch");
        } else {
            uint256 before = IERC20Upgradeable(_fromToken).balanceOf(address(this));
            IERC20Upgradeable(_fromToken).safeTransferFrom(msg.sender, address(this), _amountIn);
            _amountIn = IERC20Upgradeable(_fromToken).balanceOf(address(this)) - before;
        }

        return zap(_fromToken, _amountIn, _toToken, _minOut);
    }

    function zap(
        address _fromToken,
        uint256 _amountIn,
        address _toToken,
        uint256 _minOut
    ) public payable override returns (uint256) {

        uint256[] memory _routes = routes[_isETH(_fromToken) ? WETH : _fromToken][_isETH(_toToken) ? WETH : _toToken];

        require(_routes.length > 0, "LendFlareZap: route unavailable");

        uint256 _amount = _amountIn;

        for (uint256 i = 0; i < _routes.length; i++) {
            _amount = _swap(_routes[i], _amount);
        }

        require(_amount >= _minOut, "LendFlareZap: insufficient output");

        if (_isETH(_toToken)) {
            _unwrapIfNeeded(_amount);
            (bool success, ) = msg.sender.call{ value: _amount }("");
            require(success, "LendFlareZap: ETH transfer failed");
        } else {
            _wrapTokenIfNeeded(_toToken, _amount);
            IERC20Upgradeable(_toToken).safeTransfer(msg.sender, _amount);
        }

        return _amount;
    }


    function updateRoute(
        address _fromToken,
        address _toToken,
        uint256[] calldata _routes
    ) public onlyOwner {

        delete routes[_fromToken][_toToken];

        routes[_fromToken][_toToken] = _routes;

        emit UpdateRoute(_fromToken, _toToken, _routes);
    }

    function updateRoutes(
        address[] calldata _fromToken,
        address[] calldata _toToken,
        uint256[][] calldata _routes
    ) external {

        require(_fromToken.length == _toToken.length, "LendFlareZap: length mismatch");

        for (uint256 i = 0; i < _fromToken.length; i++) {
            updateRoute(_fromToken[i], _toToken[i], _routes[i]);
        }
    }

    function updatePoolTokens(address[] calldata _pools, address[] calldata _tokens) external onlyOwner {

        require(_pools.length == _tokens.length, "LendFlareZap: length mismatch");

        for (uint256 i = 0; i < _pools.length; i++) {
            pool2token[_pools[i]] = _tokens[i];
        }
    }

    function rescue(address[] calldata _tokens, address _recipient) external onlyOwner {

        for (uint256 i = 0; i < _tokens.length; i++) {
            IERC20Upgradeable(_tokens[i]).safeTransfer(_recipient, IERC20Upgradeable(_tokens[i]).balanceOf(address(this)));
        }
    }


    function _swap(uint256 _route, uint256 _amountIn) internal returns (uint256) {

        address _pool = address(_route & uint256(1461501637330902918203684832716283019655932542975));

        PoolType _poolType = PoolType((_route >> 160) & 255);

        uint256 _indexIn = (_route >> 170) & 3;
        uint256 _indexOut = (_route >> 172) & 3;
        uint256 _action = (_route >> 174) & 3;

        if (_poolType == PoolType.UniswapV2) {
            return _swapUniswapV2Pair(_pool, _indexIn, _indexOut, _amountIn);
        } else if (_poolType == PoolType.UniswapV3) {
            return _swapUniswapV3Pool(_pool, _indexIn, _indexOut, _amountIn);
        } else if (_poolType == PoolType.BalancerV2) {
            return _swapBalancerPool(_pool, _indexIn, _indexOut, _amountIn);
        } else if (_poolType == PoolType.LidoStake) {
            require(_pool == stETH, "LendFlareZap: pool not stETH");
            return _wrapLidoSTETH(_amountIn, _action);
        } else if (_poolType == PoolType.LidoWrap) {
            require(_pool == wstETH, "LendFlareZap: pool not wstETH");
            return _wrapLidoWSTETH(_amountIn, _action);
        } else {
            if (_action == 0) {
                return _swapCurvePool(_poolType, _pool, _indexIn, _indexOut, _amountIn);
            } else if (_action == 1) {
                uint256 _tokens = ((_route >> 168) & 3) + 1;
                return _addCurvePool(_poolType, _pool, _tokens, _indexIn, _amountIn);
            } else if (_action == 2) {
                return _removeCurvePool(_poolType, _pool, _indexOut, _amountIn);
            } else {
                revert("LendFlareZap: invalid action");
            }
        }
    }

    function _swapUniswapV2Pair(
        address _pool,
        uint256 _indexIn,
        uint256 _indexOut,
        uint256 _amountIn
    ) internal returns (uint256) {

        uint256 _rIn;
        uint256 _rOut;
        address _tokenIn;
        if (_indexIn < _indexOut) {
            (_rIn, _rOut, ) = IUniswapV2Pair(_pool).getReserves();
            _tokenIn = IUniswapV2Pair(_pool).token0();
        } else {
            (_rOut, _rIn, ) = IUniswapV2Pair(_pool).getReserves();
            _tokenIn = IUniswapV2Pair(_pool).token1();
        }
        uint256 _amountOut = _amountIn * 997;
        _amountOut = (_amountOut * _rOut) / (_rIn * 1000 + _amountOut);

        _wrapTokenIfNeeded(_tokenIn, _amountIn);
        IERC20Upgradeable(_tokenIn).safeTransfer(_pool, _amountIn);

        if (_indexIn < _indexOut) {
            IUniswapV2Pair(_pool).swap(0, _amountOut, address(this), new bytes(0));
        } else {
            IUniswapV2Pair(_pool).swap(_amountOut, 0, address(this), new bytes(0));
        }

        return _amountOut;
    }

    function _swapUniswapV3Pool(
        address _pool,
        uint256 _indexIn,
        uint256 _indexOut,
        uint256 _amountIn
    ) internal returns (uint256) {

        address _tokenIn;
        address _tokenOut;
        uint24 _fee = IUniswapV3Pool(_pool).fee();
        if (_indexIn < _indexOut) {
            _tokenIn = IUniswapV3Pool(_pool).token0();
            _tokenOut = IUniswapV3Pool(_pool).token1();
        } else {
            _tokenIn = IUniswapV3Pool(_pool).token1();
            _tokenOut = IUniswapV3Pool(_pool).token0();
        }
        _wrapTokenIfNeeded(_tokenIn, _amountIn);
        _approve(_tokenIn, UNIV3_ROUTER, _amountIn);
        IUniswapV3Router.ExactInputSingleParams memory _params = IUniswapV3Router.ExactInputSingleParams(
            _tokenIn,
            _tokenOut,
            _fee,
            address(this),
            block.timestamp + 1,
            _amountIn,
            1,
            0
        );

        return IUniswapV3Router(UNIV3_ROUTER).exactInputSingle(_params);
    }

    function _swapBalancerPool(
        address _pool,
        uint256 _indexIn,
        uint256 _indexOut,
        uint256 _amountIn
    ) internal returns (uint256) {

        bytes32 _poolId = IBalancerPool(_pool).getPoolId();
        address _tokenIn;
        address _tokenOut;
        {
            (address[] memory _tokens, , ) = IBalancerVault(BALANCER_VAULT).getPoolTokens(_poolId);
            _tokenIn = _tokens[_indexIn];
            _tokenOut = _tokens[_indexOut];
        }
        _wrapTokenIfNeeded(_tokenIn, _amountIn);
        _approve(_tokenIn, BALANCER_VAULT, _amountIn);

        return
            IBalancerVault(BALANCER_VAULT).swap(
                IBalancerVault.SingleSwap({
                    poolId: _poolId,
                    kind: IBalancerVault.SwapKind.GIVEN_IN,
                    assetIn: _tokenIn,
                    assetOut: _tokenOut,
                    amount: _amountIn,
                    userData: new bytes(0)
                }),
                IBalancerVault.FundManagement({
                    sender: address(this),
                    fromInternalBalance: false,
                    recipient: payable(address(this)),
                    toInternalBalance: false
                }),
                0,
                block.timestamp
            );
    }

    function _swapCurvePool(
        PoolType _poolType,
        address _pool,
        uint256 _indexIn,
        uint256 _indexOut,
        uint256 _amountIn
    ) internal returns (uint256) {

        address _tokenIn = _getPoolTokenByIndex(_poolType, _pool, _indexIn);
        address _tokenOut = _getPoolTokenByIndex(_poolType, _pool, _indexOut);

        _wrapTokenIfNeeded(_tokenIn, _amountIn);
        _approve(_tokenIn, _pool, _amountIn);

        uint256 _before = _getBalance(_tokenOut);
        if (_poolType == PoolType.CurveETHPool) {
            if (_isETH(_tokenIn)) {
                _unwrapIfNeeded(_amountIn);
                ICurveETHPool(_pool).exchange{ value: _amountIn }(int128(_indexIn), int128(_indexOut), _amountIn, 0);
            } else {
                ICurveETHPool(_pool).exchange(int128(_indexIn), int128(_indexOut), _amountIn, 0);
            }
        } else if (_poolType == PoolType.CurveCryptoPool) {
            ICurveCryptoPool(_pool).exchange(_indexIn, _indexOut, _amountIn, 0);
        } else if (_poolType == PoolType.CurveMetaCryptoPool) {
            IZapCurveMetaCryptoPool(_pool).exchange_underlying(_indexIn, _indexOut, _amountIn, 0);
        } else if (_poolType == PoolType.CurveTriCryptoPool) {
            ICurveTriCryptoPool(_pool).exchange(_indexIn, _indexOut, _amountIn, 0, false);
        } else if (_poolType == PoolType.CurveBasePool) {
            ICurveBasePool(_pool).exchange(int128(_indexIn), int128(_indexOut), _amountIn, 0);
        } else if (_poolType == PoolType.CurveAPool) {
            ICurveAPool(_pool).exchange(int128(_indexIn), int128(_indexOut), _amountIn, 0);
        } else if (_poolType == PoolType.CurveAPoolUnderlying) {
            ICurveAPool(_pool).exchange_underlying(int128(_indexIn), int128(_indexOut), _amountIn, 0);
        } else if (_poolType == PoolType.CurveYPool) {
            ICurveYPoolSwap(_pool).exchange(int128(_indexIn), int128(_indexOut), _amountIn, 0);
        } else if (_poolType == PoolType.CurveYPoolUnderlying) {
            _pool = ICurveYPoolDeposit(_pool).curve();
            ICurveYPoolSwap(_pool).exchange_underlying(int128(_indexIn), int128(_indexOut), _amountIn, 0);
        } else if (_poolType == PoolType.CurveMetaPool) {
            ICurveMetaPoolSwap(_pool).exchange(int128(_indexIn), int128(_indexOut), _amountIn, 0);
        } else if (_poolType == PoolType.CurveMetaPoolUnderlying) {
            _pool = ICurveMetaPoolDeposit(_pool).pool();
            ICurveMetaPoolSwap(_pool).exchange_underlying(int128(_indexIn), int128(_indexOut), _amountIn, 0);
        } else if (_poolType == PoolType.CurveFactoryPlainPool) {
            ICurveFactoryPlainPool(_pool).exchange(int128(_indexIn), int128(_indexOut), _amountIn, 0, address(this));
        } else if (_poolType == PoolType.CurveFactoryMetaPool) {
            ICurveMetaPoolSwap(_pool).exchange(int128(_indexIn), int128(_indexOut), _amountIn, 0);
        } else if (_poolType == PoolType.CurveFactoryUSDMetaPoolUnderlying) {
            ICurveMetaPoolSwap(_pool).exchange_underlying(int128(_indexIn), int128(_indexOut), _amountIn, 0);
        } else if (_poolType == PoolType.CurveFactoryBTCMetaPoolUnderlying) {
            ICurveMetaPoolSwap(_pool).exchange_underlying(int128(_indexIn), int128(_indexOut), _amountIn, 0);
        } else {
            revert("LendFlareZap: invalid poolType");
        }

        return _getBalance(_tokenOut) - _before;
    }

    function _addCurvePool(
        PoolType _poolType,
        address _pool,
        uint256 _tokens,
        uint256 _indexIn,
        uint256 _amountIn
    ) internal returns (uint256) {

        address _tokenIn = _getPoolTokenByIndex(_poolType, _pool, _indexIn);

        _wrapTokenIfNeeded(_tokenIn, _amountIn);

        if (_poolType == PoolType.CurveFactoryUSDMetaPoolUnderlying) {
            _approve(_tokenIn, CURVE_3POOL_DEPOSIT_ZAP, _amountIn);
        } else if (_poolType == PoolType.CurveFactoryBTCMetaPoolUnderlying) {
            _approve(_tokenIn, CURVE_SBTC_DEPOSIT_ZAP, _amountIn);
        } else {
            _approve(_tokenIn, _pool, _amountIn);
        }

        if (_poolType == PoolType.CurveAPool || _poolType == PoolType.CurveAPoolUnderlying) {
            bool _useUnderlying = _poolType == PoolType.CurveAPoolUnderlying;
            if (_tokens == 2) {
                uint256[2] memory _amounts;
                _amounts[_indexIn] = _amountIn;

                return ICurveA2Pool(_pool).add_liquidity(_amounts, 0, _useUnderlying);
            } else if (_tokens == 3) {
                uint256[3] memory _amounts;
                _amounts[_indexIn] = _amountIn;

                return ICurveA3Pool(_pool).add_liquidity(_amounts, 0, _useUnderlying);
            } else {
                uint256[4] memory _amounts;
                _amounts[_indexIn] = _amountIn;

                return ICurveA4Pool(_pool).add_liquidity(_amounts, 0, _useUnderlying);
            }
        } else if (_poolType == PoolType.CurveFactoryUSDMetaPoolUnderlying) {
            uint256[4] memory _amounts;
            _amounts[_indexIn] = _amountIn;

            return ICurveDepositZap(CURVE_3POOL_DEPOSIT_ZAP).add_liquidity(_pool, _amounts, 0);
        } else if (_poolType == PoolType.CurveFactoryBTCMetaPoolUnderlying) {
            uint256[4] memory _amounts;
            _amounts[_indexIn] = _amountIn;

            return ICurveDepositZap(CURVE_SBTC_DEPOSIT_ZAP).add_liquidity(_pool, _amounts, 0);
        } else if (_poolType == PoolType.CurveETHPool) {
            if (_isETH(_tokenIn)) {
                _unwrapIfNeeded(_amountIn);
            }
            uint256[2] memory _amounts;
            _amounts[_indexIn] = _amountIn;

            return ICurveETHPool(_pool).add_liquidity{ value: _amounts[0] }(_amounts, 0);
        } else {
            address _tokenOut = pool2token[_pool];
            uint256 _before = IERC20Upgradeable(_tokenOut).balanceOf(address(this));

            if (_tokens == 2) {
                uint256[2] memory _amounts;
                _amounts[_indexIn] = _amountIn;
                ICurveBase2Pool(_pool).add_liquidity(_amounts, 0);
            } else if (_tokens == 3) {
                uint256[3] memory _amounts;
                _amounts[_indexIn] = _amountIn;
                ICurveBase3Pool(_pool).add_liquidity(_amounts, 0);
            } else {
                uint256[4] memory _amounts;
                _amounts[_indexIn] = _amountIn;
                ICurveBase4Pool(_pool).add_liquidity(_amounts, 0);
            }

            return IERC20Upgradeable(_tokenOut).balanceOf(address(this)) - _before;
        }
    }

    function _removeCurvePool(
        PoolType _poolType,
        address _pool,
        uint256 _indexOut,
        uint256 _amountIn
    ) internal returns (uint256) {

        address _tokenOut = _getPoolTokenByIndex(_poolType, _pool, _indexOut);
        address _tokenIn = pool2token[_pool];

        uint256 _before = _getBalance(_tokenOut);
        if (_poolType == PoolType.CurveAPool || _poolType == PoolType.CurveAPoolUnderlying) {
            bool _useUnderlying = _poolType == PoolType.CurveAPoolUnderlying;
            ICurveAPool(_pool).remove_liquidity_one_coin(_amountIn, int128(_indexOut), 0, _useUnderlying);
        } else if (_poolType == PoolType.CurveCryptoPool) {
            ICurveCryptoPool(_pool).remove_liquidity_one_coin(_amountIn, _indexOut, 0);
        } else if (_poolType == PoolType.CurveMetaCryptoPool) {
            _approve(_tokenIn, _pool, _amountIn);
            IZapCurveMetaCryptoPool(_pool).remove_liquidity_one_coin(_amountIn, _indexOut, 0);
        } else if (_poolType == PoolType.CurveTriCryptoPool) {
            ICurveTriCryptoPool(_pool).remove_liquidity_one_coin(_amountIn, _indexOut, 0);
        } else if (_poolType == PoolType.CurveFactoryUSDMetaPoolUnderlying) {
            _approve(_tokenIn, CURVE_3POOL_DEPOSIT_ZAP, _amountIn);
            ICurveDepositZap(CURVE_3POOL_DEPOSIT_ZAP).remove_liquidity_one_coin(_pool, _amountIn, int128(_indexOut), 0);
        } else if (_poolType == PoolType.CurveFactoryBTCMetaPoolUnderlying) {
            _approve(_tokenIn, CURVE_SBTC_DEPOSIT_ZAP, _amountIn);
            ICurveDepositZap(CURVE_SBTC_DEPOSIT_ZAP).remove_liquidity_one_coin(_pool, _amountIn, int128(_indexOut), 0);
        } else if (_poolType == PoolType.CurveMetaPoolUnderlying) {
            _approve(_tokenIn, _pool, _amountIn);
            ICurveMetaPoolDeposit(_pool).remove_liquidity_one_coin(_amountIn, int128(_indexOut), 0);
        } else {
            ICurveBasePool(_pool).remove_liquidity_one_coin(_amountIn, int128(_indexOut), 0);
        }

        return _getBalance(_tokenOut) - _before;
    }

    function _wrapLidoSTETH(uint256 _amountIn, uint256 _action) internal returns (uint256) {

        require(_action == 1, "LendFlareZap: not wrap action");
        _unwrapIfNeeded(_amountIn);
        uint256 _before = IERC20Upgradeable(stETH).balanceOf(address(this));
        ILidoStETH(stETH).submit{ value: _amountIn }(address(0));
        return IERC20Upgradeable(stETH).balanceOf(address(this)).sub(_before);
    }

    function _wrapLidoWSTETH(uint256 _amountIn, uint256 _action) internal returns (uint256) {

        if (_action == 1) {
            _approve(stETH, wstETH, _amountIn);

            return ILidoWstETH(wstETH).wrap(_amountIn);
        } else if (_action == 2) {
            return ILidoWstETH(wstETH).unwrap(_amountIn);
        } else {
            revert("LendFlareZap: invalid action");
        }
    }

    function _getBalance(address _token) internal view returns (uint256) {

        if (_isETH(_token)) return address(this).balance;
        else return IERC20Upgradeable(_token).balanceOf(address(this));
    }

    function _getPoolTokenByIndex(
        PoolType _type,
        address _pool,
        uint256 _index
    ) internal view returns (address) {

        if (_type == PoolType.CurveMetaCryptoPool) {
            return IZapCurveMetaCryptoPool(_pool).underlying_coins(_index);
        } else if (_type == PoolType.CurveAPoolUnderlying) {
            return ICurveAPool(_pool).underlying_coins(_index);
        } else if (_type == PoolType.CurveYPoolUnderlying) {
            return ICurveYPoolDeposit(_pool).underlying_coins(_index);
        } else if (_type == PoolType.CurveMetaPoolUnderlying) {
            return ICurveMetaPoolDeposit(_pool).base_coins(_index);
        } else if (_type == PoolType.CurveFactoryUSDMetaPoolUnderlying) {
            if (_index == 0) return ICurveBasePool(_pool).coins(_index);
            else return _get3PoolTokenByIndex(_index - 1);
        } else if (_type == PoolType.CurveFactoryBTCMetaPoolUnderlying) {
            if (_index == 0) return ICurveBasePool(_pool).coins(_index);
            else return _getSBTCTokenByIndex(_index - 1);
        } else {
            try ICurveBasePool(_pool).coins(_index) returns (address _token) {
                return _token;
            } catch {
                return ICurveBasePool(_pool).coins(int128(_index));
            }
        }
    }

    function _get3PoolTokenByIndex(uint256 _index) internal pure returns (address) {

        if (_index == 0) return DAI;
        else if (_index == 1) return USDC;
        else if (_index == 2) return USDT;
        else return address(0);
    }

    function _getSBTCTokenByIndex(uint256 _index) internal pure returns (address) {

        if (_index == 0) return RENBTC;
        else if (_index == 1) return WBTC;
        else if (_index == 2) return SBTC;
        else return address(0);
    }

    function _isETH(address _token) internal pure returns (bool) {

        return _token == ETH || _token == address(0);
    }

    function _wrapTokenIfNeeded(address _token, uint256 _amount) internal {

        if (_token == WETH && IERC20Upgradeable(_token).balanceOf(address(this)) < _amount) {
            IWETH(_token).deposit{ value: _amount }();
        }
    }

    function _unwrapIfNeeded(uint256 _amount) internal {

        if (address(this).balance < _amount) {
            IWETH(WETH).withdraw(_amount);
        }
    }

    function _approve(
        address _token,
        address _spender,
        uint256 _amount
    ) internal {

        if (!_isETH(_token) && IERC20Upgradeable(_token).allowance(address(this), _spender) < _amount) {
            IERC20Upgradeable(_token).safeApprove(_spender, 0);
            IERC20Upgradeable(_token).safeApprove(_spender, _amount);
        }
    }

    receive() external payable {}
}