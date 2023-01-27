

pragma solidity 0.7.5;

contract EternalStorage {

    mapping(bytes32 => uint256) internal uintStorage;
    mapping(bytes32 => string) internal stringStorage;
    mapping(bytes32 => address) internal addressStorage;
    mapping(bytes32 => bytes) internal bytesStorage;
    mapping(bytes32 => bool) internal boolStorage;
    mapping(bytes32 => int256) internal intStorage;
}


pragma solidity 0.7.5;


contract Initializable is EternalStorage {

    bytes32 internal constant INITIALIZED = 0x0a6f646cd611241d8073675e00d1a1ff700fbf1b53fcf473de56d1e6e4b714ba; // keccak256(abi.encodePacked("isInitialized"))

    function setInitialize() internal {

        boolStorage[INITIALIZED] = true;
    }

    function isInitialized() public view returns (bool) {

        return boolStorage[INITIALIZED];
    }
}


pragma solidity 0.7.5;

interface IUpgradeabilityOwnerStorage {

    function upgradeabilityOwner() external view returns (address);

}


pragma solidity 0.7.5;


contract Upgradeable {

    modifier onlyIfUpgradeabilityOwner() {

        require(msg.sender == IUpgradeabilityOwnerStorage(address(this)).upgradeabilityOwner());
        _;
    }
}


pragma solidity 0.7.5;


abstract contract BridgeOperationsStorage is EternalStorage {
    function setMessageToken(bytes32 _messageId, address _token) internal {
        addressStorage[keccak256(abi.encodePacked("messageToken", _messageId))] = _token;
    }

    function messageToken(bytes32 _messageId) internal view returns (address) {
        return addressStorage[keccak256(abi.encodePacked("messageToken", _messageId))];
    }

    function setMessageValue(bytes32 _messageId, uint256 _value) internal {
        uintStorage[keccak256(abi.encodePacked("messageValue", _messageId))] = _value;
    }

    function messageValue(bytes32 _messageId) internal view returns (uint256) {
        return uintStorage[keccak256(abi.encodePacked("messageValue", _messageId))];
    }

    function setMessageRecipient(bytes32 _messageId, address _recipient) internal {
        addressStorage[keccak256(abi.encodePacked("messageRecipient", _messageId))] = _recipient;
    }

    function messageRecipient(bytes32 _messageId) internal view returns (address) {
        return addressStorage[keccak256(abi.encodePacked("messageRecipient", _messageId))];
    }
}


pragma solidity 0.7.5;



contract Ownable is EternalStorage {

    bytes4 internal constant UPGRADEABILITY_OWNER = 0x6fde8202; // upgradeabilityOwner()

    event OwnershipTransferred(address previousOwner, address newOwner);

    modifier onlyOwner() {

        require(msg.sender == owner());
        _;
    }

    modifier onlyRelevantSender() {

        (bool isProxy, bytes memory returnData) = address(this).call(abi.encodeWithSelector(UPGRADEABILITY_OWNER));
        require(
            !isProxy || // covers usage without calling through storage proxy
                (returnData.length == 32 && msg.sender == abi.decode(returnData, (address))) || // covers usage through regular proxy calls
                msg.sender == address(this) // covers calls through upgradeAndCall proxy method
        );
        _;
    }

    bytes32 internal constant OWNER = 0x02016836a56b71f0d02689e69e326f4f4c1b9057164ef592671cf0d37c8040c0; // keccak256(abi.encodePacked("owner"))

    function owner() public view returns (address) {

        return addressStorage[OWNER];
    }

    function transferOwnership(address newOwner) external onlyOwner {

        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) internal {

        require(newOwner != address(0));
        emit OwnershipTransferred(owner(), newOwner);
        addressStorage[OWNER] = newOwner;
    }
}


pragma solidity 0.7.5;

interface IAMB {

    function messageSender() external view returns (address);


    function maxGasPerTx() external view returns (uint256);


    function transactionHash() external view returns (bytes32);


    function messageId() external view returns (bytes32);


    function messageSourceChainId() external view returns (bytes32);


    function messageCallStatus(bytes32 _messageId) external view returns (bool);


    function failedMessageDataHash(bytes32 _messageId) external view returns (bytes32);


    function failedMessageReceiver(bytes32 _messageId) external view returns (address);


    function failedMessageSender(bytes32 _messageId) external view returns (address);


    function requireToPassMessage(
        address _contract,
        bytes calldata _data,
        uint256 _gas
    ) external returns (bytes32);


    function requireToConfirmMessage(
        address _contract,
        bytes calldata _data,
        uint256 _gas
    ) external returns (bytes32);


    function sourceChainId() external view returns (uint256);


    function destinationChainId() external view returns (uint256);

}



pragma solidity ^0.7.0;

