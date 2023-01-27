pragma solidity ^0.5.0;

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
}pragma solidity ^0.5.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}pragma solidity ^0.5.5;

library Address {

    function isContract(address account) internal view returns (bool) {

        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
    }

    function toPayable(address account) internal pure returns (address payable) {

        return address(uint160(account));
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call.value(amount)("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
}pragma solidity ^0.5.0;


library SafeERC20 {

    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {

        callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {

        callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
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

        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
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
}pragma solidity ^0.5.0;

contract Context {

    constructor () internal { }

    function _msgSender() internal view returns (address payable) {

        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {

        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}pragma solidity ^0.5.0;

contract Ownable is Context {

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

        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    function isOwner() public view returns (bool) {

        return _msgSender() == _owner;
    }

    function renounceOwnership() public onlyOwner {

        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {

        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {

        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}// UNLICENSED

pragma solidity ^0.5.0;

interface IEmiERC20 {

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
    event Transfer(address indexed from, address indexed to, uint256 value);

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function decimals() external view returns (uint8);


    function totalSupply() external view returns (uint256);


    function balanceOf(address owner) external view returns (uint256);


    function allowance(address owner, address spender)
        external
        view
        returns (uint256);


    function approve(address spender, uint256 value) external returns (bool);


    function transfer(address to, uint256 value) external returns (bool);


    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);

}// UNLICENSED

pragma solidity ^0.5.0;


interface IEmiRouter {

    function factory() external pure returns (address);


    function WETH() external pure returns (address);


    function getReserves(IERC20 token0, IERC20 token1)
        external
        view
        returns (
            uint256 _reserve0,
            uint256 _reserve1,
            address poolAddresss
        );


    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address ref
    )
        external
        returns (
            uint256 amountA,
            uint256 amountB,
            uint256 liquidity
        );


    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        address ref
    ) external returns (uint256[] memory amounts);


    function swapTokensForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address[] calldata pathDAI
    ) external returns (uint256[] memory amounts);


    function swapExactETHForTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address[] calldata pathDAI
    ) external payable returns (uint256[] memory amounts);


    function swapTokensForExactETH(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address[] calldata pathDAI
    ) external returns (uint256[] memory amounts);


    function swapExactTokensForETH(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address[] calldata pathDAI
    ) external returns (uint256[] memory amounts);


    function swapETHForExactTokens(
        uint256 amountOut,
        address[] calldata path,
        address[] calldata pathDAI
    ) external payable returns (uint256[] memory amounts);


    function getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    ) external view returns (uint256 amountOut);


    function getAmountIn(
        uint256 amountOut,
        uint256 reserveIn,
        uint256 reserveOut
    ) external view returns (uint256 amountIn);


    function getAmountsOut(uint256 amountIn, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);


    function getAmountsIn(uint256 amountOut, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);


    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address[] calldata pathDAI
    ) external;


    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address[] calldata pathDAI
    ) external payable;


    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address[] calldata pathDAI
    ) external;

}// UNLICENSED

pragma solidity ^0.5.0;


interface IEmiswapRegistry {

    function pools(IERC20 token1, IERC20 token2)
        external
        view
        returns (IEmiswap);


    function isPool(address addr) external view returns (bool);


    function deploy(IERC20 tokenA, IERC20 tokenB) external returns (IEmiswap);

    function getAllPools() external view returns (IEmiswap[] memory);

}

interface IEmiswap {

    function fee() external view returns (uint256);


    function tokens(uint256 i) external view returns (IERC20);


    function deposit(
        uint256[] calldata amounts,
        uint256[] calldata minAmounts,
        address referral
    ) external payable returns (uint256 fairSupply);


    function withdraw(uint256 amount, uint256[] calldata minReturns) external;


    function getBalanceForAddition(IERC20 token)
        external
        view
        returns (uint256);


    function getBalanceForRemoval(IERC20 token) external view returns (uint256);


    function getReturn(
        IERC20 fromToken,
        IERC20 destToken,
        uint256 amount
    ) external view returns (uint256, uint256);


    function swap(
        IERC20 fromToken,
        IERC20 destToken,
        uint256 amount,
        uint256 minReturn,
        address to,
        address referral
    ) external payable returns (uint256 returnAmount);


    function initialize(IERC20[] calldata assets) external;

}// MIT
pragma solidity ^0.5.0;
pragma experimental ABIEncoderV2;


