



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

    function _values(Set storage set) private view returns (bytes32[] memory) {

        return set._values;
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

    function values(Bytes32Set storage set) internal view returns (bytes32[] memory) {

        return _values(set._inner);
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

    function values(AddressSet storage set) internal view returns (address[] memory) {

        bytes32[] memory store = _values(set._inner);
        address[] memory result;

        assembly {
            result := store
        }

        return result;
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

    function values(UintSet storage set) internal view returns (uint256[] memory) {

        bytes32[] memory store = _values(set._inner);
        uint256[] memory result;

        assembly {
            result := store
        }

        return result;
    }
}




pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}




pragma solidity ^0.8.0;


abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _transferOwnership(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}




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
}




pragma solidity >=0.6.0;

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
}



pragma solidity ^0.8.7;





interface IGeneralPool {

    enum SwapKind { GIVEN_IN, GIVEN_OUT }
    struct SwapRequest {
        SwapKind kind;
        IERC20 tokenIn;
        IERC20 tokenOut;
        uint256 amount;
        bytes32 poolId;
        uint256 lastChangeBlock;
        address from;
        address to;
        bytes userData;
    }

    function onJoinPool(
        bytes32 poolId,
        address sender,
        address recipient,
        uint256[] memory balances,
        uint256 lastChangeBlock,
        uint256 protocolSwapFeePercentage,
        bytes memory userData
    ) external returns (uint256[] memory amountsIn, uint256[] memory dueProtocolFeeAmounts);


    function onExitPool(
        bytes32 poolId,
        address sender,
        address recipient,
        uint256[] memory balances,
        uint256 lastChangeBlock,
        uint256 protocolSwapFeePercentage,
        bytes memory userData
    ) external returns (uint256[] memory amountsOut, uint256[] memory dueProtocolFeeAmounts);


    function getPoolId() external view returns (bytes32);


    function onSwap(
        SwapRequest memory swapRequest,
        uint256[] memory balances,
        uint256 indexIn,
        uint256 indexOut
    ) external returns (uint256 amount);

}

interface LBPFactory {

    function create(
        string memory name,
        string memory symbol,
        address[] memory tokens,
        uint256[] memory weights,
        uint256 swapFeePercentage,
        address owner,
        bool swapEnabledOnStart
    ) external returns (address);

}

interface Vault {

    struct JoinPoolRequest {
        address[] assets;
        uint256[] maxAmountsIn;
        bytes userData;
        bool fromInternalBalance;
    }

    struct ExitPoolRequest {
        address[] assets;
        uint256[] minAmountsOut;
        bytes userData;
        bool toInternalBalance;
    }

    function joinPool(
        bytes32 poolId,
        address sender,
        address recipient,
        JoinPoolRequest memory request
    ) external;


    function exitPool(
        bytes32 poolId,
        address sender,
        address recipient,
        ExitPoolRequest memory request
    ) external;


    function getPoolTokens(bytes32 poolId)
        external
        view
        returns (
            address[] memory tokens,
            uint256[] memory balances,
            uint256 lastChangeBlock
        );

}

interface LBP {

    function updateWeightsGradually(
        uint256 startTime,
        uint256 endTime,
        uint256[] memory endWeights
    ) external;


    function setSwapEnabled(bool swapEnabled) external;


    function getPoolId() external returns (bytes32 poolID);

}

