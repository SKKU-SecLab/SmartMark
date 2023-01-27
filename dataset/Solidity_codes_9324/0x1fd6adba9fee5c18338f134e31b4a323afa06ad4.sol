

pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;




library Babylonian {

    function sqrt(int256 y) internal pure returns (int256 z) {

        if (y > 3) {
            z = y;
            int256 x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
    }
}


interface IPickleJar {

    function balanceOf(address account) external view returns (uint256);

    function depositAll() external;

    function deposit(uint256 _amount) external;

}


interface IUniswapV2Pair {

    function getReserves() external view returns (
        uint112 _reserve0, 
        uint112 _reserve1, 
        uint32 _blockTimestampLast
    );

}


interface IUniswapV2Router02 {


    modifier ensure(uint deadline) {

        require(deadline >= block.timestamp, 'UniswapV2Router: EXPIRED');
        _;
    }

    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);


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


    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);


    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);


    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);


}


interface IveCurveVault {

    function depositAll() external;

    function deposit(uint256 _amount) external;

    function approve(address spender, uint256 amount) external returns (bool);

    function transfer(address dst, uint256 amount) external returns (bool);

    function balanceOf(address account) external view returns (uint256);

}


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


abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}


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


library SignedSafeMath {

    int256 constant private _INT256_MIN = -2**255;

    function mul(int256 a, int256 b) internal pure returns (int256) {

        if (a == 0) {
            return 0;
        }

        require(!(a == -1 && b == _INT256_MIN), "SignedSafeMath: multiplication overflow");

        int256 c = a * b;
        require(c / a == b, "SignedSafeMath: multiplication overflow");

        return c;
    }

    function div(int256 a, int256 b) internal pure returns (int256) {

        require(b != 0, "SignedSafeMath: division by zero");
        require(!(b == -1 && a == _INT256_MIN), "SignedSafeMath: division overflow");

        int256 c = a / b;

        return c;
    }

    function sub(int256 a, int256 b) internal pure returns (int256) {

        int256 c = a - b;
        require((b >= 0 && c <= a) || (b < 0 && c > a), "SignedSafeMath: subtraction overflow");

        return c;
    }

    function add(int256 a, int256 b) internal pure returns (int256) {

        int256 c = a + b;
        require((b >= 0 && c >= a) || (b < 0 && c < a), "SignedSafeMath: addition overflow");

        return c;
    }
}


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


