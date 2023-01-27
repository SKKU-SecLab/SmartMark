


pragma solidity ^0.8.0;


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


interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}


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


interface IERC721Metadata is IERC721 {


    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function tokenURI(uint256 tokenId) external view returns (string memory);

}


interface IERC1155 is IERC165 {

    event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value);

    event TransferBatch(address indexed operator, address indexed from, address indexed to, uint256[] ids, uint256[] values);

    event ApprovalForAll(address indexed account, address indexed operator, bool approved);

    event URI(string value, uint256 indexed id);

    function balanceOf(address account, uint256 id) external view returns (uint256);


    function balanceOfBatch(address[] calldata accounts, uint256[] calldata ids) external view returns (uint256[] memory);


    function setApprovalForAll(address operator, bool approved) external;


    function isApprovedForAll(address account, address operator) external view returns (bool);


    function safeTransferFrom(address from, address to, uint256 id, uint256 amount, bytes calldata data) external;


    function safeBatchTransferFrom(address from, address to, uint256[] calldata ids, uint256[] calldata amounts, bytes calldata data) external;

}


library ECDSA {

    function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {

        if (signature.length != 65) {
            revert("ECDSA: invalid signature length");
        }

        bytes32 r;
        bytes32 s;
        uint8 v;

        assembly {
            r := mload(add(signature, 0x20))
            s := mload(add(signature, 0x40))
            v := byte(0, mload(add(signature, 0x60)))
        }

        return recover(hash, v, r, s);
    }

    function recover(bytes32 hash, uint8 v, bytes32 r, bytes32 s) internal pure returns (address) {

        require(uint256(s) <= 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0, "ECDSA: invalid signature 's' value");
        require(v == 27 || v == 28, "ECDSA: invalid signature 'v' value");

        address signer = ecrecover(hash, v, r, s);
        require(signer != address(0), "ECDSA: invalid signature");

        return signer;
    }

    function toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32) {

        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }

    function toTypedDataHash(bytes32 domainSeparator, bytes32 structHash) internal pure returns (bytes32) {

        return keccak256(abi.encodePacked("\x19\x01", domainSeparator, structHash));
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

        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {

        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {

        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {

        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {

        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {

        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {

        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {

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


library Clones {

    function clone(address implementation) internal returns (address instance) {

        assembly {
            let ptr := mload(0x40)
            mstore(ptr, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
            mstore(add(ptr, 0x14), shl(0x60, implementation))
            mstore(add(ptr, 0x28), 0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000)
            instance := create(0, ptr, 0x37)
        }
        require(instance != address(0), "ERC1167: create failed");
    }

    function cloneDeterministic(address implementation, bytes32 salt) internal returns (address instance) {

        assembly {
            let ptr := mload(0x40)
            mstore(ptr, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
            mstore(add(ptr, 0x14), shl(0x60, implementation))
            mstore(add(ptr, 0x28), 0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000)
            instance := create2(0, ptr, 0x37, salt)
        }
        require(instance != address(0), "ERC1167: create2 failed");
    }

    function predictDeterministicAddress(address implementation, bytes32 salt, address deployer) internal pure returns (address predicted) {

        assembly {
            let ptr := mload(0x40)
            mstore(ptr, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
            mstore(add(ptr, 0x14), shl(0x60, implementation))
            mstore(add(ptr, 0x28), 0x5af43d82803e903d91602b57fd5bf3ff00000000000000000000000000000000)
            mstore(add(ptr, 0x38), shl(0x60, deployer))
            mstore(add(ptr, 0x4c), salt)
            mstore(add(ptr, 0x6c), keccak256(ptr, 0x37))
            predicted := keccak256(add(ptr, 0x37), 0x55)
        }
    }

    function predictDeterministicAddress(address implementation, bytes32 salt) internal view returns (address predicted) {

        return predictDeterministicAddress(implementation, salt, address(this));
    }
}



interface ENSRegistryOwnerI {

    function owner(bytes32 node) external view returns (address);

}

interface ENSReverseRegistrarI {

    event NameChanged(bytes32 indexed node, string name);
    function setName(string calldata name) external returns (bytes32);

}



interface BridgeDataI {


    event AddressChanged(string name, address previousAddress, address newAddress);
    event ConnectedChainChanged(string previousConnectedChainName, string newConnectedChainName);
    event TokenURIBaseChanged(string previousTokenURIBase, string newTokenURIBase);
    event TokenSunsetAnnounced(uint256 indexed timestamp);

    function connectedChainName() external view returns (string memory);


    function ownChainName() external view returns (string memory);


    function tokenURIBase() external view returns (string memory);


    function tokenSunsetTimestamp() external view returns (uint256);


    function setTokenSunsetTimestamp(uint256 _timestamp) external;


    function setAddress(string memory name, address newAddress) external;


    function getAddress(string memory name) external view returns (address);

}




interface BridgeHeadI {


    event TokenDepositedERC721(address indexed tokenAddress, uint256 indexed tokenId, address indexed otherChainRecipient);

    event TokenDepositedERC1155Batch(address indexed tokenAddress, uint256[] tokenIds, uint256[] amounts, address indexed otherChainRecipient);

    event TokenExitedERC721(address indexed tokenAddress, uint256 indexed tokenId, address indexed recipient);

    event TokenExitedERC1155Batch(address indexed tokenAddress, uint256[] tokenIds, uint256[] amounts, address indexed recipient);

    event BridgedTokenDeployed(address indexed ownAddress, address indexed foreignAddress);

    function bridgeData() external view returns (BridgeDataI);


    function bridgeControl() external view returns (address);


    function tokenHolder() external view returns (TokenHolderI);


    function connectedChainName() external view returns (string memory);


    function ownChainName() external view returns (string memory);


    function minSignatures() external view returns (uint256);


    function depositEnabled() external view returns (bool);


    function exitEnabled() external view returns (bool);


    function tokenDepositedERC721(address tokenAddress, uint256 tokenId, address otherChainRecipient) external;


    function tokenDepositedERC1155Batch(address tokenAddress, uint256[] calldata tokenIds, uint256[] calldata amounts, address otherChainRecipient) external;


    function depositERC721(address tokenAddress, uint256 tokenId, address otherChainRecipient) external;


    function depositERC1155Batch(address tokenAddress, uint256[] calldata tokenIds, uint256[] calldata amounts, address otherChainRecipient) external;


    function processExitData(bytes memory _payload, uint256 _expirationTimestamp, bytes[] memory _signatures, uint256[] memory _exitNonces) external;


    function predictTokenAddress(string memory _prototypeName, address _foreignAddress) external view returns (address);


    function exitERC721(address _tokenAddress, uint256 _tokenId, address _recipient, address _foreignAddress, bool _allowMinting, string calldata _symbol, bytes calldata _propertiesData) external;


    function exitERC721Existing(address _tokenAddress, uint256 _tokenId, address _recipient) external;


    function exitERC1155Batch(address _tokenAddress, uint256[] memory _tokenIds, uint256[] memory _amounts, address _recipient, address _foreignAddress, address _tokenSource) external;


    function exitERC1155BatchFromHolder(address _tokenAddress, uint256[] memory _tokenIds, uint256[] memory _amounts, address _recipient) external;


    function callAsHolder(address payable _remoteAddress, bytes calldata _callPayload) external payable;


}


interface IERC721Receiver {

    function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data) external returns (bytes4);

}


interface IERC1155Receiver is IERC165 {


    function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes calldata data
    )
        external
        returns(bytes4);


    function onERC1155BatchReceived(
        address operator,
        address from,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    )
        external
        returns(bytes4);

}




interface TokenHolderI is IERC165, IERC721Receiver, IERC1155Receiver {


    function bridgeData() external view returns (BridgeDataI);


    function bridgeHead() external view returns (BridgeHeadI);


    function externalCall(address payable _remoteAddress, bytes calldata _callPayload) external payable;


    function safeTransferERC721(address _tokenAddress, uint256 _tokenId, address _to) external;


    function safeTransferERC1155Batch(address _tokenAddress, uint256[] memory _tokenIds, uint256[] memory _amounts, address _to) external;


}




interface ERC721ExistsI is IERC721 {


    function exists(uint256 tokenId) external view returns (bool);


}




interface ERC721MintableI is IERC721 {


    function safeMint(address to, uint256 tokenId) external;


}

interface ERC721DataMintableI is IERC721 {


    function safeMintWithData(address to, uint256 tokenId, bytes memory propdata) external;


}

interface ERC721SettablePropertiesI is IERC721 {


    function setPropertiesFromData(uint256 tokenId, bytes memory propdata) external;


}




interface CollectionsI is IERC721 {


    event NewCollection(address indexed owner, address collectionAddress);

    event KilledCollection(address indexed owner, address collectionAddress);

    function create(address _notificationContract,
                    string calldata _ensName,
                    string calldata _ensSubdomainName,
                    address _ensSubdomainRegistrarAddress,
                    address _ensReverseRegistrarAddress)
    external payable
    returns (address);


    function createFor(address payable _newOwner,
                       address _notificationContract,
                       string calldata _ensName,
                       string calldata _ensSubdomainName,
                       address _ensSubdomainRegistrarAddress,
                       address _ensReverseRegistrarAddress)
    external payable
    returns (address);


    function burn(uint256 tokenId) external;


    function exists(uint256 tokenId) external view returns (bool);


    function isApprovedOrOwnerOnCollection(address spender, address collectionAddr) external view returns (bool);


    function collectionAddress(uint256 tokenId) external view returns (address);


    function tokenIdForCollection(address collectionAddr) external view returns (uint256);


    function collectionExists(address collectionAddr) external view returns (bool);


    function collectionOwner(address collectionAddr) external view returns (address);


    function collectionOfOwnerByIndex(address owner, uint256 index) external view returns (address);


}







interface CollectionI is IERC165, IERC721Receiver, IERC1155Receiver  {


    event NotificationContractTransferred(address indexed previousNotificationContract, address indexed newNotificationContract);

    event AssetAdded(address tokenAddress, uint256 tokenId);

    event AssetRemoved(address tokenAddress, uint256 tokenId);

    event CollectionDestroyed(address operator);

    function isPrototype() external view returns (bool);


    function collections() external view returns (CollectionsI);


    function notificationContract() external view returns (address);


    function initialRegister(address _notificationContract,
                             string calldata _ensName,
                             string calldata _ensSubdomainName,
                             address _ensSubdomainRegistrarAddress,
                             address _ensReverseRegistrarAddress)
    external;


    function transferNotificationContract(address _newNotificationContract) external;


    function ownerAddress() external view returns (address);


    function ownsAsset(address _tokenAddress, uint256 _tokenId) external view returns(bool);


    function ownedAssetsCount() external view returns (uint256);


    function syncAssetOwnership(address _tokenAddress, uint256 _tokenId) external;


    function safeTransferTo(address _tokenAddress, uint256 _tokenId, address _to) external;


    function safeTransferTo(address _tokenAddress, uint256 _tokenId, address _to, uint256 _value) external;


    function destroy() external;


    function externalCall(address payable _remoteAddress, bytes calldata _callPayload) external payable;


    function registerENS(string calldata _name, address _registrarAddress) external;


    function registerReverseENS(address _reverseRegistrarAddress, string calldata _name) external;

}




interface IERC721Enumerable is IERC721 {


    function totalSupply() external view returns (uint256);


    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256 tokenId);


    function tokenByIndex(uint256 index) external view returns (uint256);

}








interface BridgedERC721I is IERC721Metadata, IERC721Enumerable, ERC721ExistsI, ERC721MintableI {


    event SignedTransfer(address operator, address indexed from, address indexed to, uint256 indexed tokenId, uint256 signedTransferNonce);

    function isPrototype() external view returns (bool);


    function bridgeData() external view returns (BridgeDataI);


    function initialRegister(address _bridgeDataAddress,
                             string memory _symbol, string memory _name,
                             string memory _orginalChainName, address _originalChainAddress) external;


    function baseURI() external view returns (string memory);


    function originalChainName() external view returns (string memory);


    function originalChainAddress() external view returns (address);


    function transferEnabled() external view returns (bool);


    function signedTransferNonce(address account) external view returns (uint256);


    function signedTransfer(uint256 tokenId, address to, bytes memory signature) external;


    function signedTransferWithOperator(uint256 tokenId, address to, bytes memory signature) external;


}



interface IERC1155MetadataURI is IERC1155 {

    function uri(uint256 id) external view returns (string memory);

}




interface ERC1155MintableI is IERC1155 {


    function mint(address account, uint256 id, uint256 amount) external;


    function mintBatch(address to, uint256[] memory ids, uint256[] memory amounts) external;


}






interface BridgedERC1155I is IERC1155MetadataURI, ERC1155MintableI {


    event SignedBatchTransfer(address operator, address indexed from, address indexed to, uint256[] ids, uint256[] amounts, uint256 signedTransferNonce);

    function isPrototype() external view returns (bool);


    function bridgeData() external view returns (BridgeDataI);


    function initialRegister(address _bridgeDataAddress, string memory _orginalChainName, address _originalChainAddress) external;


    function originalChainName() external view returns (string memory);


    function originalChainAddress() external view returns (address);


    function signedTransferNonce(address account) external view returns (uint256);


    function transferEnabled() external view returns (bool);


    function signedBatchTransfer(address from, address to, uint256[] memory ids, uint256[] memory amounts, bytes memory signature) external;


    function signedBatchTransferWithOperator(address from, address to, uint256[] memory ids, uint256[] memory amounts, bytes memory signature) external;


}


















contract BridgeHead is BridgeHeadI {

    using Address for address;

    BridgeDataI public override bridgeData;

    uint256 public depositSunsetTimestamp;

    mapping(address => bool) public tokenHolderEquivalent;

    uint256 public override minSignatures;

    mapping(address => bool) public allowedSigner;

    mapping(address => mapping(uint256 => bool)) public exitNonceUsed;

    event BridgeDataChanged(address indexed previousBridgeData, address indexed newBridgeData);
    event MinSignaturesSet(uint256 minSignatures);
    event DepositSunsetAnnounced(uint256 timestamp);
    event AllowedSignerSet(address indexed signerAddress, bool enabled);
    event TokenHolderEquivalentSet(address indexed holderAddress, bool enabled);

    constructor(address _bridgeDataAddress, uint256 _minSignatures)
    {
        bridgeData = BridgeDataI(_bridgeDataAddress);
        require(address(bridgeData) != address(0x0), "You need to provide an actual bridge data contract.");
        minSignatures = _minSignatures;
        require(minSignatures > 0, "At least one signature has to be required.");
    }

    modifier onlyBridgeControl()
    {

        require(msg.sender == bridgeData.getAddress("bridgeControl"), "bridgeControl key required for this function.");
        _;
    }

    modifier onlySelfOrBC()
    {

        require(msg.sender == address(this) || msg.sender == bridgeData.getAddress("bridgeControl"),
                "Signed exit data or bridgeControl key required.");
        _;
    }

    modifier onlyTokenAssignmentControl() {

        require(msg.sender == bridgeData.getAddress("tokenAssignmentControl"), "tokenAssignmentControl key required for this function.");
        _;
    }

    modifier onlyTokenHolder() {

        require(msg.sender == bridgeData.getAddress("tokenHolder"), "Only token holder can call this function.");
        _;
    }

    modifier requireDepositEnabled() {

        require(depositEnabled() == true, "This call only works when deposits are enabled.");
        _;
    }

    modifier requireExitEnabled() {

        require(exitEnabled() == true, "This call only works when exits are enabled.");
        _;
    }


    function setBridgeData(BridgeDataI _newBridgeData)
    external
    onlyBridgeControl
    {

        require(address(_newBridgeData) != address(0x0), "You need to provide an actual bridge data contract.");
        emit BridgeDataChanged(address(bridgeData), address(_newBridgeData));
        bridgeData = _newBridgeData;
    }

    function setMinSignatures(uint256 _newMinSignatures)
    public
    onlyBridgeControl
    {

        require(_newMinSignatures > 0, "At least one signature has to be required.");
        minSignatures = _newMinSignatures;
        emit MinSignaturesSet(minSignatures);
    }

    function setDepositSunsetTimestamp(uint256 _timestamp)
    public
    onlyBridgeControl
    {

        depositSunsetTimestamp = _timestamp;
        emit DepositSunsetAnnounced(_timestamp);
    }

    function setTokenSunsetTimestamp(uint256 _timestamp)
    public
    onlyBridgeControl
    {

        bridgeData.setTokenSunsetTimestamp(_timestamp);
    }

    function setAllSunsetTimestamps(uint256 _timestamp)
    public
    onlyBridgeControl
    {

        setDepositSunsetTimestamp(_timestamp);
        bridgeData.setTokenSunsetTimestamp(_timestamp);
    }

    function setAllowedSigners(address[] memory _signerAddresses, bool _enabled)
    public
    onlyBridgeControl
    {

        uint256 addrcount = _signerAddresses.length;
        for (uint256 i = 0; i < addrcount; i++) {
            allowedSigner[_signerAddresses[i]] = _enabled;
            emit AllowedSignerSet(_signerAddresses[i], _enabled);
        }
    }

    function setTokenHolderEquivalent(address[] memory _holderAddresses, bool _enabled)
    public
    onlyBridgeControl
    {

        uint256 addrcount = _holderAddresses.length;
        for (uint256 i = 0; i < addrcount; i++) {
            tokenHolderEquivalent[_holderAddresses[i]] = _enabled;
            emit TokenHolderEquivalentSet(_holderAddresses[i], _enabled);
        }
    }

    function bridgeControl()
    public view override
    returns (address) {

        return bridgeData.getAddress("bridgeControl");
    }

    function tokenHolder()
    public view override
    returns (TokenHolderI) {

        return TokenHolderI(bridgeData.getAddress("tokenHolder"));
    }

    function connectedChainName()
    public view override
    returns (string memory) {

        return bridgeData.connectedChainName();
    }

    function ownChainName()
    public view override
    returns (string memory) {

        return bridgeData.ownChainName();
    }

    function depositEnabled()
    public view override
    returns (bool)
    {

        return (bridgeData.getAddress("tokenHolder") != address(0x0)) && (depositSunsetTimestamp == 0 || depositSunsetTimestamp > block.timestamp);
    }

    function exitEnabled()
    public view override
    returns (bool)
    {

        return minSignatures > 0 && bridgeData.getAddress("tokenHolder") != address(0x0);
    }


    function tokenDepositedERC721(address _tokenAddress, uint256 _tokenId, address _otherChainRecipient)
    external override
    onlyTokenHolder
    requireDepositEnabled
    {

        emit TokenDepositedERC721(_tokenAddress, _tokenId, _otherChainRecipient);
    }

    function tokenDepositedERC1155Batch(address _tokenAddress, uint256[] calldata _tokenIds, uint256[] calldata _amounts, address _otherChainRecipient)
    external override
    onlyTokenHolder
    requireDepositEnabled
    {

        emit TokenDepositedERC1155Batch(_tokenAddress, _tokenIds, _amounts, _otherChainRecipient);
    }

    function depositERC721(address _tokenAddress, uint256 _tokenId, address _otherChainRecipient)
    external override
    requireDepositEnabled
    {

        IERC721(_tokenAddress).safeTransferFrom(msg.sender, bridgeData.getAddress("tokenHolder"), _tokenId, abi.encode(_otherChainRecipient));
    }

    function depositERC1155Batch(address _tokenAddress, uint256[] calldata _tokenIds, uint256[] calldata _amounts, address _otherChainRecipient)
    external override
    requireDepositEnabled
    {

        IERC1155(_tokenAddress).safeBatchTransferFrom(msg.sender, bridgeData.getAddress("tokenHolder"), _tokenIds, _amounts, abi.encode(_otherChainRecipient));
    }


    function processExitData(bytes memory _payload, uint256 _expirationTimestamp, bytes[] memory _signatures, uint256[] memory _exitNonces)
    external override
    requireExitEnabled
    {

        require(_payload.length >= 4, "Payload is too short.");
        require(_expirationTimestamp > block.timestamp, "Message is expired.");
        uint256 sigCount = _signatures.length;
        require(sigCount == _exitNonces.length, "Both input arrays need to be the same length.");
        require(sigCount >= minSignatures, "Need to have enough signatures.");
        address lastCheckedAddr;
        for (uint256 i = 0; i < sigCount; i++) {
            require(_signatures[i].length == 65, "Signature has wrong length.");
            bytes32 data = keccak256(abi.encodePacked(address(this), block.chainid, _exitNonces[i], _expirationTimestamp, _payload));
            bytes32 hash = ECDSA.toEthSignedMessageHash(data);
            address signer = ECDSA.recover(hash, _signatures[i]);
            require(allowedSigner[signer], "Signature does not match allowed signer.");
            require(uint160(lastCheckedAddr) < uint160(signer), "Signers need ascending order and no repeats.");
            lastCheckedAddr = signer;
            require(exitNonceUsed[signer][_exitNonces[i]] == false, "Unable to replay exit message.");
            exitNonceUsed[signer][_exitNonces[i]] = true;
        }
        address(this).functionCall(_payload);
    }

    function predictTokenAddress(string memory _prototypeName, address _foreignAddress)
    public view override
    returns (address)
    {

        bytes32 cloneSalt = bytes32(uint256(uint160(_foreignAddress)));
        address prototypeAddress = bridgeData.getAddress(_prototypeName);
        return Clones.predictDeterministicAddress(prototypeAddress, cloneSalt);
    }

    function exitERC721(address _tokenAddress, uint256 _tokenId, address _recipient, address _foreignAddress, bool _allowMinting, string memory _symbol, bytes memory _propertiesData)
    public override
    onlySelfOrBC
    requireExitEnabled
    {

        require(_tokenAddress != address(0) || _foreignAddress != address(0), "Either foreign or native token address needs to be given.");
        if (_tokenAddress == address(0)) {
            require(_allowMinting, "Minting needed for new token.");
            bytes32 cloneSalt = bytes32(uint256(uint160(_foreignAddress)));
            address prototypeERC721Address = bridgeData.getAddress("ERC721Prototype");
            _tokenAddress = Clones.predictDeterministicAddress(prototypeERC721Address, cloneSalt);
            if (!_tokenAddress.isContract()) {
                address newInstance = Clones.cloneDeterministic(prototypeERC721Address, cloneSalt);
                require(newInstance == _tokenAddress, "Error deploying new token.");
                BridgedERC721I(_tokenAddress).initialRegister(
                    address(bridgeData), _symbol,
                    string(abi.encodePacked("Bridged ", _symbol, " (from ", connectedChainName(), ")")),
                    connectedChainName(), _foreignAddress);
                emit BridgedTokenDeployed(_tokenAddress, _foreignAddress);
            }
        }
        IERC721 token = IERC721(_tokenAddress);
        if (_allowMinting && !ERC721ExistsI(_tokenAddress).exists(_tokenId)) {
            if (_propertiesData.length > 0) {
                ERC721DataMintableI(_tokenAddress).safeMintWithData(_recipient, _tokenId, _propertiesData);
            }
            else {
                ERC721MintableI(_tokenAddress).safeMint(_recipient, _tokenId);
            }
        }
        else {
            address currentOwner = token.ownerOf(_tokenId);
            if (_propertiesData.length > 0) {
                ERC721SettablePropertiesI(_tokenAddress).setPropertiesFromData(_tokenId, _propertiesData);
            }
            if (currentOwner == bridgeData.getAddress("tokenHolder")) {
                tokenHolder().safeTransferERC721(_tokenAddress, _tokenId, _recipient);
            }
            else if (tokenHolderEquivalent[currentOwner] == true) {
                token.safeTransferFrom(currentOwner, _recipient, _tokenId);
            }
            else if (currentOwner.isContract() &&
                     (IERC165(currentOwner).supportsInterface(type(CollectionI).interfaceId) ||
                      ERC721ExistsI(bridgeData.getAddress("Collections")).exists(uint256(uint160(currentOwner)))) &&
                     CollectionI(currentOwner).ownerAddress() == address(tokenHolder())) {
                callAsHolder(payable(currentOwner), abi.encodeWithSignature("safeTransferTo(address,uint256,address)", _tokenAddress, _tokenId, _recipient));
            }
            else {
                revert("Bridge has no access to this token.");
            }
        }
        emit TokenExitedERC721(_tokenAddress, _tokenId, _recipient);
    }

    function exitERC721Existing(address _tokenAddress, uint256 _tokenId, address _recipient)
    external override
    {

        exitERC721(_tokenAddress, _tokenId, _recipient, address(0), false, "", "");
    }

    function exitERC1155Batch(address _tokenAddress, uint256[] memory _tokenIds, uint256[] memory _amounts, address _recipient, address _foreignAddress, address _tokenSource)
    public override
    onlySelfOrBC
    requireExitEnabled
    {

        require(_tokenAddress != address(0) || _foreignAddress != address(0), "Either foreign or native token address needs to be given.");
        if (_tokenAddress == address(0)) {
            require(_tokenSource == address(0), "Minting source needed for new token.");
            bytes32 cloneSalt = bytes32(uint256(uint160(_foreignAddress)));
            address prototypeERC1155Address = bridgeData.getAddress("ERC1155Prototype");
            _tokenAddress = Clones.predictDeterministicAddress(prototypeERC1155Address, cloneSalt);
            if (!_tokenAddress.isContract()) {
                address newInstance = Clones.cloneDeterministic(prototypeERC1155Address, cloneSalt);
                require(newInstance == _tokenAddress, "Error deploying new token.");
                BridgedERC1155I(_tokenAddress).initialRegister(address(bridgeData), connectedChainName(), _foreignAddress);
                emit BridgedTokenDeployed(_tokenAddress, _foreignAddress);
            }
        }
        if (_tokenSource == address(0)) {
            ERC1155MintableI(_tokenAddress).mintBatch(_recipient, _tokenIds, _amounts);
        }
        else if (_tokenSource == bridgeData.getAddress("tokenHolder")) {
            tokenHolder().safeTransferERC1155Batch(_tokenAddress, _tokenIds, _amounts, _recipient);
        }
        else if (tokenHolderEquivalent[_tokenSource] == true) {
            IERC1155(_tokenAddress).safeBatchTransferFrom(_tokenSource, _recipient, _tokenIds, _amounts, "");
        }
        else if (_tokenSource.isContract() &&
                 (IERC165(_tokenSource).supportsInterface(type(CollectionI).interfaceId) ||
                 ERC721ExistsI(bridgeData.getAddress("Collections")).exists(uint256(uint160(_tokenSource)))) &&
                 CollectionI(_tokenSource).ownerAddress() == address(tokenHolder())) {
            uint256 batchcount = _tokenIds.length;
            require(batchcount == _amounts.length, "Both token IDs and amounts need to be the same length.");
            for (uint256 i = 0; i < batchcount; i++) {
                callAsHolder(payable(_tokenSource), abi.encodeWithSignature("safeTransferTo(address,uint256,address,uint256)", _tokenAddress, _tokenIds[i], _recipient, _amounts[i]));
            }
        }
        else {
            revert("Bridge has no access to this token.");
        }
        emit TokenExitedERC1155Batch(_tokenAddress, _tokenIds, _amounts, _recipient);
    }

    function exitERC1155BatchFromHolder(address _tokenAddress, uint256[] memory _tokenIds, uint256[] memory _amounts, address _recipient)
    external override
    {

        exitERC1155Batch(_tokenAddress, _tokenIds, _amounts, _recipient, address(0), bridgeData.getAddress("tokenHolder"));
    }


    function callAsHolder(address payable _remoteAddress, bytes memory _callPayload)
    public override payable
    onlySelfOrBC
    {

        tokenHolder().externalCall(_remoteAddress, _callPayload);
    }


    function registerReverseENS(address _reverseRegistrarAddress, string calldata _name)
    external
    onlyTokenAssignmentControl
    {

        require(_reverseRegistrarAddress != address(0), "need a valid reverse registrar");
        ENSReverseRegistrarI(_reverseRegistrarAddress).setName(_name);
    }


    function rescueToken(address _foreignToken, address _to)
    external
    onlyTokenAssignmentControl
    {

        IERC20 erc20Token = IERC20(_foreignToken);
        erc20Token.transfer(_to, erc20Token.balanceOf(address(this)));
    }

    function approveNFTrescue(IERC721 _foreignNFT, address _to)
    external
    onlyTokenAssignmentControl
    {

        _foreignNFT.setApprovalForAll(_to, true);
    }

}