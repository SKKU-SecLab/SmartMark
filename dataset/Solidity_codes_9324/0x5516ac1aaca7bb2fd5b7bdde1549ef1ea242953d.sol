
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
}// MIT

pragma solidity ^0.8.1;

library Address {

    function isContract(address account) internal view returns (bool) {


        return account.code.length > 0;
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

interface IERC20 {

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address to, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

}// MIT

pragma solidity ^0.8.0;


interface IERC20Metadata is IERC20 {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function decimals() external view returns (uint8);

}// Unlicensed
pragma solidity >=0.8.4;


contract DetfReflect is Ownable, IERC20, IERC20Metadata {

    using SafeMath for uint256;
    using Address for address;

    string private constant _NAME = 'DETF token';
    string private constant _SYMBOL = 'DETF';
    uint8 private constant  _DECIMALS = 18;

    uint256 private constant _MAX = ~uint256(0);
    uint256 private constant _HOLD_FEE = 150; // 1.5% of tokens goes to existing holders
    uint256 private _holdFee = _HOLD_FEE;
    uint256 private constant _TREASURE_FEE = 150; // 1.5% of tokens goes to treasury contract
    uint256 private _treasureFee = _TREASURE_FEE;
    uint256 private constant _HUNDRED_PERCENT = 10000; // 100%
    uint256 private _withdrawableAmount = 100000 * (10 ** _DECIMALS); // When 100k DEFT collected, it should be swapped to USDC automatically

    uint256 private _tTotal = 100000000 * (10 ** _DECIMALS); // 100 mln tokens
    uint256 private _rTotal = (_MAX - (_MAX % _tTotal));
    uint256 private _tHoldFeeTotal;
    uint256 private _slippage;

    bool private _swapping;
    bool public inSwapAndLiquify;
    address public pool;
    address public uniswapV2UsdcPair;
    IUniswapV2Router02 public uniswapV2Router;
    IERC20 public usdc;

    address[] private _excluded;
    mapping (address => bool) private _isExcluded;
    mapping (address => bool) private _isAmm;

    mapping (address => uint256) private _rOwned;
    mapping (address => uint256) private _tOwned;
    mapping (address => mapping (address => uint256)) private _allowances;

    event Log(string message);
    event AmmAdded(address target);
    event AmmRemoved(address target);
    event ExcludedAdded(address target);
    event ExcludedRemoved(address target);
    event PoolAddressChanged(address newPool);
    event TreasureWithdraw(address receiver, uint256 amount);
    event TreasureFeeAdded(uint256 totalBalance, uint256 tfee, uint256 rFee);
    event UsdcReceived(address receiver, uint256 detfSwapped, uint256 usdcReceived);

    constructor (address uniswapV2Router_, address usdc_) {
        _rOwned[_msgSender()] = _rTotal;
        usdc = IERC20(usdc_);
        uniswapV2Router = IUniswapV2Router02(uniswapV2Router_);
        uniswapV2UsdcPair = address(IUniswapV2Factory(uniswapV2Router.factory()).createPair(address(this), address(usdc)));
        excludeAccountFromRewards(msg.sender);
        excludeAccountFromRewards(address(this));
        excludeAccountFromRewards(uniswapV2UsdcPair);
        addToAmmList(uniswapV2UsdcPair);
        emit Transfer(address(0), _msgSender(), _tTotal);
    }


    modifier lockTheSwap {

        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }

    function excludeAccountFromRewards(address account) public onlyOwner {

        require(!_isExcluded[account], 'excludeAccountFromRewards: Account is already excluded');

        if(_rOwned[account] > 0) {
            _tOwned[account] = tokenFromReflection(_rOwned[account]);
        }

        _isExcluded[account] = true;
        _excluded.push(account);

        emit ExcludedAdded(account);
    }

    function includeAccountForRewards(address account) public onlyOwner {

        require(_isExcluded[account], 'includeAccountForRewards: Account is already excluded');
        require(account != address(this), 'includeAccountForRewards: Can not include token address');

        for (uint256 i = 0; i < _excluded.length; i++) {
            if (_excluded[i] == account) {
                _excluded[i] = _excluded[_excluded.length - 1];
                _tOwned[account] = 0;
                _isExcluded[account] = false;
                _excluded.pop();
                break;
            }
        }

        emit ExcludedRemoved(account);
    }

    function addToAmmList(address account) public onlyOwner {

        require(account != address(0), 'addToAmmList: Incorrect address!');

        _isAmm[account] = true;

        emit AmmAdded(account);
    }

    function removeFromAmmList(address account) public onlyOwner {

        require(account != address(0), 'removeFromAmmList: Incorrect address!');

        _isAmm[account] = false;

        emit AmmRemoved(account);
    }

    function changeWithdrawLimit(uint256 newLimit) public onlyOwner {

        _withdrawableAmount = newLimit;
    }

    function withdraw(address recipient, uint256 amount) public onlyOwner {

        uint256 balance = balanceOf(address(this));
        require(balance >= _withdrawableAmount, 'withdraw: Balance is less from required limit');
        require(amount <= balance, 'withdraw: Amount is more then balance');

        _transfer(address(this), recipient, amount);

        emit TreasureWithdraw(recipient, amount);
    }

    function setPoolAddress(address pool_) public onlyOwner {

        require(pool_ != address(this), 'setPoolAddress: Zero address not allowed');
        pool = pool_;

        emit PoolAddressChanged(pool);
    }

    function setSlippage(uint256 slippage) public onlyOwner returns (bool) {

        _slippage = slippage;
        return true;
    }



     function transfer(address recipient, uint256 amount) public override returns (bool) {

        _transfer(_msgSender(), recipient, amount);

        return true;
    }

    function approve(address spender, uint256 amount) public override returns (bool) {

        _approve(_msgSender(), spender, amount);

        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {

        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, 'transferFrom: Transfer amount exceeds allowance'));

        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));

        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, 'decreaseAllowance: decreased allowance below zero'));

        return true;
    }

    function reflect(uint256 tAmount) public {

        address sender = _msgSender();
        require(!_isExcluded[sender], 'reflect: Excluded addresses cannot call this function');

        (uint256 rAmount,,,,,) = _getValues(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rTotal = _rTotal.sub(rAmount);
        _tHoldFeeTotal = _tHoldFeeTotal.add(tAmount);
    }




    function name() public pure override returns (string memory) {

        return _NAME;
    }

    function symbol() public pure override returns (string memory) {

        return _SYMBOL;
    }

    function decimals() public pure override returns (uint8) {

        return _DECIMALS;
    }

    function totalSupply() public view override returns (uint256) {

        return _tTotal;
    }

    function balanceOf(address account) public view override returns (uint256) {

        if (account == address(this) || _isExcluded[account]) return _tOwned[account];
        else return tokenFromReflection(_rOwned[account]);
    }

    function allowance(address owner, address spender) public view override returns (uint256) {

        return _allowances[owner][spender];
    }

    function isExcluded(address account) public view returns (bool) {

        return _isExcluded[account];
    }

    function isAmmContract(address account) public view returns (bool) {

        return _isAmm[account];
    }

    function totalFees() public view returns (uint256) {

        return _tHoldFeeTotal;
    }

    function getSlippage() public view returns (uint256) {

        return _slippage;
    }

    function getHoldingFee() public pure returns (uint256) {

        return _HOLD_FEE;
    }

    function getTreasureFee() public pure returns (uint256) {

        return _TREASURE_FEE;
    }

    function reflectionFromToken(uint256 tAmount, bool deductTransferFee) public view returns (uint256) {

        require(tAmount <= _tTotal, 'reflectionFromToken: Amount must be less than supply');

        if (!deductTransferFee) {
            (uint256 rAmount,,,,,) = _getValues(tAmount);
            return rAmount;
        } else {
            (,uint256 rTransferAmount,,,,) = _getValues(tAmount);
            return rTransferAmount;
        }
    }

    function tokenFromReflection(uint256 rAmount) public view returns (uint256) {

        require(rAmount <= _rTotal, 'tokenFromReflection: Amount must be less than total reflections');

        uint256 currentRate = _getRate();
        return rAmount.div(currentRate);
    }




    function _approve(address owner, address spender, uint256 amount) private {

        require(owner != address(0), '_approve: Approve from the zero address');
        require(spender != address(0), '_approve: Approve to the zero address');

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(address sender, address recipient, uint256 amount) internal virtual {

        require(sender != address(0), '_transfer: Transfer from the zero address');
        require(recipient != address(0), '_transfer: Transfer to the zero address');
        require(amount > 0, '_transfer: Transfer amount must be greater than zero');
        require(balanceOf(sender) >= amount, "_transfer: The balance is insufficient");
        bool cutFee = (_isAmm[recipient] || _isAmm[sender]) && !_swapping;
        if (
            _tOwned[address(this)] >= _withdrawableAmount && 
            msg.sender != uniswapV2UsdcPair && 
            !inSwapAndLiquify
        ) {
            _swapAndSend();
        }
        if (!cutFee) {
            _disableFee();
        }

        if (_isExcluded[sender] && !_isExcluded[recipient]) {
            _transferFromExcluded(sender, recipient, amount);
        } else if (!_isExcluded[sender] && _isExcluded[recipient]) {
            _transferToExcluded(sender, recipient, amount);
        } else if (!_isExcluded[sender] && !_isExcluded[recipient]) {
            _transferStandard(sender, recipient, amount);
        } else if (_isExcluded[sender] && _isExcluded[recipient]) {
            _transferBothExcluded(sender, recipient, amount);
        } else {
            _transferStandard(sender, recipient, amount);
        }

        if (!cutFee) {
            _enableFee();
        }
    }

    function _transferStandard(address sender, address recipient, uint256 tAmount) private {

        (
            uint256 rAmount,
            uint256 rTransferAmount,
            uint256 rFee,
            uint256 tTransferAmount,
            uint256 tHoldFee,
            uint256 tTreasureFee
        ) = _getValues(tAmount);

        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);

        _claimTreasureFee(tTreasureFee);
        _reflectFee(rFee, tHoldFee);

        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _transferToExcluded(address sender, address recipient, uint256 tAmount) private {

        (
            uint256 rAmount,
            uint256 rTransferAmount,
            uint256 rFee,
            uint256 tTransferAmount,
            uint256 tHoldFee,
            uint256 tTreasureFee
        ) = _getValues(tAmount);

        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _tOwned[recipient] = _tOwned[recipient].add(tTransferAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);

        _claimTreasureFee(tTreasureFee);
        _reflectFee(rFee, tHoldFee);

        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _transferFromExcluded(address sender, address recipient, uint256 tAmount) private {

        (
            uint256 rAmount,
            uint256 rTransferAmount,
            uint256 rFee,
            uint256 tTransferAmount,
            uint256 tHoldFee,
            uint256 tTreasureFee
        ) = _getValues(tAmount);

        _tOwned[sender] = _tOwned[sender].sub(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);

        _claimTreasureFee(tTreasureFee);
        _reflectFee(rFee, tHoldFee);

        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _transferBothExcluded(address sender, address recipient, uint256 tAmount) private {

        (
            uint256 rAmount,
            uint256 rTransferAmount,
            uint256 rFee,
            uint256 tTransferAmount,
            uint256 tHoldFee,
            uint256 tTreasureFee
        ) = _getValues(tAmount);

        _tOwned[sender] = _tOwned[sender].sub(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _tOwned[recipient] = _tOwned[recipient].add(tTransferAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);

        _claimTreasureFee(tTreasureFee);
        _reflectFee(rFee, tHoldFee);

        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _reflectFee(uint256 rFee, uint256 tHoldFee) private {

        _rTotal = _rTotal.sub(rFee);
        _tHoldFeeTotal = _tHoldFeeTotal.add(tHoldFee);
    }

    function _disableFee() private {

        if (_holdFee == 0 && _treasureFee == 0) return;

        _swapping = true;
        _holdFee = 0;
        _treasureFee = 0;
    }

    function _enableFee() private {

        _swapping = false;
        _holdFee = _HOLD_FEE;
        _treasureFee = _TREASURE_FEE;
    }

    function _claimTreasureFee(uint256 tTreasureFee) private {

        uint256 currentRate = _getRate();
        uint256 rTreasureFee = tTreasureFee.mul(currentRate);

        _rOwned[address(this)] = _rOwned[address(this)].add(rTreasureFee);
        _tOwned[address(this)] = _tOwned[address(this)].add(tTreasureFee);

        emit TreasureFeeAdded(balanceOf(address(this)), tTreasureFee, rTreasureFee);
    }

    function _swapAndSend() private lockTheSwap {

        _swapTokensForUSDC(_withdrawableAmount);
        uint256 usdcBalance = usdc.balanceOf(address(this));
        usdc.transfer(pool, usdcBalance);
        emit UsdcReceived(pool, _withdrawableAmount, usdcBalance);
    }

    function _swapTokensForUSDC(uint256 tokenAmount) private {

        require(pool != address(0), "Pool not found");
        (uint256 reserveIn, uint256 reserveOut,) = IUniswapV2Pair(uniswapV2UsdcPair).getReserves();
        uint256 amountOut; 
        try uniswapV2Router.getAmountOut(tokenAmount, reserveIn, reserveOut) {
            amountOut = uniswapV2Router.getAmountOut(tokenAmount, reserveIn, reserveOut);
        } catch {
            _approve(address(this), address(uniswapV2Router), 0);
            emit Log("DETF->USDC swap failed");
        }
        uint256 minAmountOut = amountOut.sub(amountOut.mul(_slippage).div(_HUNDRED_PERCENT));
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = address(usdc);
        _approve(address(this), address(uniswapV2Router), tokenAmount);
        try uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            minAmountOut,
            path,
            pool,
            block.timestamp
        ) {
            emit Log("DETF->USDC swap success");
        } catch {
            _approve(address(this), address(uniswapV2Router), 0);
            emit Log("DETF->USDC swap failed");
        }
    }

    function _getValues(uint256 tAmount) private view returns (uint256, uint256, uint256, uint256, uint256, uint256) {

        (uint256 tTransferAmount, uint256 tHoldFee, uint256 tTreasureFee) = _getTValues(tAmount);
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee) = _getRValues(tAmount, tHoldFee, tTreasureFee);

        return (
            rAmount,
            rTransferAmount,
            rFee,
            tTransferAmount,
            tHoldFee,
            tTreasureFee
        );
    }

    function _getReflectAmount(uint256 tAmount) private view returns (uint256) {

        uint256 currentRate = _getRate();
        uint256 rAmount = tAmount.mul(currentRate);

        return rAmount;
    }

    function _getTValues(uint256 tAmount) private view returns (uint256, uint256, uint256) {

        uint256 tHoldFee = tAmount.mul(_holdFee).div(_HUNDRED_PERCENT);
        uint256 tTreasureFee = tAmount.mul(_treasureFee).div(_HUNDRED_PERCENT);
        uint256 tTransferAmount = tAmount.sub(tHoldFee).sub(tTreasureFee);

        return (
            tTransferAmount,
            tHoldFee,
            tTreasureFee
        );
    }

    function _getRValues(uint256 tAmount, uint256 tHoldFee, uint256 tTreasureFee) private view returns (uint256, uint256, uint256) {

        uint256 currentRate = _getRate();
        uint256 rAmount = tAmount.mul(currentRate);
        uint256 rFee = tHoldFee.mul(currentRate);
        uint256 rTreasureFee = tTreasureFee.mul(currentRate);
        uint256 rTransferAmount = rAmount.sub(rFee).sub(rTreasureFee);

        return (
            rAmount,
            rTransferAmount,
            rFee
        );
    }

    function _getRate() private view returns (uint256) {

        (uint256 rSupply, uint256 tSupply) = _getCurrentSupply();

        return rSupply.div(tSupply);
    }

    function _getCurrentSupply() private view returns (uint256, uint256) {

        uint256 rSupply = _rTotal;
        uint256 tSupply = _tTotal;
        for (uint256 i = 0; i < _excluded.length; i++) {
            if (_rOwned[_excluded[i]] > rSupply || _tOwned[_excluded[i]] > tSupply) return (_rTotal, _tTotal);
            rSupply = rSupply.sub(_rOwned[_excluded[i]]);
            tSupply = tSupply.sub(_tOwned[_excluded[i]]);
        }

        if (rSupply < _rTotal.div(_tTotal)) return (_rTotal, _tTotal);

        return (
            rSupply,
            tSupply
        );
    }
}// Unlicensed
pragma solidity >=0.8.4;



contract Detf is DetfReflect {

    using SafeMath for uint256;

    mapping(address => address) public delegates;

    struct Checkpoint {
        uint256 fromBlock;
        uint256 votes;
    }

    mapping(address => mapping(uint256 => Checkpoint)) public checkpoints;

    mapping(address => uint256) public numCheckpoints;

    mapping(address => uint256) public delegatorVotes;

    bytes32 public constant DOMAIN_TYPEHASH = keccak256("EIP712Domain(string name,uint256 chainId,address verifyingContract)");

    bytes32 public constant DELEGATION_TYPEHASH = keccak256("Delegation(address delegatee,uint256 nonce,uint256 expiry)");

    mapping(address => uint256) public nonces;

    event DelegateChanged(address indexed delegator, address indexed fromDelegate, address indexed toDelegate);

    event DelegateVotesChanged(address indexed delegate, uint256 previousBalance, uint256 newBalance);




    constructor (address uniswapV2Router_, address usdc_) DetfReflect(uniswapV2Router_, usdc_) {
    }

    fallback () external payable {
    }

    receive () external payable {
    }




    function delegate(address delegatee) public {

        return _delegate(msg.sender, delegatee);
    }

    function _transfer(address sender, address recipient, uint256 amount) internal virtual override {

        _moveDelegates(delegates[sender], delegates[recipient], amount, sender, true);
        super._transfer(sender, recipient, amount);
    }

    function delegateBySig(address delegatee, uint256 nonce, uint256 expiry, uint8 v, bytes32 r, bytes32 s) public {

        bytes32 domainSeparator = keccak256(abi.encode(DOMAIN_TYPEHASH, keccak256(bytes(name())), block.chainid, address(this)));
        bytes32 structHash = keccak256(abi.encode(DELEGATION_TYPEHASH, delegatee, nonce, expiry));
        bytes32 digest = keccak256(abi.encodePacked("\x19\x01", domainSeparator, structHash));
        address signatory = ecrecover(digest, v, r, s);
        require(signatory != address(0), "delegateBySig: Invalid signature!");
        require(nonce == nonces[signatory]++, "delegateBySig: Invalid nonce!");
        require(block.timestamp <= expiry, "delegateBySig: Signature expired!");
        return _delegate(signatory, delegatee);
    }




    function getCurrentVotes(address account) external view returns (uint256) {

        uint256 nCheckpoints = numCheckpoints[account];
        return nCheckpoints > 0 ? checkpoints[account][nCheckpoints - 1].votes : 0;
    }

    function getPriorVotes(address account, uint256 blockNumber) public view returns (uint256) {

        require(blockNumber < block.number, "getPriorVotes: Not yet determined!");

        uint256 nCheckpoints = numCheckpoints[account];
        if (nCheckpoints == 0) {
            return 0;
        }

        if (checkpoints[account][nCheckpoints - 1].fromBlock <= blockNumber) {
            return checkpoints[account][nCheckpoints - 1].votes;
        }

        if (checkpoints[account][0].fromBlock > blockNumber) {
            return 0;
        }

        uint256 lower = 0;
        uint256 upper = nCheckpoints - 1;
        while (upper > lower) {
            uint256 center = upper - (upper - lower) / 2; // ceil, avoiding overflow
            Checkpoint memory cp = checkpoints[account][center];
            if (cp.fromBlock == blockNumber) {
                return cp.votes;
            } else if (cp.fromBlock < blockNumber) {
                lower = center;
            } else {
                upper = center - 1;
            }
        }
        return checkpoints[account][lower].votes;
    }




    function _delegate(address delegator, address delegatee) internal {

        address currentDelegate = delegates[delegator];
        uint256 delegatorBalance = balanceOf(delegator);
        delegates[delegator] = delegatee;
        
        emit DelegateChanged(delegator, currentDelegate, delegatee);

        _moveDelegates(currentDelegate, delegatee, delegatorBalance, delegator, false);
    }

    function _moveDelegates(address srcRep, address dstRep, uint256 amount, address senderVotes, bool isTransfer) internal {

        uint256 delegateVotes = delegatorVotes[senderVotes];
        uint256 delegatorBalance = balanceOf(senderVotes);

        if (srcRep != dstRep && amount > 0) {
            if (srcRep != address(0)) {
                uint256 srcRepNum = numCheckpoints[srcRep];
                uint256 srcRepOld = srcRepNum > 0 ? checkpoints[srcRep][srcRepNum - 1].votes : 0;
                uint256 srcRepNew;
                if (isTransfer) {
                    if (amount > delegateVotes) {
                        delegatorVotes[senderVotes] = delegatorBalance.sub(amount);
                        srcRepNew = srcRepOld.add(delegatorVotes[senderVotes]).sub(delegateVotes);
                    } else {
                        delegatorVotes[senderVotes] = delegateVotes - amount;
                        srcRepNew = srcRepOld.sub(amount);
                    }
                } else {
                    if (delegateVotes != amount) {
                        delegatorVotes[senderVotes] = amount;
                        srcRepNew = srcRepOld.sub(delegateVotes);
                    } else {
                        srcRepNew = srcRepOld.sub(amount);
                    }
                }
                _writeCheckpoint(srcRep, srcRepNum, srcRepOld, srcRepNew);
            } else {
                delegatorVotes[senderVotes] = amount;
            }

            if (dstRep != address(0)) {
                uint256 dstRepNum = numCheckpoints[dstRep];
                uint256 dstRepOld = dstRepNum > 0 ? checkpoints[dstRep][dstRepNum - 1].votes : 0;
                uint256 dstRepNew = dstRepOld.add(amount);
                if (isTransfer) delegatorVotes[dstRep] += amount;
                _writeCheckpoint(dstRep, dstRepNum, dstRepOld, dstRepNew);
            }
        } else if (!isTransfer && srcRep == dstRep && amount != delegateVotes) {
            uint256 dstRepNum = numCheckpoints[dstRep];
            uint256 dstRepOld = dstRepNum > 0 ? checkpoints[dstRep][dstRepNum - 1].votes : 0;
            uint256 dstRepNew = dstRepOld.sub(delegateVotes).add(amount);
            delegatorVotes[senderVotes] = amount;
            _writeCheckpoint(dstRep, dstRepNum, dstRepOld, dstRepNew);
        }
    }

    function _writeCheckpoint(address delegatee, uint256 nCheckpoints, uint256 oldVotes, uint256 newVotes) internal {

      uint256 blockNumber = block.number;

      if (nCheckpoints > 0 && checkpoints[delegatee][nCheckpoints - 1].fromBlock == blockNumber) {
          checkpoints[delegatee][nCheckpoints - 1].votes = newVotes;
      } else {
          checkpoints[delegatee][nCheckpoints] = Checkpoint(blockNumber, newVotes);
          numCheckpoints[delegatee] = nCheckpoints + 1;
      }

      emit DelegateVotesChanged(delegatee, oldVotes, newVotes);
    }
}// MIT
pragma solidity 0.8.4;


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


    function initialize(address, address) external;

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