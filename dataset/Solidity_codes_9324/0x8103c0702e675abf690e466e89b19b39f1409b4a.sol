pragma solidity >=0.7.0;

struct FixedInflationEntry {
    string name;
    uint256 blockInterval;
    uint256 lastBlock;
    uint256 callerRewardPercentage;
}

struct FixedInflationOperation {

    address inputTokenAddress;
    uint256 inputTokenAmount;
    bool inputTokenAmountIsPercentage;
    bool inputTokenAmountIsByMint;

    address ammPlugin;
    address[] liquidityPoolAddresses;
    address[] swapPath;
    bool enterInETH;
    bool exitInETH;

    address[] receivers;
    uint256[] receiversPercentages;
}//MIT
pragma solidity >=0.7.0;
pragma abicoder v2;


interface IFixedInflationExtension {


    function init(address host) external;


    function setHost(address host) external;


    function data() external view returns(address fixedInflationContract, address host);


    function receiveTokens(address[] memory tokenAddresses, uint256[] memory transferAmounts, uint256[] memory amountsToMint) external;


    function flushBack(address[] memory tokenAddresses) external;


    function deactivationByFailure() external;


    function setEntry(FixedInflationEntry memory entryData, FixedInflationOperation[] memory operations) external;


    function active() external view returns(bool);


    function setActive(bool _active) external;


    function burnToken(address erc20TokenAddress, uint256 value) external;

}//MIT
pragma solidity >=0.7.0;

interface IERC20 {

    function totalSupply() external view returns(uint256);

    function balanceOf(address account) external view returns (uint256);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    function decimals() external view returns (uint8);

}//MIT
pragma solidity >=0.7.0;

struct LiquidityPoolData {
    address liquidityPoolAddress;
    uint256 amount;
    address tokenAddress;
    bool amountIsLiquidityPool;
    bool involvingETH;
    address receiver;
}

struct SwapData {
    bool enterInETH;
    bool exitInETH;
    address[] liquidityPoolAddresses;
    address[] path;
    address inputToken;
    uint256 amount;
    address receiver;
}//MIT
pragma solidity >=0.7.0;


interface IAMM {


    event NewLiquidityPoolAddress(address indexed);

    function info() external view returns(string memory name, uint256 version);


    function data() external view returns(address ethereumAddress, uint256 maxTokensPerLiquidityPool, bool hasUniqueLiquidityPools);


    function balanceOf(address liquidityPoolAddress, address owner) external view returns(uint256, uint256[] memory, address[] memory);


    function byLiquidityPool(address liquidityPoolAddress) external view returns(uint256, uint256[] memory, address[] memory);


    function byTokens(address[] calldata liquidityPoolTokens) external view returns(uint256, uint256[] memory, address, address[] memory);


    function byPercentage(address liquidityPoolAddress, uint256 numerator, uint256 denominator) external view returns (uint256, uint256[] memory, address[] memory);


    function byLiquidityPoolAmount(address liquidityPoolAddress, uint256 liquidityPoolAmount) external view returns(uint256[] memory, address[] memory);


    function byTokenAmount(address liquidityPoolAddress, address tokenAddress, uint256 tokenAmount) external view returns(uint256, uint256[] memory, address[] memory);


    function createLiquidityPoolAndAddLiquidity(address[] calldata tokenAddresses, uint256[] calldata amounts, bool involvingETH, address receiver) external payable returns(uint256, uint256[] memory, address, address[] memory);


    function addLiquidity(LiquidityPoolData calldata data) external payable returns(uint256, uint256[] memory, address[] memory);

    function addLiquidityBatch(LiquidityPoolData[] calldata data) external payable returns(uint256[] memory, uint256[][] memory, address[][] memory);


    function removeLiquidity(LiquidityPoolData calldata data) external returns(uint256, uint256[] memory, address[] memory);

    function removeLiquidityBatch(LiquidityPoolData[] calldata data) external returns(uint256[] memory, uint256[][] memory, address[][] memory);


    function getSwapOutput(address tokenAddress, uint256 tokenAmount, address[] calldata, address[] calldata path) view external returns(uint256[] memory);


    function swapLiquidity(SwapData calldata data) external payable returns(uint256);

    function swapLiquidityBatch(SwapData[] calldata data) external payable returns(uint256[] memory);

}//MIT
pragma solidity >=0.7.0;


