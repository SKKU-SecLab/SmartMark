
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
}

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
}

pragma solidity >=0.6.0 <0.8.0;

library EnumerableSet {


    struct Set {
        bytes32[] _values;

        mapping (bytes32 => uint256) _indexes;
    }

    function _add(Set storage set, bytes32 value) private returns (bool) {

        if (!_contains(set, value)) {
            set._values.push(value);
            set._indexes[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

    function _remove(Set storage set, bytes32 value) private returns (bool) {

        uint256 valueIndex = set._indexes[value];

        if (valueIndex != 0) { // Equivalent to contains(set, value)

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;


            bytes32 lastvalue = set._values[lastIndex];

            set._values[toDeleteIndex] = lastvalue;
            set._indexes[lastvalue] = toDeleteIndex + 1; // All indexes are 1-based

            set._values.pop();

            delete set._indexes[value];

            return true;
        } else {
            return false;
        }
    }

    function _contains(Set storage set, bytes32 value) private view returns (bool) {

        return set._indexes[value] != 0;
    }

    function _length(Set storage set) private view returns (uint256) {

        return set._values.length;
    }

    function _at(Set storage set, uint256 index) private view returns (bytes32) {

        require(set._values.length > index, "EnumerableSet: index out of bounds");
        return set._values[index];
    }


    struct Bytes32Set {
        Set _inner;
    }

    function add(Bytes32Set storage set, bytes32 value) internal returns (bool) {

        return _add(set._inner, value);
    }

    function remove(Bytes32Set storage set, bytes32 value) internal returns (bool) {

        return _remove(set._inner, value);
    }

    function contains(Bytes32Set storage set, bytes32 value) internal view returns (bool) {

        return _contains(set._inner, value);
    }

    function length(Bytes32Set storage set) internal view returns (uint256) {

        return _length(set._inner);
    }

    function at(Bytes32Set storage set, uint256 index) internal view returns (bytes32) {

        return _at(set._inner, index);
    }


    struct AddressSet {
        Set _inner;
    }

    function add(AddressSet storage set, address value) internal returns (bool) {

        return _add(set._inner, bytes32(uint256(uint160(value))));
    }

    function remove(AddressSet storage set, address value) internal returns (bool) {

        return _remove(set._inner, bytes32(uint256(uint160(value))));
    }

    function contains(AddressSet storage set, address value) internal view returns (bool) {

        return _contains(set._inner, bytes32(uint256(uint160(value))));
    }

    function length(AddressSet storage set) internal view returns (uint256) {

        return _length(set._inner);
    }

    function at(AddressSet storage set, uint256 index) internal view returns (address) {

        return address(uint160(uint256(_at(set._inner, index))));
    }



    struct UintSet {
        Set _inner;
    }

    function add(UintSet storage set, uint256 value) internal returns (bool) {

        return _add(set._inner, bytes32(value));
    }

    function remove(UintSet storage set, uint256 value) internal returns (bool) {

        return _remove(set._inner, bytes32(value));
    }

    function contains(UintSet storage set, uint256 value) internal view returns (bool) {

        return _contains(set._inner, bytes32(value));
    }

    function length(UintSet storage set) internal view returns (uint256) {

        return _length(set._inner);
    }

    function at(UintSet storage set, uint256 index) internal view returns (uint256) {

        return uint256(_at(set._inner, index));
    }
}

pragma solidity >=0.6.0 <0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

pragma solidity >=0.6.0 <0.8.0;


abstract contract AccessControl is Context {
    using EnumerableSet for EnumerableSet.AddressSet;
    using Address for address;

    struct RoleData {
        EnumerableSet.AddressSet members;
        bytes32 adminRole;
    }

    mapping (bytes32 => RoleData) private _roles;

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);

    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    function hasRole(bytes32 role, address account) public view returns (bool) {
        return _roles[role].members.contains(account);
    }

    function getRoleMemberCount(bytes32 role) public view returns (uint256) {
        return _roles[role].members.length();
    }

    function getRoleMember(bytes32 role, uint256 index) public view returns (address) {
        return _roles[role].members.at(index);
    }

    function getRoleAdmin(bytes32 role) public view returns (bytes32) {
        return _roles[role].adminRole;
    }

    function grantRole(bytes32 role, address account) public virtual {
        require(hasRole(_roles[role].adminRole, _msgSender()), "AccessControl: sender must be an admin to grant");

        _grantRole(role, account);
    }

    function revokeRole(bytes32 role, address account) public virtual {
        require(hasRole(_roles[role].adminRole, _msgSender()), "AccessControl: sender must be an admin to revoke");

        _revokeRole(role, account);
    }

    function renounceRole(bytes32 role, address account) public virtual {
        require(account == _msgSender(), "AccessControl: can only renounce roles for self");

        _revokeRole(role, account);
    }

    function _setupRole(bytes32 role, address account) internal virtual {
        _grantRole(role, account);
    }

    function _setRoleAdmin(bytes32 role, bytes32 adminRole) internal virtual {
        emit RoleAdminChanged(role, _roles[role].adminRole, adminRole);
        _roles[role].adminRole = adminRole;
    }

    function _grantRole(bytes32 role, address account) private {
        if (_roles[role].members.add(account)) {
            emit RoleGranted(role, account, _msgSender());
        }
    }

    function _revokeRole(bytes32 role, address account) private {
        if (_roles[role].members.remove(account)) {
            emit RoleRevoked(role, account, _msgSender());
        }
    }
}

pragma solidity >=0.5.0;

interface IUniswapV2Factory {

    event PairCreated(address indexed token0, address indexed token1, address pair, uint256);

    function feeTo() external view returns (address);


    function feeToSetter() external view returns (address);


    function migrator() external view returns (address);


    function getPair(address tokenA, address tokenB) external view returns (address pair);


    function allPairs(uint256) external view returns (address pair);


    function allPairsLength() external view returns (uint256);


    function createPair(address tokenA, address tokenB) external returns (address pair);


    function setFeeTo(address) external;


    function setFeeToSetter(address) external;


    function setMigrator(address) external;

}

interface IUniswapV2Pair {

    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Transfer(address indexed from, address indexed to, uint256 value);

    function name() external pure returns (string memory);


    function symbol() external pure returns (string memory);


    function decimals() external pure returns (uint8);


    function totalSupply() external view returns (uint256);


    function balanceOf(address owner) external view returns (uint256);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 value) external returns (bool);


    function transfer(address to, uint256 value) external returns (bool);


    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);


    function DOMAIN_SEPARATOR() external view returns (bytes32);


    function PERMIT_TYPEHASH() external pure returns (bytes32);


    function nonces(address owner) external view returns (uint256);


    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;


    event Mint(address indexed sender, uint256 amount0, uint256 amount1);
    event Burn(address indexed sender, uint256 amount0, uint256 amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint256 amount0In,
        uint256 amount1In,
        uint256 amount0Out,
        uint256 amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint256);


    function factory() external view returns (address);


    function token0() external view returns (address);


    function token1() external view returns (address);


    function getReserves()
        external
        view
        returns (
            uint112 reserve0,
            uint112 reserve1,
            uint32 blockTimestampLast
        );


    function price0CumulativeLast() external view returns (uint256);


    function price1CumulativeLast() external view returns (uint256);


    function kLast() external view returns (uint256);


    function mint(address to) external returns (uint256 liquidity);


    function burn(address to) external returns (uint256 amount0, uint256 amount1);


    function swap(
        uint256 amount0Out,
        uint256 amount1Out,
        address to,
        bytes calldata data
    ) external;


    function skim(address to) external;


    function sync() external;


    function initialize(address, address) external;

}

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


    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
        external
        payable
        returns (
            uint256 amountToken,
            uint256 amountETH,
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


    function removeLiquidityETH(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountToken, uint256 amountETH);


    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountA, uint256 amountB);


    function removeLiquidityETHWithPermit(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountToken, uint256 amountETH);


    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);


    function swapTokensForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);


    function swapExactETHForTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);


    function swapTokensForExactETH(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);


    function swapExactTokensForETH(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);


    function swapETHForExactTokens(
        uint256 amountOut,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);


    function quote(
        uint256 amountA,
        uint256 reserveA,
        uint256 reserveB
    ) external pure returns (uint256 amountB);


    function getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountOut);


    function getAmountIn(
        uint256 amountOut,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountIn);


    function getAmountsOut(uint256 amountIn, address[] calldata path) external view returns (uint256[] memory amounts);


    function getAmountsIn(uint256 amountOut, address[] calldata path) external view returns (uint256[] memory amounts);

}