library Address {

    function isContract(address account) internal view returns (bool) {

        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
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

        (bool success, bytes memory returndata) = target.call{ value: weiValue }(data);
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


pragma solidity 0.7.5;




contract BasicAMBMediator is Ownable {

    bytes32 internal constant BRIDGE_CONTRACT = 0x811bbb11e8899da471f0e69a3ed55090fc90215227fc5fb1cb0d6e962ea7b74f; // keccak256(abi.encodePacked("bridgeContract"))
    bytes32 internal constant MEDIATOR_CONTRACT = 0x98aa806e31e94a687a31c65769cb99670064dd7f5a87526da075c5fb4eab9880; // keccak256(abi.encodePacked("mediatorContract"))
    bytes32 internal constant REQUEST_GAS_LIMIT = 0x2dfd6c9f781bb6bbb5369c114e949b69ebb440ef3d4dd6b2836225eb1dc3a2be; // keccak256(abi.encodePacked("requestGasLimit"))

    modifier onlyMediator {

        _onlyMediator();
        _;
    }

    function _onlyMediator() internal view {

        require(msg.sender == address(bridgeContract()));
        require(messageSender() == mediatorContractOnOtherSide());
    }

    function setBridgeContract(address _bridgeContract) external onlyOwner {

        _setBridgeContract(_bridgeContract);
    }

    function setMediatorContractOnOtherSide(address _mediatorContract) external onlyOwner {

        _setMediatorContractOnOtherSide(_mediatorContract);
    }

    function setRequestGasLimit(uint256 _requestGasLimit) external onlyOwner {

        _setRequestGasLimit(_requestGasLimit);
    }

    function bridgeContract() public view returns (IAMB) {

        return IAMB(addressStorage[BRIDGE_CONTRACT]);
    }

    function mediatorContractOnOtherSide() public view virtual returns (address) {

        return addressStorage[MEDIATOR_CONTRACT];
    }

    function requestGasLimit() public view returns (uint256) {

        return uintStorage[REQUEST_GAS_LIMIT];
    }

    function _setBridgeContract(address _bridgeContract) internal {

        require(Address.isContract(_bridgeContract));
        addressStorage[BRIDGE_CONTRACT] = _bridgeContract;
    }

    function _setMediatorContractOnOtherSide(address _mediatorContract) internal {

        addressStorage[MEDIATOR_CONTRACT] = _mediatorContract;
    }

    function _setRequestGasLimit(uint256 _requestGasLimit) internal {

        require(_requestGasLimit <= maxGasPerTx());
        uintStorage[REQUEST_GAS_LIMIT] = _requestGasLimit;
    }

    function messageSender() internal view returns (address) {

        return bridgeContract().messageSender();
    }

    function messageId() internal view returns (bytes32) {

        return bridgeContract().messageId();
    }

    function maxGasPerTx() internal view returns (uint256) {

        return bridgeContract().maxGasPerTx();
    }
}


pragma solidity 0.7.5;



abstract contract FailedMessagesProcessor is BasicAMBMediator, BridgeOperationsStorage {
    event FailedMessageFixed(bytes32 indexed messageId, address token, address recipient, uint256 value);

    function requestFailedMessageFix(bytes32 _messageId) external {
        require(!bridgeContract().messageCallStatus(_messageId));
        require(bridgeContract().failedMessageReceiver(_messageId) == address(this));
        require(bridgeContract().failedMessageSender(_messageId) == mediatorContractOnOtherSide());

        bytes4 methodSelector = this.fixFailedMessage.selector;
        bytes memory data = abi.encodeWithSelector(methodSelector, _messageId);
        bridgeContract().requireToPassMessage(mediatorContractOnOtherSide(), data, requestGasLimit());
    }

    function fixFailedMessage(bytes32 _messageId) public onlyMediator {
        require(!messageFixed(_messageId));

        address token = messageToken(_messageId);
        address recipient = messageRecipient(_messageId);
        uint256 value = messageValue(_messageId);
        setMessageFixed(_messageId);
        executeActionOnFixedTokens(_messageId, token, recipient, value);
        emit FailedMessageFixed(_messageId, token, recipient, value);
    }

    function messageFixed(bytes32 _messageId) public view returns (bool) {
        return boolStorage[keccak256(abi.encodePacked("messageFixed", _messageId))];
    }

    function setMessageFixed(bytes32 _messageId) internal {
        boolStorage[keccak256(abi.encodePacked("messageFixed", _messageId))] = true;
    }

    function executeActionOnFixedTokens(
        bytes32 _messageId,
        address _token,
        address _recipient,
        uint256 _value
    ) internal virtual;
}


pragma solidity 0.7.5;


abstract contract NFTBridgeLimits is Ownable {
    event DailyLimitChanged(address indexed token, uint256 newLimit);
    event ExecutionDailyLimitChanged(address indexed token, uint256 newLimit);

    function isTokenRegistered(address _token) public view virtual returns (bool);

    function totalSpentPerDay(address _token, uint256 _day) public view returns (uint256) {
        return uintStorage[keccak256(abi.encodePacked("totalSpentPerDay", _token, _day))];
    }

    function totalExecutedPerDay(address _token, uint256 _day) public view returns (uint256) {
        return uintStorage[keccak256(abi.encodePacked("totalExecutedPerDay", _token, _day))];
    }

    function dailyLimit(address _token) public view returns (uint256) {
        return uintStorage[keccak256(abi.encodePacked("dailyLimit", _token))];
    }

    function executionDailyLimit(address _token) public view returns (uint256) {
        return uintStorage[keccak256(abi.encodePacked("executionDailyLimit", _token))];
    }

    function withinLimit(address _token) public view returns (bool) {
        return dailyLimit(address(0)) > 0 && dailyLimit(_token) > totalSpentPerDay(_token, getCurrentDay());
    }

    function withinExecutionLimit(address _token) public view returns (bool) {
        return
            executionDailyLimit(address(0)) > 0 &&
            executionDailyLimit(_token) > totalExecutedPerDay(_token, getCurrentDay());
    }

    function getCurrentDay() public view returns (uint256) {
        return block.timestamp / 1 days;
    }

    function setDailyLimit(address _token, uint256 _dailyLimit) external onlyOwner {
        require(_token == address(0) || isTokenRegistered(_token));
        _setDailyLimit(_token, _dailyLimit);
    }

    function setExecutionDailyLimit(address _token, uint256 _dailyLimit) external onlyOwner {
        require(_token == address(0) || isTokenRegistered(_token));
        _setExecutionDailyLimit(_token, _dailyLimit);
    }

    function addTotalSpentPerDay(address _token) internal {
        uintStorage[keccak256(abi.encodePacked("totalSpentPerDay", _token, getCurrentDay()))] += 1;
    }

    function addTotalExecutedPerDay(address _token) internal {
        uintStorage[keccak256(abi.encodePacked("totalExecutedPerDay", _token, getCurrentDay()))] += 1;
    }

    function _setDailyLimit(address _token, uint256 _dailyLimit) internal {
        uintStorage[keccak256(abi.encodePacked("dailyLimit", _token))] = _dailyLimit;
        emit DailyLimitChanged(_token, _dailyLimit);
    }

    function _setExecutionDailyLimit(address _token, uint256 _dailyLimit) internal {
        uintStorage[keccak256(abi.encodePacked("executionDailyLimit", _token))] = _dailyLimit;
        emit ExecutionDailyLimitChanged(_token, _dailyLimit);
    }
}



pragma solidity ^0.7.0;

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}



pragma solidity ^0.7.0;


interface IERC721 is IERC165 {

    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    function balanceOf(address owner) external view returns (uint256 balance);


    function ownerOf(uint256 tokenId) external view returns (address owner);


    function safeTransferFrom(address from, address to, uint256 tokenId) external;


    function transferFrom(address from, address to, uint256 tokenId) external;


    function approve(address to, uint256 tokenId) external;


    function getApproved(uint256 tokenId) external view returns (address operator);


    function setApprovalForAll(address operator, bool _approved) external;


    function isApprovedForAll(address owner, address operator) external view returns (bool);


    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;

}


pragma solidity 0.7.5;


interface IBurnableMintableERC721Token is IERC721 {

    function mint(address _to, uint256 _tokeId) external;


    function burn(uint256 _tokenId) external;


    function setTokenURI(uint256 _tokenId, string calldata _tokenURI) external;

}


pragma solidity 0.7.5;

library Bytes {

    function bytesToAddress(bytes memory _bytes) internal pure returns (address addr) {

        assembly {
            addr := mload(add(_bytes, 20))
        }
    }
}


pragma solidity 0.7.5;

contract ReentrancyGuard {

    function lock() internal view returns (bool res) {

        assembly {
            res := sload(0x6168652c307c1e813ca11cfb3a601f1cf3b22452021a5052d8b05f1f1f8a3e92) // keccak256(abi.encodePacked("lock"))
        }
    }

    function setLock(bool _lock) internal {

        assembly {
            sstore(0x6168652c307c1e813ca11cfb3a601f1cf3b22452021a5052d8b05f1f1f8a3e92, _lock) // keccak256(abi.encodePacked("lock"))
        }
    }
}


pragma solidity 0.7.5;





abstract contract ERC721Relayer is BasicAMBMediator, ReentrancyGuard {
    function onERC721Received(
        address,
        address _from,
        uint256 _tokenId,
        bytes calldata _data
    ) external returns (bytes4) {
        if (!lock()) {
            bridgeSpecificActionsOnTokenTransfer(msg.sender, _from, chooseReceiver(_from, _data), _tokenId);
        }
        return msg.sig;
    }

    function relayToken(
        IERC721 token,
        address _receiver,
        uint256 _tokenId
    ) external {
        _relayToken(token, _receiver, _tokenId);
    }

    function relayToken(IERC721 token, uint256 _tokenId) external {
        _relayToken(token, msg.sender, _tokenId);
    }

    function _relayToken(
        IERC721 _token,
        address _receiver,
        uint256 _tokenId
    ) internal {
        require(!lock());

        setLock(true);
        _token.transferFrom(msg.sender, address(this), _tokenId);
        setLock(false);
        bridgeSpecificActionsOnTokenTransfer(address(_token), msg.sender, _receiver, _tokenId);
    }

    function chooseReceiver(address _from, bytes memory _data) internal pure returns (address recipient) {
        recipient = _from;
        if (_data.length > 0) {
            require(_data.length == 20);
            recipient = Bytes.bytesToAddress(_data);
        }
    }

    function bridgeSpecificActionsOnTokenTransfer(
        address _token,
        address _from,
        address _receiver,
        uint256 _tokenId
    ) internal virtual;
}


pragma solidity 0.7.5;

interface VersionableBridge {

    function getBridgeInterfacesVersion()
        external
        pure
        returns (
            uint64 major,
            uint64 minor,
            uint64 patch
        );


    function getBridgeMode() external pure returns (bytes4);

}


pragma solidity 0.7.5;


contract NFTOmnibridgeInfo is VersionableBridge {

    event TokensBridgingInitiated(
        address indexed token,
        address indexed sender,
        uint256 tokenId,
        bytes32 indexed messageId
    );
    event TokensBridged(address indexed token, address indexed recipient, uint256 tokenId, bytes32 indexed messageId);

    function getBridgeInterfacesVersion()
        external
        pure
        override
        returns (
            uint64 major,
            uint64 minor,
            uint64 patch
        )
    {

        return (1, 0, 0);
    }

    function getBridgeMode() external pure override returns (bytes4 _data) {

        return 0xca7fc3dc; // bytes4(keccak256(abi.encodePacked("multi-nft-to-nft-amb")))
    }
}


pragma solidity 0.7.5;


contract NativeTokensRegistry is EternalStorage {

    function isRegisteredAsNativeToken(address _token) public view returns (bool) {

        return tokenRegistrationMessageId(_token) != bytes32(0);
    }

    function tokenRegistrationMessageId(address _token) public view returns (bytes32) {

        return bytes32(uintStorage[keccak256(abi.encodePacked("tokenRegistrationMessageId", _token))]);
    }

    function _setTokenRegistrationMessageId(address _token, bytes32 _messageId) internal {

        uintStorage[keccak256(abi.encodePacked("tokenRegistrationMessageId", _token))] = uint256(_messageId);
    }
}



pragma solidity ^0.7.0;

library Strings {

    function toString(uint256 value) internal pure returns (string memory) {


        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        uint256 index = digits - 1;
        temp = value;
        while (temp != 0) {
            buffer[index--] = byte(uint8(48 + temp % 10));
            temp /= 10;
        }
        return string(buffer);
    }
}



pragma solidity ^0.7.0;


interface IERC721Metadata is IERC721 {


    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function tokenURI(uint256 tokenId) external view returns (string memory);

}


pragma solidity 0.7.5;




contract ERC721Reader is Ownable {

    function setCustomMetadata(
        address _token,
        string calldata _name,
        string calldata _symbol
    ) external onlyOwner {

        stringStorage[keccak256(abi.encodePacked("customName", _token))] = _name;
        stringStorage[keccak256(abi.encodePacked("customSymbol", _token))] = _symbol;
    }

    function _readName(address _token) internal view returns (string memory) {

        (bool status, bytes memory data) = _token.staticcall(abi.encodeWithSelector(IERC721Metadata.name.selector));
        return status ? abi.decode(data, (string)) : stringStorage[keccak256(abi.encodePacked("customName", _token))];
    }

    function _readSymbol(address _token) internal view returns (string memory) {

        (bool status, bytes memory data) = _token.staticcall(abi.encodeWithSelector(IERC721Metadata.symbol.selector));
        return status ? abi.decode(data, (string)) : stringStorage[keccak256(abi.encodePacked("customSymbol", _token))];
    }

    function _readTokenURI(address _token, uint256 _tokenId) internal view returns (string memory) {

        (bool status, bytes memory data) =
            _token.staticcall(abi.encodeWithSelector(IERC721Metadata.tokenURI.selector, _tokenId));
        return status ? abi.decode(data, (string)) : "";
    }
}


pragma solidity 0.7.5;


contract BridgedTokensRegistry is EternalStorage {

    event NewTokenRegistered(address indexed nativeToken, address indexed bridgedToken);

    function bridgedTokenAddress(address _nativeToken) public view returns (address) {

        return addressStorage[keccak256(abi.encodePacked("homeTokenAddress", _nativeToken))];
    }

    function nativeTokenAddress(address _bridgedToken) public view returns (address) {

        return addressStorage[keccak256(abi.encodePacked("foreignTokenAddress", _bridgedToken))];
    }

    function _setTokenAddressPair(address _nativeToken, address _bridgedToken) internal {

        addressStorage[keccak256(abi.encodePacked("homeTokenAddress", _nativeToken))] = _bridgedToken;
        addressStorage[keccak256(abi.encodePacked("foreignTokenAddress", _bridgedToken))] = _nativeToken;

        emit NewTokenRegistered(_nativeToken, _bridgedToken);
    }
}


pragma solidity 0.7.5;



contract TokenImageStorage is Ownable {

    bytes32 internal constant TOKEN_IMAGE_CONTRACT = 0x20b8ca26cc94f39fab299954184cf3a9bd04f69543e4f454fab299f015b8130f; // keccak256(abi.encodePacked("tokenImageContract"))

    function setTokenImage(address _image) external onlyOwner {

        _setTokenImage(_image);
    }

    function tokenImage() public view returns (address) {

        return addressStorage[TOKEN_IMAGE_CONTRACT];
    }

    function _setTokenImage(address _image) internal {

        require(Address.isContract(_image));
        addressStorage[TOKEN_IMAGE_CONTRACT] = _image;
    }
}


pragma solidity 0.7.5;

abstract contract Proxy {
    function implementation() public view virtual returns (address);

    fallback() external payable {
        address _impl = implementation();
        require(_impl != address(0));
        assembly {
            let ptr := mload(0x40)
            calldatacopy(ptr, 0, calldatasize())
            let result := delegatecall(gas(), _impl, ptr, calldatasize(), 0, 0)
            mstore(0x40, add(ptr, returndatasize()))
            returndatacopy(ptr, 0, returndatasize())

            switch result
                case 0 {
                    revert(ptr, returndatasize())
                }
                default {
                    return(ptr, returndatasize())
                }
        }
    }
}


pragma solidity 0.7.5;

interface IOwnable {

    function owner() external view returns (address);

}


pragma solidity 0.7.5;




contract ERC721TokenProxy is Proxy {

    mapping(bytes4 => bool) private _supportedInterfaces;
    mapping(address => uint256) private _holderTokens;

    uint256[] private _tokenOwnersEntries;
    mapping(bytes32 => uint256) private _tokenOwnersIndexes;

    mapping(uint256 => address) private _tokenApprovals;
    mapping(address => mapping(address => bool)) private _operatorApprovals;
    string private name;
    string private symbol;
    mapping(uint256 => string) private _tokenURIs;
    string private _baseURI;
    address private bridgeContract;

    constructor(
        address _tokenImage,
        string memory _name,
        string memory _symbol,
        address _owner
    ) {
        assembly {
            sstore(0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc, _tokenImage)
        }
        name = _name;
        symbol = _symbol;
        bridgeContract = _owner; // _owner == HomeOmnibridgeNFT/ForeignOmnibridgeNFT mediator
    }

    function implementation() public view override returns (address impl) {

        assembly {
            impl := sload(0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc)
        }
    }

    function setImplementation(address _implementation) external {

        require(msg.sender == bridgeContract || msg.sender == IOwnable(bridgeContract).owner());
        require(_implementation != address(0));
        require(Address.isContract(_implementation));
        assembly {
            sstore(0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc, _implementation)
        }
    }
}


pragma solidity 0.7.5;


contract NFTMediatorBalanceStorage is EternalStorage {

    function mediatorOwns(address _token, uint256 _tokenId) public view returns (bool) {

        return boolStorage[keccak256(abi.encodePacked("mediatorOwns", _token, _tokenId))];
    }

    function _setMediatorOwns(
        address _token,
        uint256 _tokenId,
        bool _owns
    ) internal {

        boolStorage[keccak256(abi.encodePacked("mediatorOwns", _token, _tokenId))] = _owns;
    }
}



pragma solidity ^0.7.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}



