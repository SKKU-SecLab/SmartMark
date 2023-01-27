


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




abstract contract ERC165 is IERC165 {
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
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



interface ENSRegistryOwnerI {

    function owner(bytes32 node) external view returns (address);

}

interface ENSReverseRegistrarI {

    event NameChanged(bytes32 indexed node, string name);
    function setName(string calldata name) external returns (bytes32);

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








interface TokenHolderI is IERC165, IERC721Receiver, IERC1155Receiver {


    function bridgeData() external view returns (BridgeDataI);


    function bridgeHead() external view returns (BridgeHeadI);


    function externalCall(address payable _remoteAddress, bytes calldata _callPayload) external payable;


    function safeTransferERC721(address _tokenAddress, uint256 _tokenId, address _to) external;


    function safeTransferERC1155Batch(address _tokenAddress, uint256[] memory _tokenIds, uint256[] memory _amounts, address _to) external;


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











contract TokenHolder is ERC165, TokenHolderI {

    using Address for address;
    using Address for address payable;

    BridgeDataI public override bridgeData;

    event BridgeDataChanged(address indexed previousBridgeData, address indexed newBridgeData);

    constructor(address _bridgeDataAddress)
    {
        bridgeData = BridgeDataI(_bridgeDataAddress);
    }

    modifier onlyBridgeControl()
    {

        require(msg.sender == bridgeData.getAddress("bridgeControl"), "bridgeControl key required for this function.");
        _;
    }

    modifier onlyBridge()
    {

        require(msg.sender == bridgeData.getAddress("bridgeControl") || msg.sender == bridgeData.getAddress("bridgeHead"), "bridgeControl key or bridge head required for this function.");
        _;
    }

    modifier onlyTokenAssignmentControl() {

        require(msg.sender == bridgeData.getAddress("tokenAssignmentControl"), "tokenAssignmentControl key required for this function.");
        _;
    }


    function supportsInterface(bytes4 interfaceId)
    public view override(ERC165, IERC165)
    returns (bool)
    {

        return interfaceId == type(IERC721Receiver).interfaceId ||
               interfaceId == type(IERC1155Receiver).interfaceId ||
               super.supportsInterface(interfaceId);
    }


    function setBridgeData(BridgeDataI _newBridgeData)
    external
    onlyBridgeControl
    {

        require(address(_newBridgeData) != address(0x0), "You need to provide an actual bridge data contract.");
        emit BridgeDataChanged(address(bridgeData), address(_newBridgeData));
        bridgeData = _newBridgeData;
    }

    function bridgeHead()
    public view override
    returns (BridgeHeadI) {

        return BridgeHeadI(bridgeData.getAddress("bridgeHead"));
    }


    function onERC721Received(address _operator, address _from, uint256 _tokenId, bytes memory _data)
    external override
    returns (bytes4)
    {

        address otherChainRecipient = getRecipient(_operator, _from, _data);
        address _tokenAddress = msg.sender;
        require(IERC165(_tokenAddress).supportsInterface(type(IERC721).interfaceId), "onERC721Received caller needs to implement ERC721!");
        if (_tokenAddress == bridgeData.getAddress("Collections")) {
            CollectionI coll = CollectionI(CollectionsI(_tokenAddress).collectionAddress(_tokenId));
            if (coll.notificationContract() != address(0)) {
                coll.transferNotificationContract(address(0));
            }
        }
        bridgeHead().tokenDepositedERC721(_tokenAddress, _tokenId, otherChainRecipient);
        return this.onERC721Received.selector;
    }

    function onERC1155Received(address _operator, address _from, uint256 _id, uint256 _value, bytes calldata _data)
    external override
    returns(bytes4)
    {

        address otherChainRecipient = getRecipient(_operator, _from, _data);
        address _tokenAddress = msg.sender;
        require(IERC165(_tokenAddress).supportsInterface(type(IERC1155).interfaceId), "onERC1155Received caller needs to implement ERC1155!");
        uint256[] memory tokenIds = new uint256[](1);
        tokenIds[0] = _id;
        uint256[] memory amounts = new uint256[](1);
        amounts[0] = _value;
        bridgeHead().tokenDepositedERC1155Batch(_tokenAddress, tokenIds, amounts, otherChainRecipient);
        return this.onERC1155Received.selector;
    }

    function onERC1155BatchReceived(address _operator, address _from, uint256[] calldata _ids, uint256[] calldata _values, bytes calldata _data)
    external override
    returns(bytes4)
    {

        address otherChainRecipient = getRecipient(_operator, _from, _data);
        address _tokenAddress = msg.sender;
        require(IERC165(_tokenAddress).supportsInterface(type(IERC1155).interfaceId), "onERC1155BatchReceived caller needs to implement ERC1155!");
        bridgeHead().tokenDepositedERC1155Batch(_tokenAddress, _ids, _values, otherChainRecipient);
        return this.onERC1155BatchReceived.selector;
    }

    function getRecipient(address _operator, address _from, bytes memory _data)
    internal view
    returns(address)
    {

        if (_operator == bridgeData.getAddress("bridgeHead") && _data.length > 0) {
            return abi.decode(_data, (address));
        }
        if (_from.isContract()) {
            revert("Deposit contract-owned token via bridge head!");
        }
        if (_from == address(0)) {
            revert("Can't mint into bridge directly!");
        }
        return _from;
    }


    function externalCall(address payable _remoteAddress, bytes calldata _callPayload)
    external override payable
    onlyBridge
    {

        require(_remoteAddress != address(this) && _remoteAddress != bridgeData.getAddress("bridgeHead"), "No calls to bridge via this mechanism!");
        if (_callPayload.length > 0) {
            _remoteAddress.functionCallWithValue(_callPayload, msg.value);
        }
        else {
            _remoteAddress.sendValue(msg.value);
        }
    }


    function safeTransferERC721(address _tokenAddress, uint256 _tokenId, address _to)
    public override
    onlyBridge
    {

        IERC721(_tokenAddress).safeTransferFrom(address(this), _to, _tokenId);
    }

    function safeTransferERC1155Batch(address _tokenAddress, uint256[] memory _tokenIds, uint256[] memory _amounts, address _to)
    public override
    onlyBridge
    {

        IERC1155(_tokenAddress).safeBatchTransferFrom(address(this), _to, _tokenIds, _amounts, "");
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