interface IUniswapV2Router02 is IUniswapV2Router01 {

    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountETH);


    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountETH);


    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;


    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;


    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

}

pragma solidity ^0.7.3;

interface IATokenV1 {

    function UINT_MAX_VALUE() external view returns (uint256);


    function allowInterestRedirectionTo(address _to) external;


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 value) external returns (bool);


    function balanceOf(address _user) external view returns (uint256);


    function burnOnLiquidation(address _account, uint256 _value) external;


    function decimals() external view returns (uint8);


    function decreaseAllowance(address spender, uint256 subtractedValue) external returns (bool);


    function getInterestRedirectionAddress(address _user) external view returns (address);


    function getRedirectedBalance(address _user) external view returns (uint256);


    function getUserIndex(address _user) external view returns (uint256);


    function increaseAllowance(address spender, uint256 addedValue) external returns (bool);


    function isTransferAllowed(address _user, uint256 _amount) external view returns (bool);


    function mintOnDeposit(address _account, uint256 _amount) external;


    function name() external view returns (string memory);


    function principalBalanceOf(address _user) external view returns (uint256);


    function redeem(uint256 _amount) external;


    function redirectInterestStream(address _to) external;


    function redirectInterestStreamOf(address _from, address _to) external;


    function symbol() external view returns (string memory);


    function totalSupply() external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);


    function transferOnLiquidation(
        address _from,
        address _to,
        uint256 _value
    ) external;


    function underlyingAssetAddress() external view returns (address);

}

