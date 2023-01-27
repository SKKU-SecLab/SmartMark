


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

abstract contract Ownable is Context {
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
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
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



pragma solidity 0.6.12;


interface IUniswapV2Pair {

    function getReserves() external view returns (uint112 r0, uint112 r1, uint32 blockTimestampLast);

    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;

}

interface IUniswapV2Factory {

    function getPair(address a, address b) external view returns (address p);

}

interface IUniswapV2Router02 {

    function WETH() external returns (address);


    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;

}

library UniswapV2Library {

    using SafeMath for uint;

    function sortTokens(address tokenA, address tokenB) internal pure returns (address token0, address token1) {

        require(tokenA != tokenB, 'UV2: IDENTICAL_ADDRESSES');
        (token0, token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        require(token0 != address(0), 'UV2: ZERO_ADDRESS');
    }
    
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) internal pure returns (uint amountOut) {

        require(amountIn > 0, 'UV2: INSUFFICIENT_INPUT_AMOUNT');
        require(reserveIn > 0 && reserveOut > 0, 'UV2: INSUFFICIENT_LIQUIDITY');
        uint amountInWithFee = amountIn.mul(997);
        uint numerator = amountInWithFee.mul(reserveOut);
        uint denominator = reserveIn.mul(1000).add(amountInWithFee);
        amountOut = numerator / denominator;
    }
}



pragma solidity 0.6.12;

interface IUniMexFactory {

  function getPool(address) external returns(address);

  function getMaxLeverage(address) external returns(uint256);

  function allowedMargins(address) external returns (bool);

  function utilizationScaled(address token) external pure returns(uint256);

}



pragma solidity 0.6.12;






interface IUniMexStaking {

    function distribute(uint256 _amount) external;

}

interface IUniMexPool {

    function borrow(uint256 _amount) external;

    function distribute(uint256 _amount) external;

    function repay(uint256 _amount) external returns (bool);

}

contract UniMexMargin is Ownable {

    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    
    address private WETH_ADDRESS;
    IERC20 public WETH;
    uint256 public constant MAG = 1e18;
    uint256 public constant LIQUIDATION_MARGIN = 11*1e17; //10%
    uint256 public liquidationBonus = 9 * 1e16;
    uint256 public borrowInterestPercentScaled = 100; //10%
    uint256 public constant YEAR = 31536000;
    uint256 public positionNonce = 0;
    
    struct Position {
        bytes32 id;
        address token;
        address owner;
        uint256 owed;
        uint256 input;
        uint256 commitment;
        uint256 leverage;
        uint256 startTimestamp;
        bool isClosed;
        bool isShort;
        uint256 borrowInterest;
    }
    
    mapping(bytes32 => Position) public positionInfo;
    mapping(address => uint256) public balanceOf;
    mapping(address => uint256) public escrow;
    
    uint256 public delay;

    IUniMexStaking public staking;
    IUniMexFactory public unimex_factory;
    IUniswapV2Factory public uniswap_factory;
    IUniswapV2Router02 public uniswap_router;
    
    event OnOpenPosition(
        address indexed sender,
        bytes32 positionId,
        bool isShort,
        address indexed token
    );
    
    event OnClosePosition(
        address indexed sender,
        bytes32 positionId,
        bool isShort,
        address indexed token
    );
    
    modifier isHuman() {

        require(msg.sender == tx.origin);
        _;
    }

    constructor(
        address _staking,
        address _factory,
        address _weth,
        address _uniswap_factory,
        address _uniswap_router
    ) public {
        staking = IUniMexStaking(_staking);
        unimex_factory = IUniMexFactory(_factory);
        WETH_ADDRESS = _weth;
        WETH = IERC20(_weth);
        uniswap_factory = IUniswapV2Factory(_uniswap_factory);
        uniswap_router = IUniswapV2Router02(_uniswap_router);
    }

    function setDelay(uint256 _delay) external onlyOwner {

        delay = _delay;
    }

    function setStaking(address _staking) external onlyOwner {

        require(_staking != address(0));
        staking = IUniMexStaking(_staking);
    }

    function setLiquidationBonus(uint256 _liquidationBonus) external onlyOwner {

        require(_liquidationBonus > 0, "ZERO_LIQUIDATION_BONUS");
        liquidationBonus = _liquidationBonus;
    }

    function setBorrowPercent(uint256 _newPercentScaled) external onlyOwner {

        borrowInterestPercentScaled = _newPercentScaled;
    }

    function deposit(uint256 _amount) public {

        WETH.safeTransferFrom(msg.sender, address(this), _amount);
        balanceOf[msg.sender] = balanceOf[msg.sender].add(_amount);
    }

    function withdraw(uint256 _amount) public {

        require(balanceOf[msg.sender] >= _amount);
        balanceOf[msg.sender] = balanceOf[msg.sender].sub(_amount);
        WETH.safeTransfer(msg.sender, _amount);
    }

    function transferUserToEscrow(address from, address to, uint256 amount) private {

        require(balanceOf[from] >= amount);
        balanceOf[from] = balanceOf[from].sub(amount);
        escrow[to] = escrow[to].add(amount);
    }

    function transferEscrowToUser(address from, address to, uint256 amount) private {

        require(escrow[from] >= amount);
        escrow[from] = escrow[from].sub(amount);
        balanceOf[to] = balanceOf[to].add(amount);
    }

    function transferToUser(address to, uint256 amount) private {

        balanceOf[to] = balanceOf[to].add(amount);
    }

    function getPositionId(
        address maker,
        address token,
        uint256 amount,
        uint256 leverage,
        uint256 nonce
    ) private pure returns (bytes32 positionId) {

        positionId = keccak256(
            abi.encodePacked(maker, token, amount, leverage, nonce)
        );
    }

    function calculateConvertedValue(address baseToken, address quoteToken, uint256 amount) private view returns (uint256) {

        address token0;
        address token1;
        (token0, token1) = UniswapV2Library.sortTokens(baseToken, quoteToken);
        IUniswapV2Pair pair = IUniswapV2Pair(uniswap_factory.getPair(token0, token1));
        (uint256 reserve0, uint256 reserve1, ) = pair.getReserves();
        uint256 value;
        if (token1 == baseToken) {
            value = UniswapV2Library.getAmountOut(amount, reserve1, reserve0);
        } else {
            value = UniswapV2Library.getAmountOut(amount, reserve0, reserve1);
        }
        return value;
    }

    function swapTokens(address baseToken, address quoteToken, uint256 input, uint256 slippage) private returns (uint256 swap) {

        IERC20(baseToken).approve(address(uniswap_router), input);
        address[] memory path = new address[](2);
        path[0] = baseToken;
        path[1] = quoteToken;
        uint256 deadline = block.timestamp.add(delay);
        uint256 output = calculateConvertedValue(baseToken, quoteToken, input);
        uint256 outputWithSlippage = (output.sub(((output.mul(slippage)).div(MAG))));
        uint256 balanceBefore = IERC20(quoteToken).balanceOf(address(this));

        IUniswapV2Router02(uniswap_router)
            .swapExactTokensForTokensSupportingFeeOnTransferTokens(
                input,
                outputWithSlippage,
                path,
                address(this),
                deadline
            );
            
        uint256 balanceAfter = IERC20(quoteToken).balanceOf(address(this));
        swap = balanceAfter.sub(balanceBefore);

        require(swap > 0, "FAILED_SWAP");
    }

    function getCommitment(uint256 _amount, uint scaledLeverage) private pure returns (uint256 commitment) {

        commitment = (_amount.mul(MAG)).div(scaledLeverage);
    }

    function transferFees(uint256 fees, address pool) private {

        uint256 halfFees = fees.div(2);

        WETH.approve(pool, halfFees);	
        IUniMexPool(pool).distribute(halfFees);	

        WETH.approve(address(staking), fees.sub(halfFees));
        staking.distribute(fees.sub(halfFees));
    }

    function transferToPool(address pool, address token, uint256 amount) private {

        IERC20(token).approve(pool, amount);
        IUniMexPool(pool).repay(amount);
    }

    function calculateBorrowInterest(bytes32 positionId) public view returns (uint256) {

        Position storage position = positionInfo[positionId];
        uint256 loanTime = block.timestamp.sub(position.startTimestamp);
        return position.owed.mul(loanTime).mul(position.borrowInterest).div(1000).div(YEAR);
    }

    function _openPosition(address token, uint256 amount, uint256 scaledLeverage, uint256 scaledSlippage, bool isShort) private {

        require(amount > 0, "AMOUNT_ZERO");
        address pool = unimex_factory.getPool(address(isShort ? IERC20(token) : WETH));

        require(pool != address(0), "POOL_DOES_NOT_EXIST");
        require(scaledLeverage <= unimex_factory.getMaxLeverage(token).mul(MAG), "LEVERAGE_EXCEEDS_MAX");
        require(scaledLeverage >= MAG, "LEVERAGE_BELOW_1");

        uint amountInWeth = isShort ? calculateConvertedValue(token, WETH_ADDRESS, amount) : amount;
        uint256 commitment = getCommitment(amountInWeth, scaledLeverage);
        require(balanceOf[msg.sender] >= commitment, "NO_BALANCE");
        
        IUniMexPool(pool).borrow(amount);

        uint256 swap;
        
        {
            (address baseToken, address quoteToken) = isShort ? (token, WETH_ADDRESS) : (WETH_ADDRESS, token);
            swap = swapTokens(baseToken, quoteToken, amount, scaledSlippage);
        }

        uint256 fees = (swap.mul(8)).div(1000);	

        swap = swap.sub(fees); // swap minus fees

        if(!isShort) {
            fees = swapTokens(token, WETH_ADDRESS, fees, scaledSlippage); // convert fees to ETH
        }

        transferFees(fees, pool);

        transferUserToEscrow(msg.sender, msg.sender, commitment.add(liquidationBonus));

        positionNonce = positionNonce + 1; //possible overflow is ok
        bytes32 positionId = getPositionId(
            msg.sender,
            token,
            amount,
            scaledLeverage,
            positionNonce
        );

        Position memory position = Position({
            owed: amount,
            input: swap,
            commitment: commitment,	
            owner: msg.sender,	
            startTimestamp: block.timestamp,
            isShort: isShort,
            isClosed: false,	
            leverage: scaledLeverage,
            token: token,
            id: positionId,
            borrowInterest: borrowInterestPercentScaled
        });
        
        positionInfo[position.id] = position;

        emit OnOpenPosition(msg.sender, position.id, isShort, token);
    }

    function openShortPosition(address token, uint256 amount, uint256 leverage, uint256 slippage) public isHuman {

        _openPosition(token, amount, leverage, slippage, true);
    }

    function openLongPosition(address token, uint256 amount, uint256 leverage, uint256 slippage) public isHuman {

        _openPosition(token, amount, leverage, slippage, false);
    }

    function _closeShort(Position storage position, uint256 slippage) private {


        uint256 input = position.input;
        uint256 owed = position.owed;
        uint256 commitment = position.commitment;

        address pool = unimex_factory.getPool(position.token);

        uint256 poolInterestInTokens = calculateBorrowInterest(position.id);
        uint256 swap = swapTokens(WETH_ADDRESS, position.token, input, slippage);
        require(swap >= owed.add(poolInterestInTokens).mul(input).div(input.add(commitment)), "LIQUIDATE_ONLY");

        bool isProfit = owed < swap;
        uint256 amount;

        if(isProfit) {
            uint256 profitInTokens = swap.sub(owed);
            amount = swapTokens(position.token, WETH_ADDRESS, profitInTokens, slippage); //profit in eth
        } else {
            uint256 commitmentInTokens = swapTokens(WETH_ADDRESS, position.token, commitment, slippage);
            amount = swapTokens(position.token, WETH_ADDRESS, commitmentInTokens.sub(owed.sub(swap)), slippage); //return to user's balance
        }

        uint256 poolInterestInWeth = poolInterestInTokens > 0 ? calculateConvertedValue(position.token, address(WETH), poolInterestInTokens) : 0;

        uint256 fees = amount.mul(8e15)
                             .div(1e18)
                             .add(poolInterestInWeth);

        transferToPool(pool, position.token, owed);

        transferFees(fees, pool);

        transferEscrowToUser(position.owner, isProfit ? position.owner : address(0x0), commitment);
        transferEscrowToUser(position.owner, position.owner, liquidationBonus);
        transferToUser(position.owner, amount.sub(fees));
        
        position.isClosed = true;
        emit OnClosePosition(msg.sender, position.id, true, position.token);
    }

    function _closeLong(Position storage position, uint256 slippage) private {

        uint256 input = position.input;
        uint256 owed = position.owed;
        address pool = unimex_factory.getPool(WETH_ADDRESS);

        uint256 poolInterestValue = calculateBorrowInterest(position.id);
        uint256 swap = swapTokens(position.token, WETH_ADDRESS, input, slippage);
        require(swap >= owed.sub(position.commitment).add(poolInterestValue), "LIQUIDATE_ONLY");

        uint256 commitment = position.commitment;

        bool isProfit = swap >= owed;

        uint256 amount = isProfit ? swap.sub(owed) : commitment.sub(owed.sub(swap));

        uint256 fees = amount.mul(8e15)
                             .div(1e18)
                             .add(poolInterestValue);

        transferToPool(pool, WETH_ADDRESS, owed);

        transferFees(fees, pool);

        transferEscrowToUser(position.owner, isProfit ? position.owner : address(0x0), commitment);
        transferEscrowToUser(position.owner, position.owner, liquidationBonus);

        transferToUser(position.owner, amount.sub(fees));

        position.isClosed = true;
        emit OnClosePosition(msg.sender, position.id, false, position.token);
    }

    function closePosition(bytes32 positionId, uint256 slippage) external isHuman {

        Position storage position = positionInfo[positionId];
        require(position.isClosed == false, "CLOSED_POSITION");
        require(msg.sender == position.owner, "BORROWER_ONLY");
        if(position.isShort) {
            _closeShort(position, slippage);
        }else{
            _closeLong(position, slippage);
        }
    }

    function canLiquidate(bytes32 positionId) public view returns(bool) {

        Position storage position = positionInfo[positionId];
        if(position.isShort) {
            uint256 value = calculateConvertedValue(WETH_ADDRESS, position.token, position.input);
            uint256 poolInterestInTokens = calculateBorrowInterest(position.id);

            return value < position.owed.add(poolInterestInTokens)
                                        .mul(position.input)
                                        .div(position.input.add(position.commitment))
                                        .mul(LIQUIDATION_MARGIN)
                                        .div(MAG);
        } else {
            uint256 value = calculateConvertedValue(position.token, WETH_ADDRESS, position.input);
            uint256 poolInterestValue = calculateBorrowInterest(position.id);
            return value.add(position.commitment) < position.owed.add(poolInterestValue)
                                                                 .mul(LIQUIDATION_MARGIN)
                                                                 .div(MAG);
        }

    }

    function liquidatePosition(bytes32 positionId, uint256 slippage) external isHuman {

        Position storage position = positionInfo[positionId];
        require(position.isClosed == false, "CLOSED_POSITION");
        bool isShort = position.isShort;
        (address baseToken, address quoteToken) = isShort ? (position.token, WETH_ADDRESS) : (WETH_ADDRESS, position.token);

        uint256 input = position.input;

        require(canLiquidate(positionId), "CANNOT_LIQUIDATE");

        uint256 swap = swapTokens(quoteToken, baseToken, input, slippage);

        uint256 commitment = isShort ? swapTokens(WETH_ADDRESS, position.token, position.commitment, slippage) : position.commitment;

        uint256 fees = calculateBorrowInterest(position.id)
                            .add(position.owed.mul(8e15).div(1e18));
        uint256 canReturn = swap.add(commitment);
        liquidate(position, canReturn, fees, slippage);
        transferEscrowToUser(position.owner, address(0x0), position.commitment.add(liquidationBonus));

        position.isClosed = true;
        
        emit OnClosePosition(msg.sender, position.id, isShort, position.token);
        WETH.safeTransfer(msg.sender, liquidationBonus);
    }

    function liquidate(Position memory position, uint256 canReturn, uint fees, uint slippage) private {

        address baseToken = position.isShort ? position.token : WETH_ADDRESS;
        address pool = unimex_factory.getPool(baseToken);
        if(canReturn > position.owed) {
            transferToPool(pool, baseToken, position.owed);
            uint256 remainder = canReturn.sub(position.owed);
            if(remainder > fees) { //can pay fees completely
                uint256 userReturnAmount = remainder.sub(fees);
                if(position.isShort) {
                    fees = swapTokens(position.token, WETH_ADDRESS, fees, slippage); //convert fees to weth
                }
                transferFees(fees, pool);
                if(position.isShort) {
                    userReturnAmount = swapTokens(position.token, WETH_ADDRESS, remainder.sub(fees), slippage);
                }
                transferToUser(position.owner, userReturnAmount);
            } else { //all is left is for fees
                if(position.isShort) {
                    remainder = swapTokens(position.token, WETH_ADDRESS, 
                        canReturn.sub(position.owed), slippage);
                }
                transferFees(remainder, pool);
            }
        } else {
            transferToPool(pool, baseToken, canReturn);
        }
    }


}