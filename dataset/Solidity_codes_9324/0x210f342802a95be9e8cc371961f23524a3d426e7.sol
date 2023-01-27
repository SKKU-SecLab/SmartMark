

pragma solidity 0.6.12;

pragma experimental ABIEncoderV2;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

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
}

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

        (bool success, bytes memory returndata) = target.call{ value : weiValue}(data);
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
}

library SafeERC20 {

    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint256 value) internal {

        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {


        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

interface IBPool is IERC20 {

    function version() external view returns(uint);

    function swapExactAmountIn(address, uint, address, uint, uint) external returns (uint, uint);


    function swapExactAmountOut(address, uint, address, uint, uint) external returns (uint, uint);


    function calcInGivenOut(uint, uint, uint, uint, uint, uint) external pure returns (uint);


    function calcOutGivenIn(uint, uint, uint, uint, uint, uint) external pure returns (uint);


    function getDenormalizedWeight(address) external view returns (uint);


    function swapFee() external view returns (uint);


    function setSwapFee(uint _swapFee) external;


    function bind(address token, uint balance, uint denorm) external;


    function rebind(address token, uint balance, uint denorm) external;


    function finalize(
        uint _swapFee,
        uint _initPoolSupply,
        address[] calldata _bindTokens,
        uint[] calldata _bindDenorms
    ) external;


    function setPublicSwap(bool _publicSwap) external;

    function setController(address _controller) external;

    function setExchangeProxy(address _exchangeProxy) external;

    function getFinalTokens() external view returns (address[] memory tokens);



    function getTotalDenormalizedWeight() external view returns (uint);


    function getBalance(address token) external view returns (uint);



    function joinPool(uint poolAmountOut, uint[] calldata maxAmountsIn) external;

    function joinPoolFor(address account, uint rewardAmountOut, uint[] calldata maxAmountsIn) external;

    function joinswapPoolAmountOut(address tokenIn, uint poolAmountOut, uint maxAmountIn) external returns (uint tokenAmountIn);


    function exitPool(uint poolAmountIn, uint[] calldata minAmountsOut) external;

    function exitswapPoolAmountIn(address tokenOut, uint poolAmountIn, uint minAmountOut) external returns (uint tokenAmountOut);

    function exitswapExternAmountOut(address tokenOut, uint tokenAmountOut, uint maxPoolAmountIn) external returns (uint poolAmountIn);

    function joinswapExternAmountIn(
        address tokenIn,
        uint tokenAmountIn,
        uint minPoolAmountOut
    ) external returns (uint poolAmountOut);

    function finalizeRewardFundInfo(address _rewardFund, uint _unstakingFrozenTime) external;

    function addRewardPool(IERC20 _rewardToken, uint256 _startBlock, uint256 _endRewardBlock, uint256 _rewardPerBlock,
        uint256 _lockRewardPercent, uint256 _startVestingBlock, uint256 _endVestingBlock) external;

}

interface IFreeFromUpTo {

    function freeFromUpTo(address from, uint256 value) external returns (uint256 freed);

}

interface IBFactory {

    function newBPool() external returns (IBPool);

}

interface IValueLiquidRegistry {

    function getBestPoolsWithLimit(address, address, uint) external view returns (address[] memory);

}

interface IWETH {

    function deposit() external payable;

    function allowance(address owner, address spender) external view returns (uint256);

    function transfer(address to, uint value) external returns (bool);

    function withdraw(uint) external;

    function balanceOf(address account) external view returns (uint256);

}

contract FaaSRewardFund {

    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    event NewAdmin(address indexed newAdmin);
    event NewPendingAdmin(address indexed newPendingAdmin);
    event NewDelay(uint indexed newDelay);
    event CancelTransaction(bytes32 indexed txHash, address indexed target, uint value, string signature, bytes data, uint eta);
    event ExecuteTransaction(bytes32 indexed txHash, address indexed target, uint value, string signature, bytes data, uint eta);
    event QueueTransaction(bytes32 indexed txHash, address indexed target, uint value, string signature, bytes data, uint eta);

    uint public constant GRACE_PERIOD = 14 days;
    uint public constant MINIMUM_DELAY = 1 days;
    uint public constant MAXIMUM_DELAY = 30 days;
    bool private _initialized;
    address public faasPool;
    address public admin;
    address public pendingAdmin;
    uint public delay;
    bool public admin_initialized;
    mapping(bytes32 => bool) public queuedTransactions;

    constructor() public {
        admin_initialized = false;
        _initialized = false;
    }

    function initialized(address admin_, uint delay_, address _faasPool) public {

        require(_initialized == false, "Timelock::constructor: Delay must exceed minimum delay.");
        require(delay_ >= MINIMUM_DELAY, "Timelock::constructor: Delay must exceed minimum delay.");
        require(delay_ <= MAXIMUM_DELAY, "Timelock::constructor: Delay must not exceed maximum delay.");
        admin = admin_;
        faasPool = _faasPool;
        delay = delay_;
        _initialized = true;
    }

    receive() external payable {}

    function setDelay(uint delay_) public {

        require(msg.sender == address(this), "Timelock::setDelay: Call must come from Timelock.");
        require(delay_ >= MINIMUM_DELAY, "Timelock::setDelay: Delay must exceed minimum delay.");
        require(delay_ <= MAXIMUM_DELAY, "Timelock::setDelay: Delay must not exceed maximum delay.");
        delay = delay_;

        emit NewDelay(delay);
    }

    function acceptAdmin() public {

        require(msg.sender == pendingAdmin, "Timelock::acceptAdmin: Call must come from pendingAdmin.");
        admin = msg.sender;
        pendingAdmin = address(0);

        emit NewAdmin(admin);
    }

    function setPendingAdmin(address pendingAdmin_) public {

        if (admin_initialized) {
            require(msg.sender == address(this), "Timelock::setPendingAdmin: Call must come from Timelock.");
        } else {
            require(msg.sender == admin, "Timelock::setPendingAdmin: First call must come from admin.");
            admin_initialized = true;
        }
        pendingAdmin = pendingAdmin_;

        emit NewPendingAdmin(pendingAdmin);
    }

    function queueTransaction(address target, uint value, string memory signature, bytes memory data, uint eta) public returns (bytes32) {

        require(msg.sender == admin, "Timelock::queueTransaction: Call must come from admin.");
        require(eta >= getBlockTimestamp().add(delay), "Timelock::queueTransaction: Estimated execution block must satisfy delay.");

        bytes32 txHash = keccak256(abi.encode(target, value, signature, data, eta));
        queuedTransactions[txHash] = true;

        emit QueueTransaction(txHash, target, value, signature, data, eta);
        return txHash;
    }

    function cancelTransaction(address target, uint value, string memory signature, bytes memory data, uint eta) public {

        require(msg.sender == admin, "Timelock::cancelTransaction: Call must come from admin.");

        bytes32 txHash = keccak256(abi.encode(target, value, signature, data, eta));
        queuedTransactions[txHash] = false;

        emit CancelTransaction(txHash, target, value, signature, data, eta);
    }

    function executeTransaction(address target, uint value, string memory signature, bytes memory data, uint eta) public payable returns (bytes memory) {

        require(msg.sender == admin, "Timelock::executeTransaction: Call must come from admin.");

        bytes32 txHash = keccak256(abi.encode(target, value, signature, data, eta));
        require(queuedTransactions[txHash], "Timelock::executeTransaction: Transaction hasn't been queued.");
        require(getBlockTimestamp() >= eta, "Timelock::executeTransaction: Transaction hasn't surpassed time lock.");
        require(getBlockTimestamp() <= eta.add(GRACE_PERIOD), "Timelock::executeTransaction: Transaction is stale.");

        queuedTransactions[txHash] = false;

        bytes memory callData;

        if (bytes(signature).length == 0) {
            callData = data;
        } else {
            callData = abi.encodePacked(bytes4(keccak256(bytes(signature))), data);
        }

        (bool success, bytes memory returnData) = target.call{value : value}(callData);
        require(success, "Timelock::executeTransaction: Transaction execution reverted.");

        emit ExecuteTransaction(txHash, target, value, signature, data, eta);

        return returnData;
    }

    function getBlockTimestamp() internal view returns (uint) {

        return block.timestamp;
    }


    function balance(IERC20 _token) public view returns (uint256) {

        return _token.balanceOf(address(this));
    }

    function safeTransfer(IERC20 _token, address _to, uint256 _value) external {

        require(msg.sender == faasPool, "!faasPool");
        uint256 _tokenBal = balance(_token);
        _token.safeTransfer(_to, _tokenBal > _value ? _value : _tokenBal);
    }

    function governanceRecoverUnsupported(IERC20 _token, uint _amount, address _to) external {

        require(msg.sender == address(this), "!timelock");
        if ((address(_token) == address(0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE))) {
            (bool xfer,) = _to.call{value : _amount}("");
            require(xfer, "ERR_ETH_FAILED");
        } else {
            _token.safeTransfer(_to, _amount);
        }
    }
}

contract FaasPoolProxy {

    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    using Address for address;

    IFreeFromUpTo public constant chi = IFreeFromUpTo(0x0000000000004946c0e9F43F4Dee607b0eF1fA1c);

    modifier discountCHI(uint8 flag) {

        if ((flag & 0x1) == 0) {
            _;
        } else {
            uint256 gasStart = gasleft();
            _;
            uint256 gasSpent = 21000 + gasStart - gasleft() + 16 * msg.data.length;
            chi.freeFromUpTo(msg.sender, (gasSpent + 14154) / 41130);
        }
    }

    IWETH weth;
    address private constant ETH_ADDRESS = address(0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE);
    address public governance;
    address public exchangeProxy;

    constructor(address _weth,address _exchangeProxy) public {
        weth = IWETH(_weth);
        governance = tx.origin;
        exchangeProxy = _exchangeProxy;
    }
    struct PoolRewardInfo {
        IERC20 rewardToken;
        uint256 startBlock;
        uint256 endRewardBlock;
        uint256 rewardPerBlock;
        uint256 lockRewardPercent;
        uint256 startVestingBlock;
        uint256 endVestingBlock;
        uint unstakingFrozenTime;
        uint rewardFundAmount;
    }

    struct PoolInfo {
        IBFactory factory;
        address[] tokens;
        uint[] balances;
        uint[] denorms;
        uint swapFee;
        uint initPoolSupply;
    }

    receive() external payable {}

    function setExchangeProxy(address _exchangeProxy) external {

        require(msg.sender == governance, "!governance");
        exchangeProxy = _exchangeProxy;
    }
    function createInternal(
        PoolInfo calldata poolInfo

    ) internal returns (IBPool pool) {

        address[] memory tokens = poolInfo.tokens;
        require(tokens.length == poolInfo.balances.length, "ERR_LENGTH_MISMATCH");
        require(tokens.length == poolInfo.denorms.length, "ERR_LENGTH_MISMATCH");
        pool = poolInfo.factory.newBPool();
        bool containsETH = false;
        for (uint i = 0; i < tokens.length; i++) {
            if (transferFromAllTo(tokens[i], poolInfo.balances[i], address(pool))) {
                containsETH = true;
                tokens[i] = address(weth);
            }
        }
        require(msg.value == 0 || containsETH, "!invalid payable");
        pool.finalize(poolInfo.swapFee, poolInfo.initPoolSupply, tokens, poolInfo.denorms);

    }

    function createFaaSReward(
        PoolInfo calldata poolInfo,
        PoolRewardInfo calldata poolRewardInfo,
        uint8 flag
    ) payable external discountCHI(flag) returns (IBPool pool) {

        pool = createInternal(poolInfo);
        {
            FaaSRewardFund faasRewardFund = new FaaSRewardFund();
            pool.finalizeRewardFundInfo(address(faasRewardFund), poolRewardInfo.unstakingFrozenTime);
            pool.addRewardPool(
                poolRewardInfo.rewardToken,
                poolRewardInfo.startBlock,
                poolRewardInfo.endRewardBlock,
                poolRewardInfo.rewardPerBlock,
                poolRewardInfo.lockRewardPercent,
                poolRewardInfo.startVestingBlock,
                poolRewardInfo.endVestingBlock);
            transferFromAllTo(address(poolRewardInfo.rewardToken), poolRewardInfo.rewardFundAmount, address(faasRewardFund));
            faasRewardFund.initialized(msg.sender, poolRewardInfo.unstakingFrozenTime + 1 days, address(pool));
            pool.setExchangeProxy(exchangeProxy);
            pool.setController(address(faasRewardFund));
        }
        uint lpAmount = pool.balanceOf(address(this));
        if (lpAmount > 0) {
            IERC20(pool).safeTransfer(msg.sender, lpAmount);
        }
    }

    function isETH(IERC20 token) internal pure returns (bool) {

        return (address(token) == ETH_ADDRESS);
    }

    function transferFromAllTo(address token, uint amount, address to) internal returns (bool containsETH) {

        if (isETH(IERC20(token))) {
            require(amount == msg.value, "!invalid amount");
            weth.deposit{value : amount}();
            weth.transfer(to, amount);
            containsETH = true;
        } else {
            IERC20(token).safeTransferFrom(msg.sender, to, amount);
        }
        return containsETH;
    }

    function transferFromAllAndApprove(address token, uint amount, address spender) internal returns (bool containsETH) {

        if (isETH(IERC20(token))) {
            require(amount == msg.value, "!invalid amount");
            weth.deposit{value : amount}();
            if (weth.allowance(address(this), spender) > 0) {
                IERC20(address(weth)).safeApprove(address(spender), 0);
            }
            IERC20(address(weth)).safeApprove(spender, amount);
            containsETH = true;
        } else {
            IERC20(token).safeTransferFrom(msg.sender, address(this), amount);
            if (IERC20(token).allowance(address(this), spender) > 0) {
                IERC20(token).safeApprove(spender, 0);
            }
            IERC20(token).safeApprove(spender, amount);
        }
        return containsETH;
    }
}