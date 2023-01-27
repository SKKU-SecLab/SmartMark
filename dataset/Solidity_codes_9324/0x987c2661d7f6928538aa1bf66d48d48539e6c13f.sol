

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

interface LendingPoolAddressesProvider {

    function getLendingPool() external view returns (address);

}

interface LendingPool {

  function flashLoan(address, address[] calldata, uint256[] calldata, uint256[] calldata, address, bytes calldata params, uint16) external;

}

interface AggregatorV3Interface {

  function latestRoundData() external view returns (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound);

}

interface WrappedEther {

    function withdraw(uint256) external;

    function deposit() external payable;

}

interface FeiToken {

    function incentiveContract(address) external view returns (address); // Returns the Incentive contract for an LP token contract

}

interface FeiIncentiveContract {

    function getBuyIncentive(uint256 amount) external view returns (uint256, uint32);

    function getSellPenalty(uint256 amount) external view returns (uint256, uint32);

}

interface FeiBondingCurve {

    function getAmountOut(uint256 amountIn) external view returns (uint256 amountOut);

    function purchase(address to, uint256 amountIn) external payable returns (uint256 amountOut);

    function paused() external view returns (bool);

}

interface FeiOracle{

    function update() external returns (bool);

}

contract StabilizeStrategyFEIArbV2 is Ownable {

    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    using Address for address;
    
    address public treasuryAddress; // Address of the treasury
    address public stakingAddress; // Address to the STBZ staking pool
    address public zsTokenAddress; // The address of the controlling zs-Token
    
    uint256 constant DIVISION_FACTOR = 100000;
    uint256 public lastTradeTime = 0;
    uint256 public lastActionBalance = 0; // Balance before last deposit or withdraw
    uint256 public maxPoolSize = 10000000e18; // The maximum amount of ust tokens this strategy can hold, 10 mil by default
    uint256 public percentTradeTrigger = 10000; // 10% change in value will trigger a trade
    uint256 public maxPercentSell = 80000; // Up to 80% of the tokens are sold to the cheapest token
    uint256 public maxAmountSell = 500000; // The maximum amount of tokens that can be sold at once
    uint256 public percentDepositor = 50000; // 1000 = 1%, depositors earn 50% of all gains
    uint256 public percentFlashDepositor = 10000; // Depositors by default get 10% of flash loan profit, since funds aren't used for trade
    uint256 public percentExecutor = 10000; // 10000 = 10% of WETH goes to executor, 5% of total profit. This is on top of gas stipend
    uint256 public percentStakers = 50000; // 50% of non-depositors WETH goes to stakers, can be changed
    uint256 public minTradeSplit = 20000; // If the balance is less than or equal to this, it trades the entire balance
    uint256 public maxPercentStipend = 30000; // The maximum amount of WETH profit that can be allocated to the executor for gas in percent
    uint256 public gasStipend = 2000000; // This is the gas units that are covered by executing a trade taken from the WETH profit
    bool public incentiveActive = false; // FEI has disabled the incentive calculator
    uint256[3] private flashParams; // Global parameters guiding the flash loan setup
    uint256 constant minGain = 1e16; // Minimum amount of gain (0.01 coin) before buying WETH and splitting it
    
    struct TokenInfo {
        IERC20 token; // Reference of token
        uint256 decimals; // Decimals of token
    }
    
    TokenInfo[] private tokenList; // An array of tokens accepted as deposits

    address constant UNISWAP_ROUTER_ADDRESS = address(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D); //Address of Uniswap
    address constant WETH_ADDRESS = address(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
    address constant GAS_ORACLE_ADDRESS = address(0x169E633A2D1E6c10dD91238Ba11c4A708dfEF37C); // Chainlink address for fast gas oracle
    address constant LENDING_POOL_ADDRESS_PROVIDER = address(0xB53C1a33016B2DC2fF3653530bfF1848a515c8c5); // Provider for Aave addresses
    address constant FEI_LP_CONTRACT = address(0x94B0A3d511b6EcDb17eBF877278Ab030acb0A878);
    address constant FEI_BONDING_CURVE = address(0xe1578B4a32Eaefcd563a9E6d0dc02a4213f673B7); // ETH Bonding curve
    address constant FEI_UNISWAP_ORACLE = address(0x087F35bd241e41Fc28E43f0E8C58d283DD55bD65);
    address constant FEI_BONDING_ORACLE = address(0x89714d3AC9149426219a3568543200D1964101C4);
    uint256 constant MAX_ETH_BUY = 1000 ether;
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
    }

    
    function setupWithdrawTokens() internal {

        IERC20 _token = IERC20(address(0x956F47F50A910163D8BF957Cf5846D573E7f87CA));
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
    
    
    receive() external payable {
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
    
    function simulateExchange(uint256 _inID, uint256 _outID, uint256 _amount, bool doFlashLoan) internal view returns (uint256) {

        if(doFlashLoan == false){
            UniswapRouter router = UniswapRouter(UNISWAP_ROUTER_ADDRESS);
            if(_inID == 0){
                _amount = applyFEIFee(_amount);
                if(_amount == 0){return 0;}
            }
            
            if(_inID == _outID) { return 0;}
            if(_inID == WETH_ID || _outID == WETH_ID){
                address _inputToken;
                address _outputToken;
                if(_inID == WETH_ID){
                    _inputToken = WETH_ADDRESS;
                    _outputToken = address(tokenList[_outID].token);
                }else{
                    _inputToken = address(tokenList[_inID].token); 
                    _outputToken = WETH_ADDRESS;          
                }
                address[] memory path = new address[](2);
                path[0] = _inputToken;
                path[1] = _outputToken;
                uint256[] memory estimates = router.getAmountsOut(_amount, path);
                _amount = estimates[estimates.length - 1]; // Get output amount
            }else{
                address _inputToken = address(tokenList[_inID].token);
                address _outputToken = address(tokenList[_outID].token);
                address[] memory path = new address[](3);
                path[0] = _inputToken;
                path[1] = WETH_ADDRESS;
                path[2] = _outputToken;
                uint256[] memory estimates = router.getAmountsOut(_amount, path);
                _amount = estimates[estimates.length - 1]; // Get output amount                
            }
            
            if(_outID == 0){
                _amount = applyFEIBonus(_amount);
            }
            return _amount;
        }else{
            if(_inID != WETH_ID || _outID != WETH_ID) { return 0; } // Only can use ETH
            FeiBondingCurve bond = FeiBondingCurve(FEI_BONDING_CURVE);
            if(bond.paused() == true) { return 0; } // Not active
            _amount = bond.getAmountOut(_amount); // Will return FEI back
            _amount = simulateExchange(0, WETH_ID, _amount, false); // Will return ETH back
            return _amount;
        }
    }

    function applyFEIFee(uint256 _amount) internal view returns (uint256) {

        if(incentiveActive == false) { return _amount; }
        FeiIncentiveContract incCon = FeiIncentiveContract(FeiToken(address(tokenList[0].token)).incentiveContract(FEI_LP_CONTRACT));
        (uint256 feiFee,) = incCon.getSellPenalty(_amount);
        if(feiFee >= _amount) { return 0;}
        return _amount.sub(feiFee);
    }
    
    function applyFEIBonus(uint256 _amount) internal view returns (uint256) {

        if(incentiveActive == false) { return _amount; }
        FeiIncentiveContract incCon = FeiIncentiveContract(FeiToken(address(tokenList[0].token)).incentiveContract(FEI_LP_CONTRACT));
        (uint256 feiBonus,) = incCon.getBuyIncentive(_amount);
        return _amount.add(feiBonus);
    }
    
    function exchange(uint256 _inID, uint256 _outID, uint256 _amount, bool doFlashLoan) internal {

        if(doFlashLoan == false){
            UniswapRouter router = UniswapRouter(UNISWAP_ROUTER_ADDRESS);
            if(_inID == _outID) { return;}
            if(_inID == WETH_ID || _outID == WETH_ID){
                address _inputToken;
                address _outputToken;
                if(_inID == WETH_ID){
                    _inputToken = WETH_ADDRESS;
                    _outputToken = address(tokenList[_outID].token);
                }else{
                    _inputToken = address(tokenList[_inID].token); 
                    _outputToken = WETH_ADDRESS;          
                }
                address[] memory path = new address[](2);
                path[0] = _inputToken;
                path[1] = _outputToken;
                IERC20(_inputToken).safeApprove(UNISWAP_ROUTER_ADDRESS, 0);
                IERC20(_inputToken).safeApprove(UNISWAP_ROUTER_ADDRESS, _amount);
                router.swapExactTokensForTokensSupportingFeeOnTransferTokens(_amount, 1, path, address(this), now.add(60));
                return;
            }else{
                address _inputToken = address(tokenList[_inID].token);
                address _outputToken = address(tokenList[_outID].token);
                address[] memory path = new address[](3);
                path[0] = _inputToken;
                path[1] = WETH_ADDRESS;
                path[2] = _outputToken;
                IERC20(_inputToken).safeApprove(UNISWAP_ROUTER_ADDRESS, 0);
                IERC20(_inputToken).safeApprove(UNISWAP_ROUTER_ADDRESS, _amount);
                router.swapExactTokensForTokensSupportingFeeOnTransferTokens(_amount, 1, path, address(this), now.add(60));
                return;              
            }            
        }else{
            if(_inID != WETH_ID || _outID != WETH_ID) { return; } // Only can use ETH
            FeiBondingCurve bond = FeiBondingCurve(FEI_BONDING_CURVE);
            WrappedEther(WETH_ADDRESS).withdraw(_amount);
            uint256 _bal = tokenList[0].token.balanceOf(address(this));
            bond.purchase{value: _amount}(address(this), _amount); // Buy FEI from bonding curve with ETH
            _amount = tokenList[0].token.balanceOf(address(this)).sub(_bal); // Balance gain in FEI
            exchange(0, WETH_ID, _amount, false); // Buy WETH with FEI
            if(address(this).balance > 0){
                WrappedEther(WETH_ADDRESS).deposit{value: address(this).balance}();
            }
            return;      
        }
    }

    function getCheaperToken() internal view returns (uint256) {

        
        uint256 targetID = 0;
        uint256 mainAmount = uint256(1).mul(10**tokenList[0].decimals);
        
        uint256 estimate = 0;
        estimate = simulateExchange(0,1,mainAmount,false);
        estimate = estimate.mul(10**tokenList[0].decimals).div(10**tokenList[1].decimals); // Convert to main decimals
        if(estimate > mainAmount){
            targetID = 1;
        }
        return targetID;
    }
    
    function estimateSellAtMaximumProfit(uint256 originID, uint256 targetID, uint256 _tokenBalance, bool doFlashLoan) internal view returns (uint256) {

        
        uint256 originDecimals = 0;
        uint256 targetDecimals = 0;
        if(doFlashLoan == false){
            originDecimals = tokenList[originID].decimals;
            targetDecimals = tokenList[targetID].decimals;
        }else{
            originDecimals = 18;
            targetDecimals = 18;
        }
        
        uint256 _minAmount = _tokenBalance.mul(maxPercentSell.div(1000)).div(DIVISION_FACTOR);
        if(_minAmount == 0){ return 0; } // Nothing to sell, can't calculate
        uint256 _minReturn = _minAmount.mul(10**targetDecimals).div(10**originDecimals); // Convert decimals
        uint256 _return = simulateExchange(originID, targetID, _minAmount, doFlashLoan);
        if(_return <= _minReturn){
            return 0; // We are not going to gain from this trade
        }
        _return = _return.mul(10**originDecimals).div(10**targetDecimals); // Convert to origin decimals
        uint256 _startPrice = _return.mul(1e18).div(_minAmount);
        
        uint256 _bigAmount = _tokenBalance.mul(maxPercentSell).div(DIVISION_FACTOR);
        _return = simulateExchange(originID, targetID, _bigAmount, doFlashLoan);
        _return = _return.mul(10**originDecimals).div(10**targetDecimals); // Convert to origin decimals
        uint256 _endPrice = _return.mul(1e18).div(_bigAmount);
        if(_endPrice >= _startPrice){
            return _bigAmount;
        }
        
        uint256 scaleFactor = uint256(1).mul(10**originDecimals);
        uint256 _targetAmount = _startPrice.sub(1e18).mul(scaleFactor).div(_startPrice.sub(_endPrice).mul(scaleFactor).div(_bigAmount.sub(_minAmount))).div(2);
        if(_targetAmount > _bigAmount){
            return _bigAmount;
        }
        return _targetAmount;
    }
    
    function estimateFlashLoanResult(uint256 _tradeSize, bool _asWETH) internal view returns (uint256) {

        uint256 fee = _tradeSize.mul(90).div(DIVISION_FACTOR); // This is the Aave fee (0.09%)
        uint256 _return = 0;
        _return = simulateExchange(WETH_ID, WETH_ID, _tradeSize, true);
        if(_return > _tradeSize.add(fee)){
            _return = _return.sub(fee).sub(_tradeSize); // This is return in WETH gain
            if(_asWETH == false){
                _return = simulateExchange(WETH_ID, 1, _return, false); // Convert return to USDC amount
                _return = _return.mul(1e18).div(10**tokenList[1].decimals); // Normalize return
            }
            return _return;
        }else{
            return 0; // Do not take out a flash loan as not enough gain
        }
    }
    
    function performFlashLoan(uint256 _amount) internal returns (uint256) {

        IERC20 weth = IERC20(WETH_ADDRESS);
        uint256 flashGain = weth.balanceOf(address(this)); // Get base weth amount
        
        flashParams[0] = 1; // Authorize flash loan receiving
        
        LendingPool lender = LendingPool(LendingPoolAddressesProvider(LENDING_POOL_ADDRESS_PROVIDER).getLendingPool()); // Load the lending pool
        
        address[] memory assets = new address[](1);
        assets[0] = address(WETH_ADDRESS);       
        
        uint256[] memory amounts = new uint256[](1);
        amounts[0] = _amount; // The amount we want to borrow
        
        uint256[] memory modes = new uint256[](1);
        modes[0] = 0; // Revert if we fail to return funds
        
        bytes memory params = "";
        lender.flashLoan(address(this), assets, amounts, modes, address(this), params, 0);
        
        flashParams[0] = 0; // Deactivate flash loan receiving
        uint256 newBal = weth.balanceOf(address(this));
        require(newBal > flashGain, "Flash loan failed to increase balance");
        flashGain = newBal.sub(flashGain);
        uint256 depositorPayout = 0;
        if(balance() > 0){
            depositorPayout = flashGain.mul(percentFlashDepositor).div(DIVISION_FACTOR);
            if(depositorPayout > 0){
                exchange(WETH_ID, 1, depositorPayout, false);
                flashGain = flashGain.sub(depositorPayout);
            }
        }
        return flashGain;
    }
    
    function executeOperation(
        address[] calldata assets,
        uint256[] calldata amounts,
        uint256[] calldata premiums,
        address initiator,
        bytes calldata params
    )
        external
        returns (bool)
    {

        require(flashParams[0] == 1, "No flash loan authorized on this contract");
        address lendingPool = LendingPoolAddressesProvider(LENDING_POOL_ADDRESS_PROVIDER).getLendingPool();
        require(_msgSender() == lendingPool, "Not called from Aave");
        require(initiator == address(this), "Not Authorized"); // Prevent other contracts from calling this function
        if(params.length == 0){} // Removes the warning
        flashParams[0] = 0; // Prevent a replay;
        
        exchange(WETH_ID, WETH_ID, amounts[0], true); // Buy WETH from bonding curve and sell on Uniswap
        
        {
            for(uint256 i = 0; i < assets.length; i++) {
                uint256 amountOwing = amounts[i].add(premiums[i]);
                IERC20(assets[i]).safeApprove(lendingPool, 0);
                IERC20(assets[i]).safeApprove(lendingPool, amountOwing);
            }
        }
        
        return true;
    }
    
    function getFastGasPrice() internal view returns (uint256) {

        AggregatorV3Interface gasOracle = AggregatorV3Interface(GAS_ORACLE_ADDRESS);
        ( , int intGasPrice, , , ) = gasOracle.latestRoundData(); // We only want the answer 
        return uint256(intGasPrice);
    }
    
    function checkAndSwapTokens(address _executor, uint256 targetID, bool doFlashLoan) internal {

        lastTradeTime = now;
        
        FeiOracle(FEI_UNISWAP_ORACLE).update();

        uint256 gain = 0;
        if(doFlashLoan == false){
            uint256 length = tokenList.length;
            uint256 _totalBalance = balance(); // Get the token balance at this contract, should increase
            bool _expectIncrease = false;
            for(uint256 i = 0; i < length; i++){
                if(i != targetID){
                    uint256 sellBalance = 0;
                    uint256 _bal = tokenList[i].token.balanceOf(address(this));
                    uint256 _minTradeTarget = minTradeSplit.mul(10**tokenList[i].decimals);
                    uint256 _maxTradeTarget = maxAmountSell.mul(10**tokenList[i].decimals); // Determine the maximum amount of tokens to sell at once
                    if(_bal <= _minTradeTarget){
                        sellBalance = _bal;
                    }else{
                        sellBalance = estimateSellAtMaximumProfit(i, targetID, _bal, false);
                    }
                    if(sellBalance > _maxTradeTarget){
                        sellBalance = _maxTradeTarget;
                    }
                    if(sellBalance > 0){
                        uint256 minReceiveBalance = sellBalance.mul(10**tokenList[targetID].decimals).div(10**tokenList[i].decimals); // Change to match decimals of destination
                        uint256 estimate = simulateExchange(i, targetID, sellBalance, false);
                        if(estimate > minReceiveBalance){
                            _expectIncrease = true;
                            exchange(i, targetID, sellBalance, false);
                        }                        
                    }
                }
            }
            uint256 _newBalance = balance();
            if(_expectIncrease == true){
                require(_newBalance > _totalBalance, "Failed to gain in balance from selling tokens");
            }
            gain = _newBalance.sub(_totalBalance);
        }else{
            FeiOracle(FEI_BONDING_ORACLE).update();
            uint256 tradeSize = estimateSellAtMaximumProfit(WETH_ID, WETH_ID, MAX_ETH_BUY, true); // This will return our ideal trade size
            if(tradeSize > 0){
                performFlashLoan(tradeSize); // Our weth balance should increase, otherwise this will revert
            }            
        }

        IERC20 weth = IERC20(WETH_ADDRESS);
        uint256 _wethBalance = weth.balanceOf(address(this));
        if(gain >= minGain){
            uint256 sellBalance = gain.mul(10**tokenList[targetID].decimals).div(1e18); // Convert to target decimals
            sellBalance = sellBalance.mul(uint256(100000).sub(percentDepositor)).div(DIVISION_FACTOR);
            if(sellBalance <= tokenList[targetID].token.balanceOf(address(this))){
                exchange(targetID, WETH_ID, sellBalance, false);
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
    
    function expectedProfit(bool inWETHForExecutor, bool checkFlashLoan) external view returns (uint256, uint256) {

        
        uint256 targetID = 0;
        uint256 _normalizedGain = 0;
        if(checkFlashLoan == false){
            targetID = getCheaperToken();
            uint256 length = tokenList.length;
            for(uint256 i = 0; i < length; i++){
                if(i != targetID){
                    uint256 sellBalance = 0;
                    uint256 _bal = tokenList[i].token.balanceOf(address(this));
                    uint256 _minTradeTarget = minTradeSplit.mul(10**tokenList[i].decimals);
                    uint256 _maxTradeTarget = maxAmountSell.mul(10**tokenList[i].decimals); // Determine the maximum amount of tokens to sell at once
                    if(_bal <= _minTradeTarget){
                        sellBalance = _bal;
                    }else{
                        sellBalance = estimateSellAtMaximumProfit(i, targetID, _bal, false);
                    }
                    if(sellBalance > _maxTradeTarget){
                        sellBalance = _maxTradeTarget;
                    }
                    if(sellBalance > 0){
                        uint256 minReceiveBalance = sellBalance.mul(10**tokenList[targetID].decimals).div(10**tokenList[i].decimals); // Change to match decimals of destination
                        uint256 estimate = simulateExchange(i, targetID, sellBalance, false);
                        if(estimate > minReceiveBalance){
                            uint256 _gain = estimate.sub(minReceiveBalance).mul(1e18).div(10**tokenList[targetID].decimals); // Normalized gain
                            _normalizedGain = _normalizedGain.add(_gain);
                        }                        
                    }
                }
            }
        }else{
            uint256 tradeSize = estimateSellAtMaximumProfit(WETH_ID, WETH_ID, MAX_ETH_BUY, true); // This will return our ideal trade size
            if(tradeSize > 0){
                _normalizedGain = estimateFlashLoanResult(tradeSize, inWETHForExecutor);
            }
        }

        if(inWETHForExecutor == false){
            return (_normalizedGain, 0); // This will be in stablecoins regardless of whether flash loan or not
        }else{
            if(_normalizedGain == 0){
                return (0, 0);
            }
            uint256 estimate = 0;
            if(checkFlashLoan == false){
                if(_normalizedGain > 0){
                    uint256 sellBalance = _normalizedGain.mul(10**tokenList[targetID].decimals).div(1e18); // Convert to target decimals
                    sellBalance = sellBalance.mul(uint256(100000).sub(percentDepositor)).div(DIVISION_FACTOR);
                    estimate = simulateExchange(targetID, WETH_ID, sellBalance, false);           
                }
            }else{
                if(balance() > 0){
                    estimate = _normalizedGain.mul(uint256(100000).sub(percentFlashDepositor)).div(DIVISION_FACTOR);
                }else{
                    estimate = _normalizedGain;
                }
            }
            uint256 gasFee = getFastGasPrice().mul(gasStipend); // This is gas stipend in wei
            if(gasFee >= estimate.mul(maxPercentStipend).div(DIVISION_FACTOR)){ // Max percent of total
                return (estimate.mul(maxPercentStipend).div(DIVISION_FACTOR), targetID); // The executor will get max percent of total
            }else{
                estimate = estimate.sub(gasFee); // Subtract fee from remaining balance
                return (estimate.mul(percentExecutor).div(DIVISION_FACTOR).add(gasFee), targetID); // Executor amount with fee added
            }
        }  
    }
    
    function withdraw(address _depositor, uint256 _share, uint256 _total, bool nonContract) public onlyZSToken returns (uint256) {

        require(balance() > 0, "There are no tokens in this strategy");
        if(nonContract == true){
            if( _share > _total.mul(percentTradeTrigger).div(DIVISION_FACTOR)){
                uint256 buyID = getCheaperToken();
                checkAndSwapTokens(address(0), buyID, false);
            }
        }
        
        uint256 withdrawAmount = 0;
        uint256 _balance = balance();
        if(_share < _total){
            uint256 _myBalance = _balance.mul(_share).div(_total);
            withdrawPerOrder(_depositor, _myBalance, false); // This will withdraw based on token price
            withdrawAmount = _myBalance;
        }else{
            withdrawPerOrder(_depositor, _balance, true);
            withdrawAmount = _balance;
        }       
        lastActionBalance = balance();
        
        return withdrawAmount;
    }
    
    function withdrawPerOrder(address _receiver, uint256 _withdrawAmount, bool _takeAll) internal {

        uint256 length = tokenList.length;
        if(_takeAll == true){
            for(uint256 i = 0; i < length; i++){
                uint256 _bal = tokenList[i].token.balanceOf(address(this));
                if(_bal > 0){
                    tokenList[i].token.safeTransfer(_receiver, _bal);
                }
            }
            return;
        }
        
        for(uint256 i = 0; i < length; i++){
            uint256 _normalizedBalance = tokenList[i].token.balanceOf(address(this)).mul(1e18).div(10**tokenList[i].decimals);
            if(_normalizedBalance <= _withdrawAmount){
                if(_normalizedBalance > 0){
                    _withdrawAmount = _withdrawAmount.sub(_normalizedBalance);
                    tokenList[i].token.safeTransfer(_receiver, tokenList[i].token.balanceOf(address(this)));                    
                }
            }else{
                if(_withdrawAmount > 0){
                    uint256 _balance = _withdrawAmount.mul(10**tokenList[i].decimals).div(1e18);
                    _withdrawAmount = 0;
                    tokenList[i].token.safeTransfer(_receiver, _balance);
                }
                break; // Nothing more to withdraw
            }
        }
    }
    
    function executorSwapTokens(address _executor, uint256 _minSecSinceLastTrade, uint256 _buyID, bool doFlash) external {

        require(now.sub(lastTradeTime) > _minSecSinceLastTrade, "The last trade was too recent");
        require(_msgSender() == tx.origin, "Contracts cannot interact with this function");
        checkAndSwapTokens(_executor, _buyID, doFlash);
    }
    
    function governanceSwapTokens(uint256 _buyID, bool doFlash) external onlyGovernance {

        checkAndSwapTokens(governance(), _buyID, doFlash);
    }

    function changeTradingConditions(uint256 _pTradeTrigger,
                                    uint256 _minSplit,
                                    uint256 _pSellPercent, 
                                    uint256 _maxSell,
                                    uint256 _pStipend,
                                    uint256 _maxStipend,
                                    bool _changeIncentive) external onlyGovernance {

        require(_pTradeTrigger <= 100000 && _pSellPercent <= 100000 && _pStipend <= 100000,"Percent cannot be greater than 100%");
        percentTradeTrigger = _pTradeTrigger;
        minTradeSplit = _minSplit;
        maxPercentSell = _pSellPercent;
        maxAmountSell = _maxSell;
        maxPercentStipend = _pStipend;
        gasStipend = _maxStipend;
        incentiveActive = _changeIncentive;
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
    
    
    function startChangeStrategyAllocations(uint256 _pDepositors, uint256 _pFDepositors, 
                                            uint256 _pExecutor, uint256 _pStakers, uint256 _maxPool) external onlyGovernance {

        require(_pDepositors <= 100000 && _pFDepositors <= 100000 && _pExecutor <= 100000 && _pStakers <= 100000,"Percent cannot be greater than 100%");
        _timelockStart = now;
        _timelockType = 5;
        _timelock_data[0] = _pDepositors;
        _timelock_data[1] = _pExecutor;
        _timelock_data[2] = _pStakers;
        _timelock_data[3] = _maxPool;
        _timelock_data[4] = _pFDepositors;
    }
    
    function finishChangeStrategyAllocations() external onlyGovernance timelockConditionsMet(5) {

        percentDepositor = _timelock_data[0];
        percentExecutor = _timelock_data[1];
        percentStakers = _timelock_data[2];
        maxPoolSize = _timelock_data[3];
        percentFlashDepositor = _timelock_data[4];
    }
}