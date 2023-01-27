
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
}// MIT

pragma solidity >=0.6.0 <0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}// MIT

pragma solidity >=0.6.0 <0.8.0;

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
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
}// MIT

pragma solidity >=0.6.0 <0.8.0;


abstract contract Pausable is Context {
    event Paused(address account);

    event Unpaused(address account);

    bool private _paused;

    constructor () internal {
        _paused = false;
    }

    function paused() public view virtual returns (bool) {
        return _paused;
    }

    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
        _;
    }

    modifier whenPaused() {
        require(paused(), "Pausable: not paused");
        _;
    }

    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}pragma solidity =0.6.6;

library TransferHelper {

    function safeApprove(
        address token,
        address to,
        uint256 value
    ) internal {

        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), "TransferHelper: APPROVE_FAILED");
    }

    function safeTransfer(
        address token,
        address to,
        uint256 value
    ) internal {

        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), "TransferHelper: TRANSFER_FAILED");
    }

    function safeTransferFrom(
        address token,
        address from,
        address to,
        uint256 value
    ) internal {

        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), "TransferHelper: TRANSFER_FROM_FAILED");
    }

    function safeTransferETH(address to, uint256 value) internal {

        (bool success, ) = to.call{value: value}(new bytes(0));
        require(success, "TransferHelper: ETH_TRANSFER_FAILED");
    }
}pragma solidity >=0.6.2;

interface IPancakeRouter01 {

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

}pragma solidity >=0.6.2;


interface IPancakeRouter02 is IPancakeRouter01 {

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

}pragma solidity >=0.5.0;

interface IWETH {

    function deposit() external payable;


    function transfer(address to, uint256 value) external returns (bool);


    function withdraw(uint256) external;


    function approve(address _spender, uint256 _amount) external returns (bool);


    function balanceOf(address _account) external view returns (uint256);

}pragma solidity =0.6.6;


contract FeeReceiver is Pausable, Ownable {

    using SafeMath for uint256;

    event BuybackRateUpdated(uint256 newBuybackRate);
    event RevenueReceiverUpdated(address newRevenueReceiver);
    event RouterWhitelistUpdated(address router, bool status);
    event BuybackExecuted(uint256 amountBuyback, uint256 amountRevenue);

    address internal constant ZERO_ADDRESS = address(0);
    uint256 public constant FEE_DENOMINATOR = 10000;
    IPancakeRouter02 public pancakeRouter;
    address payable public revenueReceiver;
    uint256 public buybackRate;
    address public SYA;
    address public WETH;

    mapping(address => bool) public routerWhitelist;

    constructor(
        IPancakeRouter02 _pancakeRouterV2,
        address _SYA,
        address _WETH,
        address payable _revenueReceiver,
        uint256 _buybackRate
    ) public {
        pancakeRouter = _pancakeRouterV2;
        SYA = _SYA;
        WETH = _WETH;
        revenueReceiver = _revenueReceiver;
        buybackRate = _buybackRate;
        routerWhitelist[address(pancakeRouter)] = true;
    }

    function executeBuyback() external whenNotPaused {

        require(address(this).balance > 0, "FeeReceiver: No balance for buyback");
        address[] memory path = new address[](2);
        path[0] = WETH;
        path[1] = SYA;

        uint256 balance = address(this).balance;
        uint256 amountBuyback = balance.mul(buybackRate).div(FEE_DENOMINATOR);
        uint256 amountRevenue = balance.sub(amountBuyback);

        pancakeRouter.swapExactETHForTokensSupportingFeeOnTransferTokens{value: amountBuyback}(
            0,
            path,
            ZERO_ADDRESS,
            block.timestamp
        );
        TransferHelper.safeTransferETH(revenueReceiver, amountRevenue);
        emit BuybackExecuted(amountBuyback, amountRevenue);
    }

    function convertToETH(
        address _router,
        IERC20 _token,
        bool _fee
    ) public whenNotPaused {

        require(routerWhitelist[_router], "FeeReceiver: Router not whitelisted");
        address[] memory path = new address[](2);
        path[0] = address(_token);
        path[1] = WETH;

        uint256 balance = _token.balanceOf(address(this));
        TransferHelper.safeApprove(address(_token), address(pancakeRouter), balance);
        if (_fee) {
            IPancakeRouter02(_router).swapExactTokensForETHSupportingFeeOnTransferTokens(
                balance,
                0,
                path,
                address(this),
                block.timestamp
            );
        } else {
            IPancakeRouter02(_router).swapExactTokensForETH(balance, 0, path, address(this), block.timestamp);
        }
    }

    function unwrapWETH() public whenNotPaused {

        uint256 balance = IWETH(WETH).balanceOf(address(this));
        require(balance > 0, "FeeReceiver: Nothing to unwrap");
        IWETH(WETH).withdraw(balance);
    }

    function updateRouterWhiteliste(address _router, bool _status) external onlyOwner {

        routerWhitelist[_router] = _status;
        emit RouterWhitelistUpdated(_router, _status);
    }

    function updateBuybackRate(uint256 _newBuybackRate) external onlyOwner {

        buybackRate = _newBuybackRate;
        emit BuybackRateUpdated(_newBuybackRate);
    }

    function updateRevenueReceiver(address payable _newRevenueReceiver) external onlyOwner {

        revenueReceiver = _newRevenueReceiver;
        emit RevenueReceiverUpdated(_newRevenueReceiver);
    }

    function withdrawETH(address payable to, uint256 amount) external onlyOwner {

        to.transfer(amount);
    }

    function withdrawERC20Token(
        address token,
        address to,
        uint256 amount
    ) external onlyOwner {

        IERC20(token).transfer(to, amount);
    }

    receive() external payable {}

    function pause() external onlyOwner {

        _pause();
    }

    function unpause() external onlyOwner {

        _unpause();
    }
}// Apache-2.0

pragma solidity ^0.6.5;


library LibBytesRichErrorsV06 {


    enum InvalidByteOperationErrorCodes {
        FromLessThanOrEqualsToRequired,
        ToLessThanOrEqualsLengthRequired,
        LengthGreaterThanZeroRequired,
        LengthGreaterThanOrEqualsFourRequired,
        LengthGreaterThanOrEqualsTwentyRequired,
        LengthGreaterThanOrEqualsThirtyTwoRequired,
        LengthGreaterThanOrEqualsNestedBytesLengthRequired,
        DestinationLengthGreaterThanOrEqualSourceLengthRequired
    }

    bytes4 internal constant INVALID_BYTE_OPERATION_ERROR_SELECTOR =
        0x28006595;

    function InvalidByteOperationError(
        InvalidByteOperationErrorCodes errorCode,
        uint256 offset,
        uint256 required
    )
        internal
        pure
        returns (bytes memory)
    {

        return abi.encodeWithSelector(
            INVALID_BYTE_OPERATION_ERROR_SELECTOR,
            errorCode,
            offset,
            required
        );
    }
}// Apache-2.0

pragma solidity ^0.6.5;


library LibRichErrorsV06 {


    bytes4 internal constant STANDARD_ERROR_SELECTOR = 0x08c379a0;

    function StandardError(string memory message)
        internal
        pure
        returns (bytes memory)
    {

        return abi.encodeWithSelector(
            STANDARD_ERROR_SELECTOR,
            bytes(message)
        );
    }

    function rrevert(bytes memory errorData)
        internal
        pure
    {

        assembly {
            revert(add(errorData, 0x20), mload(errorData))
        }
    }
}// Apache-2.0

pragma solidity ^0.6.5;



