
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

abstract contract Ownable is Context {
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
}// MIT

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


    struct Bytes32Set {
        Set _inner;
    }

    function add(Bytes32Set storage set, bytes32 value) internal returns (bool) {

        return _add(set._inner, value);
    }

    function remove(Bytes32Set storage set, bytes32 value) internal returns (bool) {

        return _remove(set._inner, value);
    }

    function contains(Bytes32Set storage set, bytes32 value) internal view returns (bool) {

        return _contains(set._inner, value);
    }

    function length(Bytes32Set storage set) internal view returns (uint256) {

        return _length(set._inner);
    }

    function at(Bytes32Set storage set, uint256 index) internal view returns (bytes32) {

        return _at(set._inner, index);
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


contract ERC20 is Context, IERC20 {

    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor (string memory name_, string memory symbol_) public {
        _name = name_;
        _symbol = symbol_;
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

}// MIT

pragma solidity ^0.7.0;


interface IERC20Extended is IERC20 {
    function decimals() external view returns (uint8);
}// MIT

pragma solidity >=0.6.0 <0.8.0;

interface IERC165 {
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}// MIT

pragma solidity >=0.6.2 <0.8.0;


interface IERC1155 is IERC165 {
    event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value);

    event TransferBatch(address indexed operator, address indexed from, address indexed to, uint256[] ids, uint256[] values);

    event ApprovalForAll(address indexed account, address indexed operator, bool approved);

    event URI(string value, uint256 indexed id);

    function balanceOf(address account, uint256 id) external view returns (uint256);

    function balanceOfBatch(address[] calldata accounts, uint256[] calldata ids) external view returns (uint256[] memory);

    function setApprovalForAll(address operator, bool approved) external;

    function isApprovedForAll(address account, address operator) external view returns (bool);

    function safeTransferFrom(address from, address to, uint256 id, uint256 amount, bytes calldata data) external;

    function safeBatchTransferFrom(address from, address to, uint256[] calldata ids, uint256[] calldata amounts, bytes calldata data) external;
}// MIT

pragma solidity ^0.7.0;

interface IFlashLoanReceiver {
    function execute(address _tokenAddress, uint256 _amount, uint256 _amountWithFee) external;
}pragma solidity >=0.6.2;

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
}pragma solidity >=0.6.2;


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
}// MIT

pragma solidity ^0.7.0;
pragma experimental ABIEncoderV2;


interface IPremiaOption is IERC1155 {
    struct OptionWriteArgs {
        address token;                  // Token address
        uint256 amount;                 // Amount of tokens to write option for
        uint256 strikePrice;            // Strike price (Must follow strikePriceIncrement of token)
        uint256 expiration;             // Expiration timestamp of the option (Must follow expirationIncrement)
        bool isCall;                    // If true : Call option | If false : Put option
    }

    struct OptionData {
        address token;                  // Token address
        uint256 strikePrice;            // Strike price (Must follow strikePriceIncrement of token)
        uint256 expiration;             // Expiration timestamp of the option (Must follow expirationIncrement)
        bool isCall;                    // If true : Call option | If false : Put option
        uint256 claimsPreExp;           // Amount of options from which the funds have been withdrawn pre expiration
        uint256 claimsPostExp;          // Amount of options from which the funds have been withdrawn post expiration
        uint256 exercised;              // Amount of options which have been exercised
        uint256 supply;                 // Total circulating supply
        uint8 decimals;                 // Token decimals
    }

    struct QuoteWrite {
        address collateralToken;        // The token to deposit as collateral
        uint256 collateral;             // The amount of collateral to deposit
        uint8 collateralDecimals;       // Decimals of collateral token
        uint256 fee;                    // The amount of collateralToken needed to be paid as protocol fee
        uint256 feeReferrer;            // The amount of collateralToken which will be paid the referrer
    }

    struct QuoteExercise {
        address inputToken;             // Input token for exercise
        uint256 input;                  // Amount of input token to pay to exercise
        uint8 inputDecimals;            // Decimals of input token
        address outputToken;            // Output token from the exercise
        uint256 output;                 // Amount of output tokens which will be received on exercise
        uint8 outputDecimals;           // Decimals of output token
        uint256 fee;                    // The amount of inputToken needed to be paid as protocol fee
        uint256 feeReferrer;            // The amount of inputToken which will be paid to the referrer
    }

