pragma solidity 0.8.4;

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
}//MIT
pragma solidity 0.8.4;


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

}//MIT
pragma solidity 0.8.4;

interface IERC20 {


    function totalSupply() external view returns (uint256);

    
    function symbol() external view returns(string memory);

    
    function name() external view returns(string memory);


    function balanceOf(address account) external view returns (uint256);

    
    function decimals() external view returns (uint8);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}//MIT
pragma solidity 0.8.4;

abstract contract ReentrancyGuard {
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;
    uint256 private _status;
    constructor () {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");
        _status = _ENTERED;
        _;
        _status = _NOT_ENTERED;
    }
}//MIT
pragma solidity 0.8.4;



interface IUniswapV2Router01 {

    function factory() external pure returns (address);

    function WETH() external pure returns (address);


    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);

    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);

    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);

    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);

    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);

    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);

    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);

    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
    external
    payable
    returns (uint[] memory amounts);

    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
    external
    returns (uint[] memory amounts);

    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
    external
    returns (uint[] memory amounts);

    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
    external
    payable
    returns (uint[] memory amounts);


    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);

    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);

    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);

    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);

    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);

}

interface IUniswapV2Router02 is IUniswapV2Router01 {

    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);

    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);


    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;

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

}//MIT
pragma solidity 0.8.4;

interface IKeysStaking {

    function deposit(uint256 amount) external;

}//MIT
pragma solidity 0.8.4;


