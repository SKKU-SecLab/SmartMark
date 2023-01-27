pragma solidity ^0.8.1;

interface IERC20{

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

}pragma solidity ^0.8.1;
interface Verify {

    function setSniperStatus(address account, bool blacklisted) external;

    function setLpPair(address pair, bool enabled) external;

    function verifyUser(address from, address to) external;

    function checkLaunch(uint256 launchedAt, bool launched, bool protection, uint256 blockAmount) external;

    function feeExcluded(address account) external;

    function feeIncluded(address account) external;

    function getCoolDownSettings() external view returns(bool buyCooldown, bool sellCooldown, uint256 coolDownTime, uint256 coolDownLimit);

    function getBlacklistStatus(address account) external view returns(bool);

    function setCooldownEnabled(bool onoff, bool offon) external;

    function setCooldown(uint256 amount) external;

    function updateToken(address token) external;

    function updateRouter(address router) external;

    function getLaunchedAt() external view returns(uint256 launchedAt);

}//MIT
pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}pragma solidity ^0.8.1;
contract Ownable is Context {

    address private _owner;
    address private _previousOwner;
    uint256 private _lockTime;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
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

        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}// Unlicensed
 pragma solidity >=0.5.0;

interface IUniswapV2Pair {

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
    event Transfer(address indexed from, address indexed to, uint256 value);

    function name() external pure returns (string memory);


    function symbol() external pure returns (string memory);


    function decimals() external pure returns (uint8);


    function totalSupply() external view returns (uint256);


    function balanceOf(address owner) external view returns (uint256);


    function allowance(address owner, address spender)
        external
        view
        returns (uint256);


    function approve(address spender, uint256 value) external returns (bool);


    function transfer(address to, uint256 value) external returns (bool);


    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);


    function DOMAIN_SEPARATOR() external view returns (bytes32);


    function PERMIT_TYPEHASH() external pure returns (bytes32);


    function nonces(address owner) external view returns (uint256);


    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;


    event Mint(address indexed sender, uint256 amount0, uint256 amount1);
    event Burn(
        address indexed sender,
        uint256 amount0,
        uint256 amount1,
        address indexed to
    );
    event Swap(
        address indexed sender,
        uint256 amount0In,
        uint256 amount1In,
        uint256 amount0Out,
        uint256 amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint256);


    function factory() external view returns (address);


    function token0() external view returns (address);


    function token1() external view returns (address);


    function getReserves()
        external
        view
        returns (
            uint112 reserve0,
            uint112 reserve1,
            uint32 blockTimestampLast
        );


    function price0CumulativeLast() external view returns (uint256);


    function price1CumulativeLast() external view returns (uint256);


    function kLast() external view returns (uint256);


    function mint(address to) external returns (uint256 liquidity);


    function burn(address to)
        external
        returns (uint256 amount0, uint256 amount1);


    function swap(
        uint256 amount0Out,
        uint256 amount1Out,
        address to,
        bytes calldata data
    ) external;


    function skim(address to) external;


    function sync() external;


    function initialize(address, address) external;

}// Unlicensed
pragma solidity >=0.6.2;

interface IUniswapV2Router01 {

    function factory() external pure returns (address);


    function WETH() external pure returns (address);


    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    )
        external
        returns (
            uint256 amountA,
            uint256 amountB,
            uint256 liquidity
        );


    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
        external
        payable
        returns (
            uint256 amountToken,
            uint256 amountETH,
            uint256 liquidity
        );


    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB);


    function removeLiquidityETH(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountToken, uint256 amountETH);


    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountA, uint256 amountB);


    function removeLiquidityETHWithPermit(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountToken, uint256 amountETH);


    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);


    function swapTokensForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
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


    function swapTokensForExactETH(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);


    function swapExactTokensForETH(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);


    function swapETHForExactTokens(
        uint256 amountOut,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);


    function quote(
        uint256 amountA,
        uint256 reserveA,
        uint256 reserveB
    ) external pure returns (uint256 amountB);


    function getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountOut);


    function getAmountIn(
        uint256 amountOut,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountIn);


    function getAmountsOut(uint256 amountIn, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);


    function getAmountsIn(uint256 amountOut, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);

}pragma solidity >=0.6.2;

