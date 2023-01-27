


pragma solidity ^0.8.0;

interface IMasterChef {

    function deposit(uint256 _pid, uint256 _amount) external;

    function withdraw(uint256 _pid, uint256 _amount) external;

    function enterStaking(uint256 _amount) external;

    function leaveStaking(uint256 _amount) external;

    function userInfo(uint256 _pid, address _user) external view returns (uint256, uint256);

    function emergencyWithdraw(uint256 _pid) external;



}




pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}




pragma solidity ^0.8.0;

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




pragma solidity ^0.8.0;
contract Ownable is Context {

    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
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





pragma solidity ^0.8.0;

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




pragma solidity ^0.8.0;
contract ERC20 is Context, IERC20 {

    using Address for address;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor (string memory nameFoo, string memory symbolFoo) {
        _name = nameFoo;
        _symbol = symbolFoo;
        _decimals = 18;
    }

    function name() public view returns (string memory) {

        return _name;
    }

    function symbol() public view returns (string memory) {

        return _symbol;
    }

    function decimals() public view returns (uint8) {

        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {

        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {

        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {

        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {

        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {

        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()] - amount);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] - subtractedValue);
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal virtual {

        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        _balances[sender] = _balances[sender] - amount;
        _balances[recipient] = _balances[recipient] + amount;
        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply = _totalSupply + amount;
        _balances[account] = _balances[account] + amount;
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        _balances[account] = _balances[account] - amount;
        _totalSupply = _totalSupply - amount;
        emit Transfer(account, address(0), amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal virtual {

        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _setupDecimals(uint8 decimals_) internal {

        _decimals = decimals_;
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }

}




pragma solidity ^0.8.0;
library SafeERC20 {
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
        uint256 newAllowance = token.allowance(address(this), spender) +  value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender) - value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}




pragma solidity ^0.8.0;
contract Pausable is Context {
    event Paused(address account);

    event Unpaused(address account);

    bool private _paused;

    constructor () {
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



pragma solidity ^0.8.0;

library FullMath {
    function mulDiv(
        uint256 a,
        uint256 b,
        uint256 denominator
    ) internal pure returns (uint256 result) {
        uint256 prod0; // Least significant 256 bits of the product
        uint256 prod1; // Most significant 256 bits of the product
        assembly {
            let mm := mulmod(a, b, not(0))
            prod0 := mul(a, b)
            prod1 := sub(sub(mm, prod0), lt(mm, prod0))
        }

        if (prod1 == 0) {
            require(denominator > 0);
            assembly {
                result := div(prod0, denominator)
            }
            return result;
        }

        require(denominator > prod1);


        uint256 remainder;
        assembly {
            remainder := mulmod(a, b, denominator)
        }
        assembly {
            prod1 := sub(prod1, gt(remainder, prod0))
            prod0 := sub(prod0, remainder)
        }

        uint256 twos = (type(uint256).max - denominator + 1) & denominator;
        assembly {
            denominator := div(denominator, twos)
        }

        assembly {
            prod0 := div(prod0, twos)
        }
        assembly {
            twos := add(div(sub(0, twos), twos), 1)
        }
        prod0 |= prod1 * twos;

        uint256 inv = (3 * denominator) ^ 2;
        inv *= 2 - denominator * inv; // inverse mod 2**8
        inv *= 2 - denominator * inv; // inverse mod 2**16
        inv *= 2 - denominator * inv; // inverse mod 2**32
        inv *= 2 - denominator * inv; // inverse mod 2**64
        inv *= 2 - denominator * inv; // inverse mod 2**128
        inv *= 2 - denominator * inv; // inverse mod 2**256

        result = prod0 * inv;
        return result;
    }

    function mulDivRoundingUp(
        uint256 a,
        uint256 b,
        uint256 denominator
    ) internal pure returns (uint256 result) {
        result = mulDiv(a, b, denominator);
        if (mulmod(a, b, denominator) > 0) {
            require(result < type(uint256).max);
            result++;
        }
    }
}




pragma solidity ^0.8.0;

interface IUniswapRouterETH {
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

    function swapExactTokensForTokens(
        uint amountIn, 
        uint amountOutMin, 
        address[] calldata path, 
        address to, 
        uint deadline
    ) external returns (uint[] memory amounts);

    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
}



pragma solidity ^0.8.0;

interface IUniswapV2Pair is IERC20 {
    function token0() external view returns (address);
    function token1() external view returns (address);
}



pragma solidity ^0.8.0;
contract StratManager is Ownable, Pausable {
    address public keeper;
    address public strategist;
    address public unirouter;
    address public vault;
    constructor(
        address _keeper,
        address _strategist,
        address _unirouter,
        address _vault
    ) {
        keeper = _keeper;
        strategist = _strategist;
        unirouter = _unirouter;
        vault = _vault;
    }

    modifier onlyManager() {
        require(msg.sender == owner() || msg.sender == keeper, "!manager");
        _;
    }

    modifier onlyEOA() {
        require(msg.sender == tx.origin, "!EOA");
        _;
    }

    function setKeeper(address _keeper) external onlyManager {
        keeper = _keeper;
    }

    function setStrategist(address _strategist) external {
        require(msg.sender == strategist, "!strategist");
        strategist = _strategist;
    }

    function setUnirouter(address _unirouter) external onlyOwner {
        unirouter = _unirouter;
    }

    function setVault(address _vault) external onlyOwner {
        vault = _vault;
    }

    function beforeDeposit() external virtual {}
}



pragma solidity ^0.8.0;
abstract contract FeeManager is StratManager {
    uint constant public MAXFEE = 1000;
    uint public withdrawalFee = 0; // fee taken out on withdraw
    uint public strategistFee = 69; // 6.9% stratigest fee
    uint public sideProfitFee = 0; // amount of rewardToken swapped to stable
    uint public callFee = 42; // 4.2% fee paid to caller

    function setWithdrawalFee(uint256 _fee) external onlyManager {
        require(_fee <= MAXFEE, "fee too high");
        withdrawalFee = _fee;
    }

    function setStratFee(uint256 _fee) external onlyManager {
        require(_fee < MAXFEE, "fee too high");
        strategistFee = _fee;
    }

    function setProfitFees(uint256 _fee) external onlyManager {
      require(_fee < MAXFEE, "fee too high");
      sideProfitFee = _fee;
    }

    function setCallFee(uint256 _fee) external onlyManager {
        require(_fee < MAXFEE, "fee too high");
        callFee = _fee;
    }
}



pragma solidity ^0.8.0;

abstract contract StrategyLPBase is StratManager, FeeManager {
    using SafeERC20 for IERC20;
    using SafeERC20 for IUniswapV2Pair;

    IERC20 public swapToken;
    IERC20 public rewardToken;
    IUniswapV2Pair public stakedToken;
    IERC20 public lpAsset0;
    IERC20 public lpAsset1;
    IERC20 public sideProfitToken;

    address[] public rewardTokenToLp0Route;
    address[] public rewardTokenToLp1Route;
    address[] public rewardTokenToProfitRoute;

    uint256 MAX_INT = type(uint256).max;
    uint256 public lastHarvest;

    event StratHarvest(address indexed harvester);

    function farmAddress() public virtual returns (address) {}
    function setFarmAddress(address newAddr) internal virtual {}
    function farmDeposit(uint256 amount) internal virtual {}
    function farmWithdraw(uint256 amount) internal virtual {}
    function farmEmergencyWithdraw() internal virtual {}
    function beforeHarvest() internal virtual {}
    function balanceOfPool() public view virtual returns (uint256) {}
    function giveAllowances() internal virtual {}
    function removeAllowances() internal virtual {}
    function resetValues(address _swapToken, address _rewardToken, address _farmAddr, address _lpToken, uint256 _poolId, address _sideProfitToken) public virtual {}

    constructor(
        address _swapToken, // Should be what rewardToken gets routed through when swapping for profit and LP halves.
        address _rewardToken, // rewardToken Token
        address _lpToken, // LP Token
        address _vault, // Crack Vault that uses this strategy
        address _unirouter, // Unirouter on this chain to call for swaps
        address _keeper, // address to use as alternative owner
        address _strategist, // address where strategist fees go
        address _sideProfitToken // address of sideProfitToken token
    ) StratManager(_keeper, _strategist, _unirouter, _vault) {
        swapToken = IERC20(_swapToken);
        rewardToken = IERC20(_rewardToken);
        stakedToken = IUniswapV2Pair(_lpToken);
        lpAsset0 = IERC20(stakedToken.token0());
        lpAsset1 = IERC20(stakedToken.token1());
        sideProfitToken = IERC20(_sideProfitToken);

        if (swapToken == sideProfitToken) {
            rewardTokenToProfitRoute = [address(rewardToken), address(sideProfitToken)];
        } else {
            rewardTokenToProfitRoute = [address(rewardToken), address(swapToken), address(sideProfitToken)];
        }

        if (lpAsset0 == swapToken) {
            rewardTokenToLp0Route = [address(rewardToken), address(swapToken)];
        } else if (lpAsset0 != rewardToken) {
            rewardTokenToLp0Route = [address(rewardToken), address(swapToken), address(lpAsset0)];
        }

        if (lpAsset1 == swapToken) {
            rewardTokenToLp1Route = [address(rewardToken), address(swapToken)];
        } else if (lpAsset1 != rewardToken) {
            rewardTokenToLp1Route = [address(rewardToken), address(swapToken), address(lpAsset1)];
        }
    }

    function deposit() public whenNotPaused {
        uint256 lpTokenBal = stakedToken.balanceOf(address(this));
        if (lpTokenBal > 0) {
            farmDeposit(lpTokenBal);
        }
    }

    function beforeDeposit() external override whenNotPaused {
    }

    function withdraw(uint256 _amount) external {
        require(msg.sender == vault, "!vault");

        uint256 lpTokenBal = stakedToken.balanceOf(address(this));

        if (lpTokenBal < _amount) {
            farmWithdraw(_amount - lpTokenBal);
            lpTokenBal = stakedToken.balanceOf(address(this));
        }

        if (lpTokenBal > _amount) {
            lpTokenBal = _amount;
        }

        if (tx.origin == owner() || paused()) {
            stakedToken.safeTransfer(vault, lpTokenBal);
        } else {
            uint256 withdrawalFeeAmount = ((lpTokenBal * withdrawalFee) / MAXFEE);
            stakedToken.safeTransfer(vault, lpTokenBal - withdrawalFeeAmount);
        }
    }

    function harvest() external whenNotPaused onlyEOA {
        _harvestInternal();
    }

    function _harvestInternal() internal whenNotPaused {
        beforeHarvest();

        chargeFees();
        addLiquidity();
        deposit();

        lastHarvest = block.timestamp;
        emit StratHarvest(msg.sender);
    }

    function chargeFees() internal {
        uint256 totalFee = (strategistFee + sideProfitFee + callFee);
        require (totalFee < 1000, "fees too high");
        uint256 toProfit = FullMath.mulDiv(rewardToken.balanceOf(address(this)), totalFee, MAXFEE);
        if (toProfit > 0)
        {
            IUniswapRouterETH(unirouter).swapExactTokensForTokens(toProfit, 0, rewardTokenToProfitRoute, address(this), block.timestamp);
            uint256 sideProfitBalance = sideProfitToken.balanceOf(address(this));
            sideProfitToken.safeTransfer(msg.sender, FullMath.mulDiv(sideProfitBalance, callFee, totalFee));
            sideProfitToken.safeTransfer(strategist, FullMath.mulDiv(sideProfitBalance, strategistFee, totalFee));
            sideProfitToken.safeTransfer(vault, FullMath.mulDiv(sideProfitBalance, sideProfitFee, totalFee));
        }
    }

    function addLiquidity() internal {
        uint256 rewardTokenHalf = rewardToken.balanceOf(address(this)) / 2;
        if (rewardTokenHalf > 0)
        {
            if (lpAsset0 != rewardToken) {
                IUniswapRouterETH(unirouter).swapExactTokensForTokens(rewardTokenHalf, 0, rewardTokenToLp0Route, address(this), block.timestamp);
            }

            if (lpAsset1 != rewardToken) {
                IUniswapRouterETH(unirouter).swapExactTokensForTokens(rewardTokenHalf, 0, rewardTokenToLp1Route, address(this), block.timestamp);
            }
        }
        uint256 lp0Bal = lpAsset0.balanceOf(address(this));
        uint256 lp1Bal = lpAsset1.balanceOf(address(this));
        if ((lp0Bal > 0) && (lp1Bal > 0))
        {
            IUniswapRouterETH(unirouter).addLiquidity(address(lpAsset0), address(lpAsset1), lp0Bal, lp1Bal, 1, 1, address(this), block.timestamp);
        }
    }

    function totalBalanceOfStaked() public view returns (uint256) {
        return balanceOfWant() + balanceOfPool();
    }

    function balanceOfWant() public view returns (uint256) {
        return stakedToken.balanceOf(address(this));
    }

    function retireStrat() external {
        require(msg.sender == vault, "!vault");

        farmEmergencyWithdraw();

        uint256 lpTokenBal = stakedToken.balanceOf(address(this));
        stakedToken.transfer(vault, lpTokenBal);
    }

    function inCaseTokensGetStuck(address _token) external onlyManager {
        uint256 amount = IERC20(_token).balanceOf(address(this));
        IERC20(_token).safeTransfer(msg.sender, amount);
    }

    function panic() public onlyManager {
        pause();
        farmEmergencyWithdraw();
    }

    function pause() public onlyManager {
        _pause();
        removeAllowances();
    }

    function unpause() external onlyManager {
        _unpause();
        giveAllowances();
        deposit();
    }
}



pragma solidity ^0.8.0;

contract StrategyLPMasterChef is StrategyLPBase {
    using SafeERC20 for IERC20;

    uint256 public poolId;
    IMasterChef farm;

    constructor(
        uint256 _poolId,
        address _farm,
        address _swapToken, // intermediary swap Token
        address _rewardToken, // rewardToken Token
        address _lpToken, // LP Token
        address _vault, // Crack Vault that uses this strategy
        address _unirouter, // Unirouter on this chain to call for swaps
        address _keeper, // address to use as alternative owner.
        address _strategist, // address where strategist fees go.
        address _sideProfit // address of sideProfit token
    ) StrategyLPBase(
        _swapToken,
        _rewardToken,
        _lpToken,
        _vault,
        _unirouter,
        _keeper,
        _strategist,
        _sideProfit
    ) {
        poolId = _poolId;
        farm = IMasterChef(_farm);
        giveAllowances();
    }

    function farmAddress() public view override(StrategyLPBase) returns (address) {
        return address(farm);
    }
    function setFarmAddress(address newAddr) internal override(StrategyLPBase) {
        farm = IMasterChef(newAddr);
    }

    function farmWithdraw(uint256 _amount) internal override(StrategyLPBase) {
        farm.withdraw(poolId, _amount);
    }

    function balanceOfPool() public view override(StrategyLPBase) returns (uint256) {
        (uint256 _amount, ) = farm.userInfo(poolId, address(this));
        return _amount;
    }

    function beforeHarvest() internal override(StrategyLPBase) {
        farm.deposit(poolId, 0);
    }

    function farmEmergencyWithdraw() internal override(StrategyLPBase) {
        farm.emergencyWithdraw(poolId);
    }

    function farmDeposit(uint256 amount) internal whenNotPaused override(StrategyLPBase) {
        farm.deposit(poolId, amount);
    }

    function giveAllowances() internal override(StrategyLPBase) {
        IERC20(stakedToken).safeApprove(farmAddress(), MAX_INT);
        rewardToken.safeApprove(address(unirouter), MAX_INT);
        sideProfitToken.safeApprove(address(unirouter), MAX_INT);

        lpAsset0.safeApprove(address(unirouter), 0);
        lpAsset0.safeApprove(address(unirouter), MAX_INT);

        lpAsset1.safeApprove(address(unirouter), 0);
        lpAsset1.safeApprove(address(unirouter), MAX_INT);
    }

    function removeAllowances() internal override(StrategyLPBase) {
        IERC20(stakedToken).safeApprove(farmAddress(), 0);
        rewardToken.safeApprove(address(unirouter), 0);
        sideProfitToken.safeApprove(address(unirouter), 0);
        lpAsset0.safeApprove(address(unirouter), 0);
        lpAsset1.safeApprove(address(unirouter), 0);
    }

    function resetValues(address _swapToken, address _rewardToken, address _farmAddr, address _lpToken, uint256 _poolId, address _sideProfitToken) public onlyOwner override(StrategyLPBase) {
        removeAllowances();
        swapToken = IERC20(_swapToken);
        rewardToken = IERC20(_rewardToken);
        setFarmAddress(_farmAddr);
        stakedToken = IUniswapV2Pair(_lpToken);
        lpAsset0 = IERC20(stakedToken.token0());
        lpAsset1 = IERC20(stakedToken.token1());
        sideProfitToken = IERC20(_sideProfitToken);
        poolId = _poolId;

        if (swapToken == sideProfitToken) {
            rewardTokenToProfitRoute = [address(rewardToken), address(sideProfitToken)];
        } else {
            rewardTokenToProfitRoute = [address(rewardToken), address(swapToken), address(sideProfitToken)];
        }

        if (lpAsset0 == swapToken) {
            rewardTokenToLp0Route = [address(rewardToken), address(swapToken)];
        } else if (lpAsset0 != rewardToken) {
            rewardTokenToLp0Route = [address(rewardToken), address(swapToken), address(lpAsset0)];
        }

        if (lpAsset1 == swapToken) {
            rewardTokenToLp1Route = [address(rewardToken), address(swapToken)];
        } else if (lpAsset1 != rewardToken) {
            rewardTokenToLp1Route = [address(rewardToken), address(swapToken), address(lpAsset1)];
        }
        giveAllowances();
    }
}