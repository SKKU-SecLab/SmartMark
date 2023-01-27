


pragma solidity >=0.6.12;

interface IAggregationExecutor {

    function callBytes(bytes calldata data) external payable;  // 0xd9c45357

    function swapSingleSequence(
        bytes calldata data
    ) external;

    function finalTransactionProcessing(
        address tokenIn,
        address tokenOut,
        address to,
        bytes calldata destTokenFeeData
    ) external;

}




pragma solidity >=0.7.6;
pragma abicoder v2;

interface IERC20 {

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
    event Transfer(address indexed from, address indexed to, uint256 value);

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function decimals() external view returns (uint8);


    function totalSupply() external view returns (uint256);


    function balanceOf(address owner) external view returns (uint256);


    function allowance(address owner, address spender)
        external
        view
        returns (uint256);


    function approve(address spender, uint256 value) external returns (bool);


    function transfer(address to, uint256 value) external returns (bool);


    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);

}

library TransferHelper {

    function safeApprove(
        address token,
        address to,
        uint256 value
    ) internal {

        (bool success, bytes memory data) =
            token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            "TransferHelper: APPROVE_FAILED"
        );
    }

    function safeTransfer(
        address token,
        address to,
        uint256 value
    ) internal {

        (bool success, bytes memory data) =
            token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            "TransferHelper: TRANSFER_FAILED"
        );
    }

    function safeTransferFrom(
        address token,
        address from,
        address to,
        uint256 value
    ) internal {

        (bool success, bytes memory data) =
            token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            "TransferHelper: TRANSFER_FROM_FAILED"
        );
    }

    function safeTransferETH(address to, uint256 value) internal {

        (bool success, ) = to.call{value: value}(new bytes(0));
        require(success, "TransferHelper: ETH_TRANSFER_FAILED");
    }
}

library SafeMath {

    function add(uint256 x, uint256 y) internal pure returns (uint256 z) {

        require((z = x + y) >= x, "ds-math-add-overflow");
    }

    function sub(uint256 x, uint256 y) internal pure returns (uint256 z) {

        require((z = x - y) <= x, "ds-math-sub-underflow");
    }

    function mul(uint256 x, uint256 y) internal pure returns (uint256 z) {

        require(y == 0 || (z = x * y) / y == x, "ds-math-mul-overflow");
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256 c) {

        require(b > 0, "ds-math-division-by-zero");
        c = a / b;
    }
}

interface IERC20Permit {