    struct Pool {
        uint256 tokenAmount;
        uint256 denominatorAmount;
    }

    function denominatorDecimals() external view returns(uint8);

    function maxExpiration() external view returns(uint256);
    function optionData(uint256 _optionId) external view returns (OptionData memory);
    function tokenStrikeIncrement(address _token) external view returns (uint256);
    function nbWritten(address _writer, uint256 _optionId) external view returns (uint256);

    function getOptionId(address _token, uint256 _expiration, uint256 _strikePrice, bool _isCall) external view returns(uint256);
    function getOptionIdOrCreate(address _token, uint256 _expiration, uint256 _strikePrice, bool _isCall) external returns(uint256);


    function getWriteQuote(address _from, OptionWriteArgs memory _option, address _referrer, uint8 _decimals) external view returns(QuoteWrite memory);
    function getExerciseQuote(address _from, OptionData memory _option, uint256 _amount, address _referrer, uint8 _decimals) external view returns(QuoteExercise memory);

    function writeOptionWithIdFrom(address _from, uint256 _optionId, uint256 _amount, address _referrer) external returns(uint256);
    function writeOption(address _token, OptionWriteArgs memory _option, address _referrer) external returns(uint256);
    function writeOptionFrom(address _from, OptionWriteArgs memory _option, address _referrer) external returns(uint256);
    function cancelOption(uint256 _optionId, uint256 _amount) external;
    function cancelOptionFrom(address _from, uint256 _optionId, uint256 _amount) external;
    function exerciseOption(uint256 _optionId, uint256 _amount) external;
    function exerciseOptionFrom(address _from, uint256 _optionId, uint256 _amount, address _referrer) external;
    function withdraw(uint256 _optionId) external;
    function withdrawFrom(address _from, uint256 _optionId) external;
    function withdrawPreExpiration(uint256 _optionId, uint256 _amount) external;
    function withdrawPreExpirationFrom(address _from, uint256 _optionId, uint256 _amount) external;
    function flashExerciseOption(uint256 _optionId, uint256 _amount, address _referrer, IUniswapV2Router02 _router, uint256 _amountInMax) external;
    function flashExerciseOptionFrom(address _from, uint256 _optionId, uint256 _amount, address _referrer, IUniswapV2Router02 _router, uint256 _amountInMax) external;
    function flashLoan(address _tokenAddress, uint256 _amount, IFlashLoanReceiver _receiver) external;
}// MIT

pragma solidity ^0.7.0;

interface IFeeCalculator {
    enum FeeType {Write, Exercise, Maker, Taker, FlashLoan}

    function writeFee() external view returns(uint256);
    function exerciseFee() external view returns(uint256);
    function flashLoanFee() external view returns(uint256);

    function referrerFee() external view returns(uint256);
    function referredDiscount() external view returns(uint256);

    function makerFee() external view returns(uint256);
    function takerFee() external view returns(uint256);

    function getFee(address _user, bool _hasReferrer, FeeType _feeType) external view returns(uint256);
    function getFeeAmounts(address _user, bool _hasReferrer, uint256 _amount, FeeType _feeType) external view returns(uint256 _fee, uint256 _feeReferrer);
    function getFeeAmountsWithDiscount(address _user, bool _hasReferrer, uint256 _baseFee) external view returns(uint256 _fee, uint256 _feeReferrer);
}// MIT

pragma solidity ^0.7.0;

interface IPremiaReferral {
    function referrals(address _referred) external view returns(address _referrer);
    function trySetReferrer(address _referred, address _potentialReferrer) external returns(address);
}// MIT

pragma solidity ^0.7.0;


interface IPremiaUncutErc20 is IERC20 {
    function getTokenPrice(address _token) external view returns(uint256);
    function mint(address _account, uint256 _amount) external;
    function mintReward(address _account, address _token, uint256 _feePaid, uint8 _decimals) external;
}// MIT

pragma solidity ^0.7.0;



