

pragma solidity >=0.4.23 <0.5.0 >=0.4.24 <0.5.0;


contract IAuthority {

    function canCall(
        address src, address dst, bytes4 sig
    ) public view returns (bool);

}



contract DSAuthEvents {

    event LogSetAuthority (address indexed authority);
    event LogSetOwner     (address indexed owner);
}

contract DSAuth is DSAuthEvents {

    IAuthority   public  authority;
    address      public  owner;

    constructor() public {
        owner = msg.sender;
        emit LogSetOwner(msg.sender);
    }

    function setOwner(address owner_)
        public
        auth
    {

        owner = owner_;
        emit LogSetOwner(owner);
    }

    function setAuthority(IAuthority authority_)
        public
        auth
    {

        authority = authority_;
        emit LogSetAuthority(authority);
    }

    modifier auth {

        require(isAuthorized(msg.sender, msg.sig), "ds-auth-unauthorized");
        _;
    }

    modifier onlyOwner() {

        require(msg.sender == owner);
        _;
    }

    function isAuthorized(address src, bytes4 sig) internal view returns (bool) {

        if (src == owner) {
            return true;
        } else if (authority == IAuthority(0)) {
            return false;
        } else {
            return authority.canCall(src, this, sig);
        }
    }
}




contract PausableDSAuth is DSAuth {

  event Pause();
  event Unpause();

  bool public paused = false;


  modifier whenNotPaused() {

    require(!paused);
    _;
  }

  modifier whenPaused() {

    require(paused);
    _;
  }

  function pause() public onlyOwner whenNotPaused {

    paused = true;
    emit Pause();
  }

  function unpause() public onlyOwner whenPaused {

    paused = false;
    emit Unpause();
  }
}


contract SettingIds {

    bytes32 public constant CONTRACT_RING_ERC20_TOKEN = "CONTRACT_RING_ERC20_TOKEN";

    bytes32 public constant CONTRACT_KTON_ERC20_TOKEN = "CONTRACT_KTON_ERC20_TOKEN";

    bytes32 public constant CONTRACT_GOLD_ERC20_TOKEN = "CONTRACT_GOLD_ERC20_TOKEN";

    bytes32 public constant CONTRACT_WOOD_ERC20_TOKEN = "CONTRACT_WOOD_ERC20_TOKEN";

    bytes32 public constant CONTRACT_WATER_ERC20_TOKEN = "CONTRACT_WATER_ERC20_TOKEN";

    bytes32 public constant CONTRACT_FIRE_ERC20_TOKEN = "CONTRACT_FIRE_ERC20_TOKEN";

    bytes32 public constant CONTRACT_SOIL_ERC20_TOKEN = "CONTRACT_SOIL_ERC20_TOKEN";

    bytes32 public constant CONTRACT_OBJECT_OWNERSHIP = "CONTRACT_OBJECT_OWNERSHIP";

    bytes32 public constant CONTRACT_TOKEN_LOCATION = "CONTRACT_TOKEN_LOCATION";

    bytes32 public constant CONTRACT_LAND_BASE = "CONTRACT_LAND_BASE";

    bytes32 public constant CONTRACT_USER_POINTS = "CONTRACT_USER_POINTS";

    bytes32 public constant CONTRACT_INTERSTELLAR_ENCODER = "CONTRACT_INTERSTELLAR_ENCODER";

    bytes32 public constant CONTRACT_DIVIDENDS_POOL = "CONTRACT_DIVIDENDS_POOL";

    bytes32 public constant CONTRACT_TOKEN_USE = "CONTRACT_TOKEN_USE";

    bytes32 public constant CONTRACT_REVENUE_POOL = "CONTRACT_REVENUE_POOL";

    bytes32 public constant CONTRACT_BRIDGE_POOL = "CONTRACT_BRIDGE_POOL";

    bytes32 public constant CONTRACT_ERC721_BRIDGE = "CONTRACT_ERC721_BRIDGE";

    bytes32 public constant CONTRACT_PET_BASE = "CONTRACT_PET_BASE";

    bytes32 public constant UINT_AUCTION_CUT = "UINT_AUCTION_CUT";  // Denominator is 10000

    bytes32 public constant UINT_TOKEN_OFFER_CUT = "UINT_TOKEN_OFFER_CUT";  // Denominator is 10000

    bytes32 public constant UINT_REFERER_CUT = "UINT_REFERER_CUT";

    bytes32 public constant UINT_BRIDGE_FEE = "UINT_BRIDGE_FEE";

    bytes32 public constant CONTRACT_LAND_RESOURCE = "CONTRACT_LAND_RESOURCE";
}


