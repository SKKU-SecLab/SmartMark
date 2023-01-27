
pragma solidity ^0.7.0;

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

pragma solidity ^0.7.0;

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

pragma solidity ^0.7.0;

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

pragma solidity ^0.7.0;


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

pragma solidity ^0.7.0;

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
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
}// MIT

pragma solidity ^0.7.0;


contract ERC20 is Context, IERC20 {

    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor (string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
        _decimals = 18;
    }

    function name() public view virtual returns (string memory) {

        return _name;
    }

    function symbol() public view virtual returns (string memory) {

        return _symbol;
    }

    function decimals() public view virtual returns (uint8) {

        return _decimals;
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

    function _setupDecimals(uint8 decimals_) internal virtual {

        _decimals = decimals_;
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }

}pragma solidity ^0.7.0;


interface IWETH is IERC20 {
  function deposit() external payable;
  function withdraw(uint) external;
  function decimals() external view returns(uint8);
}//Unlicense
pragma solidity ^0.7.0;
pragma experimental ABIEncoderV2;

interface ILendingRegistry {
    function wrappedToProtocol(address _wrapped) external view returns(bytes32);
    function wrappedToUnderlying(address _wrapped) external view returns(address);
    function underlyingToProtocolWrapped(address _underlying, bytes32 protocol) external view returns (address);
    function protocolToLogic(bytes32 _protocol) external view returns (address);

    function setWrappedToProtocol(address _wrapped, bytes32 _protocol) external;

    function setWrappedToUnderlying(address _wrapped, address _underlying) external;

    function setProtocolToLogic(bytes32 _protocol, address _logic) external;
    function setUnderlyingToProtocolWrapped(address _underlying, bytes32 _protocol, address _wrapped) external;

    function getLendTXData(address _underlying, uint256 _amount, bytes32 _protocol) external view returns(address[] memory targets, bytes[] memory data);

    function getUnlendTXData(address _wrapped, uint256 _amount) external view returns(address[] memory targets, bytes[] memory data);
}// MIT
pragma solidity ^0.7.0;

interface ILendingLogic {
    function getAPRFromUnderlying(address _token) external view returns(uint256);

    function getAPRFromWrapped(address _token) external view returns(uint256);

    function lend(address _underlying, uint256 _amount, address _tokenHolder) external view returns(address[] memory targets, bytes[] memory data);

    function unlend(address _wrapped, uint256 _amount, address _tokenHolder) external view returns(address[] memory targets, bytes[] memory data);

    function exchangeRate(address _wrapped) external returns(uint256);

    function exchangeRateView(address _wrapped) external view returns(uint256);
}//Unlicense
pragma solidity ^0.7.0;

interface IPieRegistry {
    function inRegistry(address _pool) external view returns(bool);
    function entries(uint256 _index) external view returns(address);
    function addSmartPool(address _smartPool) external;
    function removeSmartPool(uint256 _index) external;
}//Unlicense
pragma solidity ^0.7.0;


interface IPie is IERC20 {
    function joinPool(uint256 _amount) external;
    function exitPool(uint256 _amount) external;
    function calcTokensForAmount(uint256 _amount) external view  returns(address[] memory tokens, uint256[] memory amounts);
}pragma solidity ^0.7.0;


interface uniV3Router {

    struct ExactInputSingleParams {
        address tokenIn;
        address tokenOut;
        uint24 fee;
        address recipient;
        uint256 amountIn;
        uint256 amountOutMinimum;
        uint160 sqrtPriceLimitX96;
    }

    struct ExactOutputSingleParams {
        address tokenIn;
        address tokenOut;
        uint24 fee;
        address recipient;
        uint256 amountOut;
        uint256 amountInMaximum;
        uint160 sqrtPriceLimitX96;
    }

    struct ExactInputParams {
        bytes path;
        address recipient;
        uint256 deadline;
        uint256 amountIn;
        uint256 amountOutMinimum;
    }

    struct ExactOutputParams {
        bytes path;
        address recipient;
        uint256 deadline;
        uint256 amountOut;
        uint256 amountInMaximum;
    }

    function exactInputSingle(ExactInputSingleParams memory params) external returns (uint256 amountOut);

    function exactOutputSingle(ExactOutputSingleParams calldata params) external;

    function exactOutput(ExactOutputParams memory params) external returns (uint256 amountIn);
}

interface uniOracle {
   function quoteExactOutputSingle(
    address tokenIn,
    address tokenOut,
    uint24 fee,
    uint256 amountOut,
    uint160 sqrtPriceLimitX96
  ) external returns (uint256 amountIn);
}// MIT
pragma solidity ^0.7.0;



contract SimpleUniRecipe is Ownable {
    using SafeERC20 for IERC20;
    using SafeMath for uint256;


    IERC20 constant DAI = IERC20(0x6B175474E89094C44Da98b954EedeAC495271d0F);
    IWETH constant WETH = IWETH(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
    ILendingRegistry immutable lendingRegistry;
    IPieRegistry immutable basketRegistry;


    uniV3Router uniRouter;
    uniOracle oracle;

    constructor(
        address _lendingRegistry,
        address _pieRegistry,
        address _uniV3Router,
        address _uniOracle
    ) {
        require(_lendingRegistry != address(0), "LENDING_MANAGER_ZERO");
        require(_pieRegistry != address(0), "PIE_REGISTRY_ZERO");

        lendingRegistry = ILendingRegistry(_lendingRegistry);
        basketRegistry = IPieRegistry(_pieRegistry);

        uniRouter = uniV3Router(_uniV3Router);
        oracle = uniOracle(_uniOracle);

        DAI.approve(address(uniRouter), type(uint256).max);
        WETH.approve(address(uniRouter), type(uint256).max);
    }


    function bake(
        address _basket,
        uint256 _maxInput,
        uint256 _mintAmount
    ) external returns (uint256 inputAmountUsed, uint256 outputAmount) {
        DAI.safeTransferFrom(msg.sender, address(this), _maxInput);

        outputAmount = _bake(_basket, _mintAmount);

        uint256 remainingInputBalance = DAI.balanceOf(address(this));
        if (remainingInputBalance > 0) {
            DAI.safeTransfer(msg.sender, remainingInputBalance);
        }
        inputAmountUsed = _maxInput - remainingInputBalance;

        IERC20(_basket).safeTransfer(msg.sender, outputAmount);
    }

    function toBasket(
        address _basket,
        uint256 _mintAmount
    ) external payable returns (uint256 inputAmountUsed, uint256 outputAmount) {
        WETH.deposit{value : msg.value}();

        _swap_in_amount(
            address(WETH),
            address(DAI),
            msg.value,
            500
        );

        outputAmount = _bake(_basket, _mintAmount);

        uint256 daiBalance = DAI.balanceOf(address(this));
        if (daiBalance > 0) {
            uint256 remainingEth = _swap_in_amount(
                address(DAI),
                address(WETH),
                daiBalance,
                500
            );
            inputAmountUsed = msg.value - remainingEth;

            WETH.withdraw(remainingEth);
            msg.sender.transfer(remainingEth);
        }

        IERC20(_basket).safeTransfer(msg.sender, outputAmount);
    }

    function getPrice(address _basket, uint256 _amount) public returns (uint256 _price) {
        require(basketRegistry.inRegistry(_basket));

        (address[] memory tokens, uint256[] memory amounts) = IPie(_basket).calcTokensForAmount(_amount);
        address _token;
        address _underlying;
        uint256 _amount;
        for (uint256 i; i < tokens.length; ++i) {
            _token = tokens[i];
            _amount = amounts[i].add(1);

            assembly {
                if iszero(_amount) {
                    revert(0, 0)
                }
            }

            _underlying = lendingRegistry.wrappedToUnderlying(_token);
            if (_underlying != address(0)) {
                _amount = mulDivDown(
                    _amount,
                    getLendingLogicFromWrapped(_token).exchangeRateView(_token),
                    1e18
                );
                _token = _underlying;
            }

            _price += _token == address(DAI) ? _amount : _quoteExactOutput(address(DAI), _token, _amount, 500);
        }
        return _price;
    }

    function getPriceEth(address _basket, uint256 _amount) external returns (uint256 _price) {
        _price = _quoteExactOutput(
            address(WETH),
            address(DAI),
            getPrice(_basket, _amount),
            500
        );
    }


    function _bake(address _basket, uint256 _mintAmount) internal returns (uint256 outputAmount) {
        require(basketRegistry.inRegistry(_basket));

        swapAndJoin(_basket, _mintAmount);

        outputAmount = IERC20(_basket).balanceOf(address(this));
    }

    function swapAndJoin(address _basket, uint256 _mintAmount) internal {
        IPie basket = IPie(_basket);
        (address[] memory tokens, uint256[] memory amounts) = basket.calcTokensForAmount(_mintAmount);

        address _token;
        address underlying;
        uint256 _amount;
        uint256 underlyingAmount;
        ILendingLogic lendingLogic;

        for (uint256 i; i < tokens.length; ++i) {
            _token = tokens[i];
            _amount = amounts[i].add(1);

            underlying = lendingRegistry.wrappedToUnderlying(_token);

            if (underlying == address(0) && _token != address(DAI)) {
                _swap_out_amount(
                    address(DAI),
                    _token,
                    _amount,
                    500
                );
            } else {
                lendingLogic = getLendingLogicFromWrapped(_token);
                underlyingAmount = mulDivDown(_amount, lendingLogic.exchangeRate(_token), 1e18);

                if (underlying != address(DAI)) {
                    _swap_out_amount(
                        address(DAI),
                        underlying,
                        underlyingAmount,
                        500
                    );
                }

                (address[] memory targets, bytes[] memory data) = lendingLogic.lend(underlying, underlyingAmount, address(this));
                for (uint256 j; j < targets.length; ++j) {
                    (bool success,) = targets[j].call{value : 0}(data[j]);
                    require(success, "CALL_FAILED");
                }
            }
            IERC20(_token).approve(_basket, _amount);
        }
        basket.joinPool(_mintAmount);
    }

    function _swap_out_amount(
        address _from,
        address _to,
        uint256 _amountOut,
        uint24 _fee
    ) internal {
        uniRouter.exactOutputSingle(
            uniV3Router.ExactOutputSingleParams(
                _from,
                _to,
                _fee,
                address(this),
                _amountOut,
                type(uint256).max,
                0
            )
        );
    }

    function _swap_in_amount(
        address _from,
        address _to,
        uint256 _amountIn,
        uint24 _fee
    ) internal returns (uint256) {
        return uniRouter.exactInputSingle(
            uniV3Router.ExactInputSingleParams(
                _from,
                _to,
                _fee,
                address(this),
                _amountIn,
                0,
                0
            )
        );
    }

    function _quoteExactOutput(
        address _from,
        address _to,
        uint256 _amountOut,
        uint24 _fee
    ) internal returns (uint256 _amountIn) {
        try oracle.quoteExactOutputSingle(_from, _to, _fee, _amountOut, 0) returns (uint256 _p) {
            _amountIn = _p;
        } catch {
            _amountIn = type(uint256).max;
        }
    }

    function getLendingLogicFromWrapped(address _wrapped) internal view returns (ILendingLogic) {
        return ILendingLogic(
            lendingRegistry.protocolToLogic(
                lendingRegistry.wrappedToProtocol(
                    _wrapped
                )
            )
        );
    }

    function mulDivDown(
        uint256 x,
        uint256 y,
        uint256 denominator
    ) internal pure returns (uint256 z) {
        assembly {
            z := mul(x, y)

            if iszero(and(iszero(iszero(denominator)), or(iszero(x), eq(div(z, x), y)))) {
                revert(0, 0)
            }

            z := div(z, denominator)
        }
    }


    function updateUniRouter(address _newRouter, address _oracle) external onlyOwner {
        uniRouter = uniV3Router(_newRouter);

        WETH.approve(_newRouter, 0);
        WETH.approve(_newRouter, type(uint256).max);

        DAI.approve(_newRouter, 0);
        DAI.approve(_newRouter, type(uint256).max);
    }

    function updateUniOracle(address _newOracle) external onlyOwner {
        oracle = uniOracle(_newOracle);
    }

    receive() external payable {}
}