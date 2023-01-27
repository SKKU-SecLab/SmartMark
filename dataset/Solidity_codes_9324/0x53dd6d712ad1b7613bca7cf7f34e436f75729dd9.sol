
pragma solidity >=0.8.0;

interface IERC20 {

    function mint(address _to, uint256 _value) external;


    function allowance(address owner, address spender)
        external
        view
        returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function increaseAllowance(address spender, uint256 addedValue)
        external
        returns (bool);


    function transfer(address _to, uint256 _value)
        external
        returns (bool success);


    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    ) external returns (bool success);


    function balanceOf(address _owner) external view returns (uint256 balance);

}

interface IWETH {

    function deposit() external payable;


    function withdraw(uint amount) external;


    function transfer(address to, uint amount) external returns (bool);


    function approve(address spender, uint256 amount) external returns (bool);

}

interface IOracleRouterV2 {

    function owner() external view returns (address);


    function setOwner(address _owner) external;


    function canRoute(address user) external view returns (bool);


    function setCanRoute(address parser, bool _canRoute) external;


    function routeValue(
        bytes16 uuid,
        string memory chain,
        bytes memory emiter,
        bytes32 topic0,
        bytes memory token,
        bytes memory sender,
        bytes memory receiver,
        uint256 amount
    ) external;


    event SetOwner(address indexed ownerOld, address indexed ownerNew);

    event SetCanRoute(
        address indexed owner,
        address indexed parser,
        bool indexed newBool
    );

    event RouteValue(
        bytes16 uuid,
        string chain,
        bytes emiter,
        bytes indexed token,
        bytes indexed sender,
        bytes indexed receiver,
        uint256 amount
    );
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

interface IRelay is IOracleRouterV2 {

    function wnative() external view returns (IWETH);


    function router() external view returns (IUniswapV2Router01);


    function gton() external view returns (IERC20);


    function isAllowedChain(string calldata chain) external view returns (bool);


    function setIsAllowedChain(string calldata chain, bool newBool) external;


    function feeMin(string calldata destination) external view returns (uint256);


    function feePercent(string calldata destination) external view returns (uint256);


    function setFees(string calldata destination, uint256 _feeMin, uint256 _feePercent) external;


    function lowerLimit(string calldata destination) external view returns (uint256);


    function upperLimit(string calldata destination) external view returns (uint256);


    function setLimits(string calldata destination, uint256 _lowerLimit, uint256 _upperLimit) external;


    function relayTopic() external view returns (bytes32);


    function setRelayTopic(bytes32 _relayTopic) external;


    function lock(string calldata destination, bytes calldata receiver) external payable;


    function reclaimERC20(IERC20 token, uint256 amount) external;


    function reclaimNative(uint256 amount) external;


    event Lock(
        string indexed destinationHash,
        bytes indexed receiverHash,
        string destination,
        bytes receiver,
        uint256 amount
    );

    event CalculateFee(
        uint256 amountIn,
        uint256 amountOut,
        uint256 feeMin,
        uint256 feePercent,
        uint256 fee,
        uint256 amountMinusFee
    );

    event DeliverRelay(address user, uint256 amount0, uint256 amount1);

    event SetRelayTopic(bytes32 indexed topicOld, bytes32 indexed topicNew);

    event SetWallet(address indexed walletOld, address indexed walletNew);

    event SetIsAllowedChain(string chain, bool newBool);

    event SetFees(string destination, uint256 _feeMin, uint256 _feePercent);

