

pragma solidity ^0.6.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);

    
    function decimals() external view returns (uint8);


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

contract Ownable is Context {

    address private _governance;

    event GovernanceTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
        address msgSender = _msgSender();
        _governance = msgSender;
        emit GovernanceTransferred(address(0), msgSender);
    }

    function governance() public view returns (address) {

        return _governance;
    }

    modifier onlyGovernance() {

        require(_governance == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function transferGovernance(address newOwner) internal virtual onlyGovernance {

        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit GovernanceTransferred(_governance, newOwner);
        _governance = newOwner;
    }
}


pragma solidity =0.6.6;


interface StabilizeStakingPool {

    function notifyRewardAmount(uint256) external;

}

interface UniswapRouter {

    function swapExactETHForTokens(uint, address[] calldata, address, uint) external payable returns (uint[] memory);

    function swapExactTokensForTokens(uint, uint, address[] calldata, address, uint) external returns (uint[] memory);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(uint, uint, address[] calldata, address, uint) external;

    function getAmountsOut(uint, address[] calldata) external view returns (uint[] memory); // For a value in, it calculates value out

}

interface AggregatorV3Interface {

  function latestRoundData() external view returns (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound);

}

interface UniswapLikeLPToken {

    function sync() external; // We need to call sync before Trading on Uniswap due to rebase potential

}

contract StabilizeStrategyAMPLArbV1 is Ownable {

    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    using Address for address;
    
    address public treasuryAddress; // Address of the treasury
    address public stakingAddress; // Address to the STBZ staking pool
    address public zsTokenAddress; // The address of the controlling zs-Token
    
    uint256 constant DIVISION_FACTOR = 100000;
    uint256 public lastTradeTime = 0;
    uint256 public lastActionBalance = 0; // Balance before last deposit or withdraw
    uint256 public maxPoolSize = 10000000e18; // The maximum amount of tokens this strategy can hold, 10 mil by default
    uint256 public maxPercentSell = 100000; // Up to 100% of the tokens are sold to the cheapest token
    uint256 public maxAmountSell = 500000; // The maximum amount of tokens that can be sold at once
    uint256 public maxPercentStipend = 30000; // The maximum amount of WETH profit that can be allocated to the executor for gas in percent
    uint256 public gasStipend = 1000000; // This is the gas units that are covered by executing a trade taken from the WETH profit
    uint256 public minGain = 1e16; // Minimum amount of gain (0.01 coin) before buying WETH and splitting it
    uint256 public minWithdrawFee = 500; // 0.5% fee
    
    uint256 public percentDepositor = 50000; // 1000 = 1%, depositors earn 50% of all gains
    uint256 public percentExecutor = 10000; // 10000 = 10% of WETH goes to executor, 5% of total profit. This is on top of gas stipend
    uint256 public percentStakers = 50000; // 50% of non-depositors WETH goes to stakers, can be changed
    
    uint256 public lastAmplTotalSupply;
    uint256 public lastAmplPrice;
    uint256 private _tokenToSell; // This goes down with each trade 
    bool private _inExpansion; // Determines which token to sell
    uint256 public lastRebasePercent;
    uint256 public amplSupplyChangeFactor = 50000; // This is a factor used by the strategy to determine how much ampl to sell in expansion
    uint256 public usdcSupplyChangeFactor = 20000; // This is a factor used by the strategy to determine how much usdc to sell in contraction
    uint256 public amplSellAmplificationFactor = 1; // The higher this number the more aggressive the sell during expansion
    uint256 public usdcSellAmplificationFactor = 1; // The higher this number the more aggressive the buyback in contraction
    
    struct TokenInfo {
        IERC20 token; // Reference of token
        uint256 decimals; // Decimals of token
    }
    
    TokenInfo[] private tokenList; // An array of tokens accepted as deposits

    address constant UNISWAP_ROUTER_ADDRESS = address(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D); //Address of Uniswap
    address constant WETH_ADDRESS = address(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
    address constant UNISWAP_AMPLETH_LP = address(0xc5be99A02C6857f9Eac67BbCE58DF5572498F40c);
    address constant GAS_ORACLE_ADDRESS = address(0x169E633A2D1E6c10dD91238Ba11c4A708dfEF37C); // Chainlink address for fast gas oracle
    address constant AMPL_PRICE_ORACLE = address(0xe20CA8D7546932360e37E9D72c1a47334af57706); // AMPL / USD
    uint256 constant WETH_ID = 2; // This strat will buy USDC with WETH and sell other tokens for WETH
    
    constructor(
        address _treasury,
        address _staking,
        address _zsToken
    ) public {
        treasuryAddress = _treasury;
        stakingAddress = _staking;
        zsTokenAddress = _zsToken;
        setupWithdrawTokens();
        lastAmplTotalSupply = tokenList[0].token.totalSupply();
        lastAmplPrice = getAmplUSDPrice();
        if(lastAmplPrice >= 1e18){
            _inExpansion = true;
        }
    }

    
    function setupWithdrawTokens() internal {

        IERC20 _token = IERC20(address(0xD46bA6D942050d489DBd938a2C909A5d5039A161));
        tokenList.push(
            TokenInfo({
                token: _token,
                decimals: _token.decimals()
            })
        );
        
        _token = IERC20(address(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48));
        tokenList.push(
            TokenInfo({
                token: _token,
                decimals: _token.decimals()
            })
        );
    }
    
    modifier onlyZSToken() {

        require(zsTokenAddress == _msgSender(), "Call not sent from the zs-Token");
        _;
    }
    
    
    function rewardTokensCount() external view returns (uint256) {

        return tokenList.length;
    }
    
    function rewardTokenAddress(uint256 _pos) external view returns (address) {

        require(_pos < tokenList.length,"No token at that position");
        return address(tokenList[_pos].token);
    }
    
    function balance() public view returns (uint256) {

        return getNormalizedTotalBalance(address(this));
    }
    
    function getNormalizedTotalBalance(address _address) public view returns (uint256) {

        uint256 _balance = 0;
        for(uint256 i = 0; i < tokenList.length; i++){
            uint256 _bal = tokenList[i].token.balanceOf(_address);
            _bal = _bal.mul(1e18).div(10**tokenList[i].decimals);
            _balance = _balance.add(_bal); // This has been normalized to 1e18 decimals
        }
        return _balance;
    }
    
    function withdrawTokenReserves() public view returns (address, uint256) {

        if(tokenList[0].token.balanceOf(address(this)) > 0){
            return (address(tokenList[0].token), tokenList[0].token.balanceOf(address(this)));
        }else if(tokenList[1].token.balanceOf(address(this)) > 0){
            return (address(tokenList[1].token), tokenList[1].token.balanceOf(address(this)));
        }else{
            return (address(0), 0); // No balance
        }
    }
    
    
    function enter() external onlyZSToken {

        deposit(false);
    }
    
    function exit() external onlyZSToken {

        withdraw(_msgSender(),1,1, false);
    }
    
    function deposit(bool nonContract) public onlyZSToken {

        
        if(nonContract == true){ }
        lastActionBalance = balance();
        require(lastActionBalance <= maxPoolSize,"This strategy has reached its maximum balance");
    }

    function simulateExchange(uint256 _inID, uint256 _outID, uint256 _amount) internal view returns (uint256) {

        UniswapRouter router = UniswapRouter(UNISWAP_ROUTER_ADDRESS);
        if(_outID == WETH_ID){
            address[] memory path = new address[](2);
            path[0] = address(tokenList[_inID].token);
            path[1] = WETH_ADDRESS;
            uint256[] memory estimates = router.getAmountsOut(_amount, path);
            _amount = estimates[estimates.length - 1]; // This is the amount of WETH returned
            return _amount;
        }else{
            address[] memory path = new address[](3);
            path[0] = address(tokenList[_inID].token);
            path[1] = WETH_ADDRESS;
            path[2] = address(tokenList[_outID].token);
            uint256[] memory estimates = router.getAmountsOut(_amount, path);
            _amount = estimates[estimates.length - 1];
            return _amount;            
        }
    }

    function exchange(uint256 _inID, uint256 _outID, uint256 _amount) internal {

        UniswapRouter router = UniswapRouter(UNISWAP_ROUTER_ADDRESS);
        UniswapLikeLPToken lpPool = UniswapLikeLPToken(UNISWAP_AMPLETH_LP);
        lpPool.sync();
        if(_outID == WETH_ID){
            address[] memory path = new address[](2);
            path[0] = address(tokenList[_inID].token);
            path[1] = WETH_ADDRESS;
            tokenList[_inID].token.safeApprove(UNISWAP_ROUTER_ADDRESS, 0);
            tokenList[_inID].token.safeApprove(UNISWAP_ROUTER_ADDRESS, _amount);
            router.swapExactTokensForTokens(_amount, 1, path, address(this), now.add(60));
            return;
        }else{
            address[] memory path = new address[](3);
            path[0] = address(tokenList[_inID].token);
            path[1] = WETH_ADDRESS;
            path[2] = address(tokenList[_outID].token);
            tokenList[_inID].token.safeApprove(UNISWAP_ROUTER_ADDRESS, 0);
            tokenList[_inID].token.safeApprove(UNISWAP_ROUTER_ADDRESS, _amount);
            router.swapExactTokensForTokens(_amount, 1, path, address(this), now.add(60));
            return;           
        }
    }
    
    function estimateSellAtMaximumProfit(uint256 originID, uint256 targetID, uint256 _tokenBalance) internal view returns (uint256) {

        
        uint256 _minAmount = _tokenBalance.mul(DIVISION_FACTOR.div(1000)).div(DIVISION_FACTOR);
        if(_minAmount == 0){ return 0; } // Nothing to sell, can't calculate
        uint256 _minReturn = _minAmount.mul(10**tokenList[targetID].decimals).div(10**tokenList[originID].decimals); // Convert decimals
        uint256 _return = simulateExchange(originID, targetID, _minAmount);
        if(_return <= _minReturn){
            return 0; // We are not going to gain from this trade
        }
        _return = _return.mul(10**tokenList[originID].decimals).div(10**tokenList[targetID].decimals); // Convert to origin decimals
        uint256 _startPrice = _return.mul(1e18).div(_minAmount);
        
        uint256 _bigAmount = _tokenBalance.mul(DIVISION_FACTOR).div(DIVISION_FACTOR);
        _return = simulateExchange(originID, targetID, _bigAmount);
        _return = _return.mul(10**tokenList[originID].decimals).div(10**tokenList[targetID].decimals); // Convert to origin decimals
        uint256 _endPrice = _return.mul(1e18).div(_bigAmount);
        if(_endPrice >= _startPrice){
            return _bigAmount;
        }
        
        uint256 scaleFactor = uint256(1).mul(10**tokenList[originID].decimals);
        uint256 _targetAmount = _startPrice.sub(1e18).mul(scaleFactor).div(_startPrice.sub(_endPrice).mul(scaleFactor).div(_bigAmount.sub(_minAmount))).div(2);
        if(_targetAmount > _bigAmount){
            return _bigAmount;
        }
        return _targetAmount;
    }
    
    function getFastGasPrice() internal view returns (uint256) {

        AggregatorV3Interface gasOracle = AggregatorV3Interface(GAS_ORACLE_ADDRESS);
        ( , int intGasPrice, , , ) = gasOracle.latestRoundData(); // We only want the answer 
        return uint256(intGasPrice);
    }
    
    function getAmplUSDPrice() public view returns (uint256) {

        AggregatorV3Interface priceOracle = AggregatorV3Interface(AMPL_PRICE_ORACLE);
        ( , int256 intPrice, , , ) = priceOracle.latestRoundData(); // We only want the answer 
        return uint256(intPrice);
    }
    
    function calculateTokenToSell() internal view returns (uint256, uint256, bool) {

        uint256 currentSupply = tokenList[0].token.totalSupply();
        int256 currentPrice = int256(getAmplUSDPrice());
        int256 percentChange = (currentPrice - int256(lastAmplPrice)) * int256(DIVISION_FACTOR) / int256(lastAmplPrice);
        if(percentChange > 100000) {percentChange = 100000;} // We only act on at most 100% change
        if(percentChange < -100000) {percentChange = -100000;}
        if(currentSupply > lastAmplTotalSupply){
            
            uint256 sellPercent;
            if(int256(amplSupplyChangeFactor) <= percentChange * int256(amplSellAmplificationFactor)){
                sellPercent = 0;
            }else if(percentChange > 0){
                sellPercent = amplSupplyChangeFactor.sub(uint256(percentChange).mul(amplSellAmplificationFactor));
            }else{
                sellPercent = amplSupplyChangeFactor.add(uint256(-percentChange).mul(amplSellAmplificationFactor));
            }
            if(sellPercent > DIVISION_FACTOR){sellPercent = DIVISION_FACTOR;}
            
            uint256 changedAmplPercent = currentSupply.sub(lastAmplTotalSupply).mul(DIVISION_FACTOR).div(lastAmplTotalSupply);
            uint256 changedAmpl = tokenList[0].token.balanceOf(address(this)).mul(changedAmplPercent).div(DIVISION_FACTOR);
            
            uint256 _amount = changedAmpl.mul(sellPercent).div(DIVISION_FACTOR); // This the amount to sell
            
            _amount = _amount.mul(1e18).div(10**tokenList[0].decimals);
            return (changedAmplPercent, _amount, true);
        }else{
            
            uint256 changedAmplPercent = lastAmplTotalSupply.sub(currentSupply).mul(DIVISION_FACTOR).div(lastAmplTotalSupply);
            
            if(percentChange > 0){
                
                uint256 sellPercent = changedAmplPercent.mul(usdcSupplyChangeFactor.add(uint256(percentChange).mul(usdcSellAmplificationFactor))).div(DIVISION_FACTOR);
                if(sellPercent > DIVISION_FACTOR){sellPercent = DIVISION_FACTOR;}
                
                uint256 _amount = tokenList[1].token.balanceOf(address(this)).mul(sellPercent).div(DIVISION_FACTOR);
                
                _amount = _amount.mul(1e18).div(10**tokenList[1].decimals);
                return (changedAmplPercent, _amount, false);
            }else{
                return (changedAmplPercent, 0, false); // Do not sell if negative percent change
            }
        }
    }
    
    function expectedProfit(bool inWETHForExecutor) external view returns (uint256) {

        uint256 currentSupply = tokenList[0].token.totalSupply();
        uint256 sellBalance = 0;
        uint256 _normalizedGain;
        uint256 targetID;
        bool expansion = false;
        if(currentSupply == lastAmplTotalSupply && _tokenToSell == 0) { return 0; } // Nothing to gain
        if(currentSupply != lastAmplTotalSupply){
            (, sellBalance, expansion) = calculateTokenToSell();
        }else{
            sellBalance = _tokenToSell; // This is normalized
            expansion = _inExpansion;
        }
        
        if(sellBalance > 0){
            uint256 originID = 0;
            if(expansion == true){
                targetID = 1;
                originID = 0;
            }else{
                targetID = 0;
                originID = 1;
            }
            sellBalance = sellBalance.mul(10**tokenList[originID].decimals).div(1e18); // Convert from normalized
            uint256 _bal = tokenList[originID].token.balanceOf(address(this));
            if(sellBalance > _bal){
                sellBalance = _bal;
            }
            if(sellBalance > 0){
                uint256 _maxTradeTarget = maxAmountSell.mul(10**tokenList[originID].decimals); // Determine the maximum amount of tokens to sell at once
                sellBalance = estimateSellAtMaximumProfit(originID, targetID, sellBalance);
                if(sellBalance > _maxTradeTarget){
                    sellBalance = _maxTradeTarget;
                }
            }
            if(sellBalance > 0){
                uint256 minReceiveBalance = sellBalance.mul(10**tokenList[targetID].decimals).div(10**tokenList[originID].decimals); // Change to match decimals of destination
                uint256 estimate = simulateExchange(originID, targetID, sellBalance);
                if(estimate > minReceiveBalance){
                    uint256 _gain = estimate.sub(minReceiveBalance).mul(1e18).div(10**tokenList[targetID].decimals); // Normalized gain
                    _normalizedGain = _normalizedGain.add(_gain);
                }                        
            }
        }
        
        if(inWETHForExecutor == false){
            return _normalizedGain; // This will be in stablecoins
        }else{
            if(_normalizedGain == 0){
                return 0;
            }
            uint256 estimate = 0;
            if(_normalizedGain > 0){
                sellBalance = _normalizedGain.mul(10**tokenList[targetID].decimals).div(1e18); // Convert to target decimals
                sellBalance = sellBalance.mul(DIVISION_FACTOR.sub(percentDepositor)).div(DIVISION_FACTOR);
                estimate = simulateExchange(targetID, WETH_ID, sellBalance);           
            }
            uint256 gasFee = getFastGasPrice().mul(gasStipend); // This is gas stipend in wei
            if(gasFee >= estimate.mul(maxPercentStipend).div(DIVISION_FACTOR)){ // Max percent of total
                return estimate.mul(maxPercentStipend).div(DIVISION_FACTOR); // The executor will get max percent of total
            }else{
                estimate = estimate.sub(gasFee); // Subtract fee from remaining balance
                return estimate.mul(percentExecutor).div(DIVISION_FACTOR).add(gasFee); // Executor amount with fee added
            }
        }  
    }
    
    function checkAndSwapTokens(address _executor) internal {

        uint256 currentSupply = tokenList[0].token.totalSupply();
        if(currentSupply == lastAmplTotalSupply && _tokenToSell == 0) { return; } // Nothing to gain
        if(currentSupply != lastAmplTotalSupply){
            (lastRebasePercent, _tokenToSell, _inExpansion) = calculateTokenToSell();
            lastAmplTotalSupply = currentSupply;
            lastAmplPrice = getAmplUSDPrice();
        }
        if(_executor == address(0)){ return; } // No executor running this code, return
        
        lastTradeTime = now;
        
        uint256 sellBalance = _tokenToSell;
        uint256 targetID = 0;
        bool _expectIncrease = false;
        uint256 _totalBalance = balance(); // Get the token balance at this contract, should increase
        if(sellBalance > 0){
            uint256 originID = 0;
            if(_inExpansion == true){
                targetID = 1;
                originID = 0;
            }else{
                targetID = 0;
                originID = 1;
            }
            sellBalance = sellBalance.mul(10**tokenList[originID].decimals).div(1e18); // Convert from normalized
            uint256 _bal = tokenList[originID].token.balanceOf(address(this));
            if(sellBalance > _bal){
                sellBalance = _bal;
                _tokenToSell = 0; // There are no more tokens to sell
            }
            if(sellBalance > 0){
                uint256 _maxTradeTarget = maxAmountSell.mul(10**tokenList[originID].decimals); // Determine the maximum amount of tokens to sell at once
                sellBalance = estimateSellAtMaximumProfit(originID, targetID, sellBalance);
                if(sellBalance > _maxTradeTarget){
                    sellBalance = _maxTradeTarget;
                }
            }
            if(sellBalance > 0){
                uint256 minReceiveBalance = sellBalance.mul(10**tokenList[targetID].decimals).div(10**tokenList[originID].decimals); // Change to match decimals of destination
                uint256 estimate = simulateExchange(originID, targetID, sellBalance);
                if(estimate > minReceiveBalance){
                    _expectIncrease = true;
                    exchange(originID, targetID, sellBalance);
                    if(_tokenToSell > 0){
                        _tokenToSell = _tokenToSell.sub(sellBalance.mul(1e18).div(10**tokenList[originID].decimals));
                    }
                }                        
            }
        }
        uint256 _newBalance = balance();
        if(_expectIncrease == true){
            require(_newBalance > _totalBalance, "Failed to gain in balance from selling tokens");
        }else{
            _tokenToSell = 0; // No gain expected? stop possible trades
        }
        uint256 gain = _newBalance.sub(_totalBalance);

        IERC20 weth = IERC20(WETH_ADDRESS);
        uint256 _wethBalance = weth.balanceOf(address(this));
        if(gain >= minGain){
            sellBalance = gain.mul(10**tokenList[targetID].decimals).div(1e18); // Convert to target decimals
            sellBalance = sellBalance.mul(uint256(100000).sub(percentDepositor)).div(DIVISION_FACTOR);
            if(sellBalance <= tokenList[targetID].token.balanceOf(address(this))){
                exchange(targetID, WETH_ID, sellBalance);
                _wethBalance = weth.balanceOf(address(this));
            }
        }
        if(_wethBalance > 0){
            if(_executor != address(0)){
                uint256 maxGasFee = getFastGasPrice().mul(gasStipend); // This is gas stipend in wei
                uint256 gasFee = tx.gasprice.mul(gasStipend); // This is gas fee requested
                if(gasFee > maxGasFee){
                    gasFee = maxGasFee; // Gas fee cannot be greater than the maximum
                }
                uint256 executorAmount = gasFee;
                if(gasFee >= _wethBalance.mul(maxPercentStipend).div(DIVISION_FACTOR)){
                    executorAmount = _wethBalance.mul(maxPercentStipend).div(DIVISION_FACTOR); // The executor will get the entire amount up to point
                }else{
                    executorAmount = _wethBalance.sub(gasFee).mul(percentExecutor).div(DIVISION_FACTOR).add(gasFee);
                }
                if(executorAmount > 0){
                    weth.safeTransfer(_executor, executorAmount);
                    _wethBalance = weth.balanceOf(address(this)); // Recalculate WETH in contract           
                }
            }
            if(_wethBalance > 0){
                uint256 stakersAmount = _wethBalance.mul(percentStakers).div(DIVISION_FACTOR);
                uint256 treasuryAmount = _wethBalance.sub(stakersAmount);
                if(treasuryAmount > 0){
                    weth.safeTransfer(treasuryAddress, treasuryAmount);
                }
                if(stakersAmount > 0){
                    if(stakingAddress != address(0)){
                        weth.safeTransfer(stakingAddress, stakersAmount);
                        StabilizeStakingPool(stakingAddress).notifyRewardAmount(stakersAmount);                                
                    }else{
                        weth.safeTransfer(treasuryAddress, stakersAmount);
                    }
                }
            }                
        }
    }
    
    function getPredictedWithdrawFee() public view returns (uint256) {

        uint256 currentSupply = tokenList[0].token.totalSupply();
        if(currentSupply != lastAmplTotalSupply){
            (uint256 rebasePercent, , bool expansion) = calculateTokenToSell();
            if(expansion == false){
                if(rebasePercent > minWithdrawFee){
                    return rebasePercent;
                }else{
                    return minWithdrawFee;
                }
            }else{
                return minWithdrawFee;
            }
        }else{
            if(_inExpansion == false){
                if(lastRebasePercent > minWithdrawFee){
                    return lastRebasePercent;
                }else{
                    return minWithdrawFee;
                }
            }else{
                return minWithdrawFee;
            }
        }
    }
    
    function deductWithdrawFee(uint256 tokenID, uint256 feeAmount, bool lastUser) internal {

        if(lastUser == false){
            feeAmount = feeAmount.mul(DIVISION_FACTOR.sub(percentDepositor)).div(DIVISION_FACTOR); // Keep some for depositors
        }
        if(feeAmount > 0){
            exchange(tokenID, WETH_ID, feeAmount);
        }
        IERC20 weth = IERC20(WETH_ADDRESS);
        uint256 _wethBalance = weth.balanceOf(address(this));
        if(_wethBalance > 0){
            uint256 stakersAmount = _wethBalance.mul(percentStakers).div(DIVISION_FACTOR);
            uint256 treasuryAmount = _wethBalance.sub(stakersAmount);
            if(treasuryAmount > 0){
                weth.safeTransfer(treasuryAddress, treasuryAmount);
            }
            if(stakersAmount > 0){
                if(stakingAddress != address(0)){
                    weth.safeTransfer(stakingAddress, stakersAmount);
                    StabilizeStakingPool(stakingAddress).notifyRewardAmount(stakersAmount);                                
                }else{
                    weth.safeTransfer(treasuryAddress, stakersAmount);
                }
            }
        }
    }
    
    function withdraw(address _depositor, uint256 _share, uint256 _total, bool nonContract) public onlyZSToken returns (uint256) {

        require(balance() > 0, "There are no tokens in this strategy");
        if(nonContract == false) {}
        uint256 feePercent = 0;
        if(_depositor != zsTokenAddress){
            checkAndSwapTokens(address(0));
            feePercent = getPredictedWithdrawFee(); // Fee is applied to these addresses
        }

        uint256 withdrawAmount = 0;
        uint256 _balance = balance();
        if(_share < _total){
            uint256 _myBalance = _balance.mul(_share).div(_total);
            withdrawPerOrderWithFee(_depositor, _myBalance, false, feePercent); // This will withdraw based on token price
            withdrawAmount = _myBalance;
        }else{
            withdrawPerOrderWithFee(_depositor, _balance, true, feePercent);
            withdrawAmount = _balance;
        }       
        lastActionBalance = balance();
        
        return withdrawAmount;
    }
    
    function withdrawPerOrderWithFee(address _receiver, uint256 _withdrawAmount, bool _takeAll, uint256 withdrawFee) internal {

        uint256 length = tokenList.length;
        if(_takeAll == true){
            for(uint256 i = 0; i < length; i++){
                uint256 _balance = tokenList[i].token.balanceOf(address(this));
                if(_balance > 0){
                    uint256 feeAmount = _balance.mul(withdrawFee).div(DIVISION_FACTOR);
                    if(feeAmount > 0){
                        _balance = _balance.sub(feeAmount);
                        deductWithdrawFee(i, feeAmount, true);
                    }
                    tokenList[i].token.safeTransfer(_receiver, _balance);
                }
            }
            return;
        }
        
        for(uint256 i = 0; i < length; i++){
            uint256 _normalizedBalance = tokenList[i].token.balanceOf(address(this)).mul(1e18).div(10**tokenList[i].decimals);
            if(_normalizedBalance <= _withdrawAmount){
                if(_normalizedBalance > 0){
                    _withdrawAmount = _withdrawAmount.sub(_normalizedBalance);
                    uint256 _balance = tokenList[i].token.balanceOf(address(this));
                    uint256 feeAmount = _balance.mul(withdrawFee).div(DIVISION_FACTOR);
                    if(feeAmount > 0){
                        _balance = _balance.sub(feeAmount);
                        deductWithdrawFee(i, feeAmount, false);
                    }
                    tokenList[i].token.safeTransfer(_receiver, _balance);                    
                }
            }else{
                if(_withdrawAmount > 0){
                    uint256 _balance = _withdrawAmount.mul(10**tokenList[i].decimals).div(1e18);
                    _withdrawAmount = 0;
                    uint256 feeAmount = _balance.mul(withdrawFee).div(DIVISION_FACTOR);
                    if(feeAmount > 0){
                        _balance = _balance.sub(feeAmount);
                        deductWithdrawFee(i, feeAmount, false);
                    }
                    tokenList[i].token.safeTransfer(_receiver, _balance);
                }
                break; // Nothing more to withdraw
            }
        }
    }
    
    function executorSwapTokens(address _executor, uint256 _minSecSinceLastTrade) external {

        require(now.sub(lastTradeTime) >= _minSecSinceLastTrade, "The last trade was too recent");
        require(_msgSender() == tx.origin, "Contracts cannot interact with this function");
        checkAndSwapTokens(_executor);
    }
    
    function governanceSwapTokens() external onlyGovernance {

        checkAndSwapTokens(governance());
    }

    function changeTradingConditions(uint256 _pSellPercent, 
                                    uint256 _maxSell,
                                    uint256 _pStipend,
                                    uint256 _maxStipend,
                                    uint256 _minGain,
                                    uint256 aFactor,
                                    uint256 uFactor,
                                    uint256 aAmplifer,
                                    uint256 uAmplifer) external onlyGovernance {

        require( _pSellPercent <= 100000 && _pStipend <= 100000,"Percent cannot be greater than 100%");

        maxPercentSell = _pSellPercent;
        maxAmountSell = _maxSell;
        maxPercentStipend = _pStipend;
        gasStipend = _maxStipend;
        minGain = _minGain;
        amplSupplyChangeFactor = aFactor;
        usdcSupplyChangeFactor = uFactor;
        amplSellAmplificationFactor = aAmplifer;
        usdcSellAmplificationFactor = uAmplifer;
    }
    
    function governanceRemoveStuckToken(address _token, uint256 _amount) external onlyGovernance {

        uint256 length = tokenList.length;
        for(uint256 i = 0; i < length; i++){
            require(_token != address(tokenList[i].token), "Cannot remove native token");
        }
        IERC20(_token).safeTransfer(governance(), _amount);
    }
    
    
    uint256 private _timelockStart; // The start of the timelock to change governance variables
    uint256 private _timelockType; // The function that needs to be changed
    uint256 constant TIMELOCK_DURATION = 86400; // Timelock is 24 hours
    
    address private _timelock_address;
    uint256[5] private _timelock_data;
    
    modifier timelockConditionsMet(uint256 _type) {

        require(_timelockType == _type, "Timelock not acquired for this function");
        _timelockType = 0; // Reset the type once the timelock is used
        if(balance() > 0){ // Timelock only applies when balance exists
            require(now >= _timelockStart + TIMELOCK_DURATION, "Timelock time not met");
        }
        _;
    }
    
    function startGovernanceChange(address _address) external onlyGovernance {

        _timelockStart = now;
        _timelockType = 1;
        _timelock_address = _address;       
    }
    
    function finishGovernanceChange() external onlyGovernance timelockConditionsMet(1) {

        transferGovernance(_timelock_address);
    }
    
    function startChangeTreasury(address _address) external onlyGovernance {

        _timelockStart = now;
        _timelockType = 2;
        _timelock_address = _address;
    }
    
    function finishChangeTreasury() external onlyGovernance timelockConditionsMet(2) {

        treasuryAddress = _timelock_address;
    }
    
    function startChangeStakingPool(address _address) external onlyGovernance {

        _timelockStart = now;
        _timelockType = 3;
        _timelock_address = _address;
    }
    
    function finishChangeStakingPool() external onlyGovernance timelockConditionsMet(3) {

        stakingAddress = _timelock_address;
    }
    
    function startChangeZSToken(address _address) external onlyGovernance {

        _timelockStart = now;
        _timelockType = 4;
        _timelock_address = _address;
    }
    
    function finishChangeZSToken() external onlyGovernance timelockConditionsMet(4) {

        zsTokenAddress = _timelock_address;
    }
    
    
    function startChangeStrategyAllocations(uint256 _pDepositors, 
                                            uint256 _pExecutor, uint256 _pStakers, uint256 _maxPool) external onlyGovernance {

        require(_pDepositors <= 100000 && _pExecutor <= 100000 && _pStakers <= 100000,"Percent cannot be greater than 100%");
        _timelockStart = now;
        _timelockType = 5;
        _timelock_data[0] = _pDepositors;
        _timelock_data[1] = _pExecutor;
        _timelock_data[2] = _pStakers;
        _timelock_data[3] = _maxPool;
    }
    
    function finishChangeStrategyAllocations() external onlyGovernance timelockConditionsMet(5) {

        percentDepositor = _timelock_data[0];
        percentExecutor = _timelock_data[1];
        percentStakers = _timelock_data[2];
        maxPoolSize = _timelock_data[3];
    }
    
    function startChangeMinWithdrawFee(uint256 _fee) external onlyGovernance {

        require(_fee <= 25000, "The fee is too high");
        _timelockStart = now;
        _timelockType = 6;
        _timelock_data[0] = _fee;
    }
    
    function finishChangeMinWIthdrawFee() external onlyGovernance timelockConditionsMet(6) {

        minWithdrawFee = _timelock_data[0];
    }
}