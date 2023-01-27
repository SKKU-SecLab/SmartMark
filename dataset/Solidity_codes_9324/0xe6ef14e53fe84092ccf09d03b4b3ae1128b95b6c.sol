pragma solidity >=0.4.24 <0.7.0;


contract Initializable {


  bool private initialized;

  bool private initializing;

  modifier initializer() {

    require(initializing || isConstructor() || !initialized, "Contract instance has already been initialized");

    bool isTopLevelCall = !initializing;
    if (isTopLevelCall) {
      initializing = true;
      initialized = true;
    }

    _;

    if (isTopLevelCall) {
      initializing = false;
    }
  }

  function isConstructor() private view returns (bool) {

    address self = address(this);
    uint256 cs;
    assembly { cs := extcodesize(self) }
    return cs == 0;
  }

  uint256[50] private ______gap;
}
pragma solidity ^0.6.0;

contract ContextUpgradeSafe is Initializable {


    function __Context_init() internal initializer {

        __Context_init_unchained();
    }

    function __Context_init_unchained() internal initializer {



    }


    function _msgSender() internal view virtual returns (address payable) {

        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {

        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }

    uint256[50] private __gap;
}
pragma solidity ^0.6.0;

contract OwnableUpgradeSafe is Initializable, ContextUpgradeSafe {

    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


    function __Ownable_init() internal initializer {

        __Context_init_unchained();
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal initializer {



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

    uint256[49] private __gap;
}
pragma solidity ^0.6.0;

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
}
pragma solidity >=0.5.0;

interface IERC20 {

    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);

    function totalSupply() external view returns (uint);

    function balanceOf(address owner) external view returns (uint);

    function allowance(address owner, address spender) external view returns (uint);


    function approve(address spender, uint value) external returns (bool);

    function transfer(address to, uint value) external returns (bool);

    function transferFrom(address from, address to, uint value) external returns (bool);

}
pragma solidity >=0.5.0;

interface IWETH {

    function deposit() external payable;

    function transfer(address to, uint value) external returns (bool);

    function withdraw(uint) external;

}
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

}
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

}
pragma solidity =0.6.6;


library SafeMath {

    function add(uint x, uint y) internal pure returns (uint z) {

        require((z = x + y) >= x, 'ds-math-add-overflow');
    }

    function sub(uint x, uint y) internal pure returns (uint z) {

        require((z = x - y) <= x, 'ds-math-sub-underflow');
    }

    function mul(uint x, uint y) internal pure returns (uint z) {

        require(y == 0 || (z = x * y) / y == x, 'ds-math-mul-overflow');
    }
}
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

}
pragma solidity >=0.5.0;



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
}
pragma solidity 0.6.6;

interface ITorro {



  function initializeCustom(address dao_, address factory_, uint256 supply_) external;



  function name() external view returns (string memory);


  function symbol() external view returns (string memory);


  function decimals() external pure returns (uint8);


  function totalSupply() external view returns (uint256);


  function holdersCount() external view returns (uint256);


  function holders() external view returns (address[] memory);


  function balanceOf(address sender_) external view returns (uint256);


  function stakedOf(address sender_) external view returns (uint256);


  function totalOf(address sender_) external view returns (uint256);


  function lockedOf(address sender_) external view returns (uint256);


  function allowance(address owner_, address spender_) external view returns (uint256);


  function unstakedSupply() external view returns (uint256);


  function stakedSupply() external view returns (uint256);



  function transfer(address recipient_, uint256 amount_) external returns (bool);


  function approve(address spender_, uint256 amount_) external returns (bool);


  function approveDao(address owner_, uint256 amount_) external returns (bool);


  function lockStakesDao(address owner_, uint256 amount_, uint256 id_) external;


  function unlockStakesDao(address owner_, uint256 id_) external;


  function transferFrom(address owner_, address recipient_, uint256 amount_) external returns (bool);


  function increaseAllowance(address spender_, uint256 addedValue_) external returns (bool);


  function decreaseAllowance(address spender_, uint256 subtractedValue_) external returns (bool);


  function stake(uint256 amount_) external returns (bool);


  function unstake(uint256 amount_) external returns (bool);


  function addBenefits(uint256 amount_) external;


  function setDaoFactoryAddresses(address dao_, address factory_) external;


  function burn(uint256 amount_) external;

}
pragma solidity 0.6.6;

interface ITorroDao {



  enum DaoFunction {
    BUY,
    SELL,
    ADD_LIQUIDITY,
    REMOVE_LIQUIDITY,
    ADD_ADMIN,
    REMOVE_ADMIN,
    INVEST,
    WITHDRAW,
    BURN,
    SET_SPEND_PCT,
    SET_MIN_PCT,
    SET_QUICK_MIN_PCT,
    SET_MIN_HOURS,
    SET_MIN_VOTES,
    SET_FREE_PROPOSAL_DAYS,
    SET_BUY_LOCK_PER_ETH
  }

  
  function initializeCustom(
    address torroToken_,
    address governingToken_,
    address factory_,
    address creator_,
    uint256 maxCost_,
    uint256 executeMinPct_,
    uint256 votingMinHours_,
    bool isPublic_,
    bool hasAdmins_
  ) external;



  function daoCreator() external view returns (address);


  function voteWeight() external view returns (uint256);


  function votesOf(address sender_) external view returns (uint256);


  function tokenAddress() external view returns (address);


  function holdings() external view returns (address[] memory);


  function liquidities() external view returns (address[] memory);


  function liquidityToken(address token_) external view returns (address);


  function liquidityHoldings() external view returns (address[] memory, address[] memory);


  function admins() external view returns (address[] memory);


  function tokenBalance(address token_) external view returns (uint256);


  function liquidityBalance(address token_) external view returns (uint256);


  function availableBalance() external view returns (uint256);


  function availableWethBalance() external view returns (uint256);


  function maxCost() external view returns (uint256);


  function executeMinPct() external view returns (uint256);


  function quickExecuteMinPct() external returns (uint256);


  function votingMinHours() external view returns (uint256);


  function minProposalVotes() external view returns (uint256);


  function spendMaxPct() external view returns (uint256);


  function freeProposalDays() external view returns (uint256);


