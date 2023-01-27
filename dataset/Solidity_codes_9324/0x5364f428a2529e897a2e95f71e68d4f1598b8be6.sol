

pragma solidity 0.4.24;

contract EternalStorage {


    mapping(bytes32 => uint256) internal uintStorage;
    mapping(bytes32 => string) internal stringStorage;
    mapping(bytes32 => address) internal addressStorage;
    mapping(bytes32 => bytes) internal bytesStorage;
    mapping(bytes32 => bool) internal boolStorage;
    mapping(bytes32 => int256) internal intStorage;


    mapping(bytes32 => uint256[]) internal uintArrayStorage;
    mapping(bytes32 => string[]) internal stringArrayStorage;
    mapping(bytes32 => address[]) internal addressArrayStorage;
    mapping(bytes32 => bool[]) internal boolArrayStorage;
    mapping(bytes32 => int256[]) internal intArrayStorage;
    mapping(bytes32 => bytes32[]) internal bytes32ArrayStorage;
}


pragma solidity 0.4.24;


contract EternalOwnable is EternalStorage {

    event EternalOwnershipTransferred(address previousOwner, address newOwner);

    modifier onlyOwner() {

        require(msg.sender == owner());
        _;
    }

    function owner() public view returns (address) {

        return addressStorage[keccak256(abi.encodePacked("owner"))];
    }

    function transferOwnership(address newOwner) public onlyOwner {

        require(newOwner != address(0));
        setOwner(newOwner);
    }

    function setOwner(address newOwner) internal {

        emit EternalOwnershipTransferred(owner(), newOwner);
        addressStorage[keccak256(abi.encodePacked("owner"))] = newOwner;
    }
}


pragma solidity 0.4.24;

interface IForeignBridgeValidators {

    function isValidator(address _validator) external view returns(bool);

    function requiredSignatures() external view returns(uint256);

    function setValidators(address[] _validators) external returns(bool);

}


pragma solidity ^0.4.24;

library SafeMath {


  function mul(uint256 a, uint256 b) internal pure returns (uint256) {

    if (a == 0) {
      return 0;
    }

    uint256 c = a * b;
    require(c / a == b);

    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {

    require(b > 0); // Solidity only automatically asserts when dividing by 0
    uint256 c = a / b;

    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {

    require(b <= a);
    uint256 c = a - b;

    return c;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256) {

    uint256 c = a + b;
    require(c >= a);

    return c;
  }

  function mod(uint256 a, uint256 b) internal pure returns (uint256) {

    require(b != 0);
    return a % b;
  }
}


pragma solidity 0.4.24;





contract ForeignBridgeValidators is IForeignBridgeValidators, EternalStorage, EternalOwnable {

  using SafeMath for uint256;

  event ValidatorsChanged (address[] validators);
  event RequiredSignaturesChanged (uint256 requiredSignatures);

  function initialize(address[] _initialValidators, address _foreignBridge) public returns (bool) {

    require(!isInitialized());
    require(_foreignBridge != address(0));
    setOwner(_foreignBridge);
    for (uint256 i = 0; i < _initialValidators.length; i++) {
        require(_initialValidators[i] != address(0));
    }
    _setValidators(_initialValidators);
    emit ValidatorsChanged(_initialValidators);
    _setRequiredSignatures();
    emit RequiredSignaturesChanged(requiredSignatures());
    _setDeployedAtBlock();
    _setInitialize(true);
    return isInitialized();
  }

  function setValidators(address[] _validators) external onlyOwner returns (bool) {

    for (uint256 i = 0; i < _validators.length; i++) {
      require(_validators[i] != address(0));
    }
    _setValidators(_validators);
    emit ValidatorsChanged(_validators);
    _setRequiredSignatures();
    emit RequiredSignaturesChanged(requiredSignatures());
    return true;
  }

  bytes32 internal constant VALIDATORS = keccak256(abi.encodePacked("validators"));
  bytes32 internal constant REQUIRED_SIGNATURES = keccak256(abi.encodePacked("requiredSignatures"));
  bytes32 internal constant IS_INITIALIZED = keccak256(abi.encodePacked("isInitialized"));
  bytes32 internal constant DEPLOYED_AT_BLOCK = keccak256(abi.encodePacked("deployedAtBlock"));

  function validators() public view returns(address[]) {

    return addressArrayStorage[VALIDATORS];
  }

  function validatorCount() public view returns(uint256) {

    return addressArrayStorage[VALIDATORS].length;
  }

  function isValidator(address _address) public view returns(bool) {

    uint256 _validatorCount = validatorCount();
    for (uint256 i; i < _validatorCount; i++) {
      if (_address == addressArrayStorage[VALIDATORS][i]) {
        return true;
      }
    }
    return false;
  }

  function requiredSignatures() public view returns(uint256) {

    return uintStorage[REQUIRED_SIGNATURES];
  }

  function isInitialized() public view returns(bool) {

      return boolStorage[IS_INITIALIZED];
  }

  function deployedAtBlock() public view returns(uint256) {

      return uintStorage[DEPLOYED_AT_BLOCK];
  }

  function getForeignBridgeValidatorsInterfacesVersion() public pure returns(uint64 major, uint64 minor, uint64 patch) {

      return (1, 0, 0);
  }

  function _setValidators(address[] _validators) private {

    addressArrayStorage[VALIDATORS] = _validators;
  }

  function _setRequiredSignatures() private {

    uintStorage[REQUIRED_SIGNATURES] = validatorCount().div(2).add(1);
    emit RequiredSignaturesChanged(requiredSignatures());
  }

  function _setInitialize(bool _status) private {

      boolStorage[IS_INITIALIZED] = _status;
  }

  function _setDeployedAtBlock() private {

    uintStorage[DEPLOYED_AT_BLOCK] = block.number;
  }
}