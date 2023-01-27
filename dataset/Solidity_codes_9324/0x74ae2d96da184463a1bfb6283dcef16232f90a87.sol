


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
}


pragma solidity ^0.6.0;


contract Pausable is Context {

    event Paused(address account);

    event Unpaused(address account);

    bool private _paused;

    constructor () internal {
        _paused = false;
    }

    function paused() public view returns (bool) {

        return _paused;
    }

    modifier whenNotPaused() {

        require(!_paused, "Pausable: paused");
        _;
    }

    modifier whenPaused() {

        require(_paused, "Pausable: not paused");
        _;
    }

    function _pause() internal virtual whenNotPaused {

        _paused = true;
        emit Paused(_msgSender());
    }

    function _unpause() internal virtual whenPaused {

        _paused = false;
        emit Unpaused(_msgSender());
    }
}


pragma solidity ^0.6.0;

contract ReentrancyGuard {


    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor () internal {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {

        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
    }
}


pragma solidity >=0.5.0;

interface ISakeSwapFactory {

    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);

    function feeToSetter() external view returns (address);

    function migrator() external view returns (address);


    function getPair(address tokenA, address tokenB) external view returns (address pair);

    function allPairs(uint) external view returns (address pair);

    function allPairsLength() external view returns (uint);


    function createPair(address tokenA, address tokenB) external returns (address pair);


    function setFeeTo(address) external;

    function setFeeToSetter(address) external;

    function setMigrator(address) external;

}


pragma solidity >=0.6.2;

interface ISakeSwapRouter {

    function factory() external pure returns (address);


    function WETH() external pure returns (address);


    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    )
        external
        returns (
            uint256 amountA,
            uint256 amountB,
            uint256 liquidity
        );


    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
        external
        payable
        returns (
            uint256 amountToken,
            uint256 amountETH,
            uint256 liquidity
        );


    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    )
        external
        returns (
            uint256 amountA,
            uint256 amountB
        );


    function removeLiquidityETH(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
        external
        returns (
            uint256 amountToken,
            uint256 amountETH
        );


    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    )
        external
        returns (
            uint256 amountA,
            uint256 amountB
        );


    function removeLiquidityETHWithPermit(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    )
        external
        returns (
            uint256 amountToken,
            uint256 amountETH
        );


    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline,
        bool ifmint
    ) external returns (uint256[] memory amounts);


    function swapTokensForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline,
        bool ifmint
    ) external returns (uint256[] memory amounts);


    function swapExactETHForTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline,
        bool ifmint
    ) external payable returns (uint256[] memory amounts);


    function swapTokensForExactETH(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline,
        bool ifmint
    ) external returns (uint256[] memory amounts);


    function swapExactTokensForETH(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline,
        bool ifmint
    ) external returns (uint256[] memory amounts);


    function swapETHForExactTokens(
        uint256 amountOut,
        address[] calldata path,
        address to,
        uint256 deadline,
        bool ifmint
    ) external payable returns (uint256[] memory amounts);


    function quote(
        uint256 amountA,
        uint256 reserveA,
        uint256 reserveB
    ) external pure returns (uint256 amountB);


    function getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountOut);


    function getAmountIn(
        uint256 amountOut,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountIn);


    function getAmountsOut(uint256 amountIn, address[] calldata path) external view returns (uint256[] memory amounts);


    function getAmountsIn(uint256 amountOut, address[] calldata path) external view returns (uint256[] memory amounts);


    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountETH);


    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountETH);


    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline,
        bool ifmint
    ) external;


    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline,
        bool ifmint
    ) external payable;


    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline,
        bool ifmint
    ) external;

}


pragma solidity >=0.5.0;

interface ISakeSwapPair {

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

    function stoken() external view returns (address);

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

    function dealSlippageWithIn(address[] calldata path, uint amountIn, address to, bool ifmint) external returns (uint amountOut);

    function dealSlippageWithOut(address[] calldata path, uint amountOut, address to, bool ifmint) external returns (uint extra);

    function getAmountOutMarket(address token, uint amountIn) external view returns (uint _out, uint t0Price);

