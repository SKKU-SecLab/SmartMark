
pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}// MIT

pragma solidity ^0.8.0;


abstract contract Ownable is Context {
    address private _owner;

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
}// MIT

pragma solidity ^0.8.0;

abstract contract ReentrancyGuard {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
    }
}// MIT

pragma solidity ^0.8.0;

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
}// MIT

pragma solidity ^0.8.0;

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
}// MIT

pragma solidity ^0.8.0;


library SafeMath {

    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        return a + b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        return a * b;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        return a % b;
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}pragma solidity >=0.5.0;

interface IUniswapV2Factory {

    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);

    function feeToSetter() external view returns (address);


    function getPair(address tokenA, address tokenB) external view returns (address pair);

    function allPairs(uint) external view returns (address pair);

    function allPairsLength() external view returns (uint);


    function createPair(address tokenA, address tokenB) external returns (address pair);


    function setFeeTo(address) external;

    function setFeeToSetter(address) external;

}pragma solidity >=0.5.0;

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


    function initialize(address, address) external;

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

}/**

Aspen: The Ultimate NFT Platform
Have fun growing your portfolio
https://aspenft.io

*/

pragma solidity ^0.8.0;


contract Aspen is Context, IERC20, Ownable, ReentrancyGuard {

    using SafeMath for uint256;
    using Address for address;

    string private constant _name = "Aspen";
    string private constant _symbol = "Aspen";
    uint8 private constant _decimals = 18;

    uint256 private constant MAX = ~uint256(0);
    uint256 private constant _totalTokenSupply = 1 * 10**12 * 10**_decimals;
    uint256 private _totalReflections = (MAX - (MAX % _totalTokenSupply));
    uint256 private _totalTaxesReflectedToHodlers;
    uint256 private _totalTaxesSentToTreasury;
    mapping(address => uint256) private _reflectionsOwned;
    mapping(address => mapping(address => uint256)) private _allowances;

    address payable public _treasuryAddress;
    uint256 private _currentTaxForReflections = 0; // modified depending on context of tx
    uint256 private _currentTaxForTreasury = 0; // modified depending on context of tx
    uint256 public _fixedTaxForReflections = 0; // unchanged save by owner transaction
    uint256 public _fixedTaxForTreasury = 0; // unchanged save by owner transaction

    mapping(address => bool) private _isExcludedFromTaxes;

    address private constant uniDefault =
        0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
    IUniswapV2Router02 public immutable uniswapV2Router;
    bool private _inSwap = false;
    address public immutable uniswapV2Pair;

    uint256 private constant _minimumTokensToSwap = 10 * 10**3 * 10**_decimals;

    event TreasuryAddressSet(address indexed _to);
    event ExcludedFromTaxes(address indexed _to, bool indexed _excluded);
    event ReflectionTaxesModified(uint256 indexed _tax);
    event TreasuryTaxesModified(uint256 indexed _tax);

    modifier lockTheSwap() {

        _inSwap = true;
        _;
        _inSwap = false;
    }

    constructor(address payable treasuryAddress, address router) {
        require(
            (treasuryAddress != address(0)),
            "Give me the treasury address"
        );
        _treasuryAddress = treasuryAddress;
        _reflectionsOwned[_msgSender()] = _totalReflections;

        if (router == address(0)) {
            router = uniDefault;
        }
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(router);

        address _uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), _uniswapV2Router.WETH());
        uniswapV2Pair = _uniswapV2Pair;
        uniswapV2Router = _uniswapV2Router;

        _isExcludedFromTaxes[owner()] = true;
        _isExcludedFromTaxes[address(this)] = true;
        _isExcludedFromTaxes[_treasuryAddress] = true;

        emit Transfer(address(0), _msgSender(), _totalTokenSupply);
    }

    receive() external payable {
        return;
    }

    function setTreasuryAddress(address payable treasuryAddress) external {

        require(
            _msgSender() == _treasuryAddress,
            "You are not the treasury address"
        );
        require(
            (treasuryAddress != address(0)),
            "Give me the treasury address"
        );
        address _previousTreasuryAddress = _treasuryAddress;
        _treasuryAddress = treasuryAddress;
        _isExcludedFromTaxes[treasuryAddress] = true;
        _isExcludedFromTaxes[_previousTreasuryAddress] = false;
        emit TreasuryAddressSet(treasuryAddress);
    }

    function excludeFromTaxes(address account, bool excluded)
        external
        onlyOwner
    {

        _isExcludedFromTaxes[account] = excluded;
        emit ExcludedFromTaxes(account, excluded);
    }

    function setReflectionsTax(uint256 tax) external onlyOwner {

        require(tax <= 10, "ERC20: tax out of band");
        _currentTaxForReflections = tax;
        _fixedTaxForReflections = tax;
        emit ReflectionTaxesModified(tax);
    }

    function setTreasuryTax(uint256 tax) external onlyOwner {

        require(tax <= 10, "ERC20: tax out of band");
        _currentTaxForTreasury = tax;
        _fixedTaxForTreasury = tax;
        emit TreasuryTaxesModified(tax);
    }

    function manualSend() external onlyOwner {

        uint256 _contractETHBalance = address(this).balance;
        _sendETHToTreasury(_contractETHBalance);
    }

    function manualSwap() external onlyOwner {

        uint256 _contractBalance = balanceOf(address(this));
        _swapTokensForETH(_contractBalance);
    }

    function transfer(address recipient, uint256 amount)
        public
        override
        returns (bool)
    {

        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function approve(address spender, uint256 amount)
        public
        override
        returns (bool)
    {

        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override returns (bool) {

        _transfer(sender, recipient, amount);
        _approve(
            sender,
            _msgSender(),
            _allowances[sender][_msgSender()].sub(
                amount,
                "ERC20: transfer amount exceeds allowance"
            )
        );
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue)
        public
        virtual
        returns (bool)
    {

        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender].add(addedValue)
        );
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        virtual
        returns (bool)
    {

        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender].sub(
                subtractedValue,
                "ERC20: decreased allowance below zero"
            )
        );
        return true;
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

        uint256 currentRate = _getRate();
        return _totalReflections.div(currentRate);
    }

    function isExcludedFromTaxes(address account) public view returns (bool) {

        return _isExcludedFromTaxes[account];
    }

    function totalTaxesSentToReflections() public view returns (uint256) {

        return tokensFromReflection(_totalTaxesReflectedToHodlers);
    }

    function totalTaxesSentToTreasury() public view returns (uint256) {

        return tokensFromReflection(_totalTaxesSentToTreasury);
    }

    function getETHBalance() public view returns (uint256 balance) {

        return address(this).balance;
    }

    function allowance(address owner, address spender)
        public
        view
        override
        returns (uint256)
    {

        return _allowances[owner][spender];
    }

    function balanceOf(address account) public view override returns (uint256) {

        return tokensFromReflection(_reflectionsOwned[account]);
    }

    function reflectionFromToken(
        uint256 amountOfTokens,
        bool deductTaxForReflections
    ) public view returns (uint256) {

        require(
            amountOfTokens <= _totalTokenSupply,
            "Amount must be less than supply"
        );
        if (!deductTaxForReflections) {
            (uint256 reflectionsToDebit, , , ) = _getValues(amountOfTokens);
            return reflectionsToDebit;
        } else {
            (, uint256 reflectionsToCredit, , ) = _getValues(amountOfTokens);
            return reflectionsToCredit;
        }
    }

    function tokensFromReflection(uint256 amountOfReflections)
        public
        view
        returns (uint256)
    {

        require(
            amountOfReflections <= _totalReflections,
            "ERC20: Amount too large"
        );
        uint256 currentRate = _getRate();
        return amountOfReflections.div(currentRate);
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) private {

        require(owner != address(0), "ERC20: approve from 0 address");
        require(spender != address(0), "ERC20: approve to 0 address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amountOfTokens
    ) private nonReentrant {

        require(sender != address(0), "ERC20: transfer from 0 address");
        require(recipient != address(0), "ERC20: transfer to 0 address");
        require(amountOfTokens > 0, "ERC20: Transfer more than zero");

        bool takeFee = true;
        if (_isExcludedFromTaxes[sender] || _isExcludedFromTaxes[recipient]) {
            takeFee = false;
        }

        bool buySide = false;
        if (sender == address(uniswapV2Pair)) {
            buySide = true;
        }

        if (!takeFee) {
            _setNoFees();
        } else if (buySide) {
            _setBuySideFees();
        } else {
            _setSellSideFees();
        }

        _tokenTransfer(sender, recipient, amountOfTokens);

        _restoreAllFees();
    }

    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 amountOfTokens
    ) private {

        if (sender == _treasuryAddress && recipient == address(this)) {
            _manualReflect(amountOfTokens);
            return;
        }

        (
            uint256 reflectionsToDebit, // sender
            uint256 reflectionsToCredit, // recipient
            uint256 reflectionsToRemove, // to all the hodlers
            uint256 reflectionsForTreasury // to treasury
        ) = _getValues(amountOfTokens);

        _reflectionsOwned[sender] = _reflectionsOwned[sender].sub(
            reflectionsToDebit
        );
        _reflectionsOwned[recipient] = _reflectionsOwned[recipient].add(
            reflectionsToCredit
        );

        _takeTreasuryTax(reflectionsForTreasury);
        _takeReflectionTax(reflectionsToRemove);

        uint256 contractTokenBalance = balanceOf(address(this));
        bool overMinTokenBalance = contractTokenBalance >= _minimumTokensToSwap;
        if (!_inSwap && overMinTokenBalance && reflectionsForTreasury != 0) {
            _swapTokensForETH(contractTokenBalance);
        }
        uint256 contractETHBalance = address(this).balance;
        if (contractETHBalance > 0) {
            _sendETHToTreasury(address(this).balance);
        }

        emit Transfer(sender, recipient, reflectionsToCredit.div(_getRate()));
    }

    function _manualReflect(uint256 amountOfTokens) private {

        uint256 currentRate = _getRate();
        uint256 amountOfReflections = amountOfTokens.mul(currentRate);

        _reflectionsOwned[_treasuryAddress] = _reflectionsOwned[
            _treasuryAddress
        ].sub(amountOfReflections);
        _totalReflections = _totalReflections.sub(amountOfReflections);
    }

    function _takeTreasuryTax(uint256 reflectionsForTreasury) private {

        _reflectionsOwned[address(this)] = _reflectionsOwned[address(this)].add(
            reflectionsForTreasury
        );
        _totalTaxesSentToTreasury = _totalTaxesSentToTreasury.add(
            reflectionsForTreasury
        );
    }

    function _takeReflectionTax(uint256 reflectionsToRemove) private {

        _totalReflections = _totalReflections.sub(reflectionsToRemove);
        _totalTaxesReflectedToHodlers = _totalTaxesReflectedToHodlers.add(
            reflectionsToRemove
        );
    }

    function _swapTokensForETH(uint256 tokenAmount) private lockTheSwap {

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();

        _approve(address(this), address(uniswapV2Router), tokenAmount);

        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            address(_treasuryAddress),
            block.timestamp
        );
    }

    function _sendETHToTreasury(uint256 amount) private {

        (bool success, ) = _treasuryAddress.call{value: amount}("");
        require(success == true, "send eth to treasury failed");
    }

    function _setBuySideFees() private {

        _currentTaxForReflections = _fixedTaxForReflections;
        _currentTaxForTreasury = 0;
    }

    function _setSellSideFees() private {

        _currentTaxForReflections = 0;
        _currentTaxForTreasury = _fixedTaxForTreasury;
    }

    function _setNoFees() private {

        _currentTaxForReflections = 0;
        _currentTaxForTreasury = 0;
    }

    function _restoreAllFees() private {

        _currentTaxForReflections = _fixedTaxForReflections;
        _currentTaxForTreasury = _fixedTaxForTreasury;
    }

    function _getValues(uint256 amountOfTokens)
        private
        view
        returns (
            uint256,
            uint256,
            uint256,
            uint256
        )
    {

        (
            uint256 tokensToTransfer,
            uint256 tokensForReflections,
            uint256 tokensForTreasury
        ) = _getTokenValues(amountOfTokens);

        uint256 currentRate = _getRate();
        uint256 reflectionsTotal = amountOfTokens.mul(currentRate);
        uint256 reflectionsToTransfer = tokensToTransfer.mul(currentRate);
        uint256 reflectionsToRemove = tokensForReflections.mul(currentRate);
        uint256 reflectionsForTreasury = tokensForTreasury.mul(currentRate);

        return (
            reflectionsTotal,
            reflectionsToTransfer,
            reflectionsToRemove,
            reflectionsForTreasury
        );
    }

    function _getRate() private view returns (uint256) {

        return _totalReflections.div(_totalTokenSupply);
    }

    function _getTokenValues(uint256 amountOfTokens)
        private
        view
        returns (
            uint256,
            uint256,
            uint256
        )
    {

        uint256 tokensForReflections = amountOfTokens
            .mul(_currentTaxForReflections)
            .div(100);
        uint256 tokensForTreasury = amountOfTokens
            .mul(_currentTaxForTreasury)
            .div(100);
        uint256 tokensToTransfer = amountOfTokens.sub(tokensForReflections).sub(
            tokensForTreasury
        );
        return (tokensToTransfer, tokensForReflections, tokensForTreasury);
    }
}