library LibBytesV06 {


    using LibBytesV06 for bytes;

    function rawAddress(bytes memory input)
        internal
        pure
        returns (uint256 memoryAddress)
    {

        assembly {
            memoryAddress := input
        }
        return memoryAddress;
    }

    function contentAddress(bytes memory input)
        internal
        pure
        returns (uint256 memoryAddress)
    {

        assembly {
            memoryAddress := add(input, 32)
        }
        return memoryAddress;
    }

    function memCopy(
        uint256 dest,
        uint256 source,
        uint256 length
    )
        internal
        pure
    {

        if (length < 32) {
            assembly {
                let mask := sub(exp(256, sub(32, length)), 1)
                let s := and(mload(source), not(mask))
                let d := and(mload(dest), mask)
                mstore(dest, or(s, d))
            }
        } else {
            if (source == dest) {
                return;
            }

            if (source > dest) {
                assembly {
                    length := sub(length, 32)
                    let sEnd := add(source, length)
                    let dEnd := add(dest, length)

                    let last := mload(sEnd)

                    for {} lt(source, sEnd) {} {
                        mstore(dest, mload(source))
                        source := add(source, 32)
                        dest := add(dest, 32)
                    }

                    mstore(dEnd, last)
                }
            } else {
                assembly {
                    length := sub(length, 32)
                    let sEnd := add(source, length)
                    let dEnd := add(dest, length)

                    let first := mload(source)

                    for {} slt(dest, dEnd) {} {
                        mstore(dEnd, mload(sEnd))
                        sEnd := sub(sEnd, 32)
                        dEnd := sub(dEnd, 32)
                    }

                    mstore(dest, first)
                }
            }
        }
    }

    function slice(
        bytes memory b,
        uint256 from,
        uint256 to
    )
        internal
        pure
        returns (bytes memory result)
    {
        if (from > to) {
            LibRichErrorsV06.rrevert(LibBytesRichErrorsV06.InvalidByteOperationError(
                LibBytesRichErrorsV06.InvalidByteOperationErrorCodes.FromLessThanOrEqualsToRequired,
                from,
                to
            ));
        }
        if (to > b.length) {
            LibRichErrorsV06.rrevert(LibBytesRichErrorsV06.InvalidByteOperationError(
                LibBytesRichErrorsV06.InvalidByteOperationErrorCodes.ToLessThanOrEqualsLengthRequired,
                to,
                b.length
            ));
        }

        result = new bytes(to - from);
        memCopy(
            result.contentAddress(),
            b.contentAddress() + from,
            result.length
        );
        return result;
    }

    function sliceDestructive(
        bytes memory b,
        uint256 from,
        uint256 to
    )
        internal
        pure
        returns (bytes memory result)
    {
        if (from > to) {
            LibRichErrorsV06.rrevert(LibBytesRichErrorsV06.InvalidByteOperationError(
                LibBytesRichErrorsV06.InvalidByteOperationErrorCodes.FromLessThanOrEqualsToRequired,
                from,
                to
            ));
        }
        if (to > b.length) {
            LibRichErrorsV06.rrevert(LibBytesRichErrorsV06.InvalidByteOperationError(
                LibBytesRichErrorsV06.InvalidByteOperationErrorCodes.ToLessThanOrEqualsLengthRequired,
                to,
                b.length
            ));
        }

        assembly {
            result := add(b, from)
            mstore(result, sub(to, from))
        }
        return result;
    }

    function popLastByte(bytes memory b)
        internal
        pure
        returns (bytes1 result)
    {
        if (b.length == 0) {
            LibRichErrorsV06.rrevert(LibBytesRichErrorsV06.InvalidByteOperationError(
                LibBytesRichErrorsV06.InvalidByteOperationErrorCodes.LengthGreaterThanZeroRequired,
                b.length,
                0
            ));
        }

        result = b[b.length - 1];

        assembly {
            let newLen := sub(mload(b), 1)
            mstore(b, newLen)
        }
        return result;
    }

    function equals(
        bytes memory lhs,
        bytes memory rhs
    )
        internal
        pure
        returns (bool equal)
    {
        return lhs.length == rhs.length && keccak256(lhs) == keccak256(rhs);
    }

    function readAddress(
        bytes memory b,
        uint256 index
    )
        internal
        pure
        returns (address result)
    {
        if (b.length < index + 20) {
            LibRichErrorsV06.rrevert(LibBytesRichErrorsV06.InvalidByteOperationError(
                LibBytesRichErrorsV06.InvalidByteOperationErrorCodes.LengthGreaterThanOrEqualsTwentyRequired,
                b.length,
                index + 20 // 20 is length of address
            ));
        }

        index += 20;

        assembly {
            result := and(mload(add(b, index)), 0xffffffffffffffffffffffffffffffffffffffff)
        }
        return result;
    }

    function writeAddress(
        bytes memory b,
        uint256 index,
        address input
    )
        internal
        pure
    {
        if (b.length < index + 20) {
            LibRichErrorsV06.rrevert(LibBytesRichErrorsV06.InvalidByteOperationError(
                LibBytesRichErrorsV06.InvalidByteOperationErrorCodes.LengthGreaterThanOrEqualsTwentyRequired,
                b.length,
                index + 20 // 20 is length of address
            ));
        }

        index += 20;

        assembly {

            let neighbors := and(
                mload(add(b, index)),
                0xffffffffffffffffffffffff0000000000000000000000000000000000000000
            )

            input := and(input, 0xffffffffffffffffffffffffffffffffffffffff)

            mstore(add(b, index), xor(input, neighbors))
        }
    }

    function readBytes32(
        bytes memory b,
        uint256 index
    )
        internal
        pure
        returns (bytes32 result)
    {
        if (b.length < index + 32) {
            LibRichErrorsV06.rrevert(LibBytesRichErrorsV06.InvalidByteOperationError(
                LibBytesRichErrorsV06.InvalidByteOperationErrorCodes.LengthGreaterThanOrEqualsThirtyTwoRequired,
                b.length,
                index + 32
            ));
        }

        index += 32;

        assembly {
            result := mload(add(b, index))
        }
        return result;
    }

    function writeBytes32(
        bytes memory b,
        uint256 index,
        bytes32 input
    )
        internal
        pure
    {
        if (b.length < index + 32) {
            LibRichErrorsV06.rrevert(LibBytesRichErrorsV06.InvalidByteOperationError(
                LibBytesRichErrorsV06.InvalidByteOperationErrorCodes.LengthGreaterThanOrEqualsThirtyTwoRequired,
                b.length,
                index + 32
            ));
        }

        index += 32;

        assembly {
            mstore(add(b, index), input)
        }
    }

    function readUint256(
        bytes memory b,
        uint256 index
    )
        internal
        pure
        returns (uint256 result)
    {
        result = uint256(readBytes32(b, index));
        return result;
    }

    function writeUint256(
        bytes memory b,
        uint256 index,
        uint256 input
    )
        internal
        pure
    {
        writeBytes32(b, index, bytes32(input));
    }

    function readBytes4(
        bytes memory b,
        uint256 index
    )
        internal
        pure
        returns (bytes4 result)
    {
        if (b.length < index + 4) {
            LibRichErrorsV06.rrevert(LibBytesRichErrorsV06.InvalidByteOperationError(
                LibBytesRichErrorsV06.InvalidByteOperationErrorCodes.LengthGreaterThanOrEqualsFourRequired,
                b.length,
                index + 4
            ));
        }

        index += 32;

        assembly {
            result := mload(add(b, index))
            result := and(result, 0xFFFFFFFF00000000000000000000000000000000000000000000000000000000)
        }
        return result;
    }

    function writeLength(bytes memory b, uint256 length)
        internal
        pure
    {
        assembly {
            mstore(b, length)
        }
    }
}// MIT

pragma solidity >=0.6.0 <0.8.0;

abstract contract ReentrancyGuard {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor () internal {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
    }
}pragma solidity =0.6.6;


