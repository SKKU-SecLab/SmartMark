
pragma solidity 0.4.25;




interface AttributeRegistryInterface {

  function hasAttribute(
    address account,
    uint256 attributeTypeID
  ) external view returns (bool);


  function getAttributeValue(
    address account,
    uint256 attributeTypeID
  ) external view returns (uint256);


  function countAttributeTypes() external view returns (uint256);


  function getAttributeTypeID(uint256 index) external view returns (uint256);

}


interface TPLBasicValidatorInterface {

  function isValidator() external view returns (bool);


  function canIssueAttributeType(
    uint256 attributeTypeID
  ) external view returns (bool);


  function canIssueAttribute(
    address account,
    uint256 attributeTypeID
  ) external view returns (bool, bytes1);


  function canRevokeAttribute(
    address account,
    uint256 attributeTypeID
  ) external view returns (bool, bytes1);


  function getJurisdiction() external view returns (address);

}


interface BasicJurisdictionInterface {

  event AttributeTypeAdded(uint256 indexed attributeTypeID, string description);
  
  event AttributeTypeRemoved(uint256 indexed attributeTypeID);
  
  event ValidatorAdded(address indexed validator, string description);
  
  event ValidatorRemoved(address indexed validator);
  
  event ValidatorApprovalAdded(
    address validator,
    uint256 indexed attributeTypeID
  );

  event ValidatorApprovalRemoved(
    address validator,
    uint256 indexed attributeTypeID
  );

  event AttributeAdded(
    address validator,
    address indexed attributee,
    uint256 attributeTypeID,
    uint256 attributeValue
  );

  event AttributeRemoved(
    address validator,
    address indexed attributee,
    uint256 attributeTypeID
  );

  function addAttributeType(uint256 ID, string description) external;


  function removeAttributeType(uint256 ID) external;


  function addValidator(address validator, string description) external;


  function removeValidator(address validator) external;


  function addValidatorApproval(
    address validator,
    uint256 attributeTypeID
  ) external;


  function removeValidatorApproval(
    address validator,
    uint256 attributeTypeID
  ) external;


  function issueAttribute(
    address account,
    uint256 attributeTypeID,
    uint256 value
  ) external payable;


  function revokeAttribute(
    address account,
    uint256 attributeTypeID
  ) external;


  function canIssueAttributeType(
    address validator,
    uint256 attributeTypeID
  ) external view returns (bool);


  function getAttributeTypeDescription(
    uint256 attributeTypeID
  ) external view returns (string description);

  
  function getValidatorDescription(
    address validator
  ) external view returns (string description);


  function getAttributeValidator(
    address account,
    uint256 attributeTypeID
  ) external view returns (address validator, bool isStillValid);


  function countAttributeTypes() external view returns (uint256);


  function getAttributeTypeID(uint256 index) external view returns (uint256);


  function getAttributeTypeIDs() external view returns (uint256[]);


  function countValidators() external view returns (uint256);


  function getValidator(uint256 index) external view returns (address);


  function getValidators() external view returns (address[]);

}


contract TPLBasicValidator is TPLBasicValidatorInterface {


  AttributeRegistryInterface internal _registry;

  BasicJurisdictionInterface internal _jurisdiction;

  uint256 internal _validAttributeTypeID;

  constructor(
    AttributeRegistryInterface registry,
    uint256 validAttributeTypeID
  ) public {
    _registry = AttributeRegistryInterface(registry);
    _jurisdiction = BasicJurisdictionInterface(registry);
    _validAttributeTypeID = validAttributeTypeID;
  }

  function isValidator() external view returns (bool) {

    uint256 totalValidators = _jurisdiction.countValidators();
    
    for (uint256 i = 0; i < totalValidators; i++) {
      address validator = _jurisdiction.getValidator(i);
      if (validator == address(this)) {
        return true;
      }
    }

    return false;
  }

  function canIssueAttributeType(
    uint256 attributeTypeID
  ) external view returns (bool) {

    return (
      _validAttributeTypeID == attributeTypeID &&
      _jurisdiction.canIssueAttributeType(address(this), _validAttributeTypeID)
    );
  }

  function canIssueAttribute(
    address account,
    uint256 attributeTypeID
  ) external view returns (bool, bytes1) {

    if (_validAttributeTypeID != attributeTypeID) {
      return (false, hex"A0");
    }

    if (_registry.hasAttribute(account, _validAttributeTypeID)) {
      return (false, hex"B0");
    }

    return (true, hex"01");
  }

  function canRevokeAttribute(
    address account,
    uint256 attributeTypeID
  ) external view returns (bool, bytes1) {

    if (_validAttributeTypeID != attributeTypeID) {
      return (false, hex"A0");
    }

    if (!_registry.hasAttribute(account, _validAttributeTypeID)) {
      return (false, hex"B0");
    }

    (address validator, bool unused) = _jurisdiction.getAttributeValidator(
      account,
      _validAttributeTypeID
    );
    unused;

    if (validator != address(this)) {
      return (false, hex"C0");
    }    

    return (true, hex"01");
  }

  function getValidAttributeID() external view returns (uint256) {

    return _validAttributeTypeID;
  }

  function getJurisdiction() external view returns (address) {

    return address(_jurisdiction);
  }

  function _issueAttribute(address account) internal returns (bool) {

    _jurisdiction.issueAttribute(account, _validAttributeTypeID, 0);
    return true;
  }

  function _revokeAttribute(address account) internal returns (bool) {

    _jurisdiction.revokeAttribute(account, _validAttributeTypeID);
    return true;
  }
}


contract CryptoCopycatsCooperative is TPLBasicValidator {


  string public name = "Crypto Copycats Cooperative";

  mapping(address => bool) private _careCoordinator;

  constructor(
    AttributeRegistryInterface registry,
    uint256 validAttributeTypeID
  ) public TPLBasicValidator(registry, validAttributeTypeID) {
    _careCoordinator[msg.sender] = true;
  }

  modifier onlyCareCoordinators() {

    require(
      _careCoordinator[msg.sender],
      "This method may only be called by a care coordinator."
    );
    _;
  }

  function addCareCoordinator(address account) external onlyCareCoordinators {

    _careCoordinator[account] = true;
  }

  function issueAttribute(
    bool doYouLoveCats,
    bool doYouLoveDogsMoreThanCats,
    bool areYouACrazyCatLady
  ) external {

    require(doYouLoveCats, "only cat lovers allowed");
    require(doYouLoveDogsMoreThanCats, "no liars allowed");
    require(!areYouACrazyCatLady, "we are very particular");
    require(_issueAttribute(msg.sender));
  }

  function revokeAttribute(address account) external onlyCareCoordinators {

    require(_revokeAttribute(account));
  }
}