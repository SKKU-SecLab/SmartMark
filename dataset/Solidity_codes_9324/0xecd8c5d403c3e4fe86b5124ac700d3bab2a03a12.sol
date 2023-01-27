
pragma solidity >=0.6.0 <0.8.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}// MIT

pragma solidity >=0.6.0 <0.8.0;

library SafeMath {

    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b > a) return (false, 0);
        return (true, a - b);
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b == 0) return (false, 0);
        return (true, a / b);
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b == 0) return (false, 0);
        return (true, a % b);
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b <= a, "SafeMath: subtraction overflow");
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0, "SafeMath: division by zero");
        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0, "SafeMath: modulo by zero");
        return a % b;
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b <= a, errorMessage);
        return a - b;
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        return a / b;
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        return a % b;
    }
}// MIT

pragma solidity >=0.6.2 <0.8.0;

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
}// MIT

pragma solidity >=0.6.0 <0.8.0;


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
}// MIT

pragma solidity >=0.6.0 <0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}// MIT

pragma solidity >=0.6.0 <0.8.0;

abstract contract ReentrancyGuard {

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
}// MIT

pragma solidity >=0.6.0 <0.8.0;


contract TokenTimelock {

    using SafeERC20 for IERC20;

    IERC20 private _token;

    address private _beneficiary;

    uint256 private _releaseTime;

    constructor (IERC20 token_, address beneficiary_, uint256 releaseTime_) public {
        require(releaseTime_ > block.timestamp, "TokenTimelock: release time is before current time");
        _token = token_;
        _beneficiary = beneficiary_;
        _releaseTime = releaseTime_;
    }

    function token() public view virtual returns (IERC20) {

        return _token;
    }

    function beneficiary() public view virtual returns (address) {

        return _beneficiary;
    }

    function releaseTime() public view virtual returns (uint256) {

        return _releaseTime;
    }

    function release() public virtual {

        require(block.timestamp >= releaseTime(), "TokenTimelock: current time is before release time");

        uint256 amount = token().balanceOf(address(this));
        require(amount > 0, "TokenTimelock: no tokens to release");

        token().safeTransfer(beneficiary(), amount);
    }
}// MIT

pragma solidity >=0.6.0 <0.8.0;

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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
}// UNLICENSED

pragma solidity ^0.7.3;

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

}// UNLICENSED

pragma solidity ^0.7.3;

interface IUniswapV2Factory {

  event PairCreated(address indexed token0, address indexed token1, address pair, uint);

  function getPair(address tokenA, address tokenB) external view returns (address pair);

  function allPairs(uint) external view returns (address pair);

  function allPairsLength() external view returns (uint);


  function feeTo() external view returns (address);

  function feeToSetter() external view returns (address);


  function createPair(address tokenA, address tokenB) external returns (address pair);

}//UNLICENSED




pragma solidity ^0.7.3;