interface IPancakePair {

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

library PancakeLibrary {

    using SafeMath for uint256;

    function sortTokens(address tokenA, address tokenB) internal pure returns (address token0, address token1) {

        require(tokenA != tokenB, "PancakeLibrary: IDENTICAL_ADDRESSES");
        (token0, token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        require(token0 != address(0), "PancakeLibrary: ZERO_ADDRESS");
    }

    function quote(
        uint256 amountA,
        uint256 reserveA,
        uint256 reserveB
    ) internal pure returns (uint256 amountB) {

        require(amountA > 0, "PancakeLibrary: INSUFFICIENT_AMOUNT");
        require(reserveA > 0 && reserveB > 0, "PancakeLibrary: INSUFFICIENT_LIQUIDITY");
        amountB = amountA.mul(reserveB) / reserveA;
    }
}pragma solidity >=0.5.0;

interface IReferralRegistry {

    function getUserReferee(address _user) external view returns (address);


    function hasUserReferee(address _user) external view returns (bool);


    function createReferralAnchor(address _user, address _referee) external;

}pragma solidity ^0.6.5;

interface IZerox {

    function getFunctionImplementation(bytes4 selector) external returns (address payable);

}pragma solidity =0.6.6;


contract FloozRouter is Ownable, Pausable, ReentrancyGuard {

    using SafeMath for uint256;
    using LibBytesV06 for bytes;

    event SwapFeeUpdated(uint16 swapFee);
    event ReferralRegistryUpdated(address referralRegistry);
    event ReferralRewardRateUpdated(uint16 referralRewardRate);
    event ReferralsActivatedUpdated(bool activated);
    event FeeReceiverUpdated(address payable feeReceiver);
    event BalanceThresholdUpdated(uint256 balanceThreshold);
    event CustomReferralRewardRateUpdated(address indexed account, uint16 referralRate);
    event ReferralRewardPaid(address from, address indexed to, address tokenOut, address tokenReward, uint256 amount);
    event ForkUpdated(address factory);

    uint256 public constant FEE_DENOMINATOR = 10000;

    uint16 public swapFee;

    address public immutable WETH;

    address payable public immutable zeroEx;

    address payable public immutable oneInch;

    IReferralRegistry public referralRegistry;

    IERC20 public saveYourAssetsToken;

    uint256 public balanceThreshold;

    address payable public feeReceiver;

    uint16 public referralRewardRate;

    bool public referralsActivated;

    mapping(address => uint16) public customReferralRewardRate;

    mapping(address => bool) public forkActivated;

    mapping(address => bytes) public forkInitCode;

    constructor(
        address _WETH,
        uint16 _swapFee,
        uint16 _referralRewardRate,
        address payable _feeReceiver,
        uint256 _balanceThreshold,
        IERC20 _saveYourAssetsToken,
        IReferralRegistry _referralRegistry,
        address payable _zeroEx,
        address payable _oneInch
    ) public {
        WETH = _WETH;
        swapFee = _swapFee;
        referralRewardRate = _referralRewardRate;
        feeReceiver = _feeReceiver;
        saveYourAssetsToken = _saveYourAssetsToken;
        balanceThreshold = _balanceThreshold;
        referralRegistry = _referralRegistry;
        zeroEx = _zeroEx;
        oneInch = _oneInch;
        referralsActivated = true;
    }

    function swapExactETHForTokens(
        address fork,
        uint256 amountOutMin,
        address[] calldata path,
        address referee
    ) external payable whenNotPaused isValidFork(fork) isValidReferee(referee) returns (uint256[] memory amounts) {

        require(path[0] == WETH, "FloozRouter: INVALID_PATH");
        referee = _getReferee(referee);
        (uint256 swapAmount, uint256 feeAmount, uint256 referralReward) = _calculateFeesAndRewards(
            msg.value,
            referee,
            false
        );
        amounts = _getAmountsOut(fork, swapAmount, path);
        require(amounts[amounts.length - 1] >= amountOutMin, "FloozRouter: INSUFFICIENT_OUTPUT_AMOUNT");
        IWETH(WETH).deposit{value: amounts[0]}();
        assert(IWETH(WETH).transfer(_pairFor(fork, path[0], path[1]), amounts[0]));
        _swap(fork, amounts, path, msg.sender);

        if (feeAmount.add(referralReward) > 0)
            _withdrawFeesAndRewards(address(0), path[path.length - 1], referee, feeAmount, referralReward);
    }

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        address fork,
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address referee
    ) external whenNotPaused isValidFork(fork) isValidReferee(referee) {

        require(path[path.length - 1] == WETH, "FloozRouter: INVALID_PATH");
        referee = _getReferee(referee);
        TransferHelper.safeTransferFrom(path[0], msg.sender, _pairFor(fork, path[0], path[1]), amountIn);
        _swapSupportingFeeOnTransferTokens(fork, path, address(this));
        uint256 amountOut = IERC20(WETH).balanceOf(address(this));
        IWETH(WETH).withdraw(amountOut);
        (uint256 amountWithdraw, uint256 feeAmount, uint256 referralReward) = _calculateFeesAndRewards(
            amountOut,
            referee,
            false
        );
        require(amountWithdraw >= amountOutMin, "FloozRouter: LOW_SLIPPAGE");
        TransferHelper.safeTransferETH(msg.sender, amountWithdraw);

        if (feeAmount.add(referralReward) > 0)
            _withdrawFeesAndRewards(address(0), path[path.length - 1], referee, feeAmount, referralReward);
    }

    function swapExactTokensForTokens(
        address fork,
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address referee
    ) external whenNotPaused isValidFork(fork) isValidReferee(referee) returns (uint256[] memory amounts) {

        referee = _getReferee(referee);
        (uint256 swapAmount, uint256 feeAmount, uint256 referralReward) = _calculateFeesAndRewards(
            amountIn,
            referee,
            false
        );
        amounts = _getAmountsOut(fork, swapAmount, path);
        require(amounts[amounts.length - 1] >= amountOutMin, "FloozRouter: INSUFFICIENT_OUTPUT_AMOUNT");
        TransferHelper.safeTransferFrom(path[0], msg.sender, _pairFor(fork, path[0], path[1]), swapAmount);
        _swap(fork, amounts, path, msg.sender);

        if (feeAmount.add(referralReward) > 0)
            _withdrawFeesAndRewards(path[0], path[path.length - 1], referee, feeAmount, referralReward);
    }

    function swapExactTokensForETH(
        address fork,
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address referee
    ) external whenNotPaused isValidFork(fork) isValidReferee(referee) returns (uint256[] memory amounts) {

        require(path[path.length - 1] == WETH, "FloozRouter: INVALID_PATH");
        referee = _getReferee(referee);
        amounts = _getAmountsOut(fork, amountIn, path);
        (uint256 amountWithdraw, uint256 feeAmount, uint256 referralReward) = _calculateFeesAndRewards(
            amounts[amounts.length - 1],
            referee,
            false
        );
        require(amountWithdraw >= amountOutMin, "FloozRouter: INSUFFICIENT_OUTPUT_AMOUNT");
        TransferHelper.safeTransferFrom(path[0], msg.sender, _pairFor(fork, path[0], path[1]), amounts[0]);
        _swap(fork, amounts, path, address(this));
        IWETH(WETH).withdraw(amounts[amounts.length - 1]);
        TransferHelper.safeTransferETH(msg.sender, amountWithdraw);

        if (feeAmount.add(referralReward) > 0)
            _withdrawFeesAndRewards(address(0), path[path.length - 1], referee, feeAmount, referralReward);
    }

    function swapETHForExactTokens(
        address fork,
        uint256 amountOut,
        address[] calldata path,
        address referee
    ) external payable whenNotPaused isValidFork(fork) isValidReferee(referee) returns (uint256[] memory amounts) {

        require(path[0] == WETH, "FloozRouter: INVALID_PATH");
        amounts = _getAmountsIn(fork, amountOut, path);
        (, uint256 feeAmount, uint256 referralReward) = _calculateFeesAndRewards(amounts[0], referee, true);
        require(amounts[0].add(feeAmount).add(referralReward) <= msg.value, "FloozRouter: EXCESSIVE_INPUT_AMOUNT");

        IWETH(WETH).deposit{value: amounts[0]}();
        assert(IWETH(WETH).transfer(_pairFor(fork, path[0], path[1]), amounts[0]));
        _swap(fork, amounts, path, msg.sender);

        if (msg.value > amounts[0].add(feeAmount).add(referralReward))
            TransferHelper.safeTransferETH(msg.sender, msg.value - amounts[0].add(feeAmount).add(referralReward));

        if (feeAmount.add(referralReward) > 0)
            _withdrawFeesAndRewards(address(0), path[path.length - 1], referee, feeAmount, referralReward);
    }

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        address fork,
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address referee
    ) external whenNotPaused isValidFork(fork) isValidReferee(referee) {

        referee = _getReferee(referee);
        (uint256 swapAmount, uint256 feeAmount, uint256 referralReward) = _calculateFeesAndRewards(
            amountIn,
            referee,
            false
        );
        TransferHelper.safeTransferFrom(path[0], msg.sender, _pairFor(fork, path[0], path[1]), swapAmount);
        uint256 balanceBefore = IERC20(path[path.length - 1]).balanceOf(msg.sender);
        _swapSupportingFeeOnTransferTokens(fork, path, msg.sender);
        require(
            IERC20(path[path.length - 1]).balanceOf(msg.sender).sub(balanceBefore) >= amountOutMin,
            "FloozRouter: INSUFFICIENT_OUTPUT_AMOUNT"
        );

        if (feeAmount.add(referralReward) > 0)
            _withdrawFeesAndRewards(path[0], path[path.length - 1], referee, feeAmount, referralReward);
    }

    function swapTokensForExactTokens(
        address fork,
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address referee
    ) external whenNotPaused isValidFork(fork) isValidReferee(referee) returns (uint256[] memory amounts) {

        referee = _getReferee(referee);
        amounts = _getAmountsIn(fork, amountOut, path);
        (, uint256 feeAmount, uint256 referralReward) = _calculateFeesAndRewards(amounts[0], referee, true);

        require(amounts[0].add(feeAmount).add(referralReward) <= amountInMax, "FloozRouter: EXCESSIVE_INPUT_AMOUNT");
        TransferHelper.safeTransferFrom(path[0], msg.sender, _pairFor(fork, path[0], path[1]), amounts[0]);
        _swap(fork, amounts, path, msg.sender);

        if (feeAmount.add(referralReward) > 0)
            _withdrawFeesAndRewards(path[0], path[path.length - 1], referee, feeAmount, referralReward);
    }