contract IBurnableERC20 {

    function burn(address _from, uint _value) public;

}



contract IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}




contract IERC1155 is IERC165 {

    event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value);

    event TransferBatch(address indexed operator, address indexed from, address indexed to, uint256[] ids, uint256[] values);

    event ApprovalForAll(address indexed account, address indexed operator, bool approved);

    event URI(string value, uint256 indexed id);

    function balanceOf(address account, uint256 id) external view returns (uint256);


    function balanceOfBatch(address[] accounts, uint256[] ids) external view returns (uint256[] memory);


    function setApprovalForAll(address operator, bool approved) external;


    function isApprovedForAll(address account, address operator) external view returns (bool);


    function safeTransferFrom(address from, address to, uint256 id, uint256 amount, bytes data) external;


    function safeBatchTransferFrom(address from, address to, uint256[] ids, uint256[] amounts, bytes data) external;

}



contract IERC1155Receiver {


    bytes4 internal constant ERC1155_RECEIVED_VALUE = 0xf23a6e61;
    bytes4 internal constant ERC1155_BATCH_RECEIVED_VALUE = 0xbc197c81;

    function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes data
    )
        external
        returns(bytes4);


    function onERC1155BatchReceived(
        address operator,
        address from,
        uint256[] ids,
        uint256[] values,
        bytes data
    )
        external
        returns(bytes4);

}



contract IERC721 is IERC165 {


  bytes4 internal constant InterfaceId_ERC721 = 0x80ac58cd;

  bytes4 internal constant InterfaceId_ERC721Exists = 0x4f558e79;

  bytes4 internal constant InterfaceId_ERC721Enumerable = 0x780e9d63;

  bytes4 internal constant InterfaceId_ERC721Metadata = 0x5b5e139f;

  event Transfer(
    address indexed _from,
    address indexed _to,
    uint256 indexed _tokenId
  );
  event Approval(
    address indexed _owner,
    address indexed _approved,
    uint256 indexed _tokenId
  );
  event ApprovalForAll(
    address indexed _owner,
    address indexed _operator,
    bool _approved
  );

  function balanceOf(address _owner) public view returns (uint256 _balance);

  function ownerOf(uint256 _tokenId) public view returns (address _owner);

  function exists(uint256 _tokenId) public view returns (bool _exists);


  function approve(address _to, uint256 _tokenId) public;

  function getApproved(uint256 _tokenId)
    public view returns (address _operator);


  function setApprovalForAll(address _operator, bool _approved) public;

  function isApprovedForAll(address _owner, address _operator)
    public view returns (bool);


  function transferFrom(address _from, address _to, uint256 _tokenId) public;

  function safeTransferFrom(address _from, address _to, uint256 _tokenId)
    public;


  function safeTransferFrom(
    address _from,
    address _to,
    uint256 _tokenId,
    bytes _data
  )
    public;

}



contract IERC721Receiver {

  bytes4 internal constant ERC721_RECEIVED = 0x150b7a02;

  function onERC721Received(
    address _operator,
    address _from,
    uint256 _tokenId,
    bytes _data
  )
    public
    returns(bytes4);

}