pragma solidity ^0.7.3;

interface ICToken {

    function _acceptAdmin() external returns (uint256);


    function _addReserves(uint256 addAmount) external returns (uint256);


    function _reduceReserves(uint256 reduceAmount) external returns (uint256);


    function _setComptroller(address newComptroller) external returns (uint256);


    function _setImplementation(
        address implementation_,
        bool allowResign,
        bytes memory becomeImplementationData
    ) external;


    function _setInterestRateModel(address newInterestRateModel) external returns (uint256);


    function _setPendingAdmin(address newPendingAdmin) external returns (uint256);


    function _setReserveFactor(uint256 newReserveFactorMantissa) external returns (uint256);


    function accrualBlockNumber() external view returns (uint256);


    function accrueInterest() external returns (uint256);


    function admin() external view returns (address);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function balanceOf(address owner) external view returns (uint256);


    function balanceOfUnderlying(address owner) external returns (uint256);


    function borrow(uint256 borrowAmount) external returns (uint256);


    function borrowBalanceCurrent(address account) external returns (uint256);


    function borrowBalanceStored(address account) external view returns (uint256);


    function borrowIndex() external view returns (uint256);


    function borrowRatePerBlock() external view returns (uint256);


    function comptroller() external view returns (address);


    function decimals() external view returns (uint8);


    function delegateToImplementation(bytes memory data) external returns (bytes memory);


    function delegateToViewImplementation(bytes memory data) external view returns (bytes memory);


    function exchangeRateCurrent() external returns (uint256);


    function exchangeRateStored() external view returns (uint256);


    function getAccountSnapshot(address account)
        external
        view
        returns (
            uint256,
            uint256,
            uint256,
            uint256
        );


    function getCash() external view returns (uint256);


    function implementation() external view returns (address);


    function interestRateModel() external view returns (address);


    function isCToken() external view returns (bool);


    function liquidateBorrow(
        address borrower,
        uint256 repayAmount,
        address cTokenCollateral
    ) external returns (uint256);


    function mint(uint256 mintAmount) external returns (uint256);


    function name() external view returns (string memory);


    function pendingAdmin() external view returns (address);


    function redeem(uint256 redeemTokens) external returns (uint256);


    function redeemUnderlying(uint256 redeemAmount) external returns (uint256);


    function repayBorrow(uint256 repayAmount) external returns (uint256);


    function repayBorrowBehalf(address borrower, uint256 repayAmount) external returns (uint256);


    function reserveFactorMantissa() external view returns (uint256);


    function seize(
        address liquidator,
        address borrower,
        uint256 seizeTokens
    ) external returns (uint256);


    function supplyRatePerBlock() external view returns (uint256);


    function symbol() external view returns (string memory);


    function totalBorrows() external view returns (uint256);


    function totalBorrowsCurrent() external returns (uint256);


    function totalReserves() external view returns (uint256);


    function totalSupply() external view returns (uint256);


    function transfer(address dst, uint256 amount) external returns (bool);


    function transferFrom(
        address src,
        address dst,
        uint256 amount
    ) external returns (bool);


    function underlying() external view returns (address);

}

pragma solidity ^0.7.3;

interface IComptroller {

    function _addCompMarkets(address[] memory cTokens) external;


    function _become(address unitroller) external;


