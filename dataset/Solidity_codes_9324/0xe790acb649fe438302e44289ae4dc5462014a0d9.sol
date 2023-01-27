



interface ICOREGlobals {

    function CORETokenAddress() external view returns (address);

    function COREVaultAddress() external returns (address);

    function UniswapFactory() external view returns (address);

    function TransferHandler() external view returns (address);

    function isContract(address) external view returns (bool);

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


interface ICORETransferHandler {

    function sync(address) external returns(bool,bool);

    function feePercentX100() external returns (uint8); 


}

contract CORE_LGE_3 is Initializable, OwnableUpgradeSafe {


    using SafeMath for uint256;

    uint256 private locked;
    modifier lock() {

        require(locked == 0, 'CORE LGE: LOCKED');
        locked = 1;
        _; // Can't re-eter until function is finished
        locked = 0;
    }

    address public WETH;
    address public CORE;
    address public DAI;
    address public cDAIxcCOREUniswapPair;
    address public cDAI; // TODO : Add setters
    address public cCORE;
    address payable public CORE_MULTISIG;

    address public uniswapFactory;
    address public sushiswapFactory;


    uint256 public totalLPCreated;    
    uint256 private totalCOREUnitsContributed;
    uint256 public LPPerCOREUnitContributed; // stored as 1e18 more - this is done for change


    event Contibution(uint256 COREvalue, address from);
    event COREBought(uint256 COREamt);

    mapping(address => PriceAverage) _averagePrices;
    struct PriceAverage{
       uint8 lastAddedHead;
       uint256[20] price;
       uint256 cumulativeLast20Blocks;
       bool arrayFull;
       uint lastBlockOfIncrement; // Just update once per block ( by buy token function )
    }
    mapping (address => bool) public claimed; 
    mapping (address => bool) public doNotSellList;
    mapping (address => uint256) public credit;
    mapping (address => uint256) public tokenReserves;

    ICOREGlobals public coreGlobals;
    bool public LGEStarted;
    bool public LGEFinished;
    bool public LGEPaused;
    uint256 public contractStartTimestamp;
    uint256 public contractStartTimestampSaved;
    uint256 public LGEDurationDays;

    mapping (address => bool ) public snapshotAdded;


    function initialize() public initializer {

        require(msg.sender == address(0x5A16552f59ea34E44ec81E58b3817833E9fD5436));
        OwnableUpgradeSafe.__Ownable_init();

        contractStartTimestamp = uint256(-1); // wet set it here to max so checks fail
        LGEDurationDays = 7 days;

        DAI = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
        CORE = 0x62359Ed7505Efc61FF1D56fEF82158CcaffA23D7;
        WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
        uniswapFactory = 0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f;
        sushiswapFactory = 0xC0AEe478e3658e2610c5F7A4A2E1777cE9e4f2Ac;
        CORE_MULTISIG = 0x5A16552f59ea34E44ec81E58b3817833E9fD5436;
        coreGlobals = ICOREGlobals(0x255CA4596A963883Afe0eF9c85EA071Cc050128B);
    
        doNotSellList[DAI] = true;
        doNotSellList[CORE] = true;
        doNotSellList[WETH] = true;

    }

    function startLGE() public onlyOwner {

        require(LGEStarted == false, "Already started");

        contractStartTimestamp = block.timestamp;
        LGEStarted = true;

        rescueRatioLock(CORE);
        rescueRatioLock(DAI); 
    }
    

    


    function addLiquidityETH() lock external payable {

        require(LGEStarted == true, "LGE : Didn't start");
        require(LGEFinished == false, "LGE : Liquidity generation finished");
        require(isLGEOver() == false, "LGE : Is over.");
        require(msg.value > 0, "LGE : You should deposit something most likely");
        
        IWETH(WETH).deposit{value: msg.value}();

        uint256 valueInCOREUnits = getAveragePriceLast20BlocksIn1WETHPriceWorth(CORE).mul(msg.value).div(1e18);
        credit[msg.sender] = credit[msg.sender].add(valueInCOREUnits);
        tokenReserves[WETH] = tokenReserves[WETH].add(msg.value);
        totalCOREUnitsContributed = totalCOREUnitsContributed.add(valueInCOREUnits);

        updateRunningAverages();

    }

    function contributeWithAllowance(address _token, uint256 _amountContribution) lock public {


        require(LGEStarted == true, "LGE : Didn't start");
        require(LGEFinished == false, "LGE : Liquidity generation finished");
        require(isLGEOver() == false, "LGE : Is over.");
        require(_amountContribution > 0, "LGE : You should deposit something most likely");

        address [] memory tokensToSell;

        address token0;
        try IUniswapV2Pair(_token).token0() { token0 = IUniswapV2Pair(_token).token0(); } catch { }

        if(token0 != address(0)) {
            address token1 = IUniswapV2Pair(_token).token1();
            bool isUniLP = IUniswapV2Factory(uniswapFactory).getPair(token1,token0) !=  address(0);
            bool isSushiLP = IUniswapV2Factory(sushiswapFactory).getPair(token0,token1) !=  address(0);
            if(!isUniLP && !isSushiLP) { revert("LGE : LP Token type not accepted"); } // reverts here
            safeTransferFrom(_token, msg.sender, _token, _amountContribution);
            uint256 balanceToken0Before = IERC20(token0).balanceOf(address(this));
            uint256 balanceToken1Before = IERC20(token1).balanceOf(address(this));
            IUniswapV2Pair(_token).burn(address(this));
            uint256 balanceToken0After = IERC20(token0).balanceOf(address(this));
            uint256 balanceToken1After = IERC20(token1).balanceOf(address(this));

            uint256 amountOutToken0 = token0 == WETH ? 
                balanceToken0After.sub(balanceToken0Before)
                : sellTokenForWETH(token0, balanceToken0After.sub(balanceToken0Before), false);

            uint256 amountOutToken1 = token1 == WETH ? 
                balanceToken1After.sub(balanceToken1Before)
                : sellTokenForWETH(token1, balanceToken1After.sub(balanceToken1Before), false);

            uint256 balanceWETHNew = IERC20(WETH).balanceOf(address(this));

            uint256 reserveWETH = tokenReserves[WETH];

            require(balanceWETHNew > reserveWETH, "sir.");
            uint256 totalWETHAdded = amountOutToken0.add(amountOutToken1);
            require(tokenReserves[WETH].add(totalWETHAdded) <= balanceWETHNew, "Ekhm"); // In case someone sends dirty dirty dust
            tokenReserves[WETH] = balanceWETHNew;
            uint256 valueInCOREUnits = getAveragePriceLast20BlocksIn1WETHPriceWorth(CORE).mul(totalWETHAdded).div(1e18);

            credit[msg.sender] = credit[msg.sender].add(valueInCOREUnits);
            emit Contibution(valueInCOREUnits, msg.sender);
            totalCOREUnitsContributed = totalCOREUnitsContributed.add(valueInCOREUnits);

            updateRunningAverages();
            return;
        } 
        
    

        if(doNotSellList[_token] && token0 == address(0)) { // We dont sell this token aka its CORE or DAI
            if(_token == CORE) {
                safeTransferFrom(CORE, msg.sender, address(this), _amountContribution);
                uint256 COREReserves = IERC20(CORE).balanceOf(address(this));
                require(COREReserves >= tokenReserves[CORE], "Didn't get enough CORE");
                credit[msg.sender] = credit[msg.sender].add(_amountContribution); // we can trust this cause
                tokenReserves[CORE] = COREReserves;
                totalCOREUnitsContributed = totalCOREUnitsContributed.add(_amountContribution);

                emit Contibution(_amountContribution, msg.sender);
            }

            else if(_token == DAI) {
                safeTransferFrom(DAI, msg.sender, address(this), _amountContribution);
                uint256 DAIReserves = IERC20(DAI).balanceOf(address(this));
                require(DAIReserves >= tokenReserves[DAI].add(_amountContribution), "Didn't get enough DAI");

                uint256 valueInWETH = 
                    _amountContribution
                    .mul(1e18) 
                    .div(getAveragePriceLast20BlocksIn1WETHPriceWorth(DAI)); // 1weth buys this much DAI so we divide to get numer of weth

                uint256 valueInCOREUnits = getAveragePriceLast20BlocksIn1WETHPriceWorth(CORE).mul(valueInWETH).div(1e18);

                credit[msg.sender] = credit[msg.sender].add(valueInCOREUnits);
                tokenReserves[DAI] = DAIReserves; 
                emit Contibution(valueInCOREUnits, msg.sender);
                totalCOREUnitsContributed = totalCOREUnitsContributed.add(valueInCOREUnits);

            }

            else if(_token == WETH) { 
                safeTransferFrom(WETH, msg.sender, address(this), _amountContribution);
                uint256 reservesWETHNew = IERC20(WETH).balanceOf(address(this));
                require(reservesWETHNew >= tokenReserves[WETH].add(_amountContribution), "Didn't get enough WETH");
                tokenReserves[WETH] = reservesWETHNew;
                uint256 valueInCOREUnits = getAveragePriceLast20BlocksIn1WETHPriceWorth(CORE).mul(_amountContribution).div(1e18);
                credit[msg.sender] = credit[msg.sender].add(valueInCOREUnits);
                emit Contibution(valueInCOREUnits, msg.sender);
                totalCOREUnitsContributed = totalCOREUnitsContributed.add(valueInCOREUnits);

            }
            else {
                revert("Unsupported Token Error, somehow on not to sell list");
            }

        } else {
            uint256 amountOut = sellTokenForWETH(_token, _amountContribution, true);
            uint256 balanceWETHNew = IERC20(WETH).balanceOf(address(this));
            uint256 reserveWETH = tokenReserves[WETH];
            require(balanceWETHNew > reserveWETH, "sir.");
            require(reserveWETH.add(amountOut) <= balanceWETHNew, "Ekhm"); // In case someone sends dirty dirty dust
            tokenReserves[WETH] = balanceWETHNew;
            uint256 valueInCOREUnits = getAveragePriceLast20BlocksIn1WETHPriceWorth(CORE).mul(amountOut).div(1e18);
            credit[msg.sender] = credit[msg.sender].add(valueInCOREUnits);
            emit Contibution(valueInCOREUnits, msg.sender);
            totalCOREUnitsContributed = totalCOREUnitsContributed.add(valueInCOREUnits);


        }
        updateRunningAverages(); // After transactions are done
    }

    function claimLP() lock public {

        safeTransfer(cDAIxcCOREUniswapPair, msg.sender, _claimLP());
    }

    function claimAndStakeLP() lock public {

        address vault = coreGlobals.COREVaultAddress();
        IUniswapV2Pair(cDAIxcCOREUniswapPair).approve(vault, uint(-1));
        ICOREVault(vault).depositFor(msg.sender, 2, _claimLP());
    }

    function _claimLP() internal returns (uint256 claimable){ 

        uint256 credit = credit[msg.sender]; // gas savings

        require(LGEFinished == true, "LGE : Liquidity generation not finished");
        require(claimed[msg.sender] == false, "LGE : Already claimed");
        require(credit > 0, "LGE : Nothing to be claimed");

        claimed[msg.sender] =  true;
        claimable = credit.mul(LPPerCOREUnitContributed).div(1e18);
    }




    function isLGEOver() public view returns (bool) {

        return block.timestamp > contractStartTimestamp.add(LGEDurationDays);
    }
    function getDAIandCOREReservesValueInETH() internal view returns (uint256 COREValueETH, uint256 DAIValueETH) {

        (uint256 reserveCORE, uint256 reserveDAI) = (tokenReserves[CORE], tokenReserves[DAI]);
        COREValueETH = reserveCORE.div(1e8).mul(getWETHValueOf1e8TokenUnits(CORE));
        DAIValueETH = reserveDAI.div(1e8).mul(getWETHValueOf1e8TokenUnits(DAI));
    }

    function getLGEContributionsValue() public view returns (uint256 COREValueETH, uint256 DAIValueETH, uint256 ETHValue) {

        (uint256 reserveCORE, uint256 reserveDAI) = (tokenReserves[CORE], tokenReserves[DAI]);
        COREValueETH = reserveCORE.div(1e8).mul(getWETHValueOf1e8TokenUnits(CORE));
        DAIValueETH = reserveDAI.div(1e8).mul(getWETHValueOf1e8TokenUnits(DAI));
        ETHValue =  IERC20(WETH).balanceOf(address(this));
    }

    function getWETHValueOf1e8TokenUnits(address _token) internal view returns (uint256) {

         address pairWithWETH = IUniswapV2Factory(uniswapFactory).getPair(_token, WETH);
         if(pairWithWETH == address(0)) return 0;
         IUniswapV2Pair pair = IUniswapV2Pair(pairWithWETH);
         (uint256 reserve0, uint256 reserve1 ,) = pair.getReserves();

         if(pair.token0() == WETH) {
             return getAmountOut(1e8,reserve1,reserve0);
         } else {
             return getAmountOut(1e8,reserve0,reserve1);
         }
    }

    function getAmountOut(uint256 amountIn, uint256 reserveIn, uint256 reserveOut) internal  pure returns (uint256 amountOut) {

        require(amountIn > 0, 'UniswapV2Library: INSUFFICIENT_INPUT_AMOUNT');
        require(reserveIn > 0 && reserveOut > 0, 'UniswapV2Library: INSUFFICIENT_LIQUIDITY');
        uint amountInWithFee = amountIn.mul(997);
        uint numerator = amountInWithFee.mul(reserveOut);
        uint denominator = reserveIn.mul(1000).add(amountInWithFee);
        amountOut = numerator / denominator;
    }



    function buyCOREforWETH(uint256 amountWETH, uint256 minAmountCOREOut) onlyOwner public {

        (uint256 COREValueETH, uint256 DAIValueETH) = getDAIandCOREReservesValueInETH();
        require(COREValueETH.add(amountWETH) <= DAIValueETH, "Buying too much CORE");
        IUniswapV2Pair pair = IUniswapV2Pair(0x32Ce7e48debdccbFE0CD037Cc89526E4382cb81b);// CORE/WETH pair
        safeTransfer(WETH, address(pair), amountWETH);
        (uint256 reservesCORE, uint256 reservesWETH, ) = pair.getReserves();
        uint256 coreOUT = getAmountOut(amountWETH, reservesWETH, reservesCORE);
        pair.swap(coreOUT, 0, address(this), "");
        tokenReserves[CORE] = tokenReserves[CORE].add(coreOUT);
        tokenReserves[WETH] = IERC20(WETH).balanceOf(address(this)); 
        require(coreOUT >= minAmountCOREOut, "Buy Slippage too high");
        emit COREBought(coreOUT);
    }


    function buyDAIforWETH(uint256 amountWETH, uint256 minAmountDAIOut) onlyOwner public {

        IUniswapV2Pair pair = IUniswapV2Pair(0xA478c2975Ab1Ea89e8196811F51A7B7Ade33eB11);// DAI/WETH pair
        safeTransfer(WETH, address(pair), amountWETH);
        (uint256 reservesDAI, uint256 reservesWETH, ) = pair.getReserves();
        uint256 daiOUT = getAmountOut(amountWETH, reservesWETH, reservesDAI);
        pair.swap(daiOUT, 0, address(this), "");
        tokenReserves[DAI] = IERC20(DAI).balanceOf(address(this)); 
        tokenReserves[WETH] = IERC20(WETH).balanceOf(address(this)); 
        require(daiOUT >= minAmountDAIOut, "Buy Slippage too high");
    }

    function sellDAIforWETH(uint256 amountDAI, uint256 minAmountWETH) onlyOwner public {

        IUniswapV2Pair pair = IUniswapV2Pair(0xA478c2975Ab1Ea89e8196811F51A7B7Ade33eB11);// DAI/WETH pair
        safeTransfer(DAI, address(pair), amountDAI);
        (uint256 reservesDAI, uint256 reservesWETH, ) = pair.getReserves();
        uint256 wethOUT = getAmountOut(amountDAI, reservesDAI, reservesWETH);
        pair.swap(0, wethOUT, address(this), "");
        tokenReserves[DAI] = IERC20(DAI).balanceOf(address(this)); 
        tokenReserves[WETH] = IERC20(WETH).balanceOf(address(this)); 
        require(wethOUT >= minAmountWETH, "Buy Slippage too high");
    }   



    function updateRunningAverages() internal {

         if(_averagePrices[DAI].lastBlockOfIncrement != block.number) {
            _averagePrices[DAI].lastBlockOfIncrement = block.number;
            updateRunningAveragePrice(DAI, false);
          }
         if(_averagePrices[CORE].lastBlockOfIncrement != block.number) {
            _averagePrices[CORE].lastBlockOfIncrement = block.number;
            updateRunningAveragePrice(CORE, false);
         }
    }

    function getAveragePriceLast20BlocksIn1WETHPriceWorth(address token) public view returns (uint256) {

       return _averagePrices[token].cumulativeLast20Blocks.div(_averagePrices[token].arrayFull ? 20 : _averagePrices[token].lastAddedHead);
    }


    function updateRunningAveragePrice(address token, bool isRescue) internal returns (uint256) {


        PriceAverage storage currentAveragePrices =  _averagePrices[token];
        address pairWithWETH = IUniswapV2Factory(uniswapFactory).getPair(token, WETH);
        uint256 wethReserves; uint256 tokenReserves;
        if(WETH == IUniswapV2Pair(pairWithWETH).token0()) {
            ( wethReserves, tokenReserves,) = IUniswapV2Pair(pairWithWETH).getReserves();
        } else {
            (tokenReserves, wethReserves,) = IUniswapV2Pair(pairWithWETH).getReserves();

        }
        uint256 outTokenFor1WETH = getAmountOut(1e18, wethReserves, tokenReserves);

        uint8 i = currentAveragePrices.lastAddedHead;
        
        uint256 oldestQuoteIndex;
        if(currentAveragePrices.arrayFull == true) {
            if (i != 19 ) {
               oldestQuoteIndex = i + 1;
            } // its 0 already else
        } else {
            if (i > 0) {
                oldestQuoteIndex = i -1;
            } // its 0 already else
        }
        uint256 firstQuote = currentAveragePrices.price[oldestQuoteIndex];
 
        if(isRescue == false){
            require(outTokenFor1WETH < firstQuote.mul(15000).div(10000), "Change too big from first recorded price");
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


    function totalCreditsSnapShot(address [] memory allDepositors, uint256 _expectedLenght) public onlyOwner {


        uint256 lenUsers = allDepositors.length;

        for (uint256 loop = 0; loop < lenUsers; loop++) {
            address curentAddress = allDepositors[loop];
            if(snapshotAdded[curentAddress] == false) {
                snapshotAdded[curentAddress] = true;
                totalCOREUnitsContributed = totalCOREUnitsContributed.add(credit[curentAddress]);
            }
        }

    }

    function editTotalUnits(uint256 _amountUnitsCORE, bool ifThisIsTrueItWillSubstractInsteadOfAdding) onlyOwner public {

        if(ifThisIsTrueItWillSubstractInsteadOfAdding)    
            { totalCOREUnitsContributed = totalCOREUnitsContributed.sub(totalCOREUnitsContributed); }
        else {
            totalCOREUnitsContributed = totalCOREUnitsContributed.add(totalCOREUnitsContributed);
        }
    }


    function addLiquidityToPair() public onlyOwner {

        require(block.timestamp > contractStartTimestamp.add(LGEDurationDays), "LGE : Liquidity generation ongoing");
        require(LGEFinished == false, "LGE : Liquidity generation finished");
        require(IERC20(WETH).balanceOf(address(this)) < 1 ether, "Too much WETH still left over in the contract");
        require(CORE_MULTISIG != address(0), "CORE MUTISIG NOT SET");
        require(cCORE != address(0), "cCORE NOT SET");
        require(cDAI != address(0), "cDAI NOT SET");
        require(totalCOREUnitsContributed > 600e18, "CORE total units are wrong"); // 600 CORE
        (uint256 COREValueETH, uint256 DAIValueETH) = getDAIandCOREReservesValueInETH();

        if(COREValueETH > DAIValueETH) {
            uint256 DELTA = COREValueETH - DAIValueETH;
            uint256 percentOfCORETooMuch = DELTA.mul(1e18).div(COREValueETH); // carry 1e18
            uint256 balanceCORE = IERC20(CORE).balanceOf(address(this));
            safeTransfer(CORE, CORE_MULTISIG, balanceCORE.mul(percentOfCORETooMuch).div(1e18));
        }

        require(COREValueETH.mul(104).div(100) > DAIValueETH, "Deviation from current price is too high" );

        IERC95(cCORE).unpauseTransfers();
        IERC95(cDAI).unpauseTransfers();

        cDAIxcCOREUniswapPair = IUniswapV2Factory(uniswapFactory).getPair(cCORE , cDAI);
        if(cDAIxcCOREUniswapPair == address(0)) { // Pair doesn't exist yet 
            cDAIxcCOREUniswapPair = IUniswapV2Factory(uniswapFactory).createPair(
                cDAI,
                cCORE
            );
        }


        uint256 balanceCORE = IERC20(CORE).balanceOf(address(this));
        uint256 balanceDAI = IERC20(DAI).balanceOf(address(this));
        uint256 DEV_FEE = 1000; 
        address CORE_MULTISIG = ICoreVault(coreGlobals.COREVaultAddress()).devaddr();
        uint256 devFeeCORE = balanceCORE.mul(DEV_FEE).div(10000);
        uint256 devFeeDAI = balanceDAI.mul(DEV_FEE).div(10000);


        safeTransfer(CORE, CORE_MULTISIG, devFeeCORE);
        safeTransfer(DAI, CORE_MULTISIG, devFeeDAI);


        safeTransfer(CORE, cCORE, balanceCORE.sub(devFeeCORE));
        safeTransfer(DAI, cDAI, balanceDAI.sub(devFeeDAI));

        IERC95(cCORE).wrapAtomic(cDAIxcCOREUniswapPair);
        IERC95(cDAI).wrapAtomic(cDAIxcCOREUniswapPair);


        require(IERC95(cDAI).balanceOf(cDAIxcCOREUniswapPair) == balanceDAI.sub(devFeeDAI), "Pair did not recieve enough DAI");
        require(IERC95(cDAI).balanceOf(cDAIxcCOREUniswapPair) > 15e23 , "Pair did not recieve enough DAI"); //1.5mln dai
        require(IERC95(cCORE).balanceOf(cDAIxcCOREUniswapPair) == balanceCORE.sub(devFeeCORE), "Pair did not recieve enough CORE");
        require(IERC95(cCORE).balanceOf(cDAIxcCOREUniswapPair) > 350e18 , "Pair did not recieve enough CORE"); //350 core


        IUniswapV2Pair pair = IUniswapV2Pair(cDAIxcCOREUniswapPair); // cCORE/cDAI pair
        
        require(pair.totalSupply() == 0, "Somehow total supply is higher, sanity fail");
        pair.mint(address(this));
        require(pair.totalSupply() > 0, "We didn't create tokens!");

        totalLPCreated = pair.balanceOf(address(this));
        LPPerCOREUnitContributed = totalLPCreated.mul(1e18).div(totalCOREUnitsContributed); // Stored as 1e18 more for round erorrs and change
        require(LPPerCOREUnitContributed > 0, "LP Per Unit Contribute Must be above Zero");
        require(totalLPCreated >= 27379e18, "Didn't create enough lp");
        ICORETransferHandler(coreGlobals.TransferHandler()).sync(cDAIxcCOREUniswapPair);

        LGEFinished = true;

    }



    function safetyTokenWithdraw(address token) onlyOwner public {

        require(block.timestamp > contractStartTimestamp.add(LGEDurationDays).add(1 days));
        IERC20(token).transfer(msg.sender, IERC20(token).balanceOf(address(this)));
    }
    function safetyETHWithdraw() onlyOwner public {

        require(block.timestamp > contractStartTimestamp.add(LGEDurationDays).add(1 days));
        msg.sender.call.value(address(this).balance)("");
    }

    function setCDAI(address _cDAI) onlyOwner public {

        cDAI = _cDAI;
    }

    function setcCORE(address _cCORE) onlyOwner public {

        cCORE = _cCORE;
    }

    function editLGETime(uint256 numHours, bool shouldSubstract) public {

        require(msg.sender == 0x82810e81CAD10B8032D39758C8DBa3bA47Ad7092 
            || msg.sender == 0xC91FE1ee441402D854B8F22F94Ddf66618169636 
            || msg.sender == CORE_MULTISIG, "LGE: Requires admin");
        require(numHours <= 24);
        if(shouldSubstract) {
            LGEDurationDays = LGEDurationDays.sub(numHours.mul(1 hours));
        } else {
            LGEDurationDays = LGEDurationDays.add(numHours.mul(1 hours));
        }
    }

    function pauseLGE() public {

        require(msg.sender == 0x82810e81CAD10B8032D39758C8DBa3bA47Ad7092 
            || msg.sender == 0xC91FE1ee441402D854B8F22F94Ddf66618169636 
            || msg.sender == CORE_MULTISIG, "LGE: Requires admin");
        require(LGEPaused == false, "LGE : LGE Already paused");
        contractStartTimestampSaved = contractStartTimestamp;
        contractStartTimestamp = uint256(-1);
        LGEPaused = true;

    }

    

    function sellTokenForWETH(address _token, uint256 _amountTransfer, bool fromPerson) internal returns (uint256 amountOut) {

        
        require(_token != DAI, "No sell DAI");
        address pairWithWETH = IUniswapV2Factory(uniswapFactory).getPair(_token, WETH);
        require(pairWithWETH != address(0), "Unsupported shitcoin"); 

        IERC20 shitcoin = IERC20(_token);
        IUniswapV2Pair pair = IUniswapV2Pair(pairWithWETH);
        uint256 balanceBefore = shitcoin.balanceOf(pairWithWETH); // can pumpthis, but fails later
        if(fromPerson) {
            safeTransferFrom(_token, msg.sender, pairWithWETH, _amountTransfer); // re
        } else {
            safeTransfer(_token, pairWithWETH, _amountTransfer);
        }
        uint256 balanceAfter = shitcoin.balanceOf(pairWithWETH);
        (uint256 reserve0, uint256 reserve1, ) = pair.getReserves();

        uint256 DELTA = balanceAfter.sub(balanceBefore, "Fuqq");
        if(pair.token0() == _token) { // weth is 1
            amountOut = getAmountOut(DELTA, reserve0, reserve1);
            require(amountOut < reserve1.mul(30).div(100), "Too much slippage in selling");
            pair.swap(0, amountOut, address(this), "");

        } else { // WETH is 0
            amountOut = getAmountOut(DELTA, reserve1, reserve0);
            pair.swap(amountOut, 0, address(this), "");
            require(amountOut < reserve0.mul(30).div(100), "Too much slippage in selling");

        }

    }

    function safeTransfer(address token, address to, uint256 value) internal {

        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'LGE3: TRANSFER_FAILED');
    }

    function safeTransferFrom(address token, address from, address to, uint256 value) internal {

        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'LGE3: TRANSFER_FROM_FAILED');
    }
   
    
}