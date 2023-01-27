
pragma solidity ^0.6.0;

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
pragma solidity >=0.6.12;
interface iCHI is IERC20 {

    function freeFromUpTo(address from, uint256 value) external returns (uint256);

}// MIT
pragma solidity ^0.6.6;

interface IKeep3rV1Helper {

    function getQuoteLimit(uint gasUsed) external view returns (uint);

}//MIT

pragma solidity ^0.6.12;
interface IKeep3rV1Mini {

    function isKeeper(address) external returns (bool);

    function worked(address keeper) external;

    function totalBonded() external view returns (uint);

    function bonds(address keeper, address credit) external view returns (uint);

    function votes(address keeper) external view returns (uint);

    function isMinKeeper(address keeper, uint minBond, uint earned, uint age) external returns (bool);

    function addCreditETH(address job) external payable;

    function credits(address job, address credit) external view returns (uint);

    function receipt(address credit, address keeper, uint amount) external;

    function ETH() external view returns (address);

    function receiptETH(address keeper, uint amount) external;

}// MIT

pragma solidity ^0.6.12;
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

}// MIT
pragma solidity ^0.6.6;

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

}// MIT
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

}// MIT
pragma solidity >=0.6.2;


interface IUniswapV2Router is IUniswapV2Router01 {

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

pragma solidity >=0.5.0;

interface IWETH is IERC20{

    function deposit() external payable;

    function withdraw(uint) external;

}// MIT

pragma solidity ^0.6.12;

library FixedPoint {

    struct uq112x112 {
        uint224 _x;
    }

    struct uq144x112 {
        uint _x;
    }

    uint8 private constant RESOLUTION = 112;

    function encode(uint112 x) internal pure returns (uq112x112 memory) {

        return uq112x112(uint224(x) << RESOLUTION);
    }

    function encode144(uint144 x) internal pure returns (uq144x112 memory) {

        return uq144x112(uint256(x) << RESOLUTION);
    }

    function div(uq112x112 memory self, uint112 x) internal pure returns (uq112x112 memory) {

        require(x != 0, 'FixedPoint: DIV_BY_ZERO');
        return uq112x112(self._x / uint224(x));
    }

    function mul(uq112x112 memory self, uint y) internal pure returns (uq144x112 memory) {

        uint z;
        require(y == 0 || (z = uint(self._x) * y) / y == uint(self._x), "FixedPoint: MULTIPLICATION_OVERFLOW");
        return uq144x112(z);
    }

    function fraction(uint112 numerator, uint112 denominator) internal pure returns (uq112x112 memory) {

        require(denominator > 0, "FixedPoint: DIV_BY_ZERO");
        return uq112x112((uint224(numerator) << RESOLUTION) / denominator);
    }

    function decode(uq112x112 memory self) internal pure returns (uint112) {

        return uint112(self._x >> RESOLUTION);
    }

    function decode144(uq144x112 memory self) internal pure returns (uint144) {

        return uint144(self._x >> RESOLUTION);
    }
}// MIT

pragma solidity ^0.6.0;

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

pragma solidity ^0.6.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}// MIT

pragma solidity ^0.6.0;

