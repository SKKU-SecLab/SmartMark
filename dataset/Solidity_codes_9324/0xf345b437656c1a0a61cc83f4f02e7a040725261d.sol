
pragma solidity 0.6.12;


library SafeMath {

    
    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b <= a, "SafeMath: subtraction overflow");
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

        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }

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


contract Context {

    constructor () internal { }

    function _msgSender() internal view returns (address payable) {

        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {

        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

interface IERC20 {

    
    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function decimals() external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}


library Address {

    
    function isContract(address account) internal view returns (bool) {

        uint256 size;
        assembly { size := extcodesize(account) }
        return size > 0;
    }
}

contract ReentrancyGuard {


    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() public {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {

        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
    }
}


library SafeERC20 {

    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {

        callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }
    
    function safeMultiTransfer(IERC20 token, address[] memory to, uint256[] memory values) internal {

        require(to.length == values.length, "Different number of recipients than values");
        for (uint i = 0; i < to.length; i++) {
            callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to[i], values[i]));
        }
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {

        callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }
    
    function safeMultiTransferFrom(IERC20 token, address from, address[] memory to, uint256[] memory values) internal {

        require(to.length == values.length, "Different number of recipients than values");
        for (uint i = 0; i < to.length; i++) {
            callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to[i], values[i]));
        }
    }

    function safeApprove(IERC20 token, address spender, uint256 value) internal {

        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).sub(value);
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function callOptionalReturn(IERC20 token, bytes memory data) private {


        require(address(token).isContract(), "SafeERC20: call to non-contract");

        (bool success, bytes memory returndata) = address(token).call(data);
        require(success, "SafeERC20: low-level call failed");

        if (returndata.length > 0) { // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

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

}


library UniswapV2Library {

    using SafeMath for uint;

    function sortTokens(address tokenA, address tokenB) internal pure returns (address token0, address token1) {

        require(tokenA != tokenB, 'UniswapV2Library: IDENTICAL_ADDRESSES');
        (token0, token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        require(token0 != address(0), 'UniswapV2Library: ZERO_ADDRESS');
    }

    function pairFor(address factory, address tokenA, address tokenB) internal pure returns (address pair) {

        (address token0, address token1) = sortTokens(tokenA, tokenB);
        pair = address(uint(keccak256(abi.encodePacked(
                hex'ff',
                factory,
                keccak256(abi.encodePacked(token0, token1)),
                hex'96e8ac4277198ff8b6f785478aa9a39f403cb768dd02cbee326c3e7da348845f' // init code hash
            ))));
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

    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) internal pure returns (uint amountOut) {

        require(amountIn > 0, 'UniswapV2Library: INSUFFICIENT_INPUT_AMOUNT');
        require(reserveIn > 0 && reserveOut > 0, 'UniswapV2Library: INSUFFICIENT_LIQUIDITY');
        uint amountInWithFee = amountIn.mul(997);
        uint numerator = amountInWithFee.mul(reserveOut);
        uint denominator = reserveIn.mul(1000).add(amountInWithFee);
        amountOut = numerator / denominator;
    }

    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) internal pure returns (uint amountIn) {

        require(amountOut > 0, 'UniswapV2Library: INSUFFICIENT_OUTPUT_AMOUNT');
        require(reserveIn > 0 && reserveOut > 0, 'UniswapV2Library: INSUFFICIENT_LIQUIDITY');
        uint numerator = reserveIn.mul(amountOut).mul(1000);
        uint denominator = reserveOut.sub(amountOut).mul(997);
        amountIn = (numerator / denominator).add(1);
    }

    function getAmountsOut(address factory, uint amountIn, address[] memory path) internal view returns (uint[] memory amounts) {

        require(path.length >= 2, 'UniswapV2Library: INVALID_PATH');
        amounts = new uint[](path.length);
        amounts[0] = amountIn;
        for (uint i; i < path.length - 1; i++) {
            (uint reserveIn, uint reserveOut) = getReserves(factory, path[i], path[i + 1]);
            amounts[i + 1] = getAmountOut(amounts[i], reserveIn, reserveOut);
        }
    }

    function getAmountsIn(address factory, uint amountOut, address[] memory path) internal view returns (uint[] memory amounts) {

        require(path.length >= 2, 'UniswapV2Library: INVALID_PATH');
        amounts = new uint[](path.length);
        amounts[amounts.length - 1] = amountOut;
        for (uint i = path.length - 1; i > 0; i--) {
            (uint reserveIn, uint reserveOut) = getReserves(factory, path[i - 1], path[i]);
            amounts[i - 1] = getAmountIn(amounts[i], reserveIn, reserveOut);
        }
    }
}







interface IUniswapV2Factory {

    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);

    function feeToSetter() external view returns (address);


    function getPair(address tokenA, address tokenB) external view returns (address pair);

    function allPairs(uint) external view returns (address pair);

    function allPairsLength() external view returns (uint);


    function createPair(address tokenA, address tokenB) external returns (address pair);


    function setFeeTo(address) external;

    function setFeeToSetter(address) external;

}


pragma solidity 0.6.12;

interface IWETH {

    function deposit() external payable;

    function transfer(address to, uint value) external returns (bool);

    function withdraw(uint) external;

}


interface IHedgeySwap {

    function hedgeyCallSwap(address originalOwner, uint _c, uint _totalPurchase, address[] memory path, bool cashBack) external;

}


interface IHedgeyFactory {

    function isSwapper(address swapper) external view returns (bool);

}


contract HedgeyCalls is ReentrancyGuard {

    using SafeMath for uint;
    using SafeERC20 for IERC20;

    address public hedgeyFactory;
    address public asset;
    address public pymtCurrency;
    uint public assetDecimals;
    address public uniPair; 
    address payable public constant weth = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2; //weth address    
    uint public fee;
    address payable public feeCollector;
    uint public c = 0;
    address public constant uniFactory = 0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f; //AMM factory address
    bool private assetWeth;
    bool private pymtWeth;
    bool public cashCloseOn;
    

    constructor(address _asset, address _pymtCurrency, address payable _feeCollector, uint _fee) public {
        hedgeyFactory = msg.sender;
        require(_asset != _pymtCurrency);
        asset = _asset;
        pymtCurrency = _pymtCurrency;
        feeCollector = _feeCollector;
        fee = _fee;
        assetDecimals = IERC20(_asset).decimals();
        uniPair = IUniswapV2Factory(uniFactory).getPair(asset, pymtCurrency);
        if (uniPair != address(0x0)) {
            cashCloseOn = true;
        }
        
        if (_asset == weth) {
            assetWeth = true;
            pymtWeth = false;
        } else if (_pymtCurrency == weth) {
            assetWeth = false;
            pymtWeth = true;
        } else {
            assetWeth = false;
            pymtWeth = false;
        }
    }
    
    struct Call {
        address payable short;
        uint assetAmt;
        uint minimumPurchase;
        uint strike;
        uint totalPurch;
        uint price;
        uint expiry;
        bool open;
        bool tradeable;
        address payable long;
        bool exercised;
    }

    
    mapping (uint => Call) public calls;

    

    receive() external payable {    
    }

    function depositPymt(bool _isWeth, address _token, address _sender, uint _amt) internal {

        if (_isWeth) {
            require(msg.value == _amt, "deposit issue: sending in wrong amount of eth");
            IWETH(weth).deposit{value: _amt}();
            assert(IWETH(weth).transfer(address(this), _amt));
        } else {
            SafeERC20.safeTransferFrom(IERC20(_token), _sender, address(this), _amt);
        }
    }

    function withdrawPymt(bool _isWeth, address _token, address payable to, uint _amt) internal {

        if (_isWeth && (!Address.isContract(to))) {
            IWETH(weth).withdraw(_amt);
            to.transfer(_amt);
        } else {
            SafeERC20.safeTransfer(IERC20(_token), to, _amt);
        }
    }

    function transferPymt(bool _isWETH, address _token, address from, address payable to, uint _amt) internal {

        if (_isWETH) {
            if (!Address.isContract(to)) {
                to.transfer(_amt);
            } else {
                IWETH(weth).deposit{value: _amt}();
                assert(IWETH(weth).transfer(to, _amt));
            }
        } else {
            SafeERC20.safeTransferFrom(IERC20(_token), from, to, _amt);         
        }
    }

    function transferPymtWithFee(bool _isWETH, address _token, address from, address payable to, uint _total) internal {

        uint _fee = (_total * fee).div(1e4);
        uint _amt = _total.sub(_fee);
        if (_isWETH) {
            require(msg.value == _total, "transfer issue: wrong amount of eth sent");
        }
        transferPymt(_isWETH, _token, from, to, _amt); //transfer the stub to recipient
        if (_fee > 0) transferPymt(_isWETH, _token, from, feeCollector, _fee); //transfer fee to fee collector
    }

    
    function changeFee(uint _fee, address payable _collector) external {

        require(msg.sender == feeCollector);
        fee = _fee;
        feeCollector = _collector;
    }

    
    function updateAMM() external {

        uniPair = IUniswapV2Factory(uniFactory).getPair(asset, pymtCurrency);
        if (uniPair == address(0x0)) {
            cashCloseOn = false;
        } else {
            cashCloseOn = true;
        }
        emit AMMUpdate(cashCloseOn);
        
    }



    function newBid(uint _assetAmt, uint _strike, uint _price, uint _expiry) payable external {

        uint _totalPurch = _assetAmt.mul(_strike).div(10 ** assetDecimals);
        require(_totalPurch > 0, "c: totalPurchase error: too small amount");
        uint balCheck = pymtWeth ? msg.value : IERC20(pymtCurrency).balanceOf(msg.sender);
        require(balCheck >= _price, "c: not enough cash to bid");
        depositPymt(pymtWeth, pymtCurrency, msg.sender, _price); 
        calls[c++] = Call(address(0x0), _assetAmt, _assetAmt, _strike, _totalPurch, _price, _expiry, false, true, msg.sender, false);
        emit NewBid(c.sub(1), msg.sender, _assetAmt, _assetAmt, _strike, _price, _expiry);
    }
    
    function cancelNewBid(uint _c) external nonReentrant {

        Call storage call = calls[_c];
        require(msg.sender == call.long, "c: only long can cancel a bid");
        require(!call.open, "c: call already open");
        require(!call.exercised, "c: call already exercised");
        require(call.short == address(0x0), "c: this is not a new bid");
        call.tradeable = false;
        call.exercised = true;
        withdrawPymt(pymtWeth, pymtCurrency, call.long, call.price);
        emit OptionCancelled(_c);
    }

    
    function sellOpenOptionToNewBid(uint _c, uint _d, uint _price) payable external nonReentrant {

        Call storage openCall = calls[_c];
        Call storage newBid = calls[_d];
        require(_c != _d, "c: wrong sale function");
        require(_price == newBid.price, "c: price changed before you could execute");
        require(msg.sender == openCall.long, "c: you dont own this");
        require(openCall.strike == newBid.strike, "c: not the right strike");
        require(openCall.assetAmt == newBid.assetAmt, "c: not the right assetAmt");
        require(openCall.expiry == newBid.expiry, "c: not the right expiry");
        require(newBid.short == address(0x0), "c: this is not a new bid"); //newBid always sets the short address to 0x0
        require(openCall.open && !newBid.open && newBid.tradeable && !openCall.exercised && !newBid.exercised && openCall.expiry > now && newBid.expiry > now, "something is wrong");
        newBid.exercised = true;
        newBid.tradeable = false;
        uint feePymt = (newBid.price * fee).div(1e4);
        uint shortPymt = newBid.price.sub(feePymt);
        withdrawPymt(pymtWeth, pymtCurrency, openCall.long, shortPymt);
        if (feePymt > 0) SafeERC20.safeTransfer(IERC20(pymtCurrency), feeCollector, feePymt);
        openCall.long = newBid.long;
        openCall.price = newBid.price;
        openCall.tradeable = false;
        emit OpenOptionSold( _c, _d, openCall.long, _price);
    }

    function sellNewOption(uint _c, uint _assetAmt, uint _strike, uint _price, uint _expiry) payable external nonReentrant {

        Call storage call = calls[_c];
        require(call.strike == _strike && call.assetAmt == _assetAmt && call.price == _price && call.expiry == _expiry, "c details issue");
        require(call.short == address(0x0));
        require(msg.sender != call.long, "c: you are the long");
        require(call.expiry > now, "c: This is already expired");
        require(call.tradeable, "c: not tradeable");
        require(!call.open, "c: call already open");
        require(!call.exercised, "c: this has been exercised");
        uint feePymt = (call.price * fee).div(1e4);
        uint shortPymt = (call.price).sub(feePymt);
        uint balCheck = assetWeth ? msg.value : IERC20(asset).balanceOf(msg.sender);
        require(balCheck >= call.assetAmt, "c: not enough cash to bid");
        depositPymt(assetWeth, asset, msg.sender, call.assetAmt);
        if (feePymt > 0) SafeERC20.safeTransfer(IERC20(pymtCurrency), feeCollector, feePymt);
        withdrawPymt(pymtWeth, pymtCurrency, msg.sender, shortPymt);
        call.short = msg.sender;
        call.tradeable = false;
        call.open = true;
        emit NewOptionSold(_c, msg.sender);
    }

    
    function changeNewOption(uint _c, uint _assetAmt, uint _minimumPurchase, uint _strike, uint _price, uint _expiry) payable external nonReentrant {

        Call storage call = calls[_c];
        require(call.long == msg.sender, "c: dont own");
        require(!call.exercised, "c: exercised");
        require(!call.open, "c: open");
        require(call.tradeable, "c: !tradeable");
        uint _totalPurch = _assetAmt.mul(_strike).div(10 ** assetDecimals);
        require(_totalPurch > 0, "c: totalPurchase err");
        if (msg.sender == call.short) {
            require(_minimumPurchase.mul(_strike).div(10 ** assetDecimals) > 0, "c: min error");
            require(_assetAmt % _minimumPurchase == 0, "c: mod error");
            uint refund = (call.assetAmt > _assetAmt) ? call.assetAmt.sub(_assetAmt) : _assetAmt.sub(call.assetAmt);
            call.strike = _strike;
            call.price = _price;
            call.expiry = _expiry;
            call.minimumPurchase = _minimumPurchase;
            call.totalPurch = _totalPurch;
            call.tradeable = true;
            if (call.assetAmt > _assetAmt) {
                call.assetAmt = _assetAmt;
                withdrawPymt(assetWeth, asset, call.short, refund);
            } else if (call.assetAmt < _assetAmt) {
                call.assetAmt = _assetAmt;
                uint balCheck = assetWeth ? msg.value : IERC20(asset).balanceOf(msg.sender);
                require(balCheck >= refund, "c: short change");
                depositPymt(assetWeth, asset, msg.sender, refund);
            }
            
            emit OptionChanged(_c, _assetAmt, _minimumPurchase, _strike, _price, _expiry);

        } else if (call.short == address(0x0)) {
            uint refund = (_price > call.price) ? _price.sub(call.price) : call.price.sub(_price);
            call.assetAmt = _assetAmt;
            call.minimumPurchase = _assetAmt;
            call.strike = _strike;
            call.expiry = _expiry;
            call.totalPurch = _totalPurch;
            call.tradeable = true;
            if (_price > call.price) {
                call.price = _price;
                uint balCheck = pymtWeth ? msg.value : IERC20(pymtCurrency).balanceOf(msg.sender);
                require(balCheck >= refund, "c: not enough cash to bid");
                depositPymt(pymtWeth, pymtCurrency, msg.sender, refund);
            } else if (_price < call.price) {
                call.price = _price;
                withdrawPymt(pymtWeth, pymtCurrency, call.long, refund);
            }
            
            emit OptionChanged(_c, _assetAmt, _minimumPurchase, _strike, _price, _expiry);    
        }
           
    } 
    

    function newAsk(uint _assetAmt, uint _minimumPurchase, uint _strike, uint _price, uint _expiry) payable external {

        uint _totalPurch = _assetAmt.mul(_strike).div(10 ** assetDecimals);
        require(_totalPurch > 0, "c: totalPurchase error: too small amount");
        require(_minimumPurchase.mul(_strike).div(10 ** assetDecimals) > 0, "c: minimum purchase error, too small of a min");
        require(_assetAmt % _minimumPurchase == 0, "c: asset amount needs to be a multiple of the minimum");
        uint balCheck = assetWeth ? msg.value : IERC20(asset).balanceOf(msg.sender);
        require(balCheck >= _assetAmt, "c: not enough to sell this call option");
        depositPymt(assetWeth, asset, msg.sender, _assetAmt);
        calls[c++] = Call(msg.sender, _assetAmt, _minimumPurchase, _strike, _totalPurch, _price, _expiry, false, true, msg.sender, false);
        emit NewAsk(c.sub(1), msg.sender, _assetAmt, _minimumPurchase, _strike, _price, _expiry);
    }


    function cancelNewAsk(uint _c) external nonReentrant {

        Call storage call = calls[_c];
        require(msg.sender == call.short && msg.sender == call.long, "c: only short can change an ask");
        require(!call.open, "c: call already open");
        require(!call.exercised, "c: call already exercised");
        call.tradeable = false;
        call.exercised = true;
        withdrawPymt(assetWeth, asset, call.short, call.assetAmt);
        emit OptionCancelled(_c);
    }
    
    function buyNewOption(uint _c, uint _assetAmt, uint _strike, uint _price, uint _expiry) payable external {

        Call storage call = calls[_c];
        require(call.strike == _strike && call.expiry == _expiry, "c details issue: something changed");
        require(msg.sender != call.short, "c: you cannot buy this");
        require(call.short != address(0x0) && call.short == call.long, "c: this option is not a new ask");
        require(call.expiry > now, "c: This call is already expired");
        require(!call.exercised, "c: This has already been exercised");
        require(call.tradeable, "c: This isnt tradeable yet");
        require(!call.open, "c: This call is already open");
        require(_assetAmt >= call.minimumPurchase, "purchase size does not meet minimum");
        if (_assetAmt == call.assetAmt) {
            require(_price == call.price, "c: price does not match");
            uint balCheck = pymtWeth ? msg.value : IERC20(pymtCurrency).balanceOf(msg.sender);
            require(balCheck >= call.price, "c: not enough to sell this call option");
            transferPymtWithFee(pymtWeth, pymtCurrency, msg.sender, call.short, _price);
            call.open = true;
            call.long = msg.sender;
            call.tradeable = false;
            emit NewOptionBought(_c, msg.sender);
        } else {
            uint pricePerToken = call.price.mul(10 ** 32).div(call.assetAmt);
            uint proRataPrice = _assetAmt.mul(pricePerToken).div(10 ** 32);
            require(_price == proRataPrice, "c: price doesnt match pro rata price");
            require(call.assetAmt.sub(_assetAmt) >= call.minimumPurchase, "c: remainder too small");
            uint balCheck = pymtWeth ? msg.value : IERC20(pymtCurrency).balanceOf(msg.sender);
            require(balCheck >= proRataPrice, "c: not enough to sell this call option");
            uint proRataTotalPurchase = _assetAmt.mul(_strike).div(10 ** assetDecimals);
            transferPymtWithFee(pymtWeth, pymtCurrency, msg.sender, call.short, proRataPrice);
            calls[c++] = Call(call.short, _assetAmt, call.minimumPurchase, call.strike, proRataTotalPurchase, _price, _expiry, true, false, msg.sender, false);
            emit PoolOptionBought(_c, c.sub(1), msg.sender, _assetAmt, _strike, _price, _expiry);
            call.assetAmt -= _assetAmt;
            call.price -= _price;
            call.totalPurch = call.assetAmt.mul(_strike).div(10 ** assetDecimals);
            
        }
        
    }
    
    

    
    function buyOptionFromAsk(uint _c, uint _d, uint _price) payable external nonReentrant {

        Call storage openShort = calls[_c];
        Call storage ask = calls[_d];
        require(msg.sender == openShort.short, "c: your not the short");
        require(ask.short != address(0x0), "c: this is a newBid");
        require(_price == ask.price, "c: price changed before executed");
        require(ask.tradeable && !ask.exercised && ask.expiry > now,"c: ask issue");
        require(openShort.open && !openShort.exercised && openShort.expiry > now, "c: short issue");
        require(openShort.strike == ask.strike, "c: strikes do not match");
        require(openShort.assetAmt == ask.assetAmt, "c: asset amount does not match");
        require(openShort.expiry == ask.expiry, "c: expiry does not match");
        require(_c != _d, "c: wrong function to buyback");
        uint balCheck = pymtWeth ? msg.value : IERC20(pymtCurrency).balanceOf(msg.sender);
        require(balCheck >= ask.price, "c: not enough to buy this put");
        transferPymtWithFee(pymtWeth, pymtCurrency, openShort.short, ask.long, _price); //if newAsk then ask.long == ask.short, if openAsk then ask.long is the one receiving the payment
        ask.exercised = true;
        ask.tradeable = false;
        ask.open = false;
        withdrawPymt(assetWeth, asset, openShort.short, openShort.assetAmt);
        openShort.short = ask.short;
        emit OpenShortRePurchased( _c, _d, openShort.short, _price);
    }
    


    function setPrice(uint _c, uint _price, bool _tradeable) external {

        Call storage call = calls[_c];
        require((msg.sender == call.long && msg.sender == call.short && _tradeable) || (msg.sender == call.long && call.open), "c: you cant change the price");
        require(call.expiry > now, "c: already expired");
        require(!call.exercised, "c: already expired");
        call.price = _price; 
        call.tradeable = _tradeable;
        emit PriceSet(_c, _price, _tradeable);
    }



    function buyOpenOption(uint _c, uint _assetAmt, uint _strike, uint _price, uint _expiry) payable external nonReentrant {

        Call storage call = calls[_c];
        require(call.strike == _strike && call.assetAmt == _assetAmt && call.price == _price && call.expiry == _expiry);
        require(msg.sender != call.long);
        require(call.open);
        require(call.expiry >= now);
        require(!call.exercised);
        require(call.tradeable);
        uint balCheck = pymtWeth ? msg.value : IERC20(pymtCurrency).balanceOf(msg.sender);
        require(balCheck >= call.price);
        transferPymtWithFee(pymtWeth, pymtCurrency, msg.sender, call.long, call.price);
        if (msg.sender == call.short) {
            call.exercised = true;
            call.open = false;
            withdrawPymt(assetWeth, asset, call.short, call.assetAmt);
        }
        call.tradeable = false;
        call.long = msg.sender;
        emit OpenOptionPurchased(_c, msg.sender);
    }


    function exercise(uint _c) payable external nonReentrant {

        Call storage call = calls[_c];
        require(call.open);
        require(call.expiry >= now);
        require(!call.exercised);
        require(msg.sender == call.long);
        uint balCheck = pymtWeth ? msg.value : IERC20(pymtCurrency).balanceOf(msg.sender);
        require(balCheck >= call.totalPurch);
        call.exercised = true;
        call.open = false;
        call.tradeable = false;
        if(pymtWeth) {
            require(msg.value == call.totalPurch);
        }
        transferPymt(pymtWeth, pymtCurrency, msg.sender, call.short, call.totalPurch);   
        withdrawPymt(assetWeth, asset, call.long, call.assetAmt);
        emit OptionExercised(_c, false);
    }


    function cashClose(uint _c, bool cashBack) payable external nonReentrant {

        require(cashCloseOn);
        Call storage call = calls[_c];
        require(call.open);
        require(call.expiry >= now);
        require(!call.exercised);
        require(msg.sender == call.long);
   
        uint assetIn = estIn(call.totalPurch);
        require(assetIn < (call.assetAmt), "c: Underlying is not in the money");
        
        address to = pymtWeth ? address(this) : call.short;
        call.exercised = true;
        call.open = false;
        call.tradeable = false;
        swap(asset, call.totalPurch, assetIn, to);
        if (pymtWeth) {
            withdrawPymt(pymtWeth, pymtCurrency, call.short, call.totalPurch);
        }
        
        call.assetAmt -= assetIn;
        
        if (cashBack) {
            
            uint cashEst = estCashOut(call.assetAmt);
            address _to = pymtWeth ? address(this) : call.long;
            swap(asset, cashEst, call.assetAmt, _to);
            if (pymtWeth) {
                withdrawPymt(pymtWeth, pymtCurrency, call.long, cashEst); 
            }
        } else {
            withdrawPymt(assetWeth, asset, call.long, call.assetAmt);
        }
        
        emit OptionExercised(_c, true);
    }


    

    function returnExpired(uint[] memory _calls) external nonReentrant {

        uint _totalAssetAmount;
        for (uint i; i < _calls.length; i++) {
            Call storage call = calls[_calls[i]];
            require(!call.exercised && call.expiry < now && msg.sender == call.short);
            call.exercised = true;
            call.open = false;
            call.tradeable = false;
            _totalAssetAmount += call.assetAmt;
            emit OptionReturned(_calls[i]);
        }
        withdrawPymt(assetWeth, asset, msg.sender, _totalAssetAmount);
        
    }
    
    
    
    function rollExpired(uint[] memory _calls, uint _assetAmount, uint _minimumPurchase, uint _newStrike, uint _newPrice, uint _newExpiry) payable external {

        uint _totalAssetAmount;
        for (uint i; i < _calls.length; i++) {
            Call storage call = calls[_calls[i]];
            require(!call.exercised && call.expiry < now && msg.sender == call.short);
            call.exercised = true;
            call.open = false;
            call.tradeable = false;
            _totalAssetAmount += call.assetAmt;
            emit OptionReturned(_calls[i]);
        }
        require(_assetAmount % _minimumPurchase == 0 && _assetAmount >= _totalAssetAmount);
        uint _totalPurch = (_assetAmount).mul(_newStrike).div(10 ** assetDecimals);
        require(_totalPurch > 0 && _minimumPurchase.mul(_newStrike).div(10 ** assetDecimals) > 0);
        require(_newExpiry > block.timestamp);
        if (_assetAmount > _totalAssetAmount) {
            uint balCheck = assetWeth ? msg.value : IERC20(pymtCurrency).balanceOf(msg.sender);
            require(balCheck >= _assetAmount.sub(_totalAssetAmount));
            depositPymt(assetWeth, asset, msg.sender, _assetAmount.sub(_totalAssetAmount));
        }
        calls[c++] = Call(msg.sender, _assetAmount, _minimumPurchase, _newStrike, _totalPurch, _newPrice, _newExpiry, false, true, msg.sender, false);
        emit NewAsk(c.sub(1), msg.sender, _assetAmount, _minimumPurchase, _newStrike, _newPrice, _newExpiry);
    }
    
    
   
    
    

    
    
    function transferAndSwap(uint _c, address payable newOwner, address[] memory path, bool cashBack) external {

        Call storage call = calls[_c];
        require(call.expiry >= block.timestamp);
        require(!call.exercised);
        require(call.open);
        require(msg.sender == call.long);
        require(newOwner != call.short);
        require(!Address.isContract(newOwner) || path.length > 1);
        call.long = newOwner; //set long to new owner
        if (path.length > 1) {
            require(IHedgeyFactory(hedgeyFactory).isSwapper(newOwner)); //only whitelisted swapper addresses allowed
            require(path[0] == asset && path[path.length - 1] == pymtCurrency);
            IHedgeySwap(newOwner).hedgeyCallSwap(msg.sender, _c, call.totalPurch, path, cashBack);
        }
        
        emit OptionTransferred(_c, newOwner);
    }

    function swap(address token, uint out, uint _in, address to) internal {

        SafeERC20.safeTransfer(IERC20(token), uniPair, _in); //sends the asset amount in to the swap
        address token0 = IUniswapV2Pair(uniPair).token0();
        if (token == token0) {
            IUniswapV2Pair(uniPair).swap(0, out, to, new bytes(0));
        } else {
            IUniswapV2Pair(uniPair).swap(out, 0, to, new bytes(0));
        }
        
    }
    
    function estCashOut(uint amountIn) public view returns (uint amountOut) {

        (uint resA, uint resB,) = IUniswapV2Pair(uniPair).getReserves();
        address token1 = IUniswapV2Pair(uniPair).token1();
        amountOut = (token1 == pymtCurrency) ? UniswapV2Library.getAmountOut(amountIn, resA, resB) : UniswapV2Library.getAmountOut(amountIn, resB, resA);
    }

    function estIn(uint amountOut) public view returns (uint amountIn) {

        (uint resA, uint resB,) = IUniswapV2Pair(uniPair).getReserves();
        address token1 = IUniswapV2Pair(uniPair).token1();
        amountIn = (token1 == pymtCurrency) ? UniswapV2Library.getAmountIn(amountOut, resA, resB) : UniswapV2Library.getAmountIn(amountOut, resB, resA);
    }
    

    event NewBid(uint _i, address _long, uint _assetAmt, uint _minimumPurchase, uint _strike, uint _price, uint _expiry);
    event NewAsk(uint _i, address _long, uint _assetAmt, uint _minimumPurchase, uint _strike, uint _price, uint _expiry);
    event NewOptionSold(uint _i, address _short);
    event NewOptionBought(uint _i, address _long);
    event OpenOptionSold(uint _i, uint _j, address _long, uint _price);
    event OpenShortRePurchased(uint _i, uint _j, address _short, uint _price);
    event OpenOptionPurchased(uint _i, address _long);
    event OptionChanged(uint _i, uint _assetAmt, uint _minimumPurchase, uint _strike, uint _price, uint _expiry);
    event PriceSet(uint _i, uint _price, bool _tradeable);
    event OptionExercised(uint _i, bool _cashClosed);
    event OptionReturned(uint _i);
    event OptionCancelled(uint _i);
    event OptionTransferred(uint _i, address _newOwner);
    event PoolOptionBought(uint _i, uint _j, address _long, uint _assetAmt, uint _strike, uint _price, uint _expiry);
    event AMMUpdate(bool _cashCloseOn);
}


contract HedgeyCallsFactory {

    
    mapping(address => mapping(address => address)) public pairs;
    address payable public collector;
    uint public fee;
    mapping(address => bool) private swappers;
    
    

    constructor (address payable _collector, uint _fee) public {
        collector = _collector;
        fee = _fee;
       
    }
    
    function addSwapper(address swapper) external {

        require(msg.sender == collector, "youre not the collector");
        swappers[swapper] = true;
    }

    function isSwapper(address swapper) external view returns (bool check) {

        check = swappers[swapper];
    }
    
    
    function changeFee(uint _newFee, address payable _collector) external {

        require(msg.sender == collector, "youre not the collector");
        fee = _newFee;
        collector = _collector;
    }
    
    
    function getPair(address asset, address pymtCurrency) external view returns (address pair) {

        pair = pairs[asset][pymtCurrency];
    }
   
    
    function createContract(address asset, address pymtCurrency) external {

        require(asset != pymtCurrency, "same currencies");
        require(pairs[asset][pymtCurrency] == address(0), "contract exists");
        HedgeyCalls callContract = new HedgeyCalls(asset, pymtCurrency, collector, fee);
        pairs[asset][pymtCurrency] = address(callContract);
        emit NewPairCreated(asset, pymtCurrency, address(callContract));
    }

    event NewPairCreated(address _asset, address _pymtCurrency, address _pair);
}