    function swapTokensForExactETH(
        address fork,
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address referee
    ) external whenNotPaused isValidFork(fork) isValidReferee(referee) returns (uint256[] memory amounts) {

        require(path[path.length - 1] == WETH, "FloozRouter: INVALID_PATH");
        referee = _getReferee(referee);

        (, uint256 feeAmount, uint256 referralReward) = _calculateFeesAndRewards(amountOut, referee, true);

        amounts = _getAmountsIn(fork, amountOut.add(feeAmount).add(referralReward), path);
        require(amounts[0].add(feeAmount).add(referralReward) <= amountInMax, "FloozRouter: EXCESSIVE_INPUT_AMOUNT");
        TransferHelper.safeTransferFrom(path[0], msg.sender, _pairFor(fork, path[0], path[1]), amounts[0]);
        _swap(fork, amounts, path, address(this));
        IWETH(WETH).withdraw(amounts[amounts.length - 1]);

        TransferHelper.safeTransferETH(msg.sender, amountOut);
        if (feeAmount.add(referralReward) > 0)
            _withdrawFeesAndRewards(address(0), path[path.length - 1], referee, feeAmount, referralReward);
    }

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        address fork,
        uint256 amountOutMin,
        address[] calldata path,
        address referee
    ) external payable whenNotPaused isValidFork(fork) isValidReferee(referee) {

        require(path[0] == WETH, "FloozRouter: INVALID_PATH");
        referee = _getReferee(referee);
        (uint256 swapAmount, uint256 feeAmount, uint256 referralReward) = _calculateFeesAndRewards(
            msg.value,
            referee,
            false
        );
        IWETH(WETH).deposit{value: swapAmount}();
        assert(IWETH(WETH).transfer(_pairFor(fork, path[0], path[1]), swapAmount));
        uint256 balanceBefore = IERC20(path[path.length - 1]).balanceOf(msg.sender);
        _swapSupportingFeeOnTransferTokens(fork, path, msg.sender);
        require(
            IERC20(path[path.length - 1]).balanceOf(msg.sender).sub(balanceBefore) >= amountOutMin,
            "FloozRouter: INSUFFICIENT_OUTPUT_AMOUNT"
        );
        if (feeAmount.add(referralReward) > 0)
            _withdrawFeesAndRewards(address(0), path[path.length - 1], referee, feeAmount, referralReward);
    }

    function _getReferee(address referee) internal returns (address) {

        address sender = msg.sender;
        if (!referralRegistry.hasUserReferee(sender) && referee != address(0)) {
            referralRegistry.createReferralAnchor(sender, referee);
        }
        return referralRegistry.getUserReferee(sender);
    }

    function _swap(
        address fork,
        uint256[] memory amounts,
        address[] memory path,
        address _to
    ) internal {

        for (uint256 i; i < path.length - 1; i++) {
            (address input, address output) = (path[i], path[i + 1]);
            (address token0, ) = PancakeLibrary.sortTokens(input, output);
            uint256 amountOut = amounts[i + 1];
            (uint256 amount0Out, uint256 amount1Out) = input == token0
                ? (uint256(0), amountOut)
                : (amountOut, uint256(0));
            address to = i < path.length - 2 ? _pairFor(fork, output, path[i + 2]) : _to;
            IPancakePair(_pairFor(fork, input, output)).swap(amount0Out, amount1Out, to, new bytes(0));
        }
    }

    function _swapSupportingFeeOnTransferTokens(
        address fork,
        address[] memory path,
        address _to
    ) internal {

        for (uint256 i; i < path.length - 1; i++) {
            (address input, address output) = (path[i], path[i + 1]);
            (address token0, ) = PancakeLibrary.sortTokens(input, output);
            IPancakePair pair = IPancakePair(_pairFor(fork, input, output));
            uint256 amountInput;
            uint256 amountOutput;
            {
                (uint256 reserve0, uint256 reserve1, ) = pair.getReserves();
                (uint256 reserveInput, uint256 reserveOutput) = input == token0
                    ? (reserve0, reserve1)
                    : (reserve1, reserve0);
                amountInput = IERC20(input).balanceOf(address(pair)).sub(reserveInput);
                amountOutput = _getAmountOut(amountInput, reserveInput, reserveOutput);
            }
            (uint256 amount0Out, uint256 amount1Out) = input == token0
                ? (uint256(0), amountOutput)
                : (amountOutput, uint256(0));
            address to = i < path.length - 2 ? _pairFor(fork, output, path[i + 2]) : _to;
            pair.swap(amount0Out, amount1Out, to, new bytes(0));
        }
    }

    function executeZeroExSwap(
        bytes calldata data,
        address tokenOut,
        address tokenIn,
        address referee
    ) external payable nonReentrant whenNotPaused isValidReferee(referee) {

        referee = _getReferee(referee);
        bytes4 selector = data.readBytes4(0);
        address impl = IZerox(zeroEx).getFunctionImplementation(selector);
        require(impl != address(0), "FloozRouter: NO_IMPLEMENTATION");

        bool isAboveThreshold = userAboveBalanceThreshold(msg.sender);
        if (isAboveThreshold) {
            (bool success, ) = impl.delegatecall(data);
            require(success, "FloozRouter: REVERTED");
        } else {
            if (msg.value > 0) {
                (uint256 swapAmount, uint256 feeAmount, uint256 referralReward) = _calculateFeesAndRewards(
                    msg.value,
                    referee,
                    false
                );
                (bool success, ) = impl.call{value: swapAmount}(data);
                require(success, "FloozRouter: REVERTED");
                TransferHelper.safeTransfer(tokenIn, msg.sender, IERC20(tokenIn).balanceOf(address(this)));
                _withdrawFeesAndRewards(address(0), tokenIn, referee, feeAmount, referralReward);
            } else {
                uint256 balanceBefore = IERC20(tokenOut).balanceOf(msg.sender);
                (bool success, ) = impl.delegatecall(data);
                require(success, "FloozRouter: REVERTED");
                uint256 balanceAfter = IERC20(tokenOut).balanceOf(msg.sender);
                require(balanceBefore > balanceAfter, "INVALID_TOKEN");
                (, uint256 feeAmount, uint256 referralReward) = _calculateFeesAndRewards(
                    balanceBefore.sub(balanceAfter),
                    referee,
                    true
                );
                _withdrawFeesAndRewards(tokenOut, tokenIn, referee, feeAmount, referralReward);
            }
        }
    }

    function _calculateFeesAndRewards(
        uint256 amount,
        address referee,
        bool additiveFee
    )
        internal
        view
        returns (
            uint256 swapAmount,
            uint256 feeAmount,
            uint256 referralReward
        )
    {

        if (userAboveBalanceThreshold(msg.sender)) {
            swapAmount = amount;
        } else {
            if (additiveFee) {
                swapAmount = amount;
                feeAmount = swapAmount.mul(FEE_DENOMINATOR).div(FEE_DENOMINATOR.sub(swapFee)).sub(amount);
            } else {
                feeAmount = amount.mul(swapFee).div(FEE_DENOMINATOR);
                swapAmount = amount.sub(feeAmount);
            }

            if (referee != address(0) && referralsActivated) {
                uint16 referralRate = customReferralRewardRate[referee] > 0
                    ? customReferralRewardRate[referee]
                    : referralRewardRate;
                referralReward = feeAmount.mul(referralRate).div(FEE_DENOMINATOR);
                feeAmount = feeAmount.sub(referralReward);
            } else {
                referralReward = 0;
            }
        }
    }

    function updateFork(
        address _factory,
        bytes calldata _initCode,
        bool _activated
    ) external onlyOwner {

        forkActivated[_factory] = _activated;
        forkInitCode[_factory] = _initCode;
        emit ForkUpdated(_factory);
    }

    function userAboveBalanceThreshold(address _account) public view returns (bool) {

        return saveYourAssetsToken.balanceOf(_account) >= balanceThreshold;
    }

    function getUserFee(address user) public view returns (uint256) {

        saveYourAssetsToken.balanceOf(user) >= balanceThreshold ? 0 : swapFee;
    }

    function updateSwapFee(uint16 newSwapFee) external onlyOwner {

        swapFee = newSwapFee;
        emit SwapFeeUpdated(newSwapFee);
    }

    function updateReferralRewardRate(uint16 newReferralRewardRate) external onlyOwner {

        require(newReferralRewardRate <= FEE_DENOMINATOR, "FloozRouter: INVALID_RATE");
        referralRewardRate = newReferralRewardRate;
        emit ReferralRewardRateUpdated(newReferralRewardRate);
    }

    function updateFeeReceiver(address payable newFeeReceiver) external onlyOwner {

        feeReceiver = newFeeReceiver;
        emit FeeReceiverUpdated(newFeeReceiver);
    }

    function updateBalanceThreshold(uint256 newBalanceThreshold) external onlyOwner {

        balanceThreshold = newBalanceThreshold;
        emit BalanceThresholdUpdated(balanceThreshold);
    }

    function updateReferralsActivated(bool newReferralsActivated) external onlyOwner {

        referralsActivated = newReferralsActivated;
        emit ReferralsActivatedUpdated(newReferralsActivated);
    }

    function updateReferralRegistry(address newReferralRegistry) external onlyOwner {

        referralRegistry = IReferralRegistry(newReferralRegistry);
        emit ReferralRegistryUpdated(newReferralRegistry);
    }

    function updateCustomReferralRewardRate(address account, uint16 referralRate) external onlyOwner returns (uint256) {

        require(referralRate <= FEE_DENOMINATOR, "FloozRouter: INVALID_RATE");
        customReferralRewardRate[account] = referralRate;
        emit CustomReferralRewardRateUpdated(account, referralRate);
    }

    function getUserReferee(address user) external view returns (address) {

        return referralRegistry.getUserReferee(user);
    }

    function hasUserReferee(address user) external view returns (bool) {

        return referralRegistry.hasUserReferee(user);
    }

    function withdrawETH(address payable to, uint256 amount) external onlyOwner {

        TransferHelper.safeTransferETH(to, amount);
    }

    function withdrawERC20Token(
        address token,
        address to,
        uint256 amount
    ) external onlyOwner {

        TransferHelper.safeTransfer(token, to, amount);
    }

    function _withdrawFeesAndRewards(
        address tokenReward,
        address tokenOut,
        address referee,
        uint256 feeAmount,
        uint256 referralReward
    ) internal {

        if (tokenReward == address(0)) {
            TransferHelper.safeTransferETH(feeReceiver, feeAmount);
            if (referralReward > 0) {
                TransferHelper.safeTransferETH(referee, referralReward);
                emit ReferralRewardPaid(msg.sender, referee, tokenOut, tokenReward, referralReward);
            }
        } else {
            TransferHelper.safeTransferFrom(tokenReward, msg.sender, feeReceiver, feeAmount);
            if (referralReward > 0) {
                TransferHelper.safeTransferFrom(tokenReward, msg.sender, referee, referralReward);
                emit ReferralRewardPaid(msg.sender, referee, tokenOut, tokenReward, referralReward);
            }
        }
    }

    function _getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    ) internal pure returns (uint256 amountOut) {

        require(amountIn > 0, "FloozRouter: INSUFFICIENT_INPUT_AMOUNT");
        require(reserveIn > 0 && reserveOut > 0, "FloozRouter: INSUFFICIENT_LIQUIDITY");
        uint256 amountInWithFee = amountIn.mul((9980));
        uint256 numerator = amountInWithFee.mul(reserveOut);
        uint256 denominator = reserveIn.mul(10000).add(amountInWithFee);
        amountOut = numerator / denominator;
    }

    function _getAmountIn(
        uint256 amountOut,
        uint256 reserveIn,
        uint256 reserveOut
    ) internal pure returns (uint256 amountIn) {

        require(amountOut > 0, "FloozRouter: INSUFFICIENT_OUTPUT_AMOUNT");
        require(reserveIn > 0 && reserveOut > 0, "FloozRouter: INSUFFICIENT_LIQUIDITY");
        uint256 numerator = reserveIn.mul(amountOut).mul(10000);
        uint256 denominator = reserveOut.sub(amountOut).mul(9980);
        amountIn = (numerator / denominator).add(1);
    }

    function _getAmountsOut(
        address fork,
        uint256 amountIn,
        address[] memory path
    ) internal view returns (uint256[] memory amounts) {

        require(path.length >= 2, "FloozRouter: INVALID_PATH");
        amounts = new uint256[](path.length);
        amounts[0] = amountIn;
        for (uint256 i; i < path.length - 1; i++) {
            (uint256 reserveIn, uint256 reserveOut) = _getReserves(fork, path[i], path[i + 1]);
            amounts[i + 1] = _getAmountOut(amounts[i], reserveIn, reserveOut);
        }
    }

    function _getAmountsIn(
        address factory,
        uint256 amountOut,
        address[] memory path
    ) internal view returns (uint256[] memory amounts) {

        require(path.length >= 2, "FloozRouter: INVALID_PATH");
        amounts = new uint256[](path.length);
        amounts[amounts.length - 1] = amountOut;
        for (uint256 i = path.length - 1; i > 0; i--) {
            (uint256 reserveIn, uint256 reserveOut) = _getReserves(factory, path[i - 1], path[i]);
            amounts[i - 1] = _getAmountIn(amounts[i], reserveIn, reserveOut);
        }
    }

    function _getReserves(
        address factory,
        address tokenA,
        address tokenB
    ) internal view returns (uint256 reserveA, uint256 reserveB) {

        (address token0, ) = PancakeLibrary.sortTokens(tokenA, tokenB);
        (uint256 reserve0, uint256 reserve1, ) = IPancakePair(_pairFor(factory, tokenA, tokenB)).getReserves();
        (reserveA, reserveB) = tokenA == token0 ? (reserve0, reserve1) : (reserve1, reserve0);
    }

    function _pairFor(
        address factory,
        address tokenA,
        address tokenB
    ) internal view returns (address pair) {

        (address token0, address token1) = PancakeLibrary.sortTokens(tokenA, tokenB);
        pair = address(
            uint256(
                keccak256(
                    abi.encodePacked(
                        hex"ff",
                        factory,
                        keccak256(abi.encodePacked(token0, token1)),
                        forkInitCode[factory] // init code hash
                    )
                )
            )
        );
    }

    function pause() external onlyOwner {

        _pause();
    }

    function unpause() external onlyOwner {

        _unpause();
    }

    receive() external payable {}

    modifier isValidFork(address factory) {

        require(forkActivated[factory], "FloozRouter: INVALID_FACTORY");
        _;
    }

    modifier isValidReferee(address referee) {

        require(msg.sender != referee, "FloozRouter: SELF_REFERRAL");
        _;
    }
}pragma solidity =0.6.6;
pragma experimental ABIEncoderV2;


