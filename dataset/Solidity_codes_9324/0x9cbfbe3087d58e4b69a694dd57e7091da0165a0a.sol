
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
}// MIT

pragma solidity ^0.8.0;


interface IERC20Metadata is IERC20 {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function decimals() external view returns (uint8);

}// MIT

pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}// MIT

pragma solidity ^0.8.0;


contract ERC20 is Context, IERC20, IERC20Metadata {

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    constructor (string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    function name() public view virtual override returns (string memory) {

        return _name;
    }

    function symbol() public view virtual override returns (string memory) {

        return _symbol;
    }

    function decimals() public view virtual override returns (uint8) {

        return 18;
    }

    function totalSupply() public view virtual override returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address account) public view virtual override returns (uint256) {

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

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        _approve(sender, _msgSender(), currentAllowance - amount);

        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {

        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        _approve(_msgSender(), spender, currentAllowance - subtractedValue);

        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal virtual {

        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        _balances[sender] = senderBalance - amount;
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        _balances[account] = accountBalance - amount;
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal virtual {

        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }

}// MIT

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
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}// MIT

pragma solidity >=0.8.0 <0.9.0;

interface IFactory {
    function getPair(address tokenA, address tokenB)
        external
        view
        returns (address pair);
}// MIT

pragma solidity >=0.8.0 <0.9.0;

interface IRouter {

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB, uint256 liquidity);

    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountToken, uint256 amountETH, uint256 liquidity);
    
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

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB);

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactETHForTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);
    
    function getAmountsOut(
        uint256 amountIn, 
        address[] calldata path
    ) external view returns (uint256[] memory amounts);
}// MIT

pragma solidity >=0.8.0 <0.9.0;

interface IWrapper {

    struct WrapParams {
        address sourceToken;
        address [] destinationTokens;
        address [] path1;
        address [] path2;
        uint256 amount;
        uint256 [] userSlippageToleranceAmounts;
        uint256 deadline;
    }

    struct UnwrapParams {
        address lpTokenPairAddress;
        address destinationToken;
        address [] path1;
        address [] path2;
        uint256 amount;
        uint256 [] userSlippageToleranceAmounts;
        uint256 [] minUnwrapAmounts;
        uint256 deadline;
    }

    struct RemixWrapParams {
        address [] sourceTokens;
        address [] destinationTokens;
        address [] path1;
        address [] path2;
        uint256 amount1;
        uint256 amount2;
        uint256 [] userSlippageToleranceAmounts;
        uint256 deadline;
    }

    struct RemixParams {
        address lpTokenPairAddress;
        address [] destinationTokens;
        address [] wrapPath1;
        address [] wrapPath2;
        uint256 amount;
        uint256 [] remixWrapSlippageToleranceAmounts;
        uint256 [] minUnwrapAmounts;
        uint256 deadline;
        bool crossDexRemix;
    }

    function wrap(WrapParams memory params) 
        external 
        payable 
        returns (address, uint256);

    function unwrap(UnwrapParams memory params) 
        external 
        payable 
        returns (uint256);

    function remix(RemixParams memory params) 
        external 
        payable 
        returns (address, uint256);
}// MIT

pragma solidity >=0.8.0 <0.9.0;

interface ILPERC20 {
    function token0() external view returns (address);
    function token1() external view returns (address);
}// MIT

pragma solidity >=0.8.0 <0.9.0;

interface IWETH {
    function deposit() external payable;
    function transfer(address to, uint256 value) external returns (bool);
    function withdraw(uint256) external;
}// MIT
pragma solidity >=0.8.0 <0.9.0;