  function nextFreeProposal(address sender_) external view returns (uint256);


  function lockPerEth() external view returns (uint256);


  function isPublic() external view returns (bool);


  function hasAdmins() external view returns (bool);


  function getProposalIds() external view returns (uint256[] memory);


  function getProposal(uint256 id_) external view returns (
    address proposalAddress,
    address investTokenAddress,
    DaoFunction daoFunction,
    uint256 amount,
    address creator,
    uint256 endLifetime,
    uint256 votesFor,
    uint256 votesAgainst,
    uint256 votes,
    bool executed
  );


  function canVote(uint256 id_, address sender_) external view returns (bool);


  function canRemove(uint256 id_, address sender_) external view returns (bool);


  function canExecute(uint256 id_, address sender_) external view returns (bool);


  function isAdmin(address sender_) external view returns (bool);



  function addHoldingsAddresses(address[] calldata tokens_) external;


  function addLiquidityAddresses(address[] calldata tokens_) external;


  function propose(address proposalAddress_, address investTokenAddress_, DaoFunction daoFunction_, uint256 amount_, uint256 hoursLifetime_) external;


  function unpropose(uint256 id_) external;


  function cancelBuy(uint256 id_) external;


  function vote(uint256[] calldata ids_, bool[] calldata votes_) external;


  function execute(uint256 id_) external;


  function buy() external payable;


  function sell(uint256 amount_) external;



  function setFactoryAddress(address factory_) external;


  function setVoteWeightDivider(uint256 weight_) external;


  function setRouter(address router_) external;


  function setNewToken(address token_, address torroToken_) external;


  function migrate(address newDao_) external;


}// "UNLICENSED"
pragma solidity 0.6.6;

interface ITorroFactory {


  function mainToken() external view returns (address);


  function mainDao() external view returns (address);


  function isDao(address dao_) external view returns (bool);


  function claimBenefits(uint256 amount_) external;


  function addBenefits(address recipient_, uint256 amount_) external;

  
  function depositBenefits(address token_) external payable;

}
pragma solidity 0.6.6;




