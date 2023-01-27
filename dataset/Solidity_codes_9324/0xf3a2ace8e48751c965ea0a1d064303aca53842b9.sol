pragma solidity 0.6.4;

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
pragma solidity 0.6.4;


interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);//from address(0) for minting

    event Approval(address indexed owner, address indexed spender, uint256 value);
}
pragma solidity 0.6.4;

interface HEX {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);//from address(0) for minting

    event Approval(address indexed owner, address indexed spender, uint256 value);

   function stakeStart(uint256 newStakedHearts, uint256 newStakedDays) external;

   function stakeEnd(uint256 stakeIndex, uint40 stakeIdParam) external;

   function stakeCount(address stakerAddr) external view returns (uint256);

   function stakeLists(address owner, uint256 stakeIndex) external view returns (uint40, uint72, uint72, uint16, uint16, uint16, bool);

   function currentDay() external view returns (uint256);

   function dailyDataRange(uint256 beginDay, uint256 endDay) external view returns (uint256[] memory);

   function globalInfo() external view returns (uint256[13] memory);


}
pragma solidity 0.6.4;

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
}//HEXMONEY.sol

pragma solidity 0.6.4;


library SafeERC20 {

    using SafeMath for uint256;
    using Address for address;

    function safeApprove(IERC20 token, address spender, uint256 value) internal {

        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {


        require(address(token).isContract(), "SafeERC20: call to non-contract");

        (bool success, bytes memory returndata) = address(token).call(data);
        require(success, "SafeERC20: low-level call failed");

        if (returndata.length > 0) { // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
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


contract TokenEvents {


    event TokenFreeze(
        address indexed user,
        uint value
    );

    event TokenUnfreeze(
        address indexed user,
        uint value
    );
    
    event FreeMintFreeze(
        address indexed user,
        uint value,
        uint indexed dapp //0 for ref, increment per external dapp
    );

    event FreeMintUnfreeze(
        address indexed user,
        uint value
    );
    
    event Transform (
        uint hexAmt,
        uint hxyAmt,
        address indexed transformer
    );

    event FounderLock (
        uint hxyAmt,
        uint timestamp
    );

    event FounderUnlock (
        uint hxyAmt,
        uint timestamp
    );
    
    event LiquidityPush(
        uint256 amountA,
        uint256 amountB,
        uint256 liquidity
    );
    
    event DividendPush(
        uint256 hexDivs  
    );
    
}

contract HEXMONEY is IERC20, TokenEvents {


    using SafeMath for uint256;
    using SafeERC20 for HEXMONEY;
    
    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    address public factoryAddress = 0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f;
    address public routerAddress = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
    address public uniHEXHXY = address(0);
    IUniswapV2Pair internal uniPairInterface = IUniswapV2Pair(uniHEXHXY);
    IUniswapV2Router02 internal uniV2Router = IUniswapV2Router02(routerAddress);
    
    address internal hexAddress = 0x2b591e99afE9f32eAA6214f7B7629768c40Eeb39;
    HEX internal hexInterface = HEX(hexAddress);

    bool public roomActive;
    uint public totalHeartsTransformed = 0;
    uint public totalHxyTransformed = 0;
    uint public totalDividends = 0;
    uint public totalLiquidityAdded = 0;
    uint public hexLiquidity = 0;
    uint public hexDivs = 0;

    uint public unlockLvl = 0;
    uint public founderLockStartTimestamp = 0;
    uint public founderLockDayLength = 1825;//5 years (10% released every sixmonths)
    uint public founderLockedTokens = 0;
    uint private allFounderLocked = 0;

    bool public mintBlock;//disables any more tokens ever being minted once _totalSupply reaches _maxSupply
    uint public minFreezeDayLength = 7; // min days to freeze
    uint internal daySeconds = 86400; // seconds in a day
    uint public totalFrozen = 0;
    mapping (address => uint) public tokenFrozenBalances;//balance of HXY frozen mapped by user
    uint public totalFreeMintFrozen = 0;
    mapping (address => uint) public freeMintFrozenBalances;//balance of HXY free minted frozen mapped by user

    uint256 public _maxSupply = 6000000000000000;// max supply @ 60M
    uint256 internal _totalSupply;
    string public constant name = "HEX Money";
    string public constant symbol = "HXY";
    uint public constant decimals = 8;
    
    address payable public airdropContract = address(0);
    address public multisig = address(0);
    address payable internal _p1 = 0xb9F8e9dad5D985dF35036C61B6Aded2ad08bd53f;
    address payable internal _p2 = 0xe551072153c02fa33d4903CAb0435Fb86F1a80cb;
    address payable internal _p3 = 0xc5f517D341c1bcb2cdC004e519AF6C4613A8AB2d;
    address payable internal _p4 = 0x47705B509A4Fe6a0237c975F81030DAC5898Dc06;
    address payable internal _p5 = 0x31101541339B4B3864E728BbBFc1b8A0b3BCAa45;
    
    bool private sync;
    bool public multisigSet;
    bool public transformsActive;
    
    address[] public minterAddresses;// future contracts to enable minting of HXY

    mapping(address => bool) admins;
    mapping(address => bool) minters;
    mapping (address => Frozen) public frozen;
    mapping (address => FreeMintFrozen) public freeMintFrozen;

    struct Frozen{
        uint256 freezeStartTimestamp;
        uint256 totalEarnedInterest;
    }
    
    struct FreeMintFrozen{
        uint256 totalHxyMinted;
    }
    
    modifier onlyMultisig(){

        require(msg.sender == multisig, "not authorized");
        _;
    }

    modifier onlyAdmins(){

        require(admins[msg.sender], "not an admin");
        _;
    }

    modifier onlyMinters(){

        require(minters[msg.sender], "not a minter");
        _;
    }
    
    modifier onlyOnceMultisig(){

        require(!multisigSet, "cannot call twice");
        multisigSet = true;
        _;
    }
    
    modifier onlyOnceTransform(){

        require(!transformsActive, "cannot call twice");
        transformsActive = true;
        _;
    }
    
    modifier synchronized {

        require(!sync, "Sync lock");
        sync = true;
        _;
        sync = false;
    }

    constructor(uint256 v2Supply) public {
        admins[_p1] = true;
        admins[_p2] = true;
        admins[_p3] = true;
        admins[msg.sender] = true;
        mintInitialTokens(v2Supply);
    }


    receive() external payable{
        donate();
    }

    
    function totalSupply() public view override returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {

        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {

        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {

        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {

        _approve(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {

        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {

        _approve(msg.sender, spender, _allowances[msg.sender][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {

        _approve(msg.sender, spender, _allowances[msg.sender][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal {

        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal {

        uint256 amt = amount;
        require(account != address(0), "ERC20: mint to the zero address");
        if(!mintBlock){
            if(_totalSupply < _maxSupply){
                if(_totalSupply.add(amt) > _maxSupply){
                    amt = _maxSupply.sub(_totalSupply);
                    _totalSupply = _maxSupply;
                    mintBlock = true;
                }
                else{
                    _totalSupply = _totalSupply.add(amt);
                }
                _balances[account] = _balances[account].add(amt);
                emit Transfer(address(0), account, amt);
            }
        }
    }

    function _burn(address account, uint256 amount) internal {

        require(account != address(0), "ERC20: burn from the zero address");

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal {

        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _burnFrom(address account, uint256 amount) internal {

        _burn(account, amount);
        _approve(account, msg.sender, _allowances[account][msg.sender].sub(amount, "ERC20: burn amount exceeds allowance"));
    }

    event Transfer(address indexed from, address indexed to, uint256 value);//from address(0) for minting

    event Approval(address indexed owner, address indexed spender, uint256 value);

    function mintInitialTokens(uint v2Supply)
        internal
        synchronized
    {

        require(v2Supply <= _maxSupply, "cannot mint");
        uint256 _founderLockedTokens = _maxSupply.div(10);
        _mint(_p1, v2Supply.sub(_founderLockedTokens));//mint HXY to airdrop on launch
        _mint(address(this), _founderLockedTokens);//mint HXY to be frozen for 10 years, 10% unfrozen every year
        founderLock(_founderLockedTokens);
    }

    function founderLock(uint tokens)
        internal
    {

        founderLockStartTimestamp = now;
        founderLockedTokens = tokens;
        allFounderLocked = tokens;
        emit FounderLock(tokens, founderLockStartTimestamp);
    }

    function unlock()
        public
        onlyAdmins
        synchronized
    {

        uint sixMonths = founderLockDayLength/10;
        require(unlockLvl < 10, "token unlock complete");
        require(founderLockStartTimestamp.add(sixMonths.mul(daySeconds)) <= now, "tokens cannot be unfrozen yet");//must be at least over 6 months
        uint value = allFounderLocked/10;
        if(founderLockStartTimestamp.add((sixMonths).mul(daySeconds)) <= now && unlockLvl == 0){
            unlockLvl++;
            founderLockedTokens = founderLockedTokens.sub(value);
            transfer(_p1, value.mul(30).div(100));
            transfer(_p2, value.mul(30).div(100));
            transfer(_p3, value.mul(20).div(100));
            transfer(_p4, value.mul(15).div(100));
            transfer(_p5, value.mul(5).div(100));
        }
        else if(founderLockStartTimestamp.add((sixMonths * 2).mul(daySeconds)) <= now && unlockLvl == 1){
            unlockLvl++;
            founderLockedTokens = founderLockedTokens.sub(value);
            transfer(_p1, value.mul(30).div(100));
            transfer(_p2, value.mul(30).div(100));
            transfer(_p3, value.mul(20).div(100));
            transfer(_p4, value.mul(15).div(100));
            transfer(_p5, value.mul(5).div(100));
        }
        else if(founderLockStartTimestamp.add((sixMonths * 3).mul(daySeconds)) <= now && unlockLvl == 2){
            unlockLvl++;
            founderLockedTokens = founderLockedTokens.sub(value);
            transfer(_p1, value.mul(30).div(100));
            transfer(_p2, value.mul(30).div(100));
            transfer(_p3, value.mul(20).div(100));
            transfer(_p4, value.mul(15).div(100));
            transfer(_p5, value.mul(5).div(100));
        }
        else if(founderLockStartTimestamp.add((sixMonths * 4).mul(daySeconds)) <= now && unlockLvl == 3){
            unlockLvl++;
            founderLockedTokens = founderLockedTokens.sub(value);
            transfer(_p1, value.mul(30).div(100));
            transfer(_p2, value.mul(30).div(100));
            transfer(_p3, value.mul(20).div(100));
            transfer(_p4, value.mul(15).div(100));
            transfer(_p5, value.mul(5).div(100));
        }
        else if(founderLockStartTimestamp.add((sixMonths * 5).mul(daySeconds)) <= now && unlockLvl == 4){
            unlockLvl++;
            founderLockedTokens = founderLockedTokens.sub(value);
            transfer(_p1, value.mul(30).div(100));
            transfer(_p2, value.mul(30).div(100));
            transfer(_p3, value.mul(20).div(100));
            transfer(_p4, value.mul(15).div(100));
            transfer(_p5, value.mul(5).div(100));
        }
        else if(founderLockStartTimestamp.add((sixMonths * 6).mul(daySeconds)) <= now && unlockLvl == 5){
            unlockLvl++;
            founderLockedTokens = founderLockedTokens.sub(value);
            transfer(_p1, value.mul(30).div(100));
            transfer(_p2, value.mul(30).div(100));
            transfer(_p3, value.mul(20).div(100));
            transfer(_p4, value.mul(15).div(100));
            transfer(_p5, value.mul(5).div(100));
        }
        else if(founderLockStartTimestamp.add((sixMonths * 7).mul(daySeconds)) <= now && unlockLvl == 6){
            unlockLvl++;
            founderLockedTokens = founderLockedTokens.sub(value);
            transfer(_p1, value.mul(30).div(100));
            transfer(_p2, value.mul(30).div(100));
            transfer(_p3, value.mul(20).div(100));
            transfer(_p4, value.mul(15).div(100));
            transfer(_p5, value.mul(5).div(100));
        }
        else if(founderLockStartTimestamp.add((sixMonths * 8).mul(daySeconds)) <= now && unlockLvl == 7)
        {
            unlockLvl++;     
            founderLockedTokens = founderLockedTokens.sub(value);      
            transfer(_p1, value.mul(30).div(100));
            transfer(_p2, value.mul(30).div(100));
            transfer(_p3, value.mul(20).div(100));
            transfer(_p4, value.mul(15).div(100));
            transfer(_p5, value.mul(5).div(100));
        }
        else if(founderLockStartTimestamp.add((sixMonths * 9).mul(daySeconds)) <= now && unlockLvl == 8){
            unlockLvl++;
            founderLockedTokens = founderLockedTokens.sub(value);
            transfer(_p1, value.mul(30).div(100));
            transfer(_p2, value.mul(30).div(100));
            transfer(_p3, value.mul(20).div(100));
            transfer(_p4, value.mul(15).div(100));
            transfer(_p5, value.mul(5).div(100));
        }
        else if(founderLockStartTimestamp.add((sixMonths * 10).mul(daySeconds)) <= now && unlockLvl == 9){
            unlockLvl++;
            if(founderLockedTokens >= value){
                founderLockedTokens = founderLockedTokens.sub(value);
            }
            else{
                value = founderLockedTokens;
                founderLockedTokens = 0;
            }
            transfer(_p1, value.mul(30).div(100));
            transfer(_p2, value.mul(30).div(100));
            transfer(_p3, value.mul(20).div(100));
            transfer(_p4, value.mul(15).div(100));
            transfer(_p5, value.mul(5).div(100));
        }
        else{
            revert();
        }
        emit FounderUnlock(value, now);
    }

    function FreezeTokens(uint amt)
        public
    {

        require(amt > 0, "zero input");
        require(tokenBalance() >= amt, "Error: insufficient balance");//ensure user has enough funds
        if(isFreezeFinished(msg.sender)){
            UnfreezeTokens();//unfreezes all currently frozen tokens + profit
        }
        tokenFrozenBalances[msg.sender] = tokenFrozenBalances[msg.sender].add(amt);
        totalFrozen = totalFrozen.add(amt);
        frozen[msg.sender].freezeStartTimestamp = now;
        _transfer(msg.sender, address(this), amt);//make transfer
        emit TokenFreeze(msg.sender, amt);
    }
    
    function UnfreezeTokens()
        public
        synchronized
    {

        require(tokenFrozenBalances[msg.sender] > 0,"Error: unsufficient frozen balance");//ensure user has enough frozen funds
        require(isFreezeFinished(msg.sender), "tokens cannot be unfrozen yet. min 7 day freeze");
        uint amt = tokenFrozenBalances[msg.sender];
        uint256 interest = calcFreezingRewards(msg.sender);
        _mint(msg.sender, interest);//mint HXY - total unfrozen / 1000 * (minFreezeDayLength + days past) @ 36.5% per year
        frozen[msg.sender].totalEarnedInterest += interest;
        tokenFrozenBalances[msg.sender] = 0;
        frozen[msg.sender].freezeStartTimestamp = 0;
        totalFrozen = totalFrozen.sub(amt);
        _transfer(address(this), msg.sender, amt);//make transfer
        emit TokenUnfreeze(msg.sender, amt);
    }


    function calcFreezingRewards(address _user)
        public
        view
        returns(uint)
    {

        return (tokenFrozenBalances[_user].div(1000) * (minFreezeDayLength + daysPastMinFreezeTime(_user)));
    }
    
    function daysPastMinFreezeTime(address _user)
        public
        view
        returns(uint)
    {

        if(frozen[_user].freezeStartTimestamp == 0){
            return 0;
        }
        uint daysPast = now.sub(frozen[_user].freezeStartTimestamp).div(daySeconds);
        if(daysPast >= minFreezeDayLength){
            return daysPast - minFreezeDayLength;// returns 0 if under 1 day passed
        }
        else{
            return 0;
        }
    }
    
    function FreezeFreeMint(uint amt, address user, uint dapp)
        public
        onlyMinters
        synchronized
    {

        require(amt > 0, "zero input");
        if(!mintBlock){
            uint t = totalSupply();
            freeMintHXY(amt,address(this));//mint HXY to contract and freeze
            if(totalSupply().sub(t) < amt){
                amt = totalSupply().sub(t);
            }
            freeMintFrozenBalances[user] = freeMintFrozenBalances[user].add(amt);
            totalFrozen = totalFrozen.add(amt);
            totalFreeMintFrozen = totalFreeMintFrozen.add(amt);
            freeMintFrozen[user].totalHxyMinted += amt;
            emit FreeMintFreeze(user, amt, dapp);
        }

    }
    
    function FreezeRefFreeMint(uint amt, address ref)
        internal
    {

        require(amt > 0, "zero input");
        if(!mintBlock){
            uint t = totalSupply();
            freeMintHXY(amt,address(this));//mint HXY to contract and freeze
            if(totalSupply().sub(t) < amt){
                amt = totalSupply().sub(t);
            }
            freeMintFrozenBalances[ref] = freeMintFrozenBalances[ref].add(amt);
            totalFrozen = totalFrozen.add(amt);
            totalFreeMintFrozen = totalFreeMintFrozen.add(amt);
            freeMintFrozen[ref].totalHxyMinted += amt;
            emit FreeMintFreeze(ref, amt, 0);
        }

    }
    
    function UnfreezeFreeMint()
        public
        synchronized
    {

        require(freeMintFrozenBalances[msg.sender] > 0,"Error: unsufficient frozen balance");//ensure user has enough frozen funds
        require(mintBlock, "tokens cannot be unfrozen yet. max supply not yet reached");
        uint amt = freeMintFrozenBalances[msg.sender];
        freeMintFrozenBalances[msg.sender] = 0;
        totalFrozen = totalFrozen.sub(amt);
        totalFreeMintFrozen = totalFreeMintFrozen.sub(amt);
        _transfer(address(this), msg.sender, amt);
        emit FreeMintUnfreeze(msg.sender, amt);
    }
    
    function freeMintHXY(uint value, address minter)
        internal
    {

        uint amt = value;
        _mint(minter, amt);//mint HXY
    }

    function transformHEX(uint hearts, address ref)//Approval needed
        public
        synchronized
    {

        require(roomActive, "transforms not yet active");
        require(hearts >= 100, "value too low");
        require(hexInterface.transferFrom(msg.sender, address(this), hearts), "Transfer failed");//send hex from user to contract
        hexDivs += hearts.div(2);//50%
        hexLiquidity += hearts.div(2);//50%
        
        (uint reserve0, uint reserve1,) = uniPairInterface.getReserves();
        uint hxy = uniV2Router.quote(hearts, reserve0, reserve1);
        if(ref != address(0))//ref
        {
            totalHxyTransformed += hxy.add(hxy.div(10));
            totalHeartsTransformed += hearts;
            FreezeRefFreeMint(hxy.div(10), ref);
        }
        else{//no ref
            totalHxyTransformed += hxy;
            totalHeartsTransformed += hearts;
        }
        require(totalHxyTransformed <= 3000000000000000, "transform threshold breached");//remaining for interest and free mint
        _mint(msg.sender, hxy);
        emit Transform(hearts, hxy, msg.sender);
    }
    
    
    function pushLiquidity()
        public
        synchronized
    {

        require(hexLiquidity > 1000, "nothing to add");
        (uint reserve0, uint reserve1,) = uniPairInterface.getReserves();
        uint hxy = uniV2Router.quote(hexLiquidity, reserve0, reserve1);
        _mint(address(this), hxy);
        this.safeApprove(routerAddress, hxy);
        require(hexInterface.approve(routerAddress, hexLiquidity), "could not approve");
        (uint amountA, uint amountB, uint liquidity) = uniV2Router.addLiquidity(hexAddress, address(this), hexLiquidity, hxy, 0, 0, _p1, now.add(800));
        totalLiquidityAdded += hexLiquidity;
        hexLiquidity = 0;
        emit LiquidityPush(amountA, amountB, liquidity);
    }
    
    
    function pushDivs()
        public
        synchronized
    {

        require(hexDivs > 0, "nothing to distribute");
        totalDividends += hexDivs;
        hexInterface.transfer(airdropContract, hexDivs);
        uint overflow = 0;
        if(hexInterface.balanceOf(address(this)).sub(hexLiquidity) > 0){
            overflow = hexInterface.balanceOf(address(this)).sub(hexLiquidity);
            hexInterface.transfer(airdropContract, overflow);   
        }
        emit DividendPush(hexDivs.add(overflow));
        hexDivs = 0;
    }
    
    
    function setMultiSig(address _multisig)
        public
        onlyAdmins
        onlyOnceMultisig
    {

        multisig = _multisig;    
    }
    
    function setAirdropContract(address payable _airdropContract)
        public
        onlyMultisig
    {

        airdropContract = _airdropContract;    
    }
    
    function addMinter(address minter)
        public
        onlyMultisig
        returns (bool)
    {        

        minters[minter] = true;
        minterAddresses.push(minter);
        return true;
    }

    function transformActivate()
        public
        onlyMultisig
        onlyOnceTransform
    {

        roomActive = true;
    }

    function setExchange(address exchange)
        public
        onlyMultisig
    {

        uniHEXHXY = exchange;
        uniPairInterface = IUniswapV2Pair(uniHEXHXY);
    }
    
    
    function setV2Router(address router)
        public
        onlyMultisig
    {

        routerAddress = router;
        uniV2Router = IUniswapV2Router02(routerAddress);
    }
    

    function totalFrozenTokenBalance()
        public
        view
        returns (uint256)
    {

        return totalFrozen;
    }

    function tokenBalance()
        public
        view
        returns (uint256)
    {

        return balanceOf(msg.sender);
    }

    function isFreezeFinished(address _user)
        public
        view
        returns(bool)
    {

        if(frozen[_user].freezeStartTimestamp == 0){
            return false;
        }
        else{
           return frozen[_user].freezeStartTimestamp.add((minFreezeDayLength).mul(daySeconds)) <= now;               
        }

    }
    
    function donate() public payable {

        require(msg.value > 0);
        bool success = false;
        uint256 balance = msg.value;
        (success, ) =  _p1.call{value:balance.mul(30).div(100)}{gas:21000}('');
        require(success, "Transfer failed");
        (success, ) =  _p2.call{value:balance.mul(30).div(100)}{gas:21000}('');
        require(success, "Transfer failed");
        (success, ) =  _p3.call{value:balance.mul(20).div(100)}{gas:21000}('');
        require(success, "Transfer failed");
        (success, ) =  _p4.call{value:balance.mul(15).div(100)}{gas:21000}('');
        require(success, "Transfer failed");
        (success, ) =  _p5.call{value:balance.mul(5).div(100)}{gas:21000}('');
        require(success, "Transfer failed");
    }

}