contract FontsPresale is Context, ReentrancyGuard, Ownable {

    using SafeMath for uint;
    using SafeMath for uint256;
    using SafeERC20 for IERC20;


    uint256 public MIN_CONTRIBUTION = 0.1 ether;
    uint256 public MAX_CONTRIBUTION = 6 ether;

    uint256 public HARD_CAP = 180 ether; //@change for testing 

    uint256 constant FONTS_PER_ETH_PRESALE = 1111;
    uint256 constant FONTS_PER_ETH_UNISWAP = 700;

    uint256 public UNI_LP_ETH = 86 ether;
    uint256 public UNI_LP_FONT;

    uint256 public constant UNLOCK_PERCENT_PRESALE_INITIAL = 50; //For presale buyers instant release
    uint256 public constant UNLOCK_PERCENT_PRESALE_SECOND = 30; //For presale buyers after 30 days
    uint256 public constant UNLOCK_PERCENT_PRESALE_FINAL = 20; //For presale buyers after 60 days

    uint256 public DURATION_REFUND = 7 days;
    uint256 public DURATION_LIQUIDITY_LOCK = 365 days;

    uint256 public DURATION_TOKEN_DISTRIBUTION_ROUND_2 = 30 days;
    uint256 public DURATION_TOKEN_DISTRIBUTION_ROUND_3 = 60 days;    

    address FONT_TOKEN_ADDRESS = 0x4C25Bdf026Ea05F32713F00f73Ca55857Fbf6342; //FONT Token address

    IUniswapV2Router02 constant UNISWAP_V2_ADDRESS =  IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
    IUniswapV2Factory constant uniswapFactory = IUniswapV2Factory(0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f); 



    IERC20 public FONT_ERC20; //Font token address

    address public ERC20_uniswapV2Pair; //Uniswap Pair address

    TokenTimelock public UniLPTimeLock;

    
    uint256 public tokensBought; //Total tokens bought
    uint256 public tokensWithdrawn;  //Total tokens withdrawn by buyers

    bool public isStopped = false;
    bool public presaleStarted = false;
    bool public uniPairCreated = false;
    bool public liquidityLocked = false;
    bool public bulkRefunded = false;

    bool public isFontDistributedR1 = false;
    bool public isFontDistributedR2 = false;
    bool public isFontDistributedR3 = false;



    uint256 public roundTwoUnlockTime; 
    uint256 public roundThreeUnlockTime; 
    
    bool liquidityAdded = false;

    address payable contract_owner;
    
    
    uint256 public liquidityUnlockTime;
    
    uint256 public ethSent; //ETH Received
    
    uint256 public lockedLiquidityAmount;
    uint256 public refundTime; 

    mapping(address => uint) ethSpent;
    mapping(address => uint) fontBought;
    mapping(address => uint) fontHolding;
    address[] public contributors;

    

    constructor() {
        contract_owner = _msgSender(); 
        UNI_LP_FONT = UNI_LP_ETH.mul(FONTS_PER_ETH_UNISWAP);
        FONT_ERC20 = IERC20(FONT_TOKEN_ADDRESS);
    }


    receive() external payable {   
        buyTokens();
    }
    


    function allowRefunds() external onlyOwner nonReentrant {


        isStopped = true;
    }

    function buyTokens() public payable nonReentrant {

        require(_msgSender() == tx.origin);
        require(presaleStarted == true, "Presale is paused");
        require(msg.value >= MIN_CONTRIBUTION, "Less than 0.1 ETH");
        require(msg.value <= MAX_CONTRIBUTION, "More than 6 ETH");
        require(ethSent < HARD_CAP, "Hardcap reached");        
        require(msg.value.add(ethSent) <= HARD_CAP, "Hardcap will reached");
        require(ethSpent[_msgSender()].add(msg.value) <= MAX_CONTRIBUTION, "> 6 ETH");

        require(!isStopped, "Presale stopped"); //@todo

        
        uint256 tokens = msg.value.mul(FONTS_PER_ETH_PRESALE);
        require(FONT_ERC20.balanceOf(address(this)) >= tokens, "Not enough tokens"); //@tod

        if(ethSpent[_msgSender()] == 0) {
            contributors.push(_msgSender()); //Create list of contributors    
        }
        
        ethSpent[_msgSender()] = ethSpent[_msgSender()].add(msg.value);

        tokensBought = tokensBought.add(tokens);
        ethSent = ethSent.add(msg.value);

        fontBought[_msgSender()] = fontBought[_msgSender()].add(tokens); //Add fonts bought by contributor

        fontHolding[_msgSender()] = fontHolding[_msgSender()].add(tokens); //Add fonts Holding by contributor

    }

    function createUniPair() external onlyOwner {

        require(!liquidityAdded, "liquidity Already added");
        require(!uniPairCreated, "Already Created Unipair");

        ERC20_uniswapV2Pair = uniswapFactory.createPair(address(FONT_ERC20), UNISWAP_V2_ADDRESS.WETH());

        uniPairCreated = true;
    }


   
    function addLiquidity() external onlyOwner {

        require(!liquidityAdded, "liquidity Already added");
        require(ethSent >= HARD_CAP, "Hard cap not reached");   
        require(uniPairCreated, "Uniswap pair not created");


        FONT_ERC20.approve(address(UNISWAP_V2_ADDRESS), UNI_LP_FONT);
        
        UNISWAP_V2_ADDRESS.addLiquidityETH{ value: UNI_LP_ETH } (
            address(FONT_ERC20),
            UNI_LP_FONT,
            UNI_LP_FONT,
            UNI_LP_ETH,
            address(contract_owner),
            block.timestamp
        );
       
        liquidityAdded = true;
       
        if(!isStopped)
            isStopped = true;

        roundTwoUnlockTime = block.timestamp.add(DURATION_TOKEN_DISTRIBUTION_ROUND_2); 
        roundThreeUnlockTime = block.timestamp.add(DURATION_TOKEN_DISTRIBUTION_ROUND_3); 
    }

    function lockLiquidity() external onlyOwner {

        require(liquidityAdded, "Add Liquidity");
        require(!liquidityLocked, "Already Locked");
        IERC20 liquidityTokens = IERC20(ERC20_uniswapV2Pair); //Get the Uni LP token
        if(liquidityUnlockTime <= block.timestamp) {
            liquidityUnlockTime = block.timestamp.add(DURATION_LIQUIDITY_LOCK);
        }
        UniLPTimeLock = new TokenTimelock(liquidityTokens, contract_owner, liquidityUnlockTime);
        liquidityLocked = true;
        lockedLiquidityAmount = liquidityTokens.balanceOf(contract_owner);
    }
    
    function unlockLiquidity() external onlyOwner  {      

        UniLPTimeLock.release();
    }

    function unlockLiquidityTime() external view returns(uint256) {      

        return UniLPTimeLock.releaseTime();
    }    

    
    function distributeTokensRoundOne() external onlyOwner {

        require(liquidityAdded, "Add Uni Liquidity");        
        require(!isFontDistributedR1, "Round 1 done");
        for (uint i=0; i<contributors.length; i++) {          
            if(fontHolding[contributors[i]] > 0) {
                uint256 tokenAmount_ = fontBought[contributors[i]];
                tokenAmount_ = tokenAmount_.mul(UNLOCK_PERCENT_PRESALE_INITIAL).div(100);
                fontHolding[contributors[i]] = fontHolding[contributors[i]].sub(tokenAmount_);
                FONT_ERC20.safeTransfer(contributors[i], tokenAmount_);
                tokensWithdrawn = tokensWithdrawn.add(tokenAmount_);
            }
        }
        isFontDistributedR1 = true;
    }

    function distributeTokensRoundTwo() external nonReentrant{

        require(liquidityAdded, "Add Uni Liquidity"); 
        require(isFontDistributedR1, "Do Round 1");
        require(block.timestamp >= roundTwoUnlockTime, "Timelocked");
        require(!isFontDistributedR2, "Round 2 done");

        for (uint i=0; i<contributors.length; i++) {
            if(fontHolding[contributors[i]] > 0) {
                uint256 tokenAmount_ = fontBought[contributors[i]];
                tokenAmount_ = tokenAmount_.mul(UNLOCK_PERCENT_PRESALE_SECOND).div(100);
                fontHolding[contributors[i]] = fontHolding[contributors[i]].sub(tokenAmount_);
                FONT_ERC20.safeTransfer(contributors[i], tokenAmount_);
                tokensWithdrawn = tokensWithdrawn.add(tokenAmount_);
            }
        }
        isFontDistributedR2 = true;
    }

    function distributeTokensRoundThree() external nonReentrant{

        require(liquidityAdded, "Add Uni Liquidity"); 
        require(isFontDistributedR2, "Do Round 2");
        require(block.timestamp >= roundThreeUnlockTime, "Timelocked");
        require(!isFontDistributedR3, "Round 3 done");

        for (uint i=0; i<contributors.length; i++) {
            if(fontHolding[contributors[i]] > 0) {
                uint256 tokenAmount_ = fontBought[contributors[i]];
                tokenAmount_ = tokenAmount_.mul(UNLOCK_PERCENT_PRESALE_FINAL).div(100);
                fontHolding[contributors[i]] = fontHolding[contributors[i]].sub(tokenAmount_);
                FONT_ERC20.safeTransfer(contributors[i], tokenAmount_);
                tokensWithdrawn = tokensWithdrawn.add(tokenAmount_);
            }
        }
        isFontDistributedR3 = true;
    }
    


    function withdrawEth(uint amount) external onlyOwner returns(bool){

        require(liquidityAdded,"After UNI LP");        
        require(amount <= address(this).balance);
        contract_owner.transfer(amount);
        return true;
    }    

    function withdrawFont(uint amount) external onlyOwner returns(bool){

        require(liquidityAdded,"After UNI LP");
        require(isFontDistributedR3, "After distribute to buyers");
        FONT_ERC20.safeTransfer(_msgSender(), amount);
        return true;
    }

    function userFontBalance(address user) external view returns (uint256) {

        return fontHolding[user];
    }

    function userFontBought(address user) external view returns (uint256) {

        return fontBought[user];
    }

    function userEthContribution(address user) external view returns (uint256) {

        return ethSpent[user];
    }    

    function getRefund() external nonReentrant {

        require(_msgSender() == tx.origin);
        require(isStopped, "Should be stopped");
        require(!liquidityAdded);
        require(ethSent < HARD_CAP && block.timestamp >= refundTime, "Cannot refund");
        uint256 amount = ethSpent[_msgSender()];
        require(amount > 0, "No ETH");
        address payable user = _msgSender();
        
        ethSpent[user] = 0;
        fontBought[user] = 0;
        fontHolding[user] = 0;
        user.transfer(amount);
    }

    function bulkRefund() external nonReentrant {

        require(!liquidityAdded);
        require(!bulkRefunded, "Already refunded");
        require(isStopped, "Should be stopped");
        require(ethSent < HARD_CAP && block.timestamp >= refundTime, "Cannot refund");
        for (uint i=0; i<contributors.length; i++) {
            address payable user = payable(contributors[i]);
            uint256 amount = ethSpent[user];
            if(amount > 0) {
                ethSpent[user] = 0;
                fontBought[user] = 0;
                fontHolding[user] = 0;                
                user.transfer(amount);
            }
        }        
        bulkRefunded = true;
    }    
    
    function startPresale() external onlyOwner { 

        liquidityUnlockTime = block.timestamp.add(DURATION_LIQUIDITY_LOCK);
        refundTime = block.timestamp.add(DURATION_REFUND);        
        presaleStarted = true;
    }
    
    function pausePresale() external onlyOwner { 

        presaleStarted = false;
    }


}