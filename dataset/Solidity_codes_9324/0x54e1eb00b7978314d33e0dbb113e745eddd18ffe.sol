
pragma solidity 0.7.0;



interface Erc20Token {


    function transfer(address _to, uint256 _value) external returns (bool success);


    function approve(address _spender, uint256 _value) external returns (bool success);


    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    ) external returns (bool success);


    function balanceOf(address _owner) external view returns (uint256);


    function decimals() external pure returns (uint8);


    function allowance(address _owner, address _spender) external view returns (uint256);


}

abstract contract AssetAdapter {

    uint16 public immutable ASSET_TYPE;  // solhint-disable-line var-name-mixedcase

    constructor(
        uint16 assetType
    ) {
        ASSET_TYPE = assetType;
    }

    function rawSendAsset(
        bytes memory assetData,
        uint256 _amount,
        address payable _to
    ) internal virtual returns (bool success);

    function rawLockAsset(
        uint256 amount,
        address payable _from
    ) internal returns (bool success) {
        return RampInstantPoolInterface(_from).sendFundsToSwap(amount);
    }

    function getAmount(bytes memory assetData) internal virtual pure returns (uint256);

    modifier checkAssetTypeAndData(bytes memory assetData, address _pool) {
        uint16 assetType;
        assembly {
            assetType := and(
                mload(add(assetData, 2)),
                0xffff
            )
        }
        require(assetType == ASSET_TYPE, "iat");  // "invalid asset type"
        checkAssetData(assetData, _pool);
        _;
    }

    function checkAssetData(bytes memory assetData, address _pool) internal virtual view;

}

abstract contract RampInstantPoolInterface {

    uint16 public ASSET_TYPE;  // solhint-disable-line var-name-mixedcase

    function sendFundsToSwap(uint256 _amount)
        public virtual /*onlyActive onlySwapsContract isWithinLimits*/ returns(bool success);

}

abstract contract RampInstantTokenPoolInterface is RampInstantPoolInterface {

    address public token;

}

abstract contract Ownable {

    address public owner;

    event OwnerChanged(address oldOwner, address newOwner);

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "ooc");  // "only the owner can call this"
        _;
    }

    function changeOwner(address _newOwner) external onlyOwner {
        owner = _newOwner;
        emit OwnerChanged(msg.sender, _newOwner);
    }

}

abstract contract WithStatus is Ownable {

    enum Status {
        STOPPED,
        RETURN_ONLY,
        FINALIZE_ONLY,
        ACTIVE
    }

    event StatusChanged(Status oldStatus, Status newStatus);

    Status public status = Status.ACTIVE;

    function setStatus(Status _status) external onlyOwner {
        emit StatusChanged(status, _status);
        status = _status;
    }

    modifier statusAtLeast(Status _status) {
        require(status >= _status, "ics");  // "invalid contract status"
        _;
    }

}


abstract contract WithOracles is Ownable {

    mapping (address => bool) internal oracles;

    constructor() {
        oracles[msg.sender] = true;
    }

    function approveOracle(address _oracle) external onlyOwner {
        oracles[_oracle] = true;
    }

    function revokeOracle(address _oracle) external onlyOwner {
        oracles[_oracle] = false;
    }

    modifier isOracle(address _oracle) {
        require(oracles[_oracle], "ioa");  // invalid oracle address"
        _;
    }

    modifier onlyOracleOrPool(address _pool, address _oracle) {
        require(
            msg.sender == _pool || (msg.sender == _oracle && oracles[msg.sender]),
            "oop"  // "only the oracle or the pool can call this"
        );
        _;
    }

}


abstract contract WithSwapsCreators is Ownable {

    mapping (address => bool) internal creators;

    constructor() {
        creators[msg.sender] = true;
    }

    function approveSwapCreator(address _creator) external onlyOwner {
        creators[_creator] = true;
    }

    function revokeSwapCreator(address _creator) external onlyOwner {
        creators[_creator] = false;
    }

    modifier onlySwapCreator() {
        require(creators[msg.sender], "osc");  // "only the swap creator can call this"
        _;
    }

}

