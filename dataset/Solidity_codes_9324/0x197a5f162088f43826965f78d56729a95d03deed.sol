



pragma solidity 0.5.12;
pragma experimental ABIEncoderV2;


library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b != 0, errorMessage);
        return a % b;
    }
}

contract Context {

    constructor () internal {}

    function _msgSender() internal view returns (address _payable) {

        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {

        this;
        return msg.data;
    }
}

contract Ownable is Context {

    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {

        return _owner;
    }

    modifier onlyOwner() {

        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    function isOwner() public view returns (bool) {

        return _msgSender() == _owner;
    }

    function renounceOwnership() public onlyOwner {

        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {

        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {

        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

interface PoolInterface {

    function swapExactAmountIn(address, address, address, uint, address, uint) external returns (uint, uint);


    function swapExactAmountOut(address, address, uint, address, uint, address, uint) external returns (uint, uint);


    function calcInGivenOut(uint, uint, uint, uint, uint, uint) external pure returns (uint);


    function calcOutGivenIn(uint, uint, uint, uint, uint, uint) external pure returns (uint);


    function getDenormalizedWeight(address) external view returns (uint);


    function getBalance(address) external view returns (uint);


    function getSwapFee() external view returns (uint);


    function gulp(address) external;


    function calcDesireByGivenAmount(address, address, uint256, uint256) view external returns (uint);


    function calcPoolSpotPrice(address, address, uint256, uint256) external view returns (uint256);

}

interface TokenInterface {

    function balanceOf(address) external view returns (uint);


    function allowance(address, address) external view returns (uint);


    function approve(address, uint) external returns (bool);


    function transfer(address, uint) external returns (bool);


    function transferFrom(address, address, uint) external returns (bool);


    function deposit() external payable;


    function withdraw(uint) external;

}

interface RegistryInterface {

    function getBestPoolsWithLimit(address, address, uint) external view returns (address[] memory);

}

contract ExchangeProxy is Ownable {


    using SafeMath for uint256;

    struct Pool {
        address pool;
        uint tokenBalanceIn;
        uint tokenWeightIn;
        uint tokenBalanceOut;
        uint tokenWeightOut;
        uint swapFee;
        uint effectiveLiquidity;
    }

    struct Swap {
        address pool;
        address tokenIn;
        address tokenOut;
        uint swapAmount; // tokenInAmount / tokenOutAmount
        uint limitReturnAmount; // minAmountOut / maxAmountIn
        uint maxPrice;
    }

    TokenInterface weth;
    RegistryInterface registry;
    address private constant ETH_ADDRESS = address(0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE);
    uint private constant BONE = 10 ** 18;

    constructor(address _weth) public {
        weth = TokenInterface(_weth);
    }

    function setRegistry(address _registry) external onlyOwner {

        registry = RegistryInterface(_registry);
    }

    function batchSwapExactIn(
        Swap[] memory swaps,
        TokenInterface tokenIn,
        TokenInterface tokenOut,
        uint totalAmountIn,
        uint minTotalAmountOut
    )
    public payable
    returns (uint totalAmountOut)
    {

        address from = msg.sender;
        if (isETH(tokenIn)) {
            require(msg.value >= totalAmountIn, "ERROR_ETH_IN");
            weth.deposit.value(totalAmountIn)();
            from = address(this);
        }
        uint _totalSwapIn = 0;
        for (uint i = 0; i < swaps.length; i++) {
            Swap memory swap = swaps[i];
            require(swap.tokenIn == address(tokenIn) || (swap.tokenIn == address(weth) && isETH(tokenIn)), "ERR_TOKENIN_NOT_MATCH");
            safeTransferFrom(swap.tokenIn, from, swap.pool, swap.swapAmount);
            address _to = (swap.tokenOut == address(weth) && isETH(tokenOut)) ? address(this) : msg.sender;
            PoolInterface pool = PoolInterface(swap.pool);
            (uint tokenAmountOut,) = pool.swapExactAmountIn(
                msg.sender,
                swap.tokenIn,
                swap.tokenOut,
                swap.limitReturnAmount,
                _to,
                swap.maxPrice
            );
            if (_to != msg.sender) {
                transferAll(tokenOut, tokenAmountOut);
            }
            totalAmountOut = tokenAmountOut.add(totalAmountOut);
            _totalSwapIn = _totalSwapIn.add(swap.swapAmount);
        }
        require(_totalSwapIn == totalAmountIn, "ERR_TOTAL_AMOUNT_IN");
        require(totalAmountOut >= minTotalAmountOut, "ERR_LIMIT_OUT");
        if (isETH(tokenIn) && msg.value > _totalSwapIn) {
            (bool xfer,) = msg.sender.call.value(msg.value.sub(_totalSwapIn))("");
            require(xfer, "ERR_ETH_FAILED");
        }
    }

    function batchSwapExactOut(
        Swap[] memory swaps,
        TokenInterface tokenIn,
        TokenInterface tokenOut,
        uint maxTotalAmountIn
    )
    public payable
    returns (uint totalAmountIn)
    {

        address from = msg.sender;
        if (isETH(tokenIn)) {
            weth.deposit.value(msg.value)();
            from = address(this);
        }
        for (uint i = 0; i < swaps.length; i++) {
            Swap memory swap = swaps[i];
            uint tokenAmountIn = getAmountIn(swap);
            swap.tokenIn = isETH(tokenIn) ? address(weth) : swap.tokenIn;
            safeTransferFrom(swap.tokenIn, from, swap.pool, tokenAmountIn);
            address _to = (swap.tokenOut == address(weth) && isETH(tokenOut)) ? address(this) : msg.sender;
            PoolInterface pool = PoolInterface(swap.pool);
            pool.swapExactAmountOut(
                msg.sender,
                swap.tokenIn,
                swap.limitReturnAmount,
                swap.tokenOut,
                swap.swapAmount,
                _to,
                swap.maxPrice
            );
            if (_to != msg.sender) {
                transferAll(tokenOut, swap.swapAmount);
            }
            totalAmountIn = tokenAmountIn.add(totalAmountIn);
        }
        require(totalAmountIn <= maxTotalAmountIn, "ERR_LIMIT_IN");
        if (isETH(tokenIn) && msg.value > totalAmountIn) {
            transferAll(tokenIn, msg.value.sub(totalAmountIn));
        }
    }

    function multihopBatchSwapExactIn(
        Swap[][] memory swapSequences,
        TokenInterface tokenIn,
        TokenInterface tokenOut,
        uint totalAmountIn,
        uint minTotalAmountOut
    )
    public payable
    returns (uint totalAmountOut)
    {

        uint totalSwapAmount = 0;
        address from = msg.sender;
        if (isETH(tokenIn)) {
            require(msg.value >= totalAmountIn, "ERROR_ETH_IN");
            weth.deposit.value(totalAmountIn)();
            from = address(this);
        }
        for (uint i = 0; i < swapSequences.length; i++) {
            totalSwapAmount = totalSwapAmount.add(swapSequences[i][0].swapAmount);
            require(swapSequences[i][0].tokenIn == address(tokenIn) || (isETH(tokenIn) && swapSequences[i][0].tokenIn == address(weth)), "ERR_TOKENIN_NOT_MATCH");
            safeTransferFrom(swapSequences[i][0].tokenIn, from, swapSequences[i][0].pool, swapSequences[i][0].swapAmount);

            uint tokenAmountOut;
            for (uint k = 0; k < swapSequences[i].length; k++) {
                Swap memory swap = swapSequences[i][k];
                PoolInterface pool = PoolInterface(swap.pool);
                address _to;
                if (k < swapSequences[i].length - 1) {
                    _to = swapSequences[i][k + 1].pool;
                } else {
                    require(swap.tokenOut == address(tokenOut) || (swap.tokenOut == address(weth) && isETH(tokenOut)), "ERR_OUTCOIN_NOT_MATCH");
                    _to = (swap.tokenOut == address(weth) && isETH(tokenOut)) ? address(this) : msg.sender;
                }
                (tokenAmountOut,) = pool.swapExactAmountIn(
                    msg.sender,
                    swap.tokenIn,
                    swap.tokenOut,
                    swap.limitReturnAmount,
                    _to,
                    swap.maxPrice
                );
                if (k == swapSequences[i].length - 1 && _to != msg.sender) {
                    transferAll(tokenOut, tokenAmountOut);
                }
            }
            totalAmountOut = tokenAmountOut.add(totalAmountOut);
        }
        require(totalSwapAmount == totalAmountIn, "ERR_TOTAL_AMOUNT_IN");
        require(totalAmountOut >= minTotalAmountOut, "ERR_LIMIT_OUT");
        if (isETH(tokenIn) && msg.value > totalSwapAmount) {
            (bool xfer,) = msg.sender.call.value(msg.value.sub(totalAmountIn))("");
            require(xfer, "ERR_ETH_FAILED");
        }
    }

    function multihopBatchSwapExactOut(
        Swap[][] memory swapSequences,
        TokenInterface tokenIn,
        TokenInterface tokenOut,
        uint maxTotalAmountIn
    )
    public payable
    returns (uint totalAmountIn)
    {

        address from = msg.sender;
        if (isETH(tokenIn)) {
            require(msg.value >= maxTotalAmountIn, "ERROR_ETH_IN");
            weth.deposit.value(msg.value)();
            from = address(this);
        }

        for (uint i = 0; i < swapSequences.length; i++) {
            uint[] memory amountIns = getAmountsIn(swapSequences[i]);
            swapSequences[i][0].tokenIn = isETH(tokenIn) ? address(weth) : swapSequences[i][0].tokenIn;
            safeTransferFrom(swapSequences[i][0].tokenIn, from, swapSequences[i][0].pool, amountIns[0]);

            for (uint j = 0; j < swapSequences[i].length; j++) {
                Swap memory swap = swapSequences[i][j];
                PoolInterface pool = PoolInterface(swap.pool);
                address _to;
                if (j < swapSequences[i].length - 1) {
                    _to = swapSequences[i][j + 1].pool;
                } else {
                    require(swap.tokenOut == address(tokenOut) || (swap.tokenOut == address(weth) && isETH(tokenOut)), "ERR_OUTCOIN_NOT_MATCH");
                    _to = (swap.tokenOut == address(weth) && isETH(tokenOut)) ? address(this) : msg.sender;
                }
                uint _tokenOut = j < swapSequences[i].length - 1 ? amountIns[j + 1] : swap.swapAmount;
                pool.swapExactAmountOut(
                    msg.sender,
                    swap.tokenIn,
                    amountIns[j],
                    swap.tokenOut,
                    _tokenOut,
                    _to,
                    swap.maxPrice
                );
                if (j == swapSequences[i].length - 1 && _to != msg.sender) {
                    transferAll(tokenOut, _tokenOut);
                }
            }
            totalAmountIn = totalAmountIn.add(amountIns[0]);
        }
        require(totalAmountIn <= maxTotalAmountIn, "ERR_LIMIT_IN");
        if (isETH(tokenIn) && msg.value > totalAmountIn) {
            transferAll(tokenIn, msg.value.sub(totalAmountIn));
        }
    }

    function getBalance(TokenInterface token) internal view returns (uint) {

        if (isETH(token)) {
            return weth.balanceOf(address(this));
        } else {
            return token.balanceOf(address(this));
        }
    }

    function transferAll(TokenInterface token, uint amount) internal{

        if (amount == 0) {
            return;
        }

        if (isETH(token)) {
            weth.withdraw(amount);
            (bool xfer,) = msg.sender.call.value(amount)("");
            require(xfer, "ERR_ETH_FAILED");
        } else {
            safeTransfer(address(token), msg.sender, amount);
        }
    }

    function isETH(TokenInterface token) internal pure returns (bool) {

        return (address(token) == ETH_ADDRESS);
    }

    function safeApprove(
        address token,
        address to,
        uint256 value
    ) internal {

        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            'TransferHelper::safeApprove: approve failed'
        );
    }

    function safeTransfer(
        address token,
        address to,
        uint256 value
    ) internal {

        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            'TransferHelper::safeTransfer: transfer failed'
        );
    }

    function safeTransferFrom(
        address token,
        address from,
        address to,
        uint256 value
    ) internal {

        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            'TransferHelper::transferFrom: transferFrom failed'
        );
    }

    function getAmountIn(Swap memory swap) internal view returns (uint amountIn) {

        require(swap.swapAmount > 0, 'ExchangeProxy: INSUFFICIENT_OUTPUT_AMOUNT');
        PoolInterface pool = PoolInterface(swap.pool);
        amountIn = pool.calcDesireByGivenAmount(
            swap.tokenIn,
            swap.tokenOut,
            0,
            swap.swapAmount
        );
        uint256 spotPrice = pool.calcPoolSpotPrice(
            swap.tokenIn,
            swap.tokenOut,
            0,
            0
        );
        require(spotPrice <= swap.maxPrice, "ERR_LIMIT_PRICE");
    }

    function getAmountsIn(Swap[] memory swaps) internal view returns (uint[] memory amounts) {

        require(swaps.length >= 1, 'ExchangeProxy: INVALID_PATH');
        amounts = new uint[](swaps.length);
        uint i = swaps.length - 1;
        while (i > 0) {
            Swap memory swap = swaps[i];
            amounts[i] = getAmountIn(swap);
            require(swaps[i].tokenIn == swaps[i - 1].tokenOut, "ExchangeProxy: INVALID_PATH");
            swaps[i - 1].swapAmount = amounts[i];
            i--;
        }
        amounts[0] = getAmountIn(swaps[0]);
    }

    function() external payable {}

}