    function getAmountInMarket(address token, uint amountOut) external view returns (uint _in, uint t0Price);

    function getAmountOutFinal(address token, uint256 amountIn) external view returns (uint256 amountOut, uint256 stokenAmount);

    function getAmountInFinal(address token, uint256 amountOut) external view returns (uint256 amountIn, uint256 stokenAmount);

    function getTokenMarketPrice(address token) external view returns (uint price);

}


pragma solidity >=0.5.0;

interface IWETH {

    function deposit() external payable;

    function transfer(address to, uint value) external returns (bool);

    function withdraw(uint) external;

}


pragma solidity >=0.6.0;

library TransferHelper {

    function safeApprove(address token, address to, uint value) internal {

        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: APPROVE_FAILED');
    }

    function safeTransfer(address token, address to, uint value) internal {

        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FAILED');
    }

    function safeTransferFrom(address token, address from, address to, uint value) internal {

        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FROM_FAILED');
    }

    function safeTransferETH(address to, uint value) internal {

        (bool success,) = to.call{value:value}(new bytes(0));
        require(success, 'TransferHelper: ETH_TRANSFER_FAILED');
    }
}


pragma solidity 0.6.12;












contract SakeILO is Ownable, Pausable, ReentrancyGuard{

    using SafeMath for uint256;
    using SafeERC20 for IERC20;
   
    address public WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    address public SAKE = 0x066798d9ef0833ccc719076Dab77199eCbd178b0; 
    ISakeSwapFactory public sakeFactory = ISakeSwapFactory(0x75e48C954594d64ef9613AeEF97Ad85370F13807);
    ISakeSwapRouter public sakeRouter = ISakeSwapRouter(0x9C578b573EdE001b95d51a55A3FAfb45f5608b1f);

    IERC20 public projectPartyToken;
    IERC20 public contributionToken;

    uint256 public fundraisingStartTimestamp;
    uint256 public fundraisingDurationDays;

    uint256 public totalProjectPartyFund;   // amount of project party token, set ratio 
    uint256 public maxPoolContribution;     // hard cap
    uint256 public minPoolContribution;     // soft cap
    uint256 public minInvestorContribution; // min amount for each investor to contribute
    uint256 public maxInvestorContribution; // max amount for each investor to contribute
    uint256 public minSakeHolder;

    address public projectPartyAddress;
    bool public projectPartyFundDone = false;
    bool public projectPartyRefundDone = false; 
    uint256 public totalInvestorContributed = 0;
    mapping (address => uint256) public investorContributed; // how much each investor contributed
    uint256 public investorsCount;
    uint256 public transfersCount; 
 
    uint256 public lpLockPeriod;
    uint256 public lpUnlockFrequency;
    uint256 public lpUnlockFeeRatio;
    address public feeAddress;

    uint256 public totalLPCreated = 0;  // lp created amount by add liquidity to sakeswap  
    uint256 public perUnlockLP = 0;     // lp unlock amount each time
    uint256 public lpUnlockStartTimestamp = 0;
    mapping (address => uint256) public investorUnlockedLPTimes;  // how many times to unlock lp of each adddress  
    uint256 public projectPartUnlockedLPTimes;

    address public factory;

    event Contribution(address indexed user, uint256 value);
    event UnlockLP(address indexed user, uint256 lpAmount, uint256 feeAmount);
    event Refund(address indexed user, uint256 value);

    receive() external payable {
        assert(msg.sender == WETH); // only accept ETH via fallback from the WETH contract
    }

    constructor() public {
        factory = msg.sender;
    }

    function initialize(address _projectPartyToken, address _contributionToken, uint256 _fundraisingDurationDays, 
        uint256 _totalProjectPartyFund, uint256 _maxPoolContribution, uint256 _minPoolContribution, address _owner) external whenNotPaused {


        require(msg.sender == factory, "not factory address");
        projectPartyToken = IERC20(_projectPartyToken);
        contributionToken = IERC20(_contributionToken);
        fundraisingDurationDays = _fundraisingDurationDays * 1 days;
        totalProjectPartyFund = _totalProjectPartyFund;
        maxPoolContribution = _maxPoolContribution;
        minPoolContribution = _minPoolContribution;
        transferOwnership(_owner);
    }

    function setParams(uint256 minInContribution, uint256 maxInContribution, uint256 lockPeriod, uint256 unlockFrequency, uint256 feeRatio, 
        address feeTo, uint256 minSake, uint256 startTimestamp) external onlyOwner whenNotPaused {


        require(lpUnlockStartTimestamp == 0, "add liquidity finished");
        require(minInContribution <= maxInContribution && minInContribution > 0, "invalid investor contribution");
        require(lockPeriod > 0 && unlockFrequency > 0 , "zero period");
        require(lockPeriod >= unlockFrequency, "invalid period");
        require(startTimestamp > block.timestamp, "invalid start time");
        require(feeRatio >= 0 && feeRatio < 100, "invalid fee ratio");
        minInvestorContribution = minInContribution;
        maxInvestorContribution = maxInContribution;
        lpLockPeriod = lockPeriod * 1 days;
        lpUnlockFrequency = unlockFrequency * 1 days;
        lpUnlockFeeRatio = feeRatio; 
        feeAddress = feeTo;
        minSakeHolder = minSake;
        fundraisingStartTimestamp = startTimestamp;
    }

    function setPoolParams(uint256 _fundraisingDurationDays,  uint256 _totalProjectPartyFund, uint256 _maxPoolContribution, uint256 _minPoolContribution)  external onlyOwner whenNotPaused {

        require(projectPartyFundDone == false, "project party fund done");
        require(_totalProjectPartyFund > 0, "invalid project party fund");
        require(_maxPoolContribution >= _minPoolContribution && _minPoolContribution > 0, "invalid pool contribution");
        require(_fundraisingDurationDays > 0, "invalid period");

        fundraisingDurationDays = _fundraisingDurationDays * 1 days;
        totalProjectPartyFund = _totalProjectPartyFund;
        maxPoolContribution = _maxPoolContribution;
        minPoolContribution = _minPoolContribution;
    } 

    function projectPartyFund() external nonReentrant whenNotPaused {

        require(isFundraisingFinished() == false, "fundraising already finished");
        require(projectPartyFundDone == false, "repeatedly operation");
          
        projectPartyAddress = msg.sender;
        projectPartyFundDone = true;
        projectPartyToken.safeTransferFrom(msg.sender, address(this), totalProjectPartyFund);
        emit Contribution(msg.sender, totalProjectPartyFund);  
    }

    function contributeETH() external whenNotPaused nonReentrant  payable {

        require(WETH == address(contributionToken), "invalid token");
        uint256 cAmount =  contributeInternal(msg.value);
        IWETH(WETH).deposit{value: cAmount}();
        if (msg.value > cAmount){
            TransferHelper.safeTransferETH(msg.sender, msg.value.sub(cAmount));
        } 
        emit Contribution(msg.sender, cAmount);  
    }

    function contributeToken(uint256 amount) external nonReentrant whenNotPaused {

        require(WETH != address(contributionToken), "invalid token");
        uint256 cAmount = contributeInternal(amount);
        contributionToken.safeTransferFrom(msg.sender, address(this), cAmount);
        emit Contribution(msg.sender, cAmount);  
    }

    function contributeInternal(uint256 amount) internal returns (uint256)  {

        require(isFundraisingStarted() == true, "fundraising not started");
        require(isFundraisingFinished() == false, "fundraising already finished");
        uint256 contributed = investorContributed[msg.sender];
        require(contributed.add(amount) >= minInvestorContribution && contributed.add(amount) <= maxInvestorContribution, "invalid amount");
        if (minSakeHolder > 0) {
            uint256 sakeAmount = IERC20(SAKE).balanceOf(msg.sender);
            require(sakeAmount >= minSakeHolder, "sake insufficient");
        }
        if (contributed == 0) {
            investorsCount = investorsCount + 1; 
        }
        transfersCount = transfersCount + 1;  

        if (totalInvestorContributed.add(amount) <= maxPoolContribution) {
            investorContributed[msg.sender] = contributed.add(amount); 
            totalInvestorContributed = totalInvestorContributed.add(amount); 
            return amount;
        }else{
            uint256 cAmount = maxPoolContribution.sub(totalInvestorContributed);
            investorContributed[msg.sender] = contributed.add(cAmount); 
            totalInvestorContributed = maxPoolContribution;
            return cAmount;
        }
    }

    function isFundraisingStarted() public view returns (bool) {

        return projectPartyFundDone && block.timestamp >= fundraisingStartTimestamp; 
    }

    function isFundraisingFinished()  public view returns (bool) {

        if (block.timestamp >= fundraisingStartTimestamp.add(fundraisingDurationDays)) {
            return true;
        }
        if (maxPoolContribution == totalInvestorContributed && projectPartyFundDone) {
            return true;
        }
        return false;
    }

    function isFundraisingSucceed()  public view returns (bool) {

        require(isFundraisingFinished() == true, "fundraising not finished");
        return projectPartyFundDone && totalInvestorContributed >= minPoolContribution;
    } 

    function addLiquidityToSakeSwap() external onlyOwner nonReentrant whenNotPaused {

        require(lpUnlockStartTimestamp == 0, "repeatedly operation");
        require(isFundraisingSucceed() == true, "fundraising not succeeded");

        lpUnlockStartTimestamp = block.timestamp;

        uint256 projectPartyAmount = 0;
        uint256 contributionAmount = 0;
        if (totalInvestorContributed == maxPoolContribution) {
            projectPartyAmount = totalProjectPartyFund;
            contributionAmount = maxPoolContribution; 
        }else{
            projectPartyAmount = totalProjectPartyFund.mul(totalInvestorContributed).div(maxPoolContribution);
            uint256 redundant = totalProjectPartyFund.sub(projectPartyAmount); 
            contributionAmount = totalInvestorContributed;
            projectPartyToken.transfer(projectPartyAddress, redundant);  
        }
        projectPartyToken.approve(address(sakeRouter), projectPartyAmount);
        contributionToken.approve(address(sakeRouter), contributionAmount);
        (, , totalLPCreated) = sakeRouter.addLiquidity(
            address(projectPartyToken),
            address(contributionToken),
            projectPartyAmount,
            contributionAmount,
            0,
            0,
            address(this),
            now + 60
        );
        require(totalLPCreated != 0 , "add liquidity failed");
        perUnlockLP = totalLPCreated.div(lpLockPeriod.div(lpUnlockFrequency));
    }

    function setSakeAddress(address _sakeRouter, address _sakeFactory, address _weth, address _sake) external onlyOwner {

        sakeFactory = ISakeSwapFactory(_sakeFactory);
        sakeRouter = ISakeSwapRouter(_sakeRouter);
        WETH = _weth;
        SAKE = _sake;
    } 

    function projectPartyRefund() external nonReentrant whenNotPaused {

        require(msg.sender == projectPartyAddress, "invalid address");
        require(projectPartyRefundDone == false, "repeatedly operation");
        require(isFundraisingSucceed() == false, "fundraising succeed");
        projectPartyRefundDone = true;
        projectPartyToken.transfer(msg.sender, totalProjectPartyFund); 
    }

    function investorRefund() external nonReentrant whenNotPaused {

        require(isFundraisingSucceed() == false, "fundraising succeed");

        uint256 amount = investorContributed[msg.sender];
        require(amount > 0, "zero amount");

        investorContributed[msg.sender] = 0; 
        if (WETH == address(contributionToken)){
            IWETH(WETH).withdraw(amount);
            TransferHelper.safeTransferETH(msg.sender, amount);
        }else{
            contributionToken.transfer(msg.sender, amount);
        }
    }

    function projectPartyUnlockLP() external nonReentrant whenNotPaused {

        require(msg.sender == projectPartyAddress, "invalid address");
        (uint256 availableTimes, uint256 amount) = getUnlockLPAmount(false, msg.sender);
        projectPartUnlockedLPTimes = projectPartUnlockedLPTimes.add(availableTimes);
        unlockLP(amount);
    } 

    function investorUnlockLP() external nonReentrant whenNotPaused {

        require(investorContributed[msg.sender] > 0, "invalid address");
        (uint256 availableTimes, uint256 amount) = getUnlockLPAmount(true, msg.sender);
        investorUnlockedLPTimes[msg.sender] = investorUnlockedLPTimes[msg.sender].add(availableTimes);
        unlockLP(amount);
    } 


    function getUnlockLPAmount(bool isInvestor, address user) public view returns (uint256 availableTimes, uint256 amount) {

        require(lpUnlockStartTimestamp > 0, "add liquidity not finished");

        uint256 totalTimes = 0; 
        if (block.timestamp > lpUnlockStartTimestamp.add(lpLockPeriod)){
            totalTimes = lpLockPeriod.div(lpUnlockFrequency);
        }else{
            totalTimes = (block.timestamp.sub(lpUnlockStartTimestamp)).div(lpUnlockFrequency);      
        }

        if (isInvestor){
            availableTimes = totalTimes.sub(investorUnlockedLPTimes[user]);
            require(availableTimes > 0, "zero amount to unlock");

            uint256 totalRelease = perUnlockLP.mul(availableTimes);
            amount = totalRelease.div(2).mul(investorContributed[user]).div(totalInvestorContributed);
        }else{
            availableTimes = totalTimes.sub(projectPartUnlockedLPTimes);
            require(availableTimes > 0, "zero amount to unlock");

            uint256 totalRelease = perUnlockLP.mul(availableTimes);
            amount = totalRelease.div(2);    
        }
    } 

    function unlockLP(uint256 amount) internal {

        uint256 feeAmount = amount.mul(lpUnlockFeeRatio).div(100);
        ISakeSwapPair pair = ISakeSwapPair(sakeFactory.getPair(address(projectPartyToken), address(contributionToken)));
        require(pair != ISakeSwapPair(address(0)), "invalid sake pair");
        require(pair.transfer(feeAddress, feeAmount), "transfer fee fail");
        require(pair.transfer(msg.sender, amount.sub(feeAmount)), "transfer fail");
        emit UnlockLP(msg.sender, amount.sub(feeAmount), feeAmount);
    }

    function setPaused(bool bPause) external nonReentrant onlyOwner {

        if(bPause){
            _pause();
        } else {
            _unpause();
        }
    }
}