pragma solidity ^0.7.0;


interface IERC721Enumerable is IERC721 {


    function totalSupply() external view returns (uint256);


    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256 tokenId);


    function tokenByIndex(uint256 index) external view returns (uint256);

}



pragma solidity ^0.7.0;

interface IERC721Receiver {

    function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data)
    external returns (bytes4);

}



pragma solidity ^0.7.0;


abstract contract ERC165 is IERC165 {
    bytes4 private constant _INTERFACE_ID_ERC165 = 0x01ffc9a7;

    mapping(bytes4 => bool) private _supportedInterfaces;

    constructor () {
        _registerInterface(_INTERFACE_ID_ERC165);
    }

    function supportsInterface(bytes4 interfaceId) public view override returns (bool) {
        return _supportedInterfaces[interfaceId];
    }

    function _registerInterface(bytes4 interfaceId) internal virtual {
        require(interfaceId != 0xffffffff, "ERC165: invalid interface id");
        _supportedInterfaces[interfaceId] = true;
    }
}



pragma solidity ^0.7.0;

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



pragma solidity ^0.7.0;

library EnumerableSet {


    struct Set {
        bytes32[] _values;

        mapping (bytes32 => uint256) _indexes;
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

        if (valueIndex != 0) { // Equivalent to contains(set, value)

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;


            bytes32 lastvalue = set._values[lastIndex];

            set._values[toDeleteIndex] = lastvalue;
            set._indexes[lastvalue] = toDeleteIndex + 1; // All indexes are 1-based

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

        require(set._values.length > index, "EnumerableSet: index out of bounds");
        return set._values[index];
    }


    struct AddressSet {
        Set _inner;
    }

    function add(AddressSet storage set, address value) internal returns (bool) {

        return _add(set._inner, bytes32(uint256(value)));
    }

    function remove(AddressSet storage set, address value) internal returns (bool) {

        return _remove(set._inner, bytes32(uint256(value)));
    }

    function contains(AddressSet storage set, address value) internal view returns (bool) {

        return _contains(set._inner, bytes32(uint256(value)));
    }

    function length(AddressSet storage set) internal view returns (uint256) {

        return _length(set._inner);
    }

    function at(AddressSet storage set, uint256 index) internal view returns (address) {

        return address(uint256(_at(set._inner, index)));
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
}



pragma solidity ^0.7.0;

library EnumerableMap {


    struct MapEntry {
        bytes32 _key;
        bytes32 _value;
    }

    struct Map {
        MapEntry[] _entries;

        mapping (bytes32 => uint256) _indexes;
    }

    function _set(Map storage map, bytes32 key, bytes32 value) private returns (bool) {

        uint256 keyIndex = map._indexes[key];

        if (keyIndex == 0) { // Equivalent to !contains(map, key)
            map._entries.push(MapEntry({ _key: key, _value: value }));
            map._indexes[key] = map._entries.length;
            return true;
        } else {
            map._entries[keyIndex - 1]._value = value;
            return false;
        }
    }

    function _remove(Map storage map, bytes32 key) private returns (bool) {

        uint256 keyIndex = map._indexes[key];

        if (keyIndex != 0) { // Equivalent to contains(map, key)

            uint256 toDeleteIndex = keyIndex - 1;
            uint256 lastIndex = map._entries.length - 1;


            MapEntry storage lastEntry = map._entries[lastIndex];

            map._entries[toDeleteIndex] = lastEntry;
            map._indexes[lastEntry._key] = toDeleteIndex + 1; // All indexes are 1-based

            map._entries.pop();

            delete map._indexes[key];

            return true;
        } else {
            return false;
        }
    }

    function _contains(Map storage map, bytes32 key) private view returns (bool) {

        return map._indexes[key] != 0;
    }

    function _length(Map storage map) private view returns (uint256) {

        return map._entries.length;
    }

    function _at(Map storage map, uint256 index) private view returns (bytes32, bytes32) {

        require(map._entries.length > index, "EnumerableMap: index out of bounds");

        MapEntry storage entry = map._entries[index];
        return (entry._key, entry._value);
    }

    function _get(Map storage map, bytes32 key) private view returns (bytes32) {

        return _get(map, key, "EnumerableMap: nonexistent key");
    }

    function _get(Map storage map, bytes32 key, string memory errorMessage) private view returns (bytes32) {

        uint256 keyIndex = map._indexes[key];
        require(keyIndex != 0, errorMessage); // Equivalent to contains(map, key)
        return map._entries[keyIndex - 1]._value; // All indexes are 1-based
    }


    struct UintToAddressMap {
        Map _inner;
    }

    function set(UintToAddressMap storage map, uint256 key, address value) internal returns (bool) {

        return _set(map._inner, bytes32(key), bytes32(uint256(value)));
    }

    function remove(UintToAddressMap storage map, uint256 key) internal returns (bool) {

        return _remove(map._inner, bytes32(key));
    }

    function contains(UintToAddressMap storage map, uint256 key) internal view returns (bool) {

        return _contains(map._inner, bytes32(key));
    }

    function length(UintToAddressMap storage map) internal view returns (uint256) {

        return _length(map._inner);
    }

    function at(UintToAddressMap storage map, uint256 index) internal view returns (uint256, address) {

        (bytes32 key, bytes32 value) = _at(map._inner, index);
        return (uint256(key), address(uint256(value)));
    }

    function get(UintToAddressMap storage map, uint256 key) internal view returns (address) {

        return address(uint256(_get(map._inner, bytes32(key))));
    }

    function get(UintToAddressMap storage map, uint256 key, string memory errorMessage) internal view returns (address) {

        return address(uint256(_get(map._inner, bytes32(key), errorMessage)));
    }
}



pragma solidity ^0.7.0;












contract ERC721 is Context, ERC165, IERC721, IERC721Metadata, IERC721Enumerable {

    using SafeMath for uint256;
    using Address for address;
    using EnumerableSet for EnumerableSet.UintSet;
    using EnumerableMap for EnumerableMap.UintToAddressMap;
    using Strings for uint256;

    bytes4 private constant _ERC721_RECEIVED = 0x150b7a02;

    mapping (address => EnumerableSet.UintSet) private _holderTokens;

    EnumerableMap.UintToAddressMap private _tokenOwners;

    mapping (uint256 => address) private _tokenApprovals;

    mapping (address => mapping (address => bool)) private _operatorApprovals;

    string private _name;

    string private _symbol;

    mapping (uint256 => string) private _tokenURIs;

    string private _baseURI;

    bytes4 private constant _INTERFACE_ID_ERC721 = 0x80ac58cd;

    bytes4 private constant _INTERFACE_ID_ERC721_METADATA = 0x5b5e139f;

    bytes4 private constant _INTERFACE_ID_ERC721_ENUMERABLE = 0x780e9d63;

    constructor (string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;

        _registerInterface(_INTERFACE_ID_ERC721);
        _registerInterface(_INTERFACE_ID_ERC721_METADATA);
        _registerInterface(_INTERFACE_ID_ERC721_ENUMERABLE);
    }

    function balanceOf(address owner) public view override returns (uint256) {

        require(owner != address(0), "ERC721: balance query for the zero address");

        return _holderTokens[owner].length();
    }

    function ownerOf(uint256 tokenId) public view override returns (address) {

        return _tokenOwners.get(tokenId, "ERC721: owner query for nonexistent token");
    }

    function name() public view override returns (string memory) {

        return _name;
    }

    function symbol() public view override returns (string memory) {

        return _symbol;
    }

    function tokenURI(uint256 tokenId) public view override returns (string memory) {

        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");

        string memory _tokenURI = _tokenURIs[tokenId];

        if (bytes(_baseURI).length == 0) {
            return _tokenURI;
        }
        if (bytes(_tokenURI).length > 0) {
            return string(abi.encodePacked(_baseURI, _tokenURI));
        }
        return string(abi.encodePacked(_baseURI, tokenId.toString()));
    }

    function baseURI() public view returns (string memory) {

        return _baseURI;
    }

    function tokenOfOwnerByIndex(address owner, uint256 index) public view override returns (uint256) {

        return _holderTokens[owner].at(index);
    }

    function totalSupply() public view override returns (uint256) {

        return _tokenOwners.length();
    }

    function tokenByIndex(uint256 index) public view override returns (uint256) {

        (uint256 tokenId, ) = _tokenOwners.at(index);
        return tokenId;
    }

    function approve(address to, uint256 tokenId) public virtual override {

        address owner = ownerOf(tokenId);
        require(to != owner, "ERC721: approval to current owner");

        require(_msgSender() == owner || isApprovedForAll(owner, _msgSender()),
            "ERC721: approve caller is not owner nor approved for all"
        );

        _approve(to, tokenId);
    }

    function getApproved(uint256 tokenId) public view override returns (address) {

        require(_exists(tokenId), "ERC721: approved query for nonexistent token");

        return _tokenApprovals[tokenId];
    }

    function setApprovalForAll(address operator, bool approved) public virtual override {

        require(operator != _msgSender(), "ERC721: approve to caller");

        _operatorApprovals[_msgSender()][operator] = approved;
        emit ApprovalForAll(_msgSender(), operator, approved);
    }

    function isApprovedForAll(address owner, address operator) public view override returns (bool) {

        return _operatorApprovals[owner][operator];
    }

    function transferFrom(address from, address to, uint256 tokenId) public virtual override {

        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");

        _transfer(from, to, tokenId);
    }

    function safeTransferFrom(address from, address to, uint256 tokenId) public virtual override {

        safeTransferFrom(from, to, tokenId, "");
    }

    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory _data) public virtual override {

        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");
        _safeTransfer(from, to, tokenId, _data);
    }

    function _safeTransfer(address from, address to, uint256 tokenId, bytes memory _data) internal virtual {

        _transfer(from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, _data), "ERC721: transfer to non ERC721Receiver implementer");
    }

    function _exists(uint256 tokenId) internal view returns (bool) {

        return _tokenOwners.contains(tokenId);
    }

    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view returns (bool) {

        require(_exists(tokenId), "ERC721: operator query for nonexistent token");
        address owner = ownerOf(tokenId);
        return (spender == owner || getApproved(tokenId) == spender || isApprovedForAll(owner, spender));
    }

    function _safeMint(address to, uint256 tokenId) internal virtual {

        _safeMint(to, tokenId, "");
    }

    function _safeMint(address to, uint256 tokenId, bytes memory _data) internal virtual {

        _mint(to, tokenId);
        require(_checkOnERC721Received(address(0), to, tokenId, _data), "ERC721: transfer to non ERC721Receiver implementer");
    }

    function _mint(address to, uint256 tokenId) internal virtual {

        require(to != address(0), "ERC721: mint to the zero address");
        require(!_exists(tokenId), "ERC721: token already minted");

        _beforeTokenTransfer(address(0), to, tokenId);

        _holderTokens[to].add(tokenId);

        _tokenOwners.set(tokenId, to);

        emit Transfer(address(0), to, tokenId);
    }

    function _burn(uint256 tokenId) internal virtual {

        address owner = ownerOf(tokenId);

        _beforeTokenTransfer(owner, address(0), tokenId);

        _approve(address(0), tokenId);

        if (bytes(_tokenURIs[tokenId]).length != 0) {
            delete _tokenURIs[tokenId];
        }

        _holderTokens[owner].remove(tokenId);

        _tokenOwners.remove(tokenId);

        emit Transfer(owner, address(0), tokenId);
    }

    function _transfer(address from, address to, uint256 tokenId) internal virtual {

        require(ownerOf(tokenId) == from, "ERC721: transfer of token that is not own");
        require(to != address(0), "ERC721: transfer to the zero address");

        _beforeTokenTransfer(from, to, tokenId);

        _approve(address(0), tokenId);

        _holderTokens[from].remove(tokenId);
        _holderTokens[to].add(tokenId);

        _tokenOwners.set(tokenId, to);

        emit Transfer(from, to, tokenId);
    }

    function _setTokenURI(uint256 tokenId, string memory _tokenURI) internal virtual {

        require(_exists(tokenId), "ERC721Metadata: URI set of nonexistent token");
        _tokenURIs[tokenId] = _tokenURI;
    }

    function _setBaseURI(string memory baseURI_) internal virtual {

        _baseURI = baseURI_;
    }

    function _checkOnERC721Received(address from, address to, uint256 tokenId, bytes memory _data)
        private returns (bool)
    {

        if (!to.isContract()) {
            return true;
        }
        bytes memory returndata = to.functionCall(abi.encodeWithSelector(
            IERC721Receiver(to).onERC721Received.selector,
            _msgSender(),
            from,
            tokenId,
            _data
        ), "ERC721: transfer to non ERC721Receiver implementer");
        bytes4 retval = abi.decode(returndata, (bytes4));
        return (retval == _ERC721_RECEIVED);
    }

    function _approve(address to, uint256 tokenId) private {

        _tokenApprovals[tokenId] = to;
        emit Approval(ownerOf(tokenId), to, tokenId);
    }

    function _beforeTokenTransfer(address from, address to, uint256 tokenId) internal virtual { }

}


