
pragma solidity ^0.8.0;

abstract contract Initializable {
    bool private _initialized;

    bool private _initializing;

    modifier initializer() {
        require(_initializing || !_initialized, "Initializable: contract is already initialized");

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
}// MIT

pragma solidity ^0.8.0;

abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal initializer {
        __Context_init_unchained();
    }

    function __Context_init_unchained() internal initializer {
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

    function __Ownable_init() internal initializer {
        __Context_init_unchained();
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal initializer {
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
    uint256[49] private __gap;
}// MIT

pragma solidity ^0.8.0;


abstract contract PausableUpgradeable is Initializable, ContextUpgradeable {
    event Paused(address account);

    event Unpaused(address account);

    bool private _paused;

    function __Pausable_init() internal initializer {
        __Context_init_unchained();
        __Pausable_init_unchained();
    }

    function __Pausable_init_unchained() internal initializer {
        _paused = false;
    }

    function paused() public view virtual returns (bool) {
        return _paused;
    }

    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
        _;
    }

    modifier whenPaused() {
        require(paused(), "Pausable: not paused");
        _;
    }

    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
    uint256[49] private __gap;
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

library ECDSA {


    function recover(bytes32 hash, bytes memory signature)
    internal
    pure
    returns (address)
    {

        bytes32 r;
        bytes32 s;
        uint8 v;

        if (signature.length != 65) {
            return (address(0));
        }

        assembly {
            r := mload(add(signature, 0x20))
            s := mload(add(signature, 0x40))
            v := byte(0, mload(add(signature, 0x60)))
        }

        if (v < 27) {
            v += 27;
        }

        if (v != 27 && v != 28) {
            return (address(0));
        } else {
            return ecrecover(hash, v, r, s);
        }
    }

    function toBytesPrefixed(bytes32 hash)
    internal
    pure
    returns (bytes32)
    {

        return keccak256(
            abi.encodePacked("\x19Ethereum Signed Message:\n32", hash)
        );
    }
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





contract Bridge is OwnableUpgradeable, PausableUpgradeable, Cache, IBridge {

    using ECDSA for bytes32;

    mapping (uint32 => mapping(address => bool)) public relays;

    mapping (address => bool) public blacklist;

    mapping (uint32 => Round) public rounds;

    bool public emergencyShutdown;

    uint32 public minimumRequiredSignatures;

    uint32 public roundTTL;

    uint32 public initialRound;

    uint32 public lastRound;

    address public roundSubmitter;

    EverscaleAddress public roundRelaysConfiguration;

    function initialize(
        address _owner,
        address _roundSubmitter,
        uint32 _minimumRequiredSignatures,
        uint32 _roundTTL,
        uint32 _initialRound,
        uint32 _initialRoundEnd,
        uint160[] calldata _relays
    ) external initializer {

        __Pausable_init();
        __Ownable_init();
        transferOwnership(_owner);

        roundSubmitter = _roundSubmitter;
        emit UpdateRoundSubmitter(_roundSubmitter);

        minimumRequiredSignatures = _minimumRequiredSignatures;
        emit UpdateMinimumRequiredSignatures(minimumRequiredSignatures);

        roundTTL = _roundTTL;
        emit UpdateRoundTTL(roundTTL);

        require(
            _initialRoundEnd >= block.timestamp,
            "Bridge: initial round end should be in the future"
        );

        initialRound = _initialRound;
        _setRound(initialRound, _relays, _initialRoundEnd);

        lastRound = initialRound;
    }

    function setConfiguration(
        EverscaleAddress calldata _roundRelaysConfiguration
    ) external override onlyOwner {

        emit UpdateRoundRelaysConfiguration(_roundRelaysConfiguration);

        roundRelaysConfiguration = _roundRelaysConfiguration;
    }

    function pause() external override onlyOwner {

        _pause();
    }

    function unpause() external override onlyOwner {

        _unpause();
    }

    function updateMinimumRequiredSignatures(
        uint32 _minimumRequiredSignatures
    ) external override onlyOwner {

        minimumRequiredSignatures = _minimumRequiredSignatures;

        emit UpdateMinimumRequiredSignatures(_minimumRequiredSignatures);
    }

    function updateRoundTTL(
        uint32 _roundTTL
    ) external override onlyOwner {

        roundTTL = _roundTTL;

        emit UpdateRoundTTL(_roundTTL);
    }

    function isBanned(
        address candidate
    ) override public view returns (bool) {

        return blacklist[candidate];
    }

    function isRelay(
        uint32 round,
        address candidate
    ) override public view returns (bool) {

        return relays[round][candidate];
    }

    function isRoundRotten(
        uint32 round
    ) override public view returns (bool) {

        return block.timestamp > rounds[round].ttl;
    }

    function verifySignedEverscaleEvent(
        bytes memory payload,
        bytes[] memory signatures
    )
        override
        public
        view
    returns (
        uint32 errorCode
    ) {

        (EverscaleEvent memory _event) = abi.decode(payload, (EverscaleEvent));

        uint32 round = _event.round;

        if (round < initialRound) return 1;

        if (round > lastRound) return 2;

        uint32 count = _countRelaySignatures(payload, signatures, round);
        if (count < rounds[round].requiredSignatures) return 3;

        if (isRoundRotten(round)) return 4;

        if (paused()) return 5;

        return 0;
    }

    function recoverSignature(
        bytes memory payload,
        bytes memory signature
    ) public pure returns (address signer) {

        signer = keccak256(payload)
            .toBytesPrefixed()
            .recover(signature);
    }

    function forceRoundRelays(
        uint160[] calldata _relays,
        uint32 roundEnd
    ) override external {

        require(msg.sender == roundSubmitter, "Bridge: sender not round submitter");

        _setRound(lastRound + 1, _relays, roundEnd);

        lastRound++;
    }

    function setRoundSubmitter(
        address _roundSubmitter
    ) override external onlyOwner {

        roundSubmitter = _roundSubmitter;

        emit UpdateRoundSubmitter(roundSubmitter);
    }

    function setRoundRelays(
        bytes calldata payload,
        bytes[] calldata signatures
    ) override external notCached(payload) {

        require(
            verifySignedEverscaleEvent(
                payload,
                signatures
            ) == 0,
            "Bridge: signatures verification failed"
        );

        (EverscaleEvent memory _event) = abi.decode(payload, (EverscaleEvent));

        require(
            _event.configurationWid == roundRelaysConfiguration.wid &&
            _event.configurationAddress == roundRelaysConfiguration.addr,
            "Bridge: wrong event configuration"
        );

        (uint32 round, uint160[] memory _relays, uint32 roundEnd) = decodeRoundRelaysEventData(payload);

        require(round == lastRound + 1, "Bridge: wrong round");

        _setRound(round, _relays, roundEnd);

        lastRound++;
    }

    function decodeRoundRelaysEventData(
        bytes memory payload
    ) public pure returns (
        uint32 round,
        uint160[] memory _relays,
        uint32 roundEnd
    ) {

        (EverscaleEvent memory EverscaleEvent) = abi.decode(payload, (EverscaleEvent));

        (round, _relays, roundEnd) = abi.decode(
            EverscaleEvent.eventData,
            (uint32, uint160[], uint32)
        );
    }

    function decodeEverscaleEvent(
        bytes memory payload
    ) external pure returns (EverscaleEvent memory _event) {

        (_event) = abi.decode(payload, (EverscaleEvent));
    }

    function banRelays(
        address[] calldata _relays
    ) override external onlyOwner {

        for (uint i=0; i<_relays.length; i++) {
            blacklist[_relays[i]] = true;

            emit BanRelay(_relays[i], true);
        }
    }

    function unbanRelays(
        address[] calldata _relays
    ) override external onlyOwner {

        for (uint i=0; i<_relays.length; i++) {
            blacklist[_relays[i]] = false;

            emit BanRelay(_relays[i], false);
        }
    }

    function _setRound(
        uint32 round,
        uint160[] memory _relays,
        uint32 roundEnd
    ) internal {

        uint32 requiredSignatures = uint32(_relays.length * 2 / 3) + 1;

        rounds[round] = Round(
            roundEnd,
            roundEnd + roundTTL,
            uint32(_relays.length),
            requiredSignatures < minimumRequiredSignatures ? minimumRequiredSignatures : requiredSignatures
        );

        emit NewRound(round, rounds[round]);

        for (uint i=0; i<_relays.length; i++) {
            address relay = address(_relays[i]);

            relays[round][relay] = true;

            emit RoundRelay(round, relay);
        }
    }

    function _countRelaySignatures(
        bytes memory payload,
        bytes[] memory signatures,
        uint32 round
    ) internal view returns (uint32) {

        address lastSigner = address(0);
        uint32 count = 0;

        for (uint i=0; i<signatures.length; i++) {
            address signer = recoverSignature(payload, signatures[i]);

            require(signer > lastSigner, "Bridge: signatures sequence wrong");
            lastSigner = signer;

            if (isRelay(round, signer) && !isBanned(signer)) {
                count++;
            }
        }

        return count;
    }
}