




interface ICOREGlobals {

    function CORETokenAddress() external view returns (address);

    function COREGlobalsAddress() external view returns (address);

    function COREDelegatorAddress() external view returns (address);

    function COREVaultAddress() external returns (address);

    function COREWETHUniPair() external view returns (address);

    function UniswapFactory() external view returns (address);

    function TransferHandler() external view returns (address);

    function addDelegatorStateChangePermission(address that, bool status) external;

    function isStateChangeApprovedContract(address that)  external view returns (bool);

}


pragma solidity >=0.5.0;

interface IWETH {

    function deposit() external payable;

    function transfer(address to, uint value) external returns (bool);

    function withdraw(uint) external;

}


pragma solidity >=0.4.24 <0.7.0;


contract Initializable {


  bool private initialized;

  bool private initializing;

  modifier initializer() {

    require(initializing || isConstructor() || !initialized, "Contract instance has already been initialized");

    bool isTopLevelCall = !initializing;
    if (isTopLevelCall) {
      initializing = true;
      initialized = true;
    }

    _;

    if (isTopLevelCall) {
      initializing = false;
    }
  }

  function isConstructor() private view returns (bool) {

    address self = address(this);
    uint256 cs;
    assembly { cs := extcodesize(self) }
    return cs == 0;
  }

  uint256[50] private ______gap;
}


pragma solidity ^0.6.0;


contract ContextUpgradeSafe is Initializable {


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
}


pragma solidity ^0.6.0;


contract OwnableUpgradeSafe is Initializable, ContextUpgradeSafe {

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

    uint256[49] private __gap;
}


pragma solidity ^0.6.0;