contract ZapYveCrvEthLPsToPickle is Ownable {

    using SafeERC20 for IERC20;
    using Address for address;
    using SafeMath for uint256;
    using SignedSafeMath for int256;

    address public constant ethYveCrv = 0x10B47177E92Ef9D5C6059055d92DdF6290848991; // LP Token
    address public constant yveCrv = 0xc5bDdf9843308380375a611c18B50Fb9341f502A;
    address public constant crv = 0xD533a949740bb3306d119CC777fa900bA034cd52;
    address public constant weth = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    IPickleJar public pickleJar = IPickleJar(0x5Eff6d166D66BacBC1BF52E2C54dD391AE6b1f48);
    IveCurveVault public yVault = IveCurveVault(yveCrv);

    address public activeDex = 0xd9e1cE17f2641f24aE83637ab66a2cca9C378B9F; // Sushi default
    address public sushiswapRouter = 0xd9e1cE17f2641f24aE83637ab66a2cca9C378B9F;
    address public uniswapRouter = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
    IUniswapV2Router02 public swapRouter;
    
    address public swapPair = 0x58Dc5a51fE44589BEb22E8CE67720B5BC5378009; // Initialize with Sushiswap
    address public sushiswapPair = 0x58Dc5a51fE44589BEb22E8CE67720B5BC5378009;
    address public uniswapPair = 0x3dA1313aE46132A397D90d95B1424A9A7e3e0fCE;
    
    address[] public swapEthPath;
    address[] public swapCrvPath;
    address[] public swapForYveCrvPath;

    address payable public governance = 0xFEB4acf3df3cDEA7399794D0869ef76A6EfAff52;

    modifier onlyGovernance() {

        require(msg.sender == governance, "!authorized");
        _;
    }

    constructor() public Ownable() {
        swapRouter = IUniswapV2Router02(activeDex);

        IERC20(crv).safeApprove(activeDex, uint256(-1)); // For curve swaps on dex
        IERC20(weth).safeApprove(activeDex, uint256(-1)); // For staking into pickle jar
        IERC20(crv).safeApprove(yveCrv, uint256(-1));// approve vault to take curve
        IERC20(yveCrv).safeApprove(sushiswapRouter, uint256(-1));
        IERC20(ethYveCrv).safeApprove(address(pickleJar), uint256(-1)); // For staking into pickle jar

        swapEthPath = new address[](2);
        swapEthPath[0] = weth;
        swapEthPath[1] = crv;

        swapCrvPath = new address[](2);
        swapCrvPath[0] = crv;
        swapCrvPath[1] = weth;

        swapForYveCrvPath = new address[](2);
        swapForYveCrvPath[0] = weth;
        swapForYveCrvPath[1] = yveCrv;
    }

    function setGovernance(address payable _governance) external onlyGovernance {

        governance = _governance;
    }

    function zapInETH() external payable {

        _zapIn(true, msg.value);
    }

    function zapInCRV(uint256 crvAmount) external {

        require(crvAmount != 0, "0 CRV");
        IERC20(crv).transferFrom(msg.sender, address(this), crvAmount);
        _zapIn(false, IERC20(crv).balanceOf(address(this))); // Include any dust from prev txns
    }

    function _zapIn(bool _isEth, uint256 _haveAmount) internal returns (uint256) {

        IUniswapV2Pair lpPair = IUniswapV2Pair(ethYveCrv); // Pair we LP against
        (uint112 lpReserveA, uint112 lpReserveB, ) = lpPair.getReserves();

        bool useVault = shouldUseVault(lpReserveA, lpReserveB);

        if(useVault){
            uint256 amountToSwap = calculateSwapAmount(_isEth, _haveAmount);
            _tokenSwap(_isEth, amountToSwap);
            yVault.depositAll();
        }
        else{
            if(_isEth){
                int256 amountToSell = calculateSingleSided(lpReserveA, address(this).balance);
                swapRouter.swapExactETHForTokens{value: uint256(amountToSell)}(1, swapForYveCrvPath, address(this), now);
            }
            else{
                uint amountWeth = IUniswapV2Router02(sushiswapRouter).swapExactTokensForTokens(_haveAmount, 0, swapCrvPath, address(this), now)[swapCrvPath.length - 1];
                int256 amountToSell = calculateSingleSided(lpReserveA, amountWeth);
                swapRouter.swapExactTokensForTokens(uint256(amountToSell), 1, swapForYveCrvPath, address(this), now);
            }           
        }
        
        if(_isEth){
            IUniswapV2Router02(sushiswapRouter).addLiquidityETH{value: address(this).balance}( 
                yveCrv, yVault.balanceOf(address(this)), 1, 1, address(this), now
            );
        }
        else{
            IUniswapV2Router02(sushiswapRouter).addLiquidity(
                yveCrv, weth, yVault.balanceOf(address(this)), IERC20(weth).balanceOf(address(this)), 0, 0, address(this), now
            );
        }
       
        pickleJar.depositAll();
        IERC20(address(pickleJar)).safeTransfer(msg.sender, pickleJar.balanceOf(address(this)));

    }

    function _tokenSwap(bool _isEth, uint256 _amountIn) internal returns (uint256) {

        uint256 amountOut = 0;
        if (_isEth) {
            amountOut = swapRouter.swapExactETHForTokens{value: _amountIn}(1, swapEthPath, address(this), now)[swapEthPath.length - 1];
        } else {
            amountOut = swapRouter.swapExactTokensForTokens(_amountIn, 0, swapCrvPath, address(this), now)[swapCrvPath.length - 1];
        }
        require(amountOut > 0, "Error Swapping Tokens");
        return amountOut;
    }

    function setActiveDex(uint256 exchange) public onlyGovernance {

        if(exchange == 0){
            activeDex = sushiswapRouter;
            swapPair = sushiswapPair;
        }else if (exchange == 1) {
            activeDex = uniswapRouter;
            swapPair = uniswapPair;
        }else{
            require(false, "incorrect pool");
        }
        swapRouter = IUniswapV2Router02(activeDex);
        IERC20(crv).safeApprove(activeDex, uint256(-1));
        IERC20(weth).safeApprove(activeDex, uint256(-1));
    }

    function sweep(address _token) external onlyGovernance {

        IERC20(_token).safeTransfer(governance, IERC20(_token).balanceOf(address(this)));
        uint256 balance = address(this).balance;
        if(balance > 0){
            governance.transfer(balance);
        }
    }

    function shouldUseVault(uint256 lpReserveA, uint256 lpReserveB) internal view returns (bool) {

        uint256 safetyFactor = 1e5; // For extra precision
        IUniswapV2Pair pair = IUniswapV2Pair(swapPair); // Pair we might want to swap against
        (uint256 reserveA, uint256 reserveB, ) = pair.getReserves();
        uint256 pool1ratio = reserveB.mul(safetyFactor).div(reserveA);
        uint256 pool2ratio = lpReserveB.mul(safetyFactor).div(lpReserveA);
        return pool1ratio > pool2ratio; // Use vault only if pool 2 offers a better price
    }

    function calculateSingleSided(uint256 reserveIn, uint256 userIn) internal pure returns (int256) {

        return
            Babylonian.sqrt(
                int256(reserveIn).mul(int256(userIn).mul(3988000) + int256(reserveIn).mul(3988009))
            ).sub(int256(reserveIn).mul(1997)) / 1994;
    }

    function calculateSwapAmount(bool _isEth, uint256 _haveAmount) internal view returns (uint256) {

        IUniswapV2Pair pair = IUniswapV2Pair(swapPair); // Pair we swap against
        (uint256 reserveA, uint256 reserveB, ) = pair.getReserves();
        int256 pool1HaveReserve = 0;
        int256 pool1WantReserve = 0;
        int256 rb = 0;
        int256 ra = 0;
        
        if(_isEth){
            pool1HaveReserve = int256(reserveA);
            pool1WantReserve = int256(reserveB);
        }
        else{
            pool1HaveReserve = int256(reserveB);
            pool1WantReserve = int256(reserveA);
        }
        
        pair = IUniswapV2Pair(ethYveCrv); // Pair we swap against
        (reserveA, reserveB, ) = pair.getReserves();
        if(_isEth){
            ra = int256(reserveB);
            rb = int256(reserveA);
        }
        else{
            ra = int256(reserveA);
            rb = int256(reserveB);
        }
        
        int256 numToSquare = int256(_haveAmount).mul(997); // This line and the next one add together a part of the formula...
        numToSquare = numToSquare.add(pool1HaveReserve.mul(1000)); // ...which we'll need to square later on.
        int256 FACTOR = 1e20; // To help with precision

        int256 h = int256(_haveAmount); // re-assert this or else stack will get too deep and forget it
        int256 a = pool1WantReserve.mul(-1994).mul(ra).div(rb);
        int256 b = h.mul(997);
        b = b.sub(pool1HaveReserve.mul(1000));
        b = a.mul(b);

        a = ra.mul(ra).mul(FACTOR).div(rb);
        a = a.div(rb); // We lose some precision here
        int256 c = numToSquare.mul(numToSquare);
        a = c.mul(a).div(FACTOR);
        a = b.add(a); // Add result to total
        
        int256 r = pool1WantReserve.mul(pool1WantReserve);
        r = r.mul(994009);
        a = a.add(r); // Add result to total
        
        int256 sq = Babylonian.sqrt(a);
        
        b = h.mul(997).mul(ra).mul(FACTOR).div(rb);
        
        FACTOR = 1e20; // re-state, otherwise stack depth is exceeded
        r = pool1HaveReserve.mul(1000);
        r = r.mul(ra).mul(FACTOR);
        r = r.div(rb);
        h = pool1WantReserve.mul(-997);
        h = h.mul(FACTOR).sub(r);
        b = b.add(h).div(FACTOR);
        b = b.add(sq);
        
        a = ra.mul(1994);
        a = a.mul(FACTOR).div(rb); // We lose some precision here
        return uint256(b.mul(FACTOR).div(a));
    }

    receive() external payable {
        _zapIn(true, msg.value);
    }
}