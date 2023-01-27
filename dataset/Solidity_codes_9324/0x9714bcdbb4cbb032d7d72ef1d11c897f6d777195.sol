

pragma solidity >=0.4.24 <0.5.0;


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




contract PolkaPetAdaptor is PausableDSAuth, SettingIds {


    event SetTokenIDAuth(uint256 indexed tokenId, bool status);


    uint16 public producerId;

    uint8 public convertType;

    ISettingsRegistry public registry;

    address public originNft;

    uint128 public lastObjectId;

    mapping (uint256 => bool) public allowList;

    constructor(ISettingsRegistry _registry, address _originNft, uint16 _producerId) public {
        registry = _registry;
        originNft = _originNft;
        producerId = _producerId;
        convertType = 128;  // f(x) = x，fullfill with zero at left side.

        allowList[2] = true;   // Darwinia
        allowList[11] = true;  // EVO
        allowList[20] = true;  // Crab
    }

    function setTokenIDAuth(uint256 _tokenId, bool _status) public auth {

        allowList[_tokenId] = _status;
        emit SetTokenIDAuth(_tokenId, _status);	
    }

    function toMirrorTokenIdAndIncrease(uint256 _originTokenId) public auth returns (uint256) {

        require(allowList[_originTokenId], "POLKPET: PERMISSION");
        lastObjectId += 1;
	require(lastObjectId < uint128(-1), "POLKPET: OBJECTID_OVERFLOW");
        uint128 mirrorObjectId = uint128(lastObjectId & 0xffffffffffffffffffffffffffffffff);
        address objectOwnership = registry.addressOf(SettingIds.CONTRACT_OBJECT_OWNERSHIP);
        address petBase = registry.addressOf(SettingIds.CONTRACT_PET_BASE);
        IInterstellarEncoderV3 interstellarEncoder = IInterstellarEncoderV3(registry.addressOf(SettingIds.CONTRACT_INTERSTELLAR_ENCODER));
        uint256 mirrorTokenId = interstellarEncoder.encodeTokenIdForOuterObjectContract(
        petBase, objectOwnership, originNft, mirrorObjectId, producerId, convertType);

        return mirrorTokenId;
    }

}