interface IFixedInflation {


    function setEntry(FixedInflationEntry memory entryData, FixedInflationOperation[] memory operations) external;


    function flushBack(address[] memory tokenAddresses) external;

}// GPL-2.0-or-later
pragma solidity >=0.5.0;

interface IUniswapV3PoolImmutables {

    function factory() external view returns (address);


    function token0() external view returns (address);


    function token1() external view returns (address);


    function fee() external view returns (uint24);


    function tickSpacing() external view returns (int24);


    function maxLiquidityPerTick() external view returns (uint128);

}// GPL-2.0-or-later
pragma solidity >=0.5.0;

interface IUniswapV3PoolState {

    function slot0()
        external
        view
        returns (
            uint160 sqrtPriceX96,
            int24 tick,
            uint16 observationIndex,
            uint16 observationCardinality,
            uint16 observationCardinalityNext,
            uint8 feeProtocol,
            bool unlocked
        );


    function feeGrowthGlobal0X128() external view returns (uint256);


    function feeGrowthGlobal1X128() external view returns (uint256);


    function protocolFees() external view returns (uint128 token0, uint128 token1);


    function liquidity() external view returns (uint128);


    function ticks(int24 tick)
        external
        view
        returns (
            uint128 liquidityGross,
            int128 liquidityNet,
            uint256 feeGrowthOutside0X128,
            uint256 feeGrowthOutside1X128,
            int56 tickCumulativeOutside,
            uint160 secondsPerLiquidityOutsideX128,
            uint32 secondsOutside,
            bool initialized
        );


    function tickBitmap(int16 wordPosition) external view returns (uint256);


    function positions(bytes32 key)
        external
        view
        returns (
            uint128 _liquidity,
            uint256 feeGrowthInside0LastX128,
            uint256 feeGrowthInside1LastX128,
            uint128 tokensOwed0,
            uint128 tokensOwed1
        );


    function observations(uint256 index)
        external
        view
        returns (
            uint32 blockTimestamp,
            int56 tickCumulative,
            uint160 secondsPerLiquidityCumulativeX128,
            bool initialized
        );

}// GPL-2.0-or-later
pragma solidity >=0.5.0;

interface IUniswapV3PoolDerivedState {

    function observe(uint32[] calldata secondsAgos)
        external
        view
        returns (int56[] memory tickCumulatives, uint160[] memory secondsPerLiquidityCumulativeX128s);


    function snapshotCumulativesInside(int24 tickLower, int24 tickUpper)
        external
        view
        returns (
            int56 tickCumulativeInside,
            uint160 secondsPerLiquidityInsideX128,
            uint32 secondsInside
        );

}// GPL-2.0-or-later
pragma solidity >=0.5.0;

interface IUniswapV3PoolActions {

    function initialize(uint160 sqrtPriceX96) external;


    function mint(
        address recipient,
        int24 tickLower,
        int24 tickUpper,
        uint128 amount,
        bytes calldata data
    ) external returns (uint256 amount0, uint256 amount1);


    function collect(
        address recipient,
        int24 tickLower,
        int24 tickUpper,
        uint128 amount0Requested,
        uint128 amount1Requested
    ) external returns (uint128 amount0, uint128 amount1);


    function burn(
        int24 tickLower,
        int24 tickUpper,
        uint128 amount
    ) external returns (uint256 amount0, uint256 amount1);


    function swap(
        address recipient,
        bool zeroForOne,
        int256 amountSpecified,
        uint160 sqrtPriceLimitX96,
        bytes calldata data
    ) external returns (int256 amount0, int256 amount1);


    function flash(
        address recipient,
        uint256 amount0,
        uint256 amount1,
        bytes calldata data
    ) external;


    function increaseObservationCardinalityNext(uint16 observationCardinalityNext) external;

}// GPL-2.0-or-later
pragma solidity >=0.5.0;

interface IUniswapV3PoolOwnerActions {

    function setFeeProtocol(uint8 feeProtocol0, uint8 feeProtocol1) external;


    function collectProtocol(
        address recipient,
        uint128 amount0Requested,
        uint128 amount1Requested
    ) external returns (uint128 amount0, uint128 amount1);

}// GPL-2.0-or-later
pragma solidity >=0.5.0;

interface IUniswapV3PoolEvents {