    function _borrowGuardianPaused() external view returns (bool);


    function _dropCompMarket(address cToken) external;


    function _grantComp(address recipient, uint256 amount) external;


    function _mintGuardianPaused() external view returns (bool);


    function _setBorrowCapGuardian(address newBorrowCapGuardian) external;


    function _setBorrowPaused(address cToken, bool state) external returns (bool);


    function _setCloseFactor(uint256 newCloseFactorMantissa) external returns (uint256);


    function _setCollateralFactor(address cToken, uint256 newCollateralFactorMantissa) external returns (uint256);


    function _setCompRate(uint256 compRate_) external;


    function _setContributorCompSpeed(address contributor, uint256 compSpeed) external;


    function _setLiquidationIncentive(uint256 newLiquidationIncentiveMantissa) external returns (uint256);


    function _setMarketBorrowCaps(address[] memory cTokens, uint256[] memory newBorrowCaps) external;


    function _setMintPaused(address cToken, bool state) external returns (bool);


    function _setPauseGuardian(address newPauseGuardian) external returns (uint256);


    function _setPriceOracle(address newOracle) external returns (uint256);


    function _setSeizePaused(bool state) external returns (bool);


    function _setTransferPaused(bool state) external returns (bool);


    function _supportMarket(address cToken) external returns (uint256);


    function accountAssets(address, uint256) external view returns (address);


    function admin() external view returns (address);


    function allMarkets(uint256) external view returns (address);


    function borrowAllowed(
        address cToken,
        address borrower,
        uint256 borrowAmount
    ) external returns (uint256);


    function borrowCapGuardian() external view returns (address);


    function borrowCaps(address) external view returns (uint256);


    function borrowGuardianPaused(address) external view returns (bool);


    function borrowVerify(
        address cToken,
        address borrower,
        uint256 borrowAmount
    ) external;


    function checkMembership(address account, address cToken) external view returns (bool);


    function claimComp(address holder, address[] memory cTokens) external;


    function claimComp(
        address[] memory holders,
        address[] memory cTokens,
        bool borrowers,
        bool suppliers
    ) external;


    function claimComp(address holder) external;


    function closeFactorMantissa() external view returns (uint256);


    function compAccrued(address) external view returns (uint256);


    function compBorrowState(address) external view returns (uint224 index, uint32);


    function compBorrowerIndex(address, address) external view returns (uint256);


    function compClaimThreshold() external view returns (uint256);


    function compContributorSpeeds(address) external view returns (uint256);


    function compInitialIndex() external view returns (uint224);


    function compRate() external view returns (uint256);


    function compSpeeds(address) external view returns (uint256);


    function compSupplierIndex(address, address) external view returns (uint256);


    function compSupplyState(address) external view returns (uint224 index, uint32);


    function comptrollerImplementation() external view returns (address);


    function enterMarkets(address[] memory cTokens) external returns (uint256[] memory);


    function exitMarket(address cTokenAddress) external returns (uint256);


    function getAccountLiquidity(address account)
        external
        view
        returns (
            uint256,
            uint256,
            uint256
        );


    function getAllMarkets() external view returns (address[] memory);


    function getAssetsIn(address account) external view returns (address[] memory);


    function getBlockNumber() external view returns (uint256);


    function getCompAddress() external view returns (address);


    function getHypotheticalAccountLiquidity(
        address account,
        address cTokenModify,
        uint256 redeemTokens,
        uint256 borrowAmount
    )
        external
        view
        returns (
            uint256,
            uint256,
            uint256
        );


    function isComptroller() external view returns (bool);


    function lastContributorBlock(address) external view returns (uint256);


    function liquidateBorrowAllowed(
        address cTokenBorrowed,
        address cTokenCollateral,
        address liquidator,
        address borrower,
        uint256 repayAmount
    ) external returns (uint256);


    function liquidateBorrowVerify(
        address cTokenBorrowed,
        address cTokenCollateral,
        address liquidator,
        address borrower,
        uint256 actualRepayAmount,
        uint256 seizeTokens
    ) external;


    function liquidateCalculateSeizeTokens(
        address cTokenBorrowed,
        address cTokenCollateral,
        uint256 actualRepayAmount
    ) external view returns (uint256, uint256);


    function liquidationIncentiveMantissa() external view returns (uint256);


    function markets(address)
        external
        view
        returns (
            bool isListed,
            uint256 collateralFactorMantissa,
            bool isComped
        );


    function maxAssets() external view returns (uint256);