abstract contract AssetAdapterWithFees is Ownable, AssetAdapter {

    function accumulateFee(bytes memory assetData) internal virtual;

    function withdrawFees(
        bytes calldata assetData,
        address payable _to
    ) external virtual /*onlyOwner*/ returns (bool success);

    function getFee(bytes memory assetData) internal virtual pure returns (uint256);

    function getAmountWithFee(bytes memory assetData) internal pure returns (uint256) {
        return getAmount(assetData) + getFee(assetData);
    }

    function lockAssetWithFee(
        bytes memory assetData,
        address payable _from
    ) internal returns (bool success) {
        return rawLockAsset(getAmountWithFee(assetData), _from);
    }

    function sendAssetWithFee(
        bytes memory assetData,
        address payable _to
    ) internal returns (bool success) {
        return rawSendAsset(assetData, getAmountWithFee(assetData), _to);
    }

    function sendAssetKeepingFee(
        bytes memory assetData,
        address payable _to
    ) internal returns (bool success) {
        bool result = rawSendAsset(assetData, getAmount(assetData), _to);
        if (result) accumulateFee(assetData);
        return result;
    }

    function getAccumulatedFees(address _assetAddress) public virtual view returns (uint256);

}

abstract contract RampInstantEscrows
is Ownable, WithStatus, WithOracles, WithSwapsCreators, AssetAdapterWithFees {

    string public constant VERSION = "0.6.4";

    uint32 internal constant MIN_ACTUAL_TIMESTAMP = 1000000000;

    uint32 internal constant MIN_SWAP_LOCK_TIME_S = 24 hours;
    uint32 internal constant MAX_SWAP_LOCK_TIME_S = 30 days;

    event Created(bytes32 indexed swapHash);
    event Released(bytes32 indexed swapHash);
    event PoolReleased(bytes32 indexed swapHash);
    event Returned(bytes32 indexed swapHash);
    event PoolReturned(bytes32 indexed swapHash);

    mapping (bytes32 => uint32) internal swaps;

    function create(
        address payable _pool,
        address _receiver,
        address _oracle,
        bytes calldata _assetData,
        bytes32 _paymentDetailsHash,
        uint32 lockTimeS
    )
        external
        statusAtLeast(Status.ACTIVE)
        onlySwapCreator()
        isOracle(_oracle)
        checkAssetTypeAndData(_assetData, _pool)
        returns
        (bool success)
    {
        require(
            lockTimeS >= MIN_SWAP_LOCK_TIME_S && lockTimeS <= MAX_SWAP_LOCK_TIME_S,
            "ltl"  // "lock time outside limits"
        );
        bytes32 swapHash = getSwapHash(
            _pool, _receiver, _oracle, keccak256(_assetData), _paymentDetailsHash
        );
        requireSwapNotExists(swapHash);
        swaps[swapHash] = uint32(block.timestamp) + lockTimeS;
        require(
            lockAssetWithFee(_assetData, _pool),
            "elf"  // "escrow lock failed"
        );
        emit Created(swapHash);
        return true;
    }

    function release(
        address _pool,
        address payable _receiver,
        address _oracle,
        bytes calldata _assetData,
        bytes32 _paymentDetailsHash
    ) external statusAtLeast(Status.FINALIZE_ONLY) onlyOracleOrPool(_pool, _oracle) {
        bytes32 swapHash = getSwapHash(
            _pool, _receiver, _oracle, keccak256(_assetData), _paymentDetailsHash
        );
        requireSwapCreated(swapHash);
        swaps[swapHash] = 0;
        require(
            sendAssetKeepingFee(_assetData, _receiver),
            "arf"  // "asset release failed"
        );
        if (msg.sender == _pool) {
            emit PoolReleased(swapHash);
        } else {
            emit Released(swapHash);
        }
    }

    function returnFunds(
        address payable _pool,
        address _receiver,
        address _oracle,
        bytes calldata _assetData,
        bytes32 _paymentDetailsHash
    ) external statusAtLeast(Status.RETURN_ONLY) onlyOracleOrPool(_pool, _oracle) {
        bytes32 swapHash = getSwapHash(
            _pool, _receiver, _oracle, keccak256(_assetData), _paymentDetailsHash
        );
        requireSwapExpired(swapHash);
        swaps[swapHash] = 0;
        require(
            sendAssetWithFee(_assetData, _pool),
            "acf"  // "asset return failed"
        );
        if (msg.sender == _pool) {
            emit PoolReturned(swapHash);
        } else {
            emit Returned(swapHash);
        }
    }

    function getSwapStatus(
        address _pool,
        address _receiver,
        address _oracle,
        bytes calldata _assetData,
        bytes32 _paymentDetailsHash
    ) external view returns (uint32 status) {
        bytes32 swapHash = getSwapHash(
            _pool, _receiver, _oracle, keccak256(_assetData), _paymentDetailsHash
        );
        return swaps[swapHash];
    }

    function getSwapHash(
        address _pool,
        address _receiver,
        address _oracle,
        bytes32 assetHash,
        bytes32 _paymentDetailsHash
    ) internal pure returns (bytes32) {
        return keccak256(
            abi.encodePacked(
                _pool, _receiver, _oracle, assetHash, _paymentDetailsHash
            )
        );
    }

    function requireSwapNotExists(bytes32 swapHash) internal view {
        require(
            swaps[swapHash] == 0,
            "sae"  // "swap already exists"
        );
    }

    function requireSwapCreated(bytes32 swapHash) internal view {
        require(
            swaps[swapHash] > MIN_ACTUAL_TIMESTAMP,
            "siv"  // "swap invalid"
        );
    }

    function requireSwapExpired(bytes32 swapHash) internal view {
        require(
            swaps[swapHash] > MIN_ACTUAL_TIMESTAMP && block.timestamp > swaps[swapHash],
            "sei"  // "swap not expired or invalid"
        );
    }

}

