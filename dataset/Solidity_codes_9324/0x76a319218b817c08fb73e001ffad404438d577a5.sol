


pragma solidity ^0.6.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}



pragma solidity ^0.6.0;

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



pragma solidity ^0.6.0;

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



pragma solidity ^0.6.2;

library Address {

    function isContract(address account) internal view returns (bool) {

        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
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

        return _functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {

        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {

        require(address(this).balance >= value, "Address: insufficient balance for call");
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(address target, bytes memory data, uint256 weiValue, string memory errorMessage) private returns (bytes memory) {

        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{ value: weiValue }(data);
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



pragma solidity ^0.6.0;





contract ERC20 is Context, IERC20 {

    using SafeMath for uint256;
    using Address for address;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor (string memory name, string memory symbol) public {
        _name = name;
        _symbol = symbol;
        _decimals = 18;
    }

    function name() public view returns (string memory) {

        return _name;
    }

    function symbol() public view returns (string memory) {

        return _symbol;
    }

    function decimals() public view returns (uint8) {

        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {

        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {

        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {

        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {

        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {

        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal virtual {

        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal virtual {

        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _setupDecimals(uint8 decimals_) internal {

        _decimals = decimals_;
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }

}



pragma solidity ^0.6.0;


library SafeCast {

    function toUint128(uint256 value) internal pure returns (uint128) {
        require(value < 2**128, "SafeCast: value doesn\'t fit in 128 bits");
        return uint128(value);
    }

    function toUint64(uint256 value) internal pure returns (uint64) {
        require(value < 2**64, "SafeCast: value doesn\'t fit in 64 bits");
        return uint64(value);
    }

    function toUint32(uint256 value) internal pure returns (uint32) {
        require(value < 2**32, "SafeCast: value doesn\'t fit in 32 bits");
        return uint32(value);
    }

    function toUint16(uint256 value) internal pure returns (uint16) {
        require(value < 2**16, "SafeCast: value doesn\'t fit in 16 bits");
        return uint16(value);
    }

    function toUint8(uint256 value) internal pure returns (uint8) {
        require(value < 2**8, "SafeCast: value doesn\'t fit in 8 bits");
        return uint8(value);
    }

    function toUint256(int256 value) internal pure returns (uint256) {
        require(value >= 0, "SafeCast: value must be positive");
        return uint256(value);
    }

    function toInt128(int256 value) internal pure returns (int128) {
        require(value >= -2**127 && value < 2**127, "SafeCast: value doesn\'t fit in 128 bits");
        return int128(value);
    }

    function toInt64(int256 value) internal pure returns (int64) {
        require(value >= -2**63 && value < 2**63, "SafeCast: value doesn\'t fit in 64 bits");
        return int64(value);
    }

    function toInt32(int256 value) internal pure returns (int32) {
        require(value >= -2**31 && value < 2**31, "SafeCast: value doesn\'t fit in 32 bits");
        return int32(value);
    }

    function toInt16(int256 value) internal pure returns (int16) {
        require(value >= -2**15 && value < 2**15, "SafeCast: value doesn\'t fit in 16 bits");
        return int16(value);
    }

    function toInt8(int256 value) internal pure returns (int8) {
        require(value >= -2**7 && value < 2**7, "SafeCast: value doesn\'t fit in 8 bits");
        return int8(value);
    }

    function toInt256(uint256 value) internal pure returns (int256) {
        require(value < 2**255, "SafeCast: value doesn't fit in an int256");
        return int256(value);
    }
}


pragma solidity >=0.6.6;

interface PriceCalculatorInterface {
    function calculatePrice(
        uint256 buyAmount,
        uint256 buyAmountLimit,
        uint256 sellAmount,
        uint256 sellAmountLimit,
        uint256 baseTokenPool,
        uint256 settlementTokenPool
    ) external view returns (uint256[5] memory);
}


pragma solidity >=0.6.6;

enum Token {TOKEN0, TOKEN1}

enum OrderType {FLEX_0_1, FLEX_1_0, STRICT_0_1, STRICT_1_0}

library TokenLibrary {
    function another(Token self) internal pure returns (Token) {
        if (self == Token.TOKEN0) {
            return Token.TOKEN1;
        } else {
            return Token.TOKEN0;
        }
    }
}

library OrderTypeLibrary {
    function inToken(OrderType self) internal pure returns (Token) {
        if (self == OrderType.FLEX_0_1 || self == OrderType.STRICT_0_1) {
            return Token.TOKEN0;
        } else {
            return Token.TOKEN1;
        }
    }

    function isFlex(OrderType self) internal pure returns (bool) {
        return self == OrderType.FLEX_0_1 || self == OrderType.FLEX_1_0;
    }

    function isStrict(OrderType self) internal pure returns (bool) {
        return !isFlex(self);
    }

    function next(OrderType self) internal pure returns (OrderType) {
        return OrderType((uint256(self) + 1) % 4);
    }

    function isBuy(OrderType self) internal pure returns (bool) {
        return (self == OrderType.FLEX_0_1 || self == OrderType.STRICT_0_1);
    }
}


pragma solidity >=0.6.6;


library RateMath {
    using SafeMath for uint256;
    uint256 public constant RATE_POINT_MULTIPLIER = 1000000000000000000; // 10^18

    function getRate(uint256 a, uint256 b) internal pure returns (uint256) {
        return a.mul(RATE_POINT_MULTIPLIER).div(b);
    }

    function divByRate(uint256 self, uint256 rate)
        internal
        pure
        returns (uint256)
    {
        return self.mul(RATE_POINT_MULTIPLIER).div(rate);
    }

    function mulByRate(uint256 self, uint256 rate)
        internal
        pure
        returns (uint256)
    {
        return self.mul(rate).div(RATE_POINT_MULTIPLIER);
    }
}


pragma solidity >=0.6.6;



struct BoxExecutionStatus {
    OrderType partiallyRefundOrderType;
    uint64 partiallyRefundRate; // refundAmount/inAmount
    uint128 rate; // Token0/Token1
    uint32 boxNumber;
    bool onGoing;
}

struct BookExecutionStatus {
    OrderType executingOrderType;
    uint256 nextIndex;
}

library BoxExecutionStatusLibrary {
    using OrderTypeLibrary for OrderType;

    function refundRate(BoxExecutionStatus memory self, OrderType orderType)
        internal
        pure
        returns (uint256)
    {
        if (self.partiallyRefundOrderType.inToken() != orderType.inToken()) {
            return 0;
        }

        if (self.partiallyRefundOrderType.isFlex()) {
            if (orderType.isFlex()) {
                return self.partiallyRefundRate;
            }
            return RateMath.RATE_POINT_MULTIPLIER;
        }

        if (orderType.isStrict()) {
            return self.partiallyRefundRate;
        }
        return 0;
    }
}


pragma solidity >=0.6.6;




struct OrderBox {
    mapping(OrderType => OrderBook) orderBooks;
    uint128 spreadRate;
    uint128 expireAt;
}

struct OrderBook {
    mapping(address => uint256) inAmounts;
    address[] recipients;
    uint256 totalInAmount;
}

library OrderBoxLibrary {
    using RateMath for uint256;
    using SafeMath for uint256;
    using TokenLibrary for Token;

    function newOrderBox(uint128 spreadRate, uint128 expireAt)
        internal
        pure
        returns (OrderBox memory)
    {
        return OrderBox({spreadRate: spreadRate, expireAt: expireAt});
    }

    function addOrder(
        OrderBox storage self,
        OrderType orderType,
        uint256 inAmount,
        address recipient
    ) internal {
        OrderBook storage orderBook = self.orderBooks[orderType];
        if (orderBook.inAmounts[recipient] == 0) {
            orderBook.recipients.push(recipient);
        }
        orderBook.inAmounts[recipient] = orderBook.inAmounts[recipient].add(
            inAmount
        );
        orderBook.totalInAmount = orderBook.totalInAmount.add(inAmount);
    }
}

library OrderBookLibrary {
    function numOfOrder(OrderBook memory self) internal pure returns (uint256) {
        return self.recipients.length;
    }
}


pragma solidity ^0.6.6;

abstract contract BoxExchange is ERC20 {
    using BoxExecutionStatusLibrary for BoxExecutionStatus;
    using OrderBoxLibrary for OrderBox;
    using OrderBookLibrary for OrderBook;
    using OrderTypeLibrary for OrderType;
    using TokenLibrary for Token;
    using RateMath for uint256;
    using SafeMath for uint256;
    using SafeCast for uint256;

    uint256 internal constant MARKET_FEE_RATE = 200000000000000000; // market fee taker takes 20% of spread

    address internal immutable factory;

    address internal immutable marketFeeTaker; // Address that receives market fee (i.e. Lien Token)
    uint128 public marketFeePool0; // Total market fee in TOKEN0
    uint128 public marketFeePool1; // Total market fee in TOKEN1

    uint128 internal reserve0; // Total Liquidity of TOKEN0
    uint128 internal reserve1; // Total Liquidity of TOKEN1
    OrderBox[] internal orderBoxes; // Array of OrderBox
    PriceCalculatorInterface internal immutable priceCalc; // Price Calculator
    BoxExecutionStatus internal boxExecutionStatus; // Struct that has information about execution of current executing OrderBox
    BookExecutionStatus internal bookExecutionStatus; // Struct that has information about execution of current executing OrderBook

    event AcceptOrders(
        address indexed recipient,
        bool indexed isBuy, // if true, this order is exchange from TOKEN0 to TOKEN1
        uint32 indexed boxNumber,
        bool isLimit, // if true, this order is STRICT order
        uint256 tokenIn
    );

    event MoveLiquidity(
        address indexed liquidityProvider,
        bool indexed isAdd, // if true, this order is addtion of liquidity
        uint256 movedToken0Amount,
        uint256 movedToken1Amount,
        uint256 sharesMoved // Amount of share that is minted or burned
    );

    event Execution(
        bool indexed isBuy, // if true, this order is exchange from TOKEN0 to TOKEN1
        uint32 indexed boxNumber,
        address indexed recipient,
        uint256 orderAmount, // Amount of token that is transferred when this order is added
        uint256 refundAmount, // In the same token as orderAmount
        uint256 outAmount // In the other token than orderAmount
    );

    event UpdateReserve(uint128 reserve0, uint128 reserve1, uint256 totalShare);

    event PayMarketFee(uint256 amount0, uint256 amount1);

    event ExecutionSummary(
        uint32 indexed boxNumber,
        uint8 partiallyRefundOrderType,
        uint256 rate,
        uint256 partiallyRefundRate,
        uint256 totalInAmountFLEX_0_1,
        uint256 totalInAmountFLEX_1_0,
        uint256 totalInAmountSTRICT_0_1,
        uint256 totalInAmountSTRICT_1_0
    );

    modifier isAmountSafe(uint256 amount) {
        require(amount != 0, "Amount should be bigger than 0");
        _;
    }

    modifier isInTime(uint256 timeout) {
        require(timeout > _currentOpenBoxId(), "Time out");
        _;
    }

    constructor(
        PriceCalculatorInterface _priceCalc,
        address _marketFeeTaker,
        string memory _name
    ) public ERC20(_name, "share") {
        factory = msg.sender;
        priceCalc = _priceCalc;
        marketFeeTaker = _marketFeeTaker;
        _setupDecimals(8); // Decimal of share token is the same as iDOL, LBT, and Lien Token
    }

    function whenToExecute(
        address recipient,
        uint256 boxNumber,
        bool isBuy,
        bool isLimit
    )
        external
        view
        returns (
            bool isExecuted,
            uint256 boxCount,
            uint256 orderCount
        )
    {
        return
            _whenToExecute(recipient, _getOrderType(isBuy, isLimit), boxNumber);
    }

    function getExchangeData()
        external
        virtual
        view
        returns (
            uint256 boxNumber,
            uint256 _reserve0,
            uint256 _reserve1,
            uint256 totalShare,
            uint256 latestSpreadRate,
            uint256 token0PerShareE18,
            uint256 token1PerShareE18
        )
    {
        boxNumber = _currentOpenBoxId();
        (_reserve0, _reserve1) = _getReserves();
        latestSpreadRate = orderBoxes[boxNumber].spreadRate;
        totalShare = totalSupply();
        token0PerShareE18 = RateMath.getRate(_reserve0, totalShare);
        token1PerShareE18 = RateMath.getRate(_reserve1, totalShare);
    }

    function getBoxSummary(uint256 boxNumber)
        public
        view
        returns (
            uint256 executionStatusNumber,
            uint256 flexToken0InAmount,
            uint256 strictToken0InAmount,
            uint256 flexToken1InAmount,
            uint256 strictToken1InAmount
        )
    {
        uint256 nextExecutingBoxId = boxExecutionStatus.boxNumber;
        flexToken0InAmount = orderBoxes[boxNumber].orderBooks[OrderType
            .FLEX_0_1]
            .totalInAmount;
        strictToken0InAmount = orderBoxes[boxNumber].orderBooks[OrderType
            .STRICT_0_1]
            .totalInAmount;
        flexToken1InAmount = orderBoxes[boxNumber].orderBooks[OrderType
            .FLEX_1_0]
            .totalInAmount;
        strictToken1InAmount = orderBoxes[boxNumber].orderBooks[OrderType
            .STRICT_1_0]
            .totalInAmount;
        if (boxNumber < nextExecutingBoxId) {
            executionStatusNumber = 2;
        } else if (
            boxNumber == nextExecutingBoxId && boxExecutionStatus.onGoing
        ) {
            executionStatusNumber = 1;
        }
    }

    function getOrderAmount(address account, OrderType orderType)
        public
        view
        returns (uint256)
    {
        return
            orderBoxes[_currentOpenBoxId()].orderBooks[orderType]
                .inAmounts[account];
    }

    function _feeRate() internal virtual returns (uint128);

    function _receiveTokens(
        Token token,
        address from,
        uint256 amount
    ) internal virtual;

    function _sendTokens(
        Token token,
        address to,
        uint256 amount
    ) internal virtual;

    function _payForOrderExecution(
        Token token,
        address to,
        uint256 amount
    ) internal virtual;

    function _payMarketFee(
        address _marketFeeTaker,
        uint256 amount0,
        uint256 amount1
    ) internal virtual;

    function _isCurrentOpenBoxExpired() internal virtual view returns (bool) {}

    function _init(
        uint128 amount0,
        uint128 amount1,
        uint256 initialShare
    ) internal virtual {
        require(totalSupply() == 0, "Already initialized");
        require(msg.sender == factory);
        _updateReserve(amount0, amount1);
        _mint(msg.sender, initialShare);
        _receiveTokens(Token.TOKEN0, msg.sender, amount0);
        _receiveTokens(Token.TOKEN1, msg.sender, amount1);
        _openNewBox();
    }

    function _addLiquidity(
        uint256 _reserve0,
        uint256 _reserve1,
        uint256 amount,
        uint256 minShare,
        Token tokenType
    ) internal virtual {
        (uint256 amount0, uint256 amount1, uint256 share) = _calculateAmounts(
            amount,
            _reserve0,
            _reserve1,
            tokenType
        );
        require(share >= minShare, "You can't receive enough shares");
        _receiveTokens(Token.TOKEN0, msg.sender, amount0);
        _receiveTokens(Token.TOKEN1, msg.sender, amount1);
        _updateReserve(
            _reserve0.add(amount0).toUint128(),
            _reserve1.add(amount1).toUint128()
        );
        _mint(msg.sender, share);
        emit MoveLiquidity(msg.sender, true, amount0, amount1, share);
    }

    function _removeLiquidity(
        uint256 minAmount0,
        uint256 minAmount1,
        uint256 share
    ) internal virtual {
        (uint256 _reserve0, uint256 _reserve1) = _getReserves(); // gas savings
        uint256 _totalSupply = totalSupply();
        uint256 amount0 = _reserve0.mul(share).div(_totalSupply);
        uint256 amount1 = _reserve1.mul(share).div(_totalSupply);
        require(
            amount0 >= minAmount0 && amount1 >= minAmount1,
            "You can't receive enough tokens"
        );
        _updateReserve(
            _reserve0.sub(amount0).toUint128(),
            _reserve1.sub(amount1).toUint128()
        );
        _burn(msg.sender, share);
        _sendTokens(Token.TOKEN0, msg.sender, amount0);
        _sendTokens(Token.TOKEN1, msg.sender, amount1);
        emit MoveLiquidity(msg.sender, false, amount0, amount1, share);
    }

    function _addOrder(
        OrderType orderType,
        uint256 inAmount,
        address recipient
    ) internal virtual {
        _rotateBox();
        uint256 _currentOpenBoxId = _currentOpenBoxId();
        _executeOrders(5, _currentOpenBoxId);
        if (recipient == address(0)) {
            recipient = msg.sender;
        }
        _receiveTokens(orderType.inToken(), msg.sender, inAmount);
        orderBoxes[_currentOpenBoxId].addOrder(orderType, inAmount, recipient);
        emit AcceptOrders(
            recipient,
            orderType.isBuy(),
            uint32(_currentOpenBoxId),
            orderType.isStrict(),
            inAmount
        );
    }

    function _triggerExecuteOrders(uint8 maxOrderNum) internal virtual {
        _executeOrders(maxOrderNum, _currentOpenBoxId());
    }

    function _triggerPayMarketFee() internal virtual {
        (
            uint256 _marketFeePool0,
            uint256 _marketFeePool1
        ) = _getMarketFeePools();
        _updateMarketFeePool(0, 0);

        emit PayMarketFee(_marketFeePool0, _marketFeePool1);
        _payMarketFee(marketFeeTaker, _marketFeePool0, _marketFeePool1);
    }

    function _openNewBox() internal virtual {
        orderBoxes.push(
            OrderBoxLibrary.newOrderBox(
                _feeRate(),
                (block.number + 2).toUint32()
            )
        );
    }

    function _rotateBox() private {
        if (_isCurrentOpenBoxExpired()) {
            _openNewBox();
        }
    }

    function _executeOrders(uint256 maxOrderNum, uint256 _currentOpenBoxId)
        private
    {
        BoxExecutionStatus memory _boxExecutionStatus = boxExecutionStatus;
        BookExecutionStatus memory _bookExecutionStatus = bookExecutionStatus;
        if (
            _boxExecutionStatus.boxNumber >= _currentOpenBoxId &&
            (!_isCurrentOpenBoxExpired() ||
                _boxExecutionStatus.boxNumber > _currentOpenBoxId)
        ) {
            return;
        }
        if (!_boxExecutionStatus.onGoing) {
            {
                (
                    OrderType partiallyRefundOrderType,
                    uint256 partiallyRefundRate,
                    uint256 rate
                ) = _getExecutionRatesAndUpdateReserve(
                    _boxExecutionStatus.boxNumber
                );
                _boxExecutionStatus
                    .partiallyRefundOrderType = partiallyRefundOrderType;
                _boxExecutionStatus.partiallyRefundRate = partiallyRefundRate
                    .toUint64();
                _boxExecutionStatus.rate = rate.toUint128();
                _boxExecutionStatus.onGoing = true;
                _bookExecutionStatus.executingOrderType = OrderType(0);
                _bookExecutionStatus.nextIndex = 0;
            }
        }
        while (maxOrderNum != 0) {
            OrderBook storage executionBook = orderBoxes[_boxExecutionStatus
                .boxNumber]
                .orderBooks[_bookExecutionStatus.executingOrderType];
            (
                bool isBookFinished,
                uint256 nextIndex,
                uint256 executedOrderNum
            ) = _executeOrdersInBook(
                executionBook,
                _bookExecutionStatus.executingOrderType.inToken(),
                _bookExecutionStatus.nextIndex,
                _boxExecutionStatus.refundRate(
                    _bookExecutionStatus.executingOrderType
                ),
                _boxExecutionStatus.rate,
                orderBoxes[_boxExecutionStatus.boxNumber].spreadRate,
                maxOrderNum
            );
            if (isBookFinished) {
                bool isBoxFinished = _isBoxFinished(
                    orderBoxes[_boxExecutionStatus.boxNumber],
                    _bookExecutionStatus.executingOrderType
                );
                delete orderBoxes[_boxExecutionStatus.boxNumber]
                    .orderBooks[_bookExecutionStatus.executingOrderType];

                if (isBoxFinished) {
                    _boxExecutionStatus.boxNumber += 1;
                    _boxExecutionStatus.onGoing = false;
                    boxExecutionStatus = _boxExecutionStatus;

                    return; // no need to update bookExecutionStatus;
                }
                _bookExecutionStatus.executingOrderType = _bookExecutionStatus
                    .executingOrderType
                    .next();
            }
            _bookExecutionStatus.nextIndex = nextIndex.toUint32();
            maxOrderNum -= executedOrderNum;
        }
        boxExecutionStatus = _boxExecutionStatus;
        bookExecutionStatus = _bookExecutionStatus;
    }

    function _executeOrdersInBook(
        OrderBook storage orderBook,
        Token inToken,
        uint256 initialIndex,
        uint256 refundRate,
        uint256 rate,
        uint256 spreadRate,
        uint256 maxOrderNum
    )
        private
        returns (
            bool,
            uint256,
            uint256
        )
    {
        uint256 index;
        uint256 numOfOrder = orderBook.numOfOrder();
        for (
            index = initialIndex;
            index - initialIndex < maxOrderNum;
            index++
        ) {
            if (index >= numOfOrder) {
                return (true, 0, index - initialIndex);
            }
            address recipient = orderBook.recipients[index];
            _executeOrder(
                inToken,
                recipient,
                orderBook.inAmounts[recipient],
                refundRate,
                rate,
                spreadRate
            );
        }
        if (index >= numOfOrder) {
            return (true, 0, index - initialIndex);
        }
        return (false, index, index - initialIndex);
    }

    function _executeOrder(
        Token inToken,
        address recipient,
        uint256 inAmount,
        uint256 refundRate,
        uint256 rate,
        uint256 spreadRate
    ) internal {
        Token outToken = inToken.another();
        uint256 refundAmount = inAmount.mulByRate(refundRate);
        uint256 executingInAmountWithoutSpread = inAmount
            .sub(refundAmount)
            .divByRate(RateMath.RATE_POINT_MULTIPLIER.add(spreadRate));
        uint256 outAmount = _otherAmountBasedOnRate(
            inToken,
            executingInAmountWithoutSpread,
            rate
        );
        _payForOrderExecution(inToken, recipient, refundAmount);
        _payForOrderExecution(outToken, recipient, outAmount);
        emit Execution(
            (inToken == Token.TOKEN0),
            uint32(_currentOpenBoxId()),
            recipient,
            inAmount,
            refundAmount,
            outAmount
        );
    }

    function _updateReservesAndMarketFeePoolByExecution(
        uint256 spreadRate,
        uint256 executingAmount0WithoutSpread,
        uint256 executingAmount1WithoutSpread,
        uint256 rate
    ) internal virtual {
        uint256 newReserve0;
        uint256 newReserve1;
        uint256 newMarketFeePool0;
        uint256 newMarketFeePool1;
        {
            (
                uint256 differenceOfReserve,
                uint256 differenceOfMarketFee
            ) = _calculateNewReserveAndMarketFeePool(
                spreadRate,
                executingAmount0WithoutSpread,
                executingAmount1WithoutSpread,
                rate,
                Token.TOKEN0
            );
            newReserve0 = reserve0 + differenceOfReserve;
            newMarketFeePool0 = marketFeePool0 + differenceOfMarketFee;
        }
        {
            (
                uint256 differenceOfReserve,
                uint256 differenceOfMarketFee
            ) = _calculateNewReserveAndMarketFeePool(
                spreadRate,
                executingAmount1WithoutSpread,
                executingAmount0WithoutSpread,
                rate,
                Token.TOKEN1
            );
            newReserve1 = reserve1 + differenceOfReserve;
            newMarketFeePool1 = marketFeePool1 + differenceOfMarketFee;
        }
        _updateReserve(newReserve0.toUint128(), newReserve1.toUint128());
        _updateMarketFeePool(
            newMarketFeePool0.toUint128(),
            newMarketFeePool1.toUint128()
        );
    }

    function _whenToExecute(
        address recipient,
        uint256 orderTypeCount,
        uint256 boxNumber
    )
        internal
        view
        returns (
            bool isExecuted,
            uint256 boxCount,
            uint256 orderCount
        )
    {
        if (boxNumber > _currentOpenBoxId()) {
            return (false, 0, 0);
        }
        OrderBox storage yourOrderBox = orderBoxes[boxNumber];
        address[] memory recipients = yourOrderBox.orderBooks[OrderType(
            orderTypeCount
        )]
            .recipients;
        uint256 nextExecutingBoxId = boxExecutionStatus.boxNumber;
        uint256 nextIndex = bookExecutionStatus.nextIndex;
        uint256 nextType = uint256(bookExecutionStatus.executingOrderType);
        bool onGoing = boxExecutionStatus.onGoing;
        bool isExist;
        uint256 place;
        for (uint256 j = 0; j != recipients.length; j++) {
            if (recipients[j] == recipient) {
                isExist = true;
                place = j;
                break;
            }
        }

        if (
            (boxNumber < nextExecutingBoxId) ||
            ((onGoing && (boxNumber == nextExecutingBoxId)) &&
                ((orderTypeCount < nextType) ||
                    ((orderTypeCount == nextType) && (place < nextIndex))))
        ) {
            return (true, 0, 0);
        }

        if (!isExist) {
            return (false, 0, 0);
        }

        uint256 counts;
        if (boxNumber == nextExecutingBoxId && onGoing) {
            for (uint256 i = nextType; i < orderTypeCount; i++) {
                counts += yourOrderBox.orderBooks[OrderType(i)].numOfOrder();
            }
            boxCount = 1;
            orderCount = counts.add(place).sub(nextIndex) + 1;
        } else {
            for (uint256 i = 0; i != orderTypeCount; i++) {
                counts += yourOrderBox.orderBooks[OrderType(i)].numOfOrder();
            }
            boxCount = boxNumber.sub(nextExecutingBoxId) + 1;
            orderCount = counts.add(place) + 1;
        }
    }

    function _getReserves()
        internal
        view
        returns (uint256 _reserve0, uint256 _reserve1)
    {
        _reserve0 = reserve0;
        _reserve1 = reserve1;
    }

    function _getMarketFeePools()
        internal
        view
        returns (uint256 _marketFeePool0, uint256 _marketFeePool1)
    {
        _marketFeePool0 = marketFeePool0;
        _marketFeePool1 = marketFeePool1;
    }

    function _updateReserve(uint128 newReserve0, uint128 newReserve1) internal {
        reserve0 = newReserve0;
        reserve1 = newReserve1;
        emit UpdateReserve(newReserve0, newReserve1, totalSupply());
    }

    function _calculatePriceWrapper(
        uint256 flexToken0InWithoutSpread,
        uint256 strictToken0InWithoutSpread,
        uint256 flexToken1InWithoutSpread,
        uint256 strictToken1InWithoutSpread,
        uint256 _reserve0,
        uint256 _reserve1
    )
        internal
        view
        returns (
            uint256 rate,
            uint256 refundStatus,
            uint256 partiallyRefundRate,
            uint256 executingAmount0,
            uint256 executingAmount1
        )
    {
        uint256[5] memory data = priceCalc.calculatePrice(
            flexToken0InWithoutSpread,
            strictToken0InWithoutSpread,
            flexToken1InWithoutSpread,
            strictToken1InWithoutSpread,
            _reserve0,
            _reserve1
        );
        return (data[0], data[1], data[2], data[3], data[4]);
    }

    function _otherAmountBasedOnRate(
        Token token,
        uint256 amount,
        uint256 rate0Per1
    ) internal pure returns (uint256) {
        if (token == Token.TOKEN0) {
            return amount.mulByRate(rate0Per1);
        } else {
            return amount.divByRate(rate0Per1);
        }
    }

    function _currentOpenBoxId() internal view returns (uint256) {
        return orderBoxes.length - 1;
    }

    function _getOrderType(bool isBuy, bool isLimit)
        internal
        pure
        returns (uint256 orderTypeCount)
    {
        if (isBuy && isLimit) {
            orderTypeCount = 2;
        } else if (!isBuy) {
            if (isLimit) {
                orderTypeCount = 3;
            } else {
                orderTypeCount = 1;
            }
        }
    }

    function _updateMarketFeePool(
        uint128 newMarketFeePool0,
        uint128 newMarketFeePool1
    ) private {
        marketFeePool0 = newMarketFeePool0;
        marketFeePool1 = newMarketFeePool1;
    }

    function _calculateAmounts(
        uint256 amount,
        uint256 _reserve0,
        uint256 _reserve1,
        Token tokenType
    )
        private
        view
        returns (
            uint256,
            uint256,
            uint256
        )
    {
        if (tokenType == Token.TOKEN0) {
            return (
                amount,
                amount.mul(_reserve1).div(_reserve0),
                amount.mul(totalSupply()).div(_reserve0)
            );
        } else {
            return (
                amount.mul(_reserve0).div(_reserve1),
                amount,
                amount.mul(totalSupply()).div(_reserve1)
            );
        }
    }

    function _priceCalculateRates(
        OrderBox storage orderBox,
        uint256 totalInAmountFLEX_0_1,
        uint256 totalInAmountFLEX_1_0,
        uint256 totalInAmountSTRICT_0_1,
        uint256 totalInAmountSTRICT_1_0
    )
        private
        view
        returns (
            uint256 rate,
            uint256 refundStatus,
            uint256 partiallyRefundRate,
            uint256 executingAmount0,
            uint256 executingAmount1
        )
    {
        uint256 withoutSpreadRate = RateMath.RATE_POINT_MULTIPLIER +
            orderBox.spreadRate;
        return
            _calculatePriceWrapper(
                totalInAmountFLEX_0_1.divByRate(withoutSpreadRate),
                totalInAmountSTRICT_0_1.divByRate(withoutSpreadRate),
                totalInAmountFLEX_1_0.divByRate(withoutSpreadRate),
                totalInAmountSTRICT_1_0.divByRate(withoutSpreadRate),
                reserve0,
                reserve1
            );
    }

    function _getExecutionRatesAndUpdateReserve(uint32 boxNumber)
        private
        returns (
            OrderType partiallyRefundOrderType,
            uint256 partiallyRefundRate,
            uint256 rate
        )
    {
        OrderBox storage orderBox = orderBoxes[boxNumber];
        uint256 refundStatus;
        uint256 executingAmount0WithoutSpread;
        uint256 executingAmount1WithoutSpread;
        uint256 totalInAmountFLEX_0_1 = orderBox.orderBooks[OrderType.FLEX_0_1]
            .totalInAmount;
        uint256 totalInAmountFLEX_1_0 = orderBox.orderBooks[OrderType.FLEX_1_0]
            .totalInAmount;
        uint256 totalInAmountSTRICT_0_1 = orderBox.orderBooks[OrderType
            .STRICT_0_1]
            .totalInAmount;
        uint256 totalInAmountSTRICT_1_0 = orderBox.orderBooks[OrderType
            .STRICT_1_0]
            .totalInAmount;
        (
            rate,
            refundStatus,
            partiallyRefundRate,
            executingAmount0WithoutSpread,
            executingAmount1WithoutSpread
        ) = _priceCalculateRates(
            orderBox,
            totalInAmountFLEX_0_1,
            totalInAmountFLEX_1_0,
            totalInAmountSTRICT_0_1,
            totalInAmountSTRICT_1_0
        );

        {
            if (refundStatus == 0) {
                partiallyRefundOrderType = OrderType.STRICT_0_1;
            } else if (refundStatus == 1) {
                partiallyRefundOrderType = OrderType.STRICT_0_1;
            } else if (refundStatus == 2) {
                partiallyRefundOrderType = OrderType.FLEX_0_1;
            } else if (refundStatus == 3) {
                partiallyRefundOrderType = OrderType.STRICT_1_0;
            } else if (refundStatus == 4) {
                partiallyRefundOrderType = OrderType.FLEX_1_0;
            }
        }
        emit ExecutionSummary(
            boxNumber,
            uint8(partiallyRefundOrderType),
            rate,
            partiallyRefundRate,
            totalInAmountFLEX_0_1,
            totalInAmountFLEX_1_0,
            totalInAmountSTRICT_0_1,
            totalInAmountSTRICT_1_0
        );
        _updateReservesAndMarketFeePoolByExecution(
            orderBox.spreadRate,
            executingAmount0WithoutSpread,
            executingAmount1WithoutSpread,
            rate
        );
    }

    function _isBoxFinished(
        OrderBox storage orders,
        OrderType lastFinishedOrderType
    ) private view returns (bool) {
        if (lastFinishedOrderType == OrderType.STRICT_1_0) {
            return true;
        }
        for (uint256 i = uint256(lastFinishedOrderType.next()); i != 4; i++) {
            OrderBook memory book = orders.orderBooks[OrderType(i)];
            if (book.numOfOrder() != 0) {
                return false;
            }
        }
        return true;
    }

    function _calculateNewReserveAndMarketFeePool(
        uint256 spreadRate,
        uint256 executingAmountWithoutSpread,
        uint256 anotherExecutingAmountWithoutSpread,
        uint256 rate,
        Token tokenType
    ) internal returns (uint256, uint256) {
        uint256 totalSpread = executingAmountWithoutSpread.mulByRate(
            spreadRate
        );
        uint256 marketFee = totalSpread.mulByRate(MARKET_FEE_RATE);
        uint256 newReserve = executingAmountWithoutSpread +
            (totalSpread - marketFee) -
            _otherAmountBasedOnRate(
                tokenType.another(),
                anotherExecutingAmountWithoutSpread,
                rate
            );
        return (newReserve, marketFee);
    }

    function _getTokenType(bool isBuy, bool isStrict)
        internal
        pure
        returns (OrderType)
    {
        if (isBuy) {
            if (isStrict) {
                return OrderType.STRICT_0_1;
            } else {
                return OrderType.FLEX_0_1;
            }
        } else {
            if (isStrict) {
                return OrderType.STRICT_1_0;
            } else {
                return OrderType.FLEX_1_0;
            }
        }
    }
}


pragma solidity >=0.6.6;


interface ERC20Interface is IERC20 {
    function name() external view returns (string memory);
}



pragma solidity ^0.6.0;




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


pragma solidity >=0.6.6;

interface OracleInterface {
    function latestPrice() external returns (uint256);

    function getVolatility() external returns (uint256);

    function latestId() external returns (uint256);
}


pragma solidity >=0.6.6;


interface SpreadCalculatorInterface {
    function calculateCurrentSpread(
        uint256 _maturity,
        uint256 _strikePrice,
        OracleInterface oracle
    ) external returns (uint128);

    function calculateSpreadByAssetVolatility(OracleInterface oracle)
        external
        returns (uint128);
}


pragma solidity >=0.6.6;






abstract contract TokenBoxExchange is BoxExchange {
    using SafeERC20 for ERC20Interface;

    ERC20Interface public immutable idol; // token0
    ERC20Interface public immutable token;
    SpreadCalculatorInterface internal immutable spreadCalc;
    OracleInterface internal immutable oracle;

    event SpreadRate(uint128 indexed boxNumber, uint128 spreadRate);

    constructor(
        ERC20Interface _idol,
        ERC20Interface _token,
        PriceCalculatorInterface _priceCalc,
        address _marketFeeTaker,
        SpreadCalculatorInterface _spreadCalc,
        OracleInterface _oracle,
        string memory _name
    ) public BoxExchange(_priceCalc, _marketFeeTaker, _name) {
        idol = _idol;
        token = _token;
        spreadCalc = _spreadCalc;
        oracle = _oracle;
    }

    function initializeExchange(
        uint256 IDOLAmount,
        uint256 settlementTokenAmount,
        uint256 initialShare
    ) external {
        _init(
            uint128(IDOLAmount),
            uint128(settlementTokenAmount),
            initialShare
        );
    }

    function orderBaseToSettlement(
        uint256 timeout,
        address recipient,
        uint256 IDOLAmount,
        bool isLimit
    ) external isAmountSafe(IDOLAmount) isInTime(timeout) {
        OrderType orderType = _getTokenType(true, isLimit);
        _addOrder(orderType, IDOLAmount, recipient);
    }

    function orderSettlementToBase(
        uint256 timeout,
        address recipient,
        uint256 settlementTokenAmount,
        bool isLimit
    ) external isAmountSafe(settlementTokenAmount) isInTime(timeout) {
        OrderType orderType = _getTokenType(false, isLimit);
        _addOrder(orderType, settlementTokenAmount, recipient);
    }

    function addLiquidity(
        uint256 timeout,
        uint256 IDOLAmount,
        uint256 settlementTokenAmount,
        uint256 minShares
    )
        external
        isAmountSafe(IDOLAmount)
        isAmountSafe(settlementTokenAmount)
        isInTime(timeout)
    {
        require(timeout > _currentOpenBoxId(), "Time out");
        (uint256 _reserve0, uint256 _reserve1) = _getReserves(); // gas savings
        uint256 settlementAmountInBase = settlementTokenAmount
            .mul(_reserve0)
            .div(_reserve1);
        if (IDOLAmount <= settlementAmountInBase) {
            _addLiquidity(
                _reserve0,
                _reserve1,
                IDOLAmount,
                minShares,
                Token.TOKEN0
            );
        } else {
            _addLiquidity(
                _reserve0,
                _reserve1,
                settlementTokenAmount,
                minShares,
                Token.TOKEN1
            );
        }
    }

    function removeLiquidity(
        uint256 timeout,
        uint256 minBaseTokens,
        uint256 minSettlementTokens,
        uint256 sharesBurned
    ) external isInTime(timeout) {
        require(timeout > _currentOpenBoxId(), "Time out");
        _removeLiquidity(minBaseTokens, minSettlementTokens, sharesBurned);
    }

    function executeUnexecutedBox(uint8 maxOrderNum) external {
        _triggerExecuteOrders(maxOrderNum);
    }

    function sendMarketFeeToLien() external {
        _triggerPayMarketFee();
    }


    function _receiveTokens(
        Token tokenType,
        address from,
        uint256 amount
    ) internal override {
        _IERC20(tokenType).safeTransferFrom(from, address(this), amount);
    }

    function _sendTokens(
        Token tokenType,
        address to,
        uint256 amount
    ) internal override {
        if (amount > 0) {
            _IERC20(tokenType).safeTransfer(to, amount);
        }
    }

    function _payForOrderExecution(
        Token tokenType,
        address to,
        uint256 amount
    ) internal override {
        _IERC20(tokenType).safeTransfer(to, amount);
    }

    function _isCurrentOpenBoxExpired() internal override view returns (bool) {
        return block.number >= orderBoxes[_currentOpenBoxId()].expireAt;
    }

    function _openNewBox() internal override(BoxExchange) {
        super._openNewBox();
        uint256 _boxNumber = _currentOpenBoxId();
        emit SpreadRate(
            _boxNumber.toUint128(),
            orderBoxes[_boxNumber].spreadRate
        );
    }

    function _IERC20(Token tokenType) internal view returns (ERC20Interface) {
        if (tokenType == Token.TOKEN0) {
            return idol;
        }
        return token;
    }
}


pragma solidity >=0.6.6;


contract ERC20BoxExchange is TokenBoxExchange {
    constructor(
        ERC20Interface _idol,
        ERC20Interface _token,
        PriceCalculatorInterface _priceCalc,
        address _marketFeeTaker,
        SpreadCalculatorInterface _spreadCalc,
        OracleInterface _oracle,
        string memory _name
    )
        public
        TokenBoxExchange(
            _idol,
            _token,
            _priceCalc,
            _marketFeeTaker,
            _spreadCalc,
            _oracle,
            _name
        )
    {}

    function _feeRate() internal override returns (uint128) {
        return spreadCalc.calculateSpreadByAssetVolatility(oracle);
    }

    function _payMarketFee(
        address _marketFeeTaker,
        uint256 amount0,
        uint256 amount1
    ) internal override {
        if (amount0 != 0) {
            idol.safeTransfer(_marketFeeTaker, amount0);
        }
    }

    function _updateReservesAndMarketFeePoolByExecution(
        uint256 spreadRate,
        uint256 executingAmount0WithoutSpread,
        uint256 executingAmount1WithoutSpread,
        uint256 rate
    ) internal virtual override {
        uint256 newReserve0;
        uint256 newReserve1;
        uint256 newMarketFeePool0;
        uint256 marketFee1;
        {
            (
                uint256 differenceOfReserve,
                uint256 differenceOfMarketFee
            ) = _calculateNewReserveAndMarketFeePool(
                spreadRate,
                executingAmount0WithoutSpread,
                executingAmount1WithoutSpread,
                rate,
                Token.TOKEN0
            );
            newReserve0 = reserve0 + differenceOfReserve;
            newMarketFeePool0 = marketFeePool0 + differenceOfMarketFee;
        }
        {
            (newReserve1, marketFee1) = _calculateNewReserveAndMarketFeePool(
                spreadRate,
                executingAmount1WithoutSpread,
                executingAmount0WithoutSpread,
                rate,
                Token.TOKEN1
            );
            newReserve1 = newReserve1 + reserve1;
        }

        {
            uint256 convertedSpread1to0 = marketFee1
                .mulByRate(newReserve0.divByRate(newReserve1.add(marketFee1)))
                .divByRate(RateMath.RATE_POINT_MULTIPLIER);
            newReserve1 = newReserve1 + marketFee1;
            newReserve0 = newReserve0 - convertedSpread1to0;
            newMarketFeePool0 = newMarketFeePool0 + convertedSpread1to0;
        }
        _updateReserve(newReserve0.toUint128(), newReserve1.toUint128());
        _updateMarketFeePool(newMarketFeePool0.toUint128());
    }

    function _updateMarketFeePool(uint256 newMarketFeePool0) internal {
        marketFeePool0 = newMarketFeePool0.toUint128();
    }
}



pragma solidity ^0.6.0;

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
}



pragma solidity ^0.6.0;


library Arrays {
    function findUpperBound(uint256[] storage array, uint256 element) internal view returns (uint256) {
        if (array.length == 0) {
            return 0;
        }

        uint256 low = 0;
        uint256 high = array.length;

        while (low < high) {
            uint256 mid = Math.average(low, high);

            if (array[mid] > element) {
                high = mid;
            } else {
                low = mid + 1;
            }
        }

        if (low > 0 && array[low - 1] == element) {
            return low - 1;
        } else {
            return low;
        }
    }
}



pragma solidity ^0.6.0;


library Counters {
    using SafeMath for uint256;

    struct Counter {
        uint256 _value; // default: 0
    }

    function current(Counter storage counter) internal view returns (uint256) {
        return counter._value;
    }

    function increment(Counter storage counter) internal {
        counter._value += 1;
    }

    function decrement(Counter storage counter) internal {
        counter._value = counter._value.sub(1);
    }
}



pragma solidity ^0.6.0;





abstract contract ERC20Snapshot is ERC20 {

    using SafeMath for uint256;
    using Arrays for uint256[];
    using Counters for Counters.Counter;

    struct Snapshots {
        uint256[] ids;
        uint256[] values;
    }

    mapping (address => Snapshots) private _accountBalanceSnapshots;
    Snapshots private _totalSupplySnapshots;

    Counters.Counter private _currentSnapshotId;

    event Snapshot(uint256 id);

    function _snapshot() internal virtual returns (uint256) {
        _currentSnapshotId.increment();

        uint256 currentId = _currentSnapshotId.current();
        emit Snapshot(currentId);
        return currentId;
    }

    function balanceOfAt(address account, uint256 snapshotId) public view returns (uint256) {
        (bool snapshotted, uint256 value) = _valueAt(snapshotId, _accountBalanceSnapshots[account]);

        return snapshotted ? value : balanceOf(account);
    }

    function totalSupplyAt(uint256 snapshotId) public view returns(uint256) {
        (bool snapshotted, uint256 value) = _valueAt(snapshotId, _totalSupplySnapshots);

        return snapshotted ? value : totalSupply();
    }

    function _transfer(address from, address to, uint256 value) internal virtual override {
        _updateAccountSnapshot(from);
        _updateAccountSnapshot(to);

        super._transfer(from, to, value);
    }

    function _mint(address account, uint256 value) internal virtual override {
        _updateAccountSnapshot(account);
        _updateTotalSupplySnapshot();

        super._mint(account, value);
    }

    function _burn(address account, uint256 value) internal virtual override {
        _updateAccountSnapshot(account);
        _updateTotalSupplySnapshot();

        super._burn(account, value);
    }

    function _valueAt(uint256 snapshotId, Snapshots storage snapshots)
        private view returns (bool, uint256)
    {
        require(snapshotId > 0, "ERC20Snapshot: id is 0");
        require(snapshotId <= _currentSnapshotId.current(), "ERC20Snapshot: nonexistent id");


        uint256 index = snapshots.ids.findUpperBound(snapshotId);

        if (index == snapshots.ids.length) {
            return (false, 0);
        } else {
            return (true, snapshots.values[index]);
        }
    }

    function _updateAccountSnapshot(address account) private {
        _updateSnapshot(_accountBalanceSnapshots[account], balanceOf(account));
    }

    function _updateTotalSupplySnapshot() private {
        _updateSnapshot(_totalSupplySnapshots, totalSupply());
    }

    function _updateSnapshot(Snapshots storage snapshots, uint256 currentValue) private {
        uint256 currentId = _currentSnapshotId.current();
        if (_lastSnapshotId(snapshots.ids) < currentId) {
            snapshots.ids.push(currentId);
            snapshots.values.push(currentValue);
        }
    }

    function _lastSnapshotId(uint256[] storage ids) private view returns (uint256) {
        if (ids.length == 0) {
            return 0;
        } else {
            return ids[ids.length - 1];
        }
    }
}


pragma solidity >=0.6.6;


interface LienTokenInterface is IERC20 {
    function currentTerm() external view returns (uint256);

    function expiration() external view returns (uint256);

    function receiveDividend(address token, address recipient) external;

    function dividendAt(
        address token,
        address account,
        uint256 term
    ) external view returns (uint256);
}


pragma solidity >=0.6.6;






abstract contract ERC20Redistribution is ERC20Snapshot {
    using SafeERC20 for ERC20Interface;

    struct Dividend {
        mapping(ERC20Interface => uint256) tokens;
        uint256 eth;
    }

    LienTokenInterface public lien;
    mapping(uint256 => uint256) private snapshotsOfTermEnd;
    mapping(uint256 => Dividend) private totalDividendsAt;
    mapping(address => mapping(ERC20Interface => uint256))
        private lastReceivedTermsOfTokens;
    mapping(address => uint256) private lastReceivedTermsOfEth;

    event ReceiveDividendETH(address indexed recipient, uint256 amount);
    event ReceiveDividendToken(
        address indexed recipient,
        address indexed tokenAddress,
        uint256 amount
    );

    modifier termValidation(uint256 _term) {
        require(_term > 0, "0 is invalid value as term");
        _;
    }

    receive() external payable {}

    constructor(LienTokenInterface _lien) public {
        lien = _lien;
    }

    function receiveDividendToken(ERC20Interface token) public {
        uint256 _currentTerm = currentTerm();
        if (_currentTerm == 1) {
            return;
        }
        _moveDividendTokenFromLIEN(token, _currentTerm);
        uint256 lastReceivedTerm = lastReceivedTermsOfTokens[msg.sender][token];
        lastReceivedTermsOfTokens[msg.sender][token] = _currentTerm - 1;
        uint256 dividend;
        for (uint256 term = lastReceivedTerm + 1; term < _currentTerm; term++) {
            dividend += dividendTokenAt(msg.sender, token, term);
        }
        emit ReceiveDividendToken(msg.sender, address(token), dividend);
        token.safeTransfer(msg.sender, dividend);
    }

    function receiveDividendEth() public {
        uint256 _currentTerm = currentTerm();
        if (_currentTerm == 1) {
            return;
        }
        _moveDividendEthFromLIEN(_currentTerm);
        uint256 lastReceivedTerm = lastReceivedTermsOfEth[msg.sender];
        lastReceivedTermsOfEth[msg.sender] = _currentTerm - 1;
        uint256 dividend;
        for (uint256 term = lastReceivedTerm + 1; term < _currentTerm; term++) {
            dividend += dividendEthAt(msg.sender, term);
        }
        emit ReceiveDividendETH(msg.sender, dividend);
        (bool success, ) = msg.sender.call{value: dividend}("");
        require(success, "ETH transfer failed");
    }

    function currentTerm() public view returns (uint256) {
        return lien.currentTerm();
    }

    function dividendTokenAt(
        address account,
        ERC20Interface token,
        uint256 term
    ) public view returns (uint256) {
        uint256 balanceAtTermEnd = balanceOfAtTermEnd(account, term);
        uint256 totalSupplyAtTermEnd = totalSupplyAtTermEnd(term);
        uint256 totalDividend = totalDividendTokenAt(token, term);
        return totalDividend.mul(balanceAtTermEnd).div(totalSupplyAtTermEnd);
    }

    function dividendEthAt(address account, uint256 term)
        public
        view
        returns (uint256)
    {
        uint256 balanceAtTermEnd = balanceOfAtTermEnd(account, term);
        uint256 totalSupplyAtTermEnd = totalSupplyAtTermEnd(term);
        uint256 totalDividend = totalDividendEthAt(term);
        return totalDividend.mul(balanceAtTermEnd).div(totalSupplyAtTermEnd);
    }

    function totalDividendTokenAt(ERC20Interface token, uint256 term)
        public
        view
        returns (uint256)
    {
        return totalDividendsAt[term].tokens[token];
    }

    function totalDividendEthAt(uint256 term) public view returns (uint256) {
        return totalDividendsAt[term].eth;
    }

    function balanceOfAtTermEnd(address account, uint256 term)
        public
        view
        termValidation(term)
        returns (uint256)
    {
        uint256 _currentTerm = currentTerm();
        for (uint256 i = term; i < _currentTerm; i++) {
            if (_isSnapshottedOnTermEnd(i)) {
                return balanceOfAt(account, snapshotsOfTermEnd[i]);
            }
        }
        return balanceOf(account);
    }

    function totalSupplyAtTermEnd(uint256 term)
        public
        view
        termValidation(term)
        returns (uint256)
    {
        uint256 _currentTerm = currentTerm();
        for (uint256 i = term; i < _currentTerm; i++) {
            if (_isSnapshottedOnTermEnd(i)) {
                return totalSupplyAt(snapshotsOfTermEnd[i]);
            }
        }
        return totalSupply();
    }

    function _transfer(
        address from,
        address to,
        uint256 value
    ) internal virtual override {
        _snapshotOnTermEnd();
        super._transfer(from, to, value);
    }

    function _mint(address account, uint256 value) internal virtual override {
        _snapshotOnTermEnd();
        super._mint(account, value);
    }

    function _burn(address account, uint256 value) internal virtual override {
        _snapshotOnTermEnd();
        super._burn(account, value);
    }

    function _snapshotOnTermEnd() private {
        uint256 _currentTerm = currentTerm();
        if (_currentTerm > 1 && !_isSnapshottedOnTermEnd(_currentTerm - 1)) {
            snapshotsOfTermEnd[_currentTerm - 1] = _snapshot();
        }
    }

    function _isSnapshottedOnTermEnd(uint256 term) private view returns (bool) {
        return snapshotsOfTermEnd[term] != 0;
    }

    function _moveDividendTokenFromLIEN(
        ERC20Interface token,
        uint256 _currentTerm
    ) private {
        uint256 expiration = lien.expiration();
        uint256 start;
        uint256 totalNewDividend;
        if (_currentTerm > expiration) {
            start = _currentTerm - expiration;
        } else {
            start = 1;
        }
        for (uint256 i = _currentTerm - 1; i >= start; i--) {
            if (totalDividendsAt[i].tokens[token] != 0) {
                break;
            }
            uint256 dividend = lien.dividendAt(
                address(token),
                address(this),
                i
            );
            totalDividendsAt[i].tokens[token] = dividend;
            totalNewDividend += dividend;
        }
        if (totalNewDividend == 0) {
            return;
        }
        lien.receiveDividend(address(token), address(this));
    }

    function _moveDividendEthFromLIEN(uint256 _currentTerm) private {
        uint256 expiration = lien.expiration();
        uint256 start;
        uint256 totalNewDividend;
        if (_currentTerm > expiration) {
            start = _currentTerm - expiration;
        } else {
            start = 1;
        }
        for (uint256 i = _currentTerm - 1; i >= start; i--) {
            if (totalDividendsAt[i].eth != 0) {
                break;
            }
            uint256 dividend = lien.dividendAt(address(0), address(this), i);
            totalDividendsAt[i].eth = dividend;
            totalNewDividend += dividend;
        }
        if (totalNewDividend == 0) {
            return;
        }
        lien.receiveDividend(address(0), address(this));
    }
}


pragma solidity >=0.6.6;



contract LienBoxExchange is ERC20BoxExchange, ERC20Redistribution {
  constructor(
    ERC20Interface _idol,
    PriceCalculatorInterface _priceCalc,
    LienTokenInterface _lien,
    SpreadCalculatorInterface _spreadCalc,
    string memory _name
  )
    public
    ERC20Redistribution(_lien)
    ERC20BoxExchange(
      _idol,
      ERC20Interface(address(_lien)),
      _priceCalc,
      address(_lien),
      _spreadCalc,
      OracleInterface(address(0)),
      _name
    )
  {}

  function _transfer(
    address from,
    address to,
    uint256 value
  ) internal override(ERC20, ERC20Redistribution) {
    ERC20Redistribution._transfer(from, to, value);
  }

  function _burn(address account, uint256 value)
    internal
    override(ERC20, ERC20Redistribution)
  {
    ERC20Redistribution._burn(account, value);
  }

  function _mint(address account, uint256 value)
    internal
    override(ERC20, ERC20Redistribution)
  {
    ERC20Redistribution._mint(account, value);
  }
}