contract FloozMultichainRouter is Ownable, Pausable, ReentrancyGuard {

    using SafeMath for uint256;

    event SwapFeeUpdated(uint16 swapFee);
    event ReferralRegistryUpdated(address referralRegistry);
    event ReferralRewardRateUpdated(uint16 referralRewardRate);
    event ReferralsActivatedUpdated(bool activated);
    event FeeReceiverUpdated(address payable feeReceiver);
    event CustomReferralRewardRateUpdated(address indexed account, uint16 referralRate);
    event ReferralRewardPaid(address from, address indexed to, address tokenOut, address tokenReward, uint256 amount);
    event ForkCreated(address factory);
    event ForkUpdated(address factory);

    struct SwapData {
        address fork;
        address referee;
        bool fee;
    }

    struct ExternalSwapData {
        bytes data;
        address fromToken;
        address toToken;
        uint256 amountFrom;
        address referee;
        uint256 minOut;
        bool fee;
    }

    uint256 public constant FEE_DENOMINATOR = 10000;

    uint16 public swapFee;

    address public immutable WETH;

    address payable public immutable zeroEx;

    address payable public immutable oneInch;

    IReferralRegistry public referralRegistry;

    address payable public feeReceiver;

    uint16 public referralRewardRate;

    bool public referralsActivated;

    mapping(address => uint16) public customReferralRewardRate;

    mapping(address => bool) public forkActivated;

    mapping(address => bytes) public forkInitCode;

    constructor(
        address _WETH,
        uint16 _swapFee,
        uint16 _referralRewardRate,
        address payable _feeReceiver,
        IReferralRegistry _referralRegistry,
        address payable _zeroEx,
        address payable _oneInch
    ) public {
        WETH = _WETH;
        swapFee = _swapFee;
        referralRewardRate = _referralRewardRate;
        feeReceiver = _feeReceiver;
        referralRegistry = _referralRegistry;
        zeroEx = _zeroEx;
        oneInch = _oneInch;
        referralsActivated = true;
    }

    function swapExactETHForTokens(
        SwapData calldata swapData,
        uint256 amountOutMin,
        address[] calldata path
    )
        external
        payable
        whenNotPaused
        isValidFork(swapData.fork)
        isValidReferee(swapData.referee)
        returns (uint256[] memory amounts)
    {

        require(path[0] == WETH, "FloozRouter: INVALID_PATH");
        address referee = _getReferee(swapData.referee);
        (uint256 swapAmount, uint256 feeAmount, uint256 referralReward) = _calculateFeesAndRewards(
            swapData.fee,
            msg.value,
            referee,
            false
        );
        amounts = _getAmountsOut(swapData.fork, swapAmount, path);
        require(amounts[amounts.length - 1] >= amountOutMin, "FloozRouter: INSUFFICIENT_OUTPUT_AMOUNT");
        IWETH(WETH).deposit{value: amounts[0]}();
        assert(IWETH(WETH).transfer(_pairFor(swapData.fork, path[0], path[1]), amounts[0]));
        _swap(swapData.fork, amounts, path, msg.sender);

        if (feeAmount.add(referralReward) > 0)
            _withdrawFeesAndRewards(address(0), path[path.length - 1], referee, feeAmount, referralReward);
    }

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        SwapData calldata swapData,
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path
    ) external whenNotPaused isValidFork(swapData.fork) isValidReferee(swapData.referee) {

        require(path[path.length - 1] == WETH, "FloozRouter: INVALID_PATH");
        address referee = _getReferee(swapData.referee);
        TransferHelper.safeTransferFrom(path[0], msg.sender, _pairFor(swapData.fork, path[0], path[1]), amountIn);
        _swapSupportingFeeOnTransferTokens(swapData.fork, path, address(this));
        uint256 amountOut = IERC20(WETH).balanceOf(address(this));
        IWETH(WETH).withdraw(amountOut);
        (uint256 amountWithdraw, uint256 feeAmount, uint256 referralReward) = _calculateFeesAndRewards(
            swapData.fee,
            amountOut,
            referee,
            false
        );
        require(amountWithdraw >= amountOutMin, "FloozRouter: LOW_SLIPPAGE");
        TransferHelper.safeTransferETH(msg.sender, amountWithdraw);

        if (feeAmount.add(referralReward) > 0)
            _withdrawFeesAndRewards(address(0), path[path.length - 1], referee, feeAmount, referralReward);
    }

    function swapExactTokensForTokens(
        SwapData calldata swapData,
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path
    )
        external
        whenNotPaused
        isValidFork(swapData.fork)
        isValidReferee(swapData.referee)
        returns (uint256[] memory amounts)
    {

        address referee = _getReferee(swapData.referee);
        (uint256 swapAmount, uint256 feeAmount, uint256 referralReward) = _calculateFeesAndRewards(
            swapData.fee,
            amountIn,
            referee,
            false
        );
        amounts = _getAmountsOut(swapData.fork, swapAmount, path);
        require(amounts[amounts.length - 1] >= amountOutMin, "FloozRouter: INSUFFICIENT_OUTPUT_AMOUNT");
        TransferHelper.safeTransferFrom(path[0], msg.sender, _pairFor(swapData.fork, path[0], path[1]), swapAmount);
        _swap(swapData.fork, amounts, path, msg.sender);

        if (feeAmount.add(referralReward) > 0)
            _withdrawFeesAndRewards(path[0], path[path.length - 1], referee, feeAmount, referralReward);
    }

    function swapExactTokensForETH(
        SwapData calldata swapData,
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path
    )
        external
        whenNotPaused
        isValidFork(swapData.fork)
        isValidReferee(swapData.referee)
        returns (uint256[] memory amounts)
    {

        require(path[path.length - 1] == WETH, "FloozRouter: INVALID_PATH");
        address referee = _getReferee(swapData.referee);
        amounts = _getAmountsOut(swapData.fork, amountIn, path);
        (uint256 amountWithdraw, uint256 feeAmount, uint256 referralReward) = _calculateFeesAndRewards(
            swapData.fee,
            amounts[amounts.length - 1],
            referee,
            false
        );
        require(amountWithdraw >= amountOutMin, "FloozRouter: INSUFFICIENT_OUTPUT_AMOUNT");
        TransferHelper.safeTransferFrom(path[0], msg.sender, _pairFor(swapData.fork, path[0], path[1]), amounts[0]);
        _swap(swapData.fork, amounts, path, address(this));
        IWETH(WETH).withdraw(amounts[amounts.length - 1]);
        TransferHelper.safeTransferETH(msg.sender, amountWithdraw);

        if (feeAmount.add(referralReward) > 0)
            _withdrawFeesAndRewards(address(0), path[path.length - 1], referee, feeAmount, referralReward);
    }

    function swapETHForExactTokens(
        SwapData calldata swapData,
        uint256 amountOut,
        address[] calldata path
    )
        external
        payable
        whenNotPaused
        isValidFork(swapData.fork)
        isValidReferee(swapData.referee)
        returns (uint256[] memory amounts)
    {

        require(path[0] == WETH, "FloozRouter: INVALID_PATH");
        address referee = _getReferee(swapData.referee);
        amounts = _getAmountsIn(swapData.fork, amountOut, path);
        (, uint256 feeAmount, uint256 referralReward) = _calculateFeesAndRewards(
            swapData.fee,
            amounts[0],
            referee,
            true
        );
        require(amounts[0].add(feeAmount).add(referralReward) <= msg.value, "FloozRouter: EXCESSIVE_INPUT_AMOUNT");

        IWETH(WETH).deposit{value: amounts[0]}();
        assert(IWETH(WETH).transfer(_pairFor(swapData.fork, path[0], path[1]), amounts[0]));
        _swap(swapData.fork, amounts, path, msg.sender);

        if (msg.value > amounts[0].add(feeAmount).add(referralReward))
            TransferHelper.safeTransferETH(msg.sender, msg.value - amounts[0].add(feeAmount).add(referralReward));

        if (feeAmount.add(referralReward) > 0)
            _withdrawFeesAndRewards(address(0), path[path.length - 1], referee, feeAmount, referralReward);
    }

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        SwapData calldata swapData,
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path
    ) external whenNotPaused isValidFork(swapData.fork) isValidReferee(swapData.referee) {

        address referee = _getReferee(swapData.referee);
        (uint256 swapAmount, uint256 feeAmount, uint256 referralReward) = _calculateFeesAndRewards(
            swapData.fee,
            amountIn,
            referee,
            false
        );
        TransferHelper.safeTransferFrom(path[0], msg.sender, _pairFor(swapData.fork, path[0], path[1]), swapAmount);
        uint256 balanceBefore = IERC20(path[path.length - 1]).balanceOf(msg.sender);
        _swapSupportingFeeOnTransferTokens(swapData.fork, path, msg.sender);
        require(
            IERC20(path[path.length - 1]).balanceOf(msg.sender).sub(balanceBefore) >= amountOutMin,
            "FloozRouter: INSUFFICIENT_OUTPUT_AMOUNT"
        );

        if (feeAmount.add(referralReward) > 0)
            _withdrawFeesAndRewards(path[0], path[path.length - 1], referee, feeAmount, referralReward);
    }

    function swapTokensForExactTokens(
        SwapData calldata swapData,
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path
    )
        external
        whenNotPaused
        isValidFork(swapData.fork)
        isValidReferee(swapData.referee)
        returns (uint256[] memory amounts)
    {

        address referee = _getReferee(swapData.referee);
        amounts = _getAmountsIn(swapData.fork, amountOut, path);
        (, uint256 feeAmount, uint256 referralReward) = _calculateFeesAndRewards(
            swapData.fee,
            amounts[0],
            referee,
            true
        );

        require(amounts[0].add(feeAmount).add(referralReward) <= amountInMax, "FloozRouter: EXCESSIVE_INPUT_AMOUNT");
        TransferHelper.safeTransferFrom(path[0], msg.sender, _pairFor(swapData.fork, path[0], path[1]), amounts[0]);
        _swap(swapData.fork, amounts, path, msg.sender);

        if (feeAmount.add(referralReward) > 0)
            _withdrawFeesAndRewards(path[0], path[path.length - 1], referee, feeAmount, referralReward);
    }

    function swapTokensForExactETH(
        SwapData calldata swapData,
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path
    )
        external
        whenNotPaused
        isValidFork(swapData.fork)
        isValidReferee(swapData.referee)
        returns (uint256[] memory amounts)
    {

        require(path[path.length - 1] == WETH, "FloozRouter: INVALID_PATH");
        address referee = _getReferee(swapData.referee);

        (, uint256 feeAmount, uint256 referralReward) = _calculateFeesAndRewards(
            swapData.fee,
            amountOut,
            referee,
            true
        );

        amounts = _getAmountsIn(swapData.fork, amountOut.add(feeAmount).add(referralReward), path);
        require(amounts[0].add(feeAmount).add(referralReward) <= amountInMax, "FloozRouter: EXCESSIVE_INPUT_AMOUNT");
        TransferHelper.safeTransferFrom(path[0], msg.sender, _pairFor(swapData.fork, path[0], path[1]), amounts[0]);
        _swap(swapData.fork, amounts, path, address(this));
        IWETH(WETH).withdraw(amounts[amounts.length - 1]);

        TransferHelper.safeTransferETH(msg.sender, amountOut);
        if (feeAmount.add(referralReward) > 0)
            _withdrawFeesAndRewards(address(0), path[path.length - 1], referee, feeAmount, referralReward);
    }

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        SwapData calldata swapData,
        uint256 amountOutMin,
        address[] calldata path
    ) external payable whenNotPaused isValidFork(swapData.fork) isValidReferee(swapData.referee) {

        require(path[0] == WETH, "FloozRouter: INVALID_PATH");
        address referee = _getReferee(swapData.referee);
        (uint256 swapAmount, uint256 feeAmount, uint256 referralReward) = _calculateFeesAndRewards(
            swapData.fee,
            msg.value,
            referee,
            false
        );
        IWETH(WETH).deposit{value: swapAmount}();
        assert(IWETH(WETH).transfer(_pairFor(swapData.fork, path[0], path[1]), swapAmount));
        uint256 balanceBefore = IERC20(path[path.length - 1]).balanceOf(msg.sender);
        _swapSupportingFeeOnTransferTokens(swapData.fork, path, msg.sender);
        require(
            IERC20(path[path.length - 1]).balanceOf(msg.sender).sub(balanceBefore) >= amountOutMin,
            "FloozRouter: INSUFFICIENT_OUTPUT_AMOUNT"
        );
        if (feeAmount.add(referralReward) > 0)
            _withdrawFeesAndRewards(address(0), path[path.length - 1], referee, feeAmount, referralReward);
    }

    function _getReferee(address referee) internal returns (address) {

        address sender = msg.sender;
        if (!referralRegistry.hasUserReferee(sender) && referee != address(0)) {
            referralRegistry.createReferralAnchor(sender, referee);
        }
        return referralRegistry.getUserReferee(sender);
    }

    function _swap(
        address fork,
        uint256[] memory amounts,
        address[] memory path,
        address _to
    ) internal {

        for (uint256 i; i < path.length - 1; i++) {
            (address input, address output) = (path[i], path[i + 1]);
            (address token0, ) = PancakeLibrary.sortTokens(input, output);
            uint256 amountOut = amounts[i + 1];
            (uint256 amount0Out, uint256 amount1Out) = input == token0
                ? (uint256(0), amountOut)
                : (amountOut, uint256(0));
            address to = i < path.length - 2 ? _pairFor(fork, output, path[i + 2]) : _to;
            IPancakePair(_pairFor(fork, input, output)).swap(amount0Out, amount1Out, to, new bytes(0));
        }
    }

    function _swapSupportingFeeOnTransferTokens(
        address fork,
        address[] memory path,
        address _to
    ) internal {

        for (uint256 i; i < path.length - 1; i++) {
            (address input, address output) = (path[i], path[i + 1]);
            (address token0, ) = PancakeLibrary.sortTokens(input, output);
            IPancakePair pair = IPancakePair(_pairFor(fork, input, output));
            uint256 amountInput;
            uint256 amountOutput;
            {
                (uint256 reserve0, uint256 reserve1, ) = pair.getReserves();
                (uint256 reserveInput, uint256 reserveOutput) = input == token0
                    ? (reserve0, reserve1)
                    : (reserve1, reserve0);
                amountInput = IERC20(input).balanceOf(address(pair)).sub(reserveInput);
                amountOutput = _getAmountOut(amountInput, reserveInput, reserveOutput);
            }
            (uint256 amount0Out, uint256 amount1Out) = input == token0
                ? (uint256(0), amountOutput)
                : (amountOutput, uint256(0));
            address to = i < path.length - 2 ? _pairFor(fork, output, path[i + 2]) : _to;
            pair.swap(amount0Out, amount1Out, to, new bytes(0));
        }
    }

    function executeOneInchSwap(ExternalSwapData calldata swapData)
        external
        payable
        nonReentrant
        whenNotPaused
        isValidReferee(swapData.referee)
    {

        address referee = _getReferee(swapData.referee);
        uint256 balanceBefore;
        if (swapData.toToken == address(0)) {
            balanceBefore = msg.sender.balance;
        } else {
            balanceBefore = IERC20(swapData.toToken).balanceOf(msg.sender);
        }
        if (!swapData.fee) {
            if (swapData.fromToken != address(0)) {
                IERC20(swapData.fromToken).transferFrom(msg.sender, address(this), swapData.amountFrom);
                IERC20(swapData.fromToken).approve(oneInch, swapData.amountFrom);
            }
            (bool success, ) = address(oneInch).call{value: msg.value}(swapData.data);
            require(success, "FloozRouter: REVERTED");
        } else {
            if (msg.value > 0 && swapData.fromToken == address(0)) {
                (uint256 swapAmount, uint256 feeAmount, uint256 referralReward) = _calculateFeesAndRewards(
                    swapData.fee,
                    msg.value,
                    referee,
                    false
                );
                (bool success, ) = address(oneInch).call{value: swapAmount}(swapData.data);
                require(success, "FloozRouter: REVERTED");
                _withdrawFeesAndRewards(address(0), swapData.toToken, referee, feeAmount, referralReward);
            } else {
                (uint256 swapAmount, uint256 feeAmount, uint256 referralReward) = _calculateFeesAndRewards(
                    swapData.fee,
                    swapData.amountFrom,
                    referee,
                    false
                );
                IERC20(swapData.fromToken).transferFrom(msg.sender, address(this), swapAmount);
                IERC20(swapData.fromToken).approve(oneInch, swapAmount);
                (bool success, ) = address(oneInch).call(swapData.data);
                require(success, "FloozRouter: REVERTED");
                _withdrawFeesAndRewards(swapData.fromToken, swapData.toToken, referee, feeAmount, referralReward);
            }
            uint256 balanceAfter;
            if (swapData.toToken == address(0)) {
                balanceAfter = msg.sender.balance;
            } else {
                balanceAfter = IERC20(swapData.toToken).balanceOf(msg.sender);
            }
            require(balanceAfter.sub(balanceBefore) >= swapData.minOut, "FloozRouter: INSUFFICIENT_OUTPUT");
        }
    }

    function executeZeroExSwap(ExternalSwapData calldata swapData)
        external
        payable
        nonReentrant
        whenNotPaused
        isValidReferee(swapData.referee)
    {

        address referee = _getReferee(swapData.referee);
        uint256 balanceBefore;
        if (swapData.toToken == address(0)) {
            balanceBefore = msg.sender.balance;
        } else {
            balanceBefore = IERC20(swapData.toToken).balanceOf(msg.sender);
        }
        if (!swapData.fee) {
            if (msg.value > 0 && swapData.fromToken == address(0)) {
                (bool success, ) = zeroEx.call{value: msg.value}(swapData.data);
                require(success, "FloozRouter: REVERTED");
                TransferHelper.safeTransfer(
                    swapData.toToken,
                    msg.sender,
                    IERC20(swapData.toToken).balanceOf(address(this))
                );
            } else {
                IERC20(swapData.fromToken).transferFrom(msg.sender, address(this), swapData.amountFrom);
                IERC20(swapData.fromToken).approve(zeroEx, swapData.amountFrom);
                (bool success, ) = zeroEx.call(swapData.data);
                require(success, "FloozRouter: REVERTED");
                if (swapData.toToken == address(0)) {
                    TransferHelper.safeTransferETH(msg.sender, address(this).balance);
                } else {
                    TransferHelper.safeTransfer(
                        swapData.toToken,
                        msg.sender,
                        IERC20(swapData.toToken).balanceOf(address(this))
                    );
                }
            }
        } else {
            if (msg.value > 0 && swapData.fromToken == address(0)) {
                (uint256 swapAmount, uint256 feeAmount, uint256 referralReward) = _calculateFeesAndRewards(
                    swapData.fee,
                    msg.value,
                    referee,
                    false
                );
                (bool success, ) = zeroEx.call{value: swapAmount}(swapData.data);
                require(success, "FloozRouter: REVERTED");
                TransferHelper.safeTransfer(
                    swapData.toToken,
                    msg.sender,
                    IERC20(swapData.toToken).balanceOf(address(this))
                );
                _withdrawFeesAndRewards(address(0), swapData.toToken, referee, feeAmount, referralReward);
            } else {
                (uint256 swapAmount, uint256 feeAmount, uint256 referralReward) = _calculateFeesAndRewards(
                    swapData.fee,
                    swapData.amountFrom,
                    referee,
                    false
                );
                IERC20(swapData.fromToken).transferFrom(msg.sender, address(this), swapAmount);
                IERC20(swapData.fromToken).approve(zeroEx, swapAmount);
                (bool success, ) = zeroEx.call(swapData.data);
                require(success, "FloozRouter: REVERTED");
                if (swapData.toToken == address(0)) {
                    TransferHelper.safeTransferETH(msg.sender, address(this).balance);
                } else {
                    TransferHelper.safeTransfer(
                        swapData.toToken,
                        msg.sender,
                        IERC20(swapData.toToken).balanceOf(address(this))
                    );
                }
                _withdrawFeesAndRewards(swapData.fromToken, swapData.toToken, referee, feeAmount, referralReward);
            }
        }
        uint256 balanceAfter;
        if (swapData.toToken == address(0)) {
            balanceAfter = msg.sender.balance;
        } else {
            balanceAfter = IERC20(swapData.toToken).balanceOf(msg.sender);
        }
        require(balanceAfter.sub(balanceBefore) >= swapData.minOut, "FloozRouter: INSUFFICIENT_OUTPUT");
    }

    function _calculateFeesAndRewards(
        bool fee,
        uint256 amount,
        address referee,
        bool additiveFee
    )
        internal
        view
        returns (
            uint256 swapAmount,
            uint256 feeAmount,
            uint256 referralReward
        )
    {

        uint16 swapFee = swapFee;
        if (!fee) {
            swapAmount = amount;
        } else {
            if (additiveFee) {
                swapAmount = amount;
                feeAmount = swapAmount.mul(FEE_DENOMINATOR).div(FEE_DENOMINATOR.sub(swapFee)).sub(amount);
            } else {
                feeAmount = amount.mul(swapFee).div(FEE_DENOMINATOR);
                swapAmount = amount.sub(feeAmount);
            }

            if (referee != address(0) && referralsActivated) {
                uint16 referralRate = customReferralRewardRate[referee] > 0
                    ? customReferralRewardRate[referee]
                    : referralRewardRate;
                referralReward = feeAmount.mul(referralRate).div(FEE_DENOMINATOR);
                feeAmount = feeAmount.sub(referralReward);
            } else {
                referralReward = 0;
            }
        }
    }

    function registerFork(address _factory, bytes calldata _initCode) external onlyOwner {

        require(!forkActivated[_factory], "FloozRouter: ACTIVE_FORK");
        forkActivated[_factory] = true;
        forkInitCode[_factory] = _initCode;
        emit ForkCreated(_factory);
    }

    function updateFork(
        address _factory,
        bytes calldata _initCode,
        bool _activated
    ) external onlyOwner {

        forkActivated[_factory] = _activated;
        forkInitCode[_factory] = _initCode;
        emit ForkUpdated(_factory);
    }

    function updateSwapFee(uint16 newSwapFee) external onlyOwner {

        swapFee = newSwapFee;
        emit SwapFeeUpdated(newSwapFee);
    }

    function updateReferralRewardRate(uint16 newReferralRewardRate) external onlyOwner {

        require(newReferralRewardRate <= FEE_DENOMINATOR, "FloozRouter: INVALID_RATE");
        referralRewardRate = newReferralRewardRate;
        emit ReferralRewardRateUpdated(newReferralRewardRate);
    }

    function updateFeeReceiver(address payable newFeeReceiver) external onlyOwner {

        feeReceiver = newFeeReceiver;
        emit FeeReceiverUpdated(newFeeReceiver);
    }

    function updateReferralsActivated(bool newReferralsActivated) external onlyOwner {

        referralsActivated = newReferralsActivated;
        emit ReferralsActivatedUpdated(newReferralsActivated);
    }

    function updateReferralRegistry(address newReferralRegistry) external onlyOwner {

        referralRegistry = IReferralRegistry(newReferralRegistry);
        emit ReferralRegistryUpdated(newReferralRegistry);
    }

    function updateCustomReferralRewardRate(address account, uint16 referralRate) external onlyOwner returns (uint256) {

        require(referralRate <= FEE_DENOMINATOR, "FloozRouter: INVALID_RATE");
        customReferralRewardRate[account] = referralRate;
        emit CustomReferralRewardRateUpdated(account, referralRate);
    }

    function getUserReferee(address user) external view returns (address) {

        return referralRegistry.getUserReferee(user);
    }

    function hasUserReferee(address user) external view returns (bool) {

        return referralRegistry.hasUserReferee(user);
    }

    function withdrawETH(address payable to, uint256 amount) external onlyOwner {

        TransferHelper.safeTransferETH(to, amount);
    }

    function withdrawERC20Token(
        address token,
        address to,
        uint256 amount
    ) external onlyOwner {

        TransferHelper.safeTransfer(token, to, amount);
    }

    function _withdrawFeesAndRewards(
        address tokenReward,
        address tokenOut,
        address referee,
        uint256 feeAmount,
        uint256 referralReward
    ) internal {

        if (tokenReward == address(0)) {
            TransferHelper.safeTransferETH(feeReceiver, feeAmount);
            if (referralReward > 0) {
                TransferHelper.safeTransferETH(referee, referralReward);
                emit ReferralRewardPaid(msg.sender, referee, tokenOut, tokenReward, referralReward);
            }
        } else {
            TransferHelper.safeTransferFrom(tokenReward, msg.sender, feeReceiver, feeAmount);
            if (referralReward > 0) {
                TransferHelper.safeTransferFrom(tokenReward, msg.sender, referee, referralReward);
                emit ReferralRewardPaid(msg.sender, referee, tokenOut, tokenReward, referralReward);
            }
        }
    }

    function _getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    ) internal pure returns (uint256 amountOut) {

        require(amountIn > 0, "FloozRouter: INSUFFICIENT_INPUT_AMOUNT");
        require(reserveIn > 0 && reserveOut > 0, "FloozRouter: INSUFFICIENT_LIQUIDITY");
        uint256 amountInWithFee = amountIn.mul((9970));
        uint256 numerator = amountInWithFee.mul(reserveOut);
        uint256 denominator = reserveIn.mul(10000).add(amountInWithFee);
        amountOut = numerator / denominator;
    }

    function _getAmountIn(
        uint256 amountOut,
        uint256 reserveIn,
        uint256 reserveOut
    ) internal pure returns (uint256 amountIn) {

        require(amountOut > 0, "FloozRouter: INSUFFICIENT_OUTPUT_AMOUNT");
        require(reserveIn > 0 && reserveOut > 0, "FloozRouter: INSUFFICIENT_LIQUIDITY");
        uint256 numerator = reserveIn.mul(amountOut).mul(10000);
        uint256 denominator = reserveOut.sub(amountOut).mul(9970);
        amountIn = (numerator / denominator).add(1);
    }

    function _getAmountsOut(
        address fork,
        uint256 amountIn,
        address[] memory path
    ) internal view returns (uint256[] memory amounts) {

        require(path.length >= 2, "FloozRouter: INVALID_PATH");
        amounts = new uint256[](path.length);
        amounts[0] = amountIn;
        for (uint256 i; i < path.length - 1; i++) {
            (uint256 reserveIn, uint256 reserveOut) = _getReserves(fork, path[i], path[i + 1]);
            amounts[i + 1] = _getAmountOut(amounts[i], reserveIn, reserveOut);
        }
    }

    function _getAmountsIn(
        address factory,
        uint256 amountOut,
        address[] memory path
    ) internal view returns (uint256[] memory amounts) {

        require(path.length >= 2, "FloozRouter: INVALID_PATH");
        amounts = new uint256[](path.length);
        amounts[amounts.length - 1] = amountOut;
        for (uint256 i = path.length - 1; i > 0; i--) {
            (uint256 reserveIn, uint256 reserveOut) = _getReserves(factory, path[i - 1], path[i]);
            amounts[i - 1] = _getAmountIn(amounts[i], reserveIn, reserveOut);
        }
    }

    function _getReserves(
        address factory,
        address tokenA,
        address tokenB
    ) internal view returns (uint256 reserveA, uint256 reserveB) {

        (address token0, ) = PancakeLibrary.sortTokens(tokenA, tokenB);
        (uint256 reserve0, uint256 reserve1, ) = IPancakePair(_pairFor(factory, tokenA, tokenB)).getReserves();
        (reserveA, reserveB) = tokenA == token0 ? (reserve0, reserve1) : (reserve1, reserve0);
    }

    function _pairFor(
        address factory,
        address tokenA,
        address tokenB
    ) internal view returns (address pair) {

        (address token0, address token1) = PancakeLibrary.sortTokens(tokenA, tokenB);
        pair = address(
            uint256(
                keccak256(
                    abi.encodePacked(
                        hex"ff",
                        factory,
                        keccak256(abi.encodePacked(token0, token1)),
                        forkInitCode[factory] // init code hash
                    )
                )
            )
        );
    }

    function pause() external onlyOwner {

        _pause();
    }

    function unpause() external onlyOwner {

        _unpause();
    }

    receive() external payable {}

    modifier isValidFork(address factory) {

        require(forkActivated[factory], "FloozRouter: INVALID_FACTORY");
        _;
    }

    modifier isValidReferee(address referee) {

        require(msg.sender != referee, "FloozRouter: SELF_REFERRAL");
        _;
    }
}pragma solidity =0.6.6;


