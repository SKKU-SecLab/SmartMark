
pragma solidity >=0.5.0;

interface ILayerZeroReceiver {

    function lzReceive(uint16 _srcChainId, bytes calldata _srcAddress, uint64 _nonce, bytes calldata _payload) external;

}// BUSL-1.1

pragma solidity >=0.5.0;

interface ILayerZeroUserApplicationConfig {

    function setConfig(uint16 _version, uint16 _chainId, uint _configType, bytes calldata _config) external;


    function setSendVersion(uint16 _version) external;


    function setReceiveVersion(uint16 _version) external;


    function forceResumeReceive(uint16 _srcChainId, bytes calldata _srcAddress) external;

}// BUSL-1.1

pragma solidity >=0.5.0;


interface ILayerZeroEndpoint is ILayerZeroUserApplicationConfig {

    function send(uint16 _dstChainId, bytes calldata _destination, bytes calldata _payload, address payable _refundAddress, address _zroPaymentAddress, bytes calldata _adapterParams) external payable;


    function receivePayload(uint16 _srcChainId, bytes calldata _srcAddress, address _dstAddress, uint64 _nonce, uint _gasLimit, bytes calldata _payload) external;


    function getInboundNonce(uint16 _srcChainId, bytes calldata _srcAddress) external view returns (uint64);


    function getOutboundNonce(uint16 _dstChainId, address _srcAddress) external view returns (uint64);


    function estimateFees(uint16 _dstChainId, address _userApplication, bytes calldata _payload, bool _payInZRO, bytes calldata _adapterParam) external view returns (uint nativeFee, uint zroFee);


    function getChainId() external view returns (uint16);


    function retryPayload(uint16 _srcChainId, bytes calldata _srcAddress, bytes calldata _payload) external;


    function hasStoredPayload(uint16 _srcChainId, bytes calldata _srcAddress) external view returns (bool);


    function getSendLibraryAddress(address _userApplication) external view returns (address);


    function getReceiveLibraryAddress(address _userApplication) external view returns (address);


    function isSendingPayload() external view returns (bool);


    function isReceivingPayload() external view returns (bool);


    function getConfig(uint16 _version, uint16 _chainId, address _userApplication, uint _configType) external view returns (bytes memory);


    function getSendVersion(address _userApplication) external view returns (uint16);


    function getReceiveVersion(address _userApplication) external view returns (uint16);

}// BUSL-1.1

pragma solidity >=0.7.0;


interface ILayerZeroMessagingLibrary {

    function send(address _userApplication, uint64 _lastNonce, uint16 _chainId, bytes calldata _destination, bytes calldata _payload, address payable refundAddress, address _zroPaymentAddress, bytes calldata _adapterParams) external payable;


    function estimateFees(uint16 _chainId, address _userApplication, bytes calldata _payload, bool _payInZRO, bytes calldata _adapterParam) external view returns (uint nativeFee, uint zroFee);


    function setConfig(uint16 _chainId, address _userApplication, uint _configType, bytes calldata _config) external;


    function getConfig(uint16 _chainId, address _userApplication, uint _configType) external view returns (bytes memory);

}// MIT

pragma solidity >=0.6.0 <0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}// MIT

pragma solidity ^0.7.0;

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}// BUSL-1.1

pragma solidity 0.7.6;