    function mintAllowed(
        address cToken,
        address minter,
        uint256 mintAmount
    ) external returns (uint256);


    function mintGuardianPaused(address) external view returns (bool);


    function mintVerify(
        address cToken,
        address minter,
        uint256 actualMintAmount,
        uint256 mintTokens
    ) external;


    function oracle() external view returns (address);


    function pauseGuardian() external view returns (address);


    function pendingAdmin() external view returns (address);


    function pendingComptrollerImplementation() external view returns (address);


    function redeemAllowed(
        address cToken,
        address redeemer,
        uint256 redeemTokens
    ) external returns (uint256);


    function redeemVerify(
        address cToken,
        address redeemer,
        uint256 redeemAmount,
        uint256 redeemTokens
    ) external;


    function refreshCompSpeeds() external;


    function repayBorrowAllowed(
        address cToken,
        address payer,
        address borrower,
        uint256 repayAmount
    ) external returns (uint256);


    function repayBorrowVerify(
        address cToken,
        address payer,
        address borrower,
        uint256 actualRepayAmount,
        uint256 borrowerIndex
    ) external;


    function seizeAllowed(
        address cTokenCollateral,
        address cTokenBorrowed,
        address liquidator,
        address borrower,
        uint256 seizeTokens
    ) external returns (uint256);


    function seizeGuardianPaused() external view returns (bool);


    function seizeVerify(
        address cTokenCollateral,
        address cTokenBorrowed,
        address liquidator,
        address borrower,
        uint256 seizeTokens
    ) external;


    function transferAllowed(
        address cToken,
        address src,
        address dst,
        uint256 transferTokens
    ) external returns (uint256);


    function transferGuardianPaused() external view returns (bool);


    function transferVerify(
        address cToken,
        address src,
        address dst,
        uint256 transferTokens
    ) external;


    function updateContributorRewards(address contributor) external;

}

pragma solidity ^0.7.3;

interface ISushiBar {

    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function balanceOf(address account) external view returns (uint256);


    function decimals() external view returns (uint8);


    function decreaseAllowance(address spender, uint256 subtractedValue) external returns (bool);


    function enter(uint256 _amount) external;


    function increaseAllowance(address spender, uint256 addedValue) external returns (bool);


    function leave(uint256 _share) external;


    function name() external view returns (string memory);


    function sushi() external view returns (address);


    function symbol() external view returns (string memory);


    function totalSupply() external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

}

pragma solidity ^0.7.3;

interface ILendingPoolV1 {

    function LENDINGPOOL_REVISION() external view returns (uint256);


    function UINT_MAX_VALUE() external view returns (uint256);


    function addressesProvider() external view returns (address);


    function borrow(
        address _reserve,
        uint256 _amount,
        uint256 _interestRateMode,
        uint16 _referralCode
    ) external;


    function core() external view returns (address);


    function dataProvider() external view returns (address);


    function deposit(
        address _reserve,
        uint256 _amount,
        uint16 _referralCode
    ) external payable;


    function flashLoan(
        address _receiver,
        address _reserve,
        uint256 _amount,
        bytes memory _params
    ) external;


    function getReserveConfigurationData(address _reserve)
        external
        view
        returns (
            uint256 ltv,
            uint256 liquidationThreshold,
            uint256 liquidationBonus,
            address interestRateStrategyAddress,
            bool usageAsCollateralEnabled,
            bool borrowingEnabled,
            bool stableBorrowRateEnabled,
            bool isActive
        );


    function getReserveData(address _reserve)
        external
        view
        returns (
            uint256 totalLiquidity,
            uint256 availableLiquidity,
            uint256 totalBorrowsStable,
            uint256 totalBorrowsVariable,
            uint256 liquidityRate,
            uint256 variableBorrowRate,
            uint256 stableBorrowRate,
            uint256 averageStableBorrowRate,
            uint256 utilizationRate,
            uint256 liquidityIndex,
            uint256 variableBorrowIndex,
            address aTokenAddress,
            uint40 lastUpdateTimestamp
        );


    function getReserves() external view returns (address[] memory);


    function getUserAccountData(address _user)
        external
        view
        returns (
            uint256 totalLiquidityETH,
            uint256 totalCollateralETH,
            uint256 totalBorrowsETH,
            uint256 totalFeesETH,
            uint256 availableBorrowsETH,
            uint256 currentLiquidationThreshold,
            uint256 ltv,
            uint256 healthFactor
        );


