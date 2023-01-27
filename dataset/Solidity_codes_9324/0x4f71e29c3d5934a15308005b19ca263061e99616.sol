pragma solidity 0.8.4;

interface IPYESwapRouter01 {

    function factory() external view returns (address);

    function WETH() external view returns (address);


    function addLiquidity(
        address tokenA,
        address tokenB,
        bool supportsTokenFee,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);

    function addLiquidityETH(
        address token,
        bool supportsTokenFee,
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

}// MIT
pragma solidity 0.8.4;


interface IPYESwapRouter is IPYESwapRouter01 {

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

}// GPL-3.0-or-later
pragma solidity 0.8.4;

library TransferHelper {

  function safeApprove(
    address token,
    address to,
    uint256 value
) internal {

    (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
    require(
      success && (data.length == 0 || abi.decode(data, (bool))),
      'TransferHelper::safeApprove: approve failed'
    );
  }

  function safeTransfer(
    address token,
    address to,
    uint256 value
) internal {

    (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
    require(
      success && (data.length == 0 || abi.decode(data, (bool))),
      'TransferHelper::safeTransfer: transfer failed'
    );
  }

  function safeTransferFrom(
    address token,
    address from,
    address to,
    uint256 value
) internal {

    (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
    require(
      success && (data.length == 0 || abi.decode(data, (bool))),
      'TransferHelper::transferFrom: transferFrom failed'
    );
  }

  function safeTransferETH(address to, uint256 value) internal {

    (bool success, ) = to.call{value: value}(new bytes(0));
    require(success, 'TransferHelper::safeTransferETH: ETH transfer failed');
  }
}// MIT
pragma solidity 0.8.4;

interface IPYESwapPair {

    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function baseToken() external view returns (address);

    function getTotalFee() external view returns (uint);

    function name() external pure returns (string memory);

    function symbol() external pure returns (string memory);

    function decimals() external pure returns (uint8);

    function totalSupply() external view returns (uint);

    function balanceOf(address owner) external view returns (uint);

    function allowance(address owner, address spender) external view returns (uint);

    function updateTotalFee(uint totalFee) external returns (bool);


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

    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast, address _baseToken);

    function price0CumulativeLast() external view returns (uint);

    function price1CumulativeLast() external view returns (uint);

    function kLast() external view returns (uint);


    function mint(address to) external returns (uint liquidity);

    function burn(address to) external returns (uint amount0, uint amount1);

    function swap(uint amount0Out, uint amount1Out, uint amount0Fee, uint amount1Fee, address to, bytes calldata data) external;

    function skim(address to) external;

    function sync() external;


    function initialize(address, address) external;

    function setBaseToken(address _baseToken) external;

}// MIT
pragma solidity 0.8.4;

interface IPYESwapFactory {

    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);

    function feeToSetter() external view returns (address);


    function getPair(address tokenA, address tokenB) external view returns (address pair);

    function allPairs(uint) external view returns (address pair);

    function allPairsLength() external view returns (uint);

    function pairExist(address pair) external view returns (bool);


    function createPair(address tokenA, address tokenB, bool supportsTokenFee) external returns (address pair);


    function setFeeTo(address) external;

    function setFeeToSetter(address) external;

    function routerInitialize(address) external;

    function routerAddress() external view returns (address);

}// MIT
pragma solidity 0.8.4;

interface IToken {

    function addPair(address pair, address token) external;

    function depositLPFee(uint amount, address token) external;

    function isExcludedFromFee(address account) external view returns (bool);

}// MIT
pragma solidity 0.8.4;

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

}// MIT
pragma solidity 0.8.4;


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

    function div(uint x, uint y) internal pure returns (uint z) {

        require(y > 0, "ds-math-div-underflow");
        z = x / y;
    }
}// MIT
pragma solidity 0.8.4;