abstract contract TokenTransferrer {

    function doTokenTransfer(
        address _token,
        address _to,
        uint256 _amount
    ) internal returns (bool success) {
        bytes memory callData = abi.encodeWithSelector(bytes4(0xa9059cbb), _to, _amount);
        (success, callData) = _token.call(callData);
        require(success, string(callData));
        assembly {
            success := or(
                iszero(returndatasize()),
                and(eq(returndatasize(), 32), gt(mload(add(callData, mload(callData))), 0))
            )
        }
        require(success, "ttf");  // "token transfer failed"
        return true;
    }

}

abstract contract TokenAdapter is AssetAdapterWithFees, TokenTransferrer {

    uint16 internal constant TOKEN_TYPE_ID = 2;
    uint16 internal constant TOKEN_ASSET_DATA_LENGTH = 86;
    mapping (address => uint256) internal accumulatedFees;

    constructor() AssetAdapter(TOKEN_TYPE_ID) {}

    function getAmount(bytes memory assetData) internal override pure returns (uint256 amount) {
        assembly {
            amount := mload(add(assetData, 34))
        }
    }

    function getFee(bytes memory assetData) internal override pure returns (uint256 fee) {
        assembly {
            fee := mload(add(assetData, 66))
        }
    }

    function getTokenAddress(bytes memory assetData) internal pure returns (address tokenAddress) {
        assembly {
            tokenAddress := and(
                mload(add(assetData, 86)),
                0xffffffffffffffffffffffffffffffffffffffff
            )
        }
    }

    function rawSendAsset(
        bytes memory assetData,
        uint256 _amount,
        address payable _to
    ) internal override returns (bool success) {
        return doTokenTransfer(getTokenAddress(assetData), _to, _amount);
    }

    function accumulateFee(bytes memory assetData) internal override {
        accumulatedFees[getTokenAddress(assetData)] += getFee(assetData);
    }

    function withdrawFees(
        bytes calldata assetData,
        address payable _to
    ) external override onlyOwner returns (bool success) {
        address token = getTokenAddress(assetData);
        uint256 fees = accumulatedFees[token];
        accumulatedFees[token] = 0;
        return doTokenTransfer(getTokenAddress(assetData), _to, fees);
    }

    function checkAssetData(bytes memory assetData, address _pool) internal override view {
        require(assetData.length == TOKEN_ASSET_DATA_LENGTH, "adl");  // "invalid asset data length"
        require(
            RampInstantTokenPoolInterface(_pool).token() == getTokenAddress(assetData),
            "pta"  // "invalid pool token address"
        );
    }

    function getAccumulatedFees(address _assetAddress) public override view returns (uint256) {
        return accumulatedFees[_assetAddress];
    }

}

contract RampInstantTokenEscrows is RampInstantEscrows, TokenAdapter {}