    function getUserReserveData(address _reserve, address _user)
        external
        view
        returns (
            uint256 currentATokenBalance,
            uint256 currentBorrowBalance,
            uint256 principalBorrowBalance,
            uint256 borrowRateMode,
            uint256 borrowRate,
            uint256 liquidityRate,
            uint256 originationFee,
            uint256 variableBorrowIndex,
            uint256 lastUpdateTimestamp,
            bool usageAsCollateralEnabled
        );


    function initialize(address _addressesProvider) external;


    function liquidationCall(
        address _collateral,
        address _reserve,
        address _user,
        uint256 _purchaseAmount,
        bool _receiveAToken
    ) external payable;


    function parametersProvider() external view returns (address);


    function rebalanceStableBorrowRate(address _reserve, address _user) external;


    function redeemUnderlying(
        address _reserve,
        address _user,
        uint256 _amount,
        uint256 _aTokenBalanceAfterRedeem
    ) external;


    function repay(
        address _reserve,
        uint256 _amount,
        address _onBehalfOf
    ) external payable;


    function setUserUseReserveAsCollateral(address _reserve, bool _useAsCollateral) external;


    function swapBorrowRateMode(address _reserve) external;

}

pragma solidity ^0.7.3;

interface ICompoundLens {

    function getCompBalanceMetadataExt(
        address comp,
        address comptroller,
        address account
    )
        external
        returns (
            uint256 balance,
            uint256 votes,
            address delegate,
            uint256 allocated
        );

}

pragma solidity ^0.7.3;



contract FeeDistributorHelpers {

    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    address constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    address constant BASK = 0x44564d0bd94343f72E3C8a0D22308B7Fa71DB0Bb;
    address constant XBASK = 0x5C0e75EB4b27b5F9c99D78Fc96AFf7869eDa007b;

    address constant LENDING_POOL_V1 = 0x398eC7346DcD622eDc5ae82352F02bE94C62d119;
    address constant LENDING_POOL_CORE_V1 = 0x3dfd23A6c5E8BbcFc9581d2E864a68feb6a076d3;

    address constant COMPTROLLER = 0x3d9819210A31b4961b30EF54bE2aeD79B9c9Cd3B;

    address constant XSUSHI = 0x8798249c2E607446EfB7Ad49eC89dD1865Ff4272;

    address constant CUNI = 0x35A18000230DA775CAc24873d00Ff85BccdeD550;
    address constant CCOMP = 0x70e36f6BF80a52b3B46b3aF8e106CC0ed743E8e4;

    address constant AYFIv1 = 0x12e51E77DAAA58aA0E9247db7510Ea4B46F9bEAd;
    address constant ASNXv1 = 0x328C4c80BC7aCa0834Db37e6600A6c49E12Da4DE;
    address constant AMKRv1 = 0x7deB5e830be29F91E298ba5FF1356BB7f8146998;
    address constant ARENv1 = 0x69948cC03f478B95283F7dbf1CE764d0fc7EC54C;
    address constant AKNCv1 = 0x9D91BE44C06d373a8a226E1f3b146956083803eB;

    address constant UNI = 0x1f9840a85d5aF5bf1D1762F925BDADdC4201F984;
    address constant COMP = 0xc00e94Cb662C3520282E6f5717214004A7f26888;
    address constant YFI = 0x0bc529c00C6401aEF6D220BE8C6Ea1667F6Ad93e;
    address constant SNX = 0xC011a73ee8576Fb46F5E1c5751cA3B9Fe0af2a6F;
    address constant MKR = 0x9f8F72aA9304c8B593d555F12eF6589cC3A579A2;
    address constant REN = 0x408e41876cCCDC0F92210600ef50372656052a38;
    address constant KNC = 0xdd974D5C2e2928deA5F71b9825b8b646686BD200;
    address constant LRC = 0xBBbbCA6A901c926F240b89EacB641d8Aec7AEafD;
    address constant BAL = 0xba100000625a3754423978a60c9317c58a424e3D;
    address constant AAVE = 0x7Fc66500c84A76Ad7e9c93437bFc5Ac33E2DDaE9;
    address constant MTA = 0xa3BeD4E1c75D00fa6f4E5E6922DB7261B5E9AcD2;
    address constant SUSHI = 0x6B3595068778DD592e39A122f4f5a5cF09C90fE2;

    function enterMarkets(address[] memory _markets) external {

        IComptroller(COMPTROLLER).enterMarkets(_markets);
    }


    function _toUnderlying(address _derivative) internal returns (address) {

        if (_isCToken(_derivative)) {
            return _fromCToken(_derivative);
        }

        if (_isATokenV1(_derivative)) {
            return _fromATokenV1(_derivative);
        }

        if (_derivative == XSUSHI) {
            return _fromXSushi();
        }

        return _derivative;
    }

    function _isCToken(address _ctoken) public pure returns (bool) {

        return (_ctoken == CCOMP || _ctoken == CUNI);
    }

    function _isATokenV1(address _atoken) public pure returns (bool) {

        return (_atoken == AYFIv1 || _atoken == ASNXv1 || _atoken == AMKRv1 || _atoken == ARENv1 || _atoken == AKNCv1);
    }

    function _fromCToken(address _ctoken) internal returns (address _token) {

        require(_ctoken == CUNI || _ctoken == CCOMP, "!valid-from-ctoken");

        _token = ICToken(_ctoken).underlying();
        uint256 balance = ICToken(_ctoken).balanceOf(address(this));

        require(balance > 0, "!ctoken-bal");

        require(ICToken(_ctoken).redeem(balance) == 0, "!ctoken-redeem");
    }

    function _fromATokenV1(address _atoken) internal returns (address _token) {

        uint256 balance = IATokenV1(_atoken).balanceOf(address(this));

        require(balance > 0, "!atoken-bal");

        IATokenV1(_atoken).redeem(balance);
        _token = IATokenV1(_atoken).underlyingAssetAddress();
    }

    function _fromXSushi() internal returns (address) {

        uint256 balance = IERC20(XSUSHI).balanceOf(address(this));
        require(balance > 0, "!xsushi-bal");

        ISushiBar(XSUSHI).leave(balance);
        return SUSHI;
    }
}