library PYESwapLibrary {


    function sortTokens(address tokenA, address tokenB) internal pure returns (address token0, address token1) {

        require(tokenA != tokenB, 'PYESwapLibrary: IDENTICAL_ADDRESSES');
        (token0, token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        require(token0 != address(0), 'PYESwapLibrary: ZERO_ADDRESS');
    }

    function pairFor(address factory, address tokenA, address tokenB) internal pure returns (address pair) {

        (address token0, address token1) = sortTokens(tokenA, tokenB);
        pair = address(uint160(uint(keccak256(abi.encodePacked(
                hex'ff',
                factory,
                keccak256(abi.encodePacked(token0, token1)),
                hex'7322d196a5476ed6b44fc18910ef3e8a09c2baea2da66bd2cf58f5b3c9dc57ce' // init code hash
            )))));
    }

    function getReserves(address factory, address tokenA, address tokenB) internal view returns (uint reserveA, uint reserveB) {

        (address token0,) = sortTokens(tokenA, tokenB);
        (uint reserve0, uint reserve1,,) = IPYESwapPair(pairFor(factory, tokenA, tokenB)).getReserves();
        (reserveA, reserveB) = tokenA == token0 ? (reserve0, reserve1) : (reserve1, reserve0);
    }

    function quote(uint amountA, uint reserveA, uint reserveB) internal pure returns (uint amountB) {

        require(amountA > 0, 'PYESwapLibrary: INSUFFICIENT_AMOUNT');
        require(reserveA > 0 && reserveB > 0, 'PYESwapLibrary: INSUFFICIENT_LIQUIDITY');
        amountB = (amountA * reserveB) / reserveA;
    }

    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut, bool tokenFee, uint totalFee) internal pure returns (uint amountOut) {

        require(amountIn > 0, 'PYESwapLibrary: INSUFFICIENT_INPUT_AMOUNT');
        require(reserveIn > 0 && reserveOut > 0, 'PYESwapLibrary: INSUFFICIENT_LIQUIDITY');
        uint amountInMultiplier = tokenFee ? 10000 - totalFee : 10000;
        uint amountInWithFee = amountIn * amountInMultiplier;
        uint numerator = amountInWithFee * reserveOut;
        uint denominator = (reserveIn * 10000) + amountInWithFee;
        amountOut = numerator / denominator;
    }

    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut, bool tokenFee, uint totalFee) internal pure returns (uint amountIn) {

        require(amountOut > 0, 'PYESwapLibrary: INSUFFICIENT_OUTPUT_AMOUNT');
        require(reserveIn > 0 && reserveOut > 0, 'PYESwapLibrary: INSUFFICIENT_LIQUIDITY');
        uint amountOutMultiplier = tokenFee ? 10000 - totalFee : 10000;
        uint numerator = (reserveIn * amountOut) * 10000;
        uint denominator = (reserveOut - amountOut) * amountOutMultiplier;
        amountIn = (numerator / denominator) + 1;
    }

    function amountsOut(address factory, uint amountIn, address[] memory path, bool isExcluded) internal view returns (uint[] memory) {

        return isExcluded ? getAmountsOutWithoutFee(factory, amountIn, path) : getAmountsOut(factory, amountIn, path);
    }

    function amountsIn(address factory, uint amountOut, address[] memory path, bool isExcluded) internal view returns (uint[] memory) {

        return isExcluded ? getAmountsInWithoutFee(factory, amountOut, path) : getAmountsIn(factory, amountOut, path);
    }

    function getAmountsOut(address factory, uint amountIn, address[] memory path) internal view returns (uint[] memory amounts) {

        require(path.length >= 2, 'PYESwapLibrary: INVALID_PATH');
        amounts = new uint[](path.length);
        amounts[0] = amountIn;
        for (uint i; i < path.length - 1; i++) {
            IPYESwapPair pair = IPYESwapPair(pairFor(factory, path[i], path[i + 1]));
            address baseToken = pair.baseToken();
            uint totalFee = pair.getTotalFee();
            (uint reserveIn, uint reserveOut) = getReserves(factory, path[i], path[i + 1]);
            amounts[i + 1] = getAmountOut(amounts[i], reserveIn, reserveOut, baseToken != address(0), totalFee);
        }
    }

    function getAmountsIn(address factory, uint amountOut, address[] memory path) internal view returns (uint[] memory amounts) {

        require(path.length >= 2, 'PYESwapLibrary: INVALID_PATH');
        amounts = new uint[](path.length);
        amounts[amounts.length - 1] = amountOut;
        for (uint i = path.length - 1; i > 0; i--) {
            IPYESwapPair pair = IPYESwapPair(pairFor(factory, path[i - 1], path[i]));
            address baseToken = pair.baseToken();
            uint totalFee = pair.getTotalFee();
            (uint reserveIn, uint reserveOut) = getReserves(factory, path[i - 1], path[i]);
            amounts[i - 1] = getAmountIn(amounts[i], reserveIn, reserveOut, baseToken != address(0), totalFee);
        }
    }

    function getAmountsOutWithoutFee(address factory, uint amountIn, address[] memory path) internal view returns (uint[] memory amounts) {

        require(path.length >= 2, 'PYESwapLibrary: INVALID_PATH');
        amounts = new uint[](path.length);
        amounts[0] = amountIn;
        for (uint i; i < path.length - 1; i++) {
            (uint reserveIn, uint reserveOut) = getReserves(factory, path[i], path[i + 1]);
            amounts[i + 1] = getAmountOut(amounts[i], reserveIn, reserveOut, false, 0);
        }
    }

    function getAmountsInWithoutFee(address factory, uint amountOut, address[] memory path) internal view returns (uint[] memory amounts) {

        require(path.length >= 2, 'PYESwapLibrary: INVALID_PATH');
        amounts = new uint[](path.length);
        amounts[amounts.length - 1] = amountOut;
        for (uint i = path.length - 1; i > 0; i--) {
            (uint reserveIn, uint reserveOut) = getReserves(factory, path[i - 1], path[i]);
            amounts[i - 1] = getAmountIn(amounts[i], reserveIn, reserveOut, false, 0);
        }
    }

    function adminFeeCalculation(uint256 _amounts,uint256 _adminFee) internal pure returns (uint256,uint256) {

        uint adminFeeDeduct = (_amounts * _adminFee) / (10000);
        _amounts = _amounts - adminFeeDeduct;

        return (_amounts,adminFeeDeduct);
    }


    function checkIsExcluded(address account, address pairAddress) internal view returns (bool isExcluded) {

        IPYESwapPair pair = IPYESwapPair(pairAddress);
        address baseToken = pair.baseToken();

        if(baseToken == address(0)) {
            isExcluded = true;
        } else {
            address token0 = pair.token0();
            address token1 = pair.token1();

            IToken token = baseToken == token0 ? IToken(token1) : IToken(token0);
            try token.isExcludedFromFee(account) returns (bool isExcludedFromFee) {
                isExcluded = isExcludedFromFee;
            } catch {
                isExcluded = false;
            }

        }
    }

    function _calculateFees(address factory, address input, address output, uint amountIn, uint amount0Out, uint amount1Out, bool isExcluded) internal view returns (uint amount0Fee, uint amount1Fee) {

        IPYESwapPair pair = IPYESwapPair(pairFor(factory, input, output));
        (address token0,) = sortTokens(input, output);
        address baseToken = pair.baseToken();
        uint totalFee = pair.getTotalFee();
        amount0Fee = baseToken != token0 || isExcluded ? uint(0) : input == token0 ? (amountIn * totalFee) / (10**4) : (amount0Out * totalFee) / (10**4);
        amount1Fee = baseToken == token0 || isExcluded ? uint(0) : input != token0 ? (amountIn * totalFee) / (10**4) : (amount1Out * totalFee) / (10**4);
    }

    function _calculateAmounts(address factory, address input, address output, address token0, bool isExcluded) internal view returns (uint amountInput, uint amountOutput) {

        IPYESwapPair pair = IPYESwapPair(pairFor(factory, input, output));

        (uint reserve0, uint reserve1,, address baseToken) = pair.getReserves();
        uint totalFee = pair.getTotalFee();
        (uint reserveInput, uint reserveOutput) = input == token0 ? (reserve0, reserve1) : (reserve1, reserve0);

        amountInput = IERC20(input).balanceOf(address(pair)) - reserveInput;
        amountOutput = getAmountOut(amountInput, reserveInput, reserveOutput, baseToken != address(0) && !isExcluded, isExcluded ? 0 : totalFee);
    }
}// MIT
pragma solidity 0.8.4;

