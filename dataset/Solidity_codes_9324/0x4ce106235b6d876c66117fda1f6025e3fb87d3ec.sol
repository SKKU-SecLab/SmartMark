



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


pragma solidity 0.6.12;

interface ISashimiVault {

    function token() view external returns (address) ;

    function profit() view external returns (address);

    function lend() view external returns (address);

    function controller() view external returns (address);

    function deposit(uint256) external;

    function depositAll() external;

    function withdraw(uint256) external;

    function withdrawAll() external returns (uint256 amount);

    function harvest() external returns (uint256); // returns profit amount

    function earned() view external returns(uint256);

    function transfer(address tokenAddress, address receipt, uint256 amount) external;

    function transferETH(address receipt, uint256 amount) external;

    function executeTransaction(address target, uint value, string memory signature, bytes memory data) payable external;

}




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


pragma solidity 0.6.12;






abstract contract SashimiVault is ISashimiVault, Ownable {
    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    modifier onlyController{
        require(msg.sender == controller, "Not controller.");
        _;
    }

    address override public controller;
    address override public token;
    address override public profit;
    address override public lend;

    event TokenTransferred(address, address, uint256);
    event ETHTransferred(address, uint256);
    event Executed(address, uint, string, bytes);

    function transfer(address _token, address _receipt, uint256 _amount) override onlyController public {
        IERC20(token).transfer(_receipt, _amount);
        emit TokenTransferred(address(_token), _receipt, _amount);
    }

    function transferETH(address _receipt, uint256 _amount) override onlyController public {
        payable(_receipt).transfer(_amount);
        emit ETHTransferred(_receipt, _amount);
    }

    function executeTransaction(address target, uint value, string memory signature, bytes memory data) override public payable onlyController{
        bytes memory callData;
        if (bytes(signature).length == 0) {
            callData = data;
        } else {
            callData = abi.encodePacked(bytes4(keccak256(bytes(signature))), data);
        }

        (bool success, ) = target.call{value:value}(callData);
        require(success, "Execution failed.");

        emit Executed(target, value, signature, data);
    }

    function emergenceChangeLend(address _lend) public onlyController{
        lend = _lend;
    }
}




pragma solidity ^0.6.0;