    event Initialize(uint160 sqrtPriceX96, int24 tick);

    event Mint(
        address sender,
        address indexed owner,
        int24 indexed tickLower,
        int24 indexed tickUpper,
        uint128 amount,
        uint256 amount0,
        uint256 amount1
    );

    event Collect(
        address indexed owner,
        address recipient,
        int24 indexed tickLower,
        int24 indexed tickUpper,
        uint128 amount0,
        uint128 amount1
    );

    event Burn(
        address indexed owner,
        int24 indexed tickLower,
        int24 indexed tickUpper,
        uint128 amount,
        uint256 amount0,
        uint256 amount1
    );

    event Swap(
        address indexed sender,
        address indexed recipient,
        int256 amount0,
        int256 amount1,
        uint160 sqrtPriceX96,
        uint128 liquidity,
        int24 tick
    );

    event Flash(
        address indexed sender,
        address indexed recipient,
        uint256 amount0,
        uint256 amount1,
        uint256 paid0,
        uint256 paid1
    );

    event IncreaseObservationCardinalityNext(
        uint16 observationCardinalityNextOld,
        uint16 observationCardinalityNextNew
    );

    event SetFeeProtocol(uint8 feeProtocol0Old, uint8 feeProtocol1Old, uint8 feeProtocol0New, uint8 feeProtocol1New);

    event CollectProtocol(address indexed sender, address indexed recipient, uint128 amount0, uint128 amount1);
}// GPL-2.0-or-later
pragma solidity >=0.5.0;


interface IUniswapV3Pool is
    IUniswapV3PoolImmutables,
    IUniswapV3PoolState,
    IUniswapV3PoolDerivedState,
    IUniswapV3PoolActions,
    IUniswapV3PoolOwnerActions,
    IUniswapV3PoolEvents
{


}// GPL-2.0-or-later
pragma solidity >=0.5.0;

interface IUniswapV3SwapCallback {

    function uniswapV3SwapCallback(
        int256 amount0Delta,
        int256 amount1Delta,
        bytes calldata data
    ) external;

}// GPL-2.0-or-later
pragma solidity >=0.7.5;


interface ISwapRouter is IUniswapV3SwapCallback {

    struct ExactInputSingleParams {
        address tokenIn;
        address tokenOut;
        uint24 fee;
        address recipient;
        uint256 deadline;
        uint256 amountIn;
        uint256 amountOutMinimum;
        uint160 sqrtPriceLimitX96;
    }

    function exactInputSingle(ExactInputSingleParams calldata params) external payable returns (uint256 amountOut);


    struct ExactInputParams {
        bytes path;
        address recipient;
        uint256 deadline;
        uint256 amountIn;
        uint256 amountOutMinimum;
    }

    function exactInput(ExactInputParams calldata params) external payable returns (uint256 amountOut);


    struct ExactOutputSingleParams {
        address tokenIn;
        address tokenOut;
        uint24 fee;
        address recipient;
        uint256 deadline;
        uint256 amountOut;
        uint256 amountInMaximum;
        uint160 sqrtPriceLimitX96;
    }

    function exactOutputSingle(ExactOutputSingleParams calldata params) external payable returns (uint256 amountIn);


    struct ExactOutputParams {
        bytes path;
        address recipient;
        uint256 deadline;
        uint256 amountOut;
        uint256 amountInMaximum;
    }

    function exactOutput(ExactOutputParams calldata params) external payable returns (uint256 amountIn);

}// GPL-2.0-or-later
pragma solidity >=0.7.5;

interface IMulticall {

    function multicall(bytes[] calldata data) external payable returns (bytes[] memory results);

}// GPL-2.0-or-later
pragma solidity >=0.7.5;

interface IPeripheryPayments {

    function unwrapWETH9(uint256 amountMinimum, address recipient) external payable;


    function refundETH() external payable;


    function sweepToken(
        address token,
        uint256 amountMinimum,
        address recipient
    ) external payable;

}// GPL-2.0-or-later
pragma solidity >=0.5.0;

interface IPeripheryImmutableState {

    function factory() external view returns (address);


    function WETH9() external view returns (address);

}//MIT
pragma solidity >=0.7.0;