interface IUniswapV2Router02 is IUniswapV2Router01 {

    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountETH);


    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountETH);


    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;


    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;


    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

}//MIT
pragma solidity ^0.8.0;

library Address {

    function isContract(address account) internal view returns (bool) {

        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly {
            codehash := extcodehash(account)
        }
        return (codehash != accountHash && codehash != 0x0);
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(
            address(this).balance >= amount,
            "Address: insufficient balance"
        );

        (bool success, ) = recipient.call{value: amount}("");
        require(
            success,
            "Address: unable to send value, recipient may have reverted"
        );
    }

    function functionCall(address target, bytes memory data)
        internal
        returns (bytes memory)
    {

        return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {

        return _functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {

        return
            functionCallWithValue(
                target,
                data,
                value,
                "Address: low-level call with value failed"
            );
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {

        require(
            address(this).balance >= value,
            "Address: insufficient balance for call"
        );
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(
        address target,
        bytes memory data,
        uint256 weiValue,
        string memory errorMessage
    ) private returns (bytes memory) {

        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: weiValue}(
            data
        );
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
}pragma solidity ^0.8.1;

contract Verifier is Verify{

    using Address for address;
    mapping (address => bool) lpPairs;
    mapping(address => uint256) private buycooldown;
    mapping(address => uint256) private sellcooldown;
    mapping(address => bool) public _isBlacklisted;
    mapping(address => bool) public _isExcludedFromFee;
    address _token;
    IUniswapV2Router02 public uniswapV2Router;
    modifier onlyToken() {

        require(msg.sender == _token); _;
    }
    struct ILaunch {
        uint256 launchedAt;
        uint256 antiBlocks;
        bool launched;
        bool launchProtection;
    }
    ILaunch public wenLaunch;

    struct Icooldown {
        bool buycooldownEnabled;
        bool sellcooldownEnabled;
        uint256 cooldown;
        uint256 cooldownLimit;
    }
    Icooldown public cooldownInfo =
        Icooldown({
            buycooldownEnabled: true,
            sellcooldownEnabled: true,
            cooldown: 30 seconds,
            cooldownLimit: 60 seconds
        });


    constructor(address[4] memory addresses) {
        uniswapV2Router = IUniswapV2Router02(addresses[2]);
        _token = addresses[0];
        _isExcludedFromFee[addresses[0]] = true;
        _isExcludedFromFee[addresses[1]] = true;
        lpPairs[addresses[3]] = true;
    }
    
    function updateToken(address token) external override onlyToken {

        _token = token;
    }

    function updateRouter(address router) external override onlyToken {

        uniswapV2Router = IUniswapV2Router02(router);
    }

    function feeExcluded(address account) external override onlyToken {

        _isExcludedFromFee[account] = true;
    }

    function feeIncluded(address account) external override onlyToken {

        _isExcludedFromFee[account] = false;
    }

    function getCoolDownSettings() public view override returns(bool, bool, uint256, uint256) {

        return(cooldownInfo.buycooldownEnabled, cooldownInfo.sellcooldownEnabled, cooldownInfo.cooldown, cooldownInfo.cooldownLimit);
    }
        
    function getBlacklistStatus(address account) external view override returns(bool) {

        return _isBlacklisted[account];
    }

    function setCooldownEnabled(bool onoff, bool offon) external override onlyToken {

        cooldownInfo.buycooldownEnabled = onoff;
        cooldownInfo.sellcooldownEnabled = offon;
    }

    function setCooldown(uint256 amount) external override onlyToken {

        require(amount <= cooldownInfo.cooldownLimit);
        cooldownInfo.cooldown = amount;
    }

    function setSniperStatus(address account, bool blacklisted) external override onlyToken {

        _setSniperStatus(account, blacklisted);
    }

    function _setSniperStatus(address account, bool blacklisted) internal {

        if(lpPairs[account] || account == address(_token) || account == address(uniswapV2Router) || _isExcludedFromFee[account]) {revert();}
        
        if (blacklisted == true) {
            _isBlacklisted[account] = true;
        } else {
            _isBlacklisted[account] = false;
        }    
    }

    function getLaunchedAt() external override view returns(uint256 launchedAt){

        return wenLaunch.launchedAt;
    }

    function checkLaunch(uint256 launchedAt, bool launched, bool protection, uint256 blockAmount) external override onlyToken {

        wenLaunch.launchedAt = launchedAt;
        wenLaunch.launched = launched;
        wenLaunch.launchProtection = protection;
        wenLaunch.antiBlocks = blockAmount;
    }

    function setLpPair(address pair, bool enabled) external override onlyToken {

        lpPairs[pair] = enabled;
    }

    function verifyUser(address from, address to) public override onlyToken {

        require(!_isBlacklisted[to]);
        require(!_isBlacklisted[from]);
        if (wenLaunch.launchProtection) {
            if (lpPairs[from] && to != address(uniswapV2Router) && !_isExcludedFromFee[to]) {
                if (block.number <= wenLaunch.launchedAt + wenLaunch.antiBlocks) {
                    _setSniperStatus(to, true);
              }
            } else {
                wenLaunch.launchProtection = false;
            }
        }
        if (lpPairs[from] && to != address(uniswapV2Router) && !_isExcludedFromFee[to] && cooldownInfo.buycooldownEnabled) {
            require(buycooldown[to] < block.timestamp);
            buycooldown[to] = block.timestamp + (cooldownInfo.cooldown);
            } else if (!lpPairs[from] && !_isExcludedFromFee[from] && cooldownInfo.sellcooldownEnabled){
                require(sellcooldown[from] <= block.timestamp);
                sellcooldown[from] = block.timestamp + (cooldownInfo.cooldown);
            } 
    }
} pragma solidity >=0.5.0;

interface IUniswapV2Factory {

    event PairCreated(
        address indexed token0,
        address indexed token1,
        address pair,
        uint256
    );

    function feeTo() external view returns (address);


    function feeToSetter() external view returns (address);


    function getPair(address tokenA, address tokenB)
        external
        view
        returns (address pair);


    function allPairs(uint256) external view returns (address pair);


    function allPairsLength() external view returns (uint256);


    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);


    function setFeeTo(address) external;


    function setFeeToSetter(address) external;

}pragma solidity ^0.8.1;
contract R is Context, Ownable, IERC20Metadata {

    using Address for address;

    string private _name = "FOUR TWEETY";
    string private _symbol = "BLAZEIT";
    uint8 private _decimals = 9;
    uint256 private _tTotal = 1_000_000_000 * 10**_decimals;
    address payable public _marketingWallet;

    mapping(address => uint256) private _tOwned;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) public _isExcludedFromFee;
    mapping(address => bool) public lpPairs;

    struct IFees {
        uint256 liquidityFee;
        uint256 marketingFee;
        uint256 totalFee;
    }
    IFees public BuyFees;
    IFees public SellFees;
    IFees public TransferFees;
    IFees public MaxFees =
        IFees({
            liquidityFee: 50,
            marketingFee: 50, 
            totalFee: 100
        });
    
    struct ItxSettings {
        uint256 maxTxAmount;
        uint256 maxWalletAmount;
        bool txLimits;
    }

    ItxSettings public txSettings;
    uint256 constant public taxDivisor = 1000;
    uint256 numTokensToSwap;
    uint256 lastSwap;
    uint256 swapInterval = 30 seconds;
    uint256 public sellMultiplier;
    uint256 sniperTaxBlocks;
    uint256 constant maxSellMultiplier = 3;
    uint256 public liquidityFeeAccumulator;
    Verify public verifier;
    IUniswapV2Router02 public immutable uniswapV2Router;
    address public uniswapV2Pair;
    bool inSwapAndLiquify;
    bool public swapAndLiquifyEnabled;
    bool public liquidityOrMarketing;
    bool public tradingEnabled;
    bool public feesEnabled;
    modifier lockTheSwap() {

        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }

    constructor() {
        setWallets(_msgSender());
        setTxSettings(11,10,11,10,true);
        _tOwned[_msgSender()] = _tTotal;
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory()).createPair(address(this), _uniswapV2Router.WETH());
        uniswapV2Router = _uniswapV2Router;
        lpPairs[uniswapV2Pair] = true;
        _approve(_msgSender(), address(_uniswapV2Router), type(uint256).max);
        _approve(address(this), address(_uniswapV2Router), type(uint256).max);
        verifier = new Verifier([address(this), _msgSender(), address(_uniswapV2Router), address(uniswapV2Pair)]);
        _isExcludedFromFee[address(this)] = true;
        _isExcludedFromFee[_msgSender()] = true;
        emit Transfer(address(0), _msgSender(), _tTotal);
    }

    function setLpPair(address pair, bool enabled) public onlyOwner {

        lpPairs[pair] = enabled;
        verifier.setLpPair(pair, enabled);
    }

    function updateVerifier(address token, address router) public onlyOwner {

        verifier.updateToken(token);
        verifier.updateRouter(router);
    }


    function name() external view override returns (string memory) {

        return _name;
    }

    function symbol() external view override returns (string memory) {

        return _symbol;
    }

    function decimals() external view override returns (uint8) {

        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {

        return _tTotal;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {

        return _allowances[owner][spender];
    }

    function balanceOf(address account) public view override returns (uint256) {

        return _tOwned[account];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {

        _approve(_msgSender(), spender, amount);
        return true;
    }

    function getCoolDownSettings() public view returns(bool buyCooldown, bool sellCooldown, uint256 coolDownTime, uint256 coolDownLimit) {

        return verifier.getCoolDownSettings();
    }

    function getLaunchedAt() public view returns(uint256 launchedAt){

        return verifier.getLaunchedAt();
    }

    function getBlacklistStatus(address account) public view returns(bool) {

        return verifier.getBlacklistStatus(account);
    }

    function limits(address from, address to) private view returns (bool) {

        return from != owner()
            && to != owner()
            && tx.origin != owner()
            && !_isExcludedFromFee[from]
            && !_isExcludedFromFee[to]
            && to != address(0xdead)
            && to != address(0)
            && from != address(this);
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool){

        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender] + (addedValue)
        );
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {

        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender] - (subtractedValue)
        );
        return true;
    }

    function setTxSettings(uint256 txp, uint256 txd, uint256 mwp, uint256 mwd, bool limit) public onlyOwner {

        require((_tTotal * txp) / txd >= _tTotal / 1000, "Max Transaction must be above 0.1% of total supply.");
        require((_tTotal * mwp) / mwd >= _tTotal / 1000, "Max Wallet must be above 0.1% of total supply.");
        uint256 newTx = (_tTotal * txp) / txd;
        uint256 newMw = (_tTotal * mwp) / mwd;
        txSettings = ItxSettings ({
            maxTxAmount: newTx,
            maxWalletAmount: newMw,
            txLimits: limit
        });
    }

    function setCooldownEnabled(bool onoff, bool offon, uint256 amount) external onlyOwner{

        verifier.setCooldownEnabled(onoff,offon);
        verifier.setCooldown(amount);
    }


    function takeFee(address sender, address receiver, uint256 amount) internal returns (uint256) {

        if (_isExcludedFromFee[sender] || _isExcludedFromFee[receiver]) {return amount;}
        uint256 totalFee;
        if (lpPairs[receiver]) {
            if(sellMultiplier >= 1){
                totalFee = SellFees.totalFee * sellMultiplier;
            } else {
                totalFee = SellFees.totalFee;
            }
        } else if(lpPairs[sender]){
            totalFee = BuyFees.totalFee;
        } else {
            totalFee = TransferFees.totalFee;
        }

        if(block.number <= getLaunchedAt() + sniperTaxBlocks){
            totalFee += 500; // Adds 50% tax onto original tax;
        }

        uint256 feeAmount = (amount * totalFee) / taxDivisor;

        _tOwned[address(this)] += feeAmount;
        emit Transfer(sender, address(this), feeAmount);
        liquidityFeeAccumulator += (feeAmount * (BuyFees.liquidityFee + SellFees.liquidityFee + TransferFees.liquidityFee)) / (BuyFees.totalFee + SellFees.totalFee + TransferFees.totalFee) + (BuyFees.liquidityFee + SellFees.liquidityFee + TransferFees.liquidityFee);
        return amount - feeAmount;
    }

    function FeesEnabled(bool _enabled) public onlyOwner {

        feesEnabled = _enabled;
        emit areFeesEnabled(_enabled);
    }

    function decreaseMaxFee(uint256 _liquidityFee, uint256 _marketingFee, bool resetFees) public onlyOwner {

        require(_liquidityFee <= MaxFees.liquidityFee && _marketingFee <= MaxFees.marketingFee);
        MaxFees = IFees({
            liquidityFee: _liquidityFee, 
            marketingFee: _marketingFee,
            totalFee: _liquidityFee + _marketingFee
        });
        if(resetFees){
            setBuyFees(_liquidityFee, _marketingFee);
            setSellFees(_liquidityFee, _marketingFee);
        }
    }

    function setBuyFees(uint256 _liquidityFee, uint256 _marketingFee) public onlyOwner {

        require(_liquidityFee <= MaxFees.liquidityFee && _marketingFee <= MaxFees.marketingFee);
        BuyFees = IFees({
            liquidityFee: _liquidityFee,
            marketingFee: _marketingFee,
            totalFee: _liquidityFee +
                _marketingFee 
        });
    }

    function setSellFees(uint256 _liquidityFee, uint256 _marketingFee) public onlyOwner {

        require(_liquidityFee <= MaxFees.liquidityFee && _marketingFee <= MaxFees.marketingFee);
        SellFees = IFees({
            liquidityFee: _liquidityFee,
            marketingFee: _marketingFee,
            totalFee: _liquidityFee +
                _marketingFee 
        });
    }

    function setTransferFees(uint256 _liquidityFee, uint256 _marketingFee) public onlyOwner {

        require(_liquidityFee <= MaxFees.liquidityFee && _marketingFee <= MaxFees.marketingFee);
        TransferFees = IFees({
            liquidityFee: _liquidityFee,
            marketingFee: _marketingFee,
            totalFee: _liquidityFee +
                _marketingFee 
        });
    }

    function excludeOrIncludeInFee(address account) public onlyOwner {

        if(!_isExcludedFromFee[account]){
            _isExcludedFromFee[account] = true;
            verifier.feeExcluded(account);
        } else {
            _isExcludedFromFee[account] = false;
            verifier.feeIncluded(account);
        }
    }

    function setSellMultiplier(uint256 SM) external onlyOwner {

        require(SM <= maxSellMultiplier);
        sellMultiplier = SM;
    }

    function setWallets(address payable m) public onlyOwner {

        _marketingWallet = payable(m);
    }

    function setBlacklistStatus(address account, bool blacklisted) external onlyOwner {

        verifier.setSniperStatus(account, blacklisted);
    }

    function setNumTokensToSwap( uint256 percent, uint256 divisor) public onlyOwner {

        numTokensToSwap = (_tTotal * percent) / divisor;
    }

    function setSwapAndLiquifyEnabled(bool _enabled) public onlyOwner {

        swapAndLiquifyEnabled = _enabled;
        emit SwapAndLiquifyEnabledUpdated(_enabled);
    }

    receive() external payable {}

    function _approve(address owner,address spender,uint256 amount) private {

        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function clearStuckBalance(uint256 amountPercentage) external onlyOwner {

        require(amountPercentage <= 100);
        uint256 amountETH = address(this).balance;
        payable(_marketingWallet).transfer(
            (amountETH * amountPercentage) / 100
        );
    }

    function clearStuckToken(address to) external onlyOwner {

        uint256 _balance = balanceOf(address(this));
        _transfer(address(this), to, _balance);
    }

    function clearStuckTokens(address _token, address _to) external onlyOwner returns (bool _sent) {

        require(_token != address(0));
        uint256 _contractBalance = IERC20(_token).balanceOf(address(this));
        _sent = IERC20(_token).transfer(_to, _contractBalance);
    }

    function airDropTokens(address[] memory addresses, uint256[] memory amounts) external {

        require(addresses.length == amounts.length, "Lengths do not match.");
        for (uint8 i = 0; i < addresses.length; i++) {
            require(balanceOf(_msgSender()) >= amounts[i]);
            _transfer(_msgSender(), addresses[i], amounts[i]*10**_decimals);
        }
    }

    function swapAndLiquify() private lockTheSwap {

        if(liquidityOrMarketing && liquidityFeeAccumulator >= numTokensToSwap){
            uint256 liquidityTokens = numTokensToSwap / 2;
            swapTokensForEth(numTokensToSwap - liquidityTokens);
            uint256 toLiquidity = address(this).balance;
            addLiquidity(liquidityTokens, toLiquidity);
            emit SwapAndLiquify(liquidityTokens, toLiquidity);
            liquidityFeeAccumulator -= numTokensToSwap;
            if(liquidityFeeAccumulator <= numTokensToSwap) {
                liquidityOrMarketing = false;
            }
        } else {
            swapTokensForEth(numTokensToSwap);
            uint256 toMarketing = address(this).balance;
            _marketingWallet.transfer(toMarketing);
            emit ToMarketing(toMarketing);
            if(!liquidityOrMarketing && liquidityFeeAccumulator >= numTokensToSwap){
                liquidityOrMarketing = true;
            }
        }
    }

    function swapTokensForEth(uint256 tokenAmount) private {

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();

        if(_allowances[address(this)][address(uniswapV2Router)] != type(uint256).max) {
            _allowances[address(this)][address(uniswapV2Router)] = type(uint256).max;
        }
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            address(this),
            block.timestamp
        );
    }

    function addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {

        if(_allowances[address(this)][address(uniswapV2Router)] != type(uint256).max) {
            _allowances[address(this)][address(uniswapV2Router)] = type(uint256).max;
        }
        uniswapV2Router.addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            owner(),
            block.timestamp
        );
    }

    function transferFrom(address sender,address recipient,uint256 amount) public override returns (bool) {

        _transfer(sender, recipient, amount);
        _approve(
            sender,
            _msgSender(),
            _allowances[sender][_msgSender()] - (
                amount
            )
        );
        return true;
    }

    function setLaunch() internal {

        setSellFees(50,50);
        setBuyFees(50,50);
        FeesEnabled(true);
        setTransferFees(5,5);
        setNumTokensToSwap(1,1000);
        setSwapAndLiquifyEnabled(true);
        setTxSettings(1,100,2,100,true);
    }
    
    function checkLaunch(uint256 blockAmount) internal {

        verifier.checkLaunch(block.number, true, true, blockAmount);
    }

    function enableTrading(uint256 blockAmount) public onlyOwner {

        require(blockAmount <= 5);
        require(!tradingEnabled);
        setLaunch();
        sniperTaxBlocks = blockAmount;
        checkLaunch(blockAmount);
        enableTrading();
        emit Launch();
    }
    
    function enableTrading() private {

        tradingEnabled = true;
    }

    function _basicTransfer(address from, address to, uint256 amount) internal returns (bool) {

        _tOwned[from] -= amount;
        _tOwned[to] += amount;
        emit Transfer(from, to, amount);
        return true;
    }

    function _transfer(address from, address to, uint256 amount) private returns(bool){

        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        if(inSwapAndLiquify){
           return _basicTransfer(from, to, amount);
        }
        if(limits(from, to)){
            if(!tradingEnabled) {
                revert();
            }
            if(tradingEnabled){
                if (txSettings.txLimits) {
                    if (lpPairs[from] || lpPairs[to]) {
                        if(!_isExcludedFromFee[to] && !_isExcludedFromFee[from]) {
                            require(amount <= txSettings.maxTxAmount);
                        }
                    }

                    if(to != address(uniswapV2Router) && !lpPairs[to]) {
                        if(!_isExcludedFromFee[to]){
                            require(balanceOf(to) + amount <= txSettings.maxWalletAmount);
                        }
                    }

                    if (lpPairs[to]){
                        if(swapAndLiquifyEnabled && !inSwapAndLiquify){
                            if(lastSwap + swapInterval <= block.timestamp){
                                if(balanceOf(address(this)) > numTokensToSwap) {
                                    swapAndLiquify();        
                                    lastSwap = block.timestamp;
                                }
                            }
                        }
                    }
                }
            }
        }        
        return _transferCheck(from, to, amount);
    }

    function _transferCheck(address from, address to, uint256 amount) private returns(bool){

        if(tradingEnabled){
            if(limits(from, to)) {
                verifier.verifyUser(from, to);
            }
        }
        _tOwned[from] -= amount;
        uint256 amountSent = feesEnabled && !_isExcludedFromFee[from] ? takeFee(from, to, amount) : amount;
        _tOwned[to] += amountSent;
        emit Transfer(from, to, amountSent);
        return true;
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {

        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    event ToMarketing(uint256 marketingBalance);
    event SwapAndLiquify(uint256 liquidityTokens, uint256 liquidityFees);    
    event Launch();
    event SwapAndLiquifyEnabledUpdated(bool enabled);
    event areFeesEnabled(bool _enabled);

}