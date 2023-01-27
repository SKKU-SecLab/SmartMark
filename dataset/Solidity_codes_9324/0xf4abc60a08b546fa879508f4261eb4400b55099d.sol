
pragma solidity 0.6.11;


library SafeMath {

  function mul(uint256 a, uint256 b) internal pure returns (uint256) {

    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {

    uint256 c = a / b;
    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {

    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256) {

    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}

library EnumerableSet {


    struct Set {
        bytes32[] _values;

        mapping (bytes32 => uint256) _indexes;
    }

    function _add(Set storage set, bytes32 value) private returns (bool) {

        if (!_contains(set, value)) {
            set._values.push(value);
            set._indexes[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

    function _remove(Set storage set, bytes32 value) private returns (bool) {

        uint256 valueIndex = set._indexes[value];

        if (valueIndex != 0) { // Equivalent to contains(set, value)

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;


            bytes32 lastvalue = set._values[lastIndex];

            set._values[toDeleteIndex] = lastvalue;
            set._indexes[lastvalue] = toDeleteIndex + 1; // All indexes are 1-based

            set._values.pop();

            delete set._indexes[value];

            return true;
        } else {
            return false;
        }
    }

    function _contains(Set storage set, bytes32 value) private view returns (bool) {

        return set._indexes[value] != 0;
    }

    function _length(Set storage set) private view returns (uint256) {

        return set._values.length;
    }

    function _at(Set storage set, uint256 index) private view returns (bytes32) {

        require(set._values.length > index, "EnumerableSet: index out of bounds");
        return set._values[index];
    }


    struct AddressSet {
        Set _inner;
    }

    function add(AddressSet storage set, address value) internal returns (bool) {

        return _add(set._inner, bytes32(uint256(value)));
    }

    function remove(AddressSet storage set, address value) internal returns (bool) {

        return _remove(set._inner, bytes32(uint256(value)));
    }

    function contains(AddressSet storage set, address value) internal view returns (bool) {

        return _contains(set._inner, bytes32(uint256(value)));
    }

    function length(AddressSet storage set) internal view returns (uint256) {

        return _length(set._inner);
    }

    function at(AddressSet storage set, uint256 index) internal view returns (address) {

        return address(uint256(_at(set._inner, index)));
    }



    struct UintSet {
        Set _inner;
    }

    function add(UintSet storage set, uint256 value) internal returns (bool) {

        return _add(set._inner, bytes32(value));
    }

    function remove(UintSet storage set, uint256 value) internal returns (bool) {

        return _remove(set._inner, bytes32(value));
    }

    function contains(UintSet storage set, uint256 value) internal view returns (bool) {

        return _contains(set._inner, bytes32(value));
    }

    function length(UintSet storage set) internal view returns (uint256) {

        return _length(set._inner);
    }

    function at(UintSet storage set, uint256 index) internal view returns (uint256) {

        return uint256(_at(set._inner, index));
    }
}

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

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {

        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {

        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
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

contract Ownable {

  address public owner;


  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


  constructor() public {
    owner = msg.sender;
  }


  modifier onlyOwner() {

    require(msg.sender == owner);
    _;
  }


  function transferOwnership(address newOwner) onlyOwner public {

    require(newOwner != address(0));
    emit OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }
}

interface Token {

    function approve(address, uint) external returns (bool);

    function balanceOf(address) external view returns (uint);

    function transferFrom(address, address, uint) external returns (bool);

    function transfer(address, uint) external returns (bool);

}

interface OldIERC20 {

    function transfer(address, uint) external;

}

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

}

contract FarmProRata is Ownable {

    using SafeMath for uint;
    using EnumerableSet for EnumerableSet.AddressSet;
    using Address for address;
    
    modifier noContractsAllowed() {

        require(!(address(msg.sender).isContract()) && tx.origin == msg.sender, "No Contracts Allowed!");
        _;
    }

    event RewardsTransferred(address holder, uint amount);
    event EthRewardsTransferred(address holder, uint amount);
    
    event RewardsDisbursed(uint amount);
    event EthRewardsDisbursed(uint amount);
    

    address public constant trustedDepositTokenAddress = 0x76911E11FddB742D75b83C9e1F611F48f19234E4;
    address public constant trustedRewardTokenAddress = 0x961C8c0B1aaD0c0b10a51FeF6a867E3091BCef17; 
    
    address public constant BURN_ADDRESS = 0x000000000000000000000000000000000000dEaD;
    
    uint public constant cliffTime = 30 days;

    uint public constant disburseAmount = 540000e18;
    uint public constant disburseDuration = 365 days;
    
    uint public constant adminCanClaimAfter = 395 days;
    
    uint public constant swapAttemptPeriod = 1 days;
    uint public constant burnOrDisburseTokensPeriod = 7 days;

    

    uint public constant disbursePercentX100 = 100e2;
    
    uint public constant MAGIC_NUMBER = 6289308176100628;
    
    uint public constant SLIPPAGE_TOLERANCE_X_100 = 100;
    

    uint public contractDeployTime;
    uint public adminClaimableTime;
    uint public lastDisburseTime;
    uint public lastSwapExecutionTime;
    uint public lastBurnOrTokenDistributeTime;
    
    IUniswapV2Router02 public uniswapRouterV2;
    IUniswapV2Pair public uniswapV2Pair;
    address[] public SWAP_PATH;
    
    constructor(address[] memory swapPath) public {
        contractDeployTime = now;
        adminClaimableTime = contractDeployTime.add(adminCanClaimAfter);
        lastDisburseTime = contractDeployTime;
        lastSwapExecutionTime = lastDisburseTime;
        lastBurnOrTokenDistributeTime = lastDisburseTime;
        
        uniswapRouterV2 = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        uniswapV2Pair = IUniswapV2Pair(trustedDepositTokenAddress);
        SWAP_PATH = swapPath;
    }

    uint public totalClaimedRewards = 0;
    uint public totalClaimedRewardsEth = 0;

    EnumerableSet.AddressSet private holders;

    mapping (address => uint) public depositedTokens;
    mapping (address => uint) public depositTime;
    mapping (address => uint) public lastClaimedTime;
    mapping (address => uint) public totalEarnedTokens;
    mapping (address => uint) public totalEarnedEth;
    mapping (address => uint) public lastDivPoints;
    mapping (address => uint) public lastEthDivPoints;

    uint public contractBalance = 0;

    uint public totalDivPoints = 0;
    uint public totalEthDivPoints = 0;
    uint public totalTokens = 0;
    
    uint public tokensToBeDisbursedOrBurnt = 0;
    uint public tokensToBeSwapped = 0;

    uint internal constant pointMultiplier = 1e18;

    function addContractBalance(uint amount) public onlyOwner {

        require(Token(trustedRewardTokenAddress).transferFrom(msg.sender, address(this), amount), "Cannot add balance!");
        contractBalance = contractBalance.add(amount);
    }

    
    function updateAccount(address account) private {

        disburseTokens();
        attemptSwap();
        uint pendingDivs = getPendingDivs(account);
        if (pendingDivs > 0) {
            require(Token(trustedRewardTokenAddress).transfer(account, pendingDivs), "Could not transfer tokens.");
            totalEarnedTokens[account] = totalEarnedTokens[account].add(pendingDivs);
            totalClaimedRewards = totalClaimedRewards.add(pendingDivs);
            emit RewardsTransferred(account, pendingDivs);
        }
        
        uint pendingDivsEth = getPendingDivsEth(account);
        if (pendingDivsEth > 0) {
            require(Token(uniswapRouterV2.WETH()).transfer(account, pendingDivsEth), "Could not transfer WETH!");
            totalEarnedEth[account] = totalEarnedEth[account].add(pendingDivsEth);
            totalClaimedRewardsEth = totalClaimedRewardsEth.add(pendingDivsEth);
            emit EthRewardsTransferred(account, pendingDivsEth);
        }
        
        lastClaimedTime[account] = now;
        lastDivPoints[account] = totalDivPoints;
        lastEthDivPoints[account] = totalEthDivPoints;
    }

    function getPendingDivs(address _holder) public view returns (uint) {

        if (!holders.contains(_holder)) return 0;
        if (depositedTokens[_holder] == 0) return 0;

        uint newDivPoints = totalDivPoints.sub(lastDivPoints[_holder]);

        uint depositedAmount = depositedTokens[_holder];

        uint pendingDivs = depositedAmount.mul(newDivPoints).div(pointMultiplier);

        return pendingDivs;
    }
    
    function getPendingDivsEth(address _holder) public view returns (uint) {

        if (!holders.contains(_holder)) return 0;
        if (depositedTokens[_holder] == 0) return 0;

        uint newDivPoints = totalEthDivPoints.sub(lastEthDivPoints[_holder]);

        uint depositedAmount = depositedTokens[_holder];

        uint pendingDivs = depositedAmount.mul(newDivPoints).div(pointMultiplier);

        return pendingDivs;
    }

    
    function getNumberOfHolders() public view returns (uint) {

        return holders.length();
    }


    function deposit(uint amountToDeposit) public noContractsAllowed {

        require(amountToDeposit > 0, "Cannot deposit 0 Tokens");

        updateAccount(msg.sender);

        require(Token(trustedDepositTokenAddress).transferFrom(msg.sender, address(this), amountToDeposit), "Insufficient Token Allowance");

        depositedTokens[msg.sender] = depositedTokens[msg.sender].add(amountToDeposit);
        totalTokens = totalTokens.add(amountToDeposit);

        if (!holders.contains(msg.sender)) {
            holders.add(msg.sender);
        }
        depositTime[msg.sender] = now;
    }

    function withdraw(uint amountToWithdraw) public noContractsAllowed {

        require(amountToWithdraw > 0, "Cannot withdraw 0 Tokens!");

        require(depositedTokens[msg.sender] >= amountToWithdraw, "Invalid amount to withdraw");
        require(now.sub(depositTime[msg.sender]) > cliffTime, "You recently deposited, please wait before withdrawing.");
        
        updateAccount(msg.sender);

        require(Token(trustedDepositTokenAddress).transfer(msg.sender, amountToWithdraw), "Could not transfer tokens.");

        depositedTokens[msg.sender] = depositedTokens[msg.sender].sub(amountToWithdraw);
        totalTokens = totalTokens.sub(amountToWithdraw);

        if (holders.contains(msg.sender) && depositedTokens[msg.sender] == 0) {
            holders.remove(msg.sender);
        }
    }

    function emergencyWithdraw(uint amountToWithdraw) public noContractsAllowed {

        require(amountToWithdraw > 0, "Cannot withdraw 0 Tokens!");

        require(depositedTokens[msg.sender] >= amountToWithdraw, "Invalid amount to withdraw");
        require(now.sub(depositTime[msg.sender]) > cliffTime, "You recently deposited, please wait before withdrawing.");
        
        disburseTokens();
        lastClaimedTime[msg.sender] = now;
        lastDivPoints[msg.sender] = totalDivPoints;
        lastEthDivPoints[msg.sender] = totalEthDivPoints;

        require(Token(trustedDepositTokenAddress).transfer(msg.sender, amountToWithdraw), "Could not transfer tokens.");

        depositedTokens[msg.sender] = depositedTokens[msg.sender].sub(amountToWithdraw);
        totalTokens = totalTokens.sub(amountToWithdraw);

        if (holders.contains(msg.sender) && depositedTokens[msg.sender] == 0) {
            holders.remove(msg.sender);
        }
    }
    
    function claim() public noContractsAllowed {

        updateAccount(msg.sender);
    }
    
    function distributeDivs(uint amount) private {

        require(amount > 0 && totalTokens > 0, "distributeDivs failed!");
        totalDivPoints = totalDivPoints.add(amount.mul(pointMultiplier).div(totalTokens));
        emit RewardsDisbursed(amount);
    }
    
    function distributeDivsEth(uint amount) private {

        require(amount > 0 && totalTokens > 0, "distributeDivsEth failed!");
        totalEthDivPoints = totalEthDivPoints.add(amount.mul(pointMultiplier).div(totalTokens));
        emit EthRewardsDisbursed(amount);
    }

    function disburseTokens() private {

        uint amount = getPendingDisbursement();

        if (contractBalance < amount) {
            amount = contractBalance;
        }
        if (amount == 0 || totalTokens == 0) return;

        tokensToBeSwapped = tokensToBeSwapped.add(amount);        

        contractBalance = contractBalance.sub(amount);
        lastDisburseTime = now;
    }
    
    function attemptSwap() private {

        doSwap();
    }
    
    function doSwap() private {

        if (totalTokens == 0) {
            return;
        }
        
        if (now.sub(lastSwapExecutionTime) < swapAttemptPeriod) {
            return;
        }
    
        uniswapV2Pair.sync();
    
        uint _tokensToBeSwapped = tokensToBeSwapped.add(tokensToBeDisbursedOrBurnt);
        
        uint maxSwappableAmount = getMaxSwappableAmount();
        
        if (maxSwappableAmount == 0) return;
    
        if (maxSwappableAmount < tokensToBeSwapped) {
            
            uint diff = tokensToBeSwapped.sub(maxSwappableAmount);
            _tokensToBeSwapped = tokensToBeSwapped.sub(diff);
            tokensToBeDisbursedOrBurnt = tokensToBeDisbursedOrBurnt.add(diff);
            tokensToBeSwapped = 0;
    
        } else if (maxSwappableAmount < _tokensToBeSwapped) {
    
            uint diff = _tokensToBeSwapped.sub(maxSwappableAmount);
            _tokensToBeSwapped = _tokensToBeSwapped.sub(diff);
            tokensToBeDisbursedOrBurnt = diff;
            tokensToBeSwapped = 0;
    
        } else {
            tokensToBeSwapped = 0;
            tokensToBeDisbursedOrBurnt = 0;
        }
    
        if (_tokensToBeSwapped == 0) {
            return;
        }
    
        if (Token(trustedRewardTokenAddress).balanceOf(address(this)) < _tokensToBeSwapped) {
            return;
        }
    
        require(Token(trustedRewardTokenAddress).approve(address(uniswapRouterV2), _tokensToBeSwapped), 'approve failed!');
    
        uint oldWethBalance = Token(uniswapRouterV2.WETH()).balanceOf(address(this));
                
        uint amountOutMin;
        
        uint estimatedAmountOut = uniswapRouterV2.getAmountsOut(_tokensToBeSwapped, SWAP_PATH)[SWAP_PATH.length.sub(1)];
        amountOutMin = estimatedAmountOut.mul(uint(100e2).sub(SLIPPAGE_TOLERANCE_X_100)).div(100e2);
        
        uniswapRouterV2.swapExactTokensForTokens(_tokensToBeSwapped, amountOutMin, SWAP_PATH, address(this), block.timestamp);
    
        uint newWethBalance = Token(uniswapRouterV2.WETH()).balanceOf(address(this));
        uint wethReceived = newWethBalance.sub(oldWethBalance);
        require(wethReceived >= amountOutMin, "Invalid SWAP!");
        
        if (wethReceived > 0) {
            distributeDivsEth(wethReceived);    
        }

        lastSwapExecutionTime = now;
    }
    
    function disburseRewardTokens() public onlyOwner {

        require(now.sub(lastBurnOrTokenDistributeTime) > burnOrDisburseTokensPeriod, "Recently executed, Please wait!");
        
        uniswapV2Pair.sync();
        
        uint maxSwappableAmount = getMaxSwappableAmount();
        
        uint _tokensToBeDisbursed = tokensToBeDisbursedOrBurnt;
        uint _tokensToBeBurnt;
        
        if (maxSwappableAmount < _tokensToBeDisbursed) {
            _tokensToBeBurnt = _tokensToBeDisbursed.sub(maxSwappableAmount);
            _tokensToBeDisbursed = maxSwappableAmount;
        }
        
        distributeDivs(_tokensToBeDisbursed);
        if (_tokensToBeBurnt > 0) {
            require(Token(trustedRewardTokenAddress).transfer(BURN_ADDRESS, _tokensToBeBurnt), "disburseRewardTokens: burn failed!");
        }
        tokensToBeDisbursedOrBurnt = 0;
        lastBurnOrTokenDistributeTime = now;
    }
    
    
    function burnRewardTokens() public onlyOwner {

        require(now.sub(lastBurnOrTokenDistributeTime) > burnOrDisburseTokensPeriod, "Recently executed, Please wait!");
        require(Token(trustedRewardTokenAddress).transfer(BURN_ADDRESS, tokensToBeDisbursedOrBurnt), "burnRewardTokens failed!");
        tokensToBeDisbursedOrBurnt = 0;
        lastBurnOrTokenDistributeTime = now;
    }
    
    
    function getMaxSwappableAmount() public view returns (uint) {

        uint tokensAvailable = Token(trustedRewardTokenAddress).balanceOf(trustedDepositTokenAddress);
        uint maxSwappableAmount = tokensAvailable.mul(MAGIC_NUMBER).div(1e18);
        return maxSwappableAmount;
    }

    function getPendingDisbursement() public view returns (uint) {

        uint timeDiff;
        uint _now = now;
        uint _stakingEndTime = contractDeployTime.add(disburseDuration);
        if (_now > _stakingEndTime) {
            _now = _stakingEndTime;
        }
        if (lastDisburseTime >= _now) {
            timeDiff = 0;
        } else {
            timeDiff = _now.sub(lastDisburseTime);
        }

        uint pendingDisburse = disburseAmount
                                    .mul(disbursePercentX100)
                                    .mul(timeDiff)
                                    .div(disburseDuration)
                                    .div(10000);
        return pendingDisburse;
    }

    function getDepositorsList(uint startIndex, uint endIndex)
        public
        view
        returns (address[] memory stakers,
            uint[] memory stakingTimestamps,
            uint[] memory lastClaimedTimeStamps,
            uint[] memory stakedTokens) {

        require (startIndex < endIndex);

        uint length = endIndex.sub(startIndex);
        address[] memory _stakers = new address[](length);
        uint[] memory _stakingTimestamps = new uint[](length);
        uint[] memory _lastClaimedTimeStamps = new uint[](length);
        uint[] memory _stakedTokens = new uint[](length);

        for (uint i = startIndex; i < endIndex; i = i.add(1)) {
            address staker = holders.at(i);
            uint listIndex = i.sub(startIndex);
            _stakers[listIndex] = staker;
            _stakingTimestamps[listIndex] = depositTime[staker];
            _lastClaimedTimeStamps[listIndex] = lastClaimedTime[staker];
            _stakedTokens[listIndex] = depositedTokens[staker];
        }

        return (_stakers, _stakingTimestamps, _lastClaimedTimeStamps, _stakedTokens);
    }


    function transferAnyERC20Token(address _tokenAddr, address _to, uint _amount) public onlyOwner {

        require(_tokenAddr != trustedDepositTokenAddress, "Admin cannot transfer out deposit tokens from this vault!");
        require((_tokenAddr != trustedRewardTokenAddress && _tokenAddr != uniswapRouterV2.WETH()) || (now > adminClaimableTime), "Admin cannot Transfer out Reward Tokens or WETH Yet!");
        require(Token(_tokenAddr).transfer(_to, _amount), "Could not transfer out tokens!");
    }

    function transferAnyOldERC20Token(address _tokenAddr, address _to, uint _amount) public onlyOwner {

       
        require(_tokenAddr != trustedDepositTokenAddress, "Admin cannot transfer out deposit tokens from this vault!");
        require((_tokenAddr != trustedRewardTokenAddress && _tokenAddr != uniswapRouterV2.WETH()) || (now > adminClaimableTime), "Admin cannot Transfer out Reward Tokens or WETH Yet!");

        OldIERC20(_tokenAddr).transfer(_to, _amount);
    }
}