contract KEYSFarm is ReentrancyGuard, IERC20, IKeysStaking{


    using SafeMath for uint256;
    using Address for address;
    
    address constant KEYS = 0xe0a189C975e4928222978A74517442239a0b86ff;
    address constant KEYS_LP = 0x5BaCB4114Ad2D448E79aDdef121714b74D67faeC;
    
    IUniswapV2Router02 router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);

    uint256 constant precision = 10**36;
    
    uint256 public dividendsPerToken;
 
    uint256 public lockTime = 2534400;
    
    uint256 public harvestTime = 230400;
    
    struct StakedUser {
        uint256 tokensLocked;
        uint256 timeLocked;
        uint256 lastClaim;
        uint256 totalExcluded;
    }
    
    mapping ( address => StakedUser ) users;
    
    uint256 totalLocked;
    
    uint256 public fee = 1;
    
    uint256 public earlyFee = 8;
    
    address public multisig = 0xfCacEAa7b4cf845f2cfcE6a3dA680dF1BB05015c;
    
    bool receiveDisabled;
    bool refundEnabled = true;
    
    address public owner;
    modifier onlyOwner(){require(owner == msg.sender, 'Only Owner'); _;}

    
    event TransferOwnership(address newOwner);
    event UpdateFee(uint256 newFee);
    event UpdateLockTime(uint256 newTime);
    event UpdatedStakingMinimum(uint256 minimumKeys);
    event UpdatedFeeReceiver(address feeReceiver);
    event UpdatedEarlyFee(uint256 newFee);
    event UpdatedHarvestTime(uint256 newTime);
    
    constructor() {
        owner = 0xfCacEAa7b4cf845f2cfcE6a3dA680dF1BB05015c;
        
    }
    
    function totalSupply() external view override returns (uint256) { return totalLocked; }

    function balanceOf(address account) public view override returns (uint256) { return users[account].tokensLocked; }

    function allowance(address holder, address spender) external view override returns (uint256) { return holder == spender ? balanceOf(holder) : 0; }

    function name() public pure override returns (string memory) {

        return "Keys Farm";
    }
    function symbol() public pure override returns (string memory) {

        return "KEYSFARM";
    }
    function decimals() public pure override returns (uint8) {

        return 18;
    }
    function approve(address spender, uint256 amount) public view override returns (bool) {

        return users[msg.sender].tokensLocked >= amount && spender != msg.sender;
    }
    function transfer(address recipient, uint256 amount) external override returns (bool) {

        if (recipient == KEYS) {
            _unlock(msg.sender, msg.sender, amount, false);
        } else {
            _makeClaim(msg.sender);
        }
        return true;
    }
    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {

        if (recipient == KEYS) {
            _unlock(msg.sender, msg.sender, amount, false);
        } else {
            _makeClaim(msg.sender);
        }
        return true && sender == recipient;
    }
    
    
    
    function transferOwnership(address newOwner) external onlyOwner {

        owner = newOwner;
        emit TransferOwnership(newOwner);
    }
    
    function updateFee(uint256 newFee) external onlyOwner {

        require(earlyFee <= 5, 'Fee Too Large');
        fee = newFee;
        emit UpdateFee(newFee);
    }
    
    function setRefundEnabled(bool _refundEnabled) external onlyOwner {

        refundEnabled = _refundEnabled;
    }
    
    function updateFeeReceiver(address newReceiver) external onlyOwner {

        multisig = newReceiver;
        emit UpdatedFeeReceiver(newReceiver);
    }
    
    function setEarlyFee(uint256 newFee) external onlyOwner {

        require(earlyFee <= 30, 'Fee Too Large');
        earlyFee = newFee;
        emit UpdatedEarlyFee(newFee);
    }

    function setHarvestTime(uint256 newTime) external onlyOwner {

        require(newTime <= 10**7, 'Time Too Long');
        harvestTime = newTime;
        emit UpdatedHarvestTime(newTime);
    }
    
    function setLockTime(uint256 newTime) external onlyOwner {

        require(newTime <= 10**7, 'Lock Time Too Long');
        lockTime = newTime;
        emit UpdateLockTime(newTime);
    }
    
    function withdraw(bool ETH, address token, uint256 amount, address recipient) external onlyOwner {

        if (ETH) {
            require(address(this).balance >= amount, 'Insufficient Balance');
            (bool s,) = payable(recipient).call{value: amount}("");
            require(s, 'Failure on ETH Withdrawal');
        } else {
            require(token != KEYS_LP, 'Cannot Withdraw KEYS LP');
            IERC20(token).transfer(recipient, amount);
        }
    }
    
    

    function deposit(uint256 amount) external override {

        uint256 received = _transferIn(KEYS, amount);
        dividendsPerToken += received.mul(precision).div(totalLocked);
    }

    function claimReward() external nonReentrant {

        _makeClaim(msg.sender);      
    }
    
    function claimRewardForUser(address user) external nonReentrant {

        _makeClaim(user);
    }
    
    function unlock(uint256 amount) external nonReentrant {

        _unlock(msg.sender, msg.sender, amount, false);
    }
    
    function unlockFor(uint256 amount, address keysRecipient) external nonReentrant {

        _unlock(msg.sender, keysRecipient, amount, false);
    }
    
    function unlockAll() external nonReentrant {

        _unlock(msg.sender, msg.sender, users[msg.sender].tokensLocked, false);
    }
    
    function unstake(uint256 amount) external nonReentrant {

        _unlock(msg.sender, msg.sender, amount, true);
    }
    
    function unstakeAll() external nonReentrant {

        _unlock(msg.sender, msg.sender, users[msg.sender].tokensLocked, true);
    }
    
    function unstakeFor(uint256 amount, address recipient) external nonReentrant {

        _unlock(msg.sender, recipient, amount, true);
    }
    
    function stakeLP(uint256 numLPTokens) external nonReentrant {

        uint256 received = _transferIn(KEYS_LP, numLPTokens);
        _lock(msg.sender, received);
    }
    
    function stakeKeysAndETH(uint256 numKeys) external payable nonReentrant {

        require(numKeys >= 10 && msg.value >= 10**9, 'Minimum Amount');
        
        uint256 keysReceived = _transferIn(KEYS, numKeys);
        address[] memory path = new address[](2);
        path[0] = router.WETH();
        path[1] = KEYS;
        
        uint256 estimate = router.getAmountsOut(msg.value, path)[1];
        
        uint256 diff = estimate < keysReceived ? keysReceived - estimate : estimate - keysReceived;
        
        require(diff <= estimate.div(20), 'Error: Over 5% Slippage Detected');
        
        _pairAndLock(keysReceived, msg.value);
    }
    
    
    function _pairAndLock(uint256 KEYSAmount, uint256 ethAmount) internal {

        
        uint256 lBefore = IERC20(KEYS_LP).balanceOf(address(this));
        
        IERC20(KEYS).approve(address(router), KEYSAmount);
        
        (uint256 minAmountKEYS, uint256 minETH) = (KEYSAmount.mul(75).div(100), ethAmount.mul(75).div(100));
        
        receiveDisabled = true;
        
        uint256 expectedKEYS = IERC20(KEYS).balanceOf(address(this)).sub(KEYSAmount, 'ERR KEYS Amount');
        uint256 expectedETH = address(this).balance.sub(ethAmount, 'ERR ETH Amount');
        
        router.addLiquidityETH{value: ethAmount}(
            KEYS,
            KEYSAmount,
            minAmountKEYS,
            minETH,
            address(this),
            block.timestamp.add(30)
        );
        
        receiveDisabled = false;
        
        uint256 KEYSAfter = IERC20(KEYS).balanceOf(address(this));
        uint256 ETHAfter = address(this).balance;

        uint256 lpReceived = IERC20(KEYS_LP).balanceOf(address(this)).sub(lBefore);
        require(lpReceived > 0, 'Zero LP Tokens Received');
        
        _lock(msg.sender, lpReceived);
        
        if (refundEnabled) {
            if (KEYSAfter > expectedKEYS) {
                uint256 diff = KEYSAfter.sub(expectedKEYS);
                IERC20(KEYS).transfer(msg.sender, diff);
            }
        
            if (ETHAfter > expectedETH) {
                uint256 diff = ETHAfter.sub(expectedETH);
                (bool s,) = payable(msg.sender).call{value: diff, gas: 2600}("");
                require(s, 'Failure on ETH Refund');
            }
        }
    }
    
    function _removeLiquidity(uint256 nLiquidity, address recipient) private {

        
        IERC20(KEYS_LP).approve(address(router), 2*nLiquidity);
        
        router.removeLiquidityETHSupportingFeeOnTransferTokens(
            KEYS,
            nLiquidity,
            0,
            0,
            recipient,
            block.timestamp.add(30)
        );
        
    }
    
    function _makeClaim(address user) internal {

        require(users[user].tokensLocked > 0, 'Zero Tokens Locked');
        require(users[user].lastClaim + harvestTime <= block.number, 'Claim Wait Time Not Reached');
        
        uint256 amount = pendingRewards(user);
        require(amount > 0,'Zero Rewards');
        _claimReward(user);
    }
    
    function _claimReward(address user) internal {

        
        uint256 amount = pendingRewards(user);
        if (amount == 0) return;
        
        users[user].lastClaim = block.number;
        users[user].totalExcluded = currentDividends(users[user].tokensLocked);
        bool s = IERC20(KEYS).transfer(user, amount);
        require(s,'Failure On Token Transfer');
    }
    
    function _transferIn(address token, uint256 amount) internal returns (uint256) {

        
        uint256 before = IERC20(token).balanceOf(address(this));
        bool s = IERC20(token).transferFrom(msg.sender, address(this), amount);
        
        uint256 difference = IERC20(token).balanceOf(address(this)).sub(before);
        require(s && difference <= amount, 'Error On Transfer In');
        return difference;
    }
    
    function _buyAndStake() internal {

        
        uint256 feeAmount = msg.value.mul(fee).div(100);
        uint256 purchaseAmount = msg.value.sub(feeAmount);
        
        uint256 keysAmount = purchaseAmount.mul(49).div(100);
        uint256 ethAmount = purchaseAmount.sub(keysAmount);
        
        (bool success,) = payable(multisig).call{value: feeAmount}("");
        require(success, 'Failure on Dev Payment');
        
        uint256 before = IERC20(KEYS).balanceOf(address(this));
        (bool s,) = payable(KEYS).call{value: keysAmount}("");
        require(s, 'Failure on KEYS Purchase');
        
        uint256 keysReceived = IERC20(KEYS).balanceOf(address(this)).sub(before);
        
        _pairAndLock(keysReceived, ethAmount);
    }
    
    function _lock(address user, uint256 received) private {

        
        if (users[user].tokensLocked > 0) { // recurring staker
            _claimReward(user);
        } else { // new user
            users[user].lastClaim = block.number;
        }
        
        users[user].tokensLocked += received;
        users[user].timeLocked = block.number;
        users[user].totalExcluded = currentDividends(users[user].tokensLocked);
        
        totalLocked += received;
        
        emit Transfer(address(0), user, received);
    }

    function _unlock(address user, address recipient, uint256 nTokens, bool removeLiquidity) private {

        
        require(users[user].tokensLocked > 0, 'Zero Tokens Locked');
        require(users[user].tokensLocked >= nTokens && nTokens > 0, 'Insufficient Tokens');
        
        uint256 lockExpiration = users[user].timeLocked + lockTime;
        
        _claimReward(user);
        
        if (users[user].tokensLocked == nTokens) {
            delete users[user]; // Free Storage
        } else {
            users[user].tokensLocked = users[user].tokensLocked.sub(nTokens, 'Insufficient Lock Amount');
            users[user].totalExcluded = currentDividends(users[user].tokensLocked);
        }
        
        totalLocked = totalLocked.sub(nTokens, 'Negative Locked');

        uint256 tokensToSend = lockExpiration > block.number ? _calculateEarlyFee(nTokens) : nTokens;

        if (removeLiquidity) {
            _removeLiquidity(tokensToSend, recipient);
        } else {
            bool s = IERC20(KEYS_LP).transfer(recipient, tokensToSend);
            require(s, 'Failure on LP Token Transfer');
        }
        
        if (tokensToSend < nTokens) {
            uint256 dif = nTokens.sub(tokensToSend);
            IERC20(KEYS_LP).transfer(owner, dif);
        }
        
        emit Transfer(user, address(0), nTokens);
    }
    
    function _calculateEarlyFee(uint256 nTokens) internal view returns (uint256) {

        
        uint256 tax = nTokens.mul(earlyFee).div(100);
        
        return nTokens.sub(tax);
    }
    
    
    
    function getTimeUntilUnlock(address user) external view returns (uint256) {

        uint256 endTime = users[user].timeLocked + lockTime;
        return endTime > block.number ? endTime.sub(block.number) : 0;
    }
    
    function getTimeUntilNextClaim(address user) external view returns (uint256) {

        uint256 endTime = users[user].lastClaim + harvestTime;
        return endTime > block.number ? endTime.sub(block.number) : 0;
    }
    
    function currentDividends(uint256 share) internal view returns (uint256) {

        return share.mul(dividendsPerToken).div(precision);
    }
    
    function pendingRewards(address user) public view returns (uint256) {

        uint256 amount = users[user].tokensLocked;
        if(amount == 0){ return 0; }

        uint256 shareholderTotalDividends = currentDividends(amount);
        uint256 shareholderTotalExcluded = users[user].totalExcluded;

        if(shareholderTotalDividends <= shareholderTotalExcluded){ return 0; }

        return shareholderTotalDividends.sub(shareholderTotalExcluded);
    }
    
    function totalPendingRewards() external view returns (uint256) {

        return IERC20(KEYS).balanceOf(address(this)).sub(totalLocked);
    }
    
    function calculateKEYSBalance(address user) external view returns (uint256) {

        return IERC20(KEYS).balanceOf(user);
    }
    
    function calculateKEYSContractBalance() external view returns (uint256) {

        return IERC20(KEYS).balanceOf(address(this));
    }

    receive() external payable {
        if (receiveDisabled || msg.sender == address(router) || msg.sender == KEYS_LP) return;
        _buyAndStake();
    }

}