    function permit(
        address owner,
        address spender,
        uint256 amount,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

}

library RevertReasonParser {

    function parse(bytes memory data, string memory prefix)
        internal
        pure
        returns (string memory)
    {


        if (
            data.length >= 68 &&
            data[0] == "\x08" &&
            data[1] == "\xc3" &&
            data[2] == "\x79" &&
            data[3] == "\xa0"
        ) {
            string memory reason;
            assembly {
                reason := add(data, 68)
            }
            require(
                data.length >= 68 + bytes(reason).length,
                "Invalid revert reason"
            );
            return string(abi.encodePacked(prefix, "Error(", reason, ")"));
        }
        else if (
            data.length == 36 &&
            data[0] == "\x4e" &&
            data[1] == "\x48" &&
            data[2] == "\x7b" &&
            data[3] == "\x71"
        ) {
            uint256 code;
            assembly {
                code := mload(add(data, 36))
            }
            return
                string(abi.encodePacked(prefix, "Panic(", _toHex(code), ")"));
        }

        return string(abi.encodePacked(prefix, "Unknown(", _toHex(data), ")"));
    }

    function _toHex(uint256 value) private pure returns (string memory) {

        return _toHex(abi.encodePacked(value));
    }

    function _toHex(bytes memory data) private pure returns (string memory) {

        bytes16 alphabet = 0x30313233343536373839616263646566;
        bytes memory str = new bytes(2 + data.length * 2);
        str[0] = "0";
        str[1] = "x";
        for (uint256 i = 0; i < data.length; i++) {
            str[2 * i + 2] = alphabet[uint8(data[i] >> 4)];
            str[2 * i + 3] = alphabet[uint8(data[i] & 0x0f)];
        }
        return string(str);
    }
}

contract Permitable {

    event Error(string reason);

    function _permit(
        IERC20 token,
        uint256 amount,
        bytes calldata permit
    ) internal {

        if (permit.length == 32 * 7) {
            (bool success, bytes memory result) =
                address(token).call(
                    abi.encodePacked(IERC20Permit.permit.selector, permit)
                );
            if (!success) {
                string memory reason =
                    RevertReasonParser.parse(result, "Permit call failed: ");
                if (token.allowance(msg.sender, address(this)) < amount) {
                    revert(reason);
                } else {
                    emit Error(reason);
                }
            }
        }
    }
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() internal {
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
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}


contract AggregationRouter is Permitable, Ownable {

    using SafeMath for uint256;
    address public immutable WETH;
    address private constant ETH_ADDRESS =
        address(0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE);

    uint256 private constant _PARTIAL_FILL = 0x01;
    uint256 private constant _REQUIRES_EXTRA_ETH = 0x02;
    uint256 private constant _SHOULD_CLAIM = 0x04;
    uint256 private constant _BURN_FROM_MSG_SENDER = 0x08;
    uint256 private constant _BURN_FROM_TX_ORIGIN = 0x10;
    uint256 private constant _SIMPLE_SWAP = 0x20;

    struct SwapDescription {
        IERC20 srcToken;
        IERC20 dstToken;
        address[] srcReceivers;
        uint[] srcAmounts;
        address dstReceiver;
        uint256 amount;
        uint256 minReturnAmount;
        uint256 flags;
        bytes permit;
    }

    struct SimpleSwapData {
        address[] firstPools;
        uint256[] firstSwapAmounts;
        bytes[] swapDatas;
        uint256 deadline;
        bytes destTokenFeeData;
    }

    event Swapped(
        address sender,
        IERC20 srcToken,
        IERC20 dstToken,
        address dstReceiver,
        uint256 spentAmount,
        uint256 returnAmount
    );

    event ClientData(
        bytes clientData
    );

    event Exchange(address pair, uint256 amountOut, address output);

    constructor(address _WETH) public {
        WETH = _WETH;
    }

    receive() external payable {
        assert(msg.sender == WETH);
    }

    function rescueFunds(address token, uint256 amount) external onlyOwner {

        if (_isETH(IERC20(token))) {
            TransferHelper.safeTransferETH(msg.sender, amount);
        } else {
            TransferHelper.safeTransfer(token, msg.sender, amount);
        }
    }

    function swap(
        IAggregationExecutor caller,
        SwapDescription calldata desc,
        bytes calldata executorData,
        bytes calldata clientData
    ) external payable returns (uint256 returnAmount) {

        require(desc.minReturnAmount > 0, "Min return should not be 0");
        require(executorData.length > 0, "executorData should be not zero");

        uint256 flags = desc.flags;

        if (flags & _SIMPLE_SWAP != 0) return swapSimpleMode(caller, desc, executorData, clientData);

        IERC20 srcToken = desc.srcToken;
        IERC20 dstToken = desc.dstToken;

        if (flags & _REQUIRES_EXTRA_ETH != 0) {
            require(
                msg.value > (_isETH(srcToken) ? desc.amount : 0),
                "Invalid msg.value"
            );
        } else {
            require(
                msg.value == (_isETH(srcToken) ? desc.amount : 0),
                "Invalid msg.value"
            );
        }

        require(
            desc.srcReceivers.length == desc.srcAmounts.length,
            "Invalid lengths for receiving src tokens"
        );

        if (flags & _SHOULD_CLAIM != 0) {
            require(!_isETH(srcToken), "Claim token is ETH");
            _permit(srcToken, desc.amount, desc.permit);
            for (uint i = 0; i < desc.srcReceivers.length; i++) {
                TransferHelper.safeTransferFrom(
                    address(srcToken),
                    msg.sender,
                    desc.srcReceivers[i],
                    desc.srcAmounts[i]
                );
            }
        }

        if (_isETH(srcToken)) {
            for (uint i = 0; i < desc.srcReceivers.length; i++) {
                TransferHelper.safeTransferETH(
                    desc.srcReceivers[i],
                    desc.srcAmounts[i]
                );
            }
        }

        address dstReceiver =
            (desc.dstReceiver == address(0)) ? msg.sender : desc.dstReceiver;
        uint256 initialSrcBalance =
            (flags & _PARTIAL_FILL != 0) ? _getBalance(srcToken, msg.sender) : 0;
        uint256 initialDstBalance = _getBalance(dstToken, dstReceiver);

        _callWithEth(caller, executorData);

        uint256 spentAmount = desc.amount;
        returnAmount = _getBalance(dstToken, dstReceiver).sub(initialDstBalance);

        if (flags & _PARTIAL_FILL != 0) {
            spentAmount = initialSrcBalance.add(desc.amount).sub(
                _getBalance(srcToken, msg.sender)
            );
            require(
                returnAmount.mul(desc.amount) >=
                    desc.minReturnAmount.mul(spentAmount),
                "Return amount is not enough"
            );
        } else {
            require(
                returnAmount >= desc.minReturnAmount,
                "Return amount is not enough"
            );
        }

        emit Swapped(
            msg.sender,
            srcToken,
            dstToken,
            dstReceiver,
            spentAmount,
            returnAmount
        );
        emit Exchange(
            address(caller),
            returnAmount,
            _isETH(dstToken) ? WETH : address(dstToken)
        );
        emit ClientData(
            clientData
        );
    }

    function swapSimpleMode(
        IAggregationExecutor caller,
        SwapDescription calldata desc,
        bytes calldata executorData,
        bytes calldata clientData
    ) public returns (uint256 returnAmount) {

        IERC20 srcToken = desc.srcToken;
        IERC20 dstToken = desc.dstToken;
        require(!_isETH(srcToken), "src is eth, should use normal swap");

        _permit(srcToken, desc.amount, desc.permit);

        uint256 totalSwapAmount = desc.amount;
        if (desc.srcReceivers.length > 0) {
            require(
                desc.srcReceivers.length == 1 &&
                desc.srcReceivers.length == desc.srcAmounts.length,
                "Wrong number of src receivers"
            );
            TransferHelper.safeTransferFrom(
                address(srcToken),
                msg.sender,
                desc.srcReceivers[0],
                desc.srcAmounts[0]
            );
            require(desc.srcAmounts[0] <= totalSwapAmount, "invalid fee amount in src token");
            totalSwapAmount -= desc.srcAmounts[0];
        }

        address dstReceiver =
            (desc.dstReceiver == address(0)) ? msg.sender : desc.dstReceiver;
        uint256 initialDstBalance = _getBalance(dstToken, dstReceiver);

        _swapMultiSequencesWithSimpleMode(
            caller,
            address(srcToken),
            totalSwapAmount,
            address(dstToken),
            dstReceiver,
            executorData
        );

        returnAmount = _getBalance(dstToken, dstReceiver).sub(initialDstBalance);

        require(
            returnAmount >= desc.minReturnAmount,
            "Return amount is not enough"
        );

        emit Swapped(
            msg.sender,
            srcToken,
            dstToken,
            dstReceiver,
            desc.amount,
            returnAmount
        );
        emit Exchange(
            address(caller),
            returnAmount,
            _isETH(dstToken) ? WETH : address(dstToken)
        );
        emit ClientData(
            clientData
        );
    }

    function _swapMultiSequencesWithSimpleMode(
        IAggregationExecutor caller,
        address tokenIn,
        uint256 totalSwapAmount,
        address tokenOut,
        address dstReceiver,
        bytes calldata executorData
    ) internal {

        SimpleSwapData memory swapData = abi.decode(executorData, (SimpleSwapData));
        require(swapData.deadline >= block.timestamp, "ROUTER: Expired");
        require(
            swapData.firstPools.length == swapData.firstSwapAmounts.length
            && swapData.firstPools.length == swapData.swapDatas.length,
            "invalid swap data length"
        );
        uint256 numberSeq = swapData.firstPools.length;
        for (uint256 i = 0; i < numberSeq; i++) {
            TransferHelper.safeTransferFrom(
                tokenIn,
                msg.sender,
                swapData.firstPools[i],
                swapData.firstSwapAmounts[i]
            );
            require(swapData.firstSwapAmounts[i] <= totalSwapAmount, "invalid swap amount");
            totalSwapAmount -= swapData.firstSwapAmounts[i];
            {
                (bool success, bytes memory result) =
                    address(caller).call(
                        abi.encodeWithSelector(
                            caller.swapSingleSequence.selector,
                            swapData.swapDatas[i]
                        )
                    );
                if (!success) {
                    revert(RevertReasonParser.parse(result, "swapSingleSequence failed: "));
                }
            }
        }
        {
            (bool success, bytes memory result) =
                address(caller).call(
                    abi.encodeWithSelector(
                        caller.finalTransactionProcessing.selector,
                        tokenIn,
                        tokenOut,
                        dstReceiver,
                        swapData.destTokenFeeData
                    )
                );
            if (!success) {
                revert(RevertReasonParser.parse(result, "finalTransactionProcessing failed: "));
            }
        }
    }

    function _getBalance(IERC20 token, address account)
        internal
        view
        returns (uint256)
    {

        if (_isETH(token)) {
            return account.balance;
        } else {
            return token.balanceOf(account);
        }
    }

    function _isETH(IERC20 token) internal pure returns (bool) {

        return (address(token) == ETH_ADDRESS);
    }

    function _callWithEth(IAggregationExecutor caller, bytes calldata executorData) internal {

        uint256 ethAmount = _getBalance(IERC20(ETH_ADDRESS), address(this));
        if (ethAmount > msg.value) ethAmount = msg.value;
        (bool success, bytes memory result) =
            address(caller).call{value: ethAmount}(
                abi.encodeWithSelector(caller.callBytes.selector, executorData)
            );
        if (!success) {
            revert(RevertReasonParser.parse(result, "callBytes failed: "));
        }
    }
}