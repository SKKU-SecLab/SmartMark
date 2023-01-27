
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

library EnumerableSet {


    struct Set {
        bytes32[] _values;
        mapping(bytes32 => uint256) _indexes;
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

        if (valueIndex != 0) {

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;

            if (lastIndex != toDeleteIndex) {
                bytes32 lastvalue = set._values[lastIndex];

                set._values[toDeleteIndex] = lastvalue;
                set._indexes[lastvalue] = valueIndex; // Replace lastvalue's index to valueIndex
            }

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

        return set._values[index];
    }


    struct Bytes32Set {
        Set _inner;
    }

    function add(Bytes32Set storage set, bytes32 value) internal returns (bool) {

        return _add(set._inner, value);
    }

    function remove(Bytes32Set storage set, bytes32 value) internal returns (bool) {

        return _remove(set._inner, value);
    }

    function contains(Bytes32Set storage set, bytes32 value) internal view returns (bool) {

        return _contains(set._inner, value);
    }

    function length(Bytes32Set storage set) internal view returns (uint256) {

        return _length(set._inner);
    }

    function at(Bytes32Set storage set, uint256 index) internal view returns (bytes32) {

        return _at(set._inner, index);
    }


    struct AddressSet {
        Set _inner;
    }

    function add(AddressSet storage set, address value) internal returns (bool) {

        return _add(set._inner, bytes32(uint256(uint160(value))));
    }

    function remove(AddressSet storage set, address value) internal returns (bool) {

        return _remove(set._inner, bytes32(uint256(uint160(value))));
    }

    function contains(AddressSet storage set, address value) internal view returns (bool) {

        return _contains(set._inner, bytes32(uint256(uint160(value))));
    }

    function length(AddressSet storage set) internal view returns (uint256) {

        return _length(set._inner);
    }

    function at(AddressSet storage set, uint256 index) internal view returns (address) {

        return address(uint160(uint256(_at(set._inner, index))));
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


abstract contract  AutomatedExternalReflector is Context, LockableSwap, Ownable, IAutomatedExternalReflector {
    using Address for address;
    using Address for address payable;
    using SafeMath for uint256;
    using EnumerableSet for EnumerableSet.AddressSet;

    event TransactionRegistered(address indexed sender, address indexed recipient);
    event AirdropDelivered(uint256 numberOfPayouts, uint256 totalAmount, uint256 indexAt);
    event RoundSnapshotTaken(uint256 totalUsersUpdated);

    struct User {
        uint256 tokenBalance;
        uint256 totalPayouts;
        uint256 pendingPayouts;
        bool exists;
        uint256 lastPayoutRound;
    }

    mapping(uint256 => uint256) public poolForRound;

    uint256 public currentRound;
    uint256 internal totalEthDeposits;
    uint256 public currentQueueIndex;
    uint256 internal totalRewardsSent;
    uint256 public totalCirculatingTokens;
    uint256 public totalExcludedTokenHoldings = 0;

    bool public takeSnapshot = true;
    bool public snapshotPending;

    uint256 public maxGas;
    uint256 public minGas;
    uint256 public gasRequirement = 75000;
    uint256 public maxReflectionsPerRound;
    uint256 public timeBetweenRounds;
    uint256 public nextRoundStart;

    bool public reflectionsEnabled = true;

    IUniswapV2Router02 public uniswapV2Router;
    ISupportingExternalReflection public tokenContract;
    EnumerableSet.AddressSet private excludedList;

    EnumerableSet.AddressSet private privateQueue;
    address payable[] internal queue;

    mapping(address => mapping(uint256 => User)) internal dynaHodler;
    mapping(address => bool) public override isExcludedFromReflections;

    receive() external payable {
        totalEthDeposits = totalEthDeposits.add(msg.value);
    }

    fallback() external payable {
        totalEthDeposits = totalEthDeposits.add(msg.value);
    }

    function depositEth() public payable override returns(bool success) {
        totalEthDeposits = totalEthDeposits.add(msg.value);
        success = true;
    }

    function addNewUser(address newUserAddress, uint256 bal) private {
        dynaHodler[newUserAddress][currentRound+1] = User(bal, 0, 0, true, currentRound);
        dynaHodler[newUserAddress][currentRound] = User(bal, 0, 0, true, currentRound);
    }

    function logTransactionEvent(address from, address to) external override returns (bool) {
        require(_msgSender() == _owner || _msgSender() == address(tokenContract), "Only Owner or Token Contract may call this function");
        if(from != address(0)) {
            (bool success, bytes memory data) = address(tokenContract).call(abi.encodeWithSignature("balanceOf(address)",from));
            if(success){
                uint256 bal = abi.decode(data, (uint256));
                logUserTransaction(from, bal, true);
            }
        }
        if(to != address(0)) {
            (bool success, bytes memory data) = address(tokenContract).call(abi.encodeWithSignature("balanceOf(address)",to));
            if(success){
                uint256 bal = abi.decode(data, (uint256));
                logUserTransaction(to, bal, false);
            }
        }

        emit TransactionRegistered(from, to);
        return true;
    }

    function logUserTransaction(address user, uint256 value, bool isSender) private {
        if(!privateQueue.contains(user)){
            privateQueue.add(user);
            queue.push(payable(user));
        }
        if(takeSnapshot) { return; }
        uint256 prevUserBal = dynaHodler[user][currentRound].tokenBalance;

        dynaHodler[user][currentRound+1] = User({
            tokenBalance: value,
            totalPayouts: dynaHodler[user][currentRound].totalPayouts,
            pendingPayouts: dynaHodler[user][currentRound].pendingPayouts,
            exists: true,
            lastPayoutRound: dynaHodler[user][currentRound].lastPayoutRound
        });

        if(isExcludedFromReflections[user]){
            if(isSender){
                totalExcludedTokenHoldings = totalExcludedTokenHoldings.sub(prevUserBal.sub(value));
            } else {
                totalExcludedTokenHoldings = totalExcludedTokenHoldings.add(value.sub(prevUserBal));
            }
        }
    }

    function reflectRewards() external override returns (bool) {
        require(gasleft() > gasRequirement, "More gas is required for this function");
        if(!inSwapAndLiquify)
            return _reflectRewards();
        return false;
    }

    function snapshot() private returns (uint256){
        uint256 stopProcessingAt = currentQueueIndex.add(maxReflectionsPerRound);
        uint256 queueLength = queue.length;
        uint256 startingGas = gasleft();
        uint256 endGas = 0;
        uint256 queueStart = currentQueueIndex;
        uint256 gasLeft = startingGas;
        if(startingGas > maxGas){
            endGas = startingGas.sub(maxGas);
        } else {
            endGas = minGas;
        }
        uint256 minGasIncReturns = minGas.div(2).add(minGas);
        IERC20 controllingToken = IERC20(address(tokenContract));
        uint256 excludedTokensSnapshotted;
        if(currentQueueIndex == 0){
            excludedTokensSnapshotted = 0;
        } else {
            excludedTokensSnapshotted = totalExcludedTokenHoldings;
        }
        while(gasLeft > minGasIncReturns && gasLeft > endGas && currentQueueIndex < stopProcessingAt && currentQueueIndex < queueLength){
            address payable user = queue[currentQueueIndex];
            (bool success, bytes memory data) = address(controllingToken).call(abi.encodeWithSignature("balanceOf(address)",user));
            if(success){
                uint256 bal = abi.decode(data, (uint256));
                dynaHodler[user][currentRound] = User({
                    tokenBalance: bal,
                    totalPayouts: dynaHodler[user][currentRound-1].totalPayouts,
                    pendingPayouts: dynaHodler[user][currentRound-1].pendingPayouts,
                    exists: true,
                    lastPayoutRound: dynaHodler[user][currentRound-1].lastPayoutRound
                });

                dynaHodler[user][currentRound+1] = dynaHodler[user][currentRound];

                if(isExcludedFromReflections[queue[currentQueueIndex]]){
                    excludedTokensSnapshotted = excludedTokensSnapshotted.add(bal);
                }
            }
            currentQueueIndex++;
        }
        emit RoundSnapshotTaken(currentQueueIndex.sub(queueStart));

        rewardInstigator(currentQueueIndex.sub(queueStart));

        if(currentQueueIndex >= queueLength){
            currentQueueIndex = 0;
            snapshotPending = false;
        }
        return excludedTokensSnapshotted;
    }

    function rewardInstigator(uint256 shares) private {
        if(address(this).balance > poolForRound[currentRound].add(1000)){
            uint256 instigatorReward = address(this).balance.sub(poolForRound[currentRound]);

            if(instigatorReward > 1000 && tx.origin != address(uniswapV2Router)){
                instigatorReward = instigatorReward.mul(shares).div(1000);
                payable(address(tx.origin)).call{value: instigatorReward}("");
            }
        }
    }

    function _reflectRewards() private lockTheSwap returns(bool allComplete) {
        allComplete = false;
        if(takeSnapshot && snapshotPending){
            if(currentQueueIndex == 0){ totalExcludedTokenHoldings = 0; }
            uint256 newExcludedTally = snapshot();
            if(newExcludedTally != 0 && newExcludedTally != totalExcludedTokenHoldings)
                totalExcludedTokenHoldings = totalExcludedTokenHoldings.add(newExcludedTally);

            return allComplete;
        }

        if(block.timestamp < nextRoundStart || address(this).balance == 0){
            return allComplete;
        }

        uint256 stopProcessingAt = currentQueueIndex.add(maxReflectionsPerRound);
        uint256 queueLength = queue.length;
        uint256 payeeCount = 0;
        uint256 payeeAmount = 0;
        uint256 startingGas = gasleft();
        uint256 endGas = 0;
        uint256 gasLeft = startingGas;
        if(startingGas > maxGas){
            endGas = startingGas.sub(maxGas);
        } else {
            endGas = minGas;
        }
        uint256 minGasIncReturns = minGas.div(2).add(minGas);

        while(gasLeft > minGasIncReturns && gasLeft > endGas && currentQueueIndex < stopProcessingAt && currentQueueIndex < queueLength){
            address payable hodler = payable(queue[currentQueueIndex]);
            payeeAmount = payeeAmount.add(_sendEthTo(hodler));
            payeeCount++;
            currentQueueIndex++;
            gasLeft = gasleft();
        }

        rewardInstigator(payeeCount);

        if(currentQueueIndex >= queueLength || poolForRound[currentRound] == 0){
            currentQueueIndex = 0;
            allComplete = true;
            nextRoundStart = block.timestamp.add(timeBetweenRounds);
            currentRound++;
            poolForRound[currentRound] = address(this).balance;
            if(takeSnapshot){
                snapshotPending = true;
            }
        }
        totalRewardsSent = totalRewardsSent.add(payeeAmount);
        emit AirdropDelivered(payeeCount, payeeAmount, currentQueueIndex);
    }

    function enableSnapshotting(bool enable) external onlyOwner {
        takeSnapshot = enable;
    }

    function _sendEthTo(address payable hodler) private returns(uint256 reward) {
        if(!dynaHodler[hodler][currentRound].exists || dynaHodler[hodler][currentRound].tokenBalance == 0) { return 0; }
        if(dynaHodler[hodler][currentRound].lastPayoutRound == currentRound || isExcludedFromReflections[hodler]){ return 0; }

        reward = reward.add(simplePayoutCalc(hodler));
        if (reward > 1000) {
            (bool success, ) = hodler.call{value: reward}("");
            if (success){
                dynaHodler[hodler][currentRound].totalPayouts = dynaHodler[hodler][currentRound].totalPayouts.add(reward);
                dynaHodler[hodler][currentRound+1].totalPayouts = dynaHodler[hodler][currentRound].totalPayouts;
                dynaHodler[hodler][currentRound].lastPayoutRound = currentRound;
                dynaHodler[hodler][currentRound+1].lastPayoutRound = currentRound;
            } else { reward = 0; }
        }
        return reward;
    }

    function simplePayoutCalc(address hodler) private view returns (uint256) {
        return poolForRound[currentRound].mul(dynaHodler[hodler][currentRound].tokenBalance).div(totalCirculatingTokens.sub(totalExcludedTokenHoldings));
    }

    function getRemainingPayeeCount() external view override returns(uint256 count) {
        count = queue.length.sub(currentQueueIndex);
    }

    function enableReflections(bool enable) public override onlyOwner {
        require(enable != reflectionsEnabled, "Reflections already set to this value");
        reflectionsEnabled = enable;
    }

    function _excludeFromReflections(address target, bool exclude) internal {
        isExcludedFromReflections[target] = exclude;
        if(!privateQueue.contains(target)){
            privateQueue.add(target);
            queue.push(payable(target));
        }
        if(exclude){
            excludedList.add(target);
        } else {
            excludedList.remove(target);
        }
    }

    function excludeFromReflections(address target, bool exclude) public override onlyOwner {
        _excludeFromReflections(target, exclude);
    }

    function updateTokenAddress(address token, bool andPair) public onlyOwner {
        tokenContract = ISupportingExternalReflection(token);
        _excludeFromReflections(token, true);
        if(andPair){
            address pair = address(IUniswapV2Factory(uniswapV2Router.factory()).getPair(token, uniswapV2Router.WETH()));
            _excludeFromReflections(pair, true);
        }
        totalCirculatingTokens = IERC20(token).totalSupply();
    }

    function updateTotalSupply(uint256 newTotal) public override {
        require(_msgSender() == _owner || _msgSender() == address(tokenContract), "Only Owner or Token Contract may call this function");
        _updateTotalSupply(newTotal);
    }

    function _updateTotalSupply(uint256 newTotal) private {
        totalCirculatingTokens = newTotal;
    }

    function updateGasRange(uint256 _minGas, uint256 _maxGas) public onlyOwner {
        minGas = _minGas;
        maxGas = _maxGas;
    }

    function updateMaxPayoutsPerTransaction(uint256 roundLimit) external onlyOwner {
        require(roundLimit > 0, "Payout cap must be greater than one");
        maxReflectionsPerRound = roundLimit;
    }

    function updateDelayBetweenRounds(uint256 delayInMinutes) external onlyOwner {
        timeBetweenRounds = delayInMinutes * 1 minutes;
    }

    function enrollAddress(address hodlerAddress) external {
        if(!privateQueue.contains(hodlerAddress)){
            privateQueue.add(hodlerAddress);
            queue.push(payable(hodlerAddress));
        }
    }

    function enrollMultiple(address[] memory addressList) external {
        for(uint256 i = 0; i < addressList.length; i++){
            if(!privateQueue.contains(addressList[i])){
                privateQueue.add(addressList[i]);
                queue.push(payable(addressList[i]));
            }
        }
    }

    function ethSentToUserSoFar(address userAddress) external view returns(uint256) {
        return dynaHodler[userAddress][currentRound].totalPayouts.div(1 ether);
    }

    function totalEthAirdropped() external view returns(uint256){
        return totalRewardsSent.div(1 ether);
    }

    function amIEnrolledForETHDrops() external view returns(bool){
        return isAddressEnrolled(_msgSender());
    }

    function isAddressEnrolled(address ad) public view returns(bool){
        return privateQueue.contains(ad);
    }

    function collectShare() external lockTheSwap {
        _sendEthTo(payable(_msgSender()));
    }
}// MIT
pragma solidity ^0.8.0;




contract DynaAutoEthDistributorV1 is AutomatedExternalReflector {


    event UpdateRouter(address indexed newAddress, address indexed oldAddress);

    address public deadAddress = 0x000000000000000000000000000000000000dEaD;

    constructor(address tokenAddress) payable {
        _owner = msg.sender;
        currentRound = 1;
        totalEthDeposits = address(this).balance;
        currentQueueIndex = 0;
        totalRewardsSent = 0;
        totalExcludedTokenHoldings = 0;
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D); // Uniswap V2 Routers (Mainnet and Ropsten)
        uniswapV2Router = _uniswapV2Router;
        maxGas = 500000;
        minGas = 70000;
        maxReflectionsPerRound = 100;
        timeBetweenRounds = 1 seconds;
        nextRoundStart = block.timestamp + 1 seconds;

        reflectionsEnabled = true;
        updateTokenAddress(tokenAddress, true);
        _excludeFromReflections(address(_uniswapV2Router), true);
        _excludeFromReflections(address(this), true);
        _excludeFromReflections(deadAddress, true);
        _excludeFromReflections(address(0), true);

        totalCirculatingTokens = 1 * 10 ** 12 * 10 ** 18;
    }

    function updateRouter(address newAddress, bool andPair) external onlyOwner (){


        emit UpdateRouter(newAddress, address(uniswapV2Router));

        uniswapV2Router = IUniswapV2Router02(newAddress);
        _excludeFromReflections(newAddress, true);

        if(andPair){
            address uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).getPair(address(tokenContract), uniswapV2Router.WETH());
            _excludeFromReflections(uniswapV2Pair, true);
        }
    }
}