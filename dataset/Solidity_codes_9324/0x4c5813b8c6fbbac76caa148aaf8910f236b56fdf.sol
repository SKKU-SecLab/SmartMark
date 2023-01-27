
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
        _setOwner(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
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

}//GPL-3.0-or-later




pragma solidity ^0.8.7;



contract Snap is Context, IERC20, Ownable {

    using SafeMath for uint256;
    using Address for address;

    string private _name = 'SNAP!';
    string private _symbol = 'SNAP!';
    uint8 private _decimals = 9;

    uint256 private constant MAX_UINT256 = ~uint256(0);
    uint256 private constant INITIAL_FRAGMENTS_SUPPLY = 100_000_000_000_000 * 10**9;
    uint256 private constant TOTAL_GONS = MAX_UINT256 - (MAX_UINT256 % INITIAL_FRAGMENTS_SUPPLY);

    uint256 public constant MAG = 10 ** 9;
    uint256 public rateOfChange = MAG;

    uint256 private _totalSupply;
    uint256 public _gonsPerFragment;

    mapping (address => uint256) public _gonBalances;
    mapping (address => uint256) public _excludedBalances;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) private _isExcludedFromFee;
    mapping (address => bool) private _isExcludedFromReward;
    mapping (address => bool) private _isBlackListedBot;
    mapping (address => bool) private uniswapV2Pairs;
    address[] private _blackListedBots;

    uint256 private _taxFee = 8;
    uint256 private _marketingFee = 2;
    uint256 private _buyBackFee = _taxFee + 1;
    uint256 private _swapEth = 1 * 10**16;
    uint256 private _swapImpact = 10;
    uint256 private launchTime;

    uint256 private _previousTaxFee = _taxFee;
    uint256 private _previousMarketingFee = _marketingFee;
    uint256 private _previousBuyBackFee = _buyBackFee;

    address payable private _marketingWalletAddress;
    address private immutable _deadWalletAddress = 0x000000000000000000000000000000000000dEaD;

    IUniswapV2Router02 public uniswapV2Router;

    bool inSwapAndLiquify = false;
    bool public swapAndLiquifyEnabled = true;

    bool public tradingOpen = false;

    uint256 private _maxTxAmount = INITIAL_FRAGMENTS_SUPPLY.div(200);

    event SwapAndLiquifyEnabledUpdated(bool enabled);
    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 ethReceived,
        uint256 tokensIntoLiqudity
    );

    event SwapETHForTokens(
        uint256 amountIn,
        address[] path
    );

    event SwapTokensForETH(
        uint256 amountIn,
        address[] path
    );

    modifier lockTheSwap {

        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }

    constructor (address marketingWalletAddress) {
        _totalSupply = INITIAL_FRAGMENTS_SUPPLY;
        _gonBalances[_msgSender()] = TOTAL_GONS;
        _gonsPerFragment = TOTAL_GONS.div(_totalSupply);

        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        address _uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory()).createPair(address(this), _uniswapV2Router.WETH());
        uniswapV2Pairs[_uniswapV2Pair] = true;
        uniswapV2Router = _uniswapV2Router;

        _marketingWalletAddress = payable(marketingWalletAddress);
        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[address(this)] = true;
        _isExcludedFromFee[_marketingWalletAddress] = true;

        _isExcludedFromReward[_uniswapV2Pair] = true;
        _isExcludedFromReward[address(this)] = true;

        _isBlackListedBot[address(0xa1ceC245c456dD1bd9F2815a6955fEf44Eb4191b)] = true;
        _blackListedBots.push(address(0xa1ceC245c456dD1bd9F2815a6955fEf44Eb4191b));

        _isBlackListedBot[address(0x27F9Adb26D532a41D97e00206114e429ad58c679)] = true;
        _blackListedBots.push(address(0x27F9Adb26D532a41D97e00206114e429ad58c679));

        _isBlackListedBot[address(0x9282dc5c422FA91Ff2F6fF3a0b45B7BF97CF78E7)] = true;
        _blackListedBots.push(address(0x9282dc5c422FA91Ff2F6fF3a0b45B7BF97CF78E7));

        _isBlackListedBot[address(0xfad95B6089c53A0D1d861eabFaadd8901b0F8533)] = true;
        _blackListedBots.push(address(0xfad95B6089c53A0D1d861eabFaadd8901b0F8533));

        _isBlackListedBot[address(0xfe9d99ef02E905127239E85A611c29ad32c31c2F)] = true;
        _blackListedBots.push(address(0xfe9d99ef02E905127239E85A611c29ad32c31c2F));

        _isBlackListedBot[address(0x59341Bc6b4f3Ace878574b05914f43309dd678c7)] = true;
        _blackListedBots.push(address(0x59341Bc6b4f3Ace878574b05914f43309dd678c7));

        _isBlackListedBot[address(0x136F4B5b6A306091b280E3F251fa0E21b1280Cd5)] = true;
        _blackListedBots.push(address(0x136F4B5b6A306091b280E3F251fa0E21b1280Cd5));

        _isBlackListedBot[address(0xf1CA09CE745bfa38258b26cd839ef0E8DE062A40)] = true;
        _blackListedBots.push(address(0xf1CA09CE745bfa38258b26cd839ef0E8DE062A40));

        _isBlackListedBot[address(0x8719c2829944150F59E3428CA24f6Fc018E43890)] = true;
        _blackListedBots.push(address(0x8719c2829944150F59E3428CA24f6Fc018E43890));

        _isBlackListedBot[address(0xa8E0771582EA33A9d8e6d2Ccb65A8D10Bd0Ea517)] = true;
        _blackListedBots.push(address(0xa8E0771582EA33A9d8e6d2Ccb65A8D10Bd0Ea517));

        _isBlackListedBot[address(0xF3DaA7465273587aec8b2d2706335e06068ccce4)] = true;
        _blackListedBots.push(address(0xF3DaA7465273587aec8b2d2706335e06068ccce4));

        _isBlackListedBot[address(0x9272A2c7083Da2B1C2F0739d9655D1A09764DEAD)] = true;
        _blackListedBots.push(address(0x9272A2c7083Da2B1C2F0739d9655D1A09764DEAD));

        emit Transfer(address(0), _msgSender(), _totalSupply);
    }

    receive() external payable {}

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

        if (_isExcludedFromReward[account]) {
            return _excludedBalances[account];
        } else {
            return _gonBalances[account].div(_gonsPerFragment);
        }
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

    function setExcludeFromFee(address account, bool excluded) external onlyOwner() {

        _isExcludedFromFee[account] = excluded;
    }

    function setExcludeFromReward(address account, bool excluded) public onlyOwner() {

        if (excluded) {
            require(!_isExcludedFromReward[account], "Account is already excluded");
            _isExcludedFromReward[account] = true;
            _excludedBalances[account] = _gonBalances[account].div(_gonsPerFragment);
            _gonBalances[account] = 0;
        } else {
            require(_isExcludedFromReward[account], "Account is not excluded");
            _isExcludedFromReward[account] = false;
            _gonBalances[account] = _excludedBalances[account].mul(_gonsPerFragment);
            _excludedBalances[account] = 0;
        }
    }

    function addBotToBlackList(address account) external onlyOwner() {

        require(account != 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D, 'We can not blacklist Uniswap router.');
        require(!_isBlackListedBot[account], "Account is already blacklisted");
        _isBlackListedBot[account] = true;
        _blackListedBots.push(account);
    }

    function removeBotFromBlackList(address account) external onlyOwner() {

        require(_isBlackListedBot[account], "Account is not blacklisted");
        for (uint256 i = 0; i < _blackListedBots.length; i++) {
            if (_blackListedBots[i] == account) {
                _blackListedBots[i] = _blackListedBots[_blackListedBots.length - 1];
                _isBlackListedBot[account] = false;
                _blackListedBots.pop();
                break;
            }
        }
    }

    function removeAllFee() private {

        if (_taxFee == 0 && _marketingFee == 0 && _buyBackFee == 0) return;

        _previousTaxFee = _taxFee;
        _previousMarketingFee = _marketingFee;
        _previousBuyBackFee = _buyBackFee;

        _taxFee = 0;
        _marketingFee = 0;
        _buyBackFee = 0;
    }

    function restoreAllFee() private {

        _taxFee = _previousTaxFee;
        _marketingFee = _previousMarketingFee;
        _buyBackFee = _previousBuyBackFee;
    }

    function isExcludedFromFee(address account) public view returns(bool) {

        return _isExcludedFromFee[account];
    }

    function _approve(address owner, address spender, uint256 amount) private {

        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function rebasePlus(uint256 _amount) private {

        _totalSupply = _totalSupply.add(_amount.mul(_taxFee).div(100));
        _gonsPerFragment = TOTAL_GONS.div(_totalSupply);
    }

    function _transfer(address sender, address recipient, uint256 amount) private {

        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "ERC20: Transfer amount must be greater than zero");
        require(!_isBlackListedBot[sender], "You have no power here!");
        require(!_isBlackListedBot[recipient], "You have no power here!");
        require(!_isBlackListedBot[tx.origin], "You have no power here!");

        if (sender != owner() && recipient != owner()) {
            require(amount <= _maxTxAmount, "Transfer amount exceeds the maxTxAmount.");
            if (uniswapV2Pairs[sender]) {
                require(tradingOpen, "Wait for opened trading");
                require(balanceOf(recipient) <= _maxTxAmount, "Already bought maxTxAmount, wait till check off");
                require(balanceOf(tx.origin) <= _maxTxAmount, "Already bought maxTxAmount, wait till check off");

                if (block.timestamp == launchTime) {
                    _isBlackListedBot[recipient] = true;
                    _blackListedBots.push(recipient);
                }
            }

            if (!inSwapAndLiquify && swapAndLiquifyEnabled && !uniswapV2Pairs[sender]) {
                swapTokens(amount, uniswapV2Pairs[recipient]);
            }
        }

        bool takeFee = true;

        if(_isExcludedFromFee[sender] || _isExcludedFromFee[recipient]){
            takeFee = false;
        }

        if (sender != owner() && recipient != owner() && uniswapV2Pairs[sender]) {
            rebasePlus(amount);
            takeFee = false;
        }

        _tokenTransfer(sender, recipient, amount, takeFee);
    }

    function _tokenTransfer(address sender, address recipient, uint256 amount, bool takeFee) internal {

        if (!takeFee)
            removeAllFee();

        uint256 burnAmount = amount.mul(_buyBackFee.add(_marketingFee)).div(100);
        uint256 transferAmount = amount.sub(burnAmount);

        uint256 gonTotalValue = amount.mul(_gonsPerFragment);
        uint256 gonValue = transferAmount.mul(_gonsPerFragment);
        uint256 gonBurnValue = burnAmount.mul(_gonsPerFragment);

        if (!_isExcludedFromReward[sender]) {
            _gonBalances[sender] = _gonBalances[sender].sub(gonTotalValue);
        } else {
            _excludedBalances[sender] = _excludedBalances[sender].sub(amount);
        }

        if (!_isExcludedFromReward[recipient]) {
            _gonBalances[recipient] = _gonBalances[recipient].add(gonValue);
        } else {
            _excludedBalances[recipient] = _excludedBalances[recipient].add(transferAmount);
        }

        _excludedBalances[address(this)] = _excludedBalances[address(this)].add(burnAmount);

        emit Transfer(sender, recipient, transferAmount);
        emit Transfer(sender, address(this), burnAmount);

        if (!takeFee)
            restoreAllFee();
    }

    event SwapAndLiquifyFailed(bytes failErr);

    function swapTokens(uint256 amount, bool isSell) private lockTheSwap {

        uint256 contractTokenBalance = balanceOf(address(this));
        uint256 contractEthBalance = address(this).balance;

        uint256 maxAddedToSlipPage = amount.mul(_swapImpact).div(100);
        if (isSell && contractTokenBalance > maxAddedToSlipPage) {
            contractTokenBalance = maxAddedToSlipPage;
        }
        swapTokensForEth(contractTokenBalance);

        if (contractEthBalance > _swapEth) {
            uint256 toTransfer = contractEthBalance.mul(_marketingFee).div(_marketingFee.add(_buyBackFee));

            sendETHToWallet(toTransfer);
            swapEthForTokens(address(this), contractEthBalance.sub(toTransfer));
        }
    }

    function swapTokensForEth(uint256 tokenAmount) private {

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();

        _approve(address(this), address(uniswapV2Router), tokenAmount);

        try uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            address(this),
            block.timestamp
        ) {
            emit SwapTokensForETH(tokenAmount, path);
        } catch (bytes memory e) {
            emit SwapAndLiquifyFailed(e);
        }
    }

    function swapEthForTokens(address token, uint256 amount) private {

        address[] memory path = new address[](2);
        path[0] = uniswapV2Router.WETH();
        path[1] = token;

        _approve(address(this), address(uniswapV2Router), amount);

        try uniswapV2Router.swapExactETHForTokens{value: amount}(
            0, // accept any amount of Tokens
            path,
            _deadWalletAddress,
            block.timestamp.add(300)
        ) {
            emit SwapETHForTokens(amount, path);
        } catch (bytes memory e) {
            emit SwapAndLiquifyFailed(e);
        }
    }

    function sendETHToWallet(uint256 amount) private {

        _marketingWalletAddress.call{value: amount}("");
    }

    function openTrading() public onlyOwner() {

        tradingOpen = true;
        launchTime = block.timestamp;
    }

    function manualSwap() external onlyOwner() {

        uint256 contractBalance = balanceOf(address(this));
        swapTokensForEth(contractBalance);
    }

    function manualSwapAmount(uint256 amount) public onlyOwner() {

        uint256 contractBalance = balanceOf(address(this));
        require(contractBalance >= amount, 'contract balance should be greater then amount');

        swapTokensForEth(amount);
    }

    function manualSend() public onlyOwner() {

        uint256 contractETHBalance = address(this).balance;
        sendETHToWallet(contractETHBalance);
    }

    function manualSwapAndSend(uint256 amount) external onlyOwner() {

        manualSwapAmount(amount);
        manualSend();
    }

    function setSwapAndLiquifyEnabled(bool _swapAndLiquifyEnabled) external onlyOwner(){

        swapAndLiquifyEnabled = _swapAndLiquifyEnabled;
    }

    function _getMaxTxAmount() private view returns(uint256) {

        return _maxTxAmount;
    }

    function _getETHBalance() public view returns(uint256 balance) {

        return address(this).balance;
    }

    function _setTaxFee(uint256 taxFee) external onlyOwner() {

        require(taxFee >= 0 && taxFee <= 49, 'taxFee should be in 0 - 49');
        _taxFee = taxFee;
    }

    function _setMarketingFee(uint256 marketingFee) external onlyOwner() {

        require(marketingFee >= 0 && marketingFee <= 49, 'marketingFee should be in 0 - 49');
        _marketingFee = marketingFee;
    }

    function _setBuyBackFee(uint256 buyBackFee) external onlyOwner() {

        require(buyBackFee >= 0 && buyBackFee <= 49, 'buyBackFee should be in 0 - 49');
        _buyBackFee = buyBackFee;
    }

    function _setMarketingWallet(address payable marketingWalletAddress) external onlyOwner() {

        _marketingWalletAddress = marketingWalletAddress;
    }

    function _setSwapEthLimit(uint256 swapEthLimit) external onlyOwner() {

        _swapEth = swapEthLimit;
    }

    function _setSwapImpact(uint256 swapImpact) external onlyOwner() {

        _swapImpact = swapImpact;
    }

    function _setMainRouter(address router, address _uniswapV2Pair) external onlyOwner() {

        uniswapV2Pairs[_uniswapV2Pair] = true;
        uniswapV2Router = IUniswapV2Router02(router);
        setExcludeFromReward(_uniswapV2Pair, true);
    }

    function _setLiquidityPair(address _uniswapV2Pair, bool isPair) external onlyOwner() {

        uniswapV2Pairs[_uniswapV2Pair] = isPair;
        setExcludeFromReward(_uniswapV2Pair, isPair);
    }

    function _setMaxTxAmount(uint256 maxTxAmount) external onlyOwner() {

        require(maxTxAmount >= 10**9 , 'maxTxAmount should be greater than total 1e9');
        _maxTxAmount = maxTxAmount;
    }

    function recoverTokens(uint256 tokenAmount) public virtual onlyOwner() {

        _approve(address(this), owner(), tokenAmount);
        _transfer(address(this), owner(), tokenAmount);
    }

}