pragma solidity 0.7.5;




contract ERC721BridgeToken is ERC721, IBurnableMintableERC721Token {
    address public bridgeContract;

    constructor(
        string memory _name,
        string memory _symbol,
        address _bridgeContract
    ) ERC721(_name, _symbol) {
        bridgeContract = _bridgeContract;
    }

    modifier onlyBridge() {
        require(msg.sender == bridgeContract);
        _;
    }

    modifier onlyOwner() {
        require(msg.sender == bridgeContract || msg.sender == IOwnable(bridgeContract).owner());
        _;
    }

    function mint(address _to, uint256 _tokenId) external override onlyBridge {
        _safeMint(_to, _tokenId);
    }

    function burn(uint256 _tokenId) external override onlyBridge {
        _burn(_tokenId);
    }

    function setBaseURI(string calldata _baseURI) external onlyOwner {
        _setBaseURI(_baseURI);
    }

    function setBridgeContract(address _bridgeContract) external onlyOwner {
        require(_bridgeContract != address(0));
        bridgeContract = _bridgeContract;
    }

    function setTokenURI(uint256 _tokenId, string calldata _tokenURI) external override onlyOwner {
        _setTokenURI(_tokenId, _tokenURI);
    }
}


pragma solidity 0.7.5;















abstract contract BasicNFTOmnibridge is
    Initializable,
    Upgradeable,
    BridgeOperationsStorage,
    BridgedTokensRegistry,
    NativeTokensRegistry,
    NFTOmnibridgeInfo,
    NFTBridgeLimits,
    ERC721Reader,
    TokenImageStorage,
    ERC721Relayer,
    NFTMediatorBalanceStorage,
    FailedMessagesProcessor
{
    function initialize(
        address _bridgeContract,
        address _mediatorContract,
        uint256 _dailyLimit,
        uint256 _executionDailyLimit,
        uint256 _requestGasLimit,
        address _owner,
        address _image
    ) external onlyRelevantSender returns (bool) {
        require(!isInitialized());

        _setBridgeContract(_bridgeContract);
        _setMediatorContractOnOtherSide(_mediatorContract);
        _setDailyLimit(address(0), _dailyLimit);
        _setExecutionDailyLimit(address(0), _executionDailyLimit);
        _setRequestGasLimit(_requestGasLimit);
        _setOwner(_owner);
        _setTokenImage(_image);

        setInitialize();

        return isInitialized();
    }

    function isTokenRegistered(address _token) public view override returns (bool) {
        return isRegisteredAsNativeToken(_token) || nativeTokenAddress(_token) != address(0);
    }

    function deployAndHandleBridgedNFT(
        address _token,
        string calldata _name,
        string calldata _symbol,
        address _recipient,
        uint256 _tokenId,
        string calldata _tokenURI
    ) external onlyMediator {
        address bridgedToken = bridgedTokenAddress(_token);
        if (bridgedToken == address(0)) {
            string memory name = _name;
            string memory symbol = _symbol;
            if (bytes(name).length == 0) {
                require(bytes(symbol).length > 0);
                name = symbol;
            } else if (bytes(symbol).length == 0) {
                symbol = name;
            }
            bridgedToken = address(new ERC721TokenProxy(tokenImage(), _transformName(name), symbol, address(this)));
            _setTokenAddressPair(_token, bridgedToken);
            _initToken(bridgedToken);
        }

        _handleTokens(bridgedToken, false, _recipient, _tokenId);
        _setTokenURI(bridgedToken, _tokenId, _tokenURI);
    }

    function handleBridgedNFT(
        address _token,
        address _recipient,
        uint256 _tokenId,
        string calldata _tokenURI
    ) external onlyMediator {
        address token = bridgedTokenAddress(_token);

        _handleTokens(token, false, _recipient, _tokenId);
        _setTokenURI(token, _tokenId, _tokenURI);
    }

    function handleNativeNFT(
        address _token,
        address _recipient,
        uint256 _tokenId
    ) external onlyMediator {
        require(isRegisteredAsNativeToken(_token));

        _handleTokens(_token, true, _recipient, _tokenId);
    }

    function setCustomTokenAddressPair(address _nativeToken, address _bridgedToken) external onlyOwner {
        require(Address.isContract(_bridgedToken));
        require(!isTokenRegistered(_bridgedToken));
        require(bridgedTokenAddress(_nativeToken) == address(0));

        _setTokenAddressPair(_nativeToken, _bridgedToken);
        _initToken(_bridgedToken);
    }

    function fixMediatorBalance(
        address _token,
        address _receiver,
        uint256 _tokenId
    ) external onlyIfUpgradeabilityOwner {
        require(_receiver != address(0) && _receiver != mediatorContractOnOtherSide());
        require(isRegisteredAsNativeToken(_token));
        require(!mediatorOwns(_token, _tokenId));
        require(IERC721(_token).ownerOf(_tokenId) == address(this));

        _setMediatorOwns(_token, _tokenId, true);

        bytes memory data = abi.encodeWithSelector(this.handleBridgedNFT.selector, _token, _receiver, _tokenId);

        bytes32 _messageId =
            bridgeContract().requireToPassMessage(mediatorContractOnOtherSide(), data, requestGasLimit());
        _recordBridgeOperation(false, _messageId, _token, _receiver, _tokenId);
    }

    function bridgeSpecificActionsOnTokenTransfer(
        address _token,
        address _from,
        address _receiver,
        uint256 _tokenId
    ) internal override {
        require(_receiver != address(0) && _receiver != mediatorContractOnOtherSide());

        bool isKnownToken = isTokenRegistered(_token);
        bool isNativeToken = !isKnownToken || isRegisteredAsNativeToken(_token);
        bytes memory data;

        if (!isKnownToken) {
            require(IERC721(_token).ownerOf(_tokenId) == address(this));

            string memory name = _readName(_token);
            string memory symbol = _readSymbol(_token);
            string memory tokenURI = _readTokenURI(_token, _tokenId);

            require(bytes(name).length > 0 || bytes(symbol).length > 0);
            _initToken(_token);

            data = abi.encodeWithSelector(
                this.deployAndHandleBridgedNFT.selector,
                _token,
                name,
                symbol,
                _receiver,
                _tokenId,
                tokenURI
            );
        } else if (isNativeToken) {
            string memory tokenURI = _readTokenURI(_token, _tokenId);
            data = abi.encodeWithSelector(this.handleBridgedNFT.selector, _token, _receiver, _tokenId, tokenURI);
        } else {
            IBurnableMintableERC721Token(_token).burn(_tokenId);
            data = abi.encodeWithSelector(
                this.handleNativeNFT.selector,
                nativeTokenAddress(_token),
                _receiver,
                _tokenId
            );
        }

        if (isNativeToken) {
            _setMediatorOwns(_token, _tokenId, true);
        }

        bytes32 _messageId =
            bridgeContract().requireToPassMessage(mediatorContractOnOtherSide(), data, requestGasLimit());

        _recordBridgeOperation(!isKnownToken, _messageId, _token, _from, _tokenId);
    }

    function executeActionOnFixedTokens(
        bytes32 _messageId,
        address _token,
        address _recipient,
        uint256 _tokenId
    ) internal override {
        bytes32 registrationMessageId = tokenRegistrationMessageId(_token);
        if (_messageId == registrationMessageId) {
            delete uintStorage[keccak256(abi.encodePacked("dailyLimit", _token))];
            delete uintStorage[keccak256(abi.encodePacked("executionDailyLimit", _token))];
            _setTokenRegistrationMessageId(_token, bytes32(0));
        }

        _releaseToken(_token, registrationMessageId != bytes32(0), _recipient, _tokenId);
    }

    function _handleTokens(
        address _token,
        bool _isNative,
        address _recipient,
        uint256 _tokenId
    ) internal {
        require(withinExecutionLimit(_token));
        addTotalExecutedPerDay(_token);

        _releaseToken(_token, _isNative, _recipient, _tokenId);

        emit TokensBridged(_token, _recipient, _tokenId, messageId());
    }

    function _setTokenURI(
        address _token,
        uint256 _tokenId,
        string calldata _tokenURI
    ) internal {
        if (bytes(_tokenURI).length > 0) {
            IBurnableMintableERC721Token(_token).setTokenURI(_tokenId, _tokenURI);
        }
    }

    function _releaseToken(
        address _token,
        bool _isNative,
        address _recipient,
        uint256 _tokenId
    ) internal {
        if (_isNative) {
            _setMediatorOwns(_token, _tokenId, false);
            IERC721(_token).transferFrom(address(this), _recipient, _tokenId);
        } else {
            IBurnableMintableERC721Token(_token).mint(_recipient, _tokenId);
        }
    }

    function _recordBridgeOperation(
        bool _register,
        bytes32 _messageId,
        address _token,
        address _sender,
        uint256 _tokenId
    ) internal {
        require(withinLimit(_token));
        addTotalSpentPerDay(_token);

        setMessageToken(_messageId, _token);
        setMessageRecipient(_messageId, _sender);
        setMessageValue(_messageId, _tokenId);

        if (_register) {
            _setTokenRegistrationMessageId(_token, _messageId);
        }

        emit TokensBridgingInitiated(_token, _sender, _tokenId, _messageId);
    }

    function _initToken(address _token) internal {
        _setDailyLimit(_token, dailyLimit(address(0)));
        _setExecutionDailyLimit(_token, executionDailyLimit(address(0)));
    }

    function _transformName(string memory _name) internal pure virtual returns (string memory);
}


pragma solidity 0.7.5;


contract ForeignNFTOmnibridge is BasicNFTOmnibridge {
    function _transformName(string memory _name) internal pure override returns (string memory) {
        return string(abi.encodePacked(_name, " on Mainnet"));
    }
}