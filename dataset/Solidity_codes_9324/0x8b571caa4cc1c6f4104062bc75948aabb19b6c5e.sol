



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

library AddressStringUtil {

    function toAsciiString(address addr, uint len) pure internal returns (string memory) {

        require(len % 2 == 0 && len > 0 && len <= 40, "AddressStringUtil: INVALID_LEN");

        bytes memory s = new bytes(len);
        uint addrNum = uint(addr);
        for (uint i = 0; i < len / 2; i++) {
            uint8 b = uint8(addrNum >> (8 * (19 - i)));
            uint8 hi = b >> 4;
            uint8 lo = b - (hi << 4);
            s[2 * i] = char(hi);
            s[2 * i + 1] = char(lo);
        }
        return string(s);
    }

    function char(uint8 b) pure private returns (byte c) {

        if (b < 10) {
            return byte(b + 0x30);
        } else {
            return byte(b + 0x37);
        }
    }
}




pragma solidity >=0.5.0;

library SafeERC20Namer {

    function bytes32ToString(bytes32 x) pure private returns (string memory) {

        bytes memory bytesString = new bytes(32);
        uint charCount = 0;
        for (uint j = 0; j < 32; j++) {
            byte char = x[j];
            if (char != 0) {
                bytesString[charCount] = char;
                charCount++;
            }
        }
        bytes memory bytesStringTrimmed = new bytes(charCount);
        for (uint j = 0; j < charCount; j++) {
            bytesStringTrimmed[j] = bytesString[j];
        }
        return string(bytesStringTrimmed);
    }

    function parseStringData(bytes memory b) pure private returns (string memory) {

        uint charCount = 0;
        for (uint i = 32; i < 64; i++) {
            charCount <<= 8;
            charCount += uint8(b[i]);
        }

        bytes memory bytesStringTrimmed = new bytes(charCount);
        for (uint i = 0; i < charCount; i++) {
            bytesStringTrimmed[i] = b[i + 64];
        }

        return string(bytesStringTrimmed);
    }

    function addressToName(address token) pure private returns (string memory) {

        return AddressStringUtil.toAsciiString(token, 40);
    }

    function addressToSymbol(address token) pure private returns (string memory) {

        return AddressStringUtil.toAsciiString(token, 6);
    }

    function callAndParseStringReturn(address token, bytes4 selector) view private returns (string memory) {

        (bool success, bytes memory data) = token.staticcall(abi.encodeWithSelector(selector));
        if (!success || data.length == 0) {
            return "";
        }
        if (data.length == 32) {
            bytes32 decoded = abi.decode(data, (bytes32));
            return bytes32ToString(decoded);
        } else if (data.length > 64) {
            return abi.decode(data, (string));
        }
        return "";
    }

    function tokenSymbol(address token) internal view returns (string memory) {

        string memory symbol = callAndParseStringReturn(token, 0x95d89b41);
        if (bytes(symbol).length == 0) {
            return addressToSymbol(token);
        }
        return symbol;
    }

    function tokenName(address token) internal view returns (string memory) {

        string memory name = callAndParseStringReturn(token, 0x06fdde03);
        if (bytes(name).length == 0) {
            return addressToName(token);
        }
        return name;
    }
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



pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;






interface IFlashArbitrageExecutor {

    function getStrategyProfitInReturnToken(address[] memory pairs, uint256[] memory feeOnTransfers, bool[] memory token0Out) external view returns (uint256);

    function executeStrategy(uint256) external;

    function executeStrategy(address[] memory pairs, uint256[] memory feeOnTransfers, bool[] memory token0Out, bool cBTCSupport) external;

    function executeStrategy(uint256 borrowAmt, address[] memory pairs, uint256[] memory feeOnTransfers, bool[] memory token0Out, bool cBTCSupport) external;


    function getOptimalInput(address[] memory pairs, uint256[] memory feeOnTransfers, bool[] memory token0Out) external view returns (uint256);

}


contract FlashArbitrageController is OwnableUpgradeSafe {

    using SafeMath for uint256;

    event StrategyAdded(string indexed name, uint256 indexed id, address[] pairs, bool feeOff, address indexed originator);

    struct Strategy {
        string strategyName;
        bool[] token0Out; // An array saying if token 0 should be out in this step
        address[] pairs; // Array of pair addresses
        uint256[] feeOnTransfers; //Array of fee on transfers 1% = 10
        bool cBTCSupport; // Should the algorithm check for cBTC and wrap/unwrap it
        bool feeOff; // Allows for adding CORE strategies - where there is no fee on the executor
    }

    uint256 public revenueSplitFeeOffStrategy;
    uint256 public revenueSplitFeeOnStrategy;

    address public  distributor;
    IFlashArbitrageExecutor public executor;
    address public cBTC;
    address public CORE;
    address public wBTC;
    bool depreciated; // This contract can be upgraded to a new one
    uint8 MAX_STEPS_LEN; // This variable is responsible to minimsing risk of gas limit strategies being added
    Strategy[] public strategies;
    mapping(uint256 => bool) strategyBlacklist;


    function initialize(address _executor, address _distributor) initializer public  {

        require(tx.origin == address(0x5A16552f59ea34E44ec81E58b3817833E9fD5436));
        OwnableUpgradeSafe.__Ownable_init();

        cBTC = 0x7b5982dcAB054C377517759d0D2a3a5D02615AB8;
        CORE = 0x62359Ed7505Efc61FF1D56fEF82158CcaffA23D7;
        wBTC = 0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599;
        distributor = _distributor; // we dont hard set it because its not live yet
        executor = IFlashArbitrageExecutor(_executor);
        revenueSplitFeeOffStrategy = 100; // 10%
        revenueSplitFeeOnStrategy = 650; // 65%
        MAX_STEPS_LEN = 20;
    }

    

    function setExecutor(address _executor) onlyOwner public {

        executor = IFlashArbitrageExecutor(_executor);
    }

    function setDistributor(address _distributor) onlyOwner public {

        distributor = _distributor;
    }

    function setMaxStrategySteps(uint8 _maxSteps) onlyOwner public {

        MAX_STEPS_LEN = _maxSteps;
    }

    function setDepreciated(bool _depreciated) onlyOwner public {

        depreciated = _depreciated;
    }

    function setFeeSplit(uint256 _revenueSplitFeeOffStrategy, uint256 _revenueSplitFeeOnStrategy) onlyOwner public {

        require(revenueSplitFeeOffStrategy <= 200, "FA : 20% max fee for feeOff revenue split");
        require(revenueSplitFeeOnStrategy <= 950, "FA : 95% max fee for feeOff revenue split");
        revenueSplitFeeOffStrategy = _revenueSplitFeeOffStrategy;
        revenueSplitFeeOnStrategy = _revenueSplitFeeOnStrategy;
    }


    function getOptimalInput(uint256 strategyPID) public view returns (uint256) {

        Strategy memory currentStrategy = strategies[strategyPID];
        return executor.getOptimalInput(currentStrategy.pairs, currentStrategy.feeOnTransfers, currentStrategy.token0Out);
    }

    function strategyProfitInReturnToken(uint256 strategyID) public view returns (uint256 profit) {

        Strategy memory currentStrategy = strategies[strategyID];
        if(strategyBlacklist[strategyID]) return 0;
        return executor.getStrategyProfitInReturnToken(currentStrategy.pairs, currentStrategy.feeOnTransfers, currentStrategy.token0Out);
    }

    function strategyProfitInETH(uint256 strategyID) public view returns (uint256 profit) {

        Strategy memory currentStrategy = strategies[strategyID];
        if(strategyBlacklist[strategyID]) return 0;
        profit = executor.getStrategyProfitInReturnToken(currentStrategy.pairs, currentStrategy.feeOnTransfers, currentStrategy.token0Out);
        if(profit == 0) return profit;
        address pair = currentStrategy.pairs[0];
        address token = currentStrategy.token0Out[0] ? IUniswapV2Pair(pair).token1() : IUniswapV2Pair(pair).token0(); 
        address pairForProfitToken = IUniswapV2Factory(0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f).getPair(
            0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2, token
        );
        if(pairForProfitToken == address(0)) return 0;
        bool profitTokenIsToken0InPair = IUniswapV2Pair(pairForProfitToken).token0() == token;
        (uint256 reserve0, uint256 reserve1,) = IUniswapV2Pair(pairForProfitToken).getReserves();

        if(profitTokenIsToken0InPair) {
            profit = getAmountOut(profit, reserve0, reserve1);
        }
        else {
            profit = getAmountOut(profit, reserve1, reserve0);
        }
    }

    function mostProfitableStrategyInETH() public view  returns (uint256 profit, uint256 strategyID){

          
          for (uint256 i = 0; i < strategies.length; i++) {
              uint256 profitThisStrategy = strategyProfitInETH(i);

              if(profitThisStrategy > profit) {
                profit = profitThisStrategy;
                strategyID = i;
              }

          }
    }


    function strategyInfo(uint256 strategyPID) public view returns (Strategy memory){

        return strategies[strategyPID];
    }

    function numberOfStrategies() public view returns (uint256) {

        return strategies.length;
    }




    function executeStrategy(uint256 strategyPID) public {

        require(!depreciated, "This Contract is depreciated");
        Strategy memory currentStrategy = strategies[strategyPID];

        
        try executor.executeStrategy(currentStrategy.pairs, currentStrategy.feeOnTransfers, currentStrategy.token0Out, currentStrategy.cBTCSupport)
        { 
            splitProfit(currentStrategy);
        }
        catch (bytes memory reason) 
        {
            bytes memory k = bytes("UniswapV2: K");

            if(reason.length == 100 && !currentStrategy.feeOff) { // "UniswapV2: K" 
                strategyBlacklist[strategyPID] = true;
                return;
            } else {
                revert("Strategy could not execute, most likely because it was not profitable at the moment of execution.");
            }
        }

    }

    function executeStrategy(uint256 inputAmount, uint256 strategyPID) public {


        require(!depreciated, "This Contract is depreciated");
        Strategy memory currentStrategy = strategies[strategyPID];

        try executor.executeStrategy(inputAmount ,currentStrategy.pairs, currentStrategy.feeOnTransfers, currentStrategy.token0Out, currentStrategy.cBTCSupport)
        { 
            splitProfit(currentStrategy);
        }
        catch (bytes memory reason) 
        {
            bytes memory k = bytes("UniswapV2: K");
            if(reason.length == 100 && !currentStrategy.feeOff) { // "UniswapV2: K" // We don't blacklist admin added
                strategyBlacklist[strategyPID] = true;
                return;
            } else {
                revert("Strategy could not execute, most likely because it was not profitable at the moment of execution.");
            }
        }
     

    }

    function splitProfit(Strategy memory currentStrategy) internal {

        address profitToken = currentStrategy.token0Out[0] ? 
            IUniswapV2Pair(currentStrategy.pairs[0]).token1() 
                : 
            IUniswapV2Pair(currentStrategy.pairs[0]).token0();


        uint256 profit = IERC20(profitToken).balanceOf(address(this));

        if(currentStrategy.feeOff) {
            safeTransfer(profitToken, msg.sender, profit.mul(revenueSplitFeeOffStrategy).div(1000));
        }
        else {
            safeTransfer(profitToken, msg.sender, profit.mul(revenueSplitFeeOnStrategy).div(1000));
        }

        safeTransfer(profitToken, distributor, IERC20(profitToken).balanceOf(address(this)));
    }




    function addNewStrategy(bool borrowToken0, address[] memory pairs) public returns (uint256 strategyID) {


        uint256[] memory feeOnTransfers = new uint256[](pairs.length);
        strategyID = addNewStrategyWithFeeOnTransferTokens(borrowToken0, pairs, feeOnTransfers);

    }

    function addNewStrategyWithFeeOnTransferTokens(bool borrowToken0, address[] memory pairs, uint256[] memory feeOnTransfers) public returns (uint256 strategyID) {

        require(!depreciated, "This Contract is depreciated");
        require(pairs.length <= MAX_STEPS_LEN, "FA Controller - too many steps");
        require(pairs.length > 1, "FA Controller - Specifying one pair is not arbitage");
        require(pairs.length == feeOnTransfers.length, "FA Controller: Malformed Input -  pairs and feeontransfers should equal");
        bool[] memory token0Out = new bool[](pairs.length);
        token0Out[0] = borrowToken0;

        address token0 = IUniswapV2Pair(pairs[0]).token0();
        address token1 = IUniswapV2Pair(pairs[0]).token1();
        if(msg.sender != owner()) {
            require(token0 != CORE && token1 != CORE, "FA Controller: CORE strategies can be only added by an admin");
        }        
        
        bool cBTCSupport;
        if(token0 == cBTC || token1 == cBTC) cBTCSupport = true;

        address lastToken = borrowToken0 ? token0 : token1;

       
        string memory strategyName = append(
            SafeERC20Namer.tokenSymbol(lastToken),
            " price too low. In ", 
            SafeERC20Namer.tokenSymbol(token0), "/", 
            SafeERC20Namer.tokenSymbol(token1), " pair");


        for (uint256 i = 1; i < token0Out.length; i++) {
            require(pairs[i] != pairs[0], "Uniswap lock");
            address token0 = IUniswapV2Pair(pairs[i]).token0();
            address token1 = IUniswapV2Pair(pairs[i]).token1();

            if(msg.sender != owner()) {
                require(token0 != CORE && token1 != CORE, "FA Controller: CORE strategies can be only added by an admin");
            }

  
            
            if(lastToken == cBTC || lastToken == wBTC){       
                require(token0 == cBTC || token1 == cBTC || token0 == wBTC || token1 == wBTC,
                    "FA Controller: Malformed Input - pair does not contain previous token");

            } else{
                require(token0 == lastToken || token1 == lastToken, "FA Controller: Malformed Input - pair does not contain previous token");

            }




            if(lastToken == cBTC) {
                cBTCSupport = true;
                 if(token0 == wBTC || token1 == wBTC && token0 != cBTC && token1 != cBTC){
                     
                     token0Out[i] = wBTC == token1;
                     lastToken = wBTC == token1 ? token0 : token1;
                 }
            }

             else if(lastToken == wBTC && token0 == cBTC || token1 == cBTC && token0 != wBTC && token1 != wBTC){
                cBTCSupport = true;
                token0Out[i] = cBTC == token1;
                lastToken = cBTC == token1 ? token0 : token1;
            }
            else {
                token0Out[i] = token1 == lastToken;

                lastToken = token0 == lastToken ? token1 : token0;


            }
          


        
        }
        
        
        strategyID = strategies.length;

        strategies.push(
            Strategy({
                strategyName : strategyName,
                token0Out : token0Out,
                pairs : pairs,
                feeOnTransfers : feeOnTransfers,
                cBTCSupport : cBTCSupport,
                feeOff : msg.sender == owner()
            })
        );


        emit StrategyAdded(strategyName, strategyID, pairs, msg.sender == owner(), msg.sender);
    }

  
    function sendETH(address payable to, uint256 amt) internal {

        to.transfer(amt);
    }

    function safeTransfer(address token, address to, uint256 value) internal {

            (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
            require(success && (data.length == 0 || abi.decode(data, (bool))), 'FA Controller: TRANSFER_FAILED');
    }

    function getTokenSafeName(address token) public view returns (string memory) {

        return SafeERC20Namer.tokenSymbol(token);
    }


    function getAmountOut(uint256 amountIn, uint256 reserveIn, uint256 reserveOut) internal  pure returns (uint256 amountOut) {

        require(amountIn > 0, 'UniswapV2Library: INSUFFICIENT_INPUT_AMOUNT');
        require(reserveIn > 0 && reserveOut > 0, 'UniswapV2Library: INSUFFICIENT_LIQUIDITY');
        uint amountInWithFee = amountIn.mul(997);

        uint numerator = amountInWithFee.mul(reserveOut);
        uint denominator = reserveIn.mul(1000).add(amountInWithFee);

        amountOut = numerator / denominator;
    }

    function rescueTokens(address token, uint256 amt) public onlyOwner {

        IERC20(token).transfer(owner(), amt);
    }

    function rescueETH(uint256 amt) public {

        sendETH(0xd5b47B80668840e7164C1D1d81aF8a9d9727B421, amt);
    }

    function append(string memory a, string memory b, string memory c, string memory d, string memory e, string memory f) internal pure returns (string memory) {

        return string(abi.encodePacked(a, b,c,d,e,f));
    }



    function skimToken(address _token) public {

        IERC20 token = IERC20(_token);
        uint256 balToken = token.balanceOf(address(this));
        safeTransfer(_token, msg.sender, balToken.mul(revenueSplitFeeOffStrategy).div(1000));
        safeTransfer(_token, distributor, token.balanceOf(address(this)));
    }


}