pragma solidity ^0.7.3;





contract FeeDistributor is FeeDistributorHelpers, AccessControl {

    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    uint256[] public fees; // Should add up to 1e18
    address[] public feeRecipients;
    address[] public feeRecipientAssets;

    mapping(address => address) internal _bridges;
    mapping(bytes32 => address) internal _factories;

    event LogFactorySet(address indexed fromToken, address indexed toToken, address indexed factory);
    event LogBridgeSet(address indexed token, address indexed bridge);
    event LogConverted(
        address indexed server,
        address indexed token0,
        address indexed token1,
        address recipient,
        uint256 amount0,
        uint256 amount1
    );

    IUniswapV2Factory constant sushiswapFactory = IUniswapV2Factory(0xC0AEe478e3658e2610c5F7A4A2E1777cE9e4f2Ac);
    IUniswapV2Factory constant uniswapFactory = IUniswapV2Factory(0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f);

    bytes32 public constant MARKET_MAKER = keccak256("baskmaker.access.marketMaker");
    bytes32 public constant MARKET_MAKER_ADMIN = keccak256("baskmaker.access.marketMaker.admin");

    bytes32 public constant TIMELOCK = keccak256("baskmaker.access.marketMaker");
    bytes32 public constant TIMELOCK_ADMIN = keccak256("baskmaker.access.marketMaker.admin");

    constructor(
        address _timelock,
        address _admin,
        uint256[] memory _fees,
        address[] memory _feeRecipients,
        address[] memory _feeRecipientAssets
    ) {
        _setRoleAdmin(TIMELOCK, TIMELOCK_ADMIN);
        _setupRole(TIMELOCK_ADMIN, _timelock);
        _setupRole(TIMELOCK, _timelock);

        _setRoleAdmin(MARKET_MAKER, MARKET_MAKER_ADMIN);
        _setupRole(MARKET_MAKER_ADMIN, _admin);
        _setupRole(MARKET_MAKER, _admin);
        _setupRole(MARKET_MAKER, msg.sender);

        fees = _fees;
        feeRecipients = _feeRecipients;
        feeRecipientAssets = _feeRecipientAssets;
        _assertFees();

        setFactory(KNC, WETH, address(uniswapFactory));
        setFactory(LRC, WETH, address(uniswapFactory));
        setFactory(BAL, WETH, address(uniswapFactory));
        setFactory(MTA, WETH, address(uniswapFactory));
    }


    modifier authorized(bytes32 role) {

        require(hasRole(role, msg.sender), "!authorized");
        _;
    }


    function bridgeFor(address token) public view returns (address bridge) {

        bridge = _bridges[token];
        if (bridge == address(0)) {
            bridge = WETH;
        }
    }

    function factoryFor(address fromToken, address toToken) public view returns (address factory) {

        bytes32 h = keccak256(abi.encode(fromToken, toToken));
        factory = _factories[h];
        if (factory == address(0)) {
            factory = address(sushiswapFactory);
        }
    }


    function setFees(
        uint256[] memory _fees,
        address[] memory _feeRecipients,
        address[] memory _feeRecipientAssets
    ) external authorized(TIMELOCK) {

        fees = _fees;
        feeRecipients = _feeRecipients;
        feeRecipientAssets = _feeRecipientAssets;
        _assertFees();
    }

    function setBridge(address token, address bridge) external authorized(MARKET_MAKER) {

        require(token != BASK && token != WETH && token != bridge, "BaskMaker: Invalid bridge");
        _bridges[token] = bridge;
        emit LogBridgeSet(token, bridge);
    }

    function setFactory(
        address fromToken,
        address toToken,
        address factory
    ) public authorized(MARKET_MAKER) {

        require(
            factory == address(sushiswapFactory) || factory == address(uniswapFactory),
            "BaskMaker: Invalid factory"
        );

        _factories[keccak256(abi.encode(fromToken, toToken))] = factory;
        LogFactorySet(fromToken, toToken, factory);
    }

    function rescueERC20(address _token) public authorized(MARKET_MAKER) {

        uint256 _amount = IERC20(_token).balanceOf(address(this));
        IERC20(_token).safeTransfer(msg.sender, _amount);
    }

    function rescueERC20s(address[] memory _tokens) external authorized(MARKET_MAKER) {

        for (uint256 i = 0; i < _tokens.length; i++) {
            rescueERC20(_tokens[i]);
        }
    }

    function convert(address token) external authorized(MARKET_MAKER) {

        _convert(token);
    }

    function convertMultiple(address[] calldata tokens) external authorized(MARKET_MAKER) {

        uint256 len = tokens.length;
        for (uint256 i = 0; i < len; i++) {
            _convert(tokens[i]);
        }
    }


    function _convert(address token) internal {

        address token0 = _toUnderlying(token);
        uint256 amount0 = IERC20(token0).balanceOf(address(this));

        _convertStep(token0, amount0);
    }

    function _convertStep(address token, uint256 amount) internal {

        if (token == WETH) {
            uint256 wethAllocAmount;
            address wantedAsset;
            for (uint256 i = 0; i < fees.length; i++) {
                wethAllocAmount = amount.mul(fees[i]).div(1e18);
                wantedAsset = feeRecipientAssets[i];
                if (wantedAsset == token) {
                    IERC20(token).safeTransfer(feeRecipients[i], wethAllocAmount);
                } else {
                    _swap(token, feeRecipientAssets[i], wethAllocAmount, feeRecipients[i]);
                }
            }
            return;
        }

        address bridge = bridgeFor(token);
        uint256 amountOut = _swap(token, bridge, amount, address(this));
        _convertStep(bridge, amountOut);
    }

    function _swap(
        address fromToken,
        address toToken,
        uint256 amountIn,
        address to
    ) internal returns (uint256 amountOut) {

        IUniswapV2Pair pair =
            IUniswapV2Pair(IUniswapV2Factory(factoryFor(fromToken, toToken)).getPair(fromToken, toToken));
        require(address(pair) != address(0), "BaskMaker: Cannot convert");

        (uint256 reserve0, uint256 reserve1, ) = pair.getReserves();
        uint256 amountInWithFee = amountIn.mul(997);
        if (fromToken == pair.token0()) {
            amountOut = amountIn.mul(997).mul(reserve1) / reserve0.mul(1000).add(amountInWithFee);
            IERC20(fromToken).safeTransfer(address(pair), amountIn);
            pair.swap(0, amountOut, to, new bytes(0));
        } else {
            amountOut = amountIn.mul(997).mul(reserve0) / reserve1.mul(1000).add(amountInWithFee);
            IERC20(fromToken).safeTransfer(address(pair), amountIn);
            pair.swap(amountOut, 0, to, new bytes(0));
        }
        emit LogConverted(msg.sender, fromToken, toToken, to, amountIn, amountOut);
    }

    function _assertFees() internal view {

        require(fees.length == feeRecipients.length, "!invalid-recipient-length");
        require(fees.length == feeRecipientAssets.length, "!invalid-asset-length");

        uint256 total = 0;
        for (uint256 i = 0; i < fees.length; i++) {
            total = total.add(fees[i]);
        }

        require(total == 1e18, "!valid-fees");
    }
}