    event SetLimits(string destination, uint256 _lowerLimit, uint256 _upperLimit);
}

contract Relay is IRelay {


    address public override owner;

    modifier isOwner() {

        require(msg.sender == owner, "ACW");
        _;
    }

    IWETH public override wnative;
    IUniswapV2Router01 public override router;
    IERC20 public override gton;

    mapping (string => uint256) public override feeMin;
    mapping (string => uint256) public override feePercent;

    mapping(string => uint256) public override lowerLimit;

    mapping(string => uint256) public override upperLimit;

    bytes32 public override relayTopic;

    mapping(address => bool) public override canRoute;

    mapping(string => bool) public override isAllowedChain;

    receive() external payable {
        assert(msg.sender == address(wnative));
    }

    constructor (
        IWETH _wnative,
        IUniswapV2Router01 _router,
        IERC20 _gton,
        bytes32 _relayTopic,
        string[] memory allowedChains,
        uint[2][] memory fees,
        uint[2][] memory limits
    ) {
        owner = msg.sender;
        wnative = _wnative;
        router = _router;
        gton = _gton;
        relayTopic = _relayTopic;
        for (uint256 i = 0; i < allowedChains.length; i++) {
            isAllowedChain[allowedChains[i]] = true;
            feeMin[allowedChains[i]] = fees[i][0];
            feePercent[allowedChains[i]] = fees[i][1];
            lowerLimit[allowedChains[i]] = limits[i][0];
            upperLimit[allowedChains[i]] = limits[i][1];
        }
    }

    function setOwner(address _owner) external override isOwner {

        address ownerOld = owner;
        owner = _owner;
        emit SetOwner(ownerOld, _owner);
    }

    function setIsAllowedChain(string calldata chain, bool newBool)
        external
        override
        isOwner
    {

        isAllowedChain[chain] = newBool;
        emit SetIsAllowedChain(chain, newBool);
    }

    function setFees(string calldata destination, uint256 _feeMin, uint256 _feePercent) external override isOwner {

        feeMin[destination] = _feeMin;
        feePercent[destination] = _feePercent;
        emit SetFees(destination, _feeMin, _feePercent);
    }

    function setLimits(string calldata destination, uint256 _lowerLimit, uint256 _upperLimit) external override isOwner {

        lowerLimit[destination] = _lowerLimit;
        upperLimit[destination] = _upperLimit;
        emit SetLimits(destination, _lowerLimit, _upperLimit);
    }

    function lock(string calldata destination, bytes calldata receiver) external payable override {

        require(isAllowedChain[destination], "R1");
        require(msg.value > lowerLimit[destination], "R2");
        require(msg.value < upperLimit[destination], "R3");
        wnative.deposit{value: msg.value}();
        wnative.approve(address(router), msg.value);
        address[] memory path = new address[](2);
        path[0] = address(wnative);
        path[1] = address(gton);
        uint256[] memory amounts = router.swapExactTokensForTokens(msg.value, 0, path, address(this), block.timestamp+3600);
        uint256 amountMinusFee;
        uint256 fee = amounts[1] * feePercent[destination] / 100000;
        if (fee > feeMin[destination]) {
            amountMinusFee = amounts[1] - fee;
        } else {
            amountMinusFee = amounts[1] - feeMin[destination];
        }
        emit CalculateFee(amounts[0], amounts[1], feeMin[destination], feePercent[destination], fee, amountMinusFee);
        require(amountMinusFee > 0, "R4");
        emit Lock(destination, receiver, destination, receiver, amountMinusFee);
    }

    function reclaimERC20(IERC20 token, uint256 amount) external override isOwner {

        token.transfer(msg.sender, amount);
    }

    function reclaimNative(uint256 amount) external override isOwner {

        payable(msg.sender).transfer(amount);
    }

    function setCanRoute(address parser, bool _canRoute)
        external
        override
        isOwner
    {

        canRoute[parser] = _canRoute;
        emit SetCanRoute(msg.sender, parser, canRoute[parser]);
    }

    function setRelayTopic(bytes32 _relayTopic) external override isOwner {

        bytes32 topicOld = relayTopic;
        relayTopic = _relayTopic;
        emit SetRelayTopic(topicOld, _relayTopic);
    }

    function equal(bytes32 a, bytes32 b) internal pure returns (bool) {

        return keccak256(abi.encodePacked(a)) == keccak256(abi.encodePacked(b));
    }

    function deserializeUint(
        bytes memory b,
        uint256 startPos,
        uint256 len
    ) internal pure returns (uint256) {

        uint256 v = 0;
        for (uint256 p = startPos; p < startPos + len; p++) {
            v = v * 256 + uint256(uint8(b[p]));
        }
        return v;
    }

    function deserializeAddress(bytes memory b, uint256 startPos)
        internal
        pure
        returns (address)
    {

        return address(uint160(deserializeUint(b, startPos, 20)));
    }

    function routeValue(
        bytes16 uuid,
        string memory chain,
        bytes memory emiter,
        bytes32 topic0,
        bytes memory token,
        bytes memory sender,
        bytes memory receiver,
        uint256 amount
    ) external override {

        require(canRoute[msg.sender], "ACR");
        if (equal(topic0, relayTopic)) {
            gton.approve(address(router), amount);
            address[] memory path = new address[](2);
            path[0] = address(gton);
            path[1] = address(wnative);
            uint[] memory amounts = router.swapExactTokensForTokens(amount, 0, path, address(this), block.timestamp+3600);
            wnative.withdraw(amounts[1]);
            address payable user = payable(deserializeAddress(receiver, 0));
            user.transfer(amounts[1]);
            emit DeliverRelay(user, amounts[0], amounts[1]);
        }
        emit RouteValue(uuid, chain, emiter, token, sender, receiver, amount);
    }
}