pragma solidity 0.6.12;


contract SakeILOFactory {


    mapping(address => mapping(address => address)) public getPair;
    address[] public allPairs;
    address public owner;

    constructor() public {
        owner = msg.sender;
    }

    modifier onlyOwner() {

        require(owner == msg.sender, "Not Owner");
        _;
    }

    event PairCreated(address indexed projectPartyToken, address indexed contributionToken, address pair, uint256);

    function createPair(address projectPartyToken, address contributionToken, uint256 fundraisingDurationDays, 
        uint256 totalProjectPartyFund, uint256 maxPoolContribution, uint256 minPoolContribution) external onlyOwner returns (address payable pair) {


        require(projectPartyToken != contributionToken, "identical address");
        require(projectPartyToken != address(0) && contributionToken != address(0), "zero address");
        require(totalProjectPartyFund > 0, "invalid project party fund");
        require(maxPoolContribution >= minPoolContribution && minPoolContribution > 0, "invalid pool contribution");
        require(fundraisingDurationDays > 0, "invalid period");

        require(getPair[projectPartyToken][contributionToken] == address(0), "PAIR_EXISTS"); // single check is sufficient
        bytes memory bytecode = type(SakeILO).creationCode;
        bytes32 salt = keccak256(abi.encodePacked(projectPartyToken, contributionToken));
        assembly {
            pair := create2(0, add(bytecode, 32), mload(bytecode), salt)
        }
        SakeILO(pair).initialize(projectPartyToken, contributionToken, fundraisingDurationDays, totalProjectPartyFund, maxPoolContribution, minPoolContribution, msg.sender);

        getPair[projectPartyToken][contributionToken] = pair;
        allPairs.push(pair);

        emit PairCreated(projectPartyToken, contributionToken, pair, allPairs.length);
    }

    function allPairsLength() external view returns (uint256) {

        return allPairs.length;
    }

    function transferOwnership(address newOwner) public onlyOwner {

        require(newOwner != address(0), "zero address");
        owner = newOwner;
    }

}