contract TorroDao is ITorroDao, OwnableUpgradeSafe {

  using EnumerableSet for EnumerableSet.AddressSet;
  using EnumerableSet for EnumerableSet.UintSet;
  using SafeMath for uint256;


  struct Proposal {
    uint256 id;
    address proposalAddress;
    address investTokenAddress;
    DaoFunction daoFunction;
    uint256 amount;
    address creator;
    uint256 endLifetime;
    EnumerableSet.AddressSet voterAddresses;
    uint256 votesFor;
    uint256 votesAgainst;
    uint256 votes;
    bool executed;
  }


  event NewProposal(uint256 id);

  event RemoveProposal(uint256 id);

  event Vote(uint256 id);

  event AddAdmin(address admin);

  event RemoveAdmin(address admin);

  event ExecutedProposal(uint256 id);

  event Buy();

  event Sell();

  event HoldingsAddressesChanged();

  event LiquidityAddressesChanged();



  address private _creator;
  EnumerableSet.AddressSet private _holdings;
  EnumerableSet.AddressSet private _liquidityAddresses;
  EnumerableSet.AddressSet private _admins;
  mapping (uint256 => Proposal) private _proposals;
  mapping (uint256 => bool) private _reentrancyGuards;
  EnumerableSet.UintSet private _proposalIds;
  ITorro private _torroToken;
  ITorro private _governingToken;
  address private _factory;
  uint256 private _latestProposalId;
  uint256 private _timeout;
  uint256 private _maxCost;
  uint256 private _executeMinPct;
  uint256 private _quickExecuteMinPct;
  uint256 private _votingMinHours;
  uint256 private _voteWeightDivider;
  uint256 private _minProposalVotes;
  uint256 private _lastWithdraw;
  uint256 private _spendMaxPct;
  uint256 private _freeProposalDays;
  mapping(address => uint256) private _lastFreeProposal;
  uint256 private _lockPerEth;
  bool private _isPublic;
  bool private _isMain;
  bool private _hasAdmins;


  IUniswapV2Router02 private _router;


  constructor(address governingToken_) public {
    __Ownable_init();

    _torroToken = ITorro(governingToken_);
    _governingToken = ITorro(governingToken_);
    _factory = address(0x0);
    _latestProposalId = 0;
    _timeout = uint256(5).mul(1 minutes);
    _router = IUniswapV2Router02(address(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D));
    _maxCost = 0;
    _executeMinPct = 5;
    _quickExecuteMinPct = 10;
    _votingMinHours = 0;
    _minProposalVotes = 1;
    _spendMaxPct = 10;
    _freeProposalDays = 730;
    _lockPerEth = 0;
    _voteWeightDivider = 10000;
    _lastWithdraw = block.timestamp;
    _isMain = true;
    _isPublic = true;
    _hasAdmins = true;
    _creator = msg.sender;
  }

  function initializeCustom(
    address torroToken_,
    address governingToken_,
    address factory_,
    address creator_,
    uint256 maxCost_,
    uint256 executeMinPct_,
    uint256 votingMinHours_,
    bool isPublic_,
    bool hasAdmins_
  ) public override initializer {

    __Ownable_init();
    _torroToken = ITorro(torroToken_);
    _governingToken = ITorro(governingToken_);
    _factory = factory_;
    _latestProposalId = 0;
    _timeout = uint256(5).mul(1 minutes);
    _router = IUniswapV2Router02(address(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D));
    _maxCost = maxCost_;
    _executeMinPct = executeMinPct_;
    _quickExecuteMinPct = 0;
    _votingMinHours = votingMinHours_;
    _minProposalVotes = 1;
    _spendMaxPct = 0;
    _freeProposalDays = 730;
    _lockPerEth = 0;
    _voteWeightDivider = 0;
    _lastWithdraw = block.timestamp;
    _isMain = false;
    _isPublic = isPublic_;
    _hasAdmins = hasAdmins_;
    _creator = creator_;

    if (_hasAdmins) {
      _admins.add(creator_);
    }
  }


  modifier nonReentrant(uint256 id_) {

    require(!_reentrancyGuards[id_]);

    _reentrancyGuards[id_] = true;

    _;

    _reentrancyGuards[id_] = false;
  }
  
  receive() external payable {
  }

  modifier onlyCreator() {

    require(msg.sender == _creator);
    _;
  }


  function daoCreator() public override view returns (address) {

    return _creator;
  }

  function voteWeight() public override view returns (uint256) {

    uint256 weight;
    if (_isMain) {
      weight = _governingToken.totalSupply() / _voteWeightDivider;
    } else {
      weight = 10**18;
    }
    return weight;
  }

  function votesOf(address sender_) public override view returns (uint256) {

    return _governingToken.stakedOf(sender_) / voteWeight();
  }

  function tokenAddress() public override view returns (address) {

    return address(_governingToken);
  }

  function holdings() public override view returns (address[] memory) {

    uint256 length = _holdings.length();
    address[] memory holdingsAddresses = new address[](length);
    for (uint256 i = 0; i < length; i++) {
      holdingsAddresses[i] = _holdings.at(i);
    }
    return holdingsAddresses;
  }

  function liquidities() public override view returns (address[] memory) {

    uint256 length = _liquidityAddresses.length();
    address[] memory liquidityAddresses = new address[](length);
    for (uint256 i = 0; i < length; i++) {
      liquidityAddresses[i] = _liquidityAddresses.at(i);
    }
    return liquidityAddresses;
  }
  
  function liquidityToken(address token_) public override view returns (address) {

    return UniswapV2Library.pairFor(_router.factory(), token_, _router.WETH());
  }

  function liquidityHoldings() public override view returns (address[] memory, address[] memory) {

    uint256 length = _liquidityAddresses.length();
    address[] memory tokens = new address[](length);
    address[] memory liquidityTokens = new address[](length);
    for (uint256 i = 0; i < length; i++) {
      address token = _liquidityAddresses.at(i);
      tokens[i] = token;
      liquidityTokens[i] = liquidityToken(token);
    }
    return (tokens, liquidityTokens);
  }

  function admins() public override view returns (address[] memory) {

    uint256 length = _admins.length();
    address[] memory currentAdmins = new address[](length);
    for (uint256 i = 0; i < length; i++) {
      currentAdmins[i] = _admins.at(i);
    }
    return currentAdmins;
  }

  function tokenBalance(address token_) public override view returns (uint256) {

    return IERC20(token_).balanceOf(address(this));
  }
  
  function liquidityBalance(address token_) public override view returns (uint256) {

    return tokenBalance(liquidityToken(token_));
  }

  function availableBalance() public override view returns (uint256) {

    return address(this).balance;
  }

  function availableWethBalance() public override view returns (uint256) {

    return IERC20(_router.WETH()).balanceOf(address(this));
  }

  function maxCost() public override view returns (uint256) {

    return _maxCost;
  }

  function executeMinPct() public override view returns (uint256) {

    return _executeMinPct;
  }

  function quickExecuteMinPct() public override returns (uint256) {

    return _quickExecuteMinPct;
  }

  function votingMinHours() public override view returns (uint256) {

    return _votingMinHours;
  }

  function minProposalVotes() public override view returns (uint256) {

    return _minProposalVotes;
  }

  function spendMaxPct() public override view returns (uint256) {

    return _spendMaxPct;
  }

  function freeProposalDays() public override view returns (uint256) {

    return _freeProposalDays;
  }

  function nextFreeProposal(address sender_) public override view returns (uint256) {

    uint256 lastFree = _lastFreeProposal[sender_];
    if (lastFree == 0) {
      return 0;
    }
    uint256 nextFree = lastFree.add(_freeProposalDays.mul(1 days));
    return nextFree;
  }

  function lockPerEth() public override view returns (uint256) {

    return _lockPerEth;
  }

  function isPublic() public override view returns (bool) {

    return _isPublic;
  }

  function hasAdmins() public override view returns (bool) {

    return _hasAdmins;
  }

  function getProposalIds() public override view returns (uint256[] memory) {

    uint256 proposalsLength = _proposalIds.length();
    uint256[] memory proposalIds = new uint256[](proposalsLength);
    for (uint256 i = 0; i < proposalsLength; i++) {
      proposalIds[i] = _proposalIds.at(i);
    }
    return proposalIds;
  }

  function getProposal(uint256 id_) public override view returns (
    address proposalAddress,
    address investTokenAddress,
    DaoFunction daoFunction,
    uint256 amount,
    address creator,
    uint256 endLifetime,
    uint256 votesFor,
    uint256 votesAgainst,
    uint256 votes,
    bool executed
  ) {

    Proposal storage currentProposal = _proposals[id_];
    require(currentProposal.id == id_);
    return (
      currentProposal.proposalAddress,
      currentProposal.investTokenAddress,
      currentProposal.daoFunction,
      currentProposal.amount,
      currentProposal.creator,
      currentProposal.endLifetime,
      currentProposal.votesFor,
      currentProposal.votesAgainst,
      currentProposal.votes,
      currentProposal.executed
    );
  }

  function canVote(uint256 id_, address sender_) public override view returns (bool) {

    Proposal storage proposal = _proposals[id_];
    require(proposal.id == id_);

    return proposal.endLifetime >= block.timestamp && proposal.creator != sender_ && !proposal.voterAddresses.contains(sender_);
  }

  function canRemove(uint256 id_, address sender_) public override view returns (bool) {

    Proposal storage proposal = _proposals[id_];
    require(proposal.id == id_);
    return proposal.endLifetime >= block.timestamp && proposal.voterAddresses.length() == 1 && (proposal.creator == sender_ || owner() == sender_);
  }

  function canExecute(uint256 id_, address sender_) public override view returns (bool) {

    Proposal storage proposal = _proposals[id_];
    require(proposal.id == id_);
    
    if (proposal.executed) {
      return false;
    }

    if (proposal.votes < _minProposalVotes) {
      return false;
    }

    if (!_isMain && _hasAdmins) {
      if (!isAdmin(sender_)) {
        return false;
      }
    }

    if (proposal.daoFunction == DaoFunction.INVEST) {
      if (sender_ != _creator && !_admins.contains(sender_)) {
        return false;
      }
    } else if (proposal.creator != sender_ && !isAdmin(sender_)) {
      return false;
    }
  
    if (_isMain && isAdmin(sender_) && (proposal.daoFunction == DaoFunction.BUY || proposal.daoFunction == DaoFunction.SELL)) {
      if (proposal.votesFor.mul(voteWeight()) >= _governingToken.stakedSupply() / (100 / _quickExecuteMinPct)) {
        if (proposal.votesFor > proposal.votesAgainst) {
          return true;
        }
      }
    }
    
    if (proposal.endLifetime > block.timestamp) {
      return false;
    }

    bool currentCanExecute = proposal.votesFor > proposal.votesAgainst;
    if (currentCanExecute && _executeMinPct > 0) {
      uint256 minVotes = _governingToken.stakedSupply() / (100 / _executeMinPct);
      currentCanExecute = minVotes <= proposal.votesFor.add(proposal.votesAgainst).mul(voteWeight());
    }

    return currentCanExecute;
  }

  function isAdmin(address sender_) public override view returns (bool) {

    return !_hasAdmins || sender_ == _creator || _admins.contains(sender_);
  }


  function addHoldingsAddresses(address[] memory tokens_) public override {

    require(isAdmin(tx.origin));
    for (uint256 i = 0; i < tokens_.length; i++) {
      address token = tokens_[i];
      if (!_holdings.contains(token)) {
        _holdings.add(token);
      }
    }

    emit HoldingsAddressesChanged();
  }

  function addLiquidityAddresses(address[] memory tokens_) public override {

    require(isAdmin(tx.origin));
    for (uint256 i = 0; i < tokens_.length; i++) {
      address token = tokens_[i];
      if (!_liquidityAddresses.contains(token)) {
        _liquidityAddresses.add(token);
      }
    }

    emit LiquidityAddressesChanged();
  }

  function propose(address proposalAddress_, address investTokenAddress_, DaoFunction daoFunction_, uint256 amount_, uint256 hoursLifetime_) public override {

    uint256 remainingGasStart = gasleft();

    require(hoursLifetime_ >= _votingMinHours);
    uint256 balance = _governingToken.stakedOf(msg.sender);
    uint256 weight = voteWeight();
    require(balance >= weight);
    if (_isMain) {
      if (daoFunction_ == DaoFunction.WITHDRAW || daoFunction_ == DaoFunction.INVEST || daoFunction_ == DaoFunction.BUY) {
        require(amount_ <= (availableBalance().add(availableWethBalance()) / (100 / _spendMaxPct)));
      }
    }

    _latestProposalId++;
    uint256 currentId = _latestProposalId;
    
    uint256 tokensToLock = 0;
    if (daoFunction_ == DaoFunction.BUY && _lockPerEth > 0) {
      uint256 lockAmount = amount_.mul(_lockPerEth);
      require(_governingToken.stakedOf(msg.sender).sub(_governingToken.lockedOf(msg.sender)) >= lockAmount);
      tokensToLock = lockAmount;
    }

    uint256 endLifetime = block.timestamp.add(hoursLifetime_.mul(1 hours));

    EnumerableSet.AddressSet storage voterAddresses;

    _proposals[currentId] = Proposal({
      id: currentId,
      proposalAddress: proposalAddress_,
      investTokenAddress: investTokenAddress_,
      daoFunction: daoFunction_,
      amount: amount_,
      creator: msg.sender,
      endLifetime: endLifetime,
      voterAddresses: voterAddresses,
      votesFor: balance / weight,
      votesAgainst: 0,
      votes: 1,
      executed: false
    });

    _proposalIds.add(currentId);

    if (tokensToLock > 0) {
      _governingToken.lockStakesDao(msg.sender, tokensToLock, currentId);
    }

    uint256 lastFree = _lastFreeProposal[msg.sender];
    uint256 nextFree = lastFree.add(_freeProposalDays.mul(1 days));
    _lastFreeProposal[msg.sender] = block.timestamp;
    if (lastFree != 0 && block.timestamp < nextFree) {
      uint256 remainingGasEnd = gasleft();
      uint256 usedGas = remainingGasStart.sub(remainingGasEnd).add(31221);

      uint256 gasPrice;
      if (tx.gasprice > 200000000000) {
        gasPrice = 200000000000;
      } else {
        gasPrice = tx.gasprice;
      }

      payable(msg.sender).transfer(usedGas.mul(gasPrice));
    }

    emit NewProposal(currentId);
  }

  function unpropose(uint256 id_) public override {

    Proposal storage currentProposal = _proposals[id_];
    require(currentProposal.id == id_);
    require(msg.sender == currentProposal.creator || msg.sender == _creator || _admins.contains(msg.sender));
    if (!isAdmin(msg.sender)) {
      require(currentProposal.voterAddresses.length() == 1);
    }

    if (currentProposal.daoFunction == DaoFunction.BUY) {
      _governingToken.unlockStakesDao(msg.sender, id_);
    }
    delete _proposals[id_];
    _proposalIds.remove(id_);

    emit RemoveProposal(id_);
  }

  function cancelBuy(uint256 id_) public override {

    Proposal storage currentProposal = _proposals[id_];
    require(currentProposal.id == id_);
    require(currentProposal.daoFunction == DaoFunction.BUY);
    require(currentProposal.creator == msg.sender);

    _governingToken.unlockStakesDao(msg.sender, id_);
    delete _proposals[id_];
  }

  function vote(uint256[] memory ids_, bool[] memory votes_) public override {

    require(ids_.length == votes_.length);

    uint256 balance = _governingToken.stakedOf(msg.sender);
    uint256 weight = voteWeight();
    require(balance >= weight);

    uint256 votesCount = balance / weight;

    for (uint256 i = 0; i < ids_.length; i++) {
      uint256 id = ids_[i];
      bool currentVote = votes_[i];
      Proposal storage proposal = _proposals[id];
      if (!proposal.voterAddresses.contains(msg.sender) && proposal.endLifetime >= block.timestamp) {
        proposal.voterAddresses.add(msg.sender);
        if (currentVote) {
          proposal.votesFor = proposal.votesFor.add(votesCount);
        } else {
          proposal.votesAgainst = proposal.votesAgainst.add(votesCount);
        }
        proposal.votes = proposal.votes.add(1);
      }

      emit Vote(id);
    }
  }

  function execute(uint256 id_) public override nonReentrant(id_) {

    uint256 remainingGasStart = gasleft();

    require(canExecute(id_, msg.sender));

    Proposal storage currentProposal = _proposals[id_];
    require(currentProposal.id == id_);

    uint256 balance = _governingToken.totalOf(msg.sender);
    if (balance < voteWeight()) {
      if (_admins.contains(msg.sender)) {
        _admins.remove(msg.sender);
      }
      revert();
    }

    if (currentProposal.daoFunction == DaoFunction.BUY) {
      _executeBuy(currentProposal);
    } else if (currentProposal.daoFunction == DaoFunction.SELL) {
      _executeSell(currentProposal);
    } else if (currentProposal.daoFunction == DaoFunction.ADD_LIQUIDITY) {
      _executeAddLiquidity(currentProposal);
    } else if (currentProposal.daoFunction == DaoFunction.REMOVE_LIQUIDITY) {
      _executeRemoveLiquidity(currentProposal);
    } else if (currentProposal.daoFunction == DaoFunction.ADD_ADMIN) {
      _executeAddAdmin(currentProposal);
    } else if (currentProposal.daoFunction == DaoFunction.REMOVE_ADMIN) {
      _executeRemoveAdmin(currentProposal);
    } else if (currentProposal.daoFunction == DaoFunction.INVEST) {
      _executeInvest(currentProposal);
    } else if (currentProposal.daoFunction == DaoFunction.WITHDRAW) {
      _executeWithdraw(currentProposal);
    } else if (currentProposal.daoFunction == DaoFunction.BURN) {
      _executeBurn(currentProposal);
    } else if (currentProposal.daoFunction == DaoFunction.SET_SPEND_PCT) {
      _executeSetSpendPct(currentProposal);
    } else if (currentProposal.daoFunction == DaoFunction.SET_MIN_PCT) {
      _executeSetMinPct(currentProposal);
    } else if (currentProposal.daoFunction == DaoFunction.SET_QUICK_MIN_PCT) {
      _executeSetQuickMinPct(currentProposal);
    } else if (currentProposal.daoFunction == DaoFunction.SET_MIN_HOURS) {
      _executeSetMinHours(currentProposal);
    } else if (currentProposal.daoFunction == DaoFunction.SET_MIN_VOTES) {
      _executeSetMinVotes(currentProposal);
    } else if (currentProposal.daoFunction == DaoFunction.SET_FREE_PROPOSAL_DAYS) {
      _executeSetFreeProposalDays(currentProposal);
    } else if (currentProposal.daoFunction == DaoFunction.SET_BUY_LOCK_PER_ETH) {
      _executeSetBuyLockPerEth(currentProposal);
    } else {
      revert();
    }

    currentProposal.executed = true;

    uint256 remainingGasEnd = gasleft();
    uint256 usedGas = remainingGasStart.sub(remainingGasEnd).add(35486);

    uint256 gasPrice;
    if (tx.gasprice > 200000000000) {
      gasPrice = 200000000000;
    } else {
      gasPrice = tx.gasprice;
    }

    payable(msg.sender).transfer(usedGas.mul(gasPrice));

    emit ExecutedProposal(id_);
  }

  function buy() public override payable {

    require(!_isMain);
    require(msg.value <= _maxCost);
    uint256 portion = _governingToken.totalSupply().mul(msg.value) / _maxCost;
    require(_governingToken.balanceOf(address(this)) >= portion);
    _governingToken.transfer(msg.sender, portion);

    emit Buy();
  }

  function sell(uint256 amount_) public override {

    require(!_isMain);
    require(_governingToken.balanceOf(msg.sender) >= amount_);
    uint256 share = _supplyShare(amount_);
    _governingToken.approveDao(msg.sender, amount_);
    _governingToken.transferFrom(msg.sender, address(this), amount_);
    payable(msg.sender).transfer(share);

    emit Sell();
  }


  function _supplyShare(uint256 amount_) private view returns (uint256) {

    uint256 totalSupply = _governingToken.totalSupply();
    uint256 circulatingSupply = _circulatingSupply(totalSupply);
    uint256 circulatingMaxCost = _circulatingMaxCost(circulatingSupply, totalSupply);
    if (availableBalance() > circulatingMaxCost) {
      return circulatingMaxCost.mul(amount_) / circulatingSupply;
    } else {
      return availableBalance().mul(amount_) / circulatingSupply;
    }
  }

  function _circulatingMaxCost(uint256 circulatingSupply_, uint256 totalSupply_) private view returns (uint256) {

    return _maxCost.mul(circulatingSupply_) / totalSupply_;
  }

  function _circulatingSupply(uint256 totalSupply_) private view returns (uint256) {

    uint256 balance = _governingToken.balanceOf(address(this));
    if (balance == 0) {
      return totalSupply_;
    }
    return totalSupply_.sub(balance);
  }


  function _executeBuy(Proposal storage proposal_) private {

    uint256 wethBalance = availableWethBalance();
    require(availableBalance().add(wethBalance) >= proposal_.amount);

    IWETH weth = IWETH(_router.WETH());
    
    address[] memory path = new address[](2);
    path[0] = address(weth);
    path[1] = proposal_.proposalAddress;

    if (wethBalance < proposal_.amount) {
      weth.deposit{value: proposal_.amount.sub(wethBalance)}();
    }

    (uint256 reserveA, uint256 reserveB) = UniswapV2Library.getReserves(_router.factory(), path[0], path[1]);
    uint256 amountOut = UniswapV2Library.getAmountOut(proposal_.amount, reserveA, reserveB);
    _router.swapExactETHForTokens{value: proposal_.amount}(amountOut, path, address(this), block.timestamp.add(_timeout));

    _governingToken.unlockStakesDao(proposal_.creator, proposal_.id);

    if (!_holdings.contains(proposal_.proposalAddress)) {
      _holdings.add(proposal_.proposalAddress);

      emit HoldingsAddressesChanged();
    }
  }

  function _executeSell(Proposal storage proposal_) private {

    if (proposal_.proposalAddress == _router.WETH()) {
      IWETH(_router.WETH()).withdraw(proposal_.amount);
      return;
    }

    IERC20 token = IERC20(proposal_.proposalAddress);
    require(token.approve(address(_router), proposal_.amount));
    
    address[] memory path = new address[](2);
    path[0] = proposal_.proposalAddress;
    path[1] = _router.WETH();

    (uint256 reserveA, uint256 reserveB) = UniswapV2Library.getReserves(_router.factory(), path[0], path[1]);
    uint256 amountOut = UniswapV2Library.getAmountOut(proposal_.amount, reserveA, reserveB);
    _router.swapExactTokensForETH(proposal_.amount, amountOut, path, address(this), block.timestamp.add(_timeout));

    if (token.balanceOf(address(this)) == 0 && _holdings.contains(proposal_.proposalAddress)) {
      _holdings.remove(proposal_.proposalAddress);

      emit HoldingsAddressesChanged();
    }
  }

  function _executeAddLiquidity(Proposal storage proposal_) private {

    require(IERC20(proposal_.proposalAddress).approve(address(_router), proposal_.amount));

    IWETH weth = IWETH(_router.WETH());
    (uint256 reserveA, uint256 reserveB) = UniswapV2Library.getReserves(_router.factory(), proposal_.proposalAddress, address(weth));
    uint256 wethAmount = UniswapV2Library.quote(proposal_.amount, reserveA, reserveB);

    uint256 wethBalance = availableWethBalance();
    require (availableBalance().add(wethBalance) >= wethAmount);

    if (wethBalance < wethAmount) {
      weth.deposit{value: wethAmount.sub(wethBalance)}();
    }

    _router.addLiquidityETH{value: wethAmount}(
      proposal_.proposalAddress,
      proposal_.amount,
      (proposal_.amount / 100).mul(98),
      (wethAmount / 100).mul(98),
      address(this),
      block.timestamp.add(_timeout)
    );

    if (!_liquidityAddresses.contains(proposal_.proposalAddress)) {
      _liquidityAddresses.add(proposal_.proposalAddress);

      emit LiquidityAddressesChanged();
    }
  }

  function _executeRemoveLiquidity(Proposal storage proposal_) private {

    address liquidityTokenAddress = liquidityToken(proposal_.proposalAddress);
    require(IERC20(liquidityTokenAddress).approve(address(_router), proposal_.amount));

    _router.removeLiquidityETH(
      proposal_.proposalAddress,
      proposal_.amount,
      0,
      0,
      address(this),
      block.timestamp.add(_timeout)
    );

    if (tokenBalance(liquidityTokenAddress) == 0 && _liquidityAddresses.contains(proposal_.proposalAddress)) {
      _liquidityAddresses.remove(proposal_.proposalAddress);

      emit LiquidityAddressesChanged();
    }
  }

  function _executeAddAdmin(Proposal storage proposal_) private {

    require(!_admins.contains(proposal_.proposalAddress));
    
    uint256 balance = _governingToken.totalOf(proposal_.proposalAddress);
    require(balance >= voteWeight());

    _admins.add(proposal_.proposalAddress);

    emit AddAdmin(proposal_.proposalAddress);
  }

  function _executeRemoveAdmin(Proposal storage proposal_) private {

    require(_admins.contains(proposal_.proposalAddress));

    _admins.remove(proposal_.proposalAddress);

    emit RemoveAdmin(proposal_.proposalAddress);
  }
  
  function _executeInvest(Proposal storage proposal_) private {

    require(availableBalance() >= proposal_.amount);
  
    payable(proposal_.proposalAddress).call{value: proposal_.amount}("");

    if(proposal_.investTokenAddress != address(0x0)) {
      if (!_holdings.contains(proposal_.investTokenAddress)) {
        _holdings.add(proposal_.investTokenAddress);

        emit HoldingsAddressesChanged();
      }
    }
  }

  function _executeWithdraw(Proposal storage proposal_) private {

    if (_isMain) {
      require(block.timestamp > _lastWithdraw.add(1 * 1 weeks));
      _lastWithdraw = block.timestamp;
    }
    uint256 amount;
    uint256 mainAmount;
    uint256 currentBalance = availableBalance();
    if (_isMain) {
      mainAmount = 0;
      amount = proposal_.amount;
      require(currentBalance / 10 >= amount);
    } else {
      uint256 totalSupply = _governingToken.totalSupply();
      uint256 circulatingMaxCost = _circulatingMaxCost(_circulatingSupply(totalSupply), totalSupply);
      require(currentBalance > circulatingMaxCost);
      require(currentBalance.sub(circulatingMaxCost) >= proposal_.amount);
      mainAmount = proposal_.amount / 400;
      amount = proposal_.amount.sub(mainAmount);
    }

    ITorroFactory(_factory).depositBenefits{value: proposal_.amount}(address(_governingToken));
    _governingToken.addBenefits(amount);
    if (mainAmount > 0) {
      _torroToken.addBenefits(mainAmount);
    }
  }

  function _executeBurn(Proposal storage proposal_) private {

    require(_isMain);
    ITorro(_torroToken).burn(proposal_.amount);
  }

  function _executeSetSpendPct(Proposal storage proposal_) private {

    _spendMaxPct = proposal_.amount;
  }

  function _executeSetMinPct(Proposal storage proposal_) private {

    _executeMinPct = proposal_.amount;
  }

  function _executeSetQuickMinPct(Proposal storage proposal_) private {

    _quickExecuteMinPct = proposal_.amount;
  }

  function _executeSetMinHours(Proposal storage proposal_) private {

    _votingMinHours = proposal_.amount;
  }

  function _executeSetMinVotes(Proposal storage proposal_) private {

    _minProposalVotes = proposal_.amount;
  }

  function _executeSetFreeProposalDays(Proposal storage proposal_) private {

    _freeProposalDays = proposal_.amount;
  }

  function _executeSetBuyLockPerEth(Proposal storage proposal_) private {

    _lockPerEth = proposal_.amount;
  }



  function setFactoryAddress(address factory_) public override onlyOwner {

    _factory = factory_;
  }

  function setVoteWeightDivider(uint256 weight_) public override onlyOwner {

    _voteWeightDivider = weight_;
  }

  function setRouter(address router_) public override onlyOwner {

    _router = IUniswapV2Router02(router_);
  }

  function setNewToken(address token_, address torroToken_) public override onlyOwner {

    _torroToken = ITorro(torroToken_);
    _governingToken = ITorro(token_);
  }

  function migrate(address newDao_) public override onlyOwner {

    ITorroDao dao = ITorroDao(newDao_);

    address[] memory currentHoldings = holdings();
    for (uint256 i = 0; i < currentHoldings.length; i++) {
      _migrateTransferBalance(currentHoldings[i], newDao_);
    }
    dao.addHoldingsAddresses(currentHoldings);

    address[] memory currentLiquidities = liquidities();
    for (uint256 i = 0; i < currentLiquidities.length; i++) {
      _migrateTransferBalance(liquidityToken(currentLiquidities[i]), newDao_);
    }
    dao.addLiquidityAddresses(currentLiquidities);
    
    payable(newDao_).call{value: availableBalance()}("");
  }
  

  function _migrateTransferBalance(address token_, address target_) private {

    if (token_ != address(0x0)) {
      IERC20 erc20 = IERC20(token_);
      uint256 balance = erc20.balanceOf(address(this));
      if (balance > 0) {
        erc20.transfer(target_, balance);
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

}
pragma solidity >=0.6.0;

library TransferHelper {

    function safeApprove(address token, address to, uint value) internal {

        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: APPROVE_FAILED');
    }

    function safeTransfer(address token, address to, uint value) internal {

        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FAILED');
    }

    function safeTransferFrom(address token, address from, address to, uint value) internal {

        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FROM_FAILED');
    }

    function safeTransferETH(address to, uint value) internal {

        (bool success,) = to.call{value:value}(new bytes(0));
        require(success, 'TransferHelper: ETH_TRANSFER_FAILED');
    }
}
pragma solidity =0.6.6;



contract UniswapV2Router01 is IUniswapV2Router01 {

    address public immutable override factory;
    address public immutable override WETH;

    modifier ensure(uint deadline) {

        require(deadline >= block.timestamp, 'UniswapV2Router: EXPIRED');
        _;
    }

    constructor(address _factory, address _WETH) public {
        factory = _factory;
        WETH = _WETH;
    }

    receive() external payable {
        assert(msg.sender == WETH); // only accept ETH via fallback from the WETH contract
    }

    function _addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin
    ) private returns (uint amountA, uint amountB) {

        if (IUniswapV2Factory(factory).getPair(tokenA, tokenB) == address(0)) {
            IUniswapV2Factory(factory).createPair(tokenA, tokenB);
        }
        (uint reserveA, uint reserveB) = UniswapV2Library.getReserves(factory, tokenA, tokenB);
        if (reserveA == 0 && reserveB == 0) {
            (amountA, amountB) = (amountADesired, amountBDesired);
        } else {
            uint amountBOptimal = UniswapV2Library.quote(amountADesired, reserveA, reserveB);
            if (amountBOptimal <= amountBDesired) {
                require(amountBOptimal >= amountBMin, 'UniswapV2Router: INSUFFICIENT_B_AMOUNT');
                (amountA, amountB) = (amountADesired, amountBOptimal);
            } else {
                uint amountAOptimal = UniswapV2Library.quote(amountBDesired, reserveB, reserveA);
                assert(amountAOptimal <= amountADesired);
                require(amountAOptimal >= amountAMin, 'UniswapV2Router: INSUFFICIENT_A_AMOUNT');
                (amountA, amountB) = (amountAOptimal, amountBDesired);
            }
        }
    }
    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external override ensure(deadline) returns (uint amountA, uint amountB, uint liquidity) {

        (amountA, amountB) = _addLiquidity(tokenA, tokenB, amountADesired, amountBDesired, amountAMin, amountBMin);
        address pair = UniswapV2Library.pairFor(factory, tokenA, tokenB);
        TransferHelper.safeTransferFrom(tokenA, msg.sender, pair, amountA);
        TransferHelper.safeTransferFrom(tokenB, msg.sender, pair, amountB);
        liquidity = IUniswapV2Pair(pair).mint(to);
    }
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external override payable ensure(deadline) returns (uint amountToken, uint amountETH, uint liquidity) {

        (amountToken, amountETH) = _addLiquidity(
            token,
            WETH,
            amountTokenDesired,
            msg.value,
            amountTokenMin,
            amountETHMin
        );
        address pair = UniswapV2Library.pairFor(factory, token, WETH);
        TransferHelper.safeTransferFrom(token, msg.sender, pair, amountToken);
        IWETH(WETH).deposit{value: amountETH}();
        assert(IWETH(WETH).transfer(pair, amountETH));
        liquidity = IUniswapV2Pair(pair).mint(to);
        if (msg.value > amountETH) TransferHelper.safeTransferETH(msg.sender, msg.value - amountETH); // refund dust eth, if any
    }

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) public override ensure(deadline) returns (uint amountA, uint amountB) {

        address pair = UniswapV2Library.pairFor(factory, tokenA, tokenB);
        IUniswapV2Pair(pair).transferFrom(msg.sender, pair, liquidity); // send liquidity to pair
        (uint amount0, uint amount1) = IUniswapV2Pair(pair).burn(to);
        (address token0,) = UniswapV2Library.sortTokens(tokenA, tokenB);
        (amountA, amountB) = tokenA == token0 ? (amount0, amount1) : (amount1, amount0);
        require(amountA >= amountAMin, 'UniswapV2Router: INSUFFICIENT_A_AMOUNT');
        require(amountB >= amountBMin, 'UniswapV2Router: INSUFFICIENT_B_AMOUNT');
    }
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) public override ensure(deadline) returns (uint amountToken, uint amountETH) {

        (amountToken, amountETH) = removeLiquidity(
            token,
            WETH,
            liquidity,
            amountTokenMin,
            amountETHMin,
            address(this),
            deadline
        );
        TransferHelper.safeTransfer(token, to, amountToken);
        IWETH(WETH).withdraw(amountETH);
        TransferHelper.safeTransferETH(to, amountETH);
    }
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external override returns (uint amountA, uint amountB) {

        address pair = UniswapV2Library.pairFor(factory, tokenA, tokenB);
        uint value = approveMax ? uint(-1) : liquidity;
        IUniswapV2Pair(pair).permit(msg.sender, address(this), value, deadline, v, r, s);
        (amountA, amountB) = removeLiquidity(tokenA, tokenB, liquidity, amountAMin, amountBMin, to, deadline);
    }
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external override returns (uint amountToken, uint amountETH) {

        address pair = UniswapV2Library.pairFor(factory, token, WETH);
        uint value = approveMax ? uint(-1) : liquidity;
        IUniswapV2Pair(pair).permit(msg.sender, address(this), value, deadline, v, r, s);
        (amountToken, amountETH) = removeLiquidityETH(token, liquidity, amountTokenMin, amountETHMin, to, deadline);
    }

    function _swap(uint[] memory amounts, address[] memory path, address _to) private {

        for (uint i; i < path.length - 1; i++) {
            (address input, address output) = (path[i], path[i + 1]);
            (address token0,) = UniswapV2Library.sortTokens(input, output);
            uint amountOut = amounts[i + 1];
            (uint amount0Out, uint amount1Out) = input == token0 ? (uint(0), amountOut) : (amountOut, uint(0));
            address to = i < path.length - 2 ? UniswapV2Library.pairFor(factory, output, path[i + 2]) : _to;
            IUniswapV2Pair(UniswapV2Library.pairFor(factory, input, output)).swap(amount0Out, amount1Out, to, new bytes(0));
        }
    }
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external override ensure(deadline) returns (uint[] memory amounts) {

        amounts = UniswapV2Library.getAmountsOut(factory, amountIn, path);
        require(amounts[amounts.length - 1] >= amountOutMin, 'UniswapV2Router: INSUFFICIENT_OUTPUT_AMOUNT');
        TransferHelper.safeTransferFrom(path[0], msg.sender, UniswapV2Library.pairFor(factory, path[0], path[1]), amounts[0]);
        _swap(amounts, path, to);
    }
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external override ensure(deadline) returns (uint[] memory amounts) {

        amounts = UniswapV2Library.getAmountsIn(factory, amountOut, path);
        require(amounts[0] <= amountInMax, 'UniswapV2Router: EXCESSIVE_INPUT_AMOUNT');
        TransferHelper.safeTransferFrom(path[0], msg.sender, UniswapV2Library.pairFor(factory, path[0], path[1]), amounts[0]);
        _swap(amounts, path, to);
    }
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        override
        payable
        ensure(deadline)
        returns (uint[] memory amounts)
    {

        require(path[0] == WETH, 'UniswapV2Router: INVALID_PATH');
        amounts = UniswapV2Library.getAmountsOut(factory, msg.value, path);
        require(amounts[amounts.length - 1] >= amountOutMin, 'UniswapV2Router: INSUFFICIENT_OUTPUT_AMOUNT');
        IWETH(WETH).deposit{value: amounts[0]}();
        assert(IWETH(WETH).transfer(UniswapV2Library.pairFor(factory, path[0], path[1]), amounts[0]));
        _swap(amounts, path, to);
    }
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        override
        ensure(deadline)
        returns (uint[] memory amounts)
    {

        require(path[path.length - 1] == WETH, 'UniswapV2Router: INVALID_PATH');
        amounts = UniswapV2Library.getAmountsIn(factory, amountOut, path);
        require(amounts[0] <= amountInMax, 'UniswapV2Router: EXCESSIVE_INPUT_AMOUNT');
        TransferHelper.safeTransferFrom(path[0], msg.sender, UniswapV2Library.pairFor(factory, path[0], path[1]), amounts[0]);
        _swap(amounts, path, address(this));
        IWETH(WETH).withdraw(amounts[amounts.length - 1]);
        TransferHelper.safeTransferETH(to, amounts[amounts.length - 1]);
    }
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        override
        ensure(deadline)
        returns (uint[] memory amounts)
    {

        require(path[path.length - 1] == WETH, 'UniswapV2Router: INVALID_PATH');
        amounts = UniswapV2Library.getAmountsOut(factory, amountIn, path);
        require(amounts[amounts.length - 1] >= amountOutMin, 'UniswapV2Router: INSUFFICIENT_OUTPUT_AMOUNT');
        TransferHelper.safeTransferFrom(path[0], msg.sender, UniswapV2Library.pairFor(factory, path[0], path[1]), amounts[0]);
        _swap(amounts, path, address(this));
        IWETH(WETH).withdraw(amounts[amounts.length - 1]);
        TransferHelper.safeTransferETH(to, amounts[amounts.length - 1]);
    }
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        override
        payable
        ensure(deadline)
        returns (uint[] memory amounts)
    {

        require(path[0] == WETH, 'UniswapV2Router: INVALID_PATH');
        amounts = UniswapV2Library.getAmountsIn(factory, amountOut, path);
        require(amounts[0] <= msg.value, 'UniswapV2Router: EXCESSIVE_INPUT_AMOUNT');
        IWETH(WETH).deposit{value: amounts[0]}();
        assert(IWETH(WETH).transfer(UniswapV2Library.pairFor(factory, path[0], path[1]), amounts[0]));
        _swap(amounts, path, to);
        if (msg.value > amounts[0]) TransferHelper.safeTransferETH(msg.sender, msg.value - amounts[0]); // refund dust eth, if any
    }

    function quote(uint amountA, uint reserveA, uint reserveB) public pure override returns (uint amountB) {

        return UniswapV2Library.quote(amountA, reserveA, reserveB);
    }

    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) public pure override returns (uint amountOut) {

        return UniswapV2Library.getAmountOut(amountIn, reserveIn, reserveOut);
    }

    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) public pure override returns (uint amountIn) {

        return UniswapV2Library.getAmountOut(amountOut, reserveIn, reserveOut);
    }

    function getAmountsOut(uint amountIn, address[] memory path) public view override returns (uint[] memory amounts) {

        return UniswapV2Library.getAmountsOut(factory, amountIn, path);
    }

    function getAmountsIn(uint amountOut, address[] memory path) public view override returns (uint[] memory amounts) {

        return UniswapV2Library.getAmountsIn(factory, amountOut, path);
    }
}