contract EmiStaking02 is Ownable {

    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    struct LockRecord {
        uint256 amountLocked; // Amount of locked tokens in total
        uint64 lockDate; // when lock is made
        uint64 unlockDate; // when lock is made
        uint128 isWithdrawn; // whether or not it is withdrawn already
        uint256 id;
    }

    event StartStaking(
        address wallet,
        uint256 startDate,
        uint256 stopDate,
        uint256 stakeID,
        address token,
        uint256 amount
    );

    event StakesClaimed(address indexed beneficiary, uint256 stakeId, uint256 amount);
    event LockPeriodUpdated(uint256 oldPeriod, uint256 newPeriod);

    mapping(address => LockRecord[]) private locksTable;

    address public lockToken;
    uint256 public lockPeriod;
    uint256 public stakingEndDate;
    uint256 public stakingLastUnlock;
    uint256 public maxUSDStakes;

    address public emiRouter;
    address[] public pathToStables;
    uint8 public tokenMode; // 0 = simple ERC20 token, 1 = Emiswap LP-token

    constructor(
        address _token,
        uint256 _lockPeriod,
        uint256 _maxUSDValue,
        address _router,
        address [] memory _path
    ) public {
        require(_token != address(0), "Token address cannot be empty");
        require(_router != address(0), "Router address cannot be empty");
        require(_path.length > 0, "Path to stable coins must exist");
        require(_lockPeriod > 0, "Lock period cannot be 0");
        lockToken = _token;
        stakingEndDate = block.timestamp + _lockPeriod;
        lockPeriod = _lockPeriod;
        emiRouter = _router;
        stakingLastUnlock = stakingEndDate + _lockPeriod;
        pathToStables = _path;
        maxUSDStakes = _maxUSDValue; // 100000 by default
        tokenMode = 0; // simple ERC20 token by default
    }

    function stake(uint256 amount) external {

        require(block.timestamp < stakingEndDate, "Staking is over");
        require(_checkMaxUSDCondition(msg.sender, amount) == true, "Max stakes values in USD reached");
        IERC20(lockToken).safeTransferFrom(msg.sender, address(this), amount);
        uint256 stakeId = uint256(
            keccak256(abi.encodePacked("Emiswap", block.timestamp, block.difficulty, block.gaslimit))
        );
        locksTable[msg.sender].push(
            LockRecord({
                amountLocked: amount,
                lockDate: uint64(block.timestamp),
                unlockDate: uint64(block.timestamp + lockPeriod),
                id: stakeId,
                isWithdrawn: 0
            })
        );
        emit StartStaking(msg.sender, block.timestamp, block.timestamp + lockPeriod, stakeId, lockToken, amount);
    }

    function withdraw() external {

        LockRecord[] memory t = locksTable[msg.sender];
        uint256 _bal;

        for (uint256 i = 0; i < t.length; i++) {
            if (t[i].isWithdrawn == 0 && (block.timestamp >= t[i].unlockDate || block.timestamp >= stakingLastUnlock)) {
                _bal = _bal.add(t[i].amountLocked);
                locksTable[msg.sender][i].isWithdrawn = 1;
                emit StakesClaimed(msg.sender, t[i].id, t[i].amountLocked);
            }
        }

        require(_bal > 0, "No stakes to withdraw");

        IERC20(lockToken).safeTransfer(msg.sender, _bal);
    }

    function getStakesLen(address staker) external view onlyOwner returns (uint256) {

        return locksTable[staker].length;
    }

    function getStake(address staker, uint256 idx) external view onlyOwner returns (LockRecord memory) {

        require(idx < locksTable[staker].length, "Idx is wrong");

        return locksTable[staker][idx];
    }

    function getMyStakesLen() external view returns (uint256) {

        return locksTable[msg.sender].length;
    }

    function getMyStake(uint256 idx) external view returns (LockRecord memory) {

        require(idx < locksTable[msg.sender].length, "Idx is wrong");

        return locksTable[msg.sender][idx];
    }

    function unlockedBalanceOf(address staker) external view onlyOwner returns (uint256, uint256) {

        uint256 _bal = _getBalance(staker, true);
        return (_bal, _getUSDValue(_bal));
    }

    function balanceOf() external view returns (uint256, uint256) {

        uint256 _bal = _getBalance(msg.sender, false);
        return (_bal, _getUSDValue(_bal));
    }

    function myUnlockedBalance() external view returns (uint256, uint256) {

        uint256 _bal = _getBalance(msg.sender, true);
        return (_bal, _getUSDValue(_bal));
    }

    function _getBalance(address staker, bool unlockedOnly) internal view returns (uint256) {

        LockRecord[] memory t = locksTable[staker];
        uint256 _bal;

        for (uint256 i = 0; i < t.length; i++) {
            if (t[i].isWithdrawn == 0) {
                if (!unlockedOnly || (unlockedOnly && (block.timestamp >= t[i].unlockDate || block.timestamp >= stakingLastUnlock))) {
                  _bal = _bal.add(t[i].amountLocked);
                }
            }
        }
        return _bal;
    }

    function _checkMaxUSDCondition(address staker, uint256 amount) internal view returns (bool) {

        LockRecord[] memory t = locksTable[staker];
        uint256 _bal;

        for (uint256 i = 0; i < t.length; i++) {
            if (t[i].isWithdrawn == 0) { // count only existing tokens -- both locked and unlocked
                _bal = _bal.add(t[i].amountLocked);
            }
        }

        return (_getUSDValue(_bal.add(amount)) <= maxUSDStakes);
    }

    
    function getTotals() external view returns (uint256, uint256)
    {

      uint256 _bal = IERC20(lockToken).balanceOf(address(this));
      return (_bal, _getUSDValue(_bal));
    }

    function _getUSDValue(uint256 amount) internal view returns (uint256 stakesTotal) {

        if (tokenMode==0) { // straight token
          uint256 tokenDec = IEmiERC20(pathToStables[pathToStables.length-1]).decimals();
          uint256 [] memory tokenAmounts = IEmiRouter(emiRouter).getAmountsOut(amount, pathToStables);
          stakesTotal = tokenAmounts[tokenAmounts.length-1].div(10**tokenDec);
        } else if (tokenMode==1) {
          stakesTotal = _getStakesForLPToken(amount);
        } else {
          return 0;
        }
    }

    function _getStakesForLPToken(uint256 amount) internal view returns(uint256)
    {

       uint256 lpFraction = amount.mul(10**18).div(IERC20(lockToken).totalSupply());
       uint256 tokenIdx = 0;

       if (pathToStables[0]!=address(IEmiswap(lockToken).tokens(0))) {
         tokenIdx = 1;
       }

       uint256 rsv = IEmiswap(lockToken).getBalanceForAddition(
            IEmiswap(lockToken).tokens(tokenIdx)
       );

       uint256 tokenSrcDec = IEmiERC20(pathToStables[0]).decimals();
       uint256 tokenDstDec = IEmiERC20(pathToStables[pathToStables.length-1]).decimals();

       uint256 [] memory tokenAmounts = IEmiRouter(emiRouter).getAmountsOut(10**tokenSrcDec, pathToStables);
       return tokenAmounts[tokenAmounts.length-1].mul(rsv).mul(2).mul(lpFraction).div(10**(18+tokenSrcDec+tokenDstDec));
    }

    function getUnlockedRecords(address staker) external view onlyOwner returns (LockRecord[] memory) {

        LockRecord[] memory t = locksTable[staker];
        uint256 l;

        for (uint256 i = 0; i < t.length; i++) {
            if (t[i].isWithdrawn == 0 && (block.timestamp >= t[i].unlockDate  || block.timestamp >= stakingLastUnlock)) {
                l++;
            }
        }
        if (l==0) {
          return new LockRecord[](0);
        }
        LockRecord[] memory r = new LockRecord[](l);
        uint256 j = 0;
        for (uint256 i = 0; i < t.length; i++) {
            if (t[i].isWithdrawn == 0 && (block.timestamp >= t[i].unlockDate  || block.timestamp >= stakingLastUnlock)) {
                r[j++] = t[i];
            }
        }

        return r;
    }

    function updateLockPeriod(uint256 _lockPeriod) external onlyOwner {

        emit LockPeriodUpdated(lockPeriod, _lockPeriod);
        lockPeriod = _lockPeriod;
    }

    function updateLastUnlock(uint256 _unlockTime) external onlyOwner {

        stakingLastUnlock = _unlockTime;
    }

    function updatePathToStables(address [] calldata _path) external onlyOwner {

        pathToStables = _path;
    }

    function updateMaxUSD(uint256 _value) external onlyOwner {

        maxUSDStakes = _value;
    }

    function updateTokenMode(uint8 _mode) external onlyOwner {

        require(_mode < 2, "Wrong token mode");
        tokenMode = _mode;
    }

    function transferAnyERC20Token(
        address tokenAddress,
        address beneficiary,
        uint256 tokens
    ) external onlyOwner returns (bool success) {

        require(tokenAddress != address(0), "Token address cannot be 0");
        require(tokenAddress != lockToken, "Token cannot be ours");

        return IERC20(tokenAddress).transfer(beneficiary, tokens);
    }
}