contract FixedInflationUniV3 is IFixedInflation {


    event Executed(bool);

    uint256 public constant ONE_HUNDRED = 1e18;

    address public initializer;

    mapping(address => uint256) private _tokenIndex;
    address[] private _tokensToTransfer;
    uint256[] private _tokenTotalSupply;
    uint256[] private _tokenAmounts;
    uint256[] private _tokenMintAmounts;
    uint256[] private _tokenBalanceOfBefore;

    address public host;

    FixedInflationEntry private _entry;
    FixedInflationOperation[] private _operations;

    address private constant UNISWAP_V3_SWAP_ROUTER_ADDRESS = 0xE592427A0AEce92De3Edee1F18E0157C05861564;
    address private ETHEREUM_ADDRESS;

    function lazyInit(bytes memory lazyInitData) public returns(bytes memory extensionInitResult) {


        require(initializer == address(0), "Already init");

        ETHEREUM_ADDRESS = IPeripheryImmutableState(UNISWAP_V3_SWAP_ROUTER_ADDRESS).WETH9();

        (address _host, bytes memory extensionPayload, FixedInflationEntry memory newEntry, FixedInflationOperation[] memory newOperations) = abi.decode(lazyInitData, (address, bytes, FixedInflationEntry, FixedInflationOperation[]));

        require(_host != address(0), "Blank host");
        initializer = msg.sender;

        host = _host;
        if(keccak256(extensionPayload) != keccak256("")) {
            extensionInitResult = _call(_host, extensionPayload);
        }
        _set(newEntry, newOperations);
    }

    receive() external payable {
    }

    modifier extensionOnly() {

        require(msg.sender == host, "Unauthorized");
        _;
    }

    modifier activeExtensionOnly() {

        require(IFixedInflationExtension(host).active(), "not active host");
        _;
    }

    function entry() public view returns(FixedInflationEntry memory, FixedInflationOperation[] memory) {

        return (_entry, _operations);
    }

    function setEntry(FixedInflationEntry memory newEntry, FixedInflationOperation[] memory newOperations) public override extensionOnly {

        _set(newEntry, newOperations);
    }

    function nextBlock() public view returns(uint256) {

        return _entry.lastBlock == 0 ? block.number : (_entry.lastBlock + _entry.blockInterval);
    }

    function flushBack(address[] memory tokenAddresses) public override extensionOnly {

        for(uint256 i = 0; i < tokenAddresses.length; i++) {
            _transferTo(tokenAddresses[i], host, _balanceOf(tokenAddresses[i]));
        }
    }

    function execute(bool earnByAmounts) public activeExtensionOnly returns(bool executed) {

        (executed,) = executeWithMinAmounts(earnByAmounts, new uint256[](0));
    }

    function executeWithMinAmounts(bool earnByAmounts, uint256[] memory minAmounts) public activeExtensionOnly returns(bool executed, uint256[] memory outputAmounts) {

        require(block.number >= nextBlock(), "Too early to execute");
        require(_operations.length > 0, "No operations");
        emit Executed(executed = _ensureExecute());
        if(executed) {
            _entry.lastBlock = block.number;
            outputAmounts = _execute(earnByAmounts, msg.sender, minAmounts);
        } else {
            try IFixedInflationExtension(host).deactivationByFailure() {
            } catch {
            }
        }
        _clearVars();
    }

    function _ensureExecute() private returns(bool) {

        _collectFixedInflationOperationsTokens();
        try IFixedInflationExtension(host).receiveTokens(_tokensToTransfer, _tokenAmounts, _tokenMintAmounts) {
        } catch {
            return false;
        }
        for(uint256 i = 0; i < _tokensToTransfer.length; i++) {
            if(_balanceOf(_tokensToTransfer[i]) != (_tokenBalanceOfBefore[i] + _tokenAmounts[i] + _tokenMintAmounts[i])) {
                return false;
            }
        }
        return true;
    }

    function _collectFixedInflationOperationsTokens() private {

        for(uint256 i = 0; i < _operations.length; i++) {
            FixedInflationOperation memory operation = _operations[i];
            _collectTokenData(operation.ammPlugin != address(0) && operation.enterInETH ? address(0) : operation.inputTokenAddress, operation.inputTokenAmount, operation.inputTokenAmountIsPercentage, operation.inputTokenAmountIsByMint);
        }
    }

    function _collectTokenData(address inputTokenAddress, uint256 inputTokenAmount, bool inputTokenAmountIsPercentage, bool inputTokenAmountIsByMint) private {

        if(inputTokenAmount == 0) {
            return;
        }

        uint256 position = _tokenIndex[inputTokenAddress];

        if(_tokensToTransfer.length == 0 || _tokensToTransfer[position] != inputTokenAddress) {
            _tokenIndex[inputTokenAddress] = (position = _tokensToTransfer.length);
            _tokensToTransfer.push(inputTokenAddress);
            _tokenAmounts.push(0);
            _tokenMintAmounts.push(0);
            _tokenBalanceOfBefore.push(_balanceOf(inputTokenAddress));
            _tokenTotalSupply.push(0);
        }
        uint256 amount = _calculateTokenAmount(inputTokenAddress, inputTokenAmount, inputTokenAmountIsPercentage);
        if(inputTokenAmountIsByMint) {
            _tokenMintAmounts[position] = _tokenMintAmounts[position] + amount;
        } else {
            _tokenAmounts[position] = _tokenAmounts[position] + amount;
        }
    }

    function _balanceOf(address tokenAddress) private view returns (uint256) {

        if(tokenAddress == address(0)) {
            return address(this).balance;
        }
        return IERC20(tokenAddress).balanceOf(address(this));
    }

    function _calculateTokenAmount(address tokenAddress, uint256 tokenAmount, bool tokenAmountIsPercentage) private returns(uint256) {

        if(!tokenAmountIsPercentage) {
            return tokenAmount;
        }
        uint256 tokenIndex = _tokenIndex[tokenAddress];
        _tokenTotalSupply[tokenIndex] = _tokenTotalSupply[tokenIndex] != 0 ? _tokenTotalSupply[tokenIndex] : IERC20(tokenAddress).totalSupply();
        return (_tokenTotalSupply[tokenIndex] * ((tokenAmount * 1e18) / ONE_HUNDRED)) / 1e18;
    }

    function _clearVars() private {

        for(uint256 i = 0; i < _tokensToTransfer.length; i++) {
            delete _tokenIndex[_tokensToTransfer[i]];
        }
        delete _tokensToTransfer;
        delete _tokenTotalSupply;
        delete _tokenAmounts;
        delete _tokenMintAmounts;
        delete _tokenBalanceOfBefore;
    }

    function _execute(bool earnByInput, address rewardReceiver, uint256[] memory minAmounts) private returns (uint256[] memory outputAmounts) {

        outputAmounts = new uint256[](_operations.length);
        for(uint256 i = 0 ; i < _operations.length; i++) {
            FixedInflationOperation memory operation = _operations[i];
            uint256 amountIn = _calculateTokenAmount(operation.inputTokenAddress, operation.inputTokenAmount, operation.inputTokenAmountIsPercentage);
            if(operation.ammPlugin == address(0)) {
                outputAmounts[i] = _transferTo(operation.inputTokenAddress, amountIn, rewardReceiver, _entry.callerRewardPercentage, operation);
            } else {
                outputAmounts[i] = _swap(operation, amountIn, i < minAmounts.length ? minAmounts[i] : 0, rewardReceiver, _entry.callerRewardPercentage, earnByInput);
            }
        }
    }

    function _swap(FixedInflationOperation memory operation, uint256 amountIn, uint256 minAmount, address rewardReceiver, uint256 callerRewardPercentage, bool earnByInput) private returns(uint256 outputAmount) {


        uint256 inputReward = earnByInput ? _calculateRewardPercentage(amountIn, callerRewardPercentage) : 0;

        address ethereumAddress = ETHEREUM_ADDRESS;
        if(operation.ammPlugin != UNISWAP_V3_SWAP_ROUTER_ADDRESS) {
            (ethereumAddress,,) = IAMM(operation.ammPlugin).data();
        }

        if(operation.exitInETH) {
            operation.swapPath[operation.swapPath.length - 1] = ethereumAddress;
        }

        address outputToken = operation.swapPath[operation.swapPath.length - 1];

        SwapData memory swapData = SwapData(
            operation.enterInETH,
            operation.exitInETH,
            operation.liquidityPoolAddresses,
            operation.swapPath,
            operation.enterInETH ? ethereumAddress : operation.inputTokenAddress,
            amountIn - inputReward,
            address(this)
        );

        if(swapData.inputToken != address(0) && !swapData.enterInETH) {
            _safeApprove(swapData.inputToken, operation.ammPlugin, swapData.amount);
        }

        outputAmount = operation.ammPlugin == UNISWAP_V3_SWAP_ROUTER_ADDRESS ? _swapLiquidityUniswapV3(swapData, minAmount) : IAMM(operation.ammPlugin).swapLiquidity{value : swapData.enterInETH ? amountIn : 0}(swapData);

        require(outputAmount >= minAmount, "slippage");

        if(earnByInput) {
            _transferTo(operation.enterInETH ? address(0) : operation.inputTokenAddress, rewardReceiver, inputReward);
        }
        _transferTo(operation.exitInETH ? address(0) : outputToken, outputAmount, earnByInput ? address(0) : rewardReceiver, earnByInput ? 0 : callerRewardPercentage, operation);
    }

    function _calculateRewardPercentage(uint256 totalAmount, uint256 rewardPercentage) private pure returns (uint256) {

        return (totalAmount * ((rewardPercentage * 1e18) / ONE_HUNDRED)) / 1e18;
    }

    function _transferTo(address erc20TokenAddress, uint256 totalAmount, address rewardReceiver, uint256 callerRewardPercentage, FixedInflationOperation memory operation) private returns(uint256 outputAmount) {

        outputAmount = totalAmount;
        uint256 availableAmount = totalAmount;

        uint256 currentPartialAmount = rewardReceiver == address(0) ? 0 : _calculateRewardPercentage(availableAmount, callerRewardPercentage);
        _transferTo(erc20TokenAddress, rewardReceiver, currentPartialAmount);
        availableAmount -= currentPartialAmount;

        if(erc20TokenAddress != address(0)) {
            _safeApprove(erc20TokenAddress, IFixedInflationFactory(initializer).initializer(), availableAmount);
        }
        currentPartialAmount = IFixedInflationFactory(initializer).payFee{value : erc20TokenAddress != address(0) ? 0 : availableAmount}(address(this), erc20TokenAddress, availableAmount, "");
        availableAmount -= currentPartialAmount;

        uint256 stillAvailableAmount = availableAmount;

        for(uint256 i = 0; i < operation.receivers.length - 1; i++) {
            _transferTo(erc20TokenAddress, operation.receivers[i], currentPartialAmount = _calculateRewardPercentage(stillAvailableAmount, operation.receiversPercentages[i]));
            availableAmount -= currentPartialAmount;
        }

        _transferTo(erc20TokenAddress, operation.receivers[operation.receivers.length - 1], availableAmount);
    }

    function _transferTo(address erc20TokenAddress, address to, uint256 value) private {

        if(value == 0) {
            return;
        }
        if(erc20TokenAddress == address(0)) {
            (bool result,) = to.call{value:value}("");
            require(result, "ETH transfer failed");
            return;
        }
        if(to != address(0)) {
            _safeTransfer(erc20TokenAddress, to, value);
        } else {
            _safeApprove(erc20TokenAddress, host, value);
            IFixedInflationExtension(host).burnToken(erc20TokenAddress, value);
        }
    }

    function _safeApprove(address erc20TokenAddress, address to, uint256 value) internal {

        bytes memory returnData = _call(erc20TokenAddress, abi.encodeWithSelector(IERC20(erc20TokenAddress).approve.selector, to, value));
        require(returnData.length == 0 || abi.decode(returnData, (bool)), 'APPROVE_FAILED');
    }

    function _safeTransfer(address erc20TokenAddress, address to, uint256 value) private {

        bytes memory returnData = _call(erc20TokenAddress, abi.encodeWithSelector(IERC20(erc20TokenAddress).transfer.selector, to, value));
        require(returnData.length == 0 || abi.decode(returnData, (bool)), 'TRANSFER_FAILED');
    }

    function _call(address location, bytes memory payload) private returns(bytes memory returnData) {

        assembly {
            let result := call(gas(), location, 0, add(payload, 0x20), mload(payload), 0, 0)
            let size := returndatasize()
            returnData := mload(0x40)
            mstore(returnData, size)
            let returnDataPayloadStart := add(returnData, 0x20)
            returndatacopy(returnDataPayloadStart, 0, size)
            mstore(0x40, add(returnDataPayloadStart, size))
            switch result case 0 {revert(returnDataPayloadStart, size)}
        }
    }

    function _set(FixedInflationEntry memory fixedInflationEntry, FixedInflationOperation[] memory operations) private {

        require(keccak256(bytes(fixedInflationEntry.name)) != keccak256(""), "Name");
        require(fixedInflationEntry.blockInterval > 0, "Interval");
        require(fixedInflationEntry.callerRewardPercentage < ONE_HUNDRED, "Percentage");
        _entry = fixedInflationEntry;
        _setOperations(operations);
    }

    function _setOperations(FixedInflationOperation[] memory operations) private {

        delete _operations;
        for(uint256 i = 0; i < operations.length; i++) {
            FixedInflationOperation memory operation = operations[i];
            require(operation.receivers.length > 0, "No receivers");
            require(operation.receiversPercentages.length == (operation.receivers.length - 1), "Last receiver percentage is calculated automatically");
            uint256 percentage = 0;
            for(uint256 j = 0; j < operation.receivers.length - 1; j++) {
                percentage += operation.receiversPercentages[j];
            }
            require(percentage < ONE_HUNDRED, "More than one hundred");
            _operations.push(operation);
        }
    }

    function _clone(address original) private returns (address copy) {

        assembly {
            mstore(
                0,
                or(
                    0x5880730000000000000000000000000000000000000000803b80938091923cF3,
                    mul(original, 0x1000000000000000000)
                )
            )
            copy := create(0, 0, 32)
            switch extcodesize(copy)
                case 0 {
                    invalid()
                }
        }
    }

    function _swapLiquidityUniswapV3(SwapData memory data, uint256 amountOutMinimum) private returns(uint256) {

        bytes memory path = abi.encodePacked(data.inputToken, IUniswapV3Pool(data.liquidityPoolAddresses[0]).fee(), data.path[0]);
        for(uint256 i = 1; i < data.liquidityPoolAddresses.length; i++) {
            path = abi.encodePacked(path, IUniswapV3Pool(data.liquidityPoolAddresses[i]).fee(), data.path[i]);
        }

        ISwapRouter.ExactInputParams memory exactInputParams = ISwapRouter.ExactInputParams({
            path : path,
            recipient : data.exitInETH ? address(0) : data.receiver,
            deadline : block.timestamp + 10000,
            amountIn : data.amount,
            amountOutMinimum : amountOutMinimum
        });

        if(data.enterInETH || data.exitInETH) {
            return _swapLiquidityMulticall(data.enterInETH, data.exitInETH, data.amount, data.receiver, abi.encodeWithSelector(ISwapRouter(UNISWAP_V3_SWAP_ROUTER_ADDRESS).exactInput.selector, exactInputParams));
        }
        return ISwapRouter(UNISWAP_V3_SWAP_ROUTER_ADDRESS).exactInput(exactInputParams);
    }

    function _swapLiquidityMulticall(bool enterInETH, bool exitInETH, uint256 value, address recipient, bytes memory data) private returns (uint256) {

        bytes[] memory multicall = new bytes[](enterInETH && exitInETH ? 3 : 2);
        multicall[0] = data;
        if(enterInETH && exitInETH) {
            multicall[1] = abi.encodeWithSelector(IPeripheryPayments(UNISWAP_V3_SWAP_ROUTER_ADDRESS).refundETH.selector);
            multicall[2] = abi.encodeWithSelector(IPeripheryPayments(UNISWAP_V3_SWAP_ROUTER_ADDRESS).unwrapWETH9.selector, 0, recipient);
        } else {
            multicall[1] = enterInETH ? abi.encodeWithSelector(IPeripheryPayments(UNISWAP_V3_SWAP_ROUTER_ADDRESS).refundETH.selector) : abi.encodeWithSelector(IPeripheryPayments(UNISWAP_V3_SWAP_ROUTER_ADDRESS).unwrapWETH9.selector, 0, recipient);
        }
        return abi.decode(IMulticall(UNISWAP_V3_SWAP_ROUTER_ADDRESS).multicall{value : enterInETH ? value : 0}(multicall)[0], (uint256));
    }
}

interface IFixedInflationFactory {

    function initializer() external view returns (address);

    function payFee(address sender, address tokenAddress, uint256 value, bytes calldata permitSignature) external payable returns (uint256 feePaid);

}