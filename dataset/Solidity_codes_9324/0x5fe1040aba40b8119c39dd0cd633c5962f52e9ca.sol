
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

interface IERC20 {

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


contract ERC20 is Context, IERC20, IERC20Metadata {

    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    constructor(string memory name_, string memory symbol_) {
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

    function transfer(address to, uint256 amount) public virtual override returns (bool) {

        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {

        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {

        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {

        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {

        address owner = _msgSender();
        _approve(owner, spender, _allowances[owner][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {

        address owner = _msgSender();
        uint256 currentAllowance = _allowances[owner][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {

        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
        }
        _balances[to] += amount;

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
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

    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {

        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
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
}// TESTNET Contract: 0x566e777dBa0Dc36a2a79fEb7374703600aE1fF1b

pragma solidity ^0.8.3;


    contract UraniumV1 is Context, ERC20, Ownable {
        using SafeMath for uint256;
        using Address for address;

        uint8 private _decimals = 18;

        mapping (address => uint256) private _tOwned;
        mapping (address => uint256) private _tClaimed;
        mapping (address => uint256) private _tFedToReactor;
        mapping (address => uint256) private _avgPurchaseDate;


        mapping (address => bool) private _isExcluded;

        mapping (address => bool) private _isSaleAddress;

        uint256 private _tTotal = 23802891 * 10**4 * 10**_decimals;

        uint256 private _tFeeTotal = 0;
        uint256 private _tFeeTotalClaimed = 0;
        
        uint256 private _taxFee = 0;
        uint256 private _charityFeePercent = 0;
        uint256 private _burnFeePercent = 90;
        uint256 private _marketingFeePercent = 5;
        uint256 private _stakingPercent = 5;

        uint256 private _daysForFeeReduction = 365;
        uint256 private _minDaysForReStake = 30;
        uint256 private _maxPercentOfStakeRewards = 10;

        uint256 private _minSalesTaxRequiredToFeedReactor = 50;

        ReactorValues private _reactorValues = ReactorValues(
            10, 80, 10, 0, 10
        );


        struct ReactorValues {
            uint256 baseFeeReduction;
            uint256 stakePercent;
            uint256 burnPercent;
            uint256 charityPercent;
            uint256 marketingPercent;
        }

        address payable public _charityAddress;
        address payable public _marketingWallet;

        uint256 private _maxTxAmount  =  23802891 * 10**4 * 10**_decimals;

        IUniswapV2Router02 public immutable uniswapV2Router;
        address public immutable uniswapV2Pair;

        constructor (address payable charityAddress, address payable marketingWallet, address payable mainSwapRouter) ERC20("Uranium", "U238") {
            _charityAddress = charityAddress;
            _marketingWallet = marketingWallet;
            _tOwned[_msgSender()] = _tTotal;

            IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(mainSwapRouter);
            uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
                .createPair(address(this), _uniswapV2Router.WETH());

            uniswapV2Router = _uniswapV2Router;

            _isSaleAddress[mainSwapRouter] = true;
            _isSaleAddress[_msgSender()] = true;
            _isExcluded[address(0)] = true;
            _isExcluded[address(this)] = true;
            _isExcluded[_msgSender()] = true;

            emit Transfer(address(0), _msgSender(), _tTotal);
        }

        function decimals() public view override returns (uint8) {
            return _decimals;
        }


        function totalSupply() public view override returns (uint256) {
            return _tTotal.sub(_tOwned[address(0)]);
        }

        function balanceOf(address account) public view override returns (uint256) {
            return _tOwned[account];
        }

        function getTokensClaimedByAddress(address account) public view returns (uint256) {
            return _tClaimed[account];
        }

        function getTokensFedToReactor(address account) public view returns (uint256){
            return _tFedToReactor[account];
        }

        function currentFeeForAccount(address account) public view returns (uint256) {
            return _calculateUserFee(account);
        }

        function getAvgPurchaseDate(address account) public view returns (uint256) {
            return _avgPurchaseDate[account];
        }

        function transfer(address recipient, uint256 amount) public override returns (bool) {
            _transfer(_msgSender(), recipient, amount);
            return true;
        }

        function getStakeRewardByAddress(address recipient) public view returns (uint256) { 
            require(_tOwned[recipient] > 0, "Recipient must own tokens to claim rewards");
            require(_tOwned[address(this)] > 0, "Contract must have more than 0 tokens");
            uint256 maxTokensClaimable = _tOwned[address(this)].mul(_maxPercentOfStakeRewards).div(100);
            uint256 maxTokensClaimableByUser = _tOwned[recipient].mul(_maxPercentOfStakeRewards).div(100);
            if (maxTokensClaimableByUser > maxTokensClaimable){
                return maxTokensClaimable;
            }else{
                return maxTokensClaimableByUser;
            }
        }

        function _claimTokens(address sender, uint256 tAmount) private returns (bool) {
            require(_tOwned[address(this)].sub(tAmount) > 0, "Contract doesn't have enough tokens");
            _avgPurchaseDate[sender] = block.timestamp;
            _tOwned[sender] = _tOwned[sender].add(tAmount);
            _tClaimed[sender] = _tClaimed[sender].add(tAmount);
            _tOwned[address(this)] = _tOwned[address(this)].sub(tAmount);
            _tFeeTotalClaimed = _tFeeTotalClaimed.add(tAmount);
            return true;
        }

        function restakeTokens() public returns (bool) {
            require(_tOwned[_msgSender()] > 0, "You must own tokens to claim rewards");
            require(_tOwned[address(this)] > 0, "Contract must have more than 0 tokens");
            require(_avgPurchaseDate[_msgSender()] <= block.timestamp.sub(uint256(86400).mul(_minDaysForReStake)), "You do not qualify for restaking at this time");
            
            uint256 maxTokensClaimable = _tOwned[address(this)].mul(_maxPercentOfStakeRewards).div(100);
            uint256 maxTokensClaimableByUser = _tOwned[_msgSender()].mul(_maxPercentOfStakeRewards).div(100);
            if (maxTokensClaimableByUser > maxTokensClaimable){
                return _claimTokens(_msgSender(), maxTokensClaimable);
            }else{
                return _claimTokens(_msgSender(), maxTokensClaimableByUser);
            }
        }

        function feedTheReactor(bool confirmation) public returns (bool) {
            require(_tOwned[_msgSender()] > 0, "You must own tokens to feed the reactor");
            uint256 userFee = _calculateUserFee(_msgSender());
            require(userFee >= _minSalesTaxRequiredToFeedReactor, "Your sales fee must be greater than minSalesTaxRequiredToFeedReactor");
            require(confirmation, "You must supply 'true' to confirm you understand what you are doing");
            uint256 totalFee = _tOwned[_msgSender()].mul(userFee).div(100);
            uint256 reactorFee = totalFee.mul(uint256(100).sub(_reactorValues.baseFeeReduction)).div(100);
            uint256 stakeFee = reactorFee.mul(_reactorValues.stakePercent).div(100);
            uint256 burnFee = reactorFee.mul(_reactorValues.burnPercent).div(100);
            uint256 charityFee = reactorFee.mul(_reactorValues.charityPercent).div(100);
            uint256 marketingFee = reactorFee.mul(_reactorValues.marketingPercent).div(100);
            _tOwned[_msgSender()] = _tOwned[_msgSender()].sub(reactorFee);
            _tFedToReactor[_msgSender()] = _tFedToReactor[_msgSender()].add(reactorFee);
            _takeBurn(_msgSender(), burnFee);
            _takeCharity(charityFee); 
            _takeMarketing(marketingFee); 
            _reflectFee(stakeFee);
            _avgPurchaseDate[_msgSender()] = block.timestamp.sub(uint256(86400).mul(_daysForFeeReduction));
            return true;
        }

        function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
            _transfer(sender, recipient, amount);
            approve(sender, amount);
            return true;
        }

        function isExcluded(address account) public view returns (bool) {
            return _isExcluded[account];
        }

        function isSalesAddress(address account) public view returns (bool) {
            return _isSaleAddress[account];
        }

        function totalTokensReflected() public view returns (uint256) {
            return _tFeeTotal;
        }

        function totalTokensClaimed() public view returns (uint256) {
            return _tFeeTotalClaimed;
        }

        function addSaleAddress(address account) external onlyOwner() {
            require(!_isSaleAddress[account], "Account is already a sales address");
            _isSaleAddress[account] = true;
        }

        function removeSaleAddress(address account) external onlyOwner(){
            require(_isSaleAddress[account], "Account is not a Sales Address");
            _isSaleAddress[account] = false;
        }

        function excludeAccount(address account) external onlyOwner() {
            require(!_isExcluded[account], "Account is already excluded");
            _isExcluded[account] = true;
        }

        function includeAccount(address account) external onlyOwner() {
            require(_isExcluded[account], "Account is already included");
            _isExcluded[account] = false;
        }

        function _transfer(address sender, address recipient, uint256 amount) internal virtual override {
            require(sender != address(0), "ERC20: transfer from the zero address");
            require(recipient != address(0), "ERC20: transfer to the zero address");
            require(amount > 0, "Transfer amount must be greater than zero");
            
            if(sender != owner() && recipient != owner())
                require(amount <= _maxTxAmount, "Transfer amount exceeds the maxTxAmount.");
          
            _transferStandard(sender, recipient, amount);
        }

        function _transferStandard(address sender, address recipient, uint256 tAmount) private {
            
            TransferValues memory tValues = _getValues(tAmount, sender, recipient);
            
            _setWeightedAvg(sender, recipient, _tOwned[recipient].add(tValues.tTransferAmount), tValues.tTransferAmount);

            _tOwned[sender] = _tOwned[sender].sub(tAmount);
            _tOwned[recipient] = _tOwned[recipient].add(tValues.tTransferAmount);

            _takeBurn(sender, tValues.tBurn);
            _takeCharity(tValues.tCharity); 
            _takeMarketing(tValues.tMarketing); 
            _reflectFee(tValues.tFee);

            emit Transfer(sender, recipient, tValues.tTransferAmount);
        }

        function _getValues(uint256 tAmount, address sender, address receiver) private view returns (TransferValues memory) {
            uint256 baseFee = _taxFee;
            if (_isSaleAddress[receiver]){
                baseFee = _calculateUserFee(sender);
            }
            TransferValues memory tValues = _getTValues(tAmount, baseFee);
            return (tValues);
        }

        struct TransferValues {
            uint256 tTransferAmount;
            uint256 tTotalFeeAmount;
            uint256 tFee;
            uint256 tCharity;
            uint256 tMarketing;
            uint256 tBurn;
        }

        function _getTValues(uint256 tAmount, uint256 taxFee) private view returns (TransferValues memory) {
            uint256 totalFeeAmount = tAmount.mul(taxFee).div(100);
            uint256 tFee = totalFeeAmount.mul(_stakingPercent).div(100);
            uint256 tCharity = totalFeeAmount.mul(_charityFeePercent).div(100);
            uint256 tMarketing = totalFeeAmount.mul(_marketingFeePercent).div(100);
            uint256 tBurn = totalFeeAmount.mul(_burnFeePercent).div(100);

            uint256 tStackTooDeep = tAmount.sub(tFee).sub(tCharity);
            uint256 tTransferAmount = tStackTooDeep.sub(tMarketing).sub(tBurn);
            
            return TransferValues(tTransferAmount, totalFeeAmount, tFee, tCharity, tMarketing, tBurn);
        }

        function _setWeightedAvg(address sender, address recipient, uint256 aTotal, uint256 tAmount) private {
            uint256 senderPurchaseDate = _avgPurchaseDate[sender];
             if (_isSaleAddress[sender]){
                senderPurchaseDate = block.timestamp;
            }
            if (senderPurchaseDate == 0){
                senderPurchaseDate = block.timestamp.sub(uint256(86400).mul(_daysForFeeReduction));
            }
            uint256 transferWeight = tAmount.mul(uint256(100)).div(aTotal);
            if (_isSaleAddress[recipient] || _isExcluded[recipient]){
                _avgPurchaseDate[recipient] = 0;
                return;
            }
            _avgPurchaseDate[recipient] = _avgPurchaseDate[recipient].mul(uint256(100).sub(transferWeight)).div(uint256(100)).add(
                senderPurchaseDate.mul(transferWeight).div(uint256(100)));

        }   

        function _takeFeeByAddress(uint256 tFee, address a) private {
            _tOwned[a] = _tOwned[a].add(tFee);

        }

        function _takeBurn(address sender, uint256 tburn) private {
            _takeFeeByAddress(tburn, address(0));
            if (tburn > 0)emit Transfer(sender, address(0), tburn);
        }

        function _takeMarketing(uint256 tMarketing) private {
            _takeFeeByAddress(tMarketing, _marketingWallet);
        }

        function _takeCharity(uint256 tCharity) private {
            _takeFeeByAddress(tCharity, address(_charityAddress));
        }

        function _reflectFee(uint256 tFee) private {
            _takeFeeByAddress(tFee, address(this));
            _tFeeTotal = _tFeeTotal.add(tFee);
        }

        receive() external payable {}

        function _calculateUserFee(address sender) private view returns (uint256){
            uint256 baseFee = _taxFee;
            uint256 holderLength = block.timestamp - _avgPurchaseDate[sender];
            uint256 timeCompletedPercent = holderLength.mul(100).div(_daysForFeeReduction.mul(86400));
            if (timeCompletedPercent < 100){
                baseFee = uint256(100).sub(timeCompletedPercent);
                if (_taxFee > baseFee) return _taxFee;
            }
            return baseFee;
        }
       
        function _getETHBalance() public view returns(uint256 balance) {
            return address(this).balance;
        }
        
        function _setTaxFee(uint256 taxFee) external onlyOwner() {
            require(taxFee >= 0 && taxFee <= 100, 'taxFee should be in 0 - 100');
            _taxFee = taxFee;
        }

        function getFeePercents(bool reactorFee) public view returns (uint256, uint256, uint256, uint256, uint256){
            if (reactorFee) return (_reactorValues.baseFeeReduction, _reactorValues.charityPercent, _reactorValues.burnPercent, _reactorValues.marketingPercent, _reactorValues.stakePercent);
            return (_taxFee,_charityFeePercent, _burnFeePercent, _marketingFeePercent, _stakingPercent);
        }

        function _setFeePercents(uint256 charityFee, uint256 burnFee, uint256 marketingFee, uint256 stakeFee) external onlyOwner() {
             require(charityFee.add(burnFee).add(marketingFee).add(stakeFee) == 100, 'Fee percents must equal 100%');
             _charityFeePercent = charityFee;
             _burnFeePercent = burnFee;
             _marketingFeePercent = marketingFee;
             _stakingPercent = stakeFee;
        }

        function _setReactorFeePercents(uint256 feeReduction, uint256 charityFee, uint256 burnFee, uint256 marketingFee, uint256 stakeFee) external onlyOwner() {
             require(feeReduction < 100, 'Fee reduction must be less than 100%');
             require(charityFee.add(burnFee).add(marketingFee).add(stakeFee) == 100, 'Fee percents must equal 100%');
             _reactorValues.baseFeeReduction = feeReduction;
             _reactorValues.charityPercent = charityFee;
             _reactorValues.burnPercent = burnFee;
             _reactorValues.marketingPercent = marketingFee;
             _reactorValues.stakePercent = stakeFee;
        }

        function _setDaysForFeeReduction(uint256 daysForFeeReduction) external onlyOwner() {
            require(daysForFeeReduction >= 1, 'daysForFeeReduction needs to be at or above 1');
            _daysForFeeReduction = daysForFeeReduction;
        }

        function getMinSalesTaxRequiredToFeedReactor() public view returns (uint256) {
            return _minSalesTaxRequiredToFeedReactor;
        } 

        function _setMinSalesTaxRequiredToFeedReactor(uint256 salesPercent) external onlyOwner() {
            require(salesPercent >= 0 && salesPercent <= 100, 'minSalesTaxRequiredToFeedReactor must be between 0-100');
            _minSalesTaxRequiredToFeedReactor = salesPercent;
        }

        function _setMinDaysForReStake(uint256 minDaysForReStake) external onlyOwner() {
            require(minDaysForReStake >= 1, 'minDaysForReStake needs to be at or above 1');
            _minDaysForReStake = minDaysForReStake;
        }

        function _setMaxPercentOfStakeRewards(uint256 maxPercentOfStakeRewards) external onlyOwner() {
            require(maxPercentOfStakeRewards >= 1, 'minDaysForReStake needs to be at or above 1');
            _maxPercentOfStakeRewards = maxPercentOfStakeRewards;
        }

        
        function _setCharityWallet(address payable charityWalletAddress) external onlyOwner() {
            _charityAddress = charityWalletAddress;
        }

        function _setMarketingWallet(address payable marketingWalletAddress) external onlyOwner() {
            _marketingWallet = marketingWalletAddress;
        }
        
        function _setMaxTxAmount(uint256 maxTxAmount) external onlyOwner() {
            require(maxTxAmount <= _tTotal , 'maxTxAmount should be less than total supply');
            _maxTxAmount = maxTxAmount;
        }
    }