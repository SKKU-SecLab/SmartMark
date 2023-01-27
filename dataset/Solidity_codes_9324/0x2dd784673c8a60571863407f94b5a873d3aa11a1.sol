
pragma solidity ^0.4.24;
pragma experimental ABIEncoderV2;


contract CvcOntologyInterface {


    struct CredentialItem {
        bytes32 id;
        string recordType;
        string recordName;
        string recordVersion;
        string reference;
        string referenceType;
        bytes32 referenceHash;
    }

    function add(
        string _recordType,
        string _recordName,
        string _recordVersion,
        string _reference,
        string _referenceType,
        bytes32 _referenceHash
        ) external;


    function deprecate(string _type, string _name, string _version) public;


    function deprecateById(bytes32 _id) public;


    function getById(bytes32 _id) public view returns (
        bytes32 id,
        string recordType,
        string recordName,
        string recordVersion,
        string reference,
        string referenceType,
        bytes32 referenceHash,
        bool deprecated
        );


    function getByTypeNameVersion(
        string _type,
        string _name,
        string _version
        ) public view returns (
            bytes32 id,
            string recordType,
            string recordName,
            string recordVersion,
            string reference,
            string referenceType,
            bytes32 referenceHash,
            bool deprecated
        );


    function getAllIds() public view returns (bytes32[]);


    function getAll() public view returns (CredentialItem[]);

}


contract EternalStorage {


    mapping(bytes32 => uint256) internal uintStorage;
    mapping(bytes32 => string) internal stringStorage;
    mapping(bytes32 => address) internal addressStorage;
    mapping(bytes32 => bytes) internal bytesStorage;
    mapping(bytes32 => bool) internal boolStorage;
    mapping(bytes32 => int256) internal intStorage;
    mapping(bytes32 => bytes32) internal bytes32Storage;

}


contract ImplementationStorage {


    bytes32 internal constant IMPLEMENTATION_SLOT = 0xa490aab0d89837371982f93f57ffd20c47991f88066ef92475bc8233036969bb;

    constructor() public {
        assert(IMPLEMENTATION_SLOT == keccak256("cvc.proxy.implementation"));
    }

    function implementation() public view returns (address impl) {

        bytes32 slot = IMPLEMENTATION_SLOT;
        assembly {
            impl := sload(slot)
        }
    }
}


contract Initializable is EternalStorage, ImplementationStorage {



    modifier onlyInitialized() {

        require(boolStorage[keccak256(abi.encodePacked(implementation(), "initialized"))], "Contract is not initialized");
        _;
    }

    modifier initializes() {

        address impl = implementation();
        require(!boolStorage[keccak256(abi.encodePacked(impl, "initialized"))], "Contract is already initialized");
        _;
        boolStorage[keccak256(abi.encodePacked(impl, "initialized"))] = true;
    }
}


contract Ownable is EternalStorage {



    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    modifier onlyOwner() {

        require(msg.sender == owner(), "Message sender must be contract admin");
        _;
    }

    function owner() public view returns (address) {

        return addressStorage[keccak256("owner")];
    }

    function transferOwnership(address newOwner) public onlyOwner {

        require(newOwner != address(0), "Contract owner cannot be zero address");
        setOwner(newOwner);
    }

    function setOwner(address newOwner) internal {

        emit OwnershipTransferred(owner(), newOwner);
        addressStorage[keccak256("owner")] = newOwner;
    }
}