contract IInterstellarEncoderV3 {

    uint256 constant CLEAR_HIGH =  0x00000000000000000000000000000000ffffffffffffffffffffffffffffffff;

    uint256 public constant MAGIC_NUMBER = 42;    // Interstellar Encoding Magic Number.
    uint256 public constant CHAIN_ID = 1; // Ethereum mainet.
    uint256 public constant CURRENT_LAND = 1; // 1 is Atlantis, 0 is NaN.

    enum ObjectClass { 
        NaN,
        LAND,
        APOSTLE,
        OBJECT_CLASS_COUNT
    }

    function registerNewObjectClass(address _objectContract, uint8 objectClass) public;


    function encodeTokenId(address _tokenAddress, uint8 _objectClass, uint128 _objectIndex) public view returns (uint256 _tokenId);


    function encodeTokenIdForObjectContract(
        address _tokenAddress, address _objectContract, uint128 _objectId) public view returns (uint256 _tokenId);


    function encodeTokenIdForOuterObjectContract(
        address _objectContract, address nftAddress, address _originNftAddress, uint128 _objectId, uint16 _producerId, uint8 _convertType) public view returns (uint256);


    function getContractAddress(uint256 _tokenId) public view returns (address);


    function getObjectId(uint256 _tokenId) public view returns (uint128 _objectId);


    function getObjectClass(uint256 _tokenId) public view returns (uint8);


    function getObjectAddress(uint256 _tokenId) public view returns (address);


    function getProducerId(uint256 _tokenId) public view returns (uint16);


    function getOriginAddress(uint256 _tokenId) public view returns (address);


}


contract IMintableERC20 {


    function mint(address _to, uint256 _value) public;

}



contract INFTAdaptor {

    function toMirrorTokenId(uint256 _originTokenId) public view returns (uint256);


    function toMirrorTokenIdAndIncrease(uint256 _originTokenId) public returns (uint256);


    function toOriginTokenId(uint256 _mirrorTokenId) public view returns (uint256);


    function approveOriginToken(address _bridge, uint256 _originTokenId) public;


    function ownerInOrigin(uint256 _originTokenId) public view returns (address);


    function cacheMirrorTokenId(uint256 _originTokenId, uint256 _mirrorTokenId) public;

}


contract IPetBase {

    function pet2TiedStatus(uint256 _mirrorTokenId) public returns (uint256, uint256);

}


contract ISettingsRegistry {

    enum SettingsValueTypes { NONE, UINT, STRING, ADDRESS, BYTES, BOOL, INT }

    function uintOf(bytes32 _propertyName) public view returns (uint256);


    function stringOf(bytes32 _propertyName) public view returns (string);


    function addressOf(bytes32 _propertyName) public view returns (address);


    function bytesOf(bytes32 _propertyName) public view returns (bytes);


    function boolOf(bytes32 _propertyName) public view returns (bool);


    function intOf(bytes32 _propertyName) public view returns (int);


    function setUintProperty(bytes32 _propertyName, uint _value) public;


    function setStringProperty(bytes32 _propertyName, string _value) public;


    function setAddressProperty(bytes32 _propertyName, address _value) public;


    function setBytesProperty(bytes32 _propertyName, bytes _value) public;


    function setBoolProperty(bytes32 _propertyName, bool _value) public;


    function setIntProperty(bytes32 _propertyName, int _value) public;


    function getValueTypeOf(bytes32 _propertyName) public view returns (uint /* SettingsValueTypes */ );


    event ChangeProperty(bytes32 indexed _propertyName, uint256 _type);
}