contract Endpoint is Ownable, ILayerZeroEndpoint {

    uint16 public immutable chainId;

    uint16 public constant BLOCK_VERSION = 65535;
    uint16 public constant DEFAULT_VERSION = 0;
    uint16 public latestVersion;
    mapping(uint16 => ILayerZeroMessagingLibrary) public libraryLookup; // version -> ILayerZeroEndpointLibrary

    uint16 public defaultSendVersion;
    uint16 public defaultReceiveVersion;
    ILayerZeroMessagingLibrary public defaultSendLibrary;
    address public defaultReceiveLibraryAddress;

    struct LibraryConfig {
        uint16 sendVersion;
        uint16 receiveVersion;
        address receiveLibraryAddress;
        ILayerZeroMessagingLibrary sendLibrary;
    }

    struct StoredPayload {
        uint64 payloadLength;
        address dstAddress;
        bytes32 payloadHash;
    }

    mapping(address => LibraryConfig) public uaConfigLookup;
    mapping(uint16 => mapping(bytes => uint64)) public inboundNonce;
    mapping(uint16 => mapping(address => uint64)) public outboundNonce;
    mapping(uint16 => mapping(bytes => StoredPayload)) public storedPayload;

    event NewLibraryVersionAdded(uint16 version);
    event DefaultSendVersionSet(uint16 version);
    event DefaultReceiveVersionSet(uint16 version);
    event UaSendVersionSet(address ua, uint16 version);
    event UaReceiveVersionSet(address ua, uint16 version);
    event UaForceResumeReceive(uint16 chainId, bytes srcAddress);
    event PayloadCleared(uint16 srcChainId, bytes srcAddress, uint64 nonce, address dstAddress);
    event PayloadStored(uint16 srcChainId, bytes srcAddress, address dstAddress, uint64 nonce, bytes payload, bytes reason);

    constructor(uint16 _chainId) {
        chainId = _chainId;
    }

    uint8 internal constant _NOT_ENTERED = 1;
    uint8 internal constant _ENTERED = 2;
    uint8 internal _send_entered_state = 1;
    uint8 internal _receive_entered_state = 1;

    modifier sendNonReentrant() {

        require(_send_entered_state == _NOT_ENTERED, "LayerZero: no send reentrancy");
        _send_entered_state = _ENTERED;
        _;
        _send_entered_state = _NOT_ENTERED;
    }
    modifier receiveNonReentrant() {

        require(_receive_entered_state == _NOT_ENTERED, "LayerZero: no receive reentrancy");
        _receive_entered_state = _ENTERED;
        _;
        _receive_entered_state = _NOT_ENTERED;
    }

    modifier validVersion(uint16 _version) {

        require(_version <= latestVersion || _version == BLOCK_VERSION, "LayerZero: invalid messaging library version");
        _;
    }


    function send(uint16 _dstChainId, bytes calldata _destination, bytes calldata _payload, address payable _refundAddress, address _zroPaymentAddress, bytes calldata _adapterParams) external payable override sendNonReentrant {

        LibraryConfig storage uaConfig = uaConfigLookup[msg.sender];
        uint64 nonce = ++outboundNonce[_dstChainId][msg.sender];
        _getSendLibrary(uaConfig).send{value: msg.value}(msg.sender, nonce, _dstChainId, _destination, _payload, _refundAddress, _zroPaymentAddress, _adapterParams);
    }

    function receivePayload(uint16 _srcChainId, bytes calldata _srcAddress, address _dstAddress, uint64 _nonce, uint _gasLimit, bytes calldata _payload) external override receiveNonReentrant {

        require(_nonce == ++inboundNonce[_srcChainId][_srcAddress], "LayerZero: wrong nonce");

        LibraryConfig storage uaConfig = uaConfigLookup[_dstAddress];

        if (uaConfig.receiveVersion == DEFAULT_VERSION) {
            require(defaultReceiveLibraryAddress == msg.sender, "LayerZero: invalid default library");
        } else {
            require(uaConfig.receiveLibraryAddress == msg.sender, "LayerZero: invalid library");
        }

        StoredPayload storage sp = storedPayload[_srcChainId][_srcAddress];
        require(sp.payloadHash == bytes32(0), "LayerZero: in message blocking");

        try ILayerZeroReceiver(_dstAddress).lzReceive{gas: _gasLimit}(_srcChainId, _srcAddress, _nonce, _payload) {
        } catch (bytes memory reason) {
            storedPayload[_srcChainId][_srcAddress] = StoredPayload(uint64(_payload.length), _dstAddress, keccak256(_payload));
            emit PayloadStored(_srcChainId, _srcAddress, _dstAddress, _nonce, _payload, reason);
        }
    }

    function retryPayload(uint16 _srcChainId, bytes calldata _srcAddress, bytes calldata _payload) external override receiveNonReentrant {
        StoredPayload storage sp = storedPayload[_srcChainId][_srcAddress];
        require(sp.payloadHash != bytes32(0), "LayerZero: no stored payload");
        require(_payload.length == sp.payloadLength && keccak256(_payload) == sp.payloadHash, "LayerZero: invalid payload");

        address dstAddress = sp.dstAddress;
        sp.payloadLength = 0;
        sp.dstAddress = address(0);
        sp.payloadHash = bytes32(0);

        uint64 nonce = inboundNonce[_srcChainId][_srcAddress];

        ILayerZeroReceiver(dstAddress).lzReceive(_srcChainId, _srcAddress, nonce, _payload);
        emit PayloadCleared(_srcChainId, _srcAddress, nonce, dstAddress);
    }


    function newVersion(address _newLayerZeroLibraryAddress) external onlyOwner {
        require(_newLayerZeroLibraryAddress != address(0x0), "LayerZero: new version cannot be zero address");
        require(latestVersion < 65535, "LayerZero: can not add new messaging library");
        latestVersion++;
        libraryLookup[latestVersion] = ILayerZeroMessagingLibrary(_newLayerZeroLibraryAddress);
        emit NewLibraryVersionAdded(latestVersion);
    }

    function setDefaultSendVersion(uint16 _newDefaultSendVersion) external onlyOwner validVersion(_newDefaultSendVersion) {
        require(_newDefaultSendVersion != DEFAULT_VERSION, "LayerZero: default send version must > 0");
        defaultSendVersion = _newDefaultSendVersion;
        defaultSendLibrary = libraryLookup[defaultSendVersion];
        emit DefaultSendVersionSet(_newDefaultSendVersion);
    }

    function setDefaultReceiveVersion(uint16 _newDefaultReceiveVersion) external onlyOwner validVersion(_newDefaultReceiveVersion) {
        require(_newDefaultReceiveVersion != DEFAULT_VERSION, "LayerZero: default receive version must > 0");
        defaultReceiveVersion = _newDefaultReceiveVersion;
        defaultReceiveLibraryAddress = address(libraryLookup[defaultReceiveVersion]);
        emit DefaultReceiveVersionSet(_newDefaultReceiveVersion);
    }


    function setConfig(uint16 _version, uint16 _chainId, uint _configType, bytes calldata _config) external override validVersion(_version) {
        if (_version == DEFAULT_VERSION) {
            require(defaultSendVersion == defaultReceiveVersion, "LayerZero: can not set Config during DEFAULT migration");
            _version = defaultSendVersion;
        }
        require(_version != BLOCK_VERSION, "LayerZero: can not set config for BLOCK_VERSION");
        libraryLookup[_version].setConfig(_chainId, msg.sender, _configType, _config);
    }

    function setSendVersion(uint16 _newVersion) external override validVersion(_newVersion) {
        LibraryConfig storage uaConfig = uaConfigLookup[msg.sender];
        uaConfig.sendVersion = _newVersion;
        uaConfig.sendLibrary = libraryLookup[_newVersion];
        emit UaSendVersionSet(msg.sender, _newVersion);
    }

    function setReceiveVersion(uint16 _newVersion) external override validVersion(_newVersion) {
        LibraryConfig storage uaConfig = uaConfigLookup[msg.sender];
        uaConfig.receiveVersion = _newVersion;
        uaConfig.receiveLibraryAddress = address(libraryLookup[_newVersion]);
        emit UaReceiveVersionSet(msg.sender, _newVersion);
    }

    function forceResumeReceive(uint16 _srcChainId, bytes calldata _srcAddress) external override {
        StoredPayload storage sp = storedPayload[_srcChainId][_srcAddress];
        require(sp.payloadHash != bytes32(0), "LayerZero: no stored payload");
        require(sp.dstAddress == msg.sender, "LayerZero: invalid caller");

        sp.payloadLength = 0;
        sp.dstAddress = address(0);
        sp.payloadHash = bytes32(0);

        emit UaForceResumeReceive(_srcChainId, _srcAddress);
    }


    function estimateFees(uint16 _dstChainId, address _userApplication, bytes calldata _payload, bool _payInZRO, bytes calldata _adapterParams) external view override returns (uint nativeFee, uint zroFee) {
        LibraryConfig storage uaConfig = uaConfigLookup[_userApplication];
        ILayerZeroMessagingLibrary lib = uaConfig.sendVersion == DEFAULT_VERSION ? defaultSendLibrary : uaConfig.sendLibrary;
        return lib.estimateFees(_dstChainId, _userApplication, _payload, _payInZRO, _adapterParams);
    }

    function _getSendLibrary(LibraryConfig storage uaConfig) internal view returns (ILayerZeroMessagingLibrary) {
        if (uaConfig.sendVersion == DEFAULT_VERSION) {
            require(defaultSendVersion != BLOCK_VERSION, "LayerZero: default in BLOCK_VERSION");
            return defaultSendLibrary;
        } else {
            require(uaConfig.sendVersion != BLOCK_VERSION, "LayerZero: in BLOCK_VERSION");
            return uaConfig.sendLibrary;
        }
    }

    function getSendLibraryAddress(address _userApplication) external view override returns (address sendLibraryAddress) {
        LibraryConfig storage uaConfig = uaConfigLookup[_userApplication];
        uint16 sendVersion = uaConfig.sendVersion;
        require(sendVersion != BLOCK_VERSION, "LayerZero: send version is BLOCK_VERSION");
        if (sendVersion == DEFAULT_VERSION) {
            require(defaultSendVersion != BLOCK_VERSION, "LayerZero: send version (default) is BLOCK_VERSION");
            sendLibraryAddress = address(defaultSendLibrary);
        } else {
            sendLibraryAddress = address(uaConfig.sendLibrary);
        }
    }

    function getReceiveLibraryAddress(address _userApplication) external view override returns (address receiveLibraryAddress) {
        LibraryConfig storage uaConfig = uaConfigLookup[_userApplication];
        uint16 receiveVersion = uaConfig.receiveVersion;
        require(receiveVersion != BLOCK_VERSION, "LayerZero: receive version is BLOCK_VERSION");
        if (receiveVersion == DEFAULT_VERSION) {
            require(defaultReceiveVersion != BLOCK_VERSION, "LayerZero: receive version (default) is BLOCK_VERSION");
            receiveLibraryAddress = defaultReceiveLibraryAddress;
        } else {
            receiveLibraryAddress = uaConfig.receiveLibraryAddress;
        }
    }

    function isSendingPayload() external view override returns (bool) {
        return _send_entered_state == _ENTERED;
    }

    function isReceivingPayload() external view override returns (bool) {
        return _receive_entered_state == _ENTERED;
    }

    function getInboundNonce(uint16 _srcChainId, bytes calldata _srcAddress) external view override returns (uint64) {
        return inboundNonce[_srcChainId][_srcAddress];
    }

    function getOutboundNonce(uint16 _dstChainId, address _srcAddress) external view override returns (uint64) {
        return outboundNonce[_dstChainId][_srcAddress];
    }

    function getChainId() external view override returns (uint16) {
        return chainId;
    }

    function getSendVersion(address _userApplication) external view override returns (uint16) {
        LibraryConfig storage uaConfig = uaConfigLookup[_userApplication];
        return uaConfig.sendVersion == DEFAULT_VERSION ? defaultSendVersion : uaConfig.sendVersion;
    }

    function getReceiveVersion(address _userApplication) external view override returns (uint16) {
        LibraryConfig storage uaConfig = uaConfigLookup[_userApplication];
        return uaConfig.receiveVersion == DEFAULT_VERSION ? defaultReceiveVersion : uaConfig.receiveVersion;
    }

    function getConfig(uint16 _version, uint16 _chainId, address _userApplication, uint _configType) external view override validVersion(_version) returns (bytes memory) {
        if (_version == DEFAULT_VERSION) {
            require(defaultSendVersion == defaultReceiveVersion, "LayerZero: no DEFAULT config while migration");
            _version = defaultSendVersion;
        }
        require(_version != BLOCK_VERSION, "LayerZero: can not get config for BLOCK_VERSION");
        return libraryLookup[_version].getConfig(_chainId, _userApplication, _configType);
    }

    function hasStoredPayload(uint16 _srcChainId, bytes calldata _srcAddress) external view override returns (bool) {
        StoredPayload storage sp = storedPayload[_srcChainId][_srcAddress];
        return sp.payloadHash != bytes32(0);
    }
}