interface IWETH {

    function deposit() external payable;

    function transfer(address to, uint value) external returns (bool);

    function withdraw(uint) external;

}// MIT
pragma solidity 0.8.4;


abstract contract FeeStore {
    uint public adminFee;
    address public adminFeeAddress;
    address public adminFeeSetter;
    address public factoryAddress;
    mapping (address => address) public pairFeeAddress;

    event AdminFeeSet(uint adminFee, address adminFeeAddress);

    function initialize(address _factory, uint256 _adminFee, address _adminFeeAddress, address _adminFeeSetter) internal {
        factoryAddress = _factory;
        adminFee = _adminFee;
        adminFeeAddress = _adminFeeAddress;
        adminFeeSetter = _adminFeeSetter;
    }

    function setAdminFee (address _adminFeeAddress, uint _adminFee) external {
        require(msg.sender == adminFeeSetter);
        require(_adminFee <= 100);
        adminFeeAddress = _adminFeeAddress;
        adminFee = _adminFee;
        emit AdminFeeSet(adminFee, adminFeeAddress);
    }
}// MIT
pragma solidity 0.8.4;


abstract contract SupportingSwap is FeeStore, IPYESwapRouter {


    address public override factory;
    address public override WETH;

    event Received(address sender, uint256 value);

    modifier ensure(uint deadline) {
        require(deadline >= block.timestamp, 'PYESwapRouter: EXPIRED');
        _;
    }

    function _swap(address _feeCheck, uint[] memory amounts, address[] memory path, address _to) internal virtual {
        for (uint i; i < path.length - 1; i++) {
            (address input, address output) = (path[i], path[i + 1]);
            (address token0,) = PYESwapLibrary.sortTokens(input, output);

            IPYESwapPair pair = IPYESwapPair(PYESwapLibrary.pairFor(factory, input, output));
            bool isExcluded = PYESwapLibrary.checkIsExcluded(_feeCheck, address(pair));

            uint amountOut = amounts[i + 1];
            {
                uint amountsI = amounts[i];
                address[] memory _path = path;
                address finalPath = i < _path.length - 2 ? _path[i + 2] : address(0);
                (uint amount0Out, uint amount1Out) = input == token0 ? (uint(0), amountOut) : (amountOut, uint(0));
                (uint amount0Fee, uint amount1Fee) = PYESwapLibrary._calculateFees(factory, input, output, amountsI, amount0Out, amount1Out, isExcluded);
                address to = i < _path.length - 2 ? PYESwapLibrary.pairFor(factory, output, finalPath) : _to;
                pair.swap(
                    amount0Out, amount1Out, amount0Fee, amount1Fee, to, new bytes(0)
                );

            }
        }
    }


    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external virtual override ensure(deadline) returns (uint[] memory amounts) {
        require(path.length == 2, "PYESwapRouter: ONLY_TWO_TOKENS_ALLOWED");
        address pair = PYESwapLibrary.pairFor(factory, path[0], path[1]);

        uint adminFeeDeduct;
        if(path[0] == pairFeeAddress[pair]){
            (amountIn,adminFeeDeduct) = PYESwapLibrary.adminFeeCalculation(amountIn, adminFee);
            TransferHelper.safeTransferFrom(
                path[0], msg.sender, adminFeeAddress, adminFeeDeduct
            );
        }

        bool isExcluded = PYESwapLibrary.checkIsExcluded(to, pair);
        amounts = PYESwapLibrary.amountsOut(factory, amountIn, path, isExcluded);
        require(amounts[amounts.length - 1] >= amountOutMin, 'PYESwapRouter: INSUFFICIENT_OUTPUT_AMOUNT');
        TransferHelper.safeTransferFrom(
            path[0], msg.sender, pair, amounts[0]
        );
        _swap(to, amounts, path, to);
    }
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external virtual override ensure(deadline) returns (uint[] memory amounts) {
        require(path.length == 2, "PYESwapRouter: ONLY_TWO_TOKENS_ALLOWED");
        address pair = PYESwapLibrary.pairFor(factory, path[0], path[1]);
        bool isExcluded = PYESwapLibrary.checkIsExcluded(to, pair);

        uint adminFeeDeduct;
        if(path[0] == pairFeeAddress[pair]) {
            amounts = PYESwapLibrary.amountsIn(factory, amountOut, path, isExcluded);
            require(amounts[0] <= amountInMax, 'PYESwapRouter: EXCESSIVE_INPUT_AMOUNT');
            (amounts[0], adminFeeDeduct) = PYESwapLibrary.adminFeeCalculation(amounts[0], adminFee);
            TransferHelper.safeTransferFrom(
                path[0], msg.sender, adminFeeAddress, adminFeeDeduct
            );

            amounts = PYESwapLibrary.amountsOut(factory, amounts[0], path, isExcluded);

            TransferHelper.safeTransferFrom(
                path[0], msg.sender, pair, amounts[0]
            );

        } else {
            amounts = PYESwapLibrary.amountsIn(factory, amountOut, path, isExcluded);
            require(amounts[0] <= amountInMax, "PYESwapRouter: EXCESSIVE_INPUT_AMOUNT");
            TransferHelper.safeTransferFrom(
                path[0], msg.sender, pair, amounts[0]
            );
        }

        _swap(to, amounts, path, to);
    }

    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
    external
    virtual
    override
    payable
    ensure(deadline)
    returns (uint[] memory amounts)
    {
        require(path.length == 2, "PYESwapRouter: ONLY_TWO_TOKENS_ALLOWED");
        require(path[0] == WETH, "PYESwapRouter: INVALID_PATH");

        uint eth = msg.value;
        address pair = PYESwapLibrary.pairFor(factory, path[0], path[1]);
        bool isExcluded = PYESwapLibrary.checkIsExcluded(to, pair);

        uint adminFeeDeduct;
        if(path[0] == pairFeeAddress[pair]){
            (eth, adminFeeDeduct) = PYESwapLibrary.adminFeeCalculation(eth, adminFee);
            if(address(this) != adminFeeAddress){
                payable(adminFeeAddress).transfer(adminFeeDeduct);
            }
        }

        amounts = PYESwapLibrary.amountsOut(factory, msg.value, path, isExcluded);

        require(amounts[amounts.length - 1] >= amountOutMin, "PYESwapRouter: INSUFFICIENT_OUTPUT_AMOUNT");
        IWETH(WETH).deposit{value: amounts[0]}();
        assert(IWETH(WETH).transfer(pair, amounts[0]));
        _swap(to, amounts, path, to);
    }

    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
    external
    virtual
    override
    ensure(deadline)
    returns (uint[] memory amounts)
    {
        require(path.length == 2, "PYESwapRouter: ONLY_TWO_TOKENS_ALLOWED");
        require(path[path.length - 1] == WETH, 'PYESwapRouter: INVALID_PATH');

        uint adminFeeDeduct;
        address pair = PYESwapLibrary.pairFor(factory, path[0], path[1]);
        bool isExcluded = PYESwapLibrary.checkIsExcluded(to, pair);

        if(path[0] == pairFeeAddress[pair]){
            amounts = PYESwapLibrary.amountsIn(factory, amountOut, path, isExcluded);
            require(amounts[0] <= amountInMax, 'PYESwapRouter: EXCESSIVE_INPUT_AMOUNT');
            (amounts[0],adminFeeDeduct) = PYESwapLibrary.adminFeeCalculation(amounts[0],adminFee);
            TransferHelper.safeTransferFrom(
                path[0], msg.sender, adminFeeAddress, adminFeeDeduct
            );

            amounts = PYESwapLibrary.amountsOut(factory, amounts[0], path, isExcluded);

            TransferHelper.safeTransferFrom(
                path[0], msg.sender, pair, amounts[0]
            );
        } else {
            amounts = PYESwapLibrary.amountsIn(factory, amountOut, path, isExcluded);
            require(amounts[0] <= amountInMax, 'PYESwapRouter: EXCESSIVE_INPUT_AMOUNT');
            TransferHelper.safeTransferFrom(
                path[0], msg.sender, pair, amounts[0]
            );
        }
        _swap(to, amounts, path, address(this));

        uint amountETHOut = amounts[amounts.length - 1];
        if(path[1] == pairFeeAddress[pair]){
            (amountETHOut,adminFeeDeduct) = PYESwapLibrary.adminFeeCalculation(amountETHOut,adminFee);
        }
        IWETH(WETH).withdraw(amountETHOut);
        TransferHelper.safeTransferETH(to, amountETHOut);
    }
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
    external
    virtual
    override
    ensure(deadline)
    returns (uint[] memory amounts)
    {
        require(path.length == 2, "PYESwapRouter: ONLY_TWO_TOKENS_ALLOWED");
        require(path[path.length - 1] == WETH, 'PYESwapRouter: INVALID_PATH');

        uint adminFeeDeduct;
        address pair = PYESwapLibrary.pairFor(factory, path[0], path[1]);
        bool isExcluded = PYESwapLibrary.checkIsExcluded(to, pair);

        if(path[0] == pairFeeAddress[pair]){
            (amountIn,adminFeeDeduct) = PYESwapLibrary.adminFeeCalculation(amountIn, adminFee);
            TransferHelper.safeTransferFrom(
                path[0], msg.sender, adminFeeAddress, adminFeeDeduct
            );
        }

        amounts = PYESwapLibrary.amountsOut(factory, amountIn, path, isExcluded);
        require(amounts[amounts.length - 1] >= amountOutMin, 'PYESwapRouter: INSUFFICIENT_OUTPUT_AMOUNT');
        TransferHelper.safeTransferFrom(
            path[0], msg.sender, pair, amounts[0]
        );
        _swap(to, amounts, path, address(this));

        uint amountETHOut = amounts[amounts.length - 1];
        if(path[1] == pairFeeAddress[pair]){
            (amountETHOut,adminFeeDeduct) = PYESwapLibrary.adminFeeCalculation(amountETHOut,adminFee);
        }
        IWETH(WETH).withdraw(amountETHOut);
        TransferHelper.safeTransferETH(to, amountETHOut);
    }
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
    external
    virtual
    override
    payable
    ensure(deadline)
    returns (uint[] memory amounts)
    {
        require(path.length == 2, "PYESwapRouter: ONLY_TWO_TOKENS_ALLOWED");
        require(path[0] == WETH, 'PYESwapRouter: INVALID_PATH');

        address pair = PYESwapLibrary.pairFor(factory, path[0], path[1]);
        bool isExcluded = PYESwapLibrary.checkIsExcluded(to, pair);

        uint adminFeeDeduct;
        if(path[0] == pairFeeAddress[pair]){
            amounts = PYESwapLibrary.amountsIn(factory, amountOut, path, isExcluded);
            require(amounts[0] <= msg.value, 'PYESwapRouter: EXCESSIVE_INPUT_AMOUNT');

            (amounts[0], adminFeeDeduct) = PYESwapLibrary.adminFeeCalculation(amounts[0], adminFee);
            if(address(this) != adminFeeAddress){
                payable(adminFeeAddress).transfer(adminFeeDeduct);
            }

            amounts = PYESwapLibrary.amountsOut(factory, amounts[0], path, isExcluded);

            IWETH(WETH).deposit{value: amounts[0]}();
            assert(IWETH(WETH).transfer(pair, amounts[0]));

        } else {
            amounts = PYESwapLibrary.amountsIn(factory, amountOut, path, isExcluded);
            require(amounts[0] <= msg.value, 'PYESwapRouter: EXCESSIVE_INPUT_AMOUNT');
            IWETH(WETH).deposit{value: amounts[0]}();
            assert(IWETH(WETH).transfer(PYESwapLibrary.pairFor(factory, path[0], path[1]), amounts[0]));
        }

        _swap(to, amounts, path, to);
        uint bal = amounts[0] + adminFeeDeduct;
        if (msg.value > bal) TransferHelper.safeTransferETH(msg.sender, msg.value - bal);
    }


    function _swapSupportingFeeOnTransferTokens(address _feeCheck, address[] memory path, address _to) internal virtual {
        for (uint i; i < path.length - 1; i++) {
            (address input, address output) = (path[i], path[i + 1]);
            (address token0,) = PYESwapLibrary.sortTokens(input, output);

            IPYESwapPair pair = IPYESwapPair(PYESwapLibrary.pairFor(factory, input, output));
            bool isExcluded = PYESwapLibrary.checkIsExcluded(_feeCheck, address(pair));

            (uint amountInput, uint amountOutput) = PYESwapLibrary._calculateAmounts(factory, input, output, token0, isExcluded);
            (uint amount0Out, uint amount1Out) = input == token0 ? (uint(0), amountOutput) : (amountOutput, uint(0));

            (uint amount0Fee, uint amount1Fee) = PYESwapLibrary._calculateFees(factory, input, output, amountInput, amount0Out, amount1Out, isExcluded);

            {
                address[] memory _path = path;
                address finalPath = i < _path.length - 2 ? _path[i + 2] : address(0);
                address to = i < _path.length - 2 ? PYESwapLibrary.pairFor(factory, output, finalPath) : _to;
                pair.swap(amount0Out, amount1Out, amount0Fee, amount1Fee, to, new bytes(0));
            }
        }
    }
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external virtual override ensure(deadline) {
        require(path.length == 2, "PYESwapRouter: ONLY_TWO_TOKENS_ALLOWED");

        address pair = PYESwapLibrary.pairFor(factory, path[0], path[1]);
        uint adminFeeDeduct;
        if(path[0] == pairFeeAddress[pair]){
            (amountIn,adminFeeDeduct) = PYESwapLibrary.adminFeeCalculation(amountIn,adminFee);
            TransferHelper.safeTransferFrom(
                path[0], msg.sender, adminFeeAddress, adminFeeDeduct
            );
        }

        TransferHelper.safeTransferFrom(
            path[0], msg.sender, pair, amountIn
        );
        uint balanceBefore = IERC20(path[path.length - 1]).balanceOf(to);
        _swapSupportingFeeOnTransferTokens(to, path, to);
        if(path[1] == pairFeeAddress[pair]){
            (amountOutMin,adminFeeDeduct) = PYESwapLibrary.adminFeeCalculation(amountOutMin,adminFee);
        }
        require(
            IERC20(path[path.length - 1]).balanceOf(to) - balanceBefore >= amountOutMin,
            'PYESwapRouter: INSUFFICIENT_OUTPUT_AMOUNT'
        );
    }
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    )
    external
    virtual
    override
    payable
    ensure(deadline)
    {
        require(path.length == 2, "PYESwapRouter: ONLY_TWO_TOKENS_ALLOWED");
        require(path[0] == WETH, 'PYESwapRouter: INVALID_PATH');
        uint amountIn = msg.value;

        address pair = PYESwapLibrary.pairFor(factory, path[0], path[1]);
        uint adminFeeDeduct;
        if(path[0] == pairFeeAddress[pair]){
            (amountIn,adminFeeDeduct) = PYESwapLibrary.adminFeeCalculation(amountIn,adminFee);
            if(address(this) != adminFeeAddress){
                payable(adminFeeAddress).transfer(adminFeeDeduct);
            }
        }

        IWETH(WETH).deposit{value: amountIn}();
        assert(IWETH(WETH).transfer(pair, amountIn));
        uint balanceBefore = IERC20(path[path.length - 1]).balanceOf(to);
        _swapSupportingFeeOnTransferTokens(to, path, to);
        if(path[1] == pairFeeAddress[pair]){
            (amountOutMin,adminFeeDeduct) = PYESwapLibrary.adminFeeCalculation(amountOutMin,adminFee);
        }
        require(
            IERC20(path[path.length - 1]).balanceOf(to) - balanceBefore >= amountOutMin,
            'PYESwapRouter: INSUFFICIENT_OUTPUT_AMOUNT'
        );
    }
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    )
    external
    virtual
    override
    ensure(deadline)
    {
        require(path.length == 2, "PYESwapRouter: ONLY_TWO_TOKENS_ALLOWED");
        require(path[path.length - 1] == WETH, 'PYESwapRouter: INVALID_PATH');
        address pair = PYESwapLibrary.pairFor(factory, path[0], path[1]);

        if(path[0] == pairFeeAddress[pair]){
            uint adminFeeDeduct = (amountIn * adminFee) / (10000);
            amountIn = amountIn - adminFeeDeduct;
            TransferHelper.safeTransferFrom(
                path[0], msg.sender, adminFeeAddress, adminFeeDeduct
            );
        }

        TransferHelper.safeTransferFrom(
            path[0], msg.sender, pair, amountIn
        );
        _swapSupportingFeeOnTransferTokens(to, path, address(this));
        uint amountOut = IERC20(WETH).balanceOf(address(this));
        amountOutMin;
        if(path[1] == pairFeeAddress[pair]){
            uint adminFeeDeduct = (amountOut * adminFee) / (10000);
            amountOut = amountOut - adminFeeDeduct;
        }
        IWETH(WETH).withdraw(amountOut);
        TransferHelper.safeTransferETH(to, amountOut);
    }
}// MIT
pragma solidity 0.8.4;