contract ReentrancyGuardUpgradeSafe is Initializable {

    bool private _notEntered;


    function __ReentrancyGuard_init() internal initializer {

        __ReentrancyGuard_init_unchained();
    }

    function __ReentrancyGuard_init_unchained() internal initializer {



        _notEntered = true;

    }


    modifier nonReentrant() {

        require(_notEntered, "ReentrancyGuard: reentrant call");

        _notEntered = false;

        _;

        _notEntered = true;
    }

    uint256[49] private __gap;
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


pragma solidity >=0.5.0;

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


pragma solidity >=0.5.0;

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


pragma solidity ^0.6.0;


interface ICoreVault {

    function devaddr() external returns (address);

    function addPendingRewards(uint _amount) external;

}

pragma solidity 0.6.12;













library COREIUniswapV2Library {

    
    using SafeMath for uint256;

    function sortTokens(address tokenA, address tokenB) internal pure returns (address token0, address token1) {

        require(tokenA != tokenB, 'IUniswapV2Library: IDENTICAL_ADDRESSES');
        (token0, token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        require(token0 != address(0), 'IUniswapV2Library: ZERO_ADDRESS');
    }

    function getAmountOut(uint256 amountIn, uint256 reserveIn, uint256 reserveOut) internal  returns (uint256 amountOut) {

        require(amountIn > 0, 'UniswapV2Library: INSUFFICIENT_INPUT_AMOUNT');
        require(reserveIn > 0 && reserveOut > 0, 'UniswapV2Library: INSUFFICIENT_LIQUIDITY');
        uint amountInWithFee = amountIn.mul(997);

        uint numerator = amountInWithFee.mul(reserveOut);
        uint denominator = reserveIn.mul(1000).add(amountInWithFee);

        amountOut = numerator / denominator;
    }

}


interface ICOREVault {

    function depositFor(address, uint256 , uint256 ) external;

}


interface IERC95 {

    function wrapAtomic(address) external;

    function transfer(address, uint256) external returns (bool);

    function balanceOf(address) external view returns (uint256);

    function skim(address to) external;

    function unpauseTransfers() external;


}

interface CERC95 {

    function wrapAtomic(address) external;

    function transfer(address, uint256) external returns (bool);

    function balanceOf(address) external view returns (uint256);

    function skim(address to) external;

    function name() external view returns (string memory);

}


interface ICORETransferHandler {

    function sync(address) external returns(bool,bool);

}

contract cLGE is Initializable, OwnableUpgradeSafe, ReentrancyGuardUpgradeSafe {


    using SafeMath for uint256;


    
    IERC20 public tokenBeingWrapped;
    address public coreEthPair;
    address public wrappedToken;
    address public preWrapEthPair;
    address public COREToken;
    address public _WETH;
    address public wrappedTokenUniswapPair;
    address public uniswapFactory;

    uint256 public totalETHContributed;
    uint256 public totalCOREContributed;
    uint256 public totalWrapTokenContributed;



    uint256 private wrappedTokenBalance;
    uint256 private COREBalance;

    uint256 public totalCOREToRefund; // This is in case there is too much CORE in the contract we refund people who contributed CORE proportionally
    uint256 public totalLPCreated;    
    uint256 private totalUnitsContributed;
    uint256 public LPPerUnitContributed; // stored as 1e18 more - this is done for change


    event Contibution(uint256 COREvalue, address from);
    event COREBought(uint256 COREamt, address from);

    mapping (address => uint256) public COREContributed; // We take each persons core contributed to calculate units and 
    mapping (address => uint256) public unitsContributed; // unit to keep track how much each person should get of LP
    mapping (address => uint256) public unitsClaimed; 
    mapping (address => bool) public CORERefundClaimed; 
    mapping (address => address) public pairWithWETHAddressForToken; 

    mapping (address => uint256) public wrappedTokenContributed; // To calculate units
    ICOREGlobals public coreGlobals;
    bool public LGEStarted;
    uint256 public contractStartTimestamp;
    uint256 public LGEDurationDays;
    bool public LGEFinished;

    function initialize(uint256 daysLong, address _wrappedToken, address _coreGlobals, address _preWrapEthPair) public initializer {

        require(msg.sender == address(0x5A16552f59ea34E44ec81E58b3817833E9fD5436));
        OwnableUpgradeSafe.__Ownable_init();
        ReentrancyGuardUpgradeSafe.__ReentrancyGuard_init();

        contractStartTimestamp = uint256(-1); // wet set it here to max so checks fail
        LGEDurationDays = daysLong.mul(1 days);
        coreGlobals = ICOREGlobals(_coreGlobals);
        coreEthPair = coreETHPairGetter();
        (COREToken, _WETH) = (IUniswapV2Pair(coreEthPair).token0(), IUniswapV2Pair(coreEthPair).token1()); // bb
        address tokenBeingWrappedAddress = IUniswapV2Pair(_preWrapEthPair).token1(); // bb
        tokenBeingWrapped =  IERC20(tokenBeingWrappedAddress);

        pairWithWETHAddressForToken[address(tokenBeingWrapped)] = _preWrapEthPair;
        pairWithWETHAddressForToken[IUniswapV2Pair(coreEthPair).token0()] = coreEthPair;// bb 


        wrappedToken = _wrappedToken;
        preWrapEthPair = _preWrapEthPair;
        uniswapFactory = coreGlobals.UniswapFactory();
    }


    function setTokenBeingWrapped(address token, address tokenPairWithWETH) public onlyOwner {

        tokenBeingWrapped = IERC20(token);
        pairWithWETHAddressForToken[token] = tokenPairWithWETH;
    }
    
    function startLGE() public onlyOwner {

        require(LGEStarted == false, "Already started");
        contractStartTimestamp = block.timestamp;
        LGEStarted = true;

        updateRunningAverages();
    }
    
    function isLGEOver() public view returns (bool) {

        return block.timestamp > contractStartTimestamp.add(LGEDurationDays);
    }
    
    function claimLP() nonReentrant public {

        IUniswapV2Pair(wrappedTokenUniswapPair).transfer(msg.sender, _claimLP());
    }

    function claimAndStakeLP() nonReentrant public {

        address vault = coreGlobals.COREVaultAddress();

        IUniswapV2Pair(wrappedTokenUniswapPair).approve(vault, uint(-1));
    
        ICOREVault(vault).depositFor(msg.sender,1, _claimLP());
    }


    function _claimLP() internal returns (uint256 sentAmt){ 

        require(LGEFinished == true, "LGE : Liquidity generation not finished");
        require(unitsContributed[msg.sender].sub(unitsClaimed[msg.sender]) > 0, "LEG : Nothing to claim");
        sentAmt = unitsContributed[msg.sender].sub(getCORERefundForPerson(msg.sender)).mul(LPPerUnitContributed).div(1e18);


        unitsClaimed[msg.sender] = unitsContributed[msg.sender];
    }

    function buyToken(address tokenTarget, uint256 amtToken, address tokenSwapping, uint256 amtTokenSwappingInput, address pair) internal {

        (address token0, address token1) = COREIUniswapV2Library.sortTokens(tokenSwapping, tokenTarget);
        IERC20(tokenSwapping).transfer(pair, amtTokenSwappingInput); 
        if(tokenTarget == token0) {
             IUniswapV2Pair(pair).swap(amtToken, 0, address(this), "");
        }
        else {
            IUniswapV2Pair(pair).swap(0, amtToken, address(this), "");
        }

        if(tokenTarget == COREToken){
            emit COREBought(amtToken, msg.sender);
        }
        
        updateRunningAverages();
    }

    function updateRunningAverages() internal{

         if(_averagePrices[address(tokenBeingWrapped)].lastBlockOfIncrement != block.number) {
            _averagePrices[address(tokenBeingWrapped)].lastBlockOfIncrement = block.number;
            updateRunningAveragePrice(address(tokenBeingWrapped), false);
          }
         if(_averagePrices[COREToken].lastBlockOfIncrement != block.number) {
            _averagePrices[COREToken].lastBlockOfIncrement = block.number;
            updateRunningAveragePrice(COREToken, false);
         }
    }


    function coreETHPairGetter() public view returns (address) {

        return coreGlobals.COREWETHUniPair();
    }


    function getPairReserves(address pair) internal view returns (uint256 wethReserves, uint256 tokenReserves) {

        address token0 = IUniswapV2Pair(pair).token0();
        (uint256 reserve0, uint reserve1,) = IUniswapV2Pair(pair).getReserves();
        (wethReserves, tokenReserves) = token0 == _WETH ? (reserve0, reserve1) : (reserve1, reserve0);
    }

    function finalizeTokenWrapAddress(address _wrappedToken) onlyOwner public {

        wrappedToken = _wrappedToken;
    }

    function safetyTokenWithdraw(address token) onlyOwner public {

        require(block.timestamp > contractStartTimestamp.add(LGEDurationDays).add(1 days));
        IERC20(token).transfer(msg.sender, IERC20(token).balanceOf(address(this)));
    }
    function safetyETHWithdraw() onlyOwner public {

        require(block.timestamp > contractStartTimestamp.add(LGEDurationDays).add(1 days));
        msg.sender.call.value(address(this).balance)("");
    }

    function extendLGE(uint numHours) public {

        require(msg.sender == 0xd5b47B80668840e7164C1D1d81aF8a9d9727B421 || msg.sender == 0xC91FE1ee441402D854B8F22F94Ddf66618169636, "LGE: Requires admin");
        require(numHours <= 24);
        LGEDurationDays = LGEDurationDays.add(numHours.mul(1 hours));
    }

    function addLiquidityAtomic() public {

        require(LGEStarted == true, "LGE Didn't start");
        require(LGEFinished == false, "LGE : Liquidity generation finished");
        require(isLGEOver() == false, "LGE is over.");


        if(IUniswapV2Pair(preWrapEthPair).balanceOf(address(this)) > 0) {
            unwrapLiquidityTokens();
        } else{
            ( uint256 tokenBeingWrappedPer1ETH, uint256 coreTokenPer1ETH) = getHowMuch1WETHBuysOfTokens();


            uint256 balWETH = IERC20(_WETH).balanceOf(address(this));

            uint256 totalCredit; // In core units

 

            uint256 tokenBeingWrappedBalNow = IERC20(tokenBeingWrapped).balanceOf(address(this));
            uint256 tokenBeingWrappedBalChange = tokenBeingWrappedBalNow.sub(wrappedTokenBalance);
            if(tokenBeingWrappedBalChange > 0) {
                totalWrapTokenContributed = totalWrapTokenContributed.add(tokenBeingWrappedBalChange);
      
                wrappedTokenContributed[msg.sender] = wrappedTokenContributed[msg.sender].add(tokenBeingWrappedBalChange);
                totalCredit =   handleTokenBeingWrappedLiquidityAddition(tokenBeingWrappedBalChange,tokenBeingWrappedPer1ETH,coreTokenPer1ETH) ;
                wrappedTokenBalance = IERC20(tokenBeingWrapped).balanceOf(address(this));
                COREBalance = IERC20(COREToken).balanceOf(address(this)); /// CHANGE

           }           
           
            if(balWETH > 0){
                totalETHContributed = totalETHContributed.add(balWETH);
                totalCredit = totalCredit.add( handleWETHLiquidityAddition(balWETH,tokenBeingWrappedPer1ETH,coreTokenPer1ETH) );
                COREBalance = IERC20(COREToken).balanceOf(address(this)); /// CHANGE
            }

            uint256 COREBalNow = IERC20(COREToken).balanceOf(address(this));
            uint256 balCOREChange = COREBalNow.sub(COREBalance);
            if(balCOREChange > 0) {
                COREContributed[msg.sender] = COREContributed[msg.sender].add(balCOREChange);
                totalCOREContributed = totalCOREContributed.add(balCOREChange);
            }
            COREBalance = COREBalNow;

            uint256 unitsChange = totalCredit.add(balCOREChange);
            unitsContributed[msg.sender] = unitsContributed[msg.sender].add(unitsChange);
            totalUnitsContributed = totalUnitsContributed.add(unitsChange);
            emit Contibution(totalCredit, msg.sender);
        
        }
    }

    function handleTokenBeingWrappedLiquidityAddition(uint256 amt,uint256 tokenBeingWrappedPer1ETH,uint256 coreTokenPer1ETH) internal  returns (uint256 coreUnitsCredit) {

        uint256 outWETH;
        (uint256 reserveWETHofWrappedTokenPair, uint256 reserveTokenofWrappedTokenPair) = getPairReserves(preWrapEthPair);

        if(COREBalance.div(coreTokenPer1ETH) <= wrappedTokenBalance.div(tokenBeingWrappedPer1ETH)) {
            outWETH = COREIUniswapV2Library.getAmountOut(amt, reserveTokenofWrappedTokenPair, reserveWETHofWrappedTokenPair);
            buyToken(_WETH, outWETH, address(tokenBeingWrapped) , amt, preWrapEthPair);
            (uint256 buyReserveWeth, uint256 reserveCore) = getPairReserves(coreEthPair);
            uint256 outCore = COREIUniswapV2Library.getAmountOut(outWETH, buyReserveWeth, reserveCore);
            buyToken(COREToken, outCore, _WETH ,outWETH,coreEthPair);
        } else {
            outWETH = COREIUniswapV2Library.getAmountOut(amt, reserveTokenofWrappedTokenPair , reserveWETHofWrappedTokenPair);
        }

        coreUnitsCredit = outWETH.mul(coreTokenPer1ETH).div(1e18);
    }

    function handleWETHLiquidityAddition(uint256 amt,uint256 tokenBeingWrappedPer1ETH,uint256 coreTokenPer1ETH) internal returns (uint256 coreUnitsCredit) {


        if(COREBalance.div(coreTokenPer1ETH) <= wrappedTokenBalance.div(tokenBeingWrappedPer1ETH)) {
            (uint256 reserveWeth, uint256 reserveCore) = getPairReserves(coreEthPair);
            uint256 outCore = COREIUniswapV2Library.getAmountOut(amt, reserveWeth, reserveCore);
            buyToken(COREToken, outCore,_WETH,amt, coreEthPair);

        } else {
            (uint256 reserveWeth, uint256 reserveToken) = getPairReserves(preWrapEthPair);
            uint256 outToken = COREIUniswapV2Library.getAmountOut(amt, reserveWeth, reserveToken);
            buyToken(address(tokenBeingWrapped), outToken,_WETH, amt,preWrapEthPair);
            wrappedTokenBalance = IERC20(tokenBeingWrapped).balanceOf(address(this));


            wrappedTokenContributed[msg.sender] = wrappedTokenContributed[msg.sender].add(outToken);
        }
        coreUnitsCredit = amt.mul(coreTokenPer1ETH).div(1e18);

    }



    function getHowMuch1WETHBuysOfTokens() public view returns (uint256 tokenBeingWrappedPer1ETH, uint256 coreTokenPer1ETH) {

        return (getAveragePriceLast20Blocks(address(tokenBeingWrapped)), getAveragePriceLast20Blocks(COREToken));
    }


    fallback() external payable {
        if(msg.sender != _WETH) {
             addLiquidityETH();
        }
    }

    function addLiquidityETH() nonReentrant public payable {

        IWETH(_WETH).deposit{value: msg.value}();
        addLiquidityAtomic();
    }

    function addLiquidityWithTokenWithAllowance(address token, uint256 amount) public nonReentrant {

        IERC20(token).transferFrom(msg.sender, address(this), amount);
        addLiquidityAtomic();
    }   

    function unwrapLiquidityTokens() internal {

        IUniswapV2Pair pair = IUniswapV2Pair(preWrapEthPair);
        pair.transfer(preWrapEthPair, pair.balanceOf(address(this)));
        pair.burn(address(this));
        addLiquidityAtomic();
    }




    mapping(address => PriceAverage) _averagePrices;
    struct PriceAverage{
       uint8 lastAddedHead;
       uint256[20] price;
       uint256 cumulativeLast20Blocks;
       bool arrayFull;
       uint lastBlockOfIncrement; // Just update once per block ( by buy token function )
    }

    function getAveragePriceLast20Blocks(address token) public view returns (uint256){


       return _averagePrices[token].cumulativeLast20Blocks.div(_averagePrices[token].arrayFull ? 20 : _averagePrices[token].lastAddedHead);
    }


    function updateRunningAveragePrice(address token, bool isRescue) public returns (uint256) {

        PriceAverage storage currentAveragePrices =  _averagePrices[token];
        address pairWithWETH = pairWithWETHAddressForToken[token];
        (uint256 wethReserves, uint256 tokenReserves) = getPairReserves(address(pairWithWETH));
        uint256 outTokenFor1WETH = COREIUniswapV2Library.getAmountOut(1e18, wethReserves, tokenReserves);

        uint8 i = currentAveragePrices.lastAddedHead;
        
        uint256 lastQuote;
        if(i == 0) {
            lastQuote = currentAveragePrices.price[19];
        }
        else {
            lastQuote = currentAveragePrices.price[i - 1];
        }

        if(lastQuote != 0 && isRescue == false){
            require(outTokenFor1WETH < lastQuote.mul(15000).div(10000), "Change too big from previous price");
        }
        
        currentAveragePrices.cumulativeLast20Blocks = currentAveragePrices.cumulativeLast20Blocks.sub(currentAveragePrices.price[i]);
        currentAveragePrices.price[i] = outTokenFor1WETH;
        currentAveragePrices.cumulativeLast20Blocks = currentAveragePrices.cumulativeLast20Blocks.add(outTokenFor1WETH);
        currentAveragePrices.lastAddedHead++;
        if(currentAveragePrices.lastAddedHead > 19) {
            currentAveragePrices.lastAddedHead = 0;
            currentAveragePrices.arrayFull = true;
        }
        return currentAveragePrices.cumulativeLast20Blocks;
    }

    function rescueRatioLock(address token) public onlyOwner{

        updateRunningAveragePrice(token, true);
    }



    function addLiquidityToPairPublic() nonReentrant public{

        addLiquidityToPair(true,0,0);
    }

    function getUnitsContributedPerFenny(uint256 amt) internal pure returns (uint256 units){

        units = amt.mul(1e18).div(14000);
    }

    bool public LPmismatchCredited;
    function matchCreditFromLPContributionBug() onlyOwner public {

        require(LPmismatchCredited == false , "Already refunded");
        addUnitsContributed(0x6996C784cdA7a2841C3a6F579C896477586A1D9A, 15_219);
        addUnitsContributed(0x38Bc5196d8b21782372a843E5A505d9F457e6ff8, 7_280);
        addUnitsContributed(0x91a90ACd8791ABB4c07c69aBBca82822c3451584, 249);
        addUnitsContributed(0x4523b791292da89A9194B61bA4CD9d98f2af68E0, 109_647);
        addUnitsContributed(0xD2FA59811af055e0e94D570EA7F9800c0E5C0428, 151);
        addUnitsContributed(0xeeBa4a8f5b27D7d7c91cF4D4A716FbA042850f9A, 220);
        addUnitsContributed(0x2eACd09e92273D5fb86Cf40504917F664EE15Da8, 11_999);
        addUnitsContributed(0xbbAb2ca3dF54726D3F484aFFf85708C0075a4400, 289);
        addUnitsContributed(0xC8D76B1Ae76bdE393ef4CD495502D18326623ec5, 123_992);
        addUnitsContributed(0x882E11F884E9d221706DB9A36bA4856292b26d87, 1_399);
        addUnitsContributed(0xb0e7C2319993C00B9430d18bDd9f98Fefb6B5857, 250);
        addUnitsContributed(0x41AFc9c6414FE7C4AbBc9977B07E5C5e62F7938A ,1_147);
        addUnitsContributed(0x3E4D97C22571C5Ff22f0DAaBDa2d3835E67738EB, 5_129);
        addUnitsContributed(0x5924544A57e26b52231597aaa5E0374748C0a127, 2_056);
        addUnitsContributed(0xa26f824aE181cD3893D77D0ACd2Fb7afc225e07e, 4_984);
        addUnitsContributed(0x821fC6A963b94920c57966A31BA1cF9b7569Dd30, 9_645);
        addUnitsContributed(0x09cC473b67696F31A8536D43C7CF4B32Ade588C8, 299);
        addUnitsContributed(0x67593A4F0c1e290eaE66459eE160A82945a5886f, 268);
        addUnitsContributed(0x2aCFd4D5EBbC9803Ee5B6BA190BA41B8b3e6A29d, 1_097);
        addUnitsContributed(0xEd037d27846A6a7943B7b33AeBA526cd95Bd95Ce, 7_644);
        addUnitsContributed(0xe39Bc99b80a9EFD0F14F82AEA1406Eee93D456F2, 860);
        addUnitsContributed(0xA467b35b756359F55BC26bA82BAfA83B9Fb720Ed, 92);
        addUnitsContributed(0x8261F215B09F6595A66C251625c24b6F52857195, 8_973);
        addUnitsContributed(0x3D3C3EEAc517B72670DB36cb7380cd18B929430b, 27_958);
        addUnitsContributed(0x27f5EB564BAEDb169C0c2d3a5ea1d25281D9a5e5, 36);
        addUnitsContributed(0x473bbC06D7fdB7713D1ED334F8D8096CaD6eC3f3, 3_865);
        addUnitsContributed(0x11ef72795691570b28277043d344D969f749A837, 120);
        addUnitsContributed(0x2836cFCc14d89Ccf0B0a980e5605f24Fa0A4a735, 1_253);
        addUnitsContributed(0x83d371D26FE57a17849F87B14717fbAd7C6B82A5, 499);
        addUnitsContributed(0xf172ee7B2b94b70f975E98E25044F82E6C29f996, 941);

        LPmismatchCredited = true;
    }

    function addUnitsContributed(address guy, uint256 amtFenny) internal {

        unitsContributed[guy] = unitsContributed[guy].add(getUnitsContributedPerFenny(amtFenny));
        totalUnitsContributed = totalUnitsContributed.add(getUnitsContributedPerFenny(amtFenny));
    }

    function addLiquidityToPairAdmin(uint256 ratio1ETHWholeBuysXCOREUnits, uint256 ratio1ETHWholeBuysXWrappedTokenUnits)
         nonReentrant onlyOwner public{

        addLiquidityToPair(false,ratio1ETHWholeBuysXCOREUnits, ratio1ETHWholeBuysXWrappedTokenUnits);
    }
    
    function getCORERefundForPerson(address guy) public view returns (uint256) {

        return COREContributed[guy].mul(1e12).div(totalCOREContributed).
            mul(totalCOREToRefund).div(1e12);
    }
    
    function getCOREREfund() nonReentrant public {

        require(LGEFinished == true, "LGE not finished");
        require(totalCOREToRefund > 0 , "No refunds");
        require(COREContributed[msg.sender] > 0, "You didn't contribute anything");
        require(CORERefundClaimed[msg.sender] == false , "You already claimed");
        
        uint256 COREToRefundToThisPerson = getCORERefundForPerson(msg.sender);
        CORERefundClaimed[msg.sender] = true;
        IERC20(COREToken).transfer(msg.sender,COREToRefundToThisPerson);
    }

    function notMoreThan4PercentDeltaFromCurrentPrice(address pair, uint256 amtOutPer1ETH) internal  {

        (uint256 reserveWETHofWrappedTokenPair, uint256 reserveTokenofWrappedTokenPair) = getPairReserves(pair);
        uint256 outTokenFor1WETH = COREIUniswapV2Library.getAmountOut(1e18, reserveWETHofWrappedTokenPair, reserveTokenofWrappedTokenPair);
        
        require(amtOutPer1ETH.mul(104) > outTokenFor1WETH.mul(100) 
                && outTokenFor1WETH.mul(96) <  amtOutPer1ETH.mul(100), 
                  "LGE : Delta of balances is too big from actual (4% or more)");
    }

    function addLiquidityToPair(bool publicCall, uint256 ratio1ETHWholeBuysXCOREUnits, uint256 ratio1ETHWholeBuysXWrappedTokenUnits)
     internal {

        require(block.timestamp > contractStartTimestamp.add(LGEDurationDays).add(publicCall ? 2 hours : 0), "LGE : Liquidity generation ongoing");
        require(LGEFinished == false, "LGE : Liquidity generation finished");
        
        IERC95(wrappedToken).unpauseTransfers();


        tokenBeingWrapped.transfer(wrappedToken, tokenBeingWrapped.balanceOf(address(this)));
        IERC95(wrappedToken).wrapAtomic(address(this));
        IERC95(wrappedToken).skim(address(this)); // In case

        wrappedTokenUniswapPair = IUniswapV2Factory(coreGlobals.UniswapFactory()).getPair(COREToken , wrappedToken);
        if(wrappedTokenUniswapPair == address(0)) { // Pair doesn't exist yet 
            wrappedTokenUniswapPair = IUniswapV2Factory(coreGlobals.UniswapFactory()).createPair(
                COREToken,
                wrappedToken
            );
        }

        uint256 DEV_FEE = 724; // TODO: DEV_FEE isn't public //ICoreVault(coreGlobals.COREVault).DEV_FEE();
        address devaddress = ICoreVault(coreGlobals.COREVaultAddress()).devaddr();
        IERC95(wrappedToken).transfer(devaddress, IERC95(wrappedToken).balanceOf(address(this)).mul(DEV_FEE).div(10000));
        IERC20(COREToken).transfer(devaddress, IERC20(COREToken).balanceOf(address(this)).mul(DEV_FEE).div(10000));

        uint256 balanceCORENow = IERC20(COREToken).balanceOf(address(this));
        uint256 balanceCOREWrappedTokenNow = IERC95(wrappedToken).balanceOf(address(this));

        ( uint256 tokenBeingWrappedPer1ETH, uint256 coreTokenPer1ETH)  = getHowMuch1WETHBuysOfTokens();

 

        if(publicCall == false){ // admin added ratio
            notMoreThan4PercentDeltaFromCurrentPrice(coreEthPair, ratio1ETHWholeBuysXCOREUnits);
            notMoreThan4PercentDeltaFromCurrentPrice(preWrapEthPair, ratio1ETHWholeBuysXWrappedTokenUnits);

            uint256 totalValueOfWrapper = balanceCOREWrappedTokenNow.div(ratio1ETHWholeBuysXWrappedTokenUnits).mul(1e18);
            uint256 totalValueOfCORE =  balanceCORENow.div(ratio1ETHWholeBuysXCOREUnits).mul(1e18);

            totalCOREToRefund = totalValueOfWrapper >= totalValueOfCORE ? 0 :
                totalValueOfCORE.sub(totalValueOfWrapper).mul(coreTokenPer1ETH).div(1e18);

            require(totalValueOfWrapper.mul(100) < totalValueOfCORE.mul(104), "Too much WBTC value ( max 4% deviation)");


        }else{
            notMoreThan4PercentDeltaFromCurrentPrice(preWrapEthPair, tokenBeingWrappedPer1ETH);
            notMoreThan4PercentDeltaFromCurrentPrice(coreEthPair, coreTokenPer1ETH);

            uint256 totalValueOfWrapper = balanceCOREWrappedTokenNow.div(tokenBeingWrappedPer1ETH).mul(1e18);
            uint256 totalValueOfCORE =  balanceCORENow.div(coreTokenPer1ETH).mul(1e18);

            totalCOREToRefund = totalValueOfWrapper >= totalValueOfCORE ? 0 :
                totalValueOfCORE.sub(totalValueOfWrapper).mul(coreTokenPer1ETH).div(1e18);

            require(totalValueOfWrapper.mul(100) < totalValueOfCORE.mul(104), "Too much WBTC value ( max 4% deviation)");
    
        }

  


        IERC95(wrappedToken).transfer(wrappedTokenUniswapPair, IERC95(wrappedToken).balanceOf(address(this)));

        IERC20(COREToken).transfer(wrappedTokenUniswapPair, balanceCORENow.sub(totalCOREToRefund));

        require(IUniswapV2Pair(wrappedTokenUniswapPair).totalSupply() == 0, "Somehow total supply is higher, sanity fail");
        IUniswapV2Pair(wrappedTokenUniswapPair).mint(address(this));

        totalLPCreated = IUniswapV2Pair(wrappedTokenUniswapPair).balanceOf(address(this));

        LPPerUnitContributed = totalLPCreated.mul(1e18).div(totalUnitsContributed.sub(totalCOREToRefund)); // Stored as 1e18 more for round erorrs and change
        require(LPPerUnitContributed > 0, "LP Per Unit Contribute Must be above Zero");
        LGEFinished = true;

        ICORETransferHandler(coreGlobals.TransferHandler()).sync(wrappedTokenUniswapPair);
        ICORETransferHandler(coreGlobals.TransferHandler()).sync(coreEthPair);

    }
    


    
}