library SafeMath {


  function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {

    if (a == 0) {
      return 0;
    }

    c = a * b;
    assert(c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {

    return a / b;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {

    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256 c) {

    c = a + b;
    assert(c >= a);
    return c;
  }
}


contract CvcOntology is EternalStorage, Initializable, Ownable, CvcOntologyInterface {


    using SafeMath for uint256;


    constructor() public {
        initialize(msg.sender);
    }

    function add(
        string _recordType,
        string _recordName,
        string _recordVersion,
        string _reference,
        string _referenceType,
        bytes32 _referenceHash
    ) external onlyInitialized onlyOwner {

        require(bytes(_recordType).length > 0, "Empty credential item type");
        require(bytes(_recordName).length > 0, "Empty credential item name");
        require(bytes(_recordVersion).length > 0, "Empty credential item version");
        require(bytes(_reference).length > 0, "Empty credential item reference");
        require(bytes(_referenceType).length > 0, "Empty credential item type");
        require(_referenceHash != 0x0, "Empty credential item reference hash");

        bytes32 id = calculateId(_recordType, _recordName, _recordVersion);

        require(getReferenceHash(id) == 0x0, "Credential item record already exists");

        setType(id, _recordType);
        setName(id, _recordName);
        setVersion(id, _recordVersion);
        setReference(id, _reference);
        setReferenceType(id, _referenceType);
        setReferenceHash(id, _referenceHash);
        setRecordId(getCount(), id);
        incrementCount();
    }

    function initialize(address _owner) public initializes {

        setOwner(_owner);
    }

    function deprecate(string _type, string _name, string _version) public onlyInitialized onlyOwner {

        deprecateById(calculateId(_type, _name, _version));
    }

    function deprecateById(bytes32 _id) public onlyInitialized onlyOwner {

        require(getReferenceHash(_id) != 0x0, "Cannot deprecate unknown credential item");
        require(getDeprecated(_id) == false, "Credential item is already deprecated");
        setDeprecated(_id);
    }

    function getById(
        bytes32 _id
    ) public view onlyInitialized returns (
        bytes32 id,
        string recordType,
        string recordName,
        string recordVersion,
        string reference,
        string referenceType,
        bytes32 referenceHash,
        bool deprecated
    ) {

        referenceHash = getReferenceHash(_id);
        if (referenceHash != 0x0) {
            recordType = getType(_id);
            recordName = getName(_id);
            recordVersion = getVersion(_id);
            reference = getReference(_id);
            referenceType = getReferenceType(_id);
            deprecated = getDeprecated(_id);
            id = _id;
        }
    }

    function getByTypeNameVersion(
        string _type,
        string _name,
        string _version
    ) public view onlyInitialized returns (
        bytes32 id,
        string recordType,
        string recordName,
        string recordVersion,
        string reference,
        string referenceType,
        bytes32 referenceHash,
        bool deprecated
    ) {

        return getById(calculateId(_type, _name, _version));
    }

    function getAll() public view onlyInitialized returns (CredentialItem[]) {

        uint256 count = getCount();
        bytes32 id;
        CredentialItem[] memory records = new CredentialItem[](count);
        for (uint256 i = 0; i < count; i++) {
            id = getRecordId(i);
            records[i] = CredentialItem(
                id,
                getType(id),
                getName(id),
                getVersion(id),
                getReference(id),
                getReferenceType(id),
                getReferenceHash(id)
            );
        }

        return records;
    }

    function getAllIds() public view onlyInitialized returns(bytes32[]) {

        uint256 count = getCount();
        bytes32[] memory ids = new bytes32[](count);
        for (uint256 i = 0; i < count; i++) {
            ids[i] = getRecordId(i);
        }

        return ids;
    }

    function getCount() internal view returns (uint256) {

        return uintStorage[keccak256("records.count")];
    }

    function incrementCount() internal {

        uintStorage[keccak256("records.count")] = getCount().add(1);
    }

    function getRecordId(uint256 _index) internal view returns (bytes32) {

        return bytes32Storage[keccak256(abi.encodePacked("records.ids.", _index))];
    }

    function setRecordId(uint256 _index, bytes32 _id) internal {

        bytes32Storage[keccak256(abi.encodePacked("records.ids.", _index))] = _id;
    }

    function getType(bytes32 _id) internal view returns (string) {

        return stringStorage[keccak256(abi.encodePacked("records.", _id, ".type"))];
    }

    function setType(bytes32 _id, string _type) internal {

        stringStorage[keccak256(abi.encodePacked("records.", _id, ".type"))] = _type;
    }

    function getName(bytes32 _id) internal view returns (string) {

        return stringStorage[keccak256(abi.encodePacked("records.", _id, ".name"))];
    }

    function setName(bytes32 _id, string _name) internal {

        stringStorage[keccak256(abi.encodePacked("records.", _id, ".name"))] = _name;
    }

    function getVersion(bytes32 _id) internal view returns (string) {

        return stringStorage[keccak256(abi.encodePacked("records.", _id, ".version"))];
    }

    function setVersion(bytes32 _id, string _version) internal {

        stringStorage[keccak256(abi.encodePacked("records.", _id, ".version"))] = _version;
    }

    function getReference(bytes32 _id) internal view returns (string) {

        return stringStorage[keccak256(abi.encodePacked("records.", _id, ".reference"))];
    }

    function setReference(bytes32 _id, string _reference) internal {

        stringStorage[keccak256(abi.encodePacked("records.", _id, ".reference"))] = _reference;
    }

    function getReferenceType(bytes32 _id) internal view returns (string) {

        return stringStorage[keccak256(abi.encodePacked("records.", _id, ".referenceType"))];
    }

    function setReferenceType(bytes32 _id, string _referenceType) internal {

        stringStorage[keccak256(abi.encodePacked("records.", _id, ".referenceType"))] = _referenceType;
    }

    function getReferenceHash(bytes32 _id) internal view returns (bytes32) {

        return bytes32Storage[keccak256(abi.encodePacked("records.", _id, ".referenceHash"))];
    }

    function setReferenceHash(bytes32 _id, bytes32 _referenceHash) internal {

        bytes32Storage[keccak256(abi.encodePacked("records.", _id, ".referenceHash"))] = _referenceHash;
    }

    function getDeprecated(bytes32 _id) internal view returns (bool) {

        return boolStorage[keccak256(abi.encodePacked("records.", _id, ".deprecated"))];
    }

    function setDeprecated(bytes32 _id) internal {

        boolStorage[keccak256(abi.encodePacked("records.", _id, ".deprecated"))] = true;
    }

    function calculateId(string _type, string _name, string _version) internal pure returns (bytes32) {

        return keccak256(abi.encodePacked(_type, ".", _name, ".", _version));
    }
}