contract ERC721BridgeV2 is SettingIds, PausableDSAuth, IERC721Receiver, IERC1155Receiver {


    bool private singletonLock = false;

    ISettingsRegistry public registry;


    mapping(address => address) public originNFT2Adaptor;

    mapping(uint256 => uint256) public mirrorId2OriginId;

    mapping(uint256 => uint256) public mirrorId2OriginId1155;


    event SwapIn(address originContract, uint256 originTokenId, uint256 mirrorTokenId, address owner);
    event SwapOut(address originContract, uint256 originTokenId, uint256 mirrorTokenId, address owner);

    function registerAdaptor(address _originNftAddress, address _erc721Adaptor) public whenNotPaused onlyOwner {

        originNFT2Adaptor[_originNftAddress] = _erc721Adaptor;
    }

    function swapOut721(uint256 _mirrorTokenId) public  {

        IInterstellarEncoderV3 interstellarEncoder = IInterstellarEncoderV3(registry.addressOf(SettingIds.CONTRACT_INTERSTELLAR_ENCODER));
        address nftContract = interstellarEncoder.getOriginAddress(_mirrorTokenId);
        require(nftContract != address(0), "No such NFT contract");
        address adaptor = originNFT2Adaptor[nftContract];
        require(adaptor != address(0), "not registered!");
        require(ownerOfMirror(_mirrorTokenId) == msg.sender, "you have no right to swap it out!");

        address petBase = registry.addressOf(SettingIds.CONTRACT_PET_BASE);
        (uint256 apostleTokenId,) = IPetBase(petBase).pet2TiedStatus(_mirrorTokenId);
        require(apostleTokenId == 0, "Pet has been tied.");
        uint256 originTokenId = mirrorId2OriginId[_mirrorTokenId];
        address objectOwnership = registry.addressOf(SettingIds.CONTRACT_OBJECT_OWNERSHIP);
        address owner = IERC721(objectOwnership).ownerOf(_mirrorTokenId);
        if (owner != address(this)) {
            IERC721(nftContract).approve(address(this), originTokenId); // kitty must approve first 
            IERC721(nftContract).transferFrom(address(this), msg.sender, originTokenId);
        }
        IBurnableERC20(objectOwnership).burn(owner, _mirrorTokenId);
        delete mirrorId2OriginId[_mirrorTokenId];
        emit SwapOut(nftContract, originTokenId, _mirrorTokenId, msg.sender);
    }

    function swapOut1155(uint256 _mirrorTokenId) public  {

        IInterstellarEncoderV3 interstellarEncoder = IInterstellarEncoderV3(registry.addressOf(SettingIds.CONTRACT_INTERSTELLAR_ENCODER));
        address nftContract = interstellarEncoder.getOriginAddress(_mirrorTokenId);
        require(nftContract != address(0), "No such NFT contract");
        address adaptor = originNFT2Adaptor[nftContract];
        require(adaptor != address(0), "not registered!");
        address objectOwnership = registry.addressOf(SettingIds.CONTRACT_OBJECT_OWNERSHIP);
        require(IERC721(objectOwnership).ownerOf(_mirrorTokenId) == msg.sender, "you have no right to swap it out!");

        address petBase = registry.addressOf(SettingIds.CONTRACT_PET_BASE);
        (uint256 apostleTokenId,) = IPetBase(petBase).pet2TiedStatus(_mirrorTokenId);
        require(apostleTokenId == 0, "Pet has been tied.");
        uint256 originTokenId = mirrorId2OriginId1155[_mirrorTokenId];
        IBurnableERC20(objectOwnership).burn(msg.sender, _mirrorTokenId);
        IERC1155(nftContract).safeTransferFrom(address(this), msg.sender, originTokenId, 1, "");
        delete mirrorId2OriginId1155[_mirrorTokenId];
        emit SwapOut(nftContract, originTokenId, _mirrorTokenId, msg.sender);
    }

    function ownerOf(uint256 _mirrorTokenId) public view returns (address) {

        return ownerOfMirror(_mirrorTokenId);
    }

    function mirrorOfOrigin(address _originNFT, uint256 _originTokenId) public view returns (uint256) {

        INFTAdaptor adapter = INFTAdaptor(originNFT2Adaptor[_originNFT]);

        return adapter.toMirrorTokenId(_originTokenId);
    }

    function ownerOfMirror(uint256 _mirrorTokenId) public view returns (address) {

        address objectOwnership = registry.addressOf(SettingIds.CONTRACT_OBJECT_OWNERSHIP);
        address owner = IERC721(objectOwnership).ownerOf(_mirrorTokenId);
        if(owner != address(this)) {
            return owner;
        } else {
            uint originTokenId = mirrorId2OriginId[_mirrorTokenId];
            return INFTAdaptor(originNFT2Adaptor[originOwnershipAddress(_mirrorTokenId)]).ownerInOrigin(originTokenId);
        }
    }

    function originOwnershipAddress(uint256 _mirrorTokenId) public view returns (address) {

        IInterstellarEncoderV3 interstellarEncoder = IInterstellarEncoderV3(registry.addressOf(SettingIds.CONTRACT_INTERSTELLAR_ENCODER));

        return interstellarEncoder.getOriginAddress(_mirrorTokenId);
    }

    function isBridged(uint256 _mirrorTokenId) public view returns (bool) {

        return (mirrorId2OriginId[_mirrorTokenId] != 0);
    }

    function swapIn1155(address _originNftAddress, uint256 _originTokenId, uint256 _value) public whenNotPaused() {

        address _from = msg.sender;
        IERC1155(_originNftAddress).safeTransferFrom(_from, address(this), _originTokenId, _value, "");
        address adaptor = originNFT2Adaptor[_originNftAddress];
        require(adaptor != address(0), "Not registered!");
        address objectOwnership = registry.addressOf(SettingIds.CONTRACT_OBJECT_OWNERSHIP);
        for (uint256 i = 0; i < _value; i++) {
            uint256 mirrorTokenId = INFTAdaptor(adaptor).toMirrorTokenIdAndIncrease(_originTokenId);
            IMintableERC20(objectOwnership).mint(_from, mirrorTokenId);
            mirrorId2OriginId1155[mirrorTokenId] = _originTokenId;
            emit SwapIn(_originNftAddress, _originTokenId, mirrorTokenId, _from);
        }
    }

    function swapIn721(address _originNftAddress, uint256 _originTokenId) public whenNotPaused() {

        address _owner = msg.sender;
        IERC721(_originNftAddress).transferFrom(_owner, address(this), _originTokenId);
        address adaptor = originNFT2Adaptor[_originNftAddress];
        require(adaptor != address(0), "Not registered!");
        uint256 mirrorTokenId = INFTAdaptor(adaptor).toMirrorTokenId(_originTokenId);
        address objectOwnership = registry.addressOf(SettingIds.CONTRACT_OBJECT_OWNERSHIP);
        require(!isBridged(mirrorTokenId), "Already swap in");
        INFTAdaptor(adaptor).cacheMirrorTokenId(_originTokenId, mirrorTokenId);
        mirrorId2OriginId[mirrorTokenId] = _originTokenId;
        IMintableERC20(objectOwnership).mint(_owner, mirrorTokenId);
        emit SwapIn(_originNftAddress, _originTokenId, mirrorTokenId, _owner);
    }

    function onERC721Received(
      address /*_operator*/,
      address /*_from*/,
      uint256 /*_tokenId*/,
      bytes /*_data*/
    )
      public 
      returns(bytes4) 
    {

        return ERC721_RECEIVED;
    }

    function onERC1155Received(
      address /*operator*/,
      address /*from*/,
      uint256 /*id*/,
      uint256 /*value*/,
      bytes /*data*/
    )
      external
      returns(bytes4)
    {

        return ERC1155_RECEIVED_VALUE; 
    }

    function onERC1155BatchReceived(
      address /*operator*/,
      address /*from*/,
      uint256[] /*ids*/,
      uint256[] /*values*/,
      bytes /*data*/
    )
      external
      returns(bytes4)
    {

        return ERC1155_BATCH_RECEIVED_VALUE;	
    }
}