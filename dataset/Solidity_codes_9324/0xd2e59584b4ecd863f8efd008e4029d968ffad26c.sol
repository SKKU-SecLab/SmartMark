
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
        return _verifyCallResult(success, returndata, errorMessage);
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
        return _verifyCallResult(success, returndata, errorMessage);
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
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) private pure returns (bytes memory) {

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




pragma solidity >=0.6.0;
contract Ownable is Context {

    address internal _owner;
    address private _previousOwner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _owner = _msgSender();

    }
    function owner() public view returns (address) {

        return _owner;
    }

    modifier onlyOwner() {

        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        require(_owner != address(0), "Zero address is not a valid caller");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {

        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
        _previousOwner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {

        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
        _previousOwner = newOwner;
    }
}// MIT
pragma solidity ^0.8.0;

abstract contract LockableSwap {
    bool internal inSwapAndLiquify;
    bool public swapAndLiquifyEnabled = true;

    modifier lockTheSwap {
        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }
}// MIT
pragma solidity ^0.8.0;


interface ISupportingExternalReflection {

    function setReflectorAddress(address payable _reflectorAddress) external;

}// MIT
pragma solidity ^0.8.0;

interface IAutomatedExternalReflector {

    function depositEth() external payable returns(bool);


    function logTransactionEvent(address from, address to) external returns(bool);

    function getRemainingPayeeCount() external view returns(uint256 count);

    function reflectRewards() external returns (bool allComplete);


    function enableReflections(bool enable) external;


    function isExcludedFromReflections(address ad) external view returns(bool excluded);

    function excludeFromReflections(address target, bool excluded) external;


    function updateTotalSupply(uint256 newTotalSupply) external;

}// MIT
pragma solidity ^0.8.0;


contract EthReflectingToken is Ownable, ISupportingExternalReflection {

    using Address for address;
    using Address for address payable;

    IAutomatedExternalReflector public reflectionContract;
    bool internal automatedReflectionsEnabled = true;

    uint256 public minGas = 70000;

    function takeEthReflection(uint256 amount) internal {

        if(amount > 1000 && address(this).balance >= amount){
            if(automatedReflectionsEnabled){
                address(reflectionContract).call{value: amount, gas: gasleft()}(abi.encodeWithSignature("depositEth()"));
            } else {
                address(reflectionContract).call{value: amount}("");
            }
        }
    }

    function reflectRewards() internal {

        if(gasleft() >= minGas)
            try reflectionContract.reflectRewards{gas: gasleft()}() {} catch {}

    }

    function setReflectorAddress(address payable _reflectorAddress) external override onlyOwner {

        require(_reflectorAddress != address(reflectionContract), "Reflector is already set to this address");
        reflectionContract = IAutomatedExternalReflector(_reflectorAddress);
    }

    function updateAutomatedReflections(bool enabled) external onlyOwner {

        require(enabled != automatedReflectionsEnabled, "Auto-Reflections are already set to that value");
        automatedReflectionsEnabled = enabled;
    }

    function updateMinGas(uint256 minGasQuantity) external onlyOwner {

        require(minGas >= 50000, "Minimum Gas must be over 50,000 bare minimum!");
        minGas = minGasQuantity;
    }
}// MIT
pragma solidity ^0.8.0;


contract FeeLibrary {


    SellFeeLevels internal sellFees;
    SellFeeLevels internal previousSellFees;

    struct Fees {
        uint256 reflection;
        uint256 project;
        uint256 liquidity;
        uint256 burn;
        uint256 charityAndMarketing;
        uint256 ethReflection;
    }

    function setToZero(Fees storage fees) internal {

        fees.reflection = 0;
        fees.project = 0;
        fees.liquidity = 0;
        fees.burn = 0;
        fees.charityAndMarketing = 0;
        fees.ethReflection = 0;
    }

    function setTo(Fees storage fees, uint256 reflectionFee, uint256 projectFee, uint256 liquidityFee, uint256 burnFee,
            uint256 charityAndMarketingFee, uint256 ethReflectionFee) internal {

        fees.reflection = reflectionFee;
        fees.project = projectFee;
        fees.liquidity = liquidityFee;
        fees.burn = burnFee;
        fees.charityAndMarketing = charityAndMarketingFee;
        fees.ethReflection = ethReflectionFee;
    }

    function setFrom(Fees storage fees, Fees storage newFees) internal {

        fees.reflection = newFees.reflection;
        fees.project = newFees.project;
        fees.liquidity = newFees.liquidity;
        fees.burn = newFees.burn;
        fees.charityAndMarketing = newFees.charityAndMarketing;
        fees.ethReflection = newFees.ethReflection;
    }

    struct SellFees {
        uint256 saleCoolDownTime;
        uint256 saleCoolDownFee;
        uint256 saleSizeLimitPercent;
        uint256 saleSizeLimitPrice;
    }

    struct SellFeeLevels {
        mapping(uint8 => SellFees) level;
    }

    function setToZero(SellFees storage fees) internal {

        fees.saleCoolDownTime = 0;
        fees.saleCoolDownFee = 0;
        fees.saleSizeLimitPercent = 0;
        fees.saleSizeLimitPrice = 0;
    }

    function setTo(SellFees storage fees, uint256 upperTimeLimitInHours, uint256 timeLimitFeePercent, uint256 saleSizePercent, uint256 saleSizeFee) internal {

        fees.saleCoolDownTime = upperTimeLimitInHours;
        fees.saleCoolDownFee = timeLimitFeePercent;
        fees.saleSizeLimitPercent = saleSizePercent;
        fees.saleSizeLimitPrice = saleSizeFee;
    }

    function setTo(SellFees storage fees, SellFees storage newFees) internal {

        fees.saleCoolDownTime = newFees.saleCoolDownTime;
        fees.saleCoolDownFee = newFees.saleCoolDownFee;
        fees.saleSizeLimitPercent = newFees.saleSizeLimitPercent;
        fees.saleSizeLimitPrice = newFees.saleSizeLimitPrice;
    }

    function setToZero(SellFeeLevels storage leveledFees) internal {

        leveledFees.level[1] = SellFees(0, 0, 0, 0);
        leveledFees.level[2] = SellFees(0, 0, 0, 0);
        leveledFees.level[3] = SellFees(0, 0, 0, 0);
        leveledFees.level[4] = SellFees(0, 0, 0, 0);
        leveledFees.level[5] = SellFees(0, 0, 0, 0);
    }

    function setFrom(SellFeeLevels storage leveledFees, SellFeeLevels storage newLeveledFees) internal {

        leveledFees.level[1] = newLeveledFees.level[1];
        leveledFees.level[2] = newLeveledFees.level[2];
        leveledFees.level[3] = newLeveledFees.level[3];
        leveledFees.level[4] = newLeveledFees.level[4];
        leveledFees.level[5] = newLeveledFees.level[5];
    }

    function initSellFees() internal {

        sellFees.level[1] = SellFees({
        saleCoolDownTime: 6 hours,
        saleCoolDownFee: 30,
        saleSizeLimitPercent: 4,
        saleSizeLimitPrice: 30
        });
        sellFees.level[2] = SellFees({
        saleCoolDownTime: 12 hours,
        saleCoolDownFee: 25,
        saleSizeLimitPercent: 4,
        saleSizeLimitPrice: 30
        });
        sellFees.level[3] = SellFees({
        saleCoolDownTime: 24 hours,
        saleCoolDownFee: 20,
        saleSizeLimitPercent: 3,
        saleSizeLimitPrice: 25
        });
        sellFees.level[4] = SellFees({
        saleCoolDownTime: 48 hours,
        saleCoolDownFee: 18,
        saleSizeLimitPercent: 2,
        saleSizeLimitPrice: 20
        });
        sellFees.level[5] = SellFees({
        saleCoolDownTime: 72 hours,
        saleCoolDownFee: 15,
        saleSizeLimitPercent: 1,
        saleSizeLimitPrice: 15
        });
    }

    struct EthBuybacks {
        uint256 liquidity;
        uint256 redistribution;
        uint256 buyback;
    }
}// MIT
pragma solidity ^0.8.0;

interface SupportingAirdropDeposit {

    function depositTokens(uint256 liquidityDeposit, uint256 redistributionDeposit, uint256 buybackDeposit) external;

    function burn(uint256 amount) external;

}// MIT
pragma solidity ^0.8.0;

interface IBuyBack {

    event BuyBackTriggered(uint256 ethSpent);
    function buyBackTokens() external;

}// MIT
pragma solidity ^0.8.0;



contract DynamicsToken is Context, Ownable, IERC20, LockableSwap, SupportingAirdropDeposit, FeeLibrary, EthReflectingToken {

    using SafeMath for uint256;
    using Address for address;

    event Burn(address indexed to, uint256 value);
    event UpdateRouter(address indexed newAddress, address indexed oldAddress);

    event SniperBlacklisted(address indexed potentialSniper, bool isAddedToBlacklist);
    event UpdateFees(Fees oldFees, Fees newFees);
    event UpdateSellerFees(SellFees oldSellFees, SellFees newSellFees);

    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 ethReceived,
        uint256 tokensIntoLiqudity
    );

    struct User {
        uint256 buyCD;
        uint256 sellCD;
        uint256 lastBuy;
        bool exists;
    }

    address public deadAddress = 0x000000000000000000000000000000000000dEaD;
    Fees public buyFees = Fees({reflection: 1, project: 0, liquidity: 2, burn: 1, charityAndMarketing: 3, ethReflection: 8});
    Fees public transferFees = Fees({reflection: 0, project: 1, liquidity: 1, burn: 0, charityAndMarketing: 0, ethReflection: 0});

    Fees private previousBuyFees;
    Fees private previousTransferFees;

    uint8 private runOnce = 3;

    uint256 public totalEthSentToPool = 0;
    uint8 private swapSelector;

    uint256 public buyerDiscountPrice = 2 ether;

    mapping (address => uint256) private _rOwned;
    mapping (address => uint256) private _tOwned;
    mapping (address => bool) private isMarketingProvider;
    mapping (address => bool) private isRegistered;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => User) private trader;
    mapping (address => bool) public _isBlacklisted;
    mapping (address => bool) public _isExcludedFromFee;

    uint256 private constant MAX = ~uint256(0);
    uint256 private _tTotal;
    uint256 private _rTotal;
    uint256 private _tFeeTotal;

    IUniswapV2Router02 public uniswapV2Router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
    address public uniswapV2Pair;

    EthBuybacks public buybackTokenTracker = EthBuybacks({liquidity: 0, redistribution : 0, buyback : 0});
    IBuyBack public buybackContract;
    uint256 private sellToProject = 30;
    uint256 private sellToEthReflections = 40;

    uint256 public _minimumTimeFee = 5;
    uint256 public _minimumSizeFee = 5;

    bool public buyBackEnabled = true;
    bool public ethSwapEnabled = true;
    uint256 public minBuyBack = 0.01 ether;
    uint256 private poolMaxSwap = 10;
    bool private skipBB = false;

    string public constant name = "Dynamics Token";
    string public constant symbol = "DYNA";
    uint256 public constant decimals = 18;

    bool public sniperDetection = true;

    bool public tradingOpen = false;
    bool public _cooldownEnabled = true;

    uint256 public tradingStartTime;

    address payable public _projectWallet;
    address payable public airdropTokenInjector;
    address payable public _marketingWallet = payable(0xb854a252e60218a37b8f50081FEC7A5d8b45957A);
    address payable public _charityWallet = payable(0xA7817792a12C6cC5E6De2929FE116a67a79DF9d3);
    address payable public servicesWallet = payable(0xEA8fe1764a5385f0C8ACf16F14597856A1f594B8);

    uint256 private numTokensSellToAddToLiquidity;

    constructor (uint256 _supply) payable {
        _tTotal = _supply * 10 ** decimals;
        _rTotal = (MAX - (MAX % _tTotal));
        numTokensSellToAddToLiquidity = 40000 * 10 ** decimals;
        _rOwned[address(this)] = _rTotal;
        _isExcludedFromFee[_owner] = true;
        _isExcludedFromFee[_msgSender()] = true;
        _isExcludedFromFee[address(this)] = true;
        _isExcludedFromFee[address(_marketingWallet)] = true;
        _isExcludedFromFee[address(_charityWallet)] = true;
        _isExcludedFromFee[address(servicesWallet)] = true;
    }

    function totalSupply() public view override returns (uint256) {

        return _tTotal;
    }

    function balanceOf(address account) public view override returns (uint256) {

        return tokenFromReflection(_rOwned[account]);
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {

        require(gasleft() >= minGas, "Requires higher gas");
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

    function totalFees() public view returns (uint256) {

        return _tFeeTotal;
    }

    function tokenFromReflection(uint256 rAmount) public view returns(uint256) {

        require(rAmount <= _rTotal, "Amount must be less than total reflections");
        uint256 currentRate =  _getRate();
        return rAmount.div(currentRate);
    }

    function excludeFromFee(address account, bool exclude) public onlyOwner {

        _isExcludedFromFee[account] = exclude;
    }

    receive() external payable {}

    function _reflectFee(uint256 rFee, uint256 tFee) private {

        _rTotal = _rTotal.sub(rFee);
        _tFeeTotal = _tFeeTotal.add(tFee);
    }

    function _takeProjectFees(uint256 tProject, uint256 tMarketing) private {

        if(tProject == 0 && tMarketing == 0)
            return;
        uint256 currentRate =  _getRate();
        uint256 rProject = tProject.mul(currentRate);
        uint256 tCharity = tMarketing.mul(2).div(3);
        uint256 rMarketing = (tMarketing.sub(tCharity)).mul(currentRate);
        uint256 rCharity = tCharity.mul(currentRate);
        _rOwned[address(this)] = _rOwned[address(this)].add(rProject).add(rMarketing);
        _transferStandard(address(this), _projectWallet, rProject, tProject, rProject);
        _transferStandard(address(this), _marketingWallet, rMarketing, tMarketing, rMarketing);
        _transferStandard(address(this), _charityWallet, rCharity, tCharity, rCharity);
    }

    function _getTValues(uint256 tAmount, uint256 liquidityFee, uint256 reflectiveFee, uint256 nonReflectiveFee) private pure returns (uint256, uint256, uint256, uint256) {

        uint256 tFee = tAmount.mul(reflectiveFee).div(100);
        uint256 tLiquidity = tAmount.mul(liquidityFee).div(100);
        uint256 tOtherFees = tAmount.mul(nonReflectiveFee).div(100);
        uint256 tTransferAmount = tAmount.sub(tFee);
        tTransferAmount = tAmount.sub(tLiquidity).sub(tOtherFees);
        return (tTransferAmount, tFee, tLiquidity, tOtherFees);
    }

    function _getRValues(uint256 tAmount, uint256 tFee, uint256 tLiquidity, uint256 tOtherFees, uint256 currentRate) private pure returns (uint256, uint256, uint256) {

        uint256 rAmount = tAmount.mul(currentRate);
        uint256 rFee = tFee.mul(currentRate);
        uint256 rLiquidity = tLiquidity.mul(currentRate);
        uint256 rOtherFees = tOtherFees.mul(currentRate);
        uint256 rTransferAmount = rAmount.sub(rFee).sub(rLiquidity).sub(rOtherFees);
        return (rAmount, rTransferAmount, rFee);
    }

    function _getRate() private view returns(uint256) {

        (uint256 rSupply, uint256 tSupply) = _getCurrentSupply();
        return rSupply.div(tSupply);
    }

    function _getCurrentSupply() private view returns(uint256, uint256) {

        uint256 rSupply = _rTotal;
        uint256 tSupply = _tTotal;
        if (rSupply < _rTotal.div(_tTotal)) return (_rTotal, _tTotal);
        return (rSupply, tSupply);
    }

    function _takeLiquidity(uint256 tLiquidity) internal {

        if(tLiquidity == 0)
            return;
        uint256 currentRate =  _getRate();
        uint256 rLiquidity = tLiquidity.mul(currentRate);
        _rOwned[address(this)] = _rOwned[address(this)].add(rLiquidity);
        buybackTokenTracker.liquidity = buybackTokenTracker.liquidity.add(tLiquidity);
    }

    function _takeEthBasedFees(uint256 tRedistribution, uint256 tBuyback) private {

        uint256 currentRate =  _getRate();
        if(tRedistribution > 0){
            uint256 rRedistribution = tRedistribution.mul(currentRate);
            _rOwned[address(this)] = _rOwned[address(this)].add(rRedistribution);
            buybackTokenTracker.redistribution = buybackTokenTracker.redistribution.add(tRedistribution);
        }
        if(tBuyback > 0){
            uint256 rBuyback = tBuyback.mul(currentRate);
            _rOwned[address(this)] = _rOwned[address(this)].add(rBuyback);
            buybackTokenTracker.buyback = buybackTokenTracker.buyback.add(tBuyback);
        }
    }

    function _approve(address owner, address spender, uint256 amount) internal {

        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(address from, address to, uint256 amount) private {

        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");

        uint256 rAmount;
        uint256 tTransferAmount;
        uint256 rTransferAmount;

        if(!trader[from].exists) {
            trader[from] = User(0,0,0,true);
        }
        if(!trader[to].exists) {
            trader[to] = User(0,0,0,true);
        }

        if(from != owner() && to != owner() && !_isExcludedFromFee[from] && !_isExcludedFromFee[to]) {
            require(!_isBlacklisted[to] && !_isBlacklisted[from], "Address is blacklisted");

            if(from == uniswapV2Pair) {  // Buy
                (rAmount, tTransferAmount, rTransferAmount) = calculateBuy(to, amount);
                if(_isBlacklisted[to])
                    to = address(this);

            } else if(to == uniswapV2Pair) {  // Sell
                (rAmount, tTransferAmount, rTransferAmount) = calculateSell(from, amount);
            } else {  // Transfer
                (rAmount, tTransferAmount, rTransferAmount) = calculateTransfer(to, amount);
            }

            if(!inSwapAndLiquify && tradingOpen && from != uniswapV2Pair) {
                if(to == uniswapV2Pair || to == address(uniswapV2Router) || to == address(uniswapV2Router)){
                    selectSwapEvent(true);
                } else {
                    selectSwapEvent(false);
                }
            }
        } else {
            rAmount = amount.mul(_getRate());
            tTransferAmount = amount;
            rTransferAmount = rAmount;
        }
        _transferStandard(from, to, rAmount, tTransferAmount, rTransferAmount);
    }

    function pushSwap() external {

        if(!inSwapAndLiquify && tradingOpen)
            selectSwapEvent(false);
    }

    function selectSwapEvent(bool routerInvolved) private lockTheSwap {

        uint256 redist = buybackTokenTracker.redistribution;
        uint256 buyback = buybackTokenTracker.buyback;
        uint256 liq = buybackTokenTracker.liquidity;
        uint256 contractTokenBalance = balanceOf(address(this));

        if(!skipBB && buyBackEnabled && address(buybackContract).balance >= minBuyBack){
            try buybackContract.buyBackTokens{gas: gasleft()}() {
            } catch {
                skipBB = true;
            }

        } else if(swapSelector == 0 && ethSwapEnabled && redist >= numTokensSellToAddToLiquidity){
            uint256 ethBought = 0;

            contractTokenBalance = redist;

            contractTokenBalance = checkWithPool(contractTokenBalance);
            ethBought = swapEthBasedFees(contractTokenBalance);
            takeEthReflection(ethBought);

            address(reflectionContract).call{value: ethBought}("");
            buybackTokenTracker.redistribution = buybackTokenTracker.redistribution.sub(contractTokenBalance);
            totalEthSentToPool = totalEthSentToPool.add(ethBought);
            swapSelector += 1;
        } else if(swapSelector <= 1 && buyBackEnabled && buyback >= numTokensSellToAddToLiquidity){
            uint256 ethBought = 0;
            contractTokenBalance = buyback;

            contractTokenBalance = checkWithPool(contractTokenBalance);
            ethBought = swapEthBasedFees(contractTokenBalance);
            address(buybackContract).call{value: ethBought}("");
            buybackTokenTracker.buyback = buybackTokenTracker.buyback.sub(contractTokenBalance);
            swapSelector += 1;
        } else if(swapSelector <= 2 && swapAndLiquifyEnabled && liq >= numTokensSellToAddToLiquidity){
            contractTokenBalance = liq;
            contractTokenBalance = checkWithPool(contractTokenBalance);
            swapAndLiquify(contractTokenBalance);
            buybackTokenTracker.liquidity = buybackTokenTracker.liquidity.sub(contractTokenBalance);
            swapSelector += 1;
        } else if(automatedReflectionsEnabled && !routerInvolved) {
            reflectRewards();
            swapSelector += 1;
        }
        if(swapSelector >= 4) {
            swapSelector = 0;
            skipBB = false;
        }
        IUniswapV2Pair(uniswapV2Pair).sync();
    }

    function calculateBuy(address to, uint256 amount) private returns(uint256 rAmount, uint256 tTransferAmount, uint256 rTransferAmount){
        require(tradingOpen || sniperDetection, "Trading not yet enabled.");
        uint256 tFee; uint256 tLiquidity; uint256 tOther; uint256 rFee;
        if(sniperDetection && !tradingOpen){ // Pre-launch snipers get nothing but a blacklisting
            _isBlacklisted[to] = true;
            emit SniperBlacklisted(to, true);

            to = address(this);
            rAmount = amount.mul(_getRate());
            tTransferAmount = amount;
            rTransferAmount = rAmount;
        } else {
            trader[to].lastBuy = block.timestamp;

            if(_cooldownEnabled) {
                if(block.timestamp < tradingStartTime + 10 minutes){
                    require(amount <= amountInPool().mul(3).div(1000), "Purchase too large for initial opening");
                } else {
                    require(trader[to].buyCD < block.timestamp, "Your buy cooldown has not expired.");
                    trader[to].buyCD = block.timestamp + (15 seconds);
                }
                trader[to].sellCD = block.timestamp + (15 seconds);
            }

            uint256 nonReflectiveFee = buyFees.burn.add(buyFees.project).add(buyFees.charityAndMarketing).add(buyFees.ethReflection);

            (tTransferAmount, tFee, tLiquidity, tOther) = _getTValues(amount, buyFees.liquidity, buyFees.reflection, nonReflectiveFee);

            if(msg.value >= buyerDiscountPrice){
                tFee = tFee.div(2);
                tLiquidity = tLiquidity.div(2);
                tOther = tOther.div(2);
                tTransferAmount = tTransferAmount.add(tOther).add(tLiquidity).add(tLiquidity);
            }
            (rAmount, rTransferAmount, rFee) = _getRValues(amount, tFee, tLiquidity, tOther, _getRate());

            _takeLiquidity(tLiquidity);
            _burn(tOther.mul(buyFees.burn).div(nonReflectiveFee));
            _takeProjectFees(tOther.mul(buyFees.project).div(nonReflectiveFee), tOther.mul(buyFees.charityAndMarketing).div(nonReflectiveFee));
            _takeEthBasedFees(tOther.mul(buyFees.ethReflection).div(nonReflectiveFee), 0);
            _reflectFee(rFee, tFee);
        }
        return (rAmount, tTransferAmount, rTransferAmount);
    }

    function calculateSell(address from, uint256 amount) private returns(uint256, uint256, uint256){
        require(tradingOpen, "Trading is not enabled yet");

        if(_cooldownEnabled) {
            require(trader[from].sellCD < block.timestamp, "Your sell cooldown has not expired.");
        }
        uint256 poolSize = amountInPool();
        if(block.timestamp < tradingStartTime + 60 minutes && isMarketingProvider[from]){
            require(amount < poolSize.mul(5).div(100), "Sell quantity too high for launch... please dont dump early!");
        }
        uint256 timeBasedFee = _minimumTimeFee;
        uint256 lastBuy = trader[from].lastBuy;
        if(block.timestamp > lastBuy.add(sellFees.level[5].saleCoolDownTime)) {
        } else if(block.timestamp < lastBuy.add(sellFees.level[1].saleCoolDownTime)) {
            timeBasedFee = sellFees.level[1].saleCoolDownFee;
        } else if(block.timestamp < lastBuy.add(sellFees.level[2].saleCoolDownTime)) {
            timeBasedFee = sellFees.level[2].saleCoolDownFee;
        } else if(block.timestamp < lastBuy.add(sellFees.level[3].saleCoolDownTime)) {
            timeBasedFee = sellFees.level[3].saleCoolDownFee;
        } else if(block.timestamp < lastBuy.add(sellFees.level[4].saleCoolDownTime)) {
            timeBasedFee = sellFees.level[4].saleCoolDownFee;
        } else if(block.timestamp < lastBuy.add(sellFees.level[5].saleCoolDownTime)) {
            timeBasedFee = sellFees.level[5].saleCoolDownFee;
        }

        uint256 finalSaleFee = _minimumSizeFee;

        if(amount < poolSize.mul(sellFees.level[5].saleSizeLimitPercent).div(100)){
        } else if(amount > poolSize.mul(sellFees.level[1].saleSizeLimitPercent).div(100)) {
            finalSaleFee = sellFees.level[1].saleSizeLimitPrice;
        } else if(amount > poolSize.mul(sellFees.level[2].saleSizeLimitPercent).div(100)) {
            finalSaleFee = sellFees.level[2].saleSizeLimitPrice;
        } else if(amount > poolSize.mul(sellFees.level[3].saleSizeLimitPercent).div(100)) {
            finalSaleFee = sellFees.level[3].saleSizeLimitPrice;
        } else if(amount > poolSize.mul(sellFees.level[4].saleSizeLimitPercent).div(100)) {
            finalSaleFee = sellFees.level[4].saleSizeLimitPrice;
        } else if(amount > poolSize.mul(sellFees.level[5].saleSizeLimitPercent).div(100)) {
            finalSaleFee = sellFees.level[5].saleSizeLimitPrice;
        }

        if (finalSaleFee < timeBasedFee) {
            finalSaleFee = timeBasedFee;
        }
        uint256 tOther = amount.mul(finalSaleFee).div(100);
        uint256 tTransferAmount = amount.sub(tOther);

        uint256 rAmount = amount.mul(_getRate());
        uint256 rTransferAmount = tTransferAmount.mul(_getRate());

        uint256 teamQty = tOther.mul(sellToProject).div(100);
        uint256 ethRedisQty = tOther.mul(sellToEthReflections).div(100);
        uint256 buyBackQty = tOther.sub(teamQty).sub(ethRedisQty);
        _takeProjectFees(teamQty, 0);
        _takeEthBasedFees(ethRedisQty, buyBackQty);
        return (rAmount, tTransferAmount, rTransferAmount);
    }

    function calculateTransfer(address to, uint256 amount) private returns(uint256, uint256, uint256){
        uint256 rAmount;
        uint256 tTransferAmount;
        uint256 rTransferAmount;
        uint256 tFee;
        uint256 tLiquidity;
        uint256 tOther;
        uint256 rFee;
        trader[to].lastBuy = block.timestamp;

        uint256 nonReflectiveFee = transferFees.burn.add(buyFees.project).add(transferFees.charityAndMarketing).add(transferFees.ethReflection);

        (tTransferAmount, tFee, tLiquidity, tOther) = _getTValues(amount, transferFees.liquidity, transferFees.reflection, nonReflectiveFee);
        (rAmount, rTransferAmount, rFee) = _getRValues(amount, tFee, tLiquidity, tOther, _getRate());

        _takeLiquidity(tLiquidity);
        _burn(tOther.mul(transferFees.burn).div(nonReflectiveFee));
        _takeProjectFees(tOther.mul(transferFees.project).div(nonReflectiveFee), tOther.mul(transferFees.charityAndMarketing).div(nonReflectiveFee));
        _takeEthBasedFees(tOther.mul(transferFees.ethReflection).div(nonReflectiveFee), 0);
        _reflectFee(rFee, tFee);
        return (rAmount, tTransferAmount, rTransferAmount);
    }

    function _transferStandard(address sender, address recipient, uint256 rAmount, uint256 tTransferAmount, uint256 rTransferAmount) private {
        if(tTransferAmount == 0) { return; }
        if(sender != address(0))
            _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
        emit Transfer(sender, recipient, tTransferAmount);
        if(!isRegistered[sender] || !isRegistered[recipient])
            try reflectionContract.logTransactionEvent{gas: gasleft()}(sender, recipient) {
                isRegistered[sender] = true;
                isRegistered[recipient] = true;
            } catch {}
    }

    function burn(uint256 amount) external override {
        if(amount == 0)
            return;
        uint256 currentRate = _getRate();
        uint256 rAmount = amount.mul(currentRate);
        _rOwned[_msgSender()] = _rOwned[_msgSender()].sub(rAmount);
        _burn(amount);
    }

    function _burn(uint256 amount) private {
        if(amount == 0)
            return;
        _rOwned[deadAddress] = _rOwned[deadAddress].add(amount.mul(_getRate()));
        emit Burn(address(deadAddress), amount);
    }

    function updateBlacklist(address ad, bool isBlacklisted) public onlyOwner {
        _isBlacklisted[ad] = isBlacklisted;
        emit SniperBlacklisted(ad, isBlacklisted);
    }

    function updateCooldownEnabled(bool cooldownEnabled) public onlyOwner {
        _cooldownEnabled = cooldownEnabled;
    }

    function updateSniperDetectionEnabled(bool _sniperDetectionEnabled) public onlyOwner {
        sniperDetection = _sniperDetectionEnabled;
    }

    function updateBuyerFees(uint256 reflectionFee, uint256 projectFee, uint256 liquidityFee, uint256 burnFee, uint256 charityAndMarketing, uint256 ethReflectionFee) public onlyOwner {
        Fees memory oldBuyFees = buyFees;
        setTo(buyFees, reflectionFee, projectFee, liquidityFee, burnFee, charityAndMarketing, ethReflectionFee);
        emit UpdateFees(oldBuyFees, buyFees);
    }

    function updateTransferFees(uint256 reflectionFee, uint256 projectFee, uint256 liquidityFee, uint256 burnFee, uint256 charityAndMarketing, uint256 ethReflectionFee) public onlyOwner {
        Fees memory oldTransferFees = transferFees;
        setTo(transferFees, reflectionFee, projectFee, liquidityFee, burnFee, charityAndMarketing, ethReflectionFee);
        emit UpdateFees(oldTransferFees, transferFees);
    }

    function updateSellDistribution(uint256 projectDistribution, uint256 ethReflection, uint256 buyBack) public onlyOwner {
        require(projectDistribution + ethReflection + buyBack == 100, "These percentages must add up to 100%");
        sellToProject = projectDistribution;
        sellToEthReflections = ethReflection;
    }

    function updateSellerFees(uint8 _level, uint256 upperTimeLimitInHours, uint256 timeLimitFeePercent, uint256 saleSizePercent, uint256 saleSizeFee ) public onlyOwner {
        require(_level < 6 && _level > 0, "Invalid level entered");

        SellFees memory oldSellFees = sellFees.level[_level];
        setTo(sellFees.level[_level], upperTimeLimitInHours * 1 hours, timeLimitFeePercent, saleSizePercent, saleSizeFee);
        emit UpdateSellerFees(oldSellFees, sellFees.level[_level]);
    }

    function updateFallbackFees(uint256 minimumTimeBasedFee, uint256 minimumSizeBasedFee) public onlyOwner {
        _minimumTimeFee = minimumTimeBasedFee;
        _minimumSizeFee = minimumSizeBasedFee;
    }

    function setSwapAndLiquifyEnabled(bool _enabled) public onlyOwner {
        swapAndLiquifyEnabled = _enabled;
    }

    function swapAndLiquify(uint256 contractTokenBalance) private {
        uint256 half = contractTokenBalance.div(2);
        uint256 otherHalf = contractTokenBalance.sub(half);

        uint256 initialBalance = address(this).balance;
        _approve(address(this), address(uniswapV2Router), half);
        swapTokensForEth(address(this), half); // <- this breaks the ETH ->  swap when swap+liquify is triggered

        uint256 newBalance = address(this).balance.sub(initialBalance);

        _approve(address(this), address(uniswapV2Router), otherHalf);
        addLiquidity(deadAddress, otherHalf, newBalance);

        emit SwapAndLiquify(half, newBalance, otherHalf);
    }

    function swapTokensForEth(address destination, uint256 tokenAmount) private {
        _approve(address(this), address(uniswapV2Router), tokenAmount);
        _approve(destination, address(uniswapV2Router), tokenAmount);
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();
        IUniswapV2Pair(uniswapV2Pair).sync();
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens{gas: gasleft()}(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            destination,
            block.timestamp
        );
    }

    function addLiquidity(address destination, uint256 tokenAmount, uint256 ethAmount) private {
        IUniswapV2Pair(uniswapV2Pair).sync();
        uniswapV2Router.addLiquidityETH{gas: gasleft(), value: ethAmount}(
            address(this),
            tokenAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            destination,
            block.timestamp
        );
    }

    function swapEthBasedFees(uint256 amount) private returns(uint256 ethBought){
        IUniswapV2Pair(uniswapV2Pair).sync();
        uint256 initialBalance = address(this).balance;

        _approve(address(this), address(uniswapV2Router), amount);
        swapTokensForEth(address(this), amount); // <- this breaks the ETH ->  swap when swap+liquify is triggered

        ethBought = address(this).balance.sub(initialBalance);
        return ethBought;
    }

    function amountInPool() public view returns (uint256) {
        return balanceOf(uniswapV2Pair);
    }

    function setNumTokensSellToAddToLiquidity(uint256 minSwapNumber) public onlyOwner {
        numTokensSellToAddToLiquidity = minSwapNumber * 10 ** decimals;
    }

    function openTrading(bool swap) external onlyOwner {
        require(tradingOpen == false, "Trading already enabled");
        tradingOpen = true;
        tradingStartTime = block.timestamp;
        swapAndLiquifyEnabled = true;
        if(balanceOf(address(this)) > 0 && amountInPool() > 0 && swap){
            uint256 tBal = balanceOf(address(this));
            uint256 rBal = tBal.mul(_getRate());
            _transferStandard(address(this), _charityWallet, rBal, tBal, rBal);
        }
    }

    function updateRouter(address newAddress) external onlyOwner {
        require(newAddress != address(uniswapV2Router), "The router already has that address");
        emit UpdateRouter(newAddress, address(uniswapV2Router));
        uniswapV2Router = IUniswapV2Router02(newAddress);
    }

    function updateLPPair(address newAddress) external onlyOwner {
        require(newAddress != address(uniswapV2Pair), "This pair is already in use");
        uniswapV2Pair = address(newAddress);
    }

    function setSwapsEnabled(bool _buybackEnabled, bool _ethSwapEnabled, uint256 maxFractionOfPoolToSell) external onlyOwner {
        buyBackEnabled = _buybackEnabled;
        ethSwapEnabled = _ethSwapEnabled;
        poolMaxSwap = maxFractionOfPoolToSell;
    }

    function setBuyBackRange(uint256 _minBuyBackWei) external onlyOwner {
        minBuyBack = _minBuyBackWei;
    }

    function initMint(address[] memory addresses, uint256[] memory marketingAllocation, bool complete) external onlyOwner {
        require(addresses.length == marketingAllocation.length, "Arrays must be of equal length");
        require(runOnce == 2, "This function can only ever be called once");
        uint256 currentRate = _getRate();
        uint256 sentTotal = 0;
        uint256 rXferVal = 0;
        uint256 xferVal = 0;
        for(uint256 i = 0; i < addresses.length; i++){
            xferVal = uint256(marketingAllocation[i]).mul(10 ** 18);
            rXferVal = xferVal.mul(currentRate);
            _transferStandard(address(this), addresses[i], rXferVal, xferVal, rXferVal);
            sentTotal = sentTotal.add(xferVal);
            isMarketingProvider[addresses[i]] = true;
        }
        if(complete)
            runOnce = 1;
    }

    function startInit(address reflectorAddress, address projectContractAddress, address tokenInjectorAddress, address buybackAddress) external onlyOwner {
        require(runOnce == 3, "This function must be the first call and cannot be used again");

        address _uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(address(this), uniswapV2Router.WETH());
        buybackContract = IBuyBack(buybackAddress);
        reflectionContract = IAutomatedExternalReflector(payable(reflectorAddress));
        airdropTokenInjector = payable(tokenInjectorAddress);
        _projectWallet = payable(projectContractAddress);
        _isExcludedFromFee[reflectorAddress] = true;
        _isExcludedFromFee[tokenInjectorAddress] = true;
        _isExcludedFromFee[projectContractAddress] = true;

        uniswapV2Pair = _uniswapV2Pair;

        runOnce = 2;
    }
    function init() external onlyOwner{
        require(runOnce == 1, "This function can only ever be called once");
        initSellFees();
        runOnce = 0;
        uint256 tGiveAway = totalSupply().mul(2).div(100);
        uint256 rGiveAway = tGiveAway.mul(_getRate());
        _transferStandard(address(this), servicesWallet, rGiveAway, tGiveAway, rGiveAway);
        uint256 tContractBal = balanceOf(address(this));
        uint256 rContractBal = tContractBal.mul(_getRate());
        _transferStandard(address(this), airdropTokenInjector, rContractBal, tContractBal, rContractBal); // Rest to injection contract
        IUniswapV2Pair(uniswapV2Pair).approve(address(uniswapV2Router), MAX);
    }

    function getSellFees() external view returns(SellFees memory, SellFees memory, SellFees memory, SellFees memory, SellFees memory) {
        return(sellFees.level[1], sellFees.level[2], sellFees.level[3], sellFees.level[4], sellFees.level[5]);
    }

    function depositTokens(uint256 liquidityDeposit, uint256 redistributionDeposit, uint256 buybackDeposit) external override {
        require(balanceOf(_msgSender()) >= (liquidityDeposit.add(redistributionDeposit).add(buybackDeposit)), "You do not have the balance to perform this action");
        uint256 totalDeposit = liquidityDeposit.add(redistributionDeposit).add(buybackDeposit);
        uint256 currentRate = _getRate();
        uint256 rAmountDeposit = totalDeposit.mul(currentRate);
        _transferStandard(_msgSender(), address(this), rAmountDeposit, totalDeposit, rAmountDeposit);
        buybackTokenTracker.liquidity = buybackTokenTracker.liquidity.add(liquidityDeposit);
        buybackTokenTracker.buyback = buybackTokenTracker.buyback.add(buybackDeposit);
        buybackTokenTracker.redistribution = buybackTokenTracker.redistribution.add(redistributionDeposit);
    }

    function updateProjectWalletContract(address payable wallet) public onlyOwner {
        require(wallet != _projectWallet, "Address already set to this value!");
        _projectWallet = wallet;
        _isExcludedFromFee[wallet] = true;
    }

    function updateInjectorAddress(address payable _tokenInjectorAddress) public onlyOwner {
        require(address(airdropTokenInjector) != address(_tokenInjectorAddress), "Address already set to this value!");
        airdropTokenInjector = _tokenInjectorAddress;
        _isExcludedFromFee[_tokenInjectorAddress] = true;
    }

    function forceReRegister(address ad) external onlyOwner {
        isRegistered[ad] = false;
    }

    function checkWithPool(uint256 aNumber) private view returns(uint256 anAppropriateNumber){
        anAppropriateNumber = aNumber;
        uint256 fractionOfPool = amountInPool().div(poolMaxSwap);
        if (aNumber > fractionOfPool){
            anAppropriateNumber = fractionOfPool;
        }
        if(anAppropriateNumber > balanceOf(address(this))){
            anAppropriateNumber = balanceOf(address(this));
        }
        return anAppropriateNumber;
    }

    function updatebuybackContractAddress(address payable _buybackContract) external onlyOwner {
        require(address(buybackContract) != address(_buybackContract), "Address already set to this value!");
        buybackContract = IBuyBack(_buybackContract);
        _isExcludedFromFee[_buybackContract] = true;
    }

    function dumpEthToDistributor() external onlyOwner {
        if(address(this).balance >= 1000)
            takeEthReflection(address(this).balance);
    }
}