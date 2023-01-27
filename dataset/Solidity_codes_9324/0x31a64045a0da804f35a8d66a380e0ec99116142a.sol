
pragma solidity ^0.8.1;

library AddressUpgradeable {

    function isContract(address account) internal view returns (bool) {


        return account.code.length > 0;
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


abstract contract Initializable {
    bool private _initialized;

    bool private _initializing;

    modifier initializer() {
        require(_initializing ? _isConstructor() : !_initialized, "Initializable: contract is already initialized");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }

    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    function _isConstructor() private view returns (bool) {
        return !AddressUpgradeable.isContract(address(this));
    }
}// MIT

pragma solidity ^0.8.0;

abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal onlyInitializing {
    }

    function __Context_init_unchained() internal onlyInitializing {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }

    uint256[50] private __gap;
}// MIT

pragma solidity ^0.8.0;


abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function __Ownable_init() internal onlyInitializing {
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal onlyInitializing {
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

    uint256[49] private __gap;
}// MIT

pragma solidity ^0.8.0;

abstract contract ReentrancyGuard {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
    }
}// AGPL-3.0
pragma solidity ^0.8.2;


interface IEverscale {

    struct EverscaleAddress {
        int128 wid;
        uint256 addr;
    }

    struct EverscaleEvent {
        uint64 eventTransactionLt;
        uint32 eventTimestamp;
        bytes eventData;
        int8 configurationWid;
        uint256 configurationAddress;
        int8 eventContractWid;
        uint256 eventContractAddress;
        address proxy;
        uint32 round;
    }
}// AGPL-3.0
pragma solidity ^0.8.2;

pragma experimental ABIEncoderV2;


interface IBridge is IEverscale {

    struct Round {
        uint32 end;
        uint32 ttl;
        uint32 relays;
        uint32 requiredSignatures;
    }

    function updateMinimumRequiredSignatures(uint32 _minimumRequiredSignatures) external;

    function setConfiguration(EverscaleAddress calldata _roundRelaysConfiguration) external;

    function updateRoundTTL(uint32 _roundTTL) external;


    function isRelay(
        uint32 round,
        address candidate
    ) external view returns (bool);


    function isBanned(
        address candidate
    ) external view returns (bool);


    function isRoundRotten(
        uint32 round
    ) external view returns (bool);


    function verifySignedEverscaleEvent(
        bytes memory payload,
        bytes[] memory signatures
    ) external view returns (uint32);


    function setRoundRelays(
        bytes calldata payload,
        bytes[] calldata signatures
    ) external;


    function forceRoundRelays(
        uint160[] calldata _relays,
        uint32 roundEnd
    ) external;


    function banRelays(
        address[] calldata _relays
    ) external;


    function unbanRelays(
        address[] calldata _relays
    ) external;


    function pause() external;

    function unpause() external;


    function setRoundSubmitter(address _roundSubmitter) external;


    event EmergencyShutdown(bool active);

    event UpdateMinimumRequiredSignatures(uint32 value);
    event UpdateRoundTTL(uint32 value);
    event UpdateRoundRelaysConfiguration(EverscaleAddress configuration);
    event UpdateRoundSubmitter(address _roundSubmitter);

    event NewRound(uint32 indexed round, Round meta);
    event RoundRelay(uint32 indexed round, address indexed relay);
    event BanRelay(address indexed relay, bool status);
}// AGPL-3.0
pragma solidity ^0.8.2;




interface IDAO {

    struct EthAction {
        uint value;
        uint160 target;
        string signature;
        bytes data;
    }

    function setBridge(
        address _bridge
    ) external;


    function execute(
        bytes memory payload,
        bytes[] memory signatures
    ) external returns (bytes[] memory responses);


    event UpdateBridge(address indexed bridge);
    event UpdateConfiguration(IBridge.EverscaleAddress configuration);
}// AGPL-3.0
pragma solidity ^0.8.2;


contract Cache {

    mapping (bytes32 => bool) public cache;

    modifier notCached(bytes memory payload) {

        bytes32 hash_ = keccak256(abi.encode(payload));

        require(cache[hash_] == false, "Cache: payload already seen");

        _;

        cache[hash_] = true;
    }
}// AGPL-3.0
pragma solidity ^0.8.2;


contract ChainId {

    function getChainID() public view returns (uint256) {

        uint256 id;
        assembly {
            id := chainid()
        }
        return id;
    }
}// AGPL-3.0
pragma solidity ^0.8.2;





contract DAO is IDAO, IEverscale, ReentrancyGuard, OwnableUpgradeable, Cache, ChainId {

    address public bridge;
    EverscaleAddress public configuration;

    function initialize(
        address _owner,
        address _bridge
    ) public initializer {

        bridge = _bridge;

        __Ownable_init();
        transferOwnership(_owner);
    }

    function setConfiguration(
        EverscaleAddress calldata _configuration
    ) public onlyOwner {

        configuration = _configuration;
    }

    function setBridge(
        address _bridge
    ) override external onlyOwner {

        bridge = _bridge;
    }

    function decodeEthActionsEventData(
        bytes memory payload
    ) public pure returns (
        int8 _wid,
        uint256 _addr,
        uint32 chainId,
        EthAction[] memory actions
    ) {

        (EverscaleEvent memory _event) = abi.decode(payload, (EverscaleEvent));

        return abi.decode(
            _event.eventData,
            (int8, uint256, uint32, EthAction[])
        );
    }

    function execute(
        bytes calldata payload,
        bytes[] calldata signatures
    )
        override
        external
        nonReentrant
        notCached(payload)
    returns (
        bytes[] memory responses
    ) {

        require(
            IBridge(bridge).verifySignedEverscaleEvent(
                payload,
                signatures
            ) == 0,
            "DAO: signatures verification failed"
        );

        (EverscaleEvent memory _event) = abi.decode(payload, (EverscaleEvent));

        require(
            _event.configurationWid == configuration.wid &&
            _event.configurationAddress == configuration.addr,
            "DAO: wrong event configuration"
        );

        (
            ,,
            uint32 chainId,
            EthAction[] memory actions
        ) = decodeEthActionsEventData(payload);

        require(
            chainId == getChainID(),
            "DAO: wrong chain id"
        );

        responses = new bytes[](actions.length);

        for (uint i=0; i<actions.length; i++) {
            EthAction memory action = actions[i];

            bytes memory callData;

            if (bytes(action.signature).length == 0) {
                callData = action.data;
            } else {
                callData = abi.encodePacked(
                    bytes4(keccak256(bytes(action.signature))),
                    action.data
                );
            }

            (bool success, bytes memory response) = address(action.target)
                .call{value: action.value}(callData);

            require(success, "DAO: execution fail");

            responses[i] = response;
        }
    }
}