contract Ownable is Context {

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

pragma solidity ^0.6.2;

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

        return _functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {

        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {

        require(address(this).balance >= value, "Address: insufficient balance for call");
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(address target, bytes memory data, uint256 weiValue, string memory errorMessage) private returns (bytes memory) {

        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{ value: weiValue }(data);
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

pragma solidity ^0.6.12;


library UniswapV2OracleLibrary {

    using FixedPoint for *;

    function currentBlockTimestamp() internal view returns (uint32) {

        return uint32(block.timestamp % 2 ** 32);
    }

    function currentCumulativePrices(
        address pair
    ) internal view returns (uint price0Cumulative, uint price1Cumulative, uint32 blockTimestamp) {

        blockTimestamp = currentBlockTimestamp();
        price0Cumulative = IUniswapV2Pair(pair).price0CumulativeLast();
        price1Cumulative = IUniswapV2Pair(pair).price1CumulativeLast();

        (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast) = IUniswapV2Pair(pair).getReserves();
        if (blockTimestampLast != blockTimestamp) {
            uint32 timeElapsed = blockTimestamp - blockTimestampLast;
            price0Cumulative += uint(FixedPoint.fraction(reserve1, reserve0)._x) * timeElapsed;
            price1Cumulative += uint(FixedPoint.fraction(reserve0, reserve1)._x) * timeElapsed;
        }
    }
}// MIT

pragma solidity ^0.6.12;

library UniswapV2Library {

    using SafeMath for uint;

    function sortTokens(address tokenA, address tokenB) internal pure returns (address token0, address token1) {

        require(tokenA != tokenB, 'UniswapV2Library: IDENTICAL_ADDRESSES');
        (token0, token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        require(token0 != address(0), 'UniswapV2Library: ZERO_ADDRESS');
    }

    function pairFor(address factory, address tokenA, address tokenB) internal pure returns (address pair) {

        (address token0, address token1) = sortTokens(tokenA, tokenB);
        pair = address(uint(keccak256(abi.encodePacked(
                hex'ff',
                factory,
                keccak256(abi.encodePacked(token0, token1)),
                hex'96e8ac4277198ff8b6f785478aa9a39f403cb768dd02cbee326c3e7da348845f' // init code hash
            ))));
    }

    function getReserves(address factory, address tokenA, address tokenB) internal view returns (uint reserveA, uint reserveB) {

        (address token0,) = sortTokens(tokenA, tokenB);
        (uint reserve0, uint reserve1,) = IUniswapV2Pair(pairFor(factory, tokenA, tokenB)).getReserves();
        (reserveA, reserveB) = tokenA == token0 ? (reserve0, reserve1) : (reserve1, reserve0);
    }

    function quote(uint amountA, uint reserveA, uint reserveB) internal pure returns (uint amountB) {

        require(amountA > 0, 'UniswapV2Library: INSUFFICIENT_AMOUNT');
        require(reserveA > 0 && reserveB > 0, 'UniswapV2Library: INSUFFICIENT_LIQUIDITY');
        amountB = amountA.mul(reserveB) / reserveA;
    }

    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) internal pure returns (uint amountOut) {

        require(amountIn > 0, 'UniswapV2Library: INSUFFICIENT_INPUT_AMOUNT');
        require(reserveIn > 0 && reserveOut > 0, 'UniswapV2Library: INSUFFICIENT_LIQUIDITY');
        uint amountInWithFee = amountIn.mul(997);
        uint numerator = amountInWithFee.mul(reserveOut);
        uint denominator = reserveIn.mul(1000).add(amountInWithFee);
        amountOut = numerator / denominator;
    }

    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) internal pure returns (uint amountIn) {

        require(amountOut > 0, 'UniswapV2Library: INSUFFICIENT_OUTPUT_AMOUNT');
        require(reserveIn > 0 && reserveOut > 0, 'UniswapV2Library: INSUFFICIENT_LIQUIDITY');
        uint numerator = reserveIn.mul(amountOut).mul(1000);
        uint denominator = reserveOut.sub(amountOut).mul(997);
        amountIn = (numerator / denominator).add(1);
    }

    function getAmountsOut(address factory, uint amountIn, address[] memory path) internal view returns (uint[] memory amounts) {

        require(path.length >= 2, 'UniswapV2Library: INVALID_PATH');
        amounts = new uint[](path.length);
        amounts[0] = amountIn;
        for (uint i; i < path.length - 1; i++) {
            (uint reserveIn, uint reserveOut) = getReserves(factory, path[i], path[i + 1]);
            amounts[i + 1] = getAmountOut(amounts[i], reserveIn, reserveOut);
        }
    }

    function getAmountsIn(address factory, uint amountOut, address[] memory path) internal view returns (uint[] memory amounts) {

        require(path.length >= 2, 'UniswapV2Library: INVALID_PATH');
        amounts = new uint[](path.length);
        amounts[amounts.length - 1] = amountOut;
        for (uint i = path.length - 1; i > 0; i--) {
            (uint reserveIn, uint reserveOut) = getReserves(factory, path[i - 1], path[i]);
            amounts[i - 1] = getAmountIn(amounts[i], reserveIn, reserveOut);
        }
    }
}// MIT
pragma solidity ^0.6.12;
pragma experimental ABIEncoderV2;

interface IKeep3rV1Plus is IKeep3rV1Mini {

    function unbond(address bonding, uint amount) external;

    function withdraw(address bonding) external;

    function unbondings(address keeper, address credit) external view returns (uint);

    function approve(address spender, uint amount) external returns (bool);

    function jobs(address job) external view returns (bool);

    function balanceOf(address account) external view returns (uint256);

    function KPRH() external view returns (IKeep3rV1Helper);

}

interface IOracle {

    function pairs() external view returns (address[] memory);

}

contract RelayerV1OracleCustom is Ownable {

    using FixedPoint for *;
    using SafeMath for uint;

    uint public CHIFEE = 5000;
    uint public DFEE = 1000;
    uint public RDEC = 2000;

    uint constant public BASE = 10000;

    struct Observation {
        uint timestamp;
        uint price0Cumulative;
        uint price1Cumulative;
    }

    uint public minKeep = 200e18;

    modifier keeper() {

        require(RLR.isMinKeeper(msg.sender, minKeep, 0, 0), "::isKeeper:!relayer");
        _;
    }

    modifier upkeep() {

        uint _gasUsed = gasleft();
        require(RLR.isMinKeeper(msg.sender, minKeep, 0, 0), "::isKeeper:!relayer");
        _;
        uint256 gasDiff = _gasUsed.sub(gasleft());
        uint256 gasSpent = 21000 + gasDiff + 16 * msg.data.length;
        CHI.freeFromUpTo(address(this), (gasSpent + 14154) / 41947);

        uint _reward = RLR.KPRH().getQuoteLimit(gasDiff);
        _reward = _reward.sub(getReduction(_reward));
        uint chiBudget = getChiBudget(_reward);
        RLR.receipt(address(RLR), address(this), _reward.add(chiBudget));

        _reward = _swap(_reward,chiBudget);
        uint256 _rewardAfterSub = _reward.sub(_reward.mul(DFEE).div(BASE));
        Address.sendValue(payable(msg.sender),_rewardAfterSub);
        Address.sendValue(payable(owner()),address(this).balance);
    }

    modifier onlyGovernance {

        require(msg.sender == governance,"!governance");
        _;
    }

    address public governance;
    address public pendingGovernance;

    function getChiBudget(uint amount) internal view returns (uint) {

        return amount.mul(CHIFEE).div(BASE);
    }

    function getReduction(uint amount) internal view returns (uint) {

        return amount.mul(RDEC).div(BASE);
    }

    function setChiBudget(uint newBudget) public onlyOwner {

        CHIFEE = newBudget;
    }

    function setDBudget(uint newBudget) public onlyOwner {

        DFEE = newBudget;
    }

    function setReduction(uint newRed) public onlyOwner {

        RDEC = newRed;
    }

    function setMinKeep(uint _keep) external onlyGovernance {

        minKeep = _keep;
    }

    function setGovernance(address _governance) external onlyGovernance {

        pendingGovernance = _governance;
    }

    function acceptGovernance() external {

        require(msg.sender == pendingGovernance, "acceptGovernance: !pendingGov");
        governance = pendingGovernance;
    }

    IKeep3rV1Plus public RLR = IKeep3rV1Plus(0x5b3F693EfD5710106eb2Eac839368364aCB5a70f);
    IWETH public constant WETH = IWETH(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
    IUniswapV2Router public constant UNI = IUniswapV2Router(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
    iCHI public CHI = iCHI(0x0000000000004946c0e9F43F4Dee607b0eF1fA1c);

    address public constant factory = 0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f;
    uint public constant periodSize = 1800;

    address[] internal _pairs;
    mapping(address => bool) internal _known;

    function pairs() external view returns (address[] memory) {

        return _pairs;
    }

    mapping(address => Observation[]) public observations;

    function observationLength(address pair) external view returns (uint) {

        return observations[pair].length;
    }

    function pairFor(address tokenA, address tokenB) external pure returns (address) {

        return UniswapV2Library.pairFor(factory, tokenA, tokenB);
    }

    function pairForWETH(address tokenA) external pure returns (address) {

        return UniswapV2Library.pairFor(factory, tokenA, address(WETH));
    }

    constructor(address rlrtoken) public {
        governance = msg.sender;
        require(CHI.approve(address(this), uint256(-1)));
        RLR = IKeep3rV1Plus(rlrtoken);
        require(RLR.approve(address(UNI), uint256(-1)));

    }

    function updatePair(address pair) external keeper returns (bool) {

        return _update(pair);
    }

    function update(address tokenA, address tokenB) external keeper returns (bool) {

        address pair = UniswapV2Library.pairFor(factory, tokenA, tokenB);
        return _update(pair);
    }

    function _addPair(address pair) internal {

        require(!_known[pair], "known");
        _known[pair] = true;
        _pairs.push(pair);

        (uint price0Cumulative, uint price1Cumulative,) = UniswapV2OracleLibrary.currentCumulativePrices(pair);
        observations[pair].push(Observation(block.timestamp, price0Cumulative, price1Cumulative));
    }

    function addPair(address pair) public onlyGovernance {

        _addPair(pair);
    }

    function importPairs(address oracle) public onlyGovernance {

        batchAddPairs(IOracle(oracle).pairs());
    }

    function batchAddPairs(address[] memory pairsToAdd) public onlyGovernance {

        for(uint i=0;i<pairsToAdd.length;i++)
            _addPair(pairsToAdd[i]);
    }

    function add(address tokenA, address tokenB) external {

        addPair(UniswapV2Library.pairFor(factory, tokenA, tokenB));
    }

    function work() public upkeep {

        bool worked = _updateAll();
        require(worked, "UniswapV2Oracle: !work");
    }

    function workForFree() public keeper {

        bool worked = _updateAll();
        require(worked, "UniswapV2Oracle: !work");
    }

    function lastObservation(address pair) public view returns (Observation memory) {

        return observations[pair][observations[pair].length-1];
    }

    function _updateAll() internal returns (bool updated) {

        for (uint i = 0; i < _pairs.length; i++) {
            if (_update(_pairs[i])) {
                updated = true;
            }
        }
    }

    function updateFor(uint i, uint length) external keeper returns (bool updated) {

        for (; i < length; i++) {
            if (_update(_pairs[i])) {
                updated = true;
            }
        }
    }

    function workable(address pair) public view returns (bool) {

        return (block.timestamp - lastObservation(pair).timestamp) > periodSize;
    }

    function workable() external view returns (bool) {

        for (uint i = 0; i < _pairs.length; i++) {
            if (workable(_pairs[i])) {
                return true;
            }
        }
        return false;
    }

    function _update(address pair) internal returns (bool) {

        Observation memory _point = lastObservation(pair);
        uint timeElapsed = block.timestamp - _point.timestamp;
        if (timeElapsed > periodSize) {
            (uint price0Cumulative, uint price1Cumulative,) = UniswapV2OracleLibrary.currentCumulativePrices(pair);
            observations[pair].push(Observation(block.timestamp, price0Cumulative, price1Cumulative));
            return true;
        }
        return false;
    }

    function computeAmountOut(
        uint priceCumulativeStart, uint priceCumulativeEnd,
        uint timeElapsed, uint amountIn
    ) private pure returns (uint amountOut) {

        FixedPoint.uq112x112 memory priceAverage = FixedPoint.uq112x112(
            uint224((priceCumulativeEnd - priceCumulativeStart) / timeElapsed)
        );
        amountOut = priceAverage.mul(amountIn).decode144();
    }

    function _valid(address pair, uint age) internal view returns (bool) {

        return (block.timestamp - lastObservation(pair).timestamp) <= age;
    }

    function current(address tokenIn, uint amountIn, address tokenOut) external view returns (uint amountOut) {

        address pair = UniswapV2Library.pairFor(factory, tokenIn, tokenOut);
        require(_valid(pair, periodSize.mul(2)), "UniswapV2Oracle::quote: stale prices");
        (address token0,) = UniswapV2Library.sortTokens(tokenIn, tokenOut);

        Observation memory _observation = lastObservation(pair);
        (uint price0Cumulative, uint price1Cumulative,) = UniswapV2OracleLibrary.currentCumulativePrices(pair);
        if (block.timestamp == _observation.timestamp) {
            _observation = observations[pair][observations[pair].length-2];
        }

        uint timeElapsed = block.timestamp - _observation.timestamp;
        timeElapsed = timeElapsed == 0 ? 1 : timeElapsed;
        if (token0 == tokenIn) {
            return computeAmountOut(_observation.price0Cumulative, price0Cumulative, timeElapsed, amountIn);
        } else {
            return computeAmountOut(_observation.price1Cumulative, price1Cumulative, timeElapsed, amountIn);
        }
    }

    function quote(address tokenIn, uint amountIn, address tokenOut, uint granularity) external view returns (uint amountOut) {

        address pair = UniswapV2Library.pairFor(factory, tokenIn, tokenOut);
        require(_valid(pair, periodSize.mul(granularity)), "UniswapV2Oracle::quote: stale prices");
        (address token0,) = UniswapV2Library.sortTokens(tokenIn, tokenOut);

        uint priceAverageCumulative = 0;
        uint length = observations[pair].length-1;
        uint i = length.sub(granularity);


        uint nextIndex = 0;
        if (token0 == tokenIn) {
            for (; i < length; i++) {
                nextIndex = i+1;
                priceAverageCumulative += computeAmountOut(
                    observations[pair][i].price0Cumulative,
                    observations[pair][nextIndex].price0Cumulative,
                    observations[pair][nextIndex].timestamp - observations[pair][i].timestamp, amountIn);
            }
        } else {
            for (; i < length; i++) {
                nextIndex = i+1;
                priceAverageCumulative += computeAmountOut(
                    observations[pair][i].price1Cumulative,
                    observations[pair][nextIndex].price1Cumulative,
                    observations[pair][nextIndex].timestamp - observations[pair][i].timestamp, amountIn);
            }
        }
        return priceAverageCumulative.div(granularity);
    }

    function prices(address tokenIn, uint amountIn, address tokenOut, uint points) external view returns (uint[] memory) {

        return sample(tokenIn, amountIn, tokenOut, points, 1);
    }

    function sample(address tokenIn, uint amountIn, address tokenOut, uint points, uint window) public view returns (uint[] memory) {

        address pair = UniswapV2Library.pairFor(factory, tokenIn, tokenOut);
        (address token0,) = UniswapV2Library.sortTokens(tokenIn, tokenOut);
        uint[] memory _prices = new uint[](points);

        uint length = observations[pair].length-1;
        uint i = length.sub(points * window);
        uint nextIndex = 0;
        uint index = 0;

        if (token0 == tokenIn) {
            for (; i < length; i+=window) {
                nextIndex = i + window;
                _prices[index] = computeAmountOut(
                    observations[pair][i].price0Cumulative,
                    observations[pair][nextIndex].price0Cumulative,
                    observations[pair][nextIndex].timestamp - observations[pair][i].timestamp, amountIn);
                index = index + 1;
            }
        } else {
            for (; i < length; i+=window) {
                nextIndex = i + window;
                _prices[index] = computeAmountOut(
                    observations[pair][i].price1Cumulative,
                    observations[pair][nextIndex].price1Cumulative,
                    observations[pair][nextIndex].timestamp - observations[pair][i].timestamp, amountIn);
                index = index + 1;
            }
        }
        return _prices;
    }

    function hourly(address tokenIn, uint amountIn, address tokenOut, uint points) external view returns (uint[] memory) {

        return sample(tokenIn, amountIn, tokenOut, points, 2);
    }

    function daily(address tokenIn, uint amountIn, address tokenOut, uint points) external view returns (uint[] memory) {

        return sample(tokenIn, amountIn, tokenOut, points, 48);
    }

    function weekly(address tokenIn, uint amountIn, address tokenOut, uint points) external view returns (uint[] memory) {

        return sample(tokenIn, amountIn, tokenOut, points, 336);
    }

    function realizedVolatility(address tokenIn, uint amountIn, address tokenOut, uint points, uint window) external view returns (uint) {

        return stddev(sample(tokenIn, amountIn, tokenOut, points, window));
    }

    function realizedVolatilityHourly(address tokenIn, uint amountIn, address tokenOut) external view returns (uint) {

        return stddev(sample(tokenIn, amountIn, tokenOut, 1, 2));
    }

    function realizedVolatilityDaily(address tokenIn, uint amountIn, address tokenOut) external view returns (uint) {

        return stddev(sample(tokenIn, amountIn, tokenOut, 1, 48));
    }

    function realizedVolatilityWeekly(address tokenIn, uint amountIn, address tokenOut) external view returns (uint) {

        return stddev(sample(tokenIn, amountIn, tokenOut, 1, 336));
    }

    function sqrt(uint256 x) public pure returns (uint256) {

        uint256 c = (x + 1) / 2;
        uint256 b = x;
        while (c < b) {
            b = c;
            c = (x / c + c) / 2;
        }
        return b;
    }

    function stddev(uint[] memory numbers) public pure returns (uint256 sd) {

        uint sum = 0;
        for(uint i = 0; i < numbers.length; i++) {
            sum += numbers[i];
        }
        uint256 mean = sum / numbers.length;        // Integral value; float not supported in Solidity
        sum = 0;
        uint i;
        for(i = 0; i < numbers.length; i++) {
            sum += (numbers[i] - mean) ** 2;
        }
        sd = sqrt(sum / (numbers.length - 1));      //Integral value; float not supported in Solidity
        return sd;
    }


    function blackScholesEstimate(
        uint256 _vol,
        uint256 _underlying,
        uint256 _time
    ) public pure returns (uint256 estimate) {

        estimate = 40 * _vol * _underlying * sqrt(_time);
        return estimate;
    }

    function retBasedBlackScholesEstimate(
        uint256[] memory _numbers,
        uint256 _underlying,
        uint256 _time
    ) public pure {

        uint _vol = stddev(_numbers);
        blackScholesEstimate(_vol, _underlying, _time);
    }

    receive() external payable {}

    function _swap(uint _amount,uint chiBudget) internal returns (uint) {

        address[] memory path = new address[](2);
        path[0] = address(RLR);
        path[1] = address(WETH);
        uint[] memory amounts = UNI.swapExactTokensForTokens(_amount, uint256(0), path, address(this), now.add(1800));
        WETH.withdraw(amounts[1]);

        address[] memory pathtoChi = new address[](3);

        pathtoChi[0] = address(RLR);
        pathtoChi[1] = address(WETH);
        pathtoChi[2] = address(CHI);
        UNI.swapExactTokensForTokens(chiBudget, uint256(0), pathtoChi, address(this), now.add(1800));

        return amounts[1];
    }

    function getTokenBalance(address tokenAddress) public view returns (uint256) {

        return IERC20(tokenAddress).balanceOf(address(this));
    }

    function sendERC20(address tokenAddress,address receiver) internal {

        IERC20(tokenAddress).transfer(receiver, getTokenBalance(tokenAddress));
    }

    function recoverERC20(address token) public onlyOwner {

        sendERC20(token,owner());
    }

    function destructJob() public onlyOwner {

     uint256 currRLRCreds = RLR.credits(address(this),address(RLR));
     uint256 currETHCreds = RLR.credits(address(this),RLR.ETH());
     if(currRLRCreds > 0) {
        RLR.receipt(address(RLR),owner(),currRLRCreds);
     }
     if (currETHCreds > 0) {
        RLR.receiptETH(owner(),currETHCreds);
     }
     recoverERC20(address(CHI));
     selfdestruct(payable(owner()));
    }
}