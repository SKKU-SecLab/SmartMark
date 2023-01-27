
pragma solidity >=0.6.0 <0.8.0;

abstract contract ReentrancyGuard {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor () internal {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
    }
}// GPLv3
pragma solidity 0.7.2;
pragma experimental ABIEncoderV2;

contract EternalModel {

  struct Storage {
    mapping(bytes32 => address) addressStorage;
    mapping(bytes32 => bool) boolStorage;
    mapping(bytes32 => bytes) bytesStorage;
    mapping(bytes32 => int256) intStorage;
    mapping(bytes32 => string) stringStorage;
    mapping(bytes32 => uint256) uIntStorage;
  }

  Storage internal s;


  function getUint(bytes32 _key) internal view returns (uint256) {

    return s.uIntStorage[_key];
  }

  function getString(bytes32 _key) internal view returns (string memory) {

    return s.stringStorage[_key];
  }

  function getAddress(bytes32 _key) internal view returns (address) {

    return s.addressStorage[_key];
  }

  function getBool(bytes32 _key) internal view returns (bool) {

    return s.boolStorage[_key];
  }


  function setUint(bytes32 _key, uint256 _value) internal {

    s.uIntStorage[_key] = _value;
  }

  function setString(bytes32 _key, string memory _value) internal {

    s.stringStorage[_key] = _value;
  }

  function setAddress(bytes32 _key, address _value) internal {

    s.addressStorage[_key] = _value;
  }

  function setBool(bytes32 _key, bool _value) internal {

    s.boolStorage[_key] = _value;
  }
}// GPLv3
pragma solidity 0.7.2;



contract Ecosystem is EternalModel, ReentrancyGuard {

  struct Instance {
    address daoAddress;
    address daoModelAddress;
    address ecosystemModelAddress;
    address tokenHolderModelAddress;
    address tokenModelAddress;
    address governanceTokenAddress;
  }

  event Serialized(address indexed _daoAddress);

  function deserialize(address _daoAddress) external view returns (Instance memory record) {

    if (_exists(_daoAddress)) {
      record.daoAddress = _daoAddress;
      record.daoModelAddress = getAddress(
        keccak256(abi.encode(record.daoAddress, 'daoModelAddress'))
      );
      record.ecosystemModelAddress = address(this);
      record.governanceTokenAddress = getAddress(
        keccak256(abi.encode(record.daoAddress, 'governanceTokenAddress'))
      );
      record.tokenHolderModelAddress = getAddress(
        keccak256(abi.encode(record.daoAddress, 'tokenHolderModelAddress'))
      );
      record.tokenModelAddress = getAddress(
        keccak256(abi.encode(record.daoAddress, 'tokenModelAddress'))
      );
    }

    return record;
  }

  function exists(address _daoAddress) external view returns (bool recordExists) {

    return _exists(_daoAddress);
  }

  function serialize(Instance memory _record) external nonReentrant {

    bool recordExists = _exists(_record.daoAddress);

    require(
      msg.sender == _record.daoAddress || (_record.daoAddress == address(0) && !recordExists),
      'ElasticDAO: Unauthorized'
    );

    setAddress(
      keccak256(abi.encode(_record.daoAddress, 'daoModelAddress')),
      _record.daoModelAddress
    );
    setAddress(
      keccak256(abi.encode(_record.daoAddress, 'governanceTokenAddress')),
      _record.governanceTokenAddress
    );
    setAddress(
      keccak256(abi.encode(_record.daoAddress, 'tokenHolderModelAddress')),
      _record.tokenHolderModelAddress
    );
    setAddress(
      keccak256(abi.encode(_record.daoAddress, 'tokenModelAddress')),
      _record.tokenModelAddress
    );

    setBool(keccak256(abi.encode(_record.daoAddress, 'exists')), true);

    emit Serialized(_record.daoAddress);
  }

  function _exists(address _daoAddress) internal view returns (bool recordExists) {

    return getBool(keccak256(abi.encode(_daoAddress, 'exists')));
  }
}