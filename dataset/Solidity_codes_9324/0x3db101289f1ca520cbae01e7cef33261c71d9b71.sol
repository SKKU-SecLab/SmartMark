
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
}// Unlicensed

pragma solidity >=0.5.0;

interface IUniswapV2Factory {

    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);

    function feeToSetter() external view returns (address);

    function migrator() external view returns (address);


    function getPair(address tokenA, address tokenB) external view returns (address pair);

    function allPairs(uint) external view returns (address pair);

    function allPairsLength() external view returns (uint);


    function createPair(address tokenA, address tokenB) external returns (address pair);


    function setFeeTo(address) external;

    function setFeeToSetter(address) external;

    function setMigrator(address) external;

}// Unlicensed

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

}// Unlicensed

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

}// Unlicensed

pragma solidity >=0.5.0;

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

}// Unlicensed

pragma solidity >=0.5.0;

interface IWETH {

    function deposit() external payable;

    function transfer(address to, uint value) external returns (bool);

    function withdraw(uint) external;

}// Unlicensed

pragma solidity ^0.6.2;


contract DRF is Context, IERC20, Ownable {

    using SafeMath for uint256;
    using Address for address;

    mapping(address => uint256) private _rOwned;
    mapping(address => uint256) private _tOwned;
    mapping(address => mapping(address => uint256)) private _allowances;

    mapping(address => bool) private _isReflectExcluded;
    address[] private _reflectExcluded;
    mapping(address => bool) private _isNoFee;
    mapping(address => bool) private _transferPairAddress;
    uint256 private constant MAX = uint256(- 1);
    uint256 private constant _tTotal = 10000000e18;
    uint256 private _rTotal = (MAX - (MAX % _tTotal));
    uint256 private _tFeeTotal;

    enum TransferState {Normal, Buy, Sell}

    uint256 public principalSupply;
    uint256 public reserveSupply;
    uint256 public bonusSupply;

    uint256 public reflectFeeDenominator = 67;
    uint256 public buyTxFeeDenominator = 200;
    uint256 public sellTxFeeDenominator = 200;
    uint256 public buyBonusDenominator = 25;
    uint256 public sellFeeDenominator = 50;

    uint256 public restrictBuyAmount = 8000e18;

    address public lord;
    address public pairAddress;

    struct TValues {
        uint256 amount;
        uint256 transferAmount;
        uint256 fee;
        uint256 txFee;
        uint256 sellFee;
        uint256 buyBonus;
    }

    struct RValues {
        uint256 amount;
        uint256 transferAmount;
        uint256 fee;
        uint256 txFee;
        uint256 sellFee;
        uint256 buyBonus;
    }

    string private _name = 'drift.finance';
    string private _symbol = 'DRF';
    uint8 private _decimals = 18;

    constructor () public {
    }

    receive() external payable {
    }


    modifier onlyLord {

        require(_msgSender() == lord, "Lord only");
        _;
    }


    function init(address _lord, address _pairAddress) external onlyOwner {

        if (lord == address(0)) {
            lord = _lord;
            pairAddress = _pairAddress;

            _rOwned[lord] = _rTotal;
            setNoFee(lord, true);
            excludeReflectAccount(lord);
            excludeReflectAccount(pairAddress);

            setTransferPairAddress(pairAddress, true);

            setNoFee(address(this), true);
        }
    }

    function setNoFee(address account, bool value) public onlyOwner {

        _isNoFee[account] = value;
    }

    function setTransferPairAddress(address transferPairAddress, bool value) public onlyOwner {

        _transferPairAddress[transferPairAddress] = value;
    }

    function setRestrictBuyAmount(uint256 amount) external onlyOwner {

        restrictBuyAmount = amount;
    }

    function excludeReflectAccount(address account) public onlyOwner {

        require(!_isReflectExcluded[account], "Already excluded");
        if (_rOwned[account] > 0) {
            _tOwned[account] = tokenFromReflection(_rOwned[account]);
        }
        _isReflectExcluded[account] = true;
        _reflectExcluded.push(account);
    }

    function includeReflectAccount(address account) public onlyOwner {

        require(_isReflectExcluded[account], "Already included");
        for (uint256 i = 0; i < _reflectExcluded.length; i++) {
            if (_reflectExcluded[i] == account) {
                _reflectExcluded[i] = _reflectExcluded[_reflectExcluded.length - 1];
                _tOwned[account] = 0;
                _isReflectExcluded[account] = false;
                _reflectExcluded.pop();
                break;
            }
        }
    }


    function setFee(
        uint256 _reflectFeeDenominator,
        uint256 _buyTxFeeDenominator,
        uint256 _sellTxFeeDenominator,
        uint256 _buyBonusDenominator,
        uint256 _sellFeeDenominator
    ) external onlyLord {

        reflectFeeDenominator = _reflectFeeDenominator;
        buyTxFeeDenominator = _buyTxFeeDenominator;
        sellTxFeeDenominator = _sellTxFeeDenominator;
        buyBonusDenominator = _buyBonusDenominator;
        sellFeeDenominator = _sellFeeDenominator;
    }

    function setReserveSupply(uint256 amount) external onlyLord {

        reserveSupply = amount;
    }

    function depositPrincipalSupply(uint256 amount) external onlyLord {

        principalSupply = amount;
        _transferFromExcluded(lord, address(this), principalSupply, false, TransferState.Normal);
    }

    function withdrawPrincipalSupply() external onlyLord returns(uint256) {

        _transferToExcluded(address(this), lord, balanceOf(address(this)), false, TransferState.Normal);
        return principalSupply;
    }

    function distributePrincipalRewards(address rewardPairAddress) external onlyLord {

        uint256 balance = balanceOf(address(this));
        if (balance > 0) {
            uint256 reward = balance.sub(principalSupply);
            if (rewardPairAddress != address(0)) {
                _transferToExcluded(address(this), rewardPairAddress, reward, false, TransferState.Normal);
                IUniswapV2Pair(rewardPairAddress).sync();
            }
            else {
                _transferToExcluded(address(this), lord, reward, false, TransferState.Normal);
                reserveSupply = reserveSupply.add(reward);
            }
        }
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

        return _tTotal;
    }

    function circulatingSupply() public view returns (uint256) {

        return _tTotal.sub(balanceOf(address(this))).sub(balanceOf(lord));
    }

    function balanceOf(address account) public view override returns (uint256) {

        if (_isReflectExcluded[account]) return _tOwned[account];
        return tokenFromReflection(_rOwned[account]);
    }

    function isExcluded(address account) public view returns (bool) {

        return _isReflectExcluded[account];
    }

    function totalFees() public view returns (uint256) {

        return _tFeeTotal;
    }

    function reflectionFromToken(uint256 tAmount, bool deductTransferFee, TransferState transferState) public view returns (uint256) {

        require(tAmount <= _tTotal, "Amount must be less than supply");
        if (!deductTransferFee) {
            (RValues memory r,) = _getValues(tAmount, true, transferState);
            return r.amount;
        } else {
            (RValues memory r,) = _getValues(tAmount, true, transferState);
            return r.transferAmount;
        }
    }

    function tokenFromReflection(uint256 rAmount) public view returns (uint256) {

        require(rAmount <= _rTotal, "Amount must be less than total reflections");
        uint256 currentRate = _getRate();
        return rAmount.div(currentRate);
    }


    function transfer(address recipient, uint256 amount) public override returns (bool) {

        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {

        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {

        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {

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

    function reflect(uint256 tAmount) public {

        address sender = _msgSender();
        require(!_isReflectExcluded[sender], "Excluded addresses cannot call this function");
        (RValues memory r,) = _getValues(tAmount, !_isNoFee[sender], TransferState.Normal);
        _rOwned[sender] = _rOwned[sender].sub(r.amount);
        _rTotal = _rTotal.sub(r.amount);
        _tFeeTotal = _tFeeTotal.add(tAmount);
    }


    function _approve(address owner, address spender, uint256 amount) private {

        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(address sender, address recipient, uint256 amount) private {

        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Invalid amount");

        bool hasFee = !_isNoFee[sender] && !_isNoFee[recipient];
        TransferState transferState;
        if (_transferPairAddress[sender]) {
            transferState = TransferState.Buy;
        } else if (_transferPairAddress[recipient]) {
            transferState = TransferState.Sell;
        }
        if (restrictBuyAmount > 0 && transferState == TransferState.Buy && hasFee) {
            require(amount <= restrictBuyAmount, "Buy restricted");
        }
        if (_isReflectExcluded[sender] && !_isReflectExcluded[recipient]) {
            _transferFromExcluded(sender, recipient, amount, hasFee, transferState);
        } else if (!_isReflectExcluded[sender] && _isReflectExcluded[recipient]) {
            _transferToExcluded(sender, recipient, amount, hasFee, transferState);
        } else if (!_isReflectExcluded[sender] && !_isReflectExcluded[recipient]) {
            _transferStandard(sender, recipient, amount, hasFee, transferState);
        } else if (_isReflectExcluded[sender] && _isReflectExcluded[recipient]) {
            _transferBothExcluded(sender, recipient, amount, hasFee, transferState);
        } else {
            _transferStandard(sender, recipient, amount, hasFee, transferState);
        }
    }

    function _transferStandard(address sender, address recipient, uint256 tAmount, bool hasFee, TransferState transferState) private {

        (RValues memory r, TValues memory t) = _getValues(tAmount, hasFee, transferState);
        _rOwned[sender] = _rOwned[sender].sub(r.amount);
        _rOwned[recipient] = _rOwned[recipient].add(r.transferAmount.add(r.buyBonus));

        _tOwned[lord] = _tOwned[lord].add(t.txFee.add(t.sellFee)).sub(t.buyBonus);
        _rOwned[lord] = _rOwned[lord].add(r.txFee.add(r.sellFee)).sub(r.buyBonus);
        reserveSupply = reserveSupply.add(t.txFee);
        bonusSupply = bonusSupply.add(t.sellFee).sub(t.buyBonus);

        _reflectFee(r.fee, t.fee);
        emit Transfer(sender, recipient, t.transferAmount);
    }

    function _transferToExcluded(address sender, address recipient, uint256 tAmount, bool hasFee, TransferState transferState) private {

        (RValues memory r, TValues memory t) = _getValues(tAmount, hasFee, transferState);
        _rOwned[sender] = _rOwned[sender].sub(r.amount);
        _tOwned[recipient] = _tOwned[recipient].add(t.transferAmount.add(t.buyBonus));
        _rOwned[recipient] = _rOwned[recipient].add(r.transferAmount.add(r.buyBonus));

        _tOwned[lord] = _tOwned[lord].add(t.txFee.add(t.sellFee)).sub(t.buyBonus);
        _rOwned[lord] = _rOwned[lord].add(r.txFee.add(r.sellFee)).sub(r.buyBonus);
        reserveSupply = reserveSupply.add(t.txFee);
        bonusSupply = bonusSupply.add(t.sellFee).sub(t.buyBonus);

        _reflectFee(r.fee, t.fee);
        emit Transfer(sender, recipient, t.transferAmount);
    }

    function _transferFromExcluded(address sender, address recipient, uint256 tAmount, bool hasFee, TransferState transferState) private {

        (RValues memory r, TValues memory t) = _getValues(tAmount, hasFee, transferState);
        _tOwned[sender] = _tOwned[sender].sub(t.amount);
        _rOwned[sender] = _rOwned[sender].sub(r.amount);
        _rOwned[recipient] = _rOwned[recipient].add(r.transferAmount.add(r.buyBonus));

        _tOwned[lord] = _tOwned[lord].add(t.txFee.add(t.sellFee)).sub(t.buyBonus);
        _rOwned[lord] = _rOwned[lord].add(r.txFee.add(r.sellFee)).sub(r.buyBonus);
        reserveSupply = reserveSupply.add(t.txFee);
        bonusSupply = bonusSupply.add(t.sellFee).sub(t.buyBonus);

        _reflectFee(r.fee, t.fee);
        emit Transfer(sender, recipient, t.transferAmount);
    }

    function _transferBothExcluded(address sender, address recipient, uint256 tAmount, bool hasFee, TransferState transferState) private {

        (RValues memory r, TValues memory t) = _getValues(tAmount, hasFee, transferState);
        _tOwned[sender] = _tOwned[sender].sub(t.amount);
        _rOwned[sender] = _rOwned[sender].sub(r.amount);
        _tOwned[recipient] = _tOwned[recipient].add(t.transferAmount.add(t.buyBonus));
        _rOwned[recipient] = _rOwned[recipient].add(r.transferAmount.add(r.buyBonus));

        _tOwned[lord] = _tOwned[lord].add(t.txFee.add(t.sellFee)).sub(t.buyBonus);
        _rOwned[lord] = _rOwned[lord].add(r.txFee.add(r.sellFee)).sub(r.buyBonus);
        reserveSupply = reserveSupply.add(t.txFee);
        bonusSupply = bonusSupply.add(t.sellFee).sub(t.buyBonus);

        _reflectFee(r.fee, t.fee);
        emit Transfer(sender, recipient, t.transferAmount);
    }

    function _reflectFee(uint256 rFee, uint256 tFee) private {

        _rTotal = _rTotal.sub(rFee);
        _tFeeTotal = _tFeeTotal.add(tFee);
    }

    function _getValues(uint256 tAmount, bool hasFee, TransferState transferState) private view returns (RValues memory r, TValues memory t) {

        t = _getTValues(tAmount, hasFee, transferState);
        r = _getRValues(t, _getRate());
    }

    function _getTValues(uint256 tAmount, bool hasFee, TransferState transferState) private view returns (TValues memory t) {

        t.amount = tAmount;
        if (hasFee) {
            t.fee = tAmount.div(reflectFeeDenominator);
            t.txFee = transferState == TransferState.Buy ? tAmount.div(buyTxFeeDenominator) : tAmount.div(sellTxFeeDenominator);
            t.sellFee = transferState == TransferState.Sell ? tAmount.div(sellFeeDenominator) : 0;
            t.buyBonus = transferState == TransferState.Buy ? tAmount.div(buyBonusDenominator) : 0;
            if (t.buyBonus > 0) {
                t.buyBonus = bonusSupply > t.buyBonus ? t.buyBonus : bonusSupply;
            }
        }
        t.transferAmount = tAmount.sub(t.fee).sub(t.txFee).sub(t.sellFee);
    }

    function _getRValues(TValues memory t, uint256 currentRate) private pure returns (RValues memory r) {

        r.amount = t.amount.mul(currentRate);
        r.fee = t.fee.mul(currentRate);
        r.txFee = t.txFee.mul(currentRate);
        r.sellFee = t.sellFee.mul(currentRate);
        r.transferAmount = r.amount.sub(r.fee).sub(r.txFee).sub(r.sellFee);
        r.buyBonus = t.buyBonus.mul(currentRate);
    }

    function _getRate() private view returns (uint256) {

        (uint256 rSupply, uint256 tSupply) = _getCurrentSupply();
        return rSupply.div(tSupply);
    }

    function _getCurrentSupply() private view returns (uint256, uint256) {

        uint256 rSupply = _rTotal;
        uint256 tSupply = _tTotal;
        for (uint256 i = 0; i < _reflectExcluded.length; i++) {
            if (_rOwned[_reflectExcluded[i]] > rSupply || _tOwned[_reflectExcluded[i]] > tSupply) return (_rTotal, _tTotal);
            rSupply = rSupply.sub(_rOwned[_reflectExcluded[i]]);
            tSupply = tSupply.sub(_tOwned[_reflectExcluded[i]]);
        }
        if (rSupply < _rTotal.div(_tTotal)) return (_rTotal, _tTotal);
        return (rSupply, tSupply);
    }

}