contract PYESwapRouter is SupportingSwap {


    address private immutable USDC;

    constructor(address _factory, address _WETH, address _USDC, uint8 _adminFee, address _adminFeeAddress, address _adminFeeSetter) {
        require(_factory != address(0) && _WETH != address(0) && _USDC != address(0), "PYESwap: INVALID_ADDRESS");
        factory = _factory;
        WETH = _WETH;
        USDC = _USDC;
        initialize(_factory, _adminFee, _adminFeeAddress, _adminFeeSetter);
    }

    receive() external payable {
        assert(msg.sender == WETH); // only accept ETH via fallback from the WETH contract
        emit Received(msg.sender, msg.value);
    }

    function _addLiquidity(
        address tokenA,
        address tokenB,
        bool supportsTokenFee,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin
    ) internal virtual returns (uint amountA, uint amountB) {

        address pair = getPair(tokenA, tokenB);
        if (pair == address(0)) {
            if(tokenA == WETH || tokenA == USDC) {
                pair = IPYESwapFactory(factory).createPair(tokenB, tokenA, supportsTokenFee);
                pairFeeAddress[pair] = tokenA;
            } else {
                pair = IPYESwapFactory(factory).createPair(tokenA, tokenB, supportsTokenFee);
                pairFeeAddress[pair] = tokenB;
            }
        }
        (uint reserveA, uint reserveB) = PYESwapLibrary.getReserves(factory, tokenA, tokenB);
        if (reserveA == 0 && reserveB == 0) {
            (amountA, amountB) = (amountADesired, amountBDesired);
            if (tokenA == WETH || tokenA == USDC) {
                pairFeeAddress[pair] = tokenA;
            } else {
                pairFeeAddress[pair] = tokenB;
            }
        } else {
            uint amountBOptimal = PYESwapLibrary.quote(amountADesired, reserveA, reserveB);
            if (amountBOptimal <= amountBDesired) {
                require(amountBOptimal >= amountBMin, 'PYESwapRouter: INSUFFICIENT_B_AMOUNT');
                (amountA, amountB) = (amountADesired, amountBOptimal);
            } else {
                uint amountAOptimal = PYESwapLibrary.quote(amountBDesired, reserveB, reserveA);
                assert(amountAOptimal <= amountADesired);
                require(amountAOptimal >= amountAMin, 'PYESwapRouter: INSUFFICIENT_A_AMOUNT');
                (amountA, amountB) = (amountAOptimal, amountBDesired);
            }
        }
    }

    function getPair(address tokenA,address tokenB) public view returns (address){

        return IPYESwapFactory(factory).getPair(tokenA, tokenB);
    }

    function addLiquidity(
        address tokenA,
        address tokenB,
        bool supportsTokenFee,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external virtual override ensure(deadline) returns (uint amountA, uint amountB, uint liquidity) {

        (amountA, amountB) = _addLiquidity(tokenA, tokenB, supportsTokenFee, amountADesired, amountBDesired, amountAMin, amountBMin);
        address pair = PYESwapLibrary.pairFor(factory, tokenA, tokenB);
        TransferHelper.safeTransferFrom(tokenA, msg.sender, address(this), amountA);
        TransferHelper.safeTransfer(tokenA, pair, amountA);
        TransferHelper.safeTransferFrom(tokenB, msg.sender, address(this), amountB);
        TransferHelper.safeTransfer(tokenB, pair, amountB);
        liquidity = IPYESwapPair(pair).mint(to);
    }
    function addLiquidityETH(
        address token,
        bool supportsTokenFee,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external virtual override payable ensure(deadline) returns (uint amountETH, uint amountToken, uint liquidity) {

        (amountETH, amountToken) = _addLiquidity(
            WETH,
            token,
            supportsTokenFee,
            msg.value,
            amountTokenDesired,
            amountETHMin,
            amountTokenMin
        );
        address pair = PYESwapLibrary.pairFor(factory, token, WETH);

        TransferHelper.safeTransferFrom(token, msg.sender, address(this), amountToken);
        TransferHelper.safeTransfer(token, pair, amountToken);
        IWETH(WETH).deposit{value: amountETH}();
        assert(IWETH(WETH).transfer(pair, amountETH));
        liquidity = IPYESwapPair(pair).mint(to);
        if (msg.value > amountETH) TransferHelper.safeTransferETH(msg.sender, msg.value - amountETH);
    }

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) public virtual override ensure(deadline) returns (uint amountA, uint amountB) {

        address pair = PYESwapLibrary.pairFor(factory, tokenA, tokenB);
        TransferHelper.safeTransferFrom(pair, msg.sender, pair, liquidity); // send liquidity to pair
        (uint amount0, uint amount1) = IPYESwapPair(pair).burn(to);
        (address token0,) = PYESwapLibrary.sortTokens(tokenA, tokenB);
        (amountA, amountB) = tokenA == token0 ? (amount0, amount1) : (amount1, amount0);
        require(amountA >= amountAMin, 'PYESwapRouter: INSUFFICIENT_A_AMOUNT');
        require(amountB >= amountBMin, 'PYESwapRouter: INSUFFICIENT_B_AMOUNT');
    }
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) public virtual override ensure(deadline) returns (uint amountToken, uint amountETH) {

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
    ) external virtual override returns (uint amountA, uint amountB) {

        address pair = PYESwapLibrary.pairFor(factory, tokenA, tokenB);
        uint value = approveMax ? type(uint).max - 1 : liquidity;
        IPYESwapPair(pair).permit(msg.sender, address(this), value, deadline, v, r, s);
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
    ) external virtual override returns (uint amountToken, uint amountETH) {

        address pair = PYESwapLibrary.pairFor(factory, token, WETH);
        uint value = approveMax ? type(uint).max - 1 : liquidity;
        IPYESwapPair(pair).permit(msg.sender, address(this), value, deadline, v, r, s);
        (amountToken, amountETH) = removeLiquidityETH(token, liquidity, amountTokenMin, amountETHMin, to, deadline);
    }

    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) public virtual override ensure(deadline) returns (uint amountETH) {

        (, amountETH) = removeLiquidity(
            token,
            WETH,
            liquidity,
            amountTokenMin,
            amountETHMin,
            address(this),
            deadline
        );
        TransferHelper.safeTransfer(token, to, IERC20(token).balanceOf(address(this)));
        IWETH(WETH).withdraw(amountETH);
        TransferHelper.safeTransferETH(to, amountETH);
    }
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external virtual override returns (uint amountETH) {

        address pair = PYESwapLibrary.pairFor(factory, token, WETH);
        uint value = approveMax ? type(uint).max - 1 : liquidity;
        IPYESwapPair(pair).permit(msg.sender, address(this), value, deadline, v, r, s);
        amountETH = removeLiquidityETHSupportingFeeOnTransferTokens(
            token, liquidity, amountTokenMin, amountETHMin, to, deadline
        );
    }

    
}