contract ERC20 is Context, IERC20 {

    using SafeMath for uint256;
    using Address for address;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor (string memory name, string memory symbol) public {
        _name = name;
        _symbol = symbol;
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
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal virtual {

        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
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


pragma solidity 0.6.12;

interface ISashimiInvestment {
    function withdraw(address token, uint256 amount) external;
    function withdrawWithReBalance(address token, uint256 amount) external;
}


pragma solidity >=0.6.2;

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


pragma solidity >=0.6.2;


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
    function take(
        address token,
        uint amount
    ) external;
    function getTokenInPair(address pair, address token) external view returns (uint balance);
}


pragma solidity 0.6.12;











contract SashimiInvestment is ISashimiInvestment, Ownable {
    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    event AdminAdded(address admin);
    event AdminRemoved(address admin);
    event ProviderAdded(address indexed token, address provider, uint256 providerId);
    event ProviderSwitched(address indexed token, address provider, uint256 providerId);
    event ReservesRatiosChanged(address indexed token, uint256 reservesRatio);
    event ProviderDisabled(uint256 providerId);
    event ProviderEnabled(uint256 providerId);
    event ReBalancedReserves(address);
    event Harvested(address, address, uint256, uint256);

    address public router; // swap router
    address public routerForSashimi; // router for sashimi
    address public sashimi; // sashimi token
    address public wETH; // weth address
    mapping(address => bool) public isAdmin; // multi admins can chose providers

    address public beneficiary1; // 75% sashimi goes to
    address public beneficiary2; // 25% sashimi goes to

    bool public frozen;

    struct Provider {
        address vault;
        address token;
        bool enable;
        uint256 accProfit;
    }

    mapping(address => uint256) public deposits; // token => deposit amount
    mapping(address => uint256) public reservesRatios; // token => ratio
    mapping(address => uint256) public chosenProviders; // token => providerId

    uint256 public constant MAXIMAL_RATIO = 10000;
    uint256 public constant MINIMAL_RATIO = 1;
    uint256 public constant TOTAL_RATIO_SHARES = 10000;

    Provider[] public providers;

    modifier onlyRouter(){
        require(
            msg.sender == router,
            "Not router."
        );
        _;
    }

    modifier onlyAdmin(){
        require(
            isAdmin[msg.sender],
            "Not admin."
        );
        _;
    }

    modifier validRatio(uint256 _reservesRatio){
        require(_reservesRatio >= MINIMAL_RATIO, "Invalid ratio.");
        require(_reservesRatio <= MAXIMAL_RATIO, "Invalid ratio.");
        _;
    }

    modifier notFrozen() {
        require(
            !frozen, "FROZEN."
        );
        _;
    }

    constructor (address _router, address _routerForSashimi, address _sashimi, address _wETH, address _beneficiary1) public {
        router = _router;
        routerForSashimi = _routerForSashimi;
        sashimi = _sashimi;
        wETH = _wETH;
        require(sashimi != wETH, "Invalid token input.");
        frozen = true;
        beneficiary1 = _beneficiary1;
        beneficiary2 = address(0xdead);

        isAdmin[msg.sender] = true;

        providers.push(Provider({
        vault : address(0),
        token : address(0),
        enable : false,
        accProfit: 0
        }));
    }

    function reBalance(address _token) notFrozen public {
        uint256 providerId = chosenProviders[_token];
        require(providerId > 0, "Provider not chosen.");
        Provider memory provider = providers[providerId];

        uint256 reservesRatio = reservesRatios[_token];
        require(reservesRatio > 0, "ReservesRatios not exists.");

        uint256 beforeReserves = IERC20(_token).balanceOf(router);
        uint256 beforeDepositAmount = deposits[_token];
        uint256 afterReserves = (beforeReserves.add(beforeDepositAmount)).div(TOTAL_RATIO_SHARES).mul(reservesRatio);

        if (beforeReserves < afterReserves)
        {
            uint256 amount = afterReserves.sub(beforeReserves);

            ISashimiVault(provider.vault).withdraw(amount);

            IERC20(_token).safeTransfer(router, amount);
            deposits[_token] = beforeDepositAmount.sub(amount);
        }
        else if (beforeReserves > afterReserves)
        {
            uint256 amount = beforeReserves.sub(afterReserves);
            IUniswapV2Router02(router).take(_token, amount);

            ISashimiVault(provider.vault).deposit(amount);
            deposits[_token] = beforeDepositAmount.add(amount);
        }

        emit ReBalancedReserves(_token);
    }

    function harvest(address _token) notFrozen public returns (uint256 amount){
        uint256 chosen = chosenProviders[_token];
        require(chosen > 0, "Provider not chosen.");
        Provider storage provider = providers[chosen];
        amount = 0;
        uint256 profitAmount = ISashimiVault(provider.vault).harvest();
        if (profitAmount > 0)
        {
            address profit = ISashimiVault(provider.vault).profit();
            provider.accProfit += profitAmount;

            address[] memory path;
            if (profit == wETH)
            {
                path = new address[](2);
                path[0] = wETH;
                path[1] = sashimi;
            }
            else {
                path = new address[](3);
                path[0] = profit;
                path[1] = wETH;
                path[2] = sashimi;
            }

            if (IERC20(profit).allowance(address(this), routerForSashimi) == 0)
                IERC20(profit).safeApprove(routerForSashimi, type(uint256).max);

            uint[] memory amounts = IUniswapV2Router01(routerForSashimi).swapExactTokensForTokens(profitAmount, 0, path, address(this), block.timestamp + 3);
            amount = amounts[path.length - 1];

            if (beneficiary1 != address(0))
                IERC20(sashimi).safeTransfer(beneficiary1, amount.mul(75).div(100));
            if (beneficiary2 != address(0))
                IERC20(sashimi).safeTransfer(beneficiary2, amount.mul(25).div(100));
            emit Harvested(_token, profit, profitAmount, amount);
        }
    }

    function withdraw(address _token, uint256 _amount) override onlyRouter notFrozen public {
        uint256 depositAmount = deposits[_token];
        require(depositAmount > _amount, "Deposit not enough.");
        uint256 providerId = chosenProviders[_token];
        require(providerId > 0, "Provider not chosen.");

        Provider storage provider = providers[providerId];
        ISashimiVault(provider.vault).withdraw(_amount);
        IERC20(_token).safeTransfer(router, _amount);
        deposits[_token] = depositAmount.sub(_amount);
    }

    function withdrawWithReBalance(address _token, uint256 _amount) override onlyRouter notFrozen public{
        reBalance(_token);
        uint256 depositAmount = deposits[_token];
        uint256 withdrawAmount = depositAmount > _amount ? _amount : depositAmount;
        withdraw(_token, withdrawAmount);
    }

    function disableProvider(uint256 _providerId) onlyOwner public {
        require(_providerId < providers.length, "Provider not exists.");
        Provider storage pro = providers[_providerId];
        require(pro.enable, "Provider already disabled.");
        pro.enable = false;
        emit ProviderDisabled(_providerId);
    }

    function enableProvider(uint256 _providerId) onlyOwner public {
        require(_providerId < providers.length, "Provider not exists.");
        Provider storage pro = providers[_providerId];
        require(!pro.enable, "Provider already enabled.");
        pro.enable = true;
        emit ProviderEnabled(_providerId);
    }

    function addProvider(address _token, address _vault) onlyOwner public returns (uint256) {
        providers.push(Provider({
        vault : _vault,
        token : _token,
        enable : true,
        accProfit: 0
        }));

        require(ISashimiVault(_vault).controller() == address (this), "Controller not matched.");
        require(ISashimiVault(_vault).token() == _token, "Controller not matched.");

        uint256 providerId = providers.length.sub(1);
        emit ProviderAdded(_token, _vault, providerId);
        return providerId;
    }

    function chooseProvider(address _token, uint256 _providerId) onlyAdmin public {
        require(_providerId < providers.length, "Provider not added.");
        Provider storage provider = providers[_providerId];

        require(provider.token == _token, "Token not matched.");
        require(provider.enable, "Provider disabled.");

        uint256 chosen = chosenProviders[_token];
        require(chosen != _providerId, "Provider already chosen.");

        if (IERC20(ISashimiVault(provider.vault).profit()).allowance(address(this), routerForSashimi) == 0)
            IERC20(ISashimiVault(provider.vault).profit()).safeApprove(routerForSashimi, type(uint256).max);

        if (IERC20(provider.token).allowance(address(this), provider.vault) == 0)
            IERC20(provider.token).safeApprove(provider.vault, type(uint256).max);

        if (chosen != 0) {
            harvest(_token);
            Provider storage oldProvider = providers[chosen];

            uint256 withdrawAmount = ISashimiVault(oldProvider.vault).withdrawAll();
            uint256 depositAmount = deposits[_token];
            require(withdrawAmount >= depositAmount, "Insufficient withdraw amount.");
            ISashimiVault(provider.vault).deposit(depositAmount);
        }

        chosenProviders[_token] = _providerId;
        emit ProviderSwitched(_token, provider.vault, _providerId);
    }

    function changeReservesRatio(address _token, uint256 _reservesRatio) onlyOwner validRatio(_reservesRatio) public {
        reservesRatios[_token] = _reservesRatio;
        emit ReservesRatiosChanged(_token, _reservesRatio);
    }

    function addAdmin(address _admin) onlyOwner public {
        isAdmin[_admin] = true;
        emit AdminAdded(_admin);
    }

    function removeAdmin(address _admin) onlyOwner public {
        isAdmin[_admin] = false;
        emit AdminRemoved(_admin);
    }

    function changeBeneficiary1(address _beneficiary1) onlyOwner public {
        beneficiary1 = _beneficiary1;
    }

    function changeRouter(address _router) onlyOwner public {
        router = _router;
    }

    function changeSashimiRouter(address _sashimiRouter) onlyOwner public {
        routerForSashimi = _sashimiRouter;
    }

    function changeBeneficiary2(address _beneficiary2) onlyOwner public {
        beneficiary2 = _beneficiary2;
    }

    function start() onlyOwner public {
        frozen = false;
    }

    function emergencePause() onlyAdmin public {
        frozen = true;
    }

    function emergenceWithdraw(address _token, uint256 providerId, uint256 _amount, address _to) onlyOwner public{
        Provider memory provider = providers[providerId];
        ISashimiVault(provider.vault).transfer(_token, _to, _amount);
    }

    function emergenceWithdrawETH(uint256 providerId, uint256 _amount, address _to) onlyOwner public{
        Provider memory provider = providers[providerId];
        ISashimiVault(provider.vault).transferETH(_to, _amount);
    }

    function emergenceTriggerProvider(uint256 providerId, address target, uint value, string memory signature, bytes memory data) onlyOwner public{
        Provider memory provider = providers[providerId];
        ISashimiVault(provider.vault).executeTransaction(target, value, signature, data);
    }

    function emergenceTrigger(address target, string memory signature, bytes memory data) onlyOwner public{
        bytes memory callData;
        if (bytes(signature).length == 0) {
            callData = data;
        } else {
            callData = abi.encodePacked(bytes4(keccak256(bytes(signature))), data);
        }

        (bool success, ) = target.call(callData);
        require(success, "EmergenceTrigger execution failed.");
    }

    function emergenceChangeProviderLend(uint256 providerId, address _lend) onlyOwner public{
        Provider memory provider = providers[providerId];
        SashimiVault(provider.vault).emergenceChangeLend(_lend);
    }

    function earned(address _token) view public returns(address profit, uint256 amount){
        uint256 providerId = chosenProviders[_token];
        Provider memory provider = providers[providerId];
        profit = ISashimiVault(provider.vault).profit();
        amount = ISashimiVault(provider.vault).earned();
    }
}