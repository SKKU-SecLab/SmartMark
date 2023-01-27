
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


library SafeERC20 {

    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {

        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {

        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {

        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {


        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}// AGPL-3.0-only
pragma solidity >=0.8.0;

abstract contract ERC20 {

    event Transfer(address indexed from, address indexed to, uint256 amount);

    event Approval(address indexed owner, address indexed spender, uint256 amount);


    string public name;

    string public symbol;

    uint8 public immutable decimals;


    uint256 public totalSupply;

    mapping(address => uint256) public balanceOf;

    mapping(address => mapping(address => uint256)) public allowance;


    bytes32 public constant PERMIT_TYPEHASH =
        keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)");

    uint256 internal immutable INITIAL_CHAIN_ID;

    bytes32 internal immutable INITIAL_DOMAIN_SEPARATOR;

    mapping(address => uint256) public nonces;


    constructor(
        string memory _name,
        string memory _symbol,
        uint8 _decimals
    ) {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;

        INITIAL_CHAIN_ID = block.chainid;
        INITIAL_DOMAIN_SEPARATOR = computeDomainSeparator();
    }


    function approve(address spender, uint256 amount) public virtual returns (bool) {
        allowance[msg.sender][spender] = amount;

        emit Approval(msg.sender, spender, amount);

        return true;
    }

    function transfer(address to, uint256 amount) public virtual returns (bool) {
        balanceOf[msg.sender] -= amount;

        unchecked {
            balanceOf[to] += amount;
        }

        emit Transfer(msg.sender, to, amount);

        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual returns (bool) {
        if (allowance[from][msg.sender] != type(uint256).max) {
            allowance[from][msg.sender] -= amount;
        }

        balanceOf[from] -= amount;

        unchecked {
            balanceOf[to] += amount;
        }

        emit Transfer(from, to, amount);

        return true;
    }


    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public virtual {
        require(deadline >= block.timestamp, "PERMIT_DEADLINE_EXPIRED");

        unchecked {
            bytes32 digest = keccak256(
                abi.encodePacked(
                    "\x19\x01",
                    DOMAIN_SEPARATOR(),
                    keccak256(abi.encode(PERMIT_TYPEHASH, owner, spender, value, nonces[owner]++, deadline))
                )
            );

            address recoveredAddress = ecrecover(digest, v, r, s);
            require(recoveredAddress != address(0) && recoveredAddress == owner, "INVALID_PERMIT_SIGNATURE");

            allowance[recoveredAddress][spender] = value;
        }

        emit Approval(owner, spender, value);
    }

    function DOMAIN_SEPARATOR() public view virtual returns (bytes32) {
        return block.chainid == INITIAL_CHAIN_ID ? INITIAL_DOMAIN_SEPARATOR : computeDomainSeparator();
    }

    function computeDomainSeparator() internal view virtual returns (bytes32) {
        return
            keccak256(
                abi.encode(
                    keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"),
                    keccak256(bytes(name)),
                    keccak256(bytes("1")),
                    block.chainid,
                    address(this)
                )
            );
    }


    function _mint(address to, uint256 amount) internal virtual {
        totalSupply += amount;

        unchecked {
            balanceOf[to] += amount;
        }

        emit Transfer(address(0), to, amount);
    }

    function _burn(address from, uint256 amount) internal virtual {
        balanceOf[from] -= amount;

        unchecked {
            totalSupply -= amount;
        }

        emit Transfer(from, address(0), amount);
    }
}// AGPL-3.0-only
pragma solidity >=0.8.0;


library SafeTransferLib {


    function safeTransferETH(address to, uint256 amount) internal {

        bool callStatus;

        assembly {
            callStatus := call(gas(), to, amount, 0, 0, 0, 0)
        }

        require(callStatus, "ETH_TRANSFER_FAILED");
    }


    function safeTransferFrom(
        ERC20 token,
        address from,
        address to,
        uint256 amount
    ) internal {

        bool callStatus;

        assembly {
            let freeMemoryPointer := mload(0x40)

            mstore(freeMemoryPointer, 0x23b872dd00000000000000000000000000000000000000000000000000000000) // Begin with the function selector.
            mstore(add(freeMemoryPointer, 4), and(from, 0xffffffffffffffffffffffffffffffffffffffff)) // Mask and append the "from" argument.
            mstore(add(freeMemoryPointer, 36), and(to, 0xffffffffffffffffffffffffffffffffffffffff)) // Mask and append the "to" argument.
            mstore(add(freeMemoryPointer, 68), amount) // Finally append the "amount" argument. No mask as it's a full 32 byte value.

            callStatus := call(gas(), token, 0, freeMemoryPointer, 100, 0, 0)
        }

        require(didLastOptionalReturnCallSucceed(callStatus), "TRANSFER_FROM_FAILED");
    }

    function safeTransfer(
        ERC20 token,
        address to,
        uint256 amount
    ) internal {

        bool callStatus;

        assembly {
            let freeMemoryPointer := mload(0x40)

            mstore(freeMemoryPointer, 0xa9059cbb00000000000000000000000000000000000000000000000000000000) // Begin with the function selector.
            mstore(add(freeMemoryPointer, 4), and(to, 0xffffffffffffffffffffffffffffffffffffffff)) // Mask and append the "to" argument.
            mstore(add(freeMemoryPointer, 36), amount) // Finally append the "amount" argument. No mask as it's a full 32 byte value.

            callStatus := call(gas(), token, 0, freeMemoryPointer, 68, 0, 0)
        }

        require(didLastOptionalReturnCallSucceed(callStatus), "TRANSFER_FAILED");
    }

    function safeApprove(
        ERC20 token,
        address to,
        uint256 amount
    ) internal {

        bool callStatus;

        assembly {
            let freeMemoryPointer := mload(0x40)

            mstore(freeMemoryPointer, 0x095ea7b300000000000000000000000000000000000000000000000000000000) // Begin with the function selector.
            mstore(add(freeMemoryPointer, 4), and(to, 0xffffffffffffffffffffffffffffffffffffffff)) // Mask and append the "to" argument.
            mstore(add(freeMemoryPointer, 36), amount) // Finally append the "amount" argument. No mask as it's a full 32 byte value.

            callStatus := call(gas(), token, 0, freeMemoryPointer, 68, 0, 0)
        }

        require(didLastOptionalReturnCallSucceed(callStatus), "APPROVE_FAILED");
    }


    function didLastOptionalReturnCallSucceed(bool callStatus) private pure returns (bool success) {

        assembly {
            let returnDataSize := returndatasize()

            if iszero(callStatus) {
                returndatacopy(0, 0, returnDataSize)

                revert(0, returnDataSize)
            }

            switch returnDataSize
            case 32 {
                returndatacopy(0, 0, returnDataSize)

                success := iszero(iszero(mload(0)))
            }
            case 0 {
                success := 1
            }
            default {
                success := 0
            }
        }
    }
}// GPL-3.0-or-later

pragma solidity 0.8.7;

interface IStrategy {

    function skim(uint256 amount) external;


    function harvest(uint256 balance, address sender) external returns (int256 amountAdded);


    function withdraw(uint256 amount) external returns (uint256 actualAmount);


    function exit(uint256 balance) external returns (int256 amountAdded);

}// GPL-3.0-or-later

pragma solidity 0.8.7;

interface IUniswapV2Pair {

    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;

    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);

}// UNLICENSED

pragma solidity 0.8.7;

interface IBentoBoxMinimal {


    struct Rebase {
        uint128 elastic;
        uint128 base;
    }

    struct StrategyData {
        uint64 strategyStartDate;
        uint64 targetPercentage;
        uint128 balance; // the balance of the strategy that BentoBox thinks is in there
    }

    function strategyData(address token) external view returns (StrategyData memory);


    function balanceOf(address, address) external view returns (uint256);


    function deposit(
        address token_,
        address from,
        address to,
        uint256 amount,
        uint256 share
    ) external payable returns (uint256 amountOut, uint256 shareOut);


    function withdraw(
        address token_,
        address from,
        address to,
        uint256 amount,
        uint256 share
    ) external returns (uint256 amountOut, uint256 shareOut);


    function transfer(
        address token,
        address from,
        address to,
        uint256 share
    ) external;


    function toShare(
        address token,
        uint256 amount,
        bool roundUp
    ) external view returns (uint256 share);


    function toAmount(
        address token,
        uint256 share,
        bool roundUp
    ) external view returns (uint256 amount);


    function registerProtocol() external;


    function totals(address token) external view returns (Rebase memory);


    function harvest(
        address token,
        bool balance,
        uint256 maxChangeAmount
    ) external;

}// GPL-3.0-or-later

pragma solidity 0.8.7;



library UniswapV2Library {

    function sortTokens(address tokenA, address tokenB) internal pure returns (address token0, address token1) {

        require(tokenA != tokenB, "UniswapV2Library: IDENTICAL_ADDRESSES");
        (token0, token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        require(token0 != address(0), "UniswapV2Library: ZERO_ADDRESS");
    }

    function pairFor(
        address factory,
        address tokenA,
        address tokenB,
        bytes32 pairCodeHash
    ) internal pure returns (address pair) {

        (address token0, address token1) = sortTokens(tokenA, tokenB);

        pair = address(
            uint160(
                uint256(
                    keccak256(
                        abi.encodePacked(
                            hex"ff",
                            factory,
                            keccak256(abi.encodePacked(token0, token1)),
                            pairCodeHash // init code hash
                        )
                    )
                )
            )
        );
    }

    function getReserves(
        address factory,
        address tokenA,
        address tokenB,
        bytes32 pairCodeHash
    ) internal view returns (uint256 reserveA, uint256 reserveB) {

        (address token0, ) = sortTokens(tokenA, tokenB);
        (uint256 reserve0, uint256 reserve1, ) = IUniswapV2Pair(pairFor(factory, tokenA, tokenB, pairCodeHash)).getReserves();
        (reserveA, reserveB) = tokenA == token0 ? (reserve0, reserve1) : (reserve1, reserve0);
    }

    function quote(
        uint256 amountA,
        uint256 reserveA,
        uint256 reserveB
    ) internal pure returns (uint256 amountB) {

        require(amountA > 0, "UniswapV2Library: INSUFFICIENT_AMOUNT");
        require(reserveA > 0 && reserveB > 0, "UniswapV2Library: INSUFFICIENT_LIQUIDITY");
        amountB = (amountA * reserveB) / reserveA;
    }

    function getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    ) internal pure returns (uint256 amountOut) {

        require(amountIn > 0, "UniswapV2Library: INSUFFICIENT_INPUT_AMOUNT");
        require(reserveIn > 0 && reserveOut > 0, "UniswapV2Library: INSUFFICIENT_LIQUIDITY");
        uint256 amountInWithFee = amountIn * 997;
        uint256 numerator = amountInWithFee * reserveOut;
        uint256 denominator = (reserveIn * 1000) + amountInWithFee;
        amountOut = numerator / denominator;
    }

    function getAmountIn(
        uint256 amountOut,
        uint256 reserveIn,
        uint256 reserveOut
    ) internal pure returns (uint256 amountIn) {

        require(amountOut > 0, "UniswapV2Library: INSUFFICIENT_OUTPUT_AMOUNT");
        require(reserveIn > 0 && reserveOut > 0, "UniswapV2Library: INSUFFICIENT_LIQUIDITY");
        uint256 numerator = reserveIn * amountOut * 1000;
        uint256 denominator = (reserveOut - amountOut) * 997;
        amountIn = (numerator / denominator) + 1;
    }

    function getAmountsOut(
        address factory,
        uint256 amountIn,
        address[] memory path,
        bytes32 pairCodeHash
    ) internal view returns (uint256[] memory amounts) {

        require(path.length >= 2, "UniswapV2Library: INVALID_PATH");
        amounts = new uint256[](path.length);
        amounts[0] = amountIn;
        for (uint256 i; i < path.length - 1; i++) {
            (uint256 reserveIn, uint256 reserveOut) = getReserves(factory, path[i], path[i + 1], pairCodeHash);
            amounts[i + 1] = getAmountOut(amounts[i], reserveIn, reserveOut);
        }
    }

    function getAmountsIn(
        address factory,
        uint256 amountOut,
        address[] memory path,
        bytes32 pairCodeHash
    ) internal view returns (uint256[] memory amounts) {

        require(path.length >= 2, "UniswapV2Library: INVALID_PATH");
        amounts = new uint256[](path.length);
        amounts[amounts.length - 1] = amountOut;
        for (uint256 i = path.length - 1; i > 0; i--) {
            (uint256 reserveIn, uint256 reserveOut) = getReserves(factory, path[i - 1], path[i], pairCodeHash);
            amounts[i - 1] = getAmountIn(amounts[i], reserveIn, reserveOut);
        }
    }
}// GPL-3.0-or-later

pragma solidity 0.8.7;


abstract contract BaseStrategy is IStrategy, Ownable {
    using SafeERC20 for IERC20;

    address public immutable strategyToken;
    address public immutable bentoBox;
    address public immutable factory;
    address public immutable bridgeToken;

    bool public exited; /// @dev After bentobox 'exits' the strategy harvest, skim and withdraw functions can no loner be called
    uint256 public maxBentoBoxBalance; /// @dev Slippage protection when calling harvest
    mapping(address => bool) public strategyExecutors; /// @dev EOAs that can execute safeHarvest

    bytes32 internal immutable pairCodeHash;

    event LogConvert(address indexed server, address indexed token0, address indexed token1, uint256 amount0, uint256 amount1);
    event LogSetStrategyExecutor(address indexed executor, bool allowed);

    constructor(
        address _strategyToken,
        address _bentoBox,
        address _factory,
        address _bridgeToken,
        address _strategyExecutor,
        bytes32 _pairCodeHash
    ) {
        strategyToken = _strategyToken;
        bentoBox = _bentoBox;
        factory = _factory;
        bridgeToken = _bridgeToken;
        pairCodeHash = _pairCodeHash;

        if (_strategyExecutor != address(0)) {
            strategyExecutors[_strategyExecutor] = true;
            emit LogSetStrategyExecutor(_strategyExecutor, true);
        }
    }


    function _skim(uint256 amount) internal virtual;

    function _harvest(uint256 balance) internal virtual returns (int256 amountAdded);

    function _withdraw(uint256 amount) internal virtual;

    function _exit() internal virtual;

    function _harvestRewards() internal virtual {}


    modifier isActive() {
        require(!exited, "BentoBox Strategy: exited");
        _;
    }

    modifier onlyBentoBox() {
        require(msg.sender == bentoBox, "BentoBox Strategy: only BentoBox");
        _;
    }

    modifier onlyExecutor() {
        require(strategyExecutors[msg.sender], "BentoBox Strategy: only Executors");
        _;
    }

    function setStrategyExecutor(address executor, bool value) external onlyOwner {
        strategyExecutors[executor] = value;
        emit LogSetStrategyExecutor(executor, value);
    }

    function skim(uint256 amount) external override {
        _skim(amount);
    }

    function safeHarvest(
        uint256 maxBalance,
        bool rebalance,
        uint256 maxChangeAmount,
        bool harvestRewards
    ) external onlyExecutor {
        if (harvestRewards) {
            _harvestRewards();
        }

        if (maxBalance > 0) {
            maxBentoBoxBalance = maxBalance;
        }

        IBentoBoxMinimal(bentoBox).harvest(strategyToken, rebalance, maxChangeAmount);
    }

    function harvest(uint256 balance, address sender) external override isActive onlyBentoBox returns (int256) {

        if (sender == address(this) && IBentoBoxMinimal(bentoBox).totals(strategyToken).elastic <= maxBentoBoxBalance && balance > 0) {
            int256 amount = _harvest(balance);


            uint256 contractBalance = IERC20(strategyToken).balanceOf(address(this));

            if (amount >= 0) {

                if (contractBalance > 0) {
                    IERC20(strategyToken).safeTransfer(bentoBox, contractBalance);
                }

                return int256(contractBalance);
            } else if (contractBalance > 0) {

                int256 diff = amount + int256(contractBalance);

                if (diff > 0) {

                    IERC20(strategyToken).safeTransfer(bentoBox, uint256(diff));
                    _skim(uint256(-amount));
                } else {

                    _skim(contractBalance);
                }

                return diff;
            } else {

                return amount;
            }
        }

        return int256(0);
    }

    function withdraw(uint256 amount) external override isActive onlyBentoBox returns (uint256 actualAmount) {
        _withdraw(amount);
        actualAmount = IERC20(strategyToken).balanceOf(address(this));
        IERC20(strategyToken).safeTransfer(bentoBox, actualAmount);
    }

    function exit(uint256 balance) external override onlyBentoBox returns (int256 amountAdded) {
        _exit();
        uint256 actualBalance = IERC20(strategyToken).balanceOf(address(this));
        amountAdded = int256(actualBalance) - int256(balance);
        IERC20(strategyToken).safeTransfer(bentoBox, actualBalance);
        exited = true;
    }

    function afterExit(
        address to,
        uint256 value,
        bytes memory data
    ) public onlyOwner returns (bool success) {
        require(exited, "BentoBox Strategy: not exited");
        (success, ) = to.call{value: value}(data);
    }

    function swapExactTokensForUnderlying(uint256 amountOutMin, address inputToken) public onlyExecutor returns (uint256 amountOut) {
        require(factory != address(0), "BentoBox Strategy: cannot swap");
        require(inputToken != strategyToken, "BentoBox Strategy: invalid swap");

        bool useBridge = bridgeToken != address(0);

        address[] memory path = new address[](useBridge ? 3 : 2);

        path[0] = inputToken;

        if (useBridge) {
            path[1] = bridgeToken;
        }

        path[path.length - 1] = strategyToken;

        uint256 amountIn = IERC20(path[0]).balanceOf(address(this));

        uint256[] memory amounts = UniswapV2Library.getAmountsOut(factory, amountIn, path, pairCodeHash);

        amountOut = amounts[amounts.length - 1];

        require(amountOut >= amountOutMin, "BentoBox Strategy: insufficient output");

        IERC20(path[0]).safeTransfer(UniswapV2Library.pairFor(factory, path[0], path[1], pairCodeHash), amounts[0]);

        _swap(amounts, path, address(this));

        emit LogConvert(msg.sender, inputToken, strategyToken, amountIn, amountOut);
    }

    function _swap(
        uint256[] memory amounts,
        address[] memory path,
        address _to
    ) internal {
        for (uint256 i; i < path.length - 1; i++) {
            (address input, address output) = (path[i], path[i + 1]);
            address token0 = input < output ? input : output;
            uint256 amountOut = amounts[i + 1];
            (uint256 amount0Out, uint256 amount1Out) = input == token0 ? (uint256(0), amountOut) : (amountOut, uint256(0));
            address to = i < path.length - 2 ? UniswapV2Library.pairFor(factory, output, path[i + 2], pairCodeHash) : _to;
            IUniswapV2Pair(UniswapV2Library.pairFor(factory, input, output, pairCodeHash)).swap(amount0Out, amount1Out, to, new bytes(0));
        }
    }
}// MIT
pragma solidity >=0.6.12;

interface Tether {

    function approve(address spender, uint256 value) external;


    function balanceOf(address user) external view returns (uint256);


    function transfer(address to, uint256 value) external;

}// MIT
pragma solidity >=0.6.12;

interface ICurvePool {

    function coins(uint256 i) external view returns (address);


    function exchange_underlying(
        int128 i,
        int128 j,
        uint256 dx,
        uint256 min_dy,
        address receiver
    ) external returns (uint256);


    function exchange(
        int128 i,
        int128 j,
        uint256 dx,
        uint256 min_dy,
        address receiver
    ) external returns (uint256);


    function exchange(
        uint256 i,
        uint256 j,
        uint256 dx,
        uint256 min_dy
    ) external returns (uint256);


    function get_dy_underlying(
        int128 i,
        int128 j,
        uint256 dx
    ) external view returns (uint256);


    function get_dy(
        int128 i,
        int128 j,
        uint256 dx
    ) external view returns (uint256);


    function approve(address _spender, uint256 _value) external returns (bool);


    function add_liquidity(uint256[2] memory amounts, uint256 _min_mint_amount) external;


    function add_liquidity(uint256[3] memory amounts, uint256 _min_mint_amount) external;


    function add_liquidity(uint256[4] memory amounts, uint256 _min_mint_amount) external;


    function remove_liquidity_one_coin(
        uint256 tokenAmount,
        int128 i,
        uint256 min_amount
    ) external returns (uint256);


    function remove_liquidity_one_coin(
        uint256 tokenAmount,
        uint256 i,
        uint256 min_amount
    ) external returns (uint256);


    function remove_liquidity_one_coin(
        uint256 tokenAmount,
        int128 i,
        uint256 min_amount,
        address receiver
    ) external returns (uint256);

}// MIT
pragma solidity >=0.6.12;

interface ICurveThreePool {

    function exchange(
        int128 i,
        int128 j,
        uint256 dx,
        uint256 min_dy
    ) external;


    function get_dy_underlying(
        int128 i,
        int128 j,
        uint256 dx
    ) external view returns (uint256);


    function get_dy(
        int128 i,
        int128 j,
        uint256 dx
    ) external view returns (uint256);


    function add_liquidity(uint256[3] memory amounts, uint256 _min_mint_amount) external;


    function remove_liquidity_one_coin(
        uint256 amount,
        int128 i,
        uint256 minAmount
    ) external;

}// BUSL-1.1
pragma solidity >=0.7.0 <0.9.0;

interface ILPStaking {

    function BONUS_MULTIPLIER() external view returns (uint256);


    function add(uint256 _allocPoint, address _lpToken) external;


    function bonusEndBlock() external view returns (uint256);


    function deposit(uint256 _pid, uint256 _amount) external;


    function emergencyWithdraw(uint256 _pid) external;


    function getMultiplier(uint256 _from, uint256 _to) external view returns (uint256);


    function lpBalances(uint256) external view returns (uint256);


    function massUpdatePools() external;


    function owner() external view returns (address);


    function pendingStargate(uint256 _pid, address _user) external view returns (uint256);


    function poolInfo(uint256)
        external
        view
        returns (
            address lpToken,
            uint256 allocPoint,
            uint256 lastRewardBlock,
            uint256 accStargatePerShare
        );


    function poolLength() external view returns (uint256);


    function renounceOwnership() external;


    function set(uint256 _pid, uint256 _allocPoint) external;


    function setStargatePerBlock(uint256 _stargatePerBlock) external;


    function stargate() external view returns (address);


    function stargatePerBlock() external view returns (uint256);


    function startBlock() external view returns (uint256);


    function totalAllocPoint() external view returns (uint256);


    function transferOwnership(address newOwner) external;


    function updatePool(uint256 _pid) external;


    function userInfo(uint256, address) external view returns (uint256 amount, uint256 rewardDebt);


    function withdraw(uint256 _pid, uint256 _amount) external;

}// BUSL-1.1
pragma solidity >=0.6.12;

interface IStargatePool {

    function totalLiquidity() external view returns (uint256);


    function totalSupply() external view returns (uint256);


    function localDecimals() external view returns (uint256);


    function token() external view returns (address);

}// BUSL-1.1

pragma solidity >=0.7.6;
pragma abicoder v2;

interface IStargateRouter {

    struct lzTxObj {
        uint256 dstGasForCall;
        uint256 dstNativeAmount;
        bytes dstNativeAddr;
    }

    function addLiquidity(
        uint256 _poolId,
        uint256 _amountLD,
        address _to
    ) external;


    function swap(
        uint16 _dstChainId,
        uint256 _srcPoolId,
        uint256 _dstPoolId,
        address payable _refundAddress,
        uint256 _amountLD,
        uint256 _minAmountLD,
        lzTxObj memory _lzTxParams,
        bytes calldata _to,
        bytes calldata _payload
    ) external payable;


    function redeemRemote(
        uint16 _dstChainId,
        uint256 _srcPoolId,
        uint256 _dstPoolId,
        address payable _refundAddress,
        uint256 _amountLP,
        uint256 _minAmountLD,
        bytes calldata _to,
        lzTxObj memory _lzTxParams
    ) external payable;


    function instantRedeemLocal(
        uint16 _srcPoolId,
        uint256 _amountLP,
        address _to
    ) external returns (uint256);


    function redeemLocal(
        uint16 _dstChainId,
        uint256 _srcPoolId,
        uint256 _dstPoolId,
        address payable _refundAddress,
        uint256 _amountLP,
        bytes calldata _to,
        lzTxObj memory _lzTxParams
    ) external payable;


    function sendCredits(
        uint16 _dstChainId,
        uint256 _srcPoolId,
        uint256 _dstPoolId,
        address payable _refundAddress
    ) external payable;


    function quoteLayerZeroFee(
        uint16 _dstChainId,
        uint8 _functionType,
        bytes calldata _toAddress,
        bytes calldata _transferAndCallPayload,
        lzTxObj memory _lzTxParams
    ) external view returns (uint256, uint256);

}// BUSL-1.1
pragma solidity >=0.6.12;

interface IStargateToken {

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function balanceOf(address account) external view returns (uint256);


    function chainId() external view returns (uint16);


    function decimals() external view returns (uint8);


    function decreaseAllowance(address spender, uint256 subtractedValue)
        external
        returns (bool);


    function dstContractLookup(uint16) external view returns (bytes memory);


    function endpoint() external view returns (address);


    function estimateSendTokensFee(
        uint16 _dstChainId,
        bool _useZro,
        bytes memory txParameters
    ) external view returns (uint256 nativeFee, uint256 zroFee);


    function forceResumeReceive(uint16 _srcChainId, bytes memory _srcAddress)
        external;


    function increaseAllowance(address spender, uint256 addedValue)
        external
        returns (bool);


    function isMain() external view returns (bool);


    function lzReceive(
        uint16 _srcChainId,
        bytes memory _fromAddress,
        uint64 nonce,
        bytes memory _payload
    ) external;


    function name() external view returns (string memory);


    function owner() external view returns (address);


    function pauseSendTokens(bool _pause) external;


    function paused() external view returns (bool);


    function renounceOwnership() external;


    function sendTokens(
        uint16 _dstChainId,
        bytes memory _to,
        uint256 _qty,
        address zroPaymentAddress,
        bytes memory adapterParam
    ) external payable;


    function setConfig(
        uint16 _version,
        uint16 _chainId,
        uint256 _configType,
        bytes memory _config
    ) external;


    function setDestination(
        uint16 _dstChainId,
        bytes memory _destinationContractAddress
    ) external;


    function setReceiveVersion(uint16 version) external;


    function setSendVersion(uint16 version) external;


    function symbol() external view returns (string memory);


    function totalSupply() external view returns (uint256);


    function transfer(address recipient, uint256 amount)
        external
        returns (bool);


    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);


    function transferOwnership(address newOwner) external;

}// GPL-3.0-or-later
pragma solidity 0.8.7;



abstract contract BaseStargateLPStrategy is BaseStrategy {
    using SafeTransferLib for ERC20;

    event LpMinted(uint256 total, uint256 strategyAmount, uint256 feeAmount);
    event FeeParametersChanged(address feeCollector, uint256 feeAmount);

    ILPStaking public immutable staking;
    IStargateToken public immutable stargateToken;
    IStargateRouter public immutable router;
    ERC20 public immutable underlyingToken;

    uint256 public immutable poolId;
    uint256 public immutable pid;

    address public feeCollector;
    uint8 public feePercent;

    constructor(
        address _strategyToken,
        address _bentoBox,
        IStargateRouter _router,
        uint256 _poolId,
        ILPStaking _staking,
        uint256 _pid
    ) BaseStrategy(_strategyToken, _bentoBox, address(0), address(0), address(0), "") {
        router = _router;
        poolId = _poolId;
        staking = _staking;
        pid = _pid;

        ERC20 _underlyingToken = ERC20(IStargatePool(_strategyToken).token());
        stargateToken = IStargateToken(_staking.stargate());
        feePercent = 10;
        feeCollector = _msgSender();

        _underlyingToken.safeApprove(address(_router), type(uint256).max);
        underlyingToken = _underlyingToken;
        
        ERC20(_strategyToken).safeApprove(address(_staking), type(uint256).max);
    }

    function _skim(uint256 amount) internal override {
        staking.deposit(pid, amount);
    }

    function _harvest(uint256) internal override returns (int256) {
        staking.withdraw(pid, 0);
        return int256(0);
    }

    function _withdraw(uint256 amount) internal override {
        staking.withdraw(pid, amount);
    }

    function _exit() internal override {
        staking.emergencyWithdraw(pid);
    }

    function swapToLP(uint256 amountOutMin) public onlyExecutor returns (uint256 amountOut) {
        uint256 amountStrategyLpBefore = ERC20(strategyToken).balanceOf(address(this));

        _swapToUnderlying();

        uint256 underlyingTokenAmount = underlyingToken.balanceOf(address(this));

        router.addLiquidity(poolId, underlyingTokenAmount, address(this));

        uint256 total = ERC20(strategyToken).balanceOf(address(this)) - amountStrategyLpBefore;

        require(total >= amountOutMin, "INSUFFICIENT_AMOUNT_OUT");

        uint256 feeAmount = (total * feePercent) / 100;
        amountOut = total - feeAmount;
        ERC20(strategyToken).transfer(feeCollector, feeAmount);

        emit LpMinted(total, amountOut, feeAmount);
    }

    function setFeeParameters(address _feeCollector, uint8 _feePercent) external onlyOwner {
        require(feePercent <= 100, "invalid feePercent");
        feeCollector = _feeCollector;
        feePercent = _feePercent;

        emit FeeParametersChanged(_feeCollector, _feePercent);
    }

    function _swapToUnderlying() internal virtual;
}// GPL-3.0-or-later
pragma solidity 0.8.7;


contract MainnetUsdtStargateLPStrategy is BaseStargateLPStrategy {

    ICurvePool public constant STGPOOL = ICurvePool(0x3211C6cBeF1429da3D0d58494938299C92Ad5860);
    ICurveThreePool public constant THREEPOOL = ICurveThreePool(0xbEbc44782C7dB0a1A60Cb6fe97d0b483032FF1C7);
    ERC20 public constant USDC = ERC20(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);
    Tether public constant USDT = Tether(0xdAC17F958D2ee523a2206206994597C13D831ec7);

    constructor(
        address _strategyToken,
        address _bentoBox,
        IStargateRouter _router,
        uint256 _poolId,
        ILPStaking _staking,
        uint256 _pid
    ) BaseStargateLPStrategy(_strategyToken, _bentoBox, _router, _poolId, _staking, _pid) {
        IStargateToken(_staking.stargate()).approve(address(STGPOOL), type(uint256).max);
        USDC.approve(address(THREEPOOL), type(uint256).max);
    }

    function _swapToUnderlying() internal override {

        STGPOOL.exchange(0, 1, stargateToken.balanceOf(address(this)), 0);

        THREEPOOL.exchange(1, 2, USDC.balanceOf(address(this)), 0);
    }
}