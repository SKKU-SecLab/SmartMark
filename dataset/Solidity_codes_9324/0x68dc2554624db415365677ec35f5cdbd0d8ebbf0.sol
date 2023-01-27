
pragma solidity ^0.8.0;

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

pragma solidity ^0.8.0;

library Address {

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

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {

        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {

        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
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


library SafeERC20 {

    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {

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

    function safeApprove(
        IERC20 token,
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
        IERC20 token,
        address spender,
        uint256 value
    ) internal {

        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
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

    function _callOptionalReturn(IERC20 token, bytes memory data) private {


        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
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
        return msg.data;
    }
}// MIT

pragma solidity ^0.8.0;


abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
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
}// MIT

pragma solidity ^0.8.0;

library EnumerableSet {


    struct Set {
        bytes32[] _values;
        mapping(bytes32 => uint256) _indexes;
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

        if (valueIndex != 0) {

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;

            if (lastIndex != toDeleteIndex) {
                bytes32 lastvalue = set._values[lastIndex];

                set._values[toDeleteIndex] = lastvalue;
                set._indexes[lastvalue] = valueIndex; // Replace lastvalue's index to valueIndex
            }

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

        return set._values[index];
    }

    function _values(Set storage set) private view returns (bytes32[] memory) {

        return set._values;
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

    function values(Bytes32Set storage set) internal view returns (bytes32[] memory) {

        return _values(set._inner);
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

    function values(AddressSet storage set) internal view returns (address[] memory) {

        bytes32[] memory store = _values(set._inner);
        address[] memory result;

        assembly {
            result := store
        }

        return result;
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

    function values(UintSet storage set) internal view returns (uint256[] memory) {

        bytes32[] memory store = _values(set._inner);
        uint256[] memory result;

        assembly {
            result := store
        }

        return result;
    }
}// MIT

pragma solidity ^0.8.0;

abstract contract ReentrancyGuard {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
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
pragma solidity ^0.8.0;




contract BridgeLeft is Ownable, ReentrancyGuard {

    using SafeERC20 for IERC20;
    using EnumerableSet for EnumerableSet.AddressSet;

    uint256 constant public USD_DECIMALS = 6;

    uint256 internal constant ONE_PERCENT = 100;  // 1%
    uint256 public constant FEE_DENOMINATOR = 100 * ONE_PERCENT;  // 100%
    uint256 public feeNumerator = 5 * ONE_PERCENT;

    address public serviceFeeTreasury;  // this is a service fee for the project support

    bool public whitelistAllTokens;  // do we want to accept all erc20 token as a payment? todo: be careful with deflationary etc
    EnumerableSet.AddressSet internal _whitelistTokens;  // erc20 tokens we accept as a payment (before swap)  //todo gas optimisations
    EnumerableSet.AddressSet internal _whitelistStablecoins;  // stablecoins we accept as a final payment method  //todo gas optimisations
    mapping (address => uint256) public stablecoinDecimals;

    address immutable public router;  // dex router we use todo: maybe make it updateable or just deploy new contract?

    mapping (address /*user*/ => mapping (bytes16 /*orderId*/ => bool)) public userPaidOrders;

    event ServiceFeeTreasurySet(address indexed value);
    event WhitelistAllTokensSet(bool value);
    event TokenAddedToWhitelistStablecoins(address indexed token, uint256 decimals);
    event TokenAddedToWhitelist(address indexed token);
    event TokenRemovedFromWhitelistStablecoins(address indexed token);
    event TokenRemovedFromWhitelist(address indexed token);
    event OrderPaid(
        bytes16 orderId,
        uint256 orderUSDAmount,
        address destination,
        address payer,
        address payableToken,
        uint256 payableTokenAmount,
        address stablecoin,
        uint256 serviceFeeUSDAmount
    );

    constructor(
        address routerAddress,
        address serviceFeeTreasuryAddress
    ) {
        require(routerAddress != address(0), "zero address");
        router = routerAddress;

        require(serviceFeeTreasuryAddress != address(0), "zero address");
        serviceFeeTreasury = serviceFeeTreasuryAddress;
    }

    function setServiceFeeTreasury(address serviceFeeTreasuryAddress) external onlyOwner {

        require(serviceFeeTreasuryAddress != address(0), "zero address");
        serviceFeeTreasury = serviceFeeTreasuryAddress;
        emit ServiceFeeTreasurySet(serviceFeeTreasuryAddress);
    }

    function setWhitelistAllTokens(bool value) external onlyOwner {

        whitelistAllTokens = value;
        emit WhitelistAllTokensSet(value);
    }

    function getWhitelistedTokens() external view returns(address[] memory) {

        uint256 length = _whitelistTokens.length();
        address[] memory result = new address[](length);
        for (uint256 i=0; i < length; ++i) {
            result[i] = _whitelistTokens.at(i);
        }
        return result;
    }

    function getWhitelistedStablecoins() external view returns(address[] memory) {

        uint256 length = _whitelistStablecoins.length();
        address[] memory result = new address[](length);
        for (uint256 i=0; i < length; ++i) {
            result[i] = _whitelistStablecoins.at(i);
        }
        return result;
    }

    function isTokenWhitelisted(address token) external view returns(bool) {

        return _whitelistTokens.contains(token);
    }

    function isWhitelistedStablecoin(address token) public view returns(bool) {

        return _whitelistStablecoins.contains(token);
    }

    modifier onlyWhitelistedTokenOrAllWhitelisted(address token) {

        require(whitelistAllTokens || _whitelistTokens.contains(token), "not whitelisted");
        _;
    }

    function addTokenToWhitelist(address token) external onlyOwner {

        require(_whitelistTokens.add(token), "already whitelisted");
        emit TokenAddedToWhitelist(token);
    }

    function removeTokenFromWhitelist(address token) external onlyOwner {

        require(_whitelistTokens.remove(token), "not whitelisted");
        emit TokenRemovedFromWhitelist(token);
    }

    function addTokenToWhitelistStablecoins(address token, uint256 decimals) external onlyOwner {

        require(_whitelistStablecoins.add(token), "already whitelisted stablecoin");
        stablecoinDecimals[token] = decimals;
        emit TokenAddedToWhitelistStablecoins(token, decimals);
    }

    function removeTokenFromWhitelistStablecoins(address token) external onlyOwner {

        require(_whitelistStablecoins.remove(token), "not whitelisted stablecoin");
        delete stablecoinDecimals[token];
        emit TokenRemovedFromWhitelistStablecoins(token);
    }

    function setFeeNumerator(uint256 newFeeNumerator) external onlyOwner {

        require(newFeeNumerator <= 1000, "Max fee numerator: 1000");
        feeNumerator = newFeeNumerator;
    }


    function estimateFee(
        uint256 orderUSDAmount  // 6 decimals
    ) view external returns(uint256) {

        return orderUSDAmount * feeNumerator / FEE_DENOMINATOR;
    }

    function paymentStablecoin(
        bytes16 orderId,
        uint256 orderUSDAmount,  // 6 decimals
        address destination,
        address stablecoin
    ) external nonReentrant {

        require(destination != address(0), "zero address");
        require(!userPaidOrders[msg.sender][orderId], "order already paid");
        require(isWhitelistedStablecoin(stablecoin), "the end path is not stablecoin");
        userPaidOrders[msg.sender][orderId] = true;

        uint256 orderUSDAmountERC20DECIMALS = orderUSDAmount * (10 ** stablecoinDecimals[stablecoin]) / (10 ** USD_DECIMALS);
        uint256 feeStablecoinAmount = orderUSDAmount * feeNumerator / FEE_DENOMINATOR;
        uint256 feeStablecoinAmountERC20DECIMALS = feeStablecoinAmount * (10 ** stablecoinDecimals[stablecoin]) / (10 ** USD_DECIMALS);

        IERC20(stablecoin).safeTransferFrom(msg.sender, destination, orderUSDAmountERC20DECIMALS);
        IERC20(stablecoin).safeTransferFrom(msg.sender, serviceFeeTreasury, feeStablecoinAmountERC20DECIMALS);

        emit OrderPaid({
            orderId: orderId,
            orderUSDAmount: orderUSDAmount,
            destination: destination,
            payer: msg.sender,
            payableToken: stablecoin,
            payableTokenAmount: (orderUSDAmountERC20DECIMALS + feeStablecoinAmountERC20DECIMALS),
            stablecoin: stablecoin,
            serviceFeeUSDAmount: feeStablecoinAmount
        });
    }

    function estimatePayableTokenAmount(
        uint256 orderUSDAmount,  // 6 decimals
        address[] calldata path
    ) external view onlyWhitelistedTokenOrAllWhitelisted(path[0]) returns(uint256) {

        require(isWhitelistedStablecoin(path[path.length-1]), "the end path is not stablecoin");
        uint256 orderUSDAmountERC20DECIMALS = orderUSDAmount * (10 ** stablecoinDecimals[path[path.length-1]]) / (10 ** USD_DECIMALS);
        uint256[] memory amounts = IUniswapV2Router02(router).getAmountsIn(orderUSDAmountERC20DECIMALS, path);
        return amounts[0];
    }

    function paymentERC20(
        bytes16 orderId,
        uint256 orderUSDAmount,  // 6 decimals
        address destination,
        uint256 payableTokenMaxAmount,
        uint256 deadline,
        address[] calldata path
    ) external onlyWhitelistedTokenOrAllWhitelisted(path[0]) nonReentrant {

        require(destination != address(0), "zero address");
        require(!userPaidOrders[msg.sender][orderId], "order already paid");
        require(isWhitelistedStablecoin(path[path.length-1]), "the end path is not stablecoin");
        userPaidOrders[msg.sender][orderId] = true;

        uint256 orderUSDAmountERC20DECIMALS = orderUSDAmount * (10 ** stablecoinDecimals[path[path.length-1]]) / (10 ** USD_DECIMALS);
        uint256 feeStablecoinAmount = orderUSDAmount * feeNumerator / FEE_DENOMINATOR;

        uint256 amountIn;

        {
            uint256 feeStablecoinAmountERC20DECIMALS = feeStablecoinAmount * (10 ** stablecoinDecimals[path[path.length-1]]) / (10 ** USD_DECIMALS);
            uint256 totalAmountERC20DECIMALS = orderUSDAmountERC20DECIMALS + feeStablecoinAmountERC20DECIMALS;
            amountIn = IUniswapV2Router02(router).getAmountsIn(totalAmountERC20DECIMALS, path)[0];  // todo think about 2x cycle
            require(amountIn <= payableTokenMaxAmount, "insufficient payableTokenMaxAmount");
            IERC20(path[0]).safeTransferFrom(msg.sender, address(this), amountIn);
            IERC20(path[0]).safeApprove(router, amountIn);  // think: approve type(uint256).max once
            IUniswapV2Router02(router).swapExactTokensForTokens({
                amountIn: amountIn,
                amountOutMin: totalAmountERC20DECIMALS,
                path: path,
                to: address(this),
                deadline: deadline
            });
            IERC20(path[path.length-1]).safeTransfer(destination, orderUSDAmountERC20DECIMALS);
            IERC20(path[path.length-1]).safeTransfer(serviceFeeTreasury, feeStablecoinAmountERC20DECIMALS);
        }


        emit OrderPaid({
            orderId: orderId,
            orderUSDAmount: orderUSDAmount,
            destination: destination,
            payer: msg.sender,
            payableToken: path[0],
            payableTokenAmount: amountIn,
            stablecoin: path[path.length-1],
            serviceFeeUSDAmount: feeStablecoinAmount
        });
    }


    function paymentETH(
        bytes16 orderId,
        uint256 orderUSDAmount,  // 6 decimals
        address destination,
        uint256 deadline,
        address[] calldata path,
        uint256 minETHRestAmountToReturn
    ) external payable onlyWhitelistedTokenOrAllWhitelisted(path[0]) nonReentrant {

        address stablecoin = path[path.length-1];

        require(destination != address(0), "zero address");
        require(!userPaidOrders[msg.sender][orderId], "order already paid");
        require(isWhitelistedStablecoin(stablecoin), "the end path is not stablecoin");
        userPaidOrders[msg.sender][orderId] = true;

        uint256 feeStablecoinAmount = orderUSDAmount * feeNumerator / FEE_DENOMINATOR;

        _paymentETHProcess(
            orderUSDAmount,  // 6 decimals
            destination,
            deadline,
            path,
            minETHRestAmountToReturn,
            feeStablecoinAmount
        );

        emit OrderPaid({
            orderId: orderId,
            orderUSDAmount: orderUSDAmount,
            destination: destination,
            payer: msg.sender,
            payableToken: address(0),
            payableTokenAmount: msg.value,
            stablecoin: stablecoin,
            serviceFeeUSDAmount: feeStablecoinAmount
        });
    }

    function _paymentETHProcess(
        uint256 orderUSDAmount,  // 6 decimals
        address destination,
        uint256 deadline,
        address[] calldata path,
        uint256 minETHRestAmountToReturn,
        uint256 feeStablecoinAmount
    ) internal {

        uint256 orderUSDAmountERC20DECIMALS = orderUSDAmount * (10 ** stablecoinDecimals[path[path.length-1]]) / (10 ** USD_DECIMALS);
        uint256 feeStablecoinAmountERC20DECIMALS = feeStablecoinAmount * (10 ** stablecoinDecimals[path[path.length-1]]) / (10 ** USD_DECIMALS);
        uint256 totalAmountERC20DECIMALS = orderUSDAmountERC20DECIMALS + feeStablecoinAmountERC20DECIMALS;
        uint256[] memory amounts = IUniswapV2Router02(router).swapETHForExactTokens{value: msg.value}(
            totalAmountERC20DECIMALS,
            path,
            address(this),
            deadline
        );

        {
            uint256 ethRest = msg.value - amounts[0];
            if (ethRest >= minETHRestAmountToReturn) {
                (bool sent, /*bytes memory data*/) = payable(msg.sender).call{value: ethRest}("");
                require(sent, "Failed to send Ether");
            }
        }

        IERC20(path[path.length-1]).safeTransfer(destination, orderUSDAmountERC20DECIMALS);
        IERC20(path[path.length-1]).safeTransfer(serviceFeeTreasury, feeStablecoinAmountERC20DECIMALS);
    }


    fallback() external payable { }  // we need it to receive eth on the contract from uniswap
    
    function withdrawERC20To(IERC20 token, address recipient, uint256 amount) external onlyOwner {

        token.safeTransfer(recipient, amount);
    }

    function withdrawETHTo(address recipient, uint256 amount) external onlyOwner {

        (bool sent, /*bytes memory data*/) = payable(recipient).call{value: amount}("");
        require(sent, "Failed to send Ether");
    }
}