contract FeeReceiverMultichain is Ownable {

    address public WETH;

    constructor(address _WETH) public {
        WETH = _WETH;
    }

    function unwrapWETH() public {

        uint256 balance = IWETH(WETH).balanceOf(address(this));
        require(balance > 0, "FeeReceiver: Nothing to unwrap");
        IWETH(WETH).withdraw(balance);
    }

    function withdrawETH(address payable to, uint256 amount) external onlyOwner {

        to.transfer(amount);
    }

    function withdrawERC20Token(
        address token,
        address to,
        uint256 amount
    ) external onlyOwner {

        IERC20(token).transfer(to, amount);
    }

    receive() external payable {}
}pragma solidity =0.6.6;


contract ReferralRegistry is Ownable {

    event ReferralAnchorCreated(address indexed user, address indexed referee);
    event ReferralAnchorUpdated(address indexed user, address indexed referee);
    event AnchorManagerUpdated(address account, bool isManager);

    mapping(address => bool) public isAnchorManager;

    mapping(address => address) public referralAnchor;

    function createReferralAnchor(address _user, address _referee) external onlyAnchorManager {

        require(referralAnchor[_user] == address(0), "ReferralRegistry: ANCHOR_EXISTS");
        referralAnchor[_user] = _referee;
        emit ReferralAnchorCreated(_user, _referee);
    }

    function updateReferralAnchor(address _user, address _referee) external onlyOwner {

        referralAnchor[_user] = _referee;
        emit ReferralAnchorUpdated(_user, _referee);
    }

    function updateAnchorManager(address _anchorManager, bool _isManager) external onlyOwner {

        isAnchorManager[_anchorManager] = _isManager;
        emit AnchorManagerUpdated(_anchorManager, _isManager);
    }

    function getUserReferee(address _user) external view returns (address) {

        return referralAnchor[_user];
    }

    function hasUserReferee(address _user) external view returns (bool) {

        return referralAnchor[_user] != address(0);
    }

    modifier onlyAnchorManager() {

        require(isAnchorManager[msg.sender], "ReferralRegistry: FORBIDDEN");
        _;
    }
}