contract BounceProxy is Ownable {

    using EnumerableSet for EnumerableSet.AddressSet;

    struct PoolData {
        address owner;
        bool isCorrectOrder;
        uint256 fundTokenInputAmount;
    }

    mapping(address => PoolData) private _poolData;
    EnumerableSet.AddressSet private _pools;

    address public constant VAULT = address(0xBA12222222228d8Ba445958a75a0704d566BF2C8);
    address public immutable _LBPFactoryAddress;
    uint256 public immutable _feeBPS;
    address public _feeRecipient;

    constructor(
        uint256 feeBPS,
        address feeRecipient,
        address LBPFactoryAddress
    ) {
        _feeBPS = feeBPS;
        _feeRecipient = feeRecipient;
        _LBPFactoryAddress = LBPFactoryAddress;
    }

    event PoolCreated(
        address indexed pool,
        bytes32 poolId,
        string  name,
        string  symbol,
        address[]  tokens,
        uint256[]  weights,
        bool isCorrectOrder,
        uint256 swapFeePercentage,
        address owner,
        bool swapEnabledOnStart
    );

    event JoinedPool(address indexed pool, address[] tokens, uint256[] amounts, bytes userData);

    event GradualWeightUpdateScheduled(address indexed pool, uint256 startTime, uint256 endTime, uint256[] endWeights);

    event SwapEnabledSet(address indexed pool, bool swapEnabled);

    event TransferedPoolOwnership(address indexed pool, address previousOwner, address newOwner);

    event ExitedPool(address indexed pool, address[] tokens, uint256[] minAmountsOut, bytes userData);

    event TransferedFee(address indexed pool, address token, address feeRecipient, uint256 feeAmount);

    event TransferedToken(address indexed pool, address token, address to, uint256 amount);

    event ChangedFeeRecipient(address previousRecipient, address newRecipient);

    event Skimmed(address token, address to, uint256 balance);

    modifier onlyPoolOwner(address pool) {

        require(msg.sender == _poolData[pool].owner, "!owner");
        _;
    }

    function isPool(address pool) external view returns (bool valid) {

        return _pools.contains(pool);
    }

    function poolCount() external view returns (uint256 count) {

        return _pools.length();
    }

    function getPoolAt(uint256 index) external view returns (address pool) {

        return _pools.at(index);
    }

    function getPools() external view returns (address[] memory pools) {

        return _pools.values();
    }

    function getPoolData(address pool) external view returns (PoolData memory poolData) {

        return _poolData[pool];
    }

    function getBPTTokenBalance(address pool) external view returns (uint256 bptBalance) {

        return IERC20(pool).balanceOf(address(this));
    }

    struct PoolConfig {
        string name;
        string symbol;
        address[] tokens;
        uint256[] amounts;
        uint256[] weights;
        uint256[] endWeights;
        bool isCorrectOrder;
        uint256 swapFeePercentage;
        bytes userData;
        uint256 startTime;
        uint256 endTime;
    }

    function createAuction(PoolConfig memory poolConfig) external returns (address) {

        require(poolConfig.tokens.length == 2, "only two tokens");
        TransferHelper.safeTransferFrom(poolConfig.tokens[0], msg.sender, address(this), poolConfig.amounts[0]);
        TransferHelper.safeTransferFrom(poolConfig.tokens[1], msg.sender, address(this), poolConfig.amounts[1]);
        TransferHelper.safeApprove(poolConfig.tokens[0], VAULT, poolConfig.amounts[0]);
        TransferHelper.safeApprove(poolConfig.tokens[1], VAULT, poolConfig.amounts[1]);

        address pool = LBPFactory(_LBPFactoryAddress).create(
            poolConfig.name,
            poolConfig.symbol,
            poolConfig.tokens,
            poolConfig.weights,
            poolConfig.swapFeePercentage,
            address(this), // owner set to this proxy
            false // swaps disabled on start
        );

        bytes32 poolId = LBP(pool).getPoolId();
        emit PoolCreated(
            pool,
            poolId,
            poolConfig.name,
            poolConfig.symbol,
            poolConfig.tokens,
            poolConfig.weights,
            poolConfig.isCorrectOrder,
            poolConfig.swapFeePercentage,
            address(this),
            false    
        );

        _poolData[pool] = PoolData(
            msg.sender,
            poolConfig.isCorrectOrder,
            poolConfig.amounts[poolConfig.isCorrectOrder ? 0 : 1]
        );
        require(_pools.add(pool), "exists already");

        Vault(VAULT).joinPool(
            poolId,
            address(this), // sender
            address(this), // recipient
            Vault.JoinPoolRequest(poolConfig.tokens, poolConfig.amounts, poolConfig.userData, false)
        );
        emit JoinedPool(pool, poolConfig.tokens, poolConfig.amounts, poolConfig.userData);

        LBP(pool).updateWeightsGradually(poolConfig.startTime, poolConfig.endTime, poolConfig.endWeights);
        emit GradualWeightUpdateScheduled(pool, poolConfig.startTime, poolConfig.endTime, poolConfig.endWeights);

        return pool;
    }

    function setSwapEnabled(address pool, bool swapEnabled) external onlyPoolOwner(pool) {

        LBP(pool).setSwapEnabled(swapEnabled);
        emit SwapEnabledSet(pool, swapEnabled);
    }

    function transferPoolOwnership(address pool, address newOwner) external onlyPoolOwner(pool) {

        address previousOwner = _poolData[pool].owner;
        _poolData[pool].owner = newOwner;
        emit TransferedPoolOwnership(pool, previousOwner, newOwner);
    }

    enum ExitKind {
        EXACT_BPT_IN_FOR_ONE_TOKEN_OUT,
        EXACT_BPT_IN_FOR_TOKENS_OUT,
        BPT_IN_FOR_EXACT_TOKENS_OUT
    }

    function exitPool(address pool, uint256[] calldata minAmountsOut, uint256 maxBPTTokenOut) external onlyPoolOwner(pool) {

        bytes32 poolId = LBP(pool).getPoolId();
        (address[] memory poolTokens, , ) = Vault(VAULT).getPoolTokens(poolId);
        require(poolTokens.length == minAmountsOut.length, "invalid input length");
        PoolData memory poolData = _poolData[pool];

        uint256 bptToBurn;
        uint256 bptBalance = IERC20(pool).balanceOf(address(this));
        require(maxBPTTokenOut <= bptBalance, "Not enough BPT token amount");
        require(bptBalance > 0, "invalid pool");
        if (maxBPTTokenOut == 0 ) {
            bptToBurn = bptBalance;
        } else {
            bptToBurn = maxBPTTokenOut;
        }

        bytes memory userData = abi.encode(ExitKind.EXACT_BPT_IN_FOR_TOKENS_OUT, bptToBurn);
        Vault.ExitPoolRequest memory exitRequest = Vault.ExitPoolRequest(poolTokens, minAmountsOut, userData, false);

        Vault(VAULT).exitPool(poolId, address(this), payable(address(this)), exitRequest);
        emit ExitedPool(pool, poolTokens, minAmountsOut, userData);

        address fundToken = poolTokens[poolData.isCorrectOrder ? 0 : 1];
        uint256 fundTokenBalance = IERC20(fundToken).balanceOf(address(this));
        if (fundTokenBalance > poolData.fundTokenInputAmount) {
            uint256 feeAmount = ((fundTokenBalance - poolData.fundTokenInputAmount) * _feeBPS) / 10_000;
            TransferHelper.safeTransfer(fundToken, _feeRecipient, feeAmount);
            emit TransferedFee(pool, fundToken, _feeRecipient, feeAmount);
        }

        uint256 firstTokenBalance = IERC20(poolTokens[0]).balanceOf(address(this));
        TransferHelper.safeTransfer(
            poolTokens[0],
            msg.sender,
            firstTokenBalance
        );
        emit TransferedToken(pool, poolTokens[0], msg.sender, firstTokenBalance);

        uint256 secondTokenBalance = IERC20(poolTokens[1]).balanceOf(address(this));
        TransferHelper.safeTransfer(
            poolTokens[1],
            msg.sender,
            secondTokenBalance
        );
        emit TransferedToken(pool, poolTokens[1], msg.sender, secondTokenBalance);
    }

    function changeFeeRecipient(address newRecipient) external onlyOwner {

        address previousFeeReciepient = _feeRecipient;
        _feeRecipient = newRecipient;
        emit ChangedFeeRecipient(previousFeeReciepient, newRecipient);
    }

    function skim(address token, address recipient) external onlyOwner {

        require(!_pools.contains(token), "can't skim LBP token");
        uint256 balance = IERC20(token).balanceOf(address(this));
        TransferHelper.safeTransfer(token, recipient, balance);
        emit Skimmed(token, recipient, balance);
    }
}