contract WrapAndUnWrap is IWrapper {
    using SafeERC20 for IERC20;

    bool public changeRecipientIsOwner;
    address public WETH_TOKEN_ADDRESS; // Contract address for WETH tokens
    address public uniAddress;
    address public sushiAddress;
    address public uniFactoryAddress;
    address public sushiFactoryAddress;
    address public owner;
    uint256 public fee;
    uint256 public maxfee;
    IRouter public uniswapExchange;
    IFactory public factory;

    event WrapV2(address lpTokenPairAddress, uint256 amount);
    event UnWrapV2(uint256 amount);
    event LpTokenRemixWrap(address lpTokenPairAddress, uint256 amount);

    constructor(
        address _weth,
        address _uniAddress,
        address _sushiAddress,
        address _uniFactoryAddress,
        address _sushiFactoryAddress

    )
        payable
    {
        WETH_TOKEN_ADDRESS = _weth;
        uniAddress = _uniAddress;
        sushiAddress = _sushiAddress;
        uniFactoryAddress = _uniFactoryAddress;
        sushiFactoryAddress = _sushiFactoryAddress;
        
        uniswapExchange = IRouter(uniAddress);
        factory = IFactory(uniFactoryAddress);

        fee = 0;
        maxfee = 0;
        changeRecipientIsOwner = false;
        owner = msg.sender;
    }

    modifier onlyOwner {
      require(msg.sender == owner, "Not contract owner!");
      _;
    }

    fallback() external payable {
    }

    receive() external payable {
    }

    function updateChangeRecipientBool(
        bool changeRecipientIsOwnerBool
    )
        external
        onlyOwner
        returns (bool)
    {
        changeRecipientIsOwner = changeRecipientIsOwnerBool;
        return true;
    }

    function updateUniswapExchange(address newAddress) external onlyOwner returns (bool) {
        uniswapExchange = IRouter(newAddress);
        uniAddress = newAddress;
        return true;
    }

    function updateUniswapFactory(address newAddress) external onlyOwner returns (bool) {
        factory = IFactory(newAddress);
        uniFactoryAddress = newAddress;
        return true;
    }

    function adminEmergencyWithdrawTokens(
        address token,
        uint256 amount,
        address payable destination
    )
        public
        onlyOwner
        returns (bool)
    {
        if (address(token) == address(0x0)) {
            destination.transfer(amount);
        } else {
            IERC20 token_ = IERC20(token);
            token_.safeTransfer(destination, amount);
        }
        return true;
    }

    function setFee(uint256 newFee) public onlyOwner returns (bool) {
        require(
            newFee <= maxfee,
            "Admin cannot set the fee higher than the current maxfee"
        );
        fee = newFee;
        return true;
    }

    function setMaxFee(uint256 newMax) public onlyOwner returns (bool) {
        require(maxfee == 0, "Admin can only set max fee once and it is perm");
        maxfee = newMax;
        return true;
    }

    function swap(
        address sourceToken,
        address destinationToken,
        address[] memory path,
        uint256 amount,
        uint256 userSlippageToleranceAmount,
        uint256 deadline
    ) private returns (uint256) {
        if (sourceToken != address(0x0)) {
            IERC20(sourceToken).safeTransferFrom(msg.sender, address(this), amount);
        }

        conductUniswap(sourceToken, destinationToken, path, amount, userSlippageToleranceAmount, deadline);
        uint256 thisBalance = IERC20(destinationToken).balanceOf(address(this));
        IERC20(destinationToken).safeTransfer(msg.sender, thisBalance);
        return thisBalance;
    }

    function chargeFees(address token1, address token2) private {

        address thisPairAddress = factory.getPair(token1, token2);

        if (thisPairAddress == address(0)) {
            IFactory fct = IFactory(sushiFactoryAddress);
            thisPairAddress = fct.getPair(token1, token2);
        }
        IERC20 lpToken = IERC20(thisPairAddress);
        uint256 thisBalance = lpToken.balanceOf(address(this));

        IERC20 dToken1 = IERC20(token1);
        IERC20 dToken2 = IERC20(token2);

        if (fee > 0) {
            uint256 totalFee = (thisBalance * fee) / 10000;
            if (totalFee > 0) {
                lpToken.safeTransfer(owner, totalFee);
            }
            thisBalance = lpToken.balanceOf(address(this));
            lpToken.safeTransfer(msg.sender, thisBalance);
        } else {
            lpToken.safeTransfer(msg.sender, thisBalance);
        }

        address changeRecipient = msg.sender;
        if (changeRecipientIsOwner == true) {
            changeRecipient = owner;
        }
        if (dToken1.balanceOf(address(this)) > 0) {
            dToken1.safeTransfer(changeRecipient, dToken1.balanceOf(address(this)));
        }
        if (dToken2.balanceOf(address(this)) > 0) {
            dToken2.safeTransfer(changeRecipient, dToken2.balanceOf(address(this)));
        }

    }

    function createRemixWrap(RemixWrapParams memory params, bool crossDexRemix) private returns (address, uint256) {

        IRouter router = uniswapExchange;
        IFactory fct = factory;
 
        if(crossDexRemix) {
            router = IRouter(sushiAddress);
            fct = IFactory(sushiFactoryAddress);
        }

        if (params.sourceTokens[0] != params.destinationTokens[0]) {
            conductSwapT4TRemix(
                router,
                params.path1,
                params.amount1,
                params.userSlippageToleranceAmounts[0],
                params.deadline
            );
        }
        if (params.sourceTokens[1] != params.destinationTokens[1]) {
            conductSwapT4TRemix(
                router,
                params.path2,
                params.amount2,
                params.userSlippageToleranceAmounts[1],
                params.deadline
            );
        }

        IERC20 dToken1 = IERC20(params.destinationTokens[0]);
        IERC20 dToken2 = IERC20(params.destinationTokens[1]);
        uint256 dTokenBalance1 = dToken1.balanceOf(address(this));
        uint256 dTokenBalance2 = dToken2.balanceOf(address(this));

        if (crossDexRemix) {

            if (dToken1.allowance(address(this), sushiAddress) < dTokenBalance1 * 2) {
                dToken1.safeIncreaseAllowance(sushiAddress, dTokenBalance1 * 3);
            }

            if (dToken2.allowance(address(this), sushiAddress) < dTokenBalance2 * 2) {
                dToken2.safeIncreaseAllowance(sushiAddress, dTokenBalance2 * 3);
            }

        } else {
            if (dToken1.allowance(address(this), uniAddress) < dTokenBalance1 * 2) {
                dToken1.safeIncreaseAllowance(uniAddress, dTokenBalance1 * 3);
            }

            if (dToken2.allowance(address(this), uniAddress) < dTokenBalance2 * 2) {
                dToken2.safeIncreaseAllowance(uniAddress, dTokenBalance2 * 3);
            }

        }

        router.addLiquidity(
            params.destinationTokens[0],
            params.destinationTokens[1],
            dTokenBalance1,
            dTokenBalance2,
            1,
            1,
            address(this),
            1000000000000000000000000000
        );

        address thisPairAddress = fct.getPair(params.destinationTokens[0], params.destinationTokens[1]);
        IERC20 lpToken = IERC20(thisPairAddress);
        uint256 thisBalance = lpToken.balanceOf(address(this));

        chargeFees(params.destinationTokens[0], params.destinationTokens[1]);

        return (thisPairAddress, thisBalance);
    }

    function createWrap(WrapParams memory params) private returns (address, uint256) {
        uint256 amount = params.amount;
        if (params.sourceToken == address(0x0)) {
            IWETH(WETH_TOKEN_ADDRESS).deposit{value: msg.value}();
            amount = msg.value;
        } else {
            IERC20(params.sourceToken).safeTransferFrom(msg.sender, address(this), amount);
        }

        if (params.destinationTokens[0] == address(0x0)) {
            params.destinationTokens[0] = WETH_TOKEN_ADDRESS;
        }
        if (params.destinationTokens[1] == address(0x0)) {
            params.destinationTokens[1] = WETH_TOKEN_ADDRESS;
        }

        if (params.sourceToken != params.destinationTokens[0]) {
            conductUniswap(
                params.sourceToken,
                params.destinationTokens[0],
                params.path1,
                (amount / 2),
                params.userSlippageToleranceAmounts[0],
                params.deadline
            );
        }
        if (params.sourceToken != params.destinationTokens[1]) {
            conductUniswap(
                params.sourceToken,
                params.destinationTokens[1],
                params.path2,
                (amount / 2),
                params.userSlippageToleranceAmounts[1],
                params.deadline
            );
        }

        IERC20 dToken1 = IERC20(params.destinationTokens[0]);
        IERC20 dToken2 = IERC20(params.destinationTokens[1]);
        uint256 dTokenBalance1 = dToken1.balanceOf(address(this));
        uint256 dTokenBalance2 = dToken2.balanceOf(address(this));

        if (dToken1.allowance(address(this), uniAddress) < dTokenBalance1 * 2) {
            dToken1.safeIncreaseAllowance(uniAddress, dTokenBalance1 * 3);
        }

        if (dToken2.allowance(address(this), uniAddress) < dTokenBalance2 * 2) {
            dToken2.safeIncreaseAllowance(uniAddress, dTokenBalance2 * 3);
        }

        uniswapExchange.addLiquidity(
            params.destinationTokens[0],
            params.destinationTokens[1],
            dTokenBalance1,
            dTokenBalance2,
            1,
            1,
            address(this),
            1000000000000000000000000000
        );

        address thisPairAddress = factory.getPair(params.destinationTokens[0], params.destinationTokens[1]);
        IERC20 lpToken = IERC20(thisPairAddress);
        uint256 thisBalance = lpToken.balanceOf(address(this));

        chargeFees(params.destinationTokens[0], params.destinationTokens[1]);

        return (thisPairAddress, thisBalance);
    }

    function wrap(
        WrapParams memory params
    )
        override
        external
        payable
        returns (address, uint256)
    {
        if (params.destinationTokens.length == 1) {
            uint256 swapAmount = swap(params.sourceToken, params.destinationTokens[0], params.path1, params.amount, params.userSlippageToleranceAmounts[0], params.deadline);
            return (params.destinationTokens[0], swapAmount);
        } else {
            (address lpTokenPairAddress, uint256 lpTokenAmount) = createWrap(params);
            emit WrapV2(lpTokenPairAddress, lpTokenAmount);
            return (lpTokenPairAddress, lpTokenAmount);
        }
    }
    
    function removePoolLiquidity(
        address lpTokenAddress,
        uint256 amount,
        uint256 minUnwrapAmount1,
        uint256 minUnwrapAmount2,
        uint256 deadline
    )
    private returns (uint256, uint256){

        ILPERC20 lpTokenInfo = ILPERC20(lpTokenAddress);
        address token0 = lpTokenInfo.token0();
        address token1 = lpTokenInfo.token1();

        uniswapExchange.removeLiquidity(
            token0,
            token1,
            amount,
            minUnwrapAmount1,
            minUnwrapAmount2,
            address(this),
            deadline
        );

        uint256 pTokenBalance = IERC20(token0).balanceOf(address(this));
        uint256 pTokenBalance2 = IERC20(token1).balanceOf(address(this));

        return (pTokenBalance, pTokenBalance2);

    }

    function removeWrap(UnwrapParams memory params) private returns (uint256){
        address originalDestinationToken = params.destinationToken;

        IERC20 sToken = IERC20(params.lpTokenPairAddress);
        if (params.destinationToken == address(0x0)) {
            params.destinationToken = WETH_TOKEN_ADDRESS;
        }

        if (params.lpTokenPairAddress != address(0x0)) {
            sToken.safeTransferFrom(msg.sender, address(this), params.amount);
        }

        ILPERC20 thisLpInfo = ILPERC20(params.lpTokenPairAddress);
        address token0 = thisLpInfo.token0();
        address token1 = thisLpInfo.token1();

        if (sToken.allowance(address(this), uniAddress) < params.amount * 2) {
            sToken.safeIncreaseAllowance(uniAddress, params.amount * 3);
        }

        ( uint256  pTokenBalance,  uint256 pTokenBalance2 )= removePoolLiquidity(
            params.lpTokenPairAddress,
            params.amount,
            params.minUnwrapAmounts[0],
            params.minUnwrapAmounts[1],
            params.deadline
        );

        if (token0 != params.destinationToken) {
            conductUniswap(
                token0,
                params.destinationToken,
                params.path1,
                pTokenBalance,
                params.userSlippageToleranceAmounts[0],
                params.deadline
            );
        }

        if (token1 != params.destinationToken) {
            conductUniswap(
                token1,
                params.destinationToken,
                params.path2,
                pTokenBalance2,
                params.userSlippageToleranceAmounts[1],
                params.deadline
            );
        }

        IERC20 dToken = IERC20(params.destinationToken);
        uint256 destinationTokenBalance = dToken.balanceOf(address(this));

        if (originalDestinationToken == address(0x0)) {
            IWETH(WETH_TOKEN_ADDRESS).withdraw(destinationTokenBalance);
            if (fee > 0) {
                uint256 totalFee = (address(this).balance * fee) / 10000;
                if (totalFee > 0) {
                    payable(owner).transfer(totalFee);
                }
                    payable(msg.sender).transfer(address(this).balance);
            } else {
                payable(msg.sender).transfer(address(this).balance);
            }
        } else {
            if (fee > 0) {
                uint256 totalFee = (destinationTokenBalance * fee) / 10000;
                if (totalFee > 0) {
                    dToken.safeTransfer(owner, totalFee);
                }
                destinationTokenBalance = dToken.balanceOf(address(this));
                dToken.safeTransfer(msg.sender, destinationTokenBalance);
            } else {
                dToken.safeTransfer(msg.sender, destinationTokenBalance);
            }

        }

        emit UnWrapV2(destinationTokenBalance);

    
        return destinationTokenBalance;
    }

    function unwrap(
        UnwrapParams memory params
    )
        override
        public
        payable
        returns (uint256)
    {
        uint256 destAmount = removeWrap(params);
        return destAmount;
    }

    function remix(RemixParams memory params)
        override
        public
        payable
        returns (address, uint256)
    {
        uint lpTokenAmount = 0;
        address lpTokenAddress = address(0);

        IERC20 lpToken = IERC20(params.lpTokenPairAddress);
       
        if (params.lpTokenPairAddress != address(0x0)) {
            lpToken.safeTransferFrom(msg.sender, address(this), params.amount);
        }

        if (lpToken.allowance(address(this), uniAddress) < params.amount * 2) {
            lpToken.safeIncreaseAllowance(uniAddress, params.amount * 3);
        }

        if (lpToken.allowance(address(this), sushiAddress) < params.amount * 2) {
            lpToken.safeIncreaseAllowance(sushiAddress, params.amount * 3);
        }

        ILPERC20 lpTokenInfo = ILPERC20(params.lpTokenPairAddress);
        address token0 = lpTokenInfo.token0();
        address token1 = lpTokenInfo.token1();

        (uint256  pTokenBalance1, uint256 pTokenBalance2) = removePoolLiquidity(
            params.lpTokenPairAddress,
            params.amount,
            params.minUnwrapAmounts[0],
            params.minUnwrapAmounts[1],
            params.deadline
        );

        if (pTokenBalance1 > 0 && pTokenBalance2 > 0) {

            address[] memory sTokens = new address[](2);
            sTokens[0] = token0;
            sTokens[1] = token1;

            if (params.crossDexRemix) {

                IERC20 sToken0 = IERC20(sTokens[0]);
                if (sToken0.allowance(address(this), sushiAddress) < pTokenBalance1 * 2) {
                    sToken0.safeIncreaseAllowance(sushiAddress, pTokenBalance1 * 3);
                }

                IERC20 sToken1 = IERC20(sTokens[1]);
                if (sToken1.allowance(address(this), sushiAddress) < pTokenBalance2 * 2) {
                    sToken1.safeIncreaseAllowance(sushiAddress, pTokenBalance2 * 3);
                }

            } else {
                IERC20 sToken0 = IERC20(sTokens[0]);
                if (sToken0.allowance(address(this), uniAddress) < pTokenBalance1 * 2) {
                    sToken0.safeIncreaseAllowance(uniAddress, pTokenBalance1 * 3);
                }

                IERC20 sToken1 = IERC20(sTokens[1]);
                if (sToken1.allowance(address(this), uniAddress) < pTokenBalance2 * 2) {
                    sToken1.safeIncreaseAllowance(uniAddress, pTokenBalance2 * 3);
                }
            }

            RemixWrapParams memory remixParams = RemixWrapParams({
                sourceTokens: sTokens,
                destinationTokens: params.destinationTokens,
                path1: params.wrapPath1,
                path2: params.wrapPath2,
                amount1: pTokenBalance1,
                amount2: pTokenBalance2,
                userSlippageToleranceAmounts: params.remixWrapSlippageToleranceAmounts,
                deadline:  params.deadline
            });

            (lpTokenAddress, lpTokenAmount) = createRemixWrap(remixParams, params.crossDexRemix);

            emit LpTokenRemixWrap(lpTokenAddress, lpTokenAmount);
        }

        
        return (lpTokenAddress, lpTokenAmount);

    }


    function getAmountsOut(address[] memory theAddresses, uint256 amount)
        public
        view
        returns (uint256[] memory amounts1) {
        try uniswapExchange.getAmountsOut(
            amount,
            theAddresses
        ) returns (uint256[] memory amounts) {
            return amounts;
        } catch {
            uint256[] memory amounts2 = new uint256[](2);
            amounts2[0] = 0;
            amounts2[1] = 0;
            return amounts2;
        }
    }

    function getLPTokenByPair(
        address token1,
        address token2
    )
        public
        view
        returns (address lpAddr)
    {
        address thisPairAddress = factory.getPair(token1, token2);
        return thisPairAddress;
    }

    function getPoolTokensDetails(address lpTokenAddress)
        external
        view
        returns (string memory token0Name, string memory token0Symbol, uint256 token0Decimals, 
            string memory token1Name, string memory token1Symbol, uint256 token1Decimals)
    {
        address token0 = ILPERC20(lpTokenAddress).token0();
        address token1 = ILPERC20(lpTokenAddress).token1();

        string memory t0Name = ERC20(token0).name();
        string memory t0Symbol = ERC20(token0).symbol();
        uint256 t0Decimals = ERC20(token0).decimals();
        string memory t1Name = ERC20(token0).name();
        string memory t1Symbol = ERC20(token1).symbol();
        uint256 t1Decimals = ERC20(token1).decimals();

        return (t0Name, t0Symbol, t0Decimals, t1Name, t1Symbol, t1Decimals);
    }

    function getUserTokenBalance(
        address userAddress,
        address tokenAddress
    )
        public
        view
        returns (uint256)
    {
        IERC20 token = IERC20(tokenAddress);
        return token.balanceOf(userAddress);
    }

    function conductUniswap(
        address sellToken,
        address buyToken,
        address[] memory path,
        uint256 amount,
        uint256 userSlippageToleranceAmount,
        uint256 deadline
    )
        internal
        returns (uint256 amounts1)
    {
        if (sellToken == address(0x0) && buyToken == WETH_TOKEN_ADDRESS) {
            IWETH(buyToken).deposit{value: msg.value}();
            return amount;
        }

        if (sellToken == address(0x0)) {
            uniswapExchange.swapExactETHForTokens{value: msg.value}(
                userSlippageToleranceAmount,
                path,
                address(this),
                deadline
            );
        } else {
            IERC20 sToken = IERC20(sellToken);
            if (sToken.allowance(address(this), uniAddress) < amount * 2) {
                sToken.safeIncreaseAllowance(uniAddress, amount * 3);
            }

            uint256[] memory amounts = conductUniswapT4T(
                path,
                amount,
                userSlippageToleranceAmount,
                deadline
            );
            uint256 resultingTokens = amounts[amounts.length - 1];
            return resultingTokens;
        }
    }

    function conductUniswapT4T(
        address[] memory paths,
        uint256 amount,
        uint256 userSlippageToleranceAmount,
        uint256 deadline
    )
        internal
        returns (uint256[] memory amounts_)
    {
        uint256[] memory amounts =
            uniswapExchange.swapExactTokensForTokens(
                amount,
                userSlippageToleranceAmount,
                paths,
                address(this),
                deadline
            );
        return amounts;
    }

    function conductSwapT4TRemix(
        IRouter router,
        address[] memory path,
        uint256 amount,
        uint256 userSlippageToleranceAmount,
        uint256 deadline
    )
        internal
        returns (uint256[] memory amounts_)
    {
        uint256[] memory amounts =
            router.swapExactTokensForTokens(
                amount,
                userSlippageToleranceAmount,
                path,
                address(this),
                deadline
            );
        return amounts;
    }
}