contract PremiaMarket is Ownable, ReentrancyGuard {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    using EnumerableSet for EnumerableSet.AddressSet;

    IPremiaUncutErc20 public uPremia;
    IFeeCalculator public feeCalculator;
    IPremiaReferral public premiaReferral;

    EnumerableSet.AddressSet private _whitelistedOptionContracts;
    EnumerableSet.AddressSet private _whitelistedPaymentTokens;

    mapping(address => uint8) public paymentTokenDecimals;

    address public feeRecipient;

    enum SaleSide {Buy, Sell}

    uint256 private constant _inverseBasisPoint = 1e4;

    uint256 salt = 0;

    struct Order {
        address maker;              // Order maker address
        SaleSide side;              // Side (buy/sell)
        bool isDelayedWriting;      // If true, option has not been written yet
        address optionContract;     // Address of optionContract from which option is from
        uint256 optionId;           // OptionId
        address paymentToken;       // Address of token used for payment
        uint256 pricePerUnit;       // Price per unit (in paymentToken) with 18 decimals
        uint256 expirationTime;     // Expiration timestamp of option (Which is also expiration of order)
        uint256 salt;               // To ensure unique hash
        uint8 decimals;             // Option token decimals
    }

    struct Option {
        address token;              // Token address
        uint256 expiration;         // Expiration timestamp of the option (Must follow expirationIncrement)
        uint256 strikePrice;        // Strike price (Must follow strikePriceIncrement of token)
        bool isCall;                // If true : Call option | If false : Put option
    }

    mapping(bytes32 => uint256) public amounts;

    mapping(address => uint256) public uPremiaBalance;

    bool public isDelayedWritingEnabled = true;


    event OrderCreated(
        bytes32 indexed hash,
        address indexed maker,
        address indexed optionContract,
        SaleSide side,
        bool isDelayedWriting,
        uint256 optionId,
        address paymentToken,
        uint256 pricePerUnit,
        uint256 expirationTime,
        uint256 salt,
        uint256 amount,
        uint8 decimals
    );

    event OrderFilled(
        bytes32 indexed hash,
        address indexed taker,
        address indexed optionContract,
        address maker,
        address paymentToken,
        uint256 amount,
        uint256 pricePerUnit
    );

    event OrderCancelled(
        bytes32 indexed hash,
        address indexed maker,
        address indexed optionContract,
        address paymentToken,
        uint256 amount,
        uint256 pricePerUnit
    );


    constructor(IPremiaUncutErc20 _uPremia, IFeeCalculator _feeCalculator, address _feeRecipient, IPremiaReferral _premiaReferral) {
        require(_feeRecipient != address(0), "FeeRecipient cannot be 0x0 address");
        feeRecipient = _feeRecipient;
        uPremia = _uPremia;
        feeCalculator = _feeCalculator;
        premiaReferral = _premiaReferral;
    }



    function setFeeRecipient(address _feeRecipient) external onlyOwner {
        require(_feeRecipient != address(0), "FeeRecipient cannot be 0x0 address");
        feeRecipient = _feeRecipient;
    }

    function setPremiaUncutErc20(IPremiaUncutErc20 _uPremia) external onlyOwner {
        uPremia = _uPremia;
    }

    function setFeeCalculator(IFeeCalculator _feeCalculator) external onlyOwner {
        feeCalculator = _feeCalculator;
    }


    function addWhitelistedOptionContracts(address[] memory _addr) external onlyOwner {
        for (uint256 i=0; i < _addr.length; i++) {
            _whitelistedOptionContracts.add(_addr[i]);
        }
    }

    function removeWhitelistedOptionContracts(address[] memory _addr) external onlyOwner {
        for (uint256 i=0; i < _addr.length; i++) {
            _whitelistedOptionContracts.remove(_addr[i]);
        }
    }

    function addWhitelistedPaymentTokens(address[] memory _addr) external onlyOwner {
        for (uint256 i=0; i < _addr.length; i++) {
            uint8 decimals = IERC20Extended(_addr[i]).decimals();
            require(decimals <= 18, "Too many decimals");
            _whitelistedPaymentTokens.add(_addr[i]);
            paymentTokenDecimals[_addr[i]] = decimals;
        }
    }
    function removeWhitelistedPaymentTokens(address[] memory _addr) external onlyOwner {
        for (uint256 i=0; i < _addr.length; i++) {
            _whitelistedPaymentTokens.remove(_addr[i]);
        }
    }

    function setDelayedWritingEnabled(bool _state) external onlyOwner {
        isDelayedWritingEnabled = _state;
    }



    function getAmountsBatch(bytes32[] memory _orderIds) external view returns(uint256[] memory) {
        uint256[] memory result = new uint256[](_orderIds.length);

        for (uint256 i=0; i < _orderIds.length; i++) {
            result[i] = amounts[_orderIds[i]];
        }

        return result;
    }

    function getOrderHashBatch(Order[] memory _orders) external pure returns(bytes32[] memory) {
        bytes32[] memory result = new bytes32[](_orders.length);

        for (uint256 i=0; i < _orders.length; i++) {
            result[i] = getOrderHash(_orders[i]);
        }

        return result;
    }

    function getOrderHash(Order memory _order) public pure returns(bytes32) {
        return keccak256(abi.encode(_order));
    }

    function getWhitelistedOptionContracts() external view returns(address[] memory) {
        uint256 length = _whitelistedOptionContracts.length();
        address[] memory result = new address[](length);

        for (uint256 i=0; i < length; i++) {
            result[i] = _whitelistedOptionContracts.at(i);
        }

        return result;
    }

    function getWhitelistedPaymentTokens() external view returns(address[] memory) {
        uint256 length = _whitelistedPaymentTokens.length();
        address[] memory result = new address[](length);

        for (uint256 i=0; i < length; i++) {
            result[i] = _whitelistedPaymentTokens.at(i);
        }

        return result;
    }

    function isOrderValid(Order memory _order) public view returns(bool) {
        bytes32 hash = getOrderHash(_order);
        uint256 amountLeft = amounts[hash];

        if (amountLeft == 0) return false;

        if (_order.expirationTime == 0 || block.timestamp > _order.expirationTime) return false;

        IERC20 token = IERC20(_order.paymentToken);

        if (_order.side == SaleSide.Buy) {
            uint8 decimals = _order.decimals;
            uint256 basePrice = _order.pricePerUnit.mul(amountLeft).div(10**decimals);
            uint256 makerFee = feeCalculator.getFee(_order.maker, false, IFeeCalculator.FeeType.Maker);
            uint256 orderMakerFee = basePrice.mul(makerFee).div(_inverseBasisPoint);
            uint256 totalPrice = basePrice.add(orderMakerFee);

            uint256 userBalance = token.balanceOf(_order.maker);
            uint256 allowance = token.allowance(_order.maker, address(this));

            return userBalance >= totalPrice && allowance >= totalPrice;
        } else if (_order.side == SaleSide.Sell) {
            IPremiaOption premiaOption = IPremiaOption(_order.optionContract);
            bool isApproved = premiaOption.isApprovedForAll(_order.maker, address(this));

            if (_order.isDelayedWriting) {
                IPremiaOption.OptionData memory data = premiaOption.optionData(_order.optionId);
                IPremiaOption.OptionWriteArgs memory writeArgs = IPremiaOption.OptionWriteArgs({
                    token: data.token,
                    amount: amountLeft,
                    strikePrice: data.strikePrice,
                    expiration: data.expiration,
                    isCall: data.isCall
                });

                IPremiaOption.QuoteWrite memory quote = premiaOption.getWriteQuote(_order.maker, writeArgs, address(0), _order.decimals);

                uint256 userBalance = IERC20(quote.collateralToken).balanceOf(_order.maker);
                uint256 allowance = IERC20(quote.collateralToken).allowance(_order.maker, _order.optionContract);
                uint256 totalPrice = quote.collateral.add(quote.fee).add(quote.feeReferrer);

                return isApproved && userBalance >= totalPrice && allowance >= totalPrice;

            } else {
                uint256 optionBalance = premiaOption.balanceOf(_order.maker, _order.optionId);
                return isApproved && optionBalance >= amountLeft;
            }
        }

        return false;
    }

    function areOrdersValid(Order[] memory _orders) external view returns(bool[] memory) {
        bool[] memory result = new bool[](_orders.length);

        for (uint256 i=0; i < _orders.length; i++) {
            result[i] = isOrderValid(_orders[i]);
        }

        return result;
    }



    function claimUPremia() external {
        uint256 amount = uPremiaBalance[msg.sender];
        uPremiaBalance[msg.sender] = 0;
        IERC20(address(uPremia)).safeTransfer(msg.sender, amount);
    }

    function createOrder(Order memory _order, uint256 _amount) public returns(bytes32) {
        require(_whitelistedOptionContracts.contains(_order.optionContract), "Option contract not whitelisted");
        require(_whitelistedPaymentTokens.contains(_order.paymentToken), "Payment token not whitelisted");

        IPremiaOption.OptionData memory data = IPremiaOption(_order.optionContract).optionData(_order.optionId);
        require(data.strikePrice > 0, "Option not found");
        require(block.timestamp < data.expiration, "Option expired");

        _order.maker = msg.sender;
        _order.expirationTime = data.expiration;
        _order.decimals = data.decimals;
        _order.salt = salt;

        require(_order.decimals <= 18, "Too many decimals");

        if (_order.isDelayedWriting) {
            require(isDelayedWritingEnabled, "Delayed writing disabled");
        }

        if (_order.side == SaleSide.Buy) {
            _order.isDelayedWriting = false;
        }

        salt = salt.add(1);

        bytes32 hash = getOrderHash(_order);
        amounts[hash] = _amount;
        uint8 decimals = _order.decimals;

        emit OrderCreated(
            hash,
            _order.maker,
            _order.optionContract,
            _order.side,
            _order.isDelayedWriting,
            _order.optionId,
            _order.paymentToken,
            _order.pricePerUnit,
            _order.expirationTime,
            _order.salt,
            _amount,
            decimals
        );

        return hash;
    }

    function createOrderForNewOption(Order memory _order, uint256 _amount, Option memory _option, address _referrer) external returns(bytes32) {
        if (address(premiaReferral) != address(0) && _order.isDelayedWriting && _order.side == SaleSide.Sell) {
            _referrer = premiaReferral.trySetReferrer(msg.sender, _referrer);
        }

        _order.optionId = IPremiaOption(_order.optionContract).getOptionIdOrCreate(_option.token, _option.expiration, _option.strikePrice, _option.isCall);
        return createOrder(_order, _amount);
    }

    function createOrders(Order[] memory _orders, uint256[] memory _amounts) external returns(bytes32[] memory) {
        require(_orders.length == _amounts.length, "Arrays must have same length");

        bytes32[] memory result = new bytes32[](_orders.length);

        for (uint256 i=0; i < _orders.length; i++) {
            result[i] = createOrder(_orders[i], _amounts[i]);
        }

        return result;
    }

    function createOrderAndTryToFill(Order memory _order, uint256 _amount, Order[] memory _orderCandidates, bool _writeOnBuyFill, address _referrer) external {
        require(_amount > 0, "Amount must be > 0");

        for (uint256 i=0; i < _orderCandidates.length; i++) {
            require(_orderCandidates[i].side != _order.side, "Candidate order : Same order side");
            require(_orderCandidates[i].optionContract == _order.optionContract, "Candidate order : Diff option contract");
            require(_orderCandidates[i].optionId == _order.optionId, "Candidate order : Diff optionId");
        }

        uint256 totalFilled;
        if (_orderCandidates.length == 1) {
            totalFilled = fillOrder(_orderCandidates[0], _amount, _writeOnBuyFill, _referrer);
        } else if (_orderCandidates.length > 1) {
            totalFilled = fillOrders(_orderCandidates, _amount, _writeOnBuyFill, _referrer);
        }

        if (totalFilled < _amount) {
            createOrder(_order, _amount.sub(totalFilled));
        }
    }

    function writeAndCreateOrder(IPremiaOption.OptionWriteArgs memory _option, Order memory _order, address _referrer) public returns(bytes32) {
        require(_order.side == SaleSide.Sell, "Not a sell order");

        _order.isDelayedWriting = false;

        IPremiaOption optionContract = IPremiaOption(_order.optionContract);
        _order.optionId = optionContract.writeOptionFrom(msg.sender, _option, _referrer);

        return createOrder(_order, _option.amount);
    }

    function fillOrder(Order memory _order, uint256 _amount, bool _writeOnBuyFill, address _referrer) public nonReentrant returns(uint256) {
        bytes32 hash = getOrderHash(_order);

        require(_order.expirationTime != 0 && block.timestamp < _order.expirationTime, "Order expired");
        require(amounts[hash] > 0, "Order not found");
        require(_amount > 0, "Amount must be > 0");

        if (amounts[hash] < _amount) {
            _amount = amounts[hash];
        }

        amounts[hash] = amounts[hash].sub(_amount);

        if (_order.side == SaleSide.Sell && _order.isDelayedWriting) {
            IPremiaOption(_order.optionContract).writeOptionWithIdFrom(_order.maker, _order.optionId, _amount, address(0));
        } else if (_order.side == SaleSide.Buy && _writeOnBuyFill) {
            IPremiaOption(_order.optionContract).writeOptionWithIdFrom(msg.sender, _order.optionId, _amount, _referrer);
        }

        uint256 basePrice = _order.pricePerUnit.mul(_amount).div(10**_order.decimals);

        (uint256 orderMakerFee,) = feeCalculator.getFeeAmounts(_order.maker, false, basePrice, IFeeCalculator.FeeType.Maker);
        (uint256 orderTakerFee,) = feeCalculator.getFeeAmounts(msg.sender, false, basePrice, IFeeCalculator.FeeType.Taker);

        if (_order.side == SaleSide.Buy) {
            IPremiaOption(_order.optionContract).safeTransferFrom(msg.sender, _order.maker, _order.optionId, _amount, "");

            IERC20(_order.paymentToken).safeTransferFrom(_order.maker, feeRecipient, orderMakerFee.add(orderTakerFee));
            IERC20(_order.paymentToken).safeTransferFrom(_order.maker, msg.sender, basePrice.sub(orderTakerFee));

        } else {
            IERC20(_order.paymentToken).safeTransferFrom(msg.sender, feeRecipient, orderMakerFee.add(orderTakerFee));
            IERC20(_order.paymentToken).safeTransferFrom(msg.sender, _order.maker, basePrice.sub(orderMakerFee));

            IPremiaOption(_order.optionContract).safeTransferFrom(_order.maker, msg.sender, _order.optionId, _amount, "");
        }

        if (address(uPremia) != address(0)) {
            uint256 paymentTokenPrice = uPremia.getTokenPrice(_order.paymentToken);

            uPremiaBalance[_order.maker] = uPremiaBalance[_order.maker].add(orderMakerFee.mul(paymentTokenPrice).div(10**paymentTokenDecimals[_order.paymentToken]));
            uPremiaBalance[msg.sender] = uPremiaBalance[msg.sender].add(orderTakerFee.mul(paymentTokenPrice).div(10**paymentTokenDecimals[_order.paymentToken]));

            uPremia.mint(address(this), orderMakerFee.add(orderTakerFee).mul(paymentTokenPrice).div(10**paymentTokenDecimals[_order.paymentToken]));
        }

        emit OrderFilled(
            hash,
            msg.sender,
            _order.optionContract,
            _order.maker,
            _order.paymentToken,
            _amount,
            _order.pricePerUnit
        );

        return _amount;
    }


    function fillOrders(Order[] memory _orders, uint256 _maxAmount, bool _writeOnBuyFill, address _referrer) public nonReentrant returns(uint256) {
        if (_maxAmount == 0) return 0;

        uint256 takerFee = feeCalculator.getFee(msg.sender, false, IFeeCalculator.FeeType.Taker);

        if (_orders.length > 1) {
            for (uint256 i=0; i < _orders.length; i++) {
                require(i == 0 || _orders[0].paymentToken == _orders[i].paymentToken, "Different payment tokens");
                require(i == 0 || _orders[0].side == _orders[i].side, "Different order side");
                require(i == 0 || _orders[0].optionContract == _orders[i].optionContract, "Different option contract");
                require(i == 0 || _orders[0].optionId == _orders[i].optionId, "Different option id");
            }
        }

        uint256 paymentTokenPrice;
        if (address(uPremia) != address(0)) {
            uPremia.getTokenPrice(_orders[0].paymentToken);
        }

        uint256 totalFee;
        uint256 totalAmount;
        uint256 amountFilled;

        for (uint256 i=0; i < _orders.length; i++) {
            if (amountFilled >= _maxAmount) break;

            Order memory _order = _orders[i];
            bytes32 hash = getOrderHash(_order);

            if (amounts[hash] == 0) continue;
            if (block.timestamp >= _order.expirationTime) continue;

            uint256 amount = amounts[hash];
            if (amountFilled.add(amount) > _maxAmount) {
                amount = _maxAmount.sub(amountFilled);
            }

            amounts[hash] = amounts[hash].sub(amount);
            amountFilled = amountFilled.add(amount);

            if (_order.side == SaleSide.Sell && _order.isDelayedWriting) {
                IPremiaOption(_order.optionContract).writeOptionWithIdFrom(_order.maker, _order.optionId, amount, address(0));
            } else if (_order.side == SaleSide.Buy && _writeOnBuyFill) {
                IPremiaOption(_order.optionContract).writeOptionWithIdFrom(msg.sender, _order.optionId, amount, _referrer);
            }

            uint256 basePrice = _order.pricePerUnit.mul(amount).div(10**_order.decimals);

            (uint256 orderMakerFee,) = feeCalculator.getFeeAmounts(_order.maker, false, basePrice, IFeeCalculator.FeeType.Maker);
            uint256 orderTakerFee = basePrice.mul(takerFee).div(_inverseBasisPoint);

            totalFee = totalFee.add(orderMakerFee).add(orderTakerFee);

            if (_order.side == SaleSide.Buy) {
                IPremiaOption(_order.optionContract).safeTransferFrom(msg.sender, _order.maker, _order.optionId, amount, "");

                IERC20(_order.paymentToken).safeTransferFrom(_order.maker, address(this), basePrice.add(orderMakerFee));
                totalAmount = totalAmount.add(basePrice.add(orderMakerFee));

            } else {
                IERC20(_order.paymentToken).safeTransferFrom(msg.sender, _order.maker, basePrice.sub(orderMakerFee));
                IPremiaOption(_order.optionContract).safeTransferFrom(_order.maker, msg.sender, _order.optionId, amount, "");
            }

            if (address(uPremia) != address(0)) {
                uPremiaBalance[_order.maker] = uPremiaBalance[_order.maker].add(orderMakerFee.mul(paymentTokenPrice).div(10**paymentTokenDecimals[_order.paymentToken]));
                uPremiaBalance[msg.sender] = uPremiaBalance[msg.sender].add(orderTakerFee.mul(paymentTokenPrice).div(10**paymentTokenDecimals[_order.paymentToken]));
            }

            emit OrderFilled(
                hash,
                msg.sender,
                _order.optionContract,
                _order.maker,
                _order.paymentToken,
                amount,
                _order.pricePerUnit
            );
        }

        if (_orders[0].side == SaleSide.Buy) {
            IERC20(_orders[0].paymentToken).safeTransfer(feeRecipient, totalFee);
            IERC20(_orders[0].paymentToken).safeTransfer(msg.sender, totalAmount.sub(totalFee));
        } else {
            IERC20(_orders[0].paymentToken).safeTransferFrom(msg.sender, feeRecipient, totalFee);
        }

        if (address(uPremia) != address(0)) {
            uPremia.mint(address(this), totalFee.mul(paymentTokenPrice).div(10**paymentTokenDecimals[_orders[0].paymentToken]));
        }

        return amountFilled;
    }

    function cancelOrder(Order memory _order) public {
        bytes32 hash = getOrderHash(_order);
        uint256 amountLeft = amounts[hash];

        require(amountLeft > 0, "Order not found");
        require(_order.maker == msg.sender, "Not order maker");
        delete amounts[hash];

        emit OrderCancelled(
            hash,
            _order.maker,
            _order.optionContract,
            _order.paymentToken,
            amountLeft,
            _order.pricePerUnit
        );
    }

    function cancelOrders(Order[] memory _orders) external {
        for (uint256 i=0; i < _orders.length; i++) {
            cancelOrder(_orders[i]);
        }
    }
}