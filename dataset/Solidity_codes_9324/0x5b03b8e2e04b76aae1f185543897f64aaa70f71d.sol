
pragma solidity 0.5.3;


interface DharmaKeyRingImplementationV0Interface {

  event KeyModified(address indexed key, bool standard, bool admin);

  enum KeyType {
    None,
    Standard,
    Admin,
    Dual
  }

  enum AdminActionType {
    AddStandardKey,
    RemoveStandardKey,
    SetStandardThreshold,
    AddAdminKey,
    RemoveAdminKey,
    SetAdminThreshold,
    AddDualKey,
    RemoveDualKey,
    SetDualThreshold
  }

  struct AdditionalKeyCount {
    uint128 standard;
    uint128 admin;
  }

  function takeAdminAction(
    AdminActionType adminActionType, uint160 argument, bytes calldata signatures
  ) external;


  function getAdminActionID(
    AdminActionType adminActionType, uint160 argument, uint256 nonce
  ) external view returns (bytes32 adminActionID);


  function getNextAdminActionID(
    AdminActionType adminActionType, uint160 argument
  ) external view returns (bytes32 adminActionID);


  function getKeyCount() external view returns (
    uint256 standardKeyCount, uint256 adminKeyCount
  );


  function getKeyType(
    address key
  ) external view returns (bool standard, bool admin);


  function getNonce() external returns (uint256 nonce);


  function getVersion() external pure returns (uint256 version);

}


interface ERC1271 {

  function isValidSignature(
    bytes calldata data, 
    bytes calldata signature
  ) external view returns (bytes4 magicValue);

}


library ECDSA {

  function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {

    if (signature.length != 65) {
      return (address(0));
    }

    bytes32 r;
    bytes32 s;
    uint8 v;

    assembly {
      r := mload(add(signature, 0x20))
      s := mload(add(signature, 0x40))
      v := byte(0, mload(add(signature, 0x60)))
    }

    if (uint256(s) > 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0) {
      return address(0);
    }

    if (v != 27 && v != 28) {
      return address(0);
    }

    return ecrecover(hash, v, r, s);
  }

  function toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32) {

    return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
  }
}


contract DharmaKeyRingImplementationV1 is
  DharmaKeyRingImplementationV0Interface,
  ERC1271 {

  using ECDSA for bytes32;

  mapping (uint160 => KeyType) private _keys;

  uint256 private _nonce;

  AdditionalKeyCount private _additionalKeyCounts;



  uint256 internal constant _DHARMA_KEY_RING_VERSION = 1;

  bytes4 internal constant _ERC_1271_MAGIC_VALUE = bytes4(0x20c13b0b);

  function initialize(
    uint128 adminThreshold,
    uint128 executorThreshold,
    address[] calldata keys,
    uint8[] calldata keyTypes // must all be 3 (Dual) for V1
  ) external {

    assembly { if extcodesize(address) { revert(0, 0) } }

    require(keys.length == 1, "Must supply exactly one key in V1.");

    require(keys[0] != address(0), "Cannot supply the null address as a key.");

    require(
      keyTypes.length == 1 && keyTypes[0] == uint8(3),
      "Must supply exactly one Dual keyType (3) in V1."
    );

    require(adminThreshold == 1, "Admin threshold must be exactly one in V1.");

    require(
      executorThreshold == 1, "Executor threshold must be exactly one in V1."
    );

    _keys[uint160(keys[0])] = KeyType.Dual;
    emit KeyModified(keys[0], true, true);

  }

  function takeAdminAction(
    AdminActionType adminActionType, uint160 argument, bytes calldata signatures
  ) external {

    require(
      adminActionType == AdminActionType.AddDualKey,
      "Only adding new Dual key types (admin action type 6) is supported in V1."
    );

    require(argument != uint160(0), "Cannot supply the null address as a key.");

    require(_keys[argument] == KeyType.None, "Key already exists.");

    _verifySignature(
      _getAdminActionID(argument, _nonce).toEthSignedMessageHash(), signatures
    );

    _additionalKeyCounts.standard++;
    _additionalKeyCounts.admin++;

    _keys[argument] = KeyType.Dual;
    emit KeyModified(address(argument), true, true);

    _nonce++;
  }

  function isValidSignature(
    bytes calldata data, bytes calldata signature
  ) external view returns (bytes4 magicValue) {

    (bytes32 hash, , ) = abi.decode(data, (bytes32, uint8, bytes));

    _verifySignature(hash, signature);

    magicValue = _ERC_1271_MAGIC_VALUE;
  }

  function getAdminActionID(
    AdminActionType adminActionType, uint160 argument, uint256 nonce
  ) external view returns (bytes32 adminActionID) {

    adminActionType;
    adminActionID = _getAdminActionID(argument, nonce);
  }

  function getNextAdminActionID(
    AdminActionType adminActionType, uint160 argument
  ) external view returns (bytes32 adminActionID) {

    adminActionType;
    adminActionID = _getAdminActionID(argument, _nonce);
  }

  function getVersion() external pure returns (uint256 version) {

    version = _DHARMA_KEY_RING_VERSION;
  }

  function getKeyCount() external view returns (
    uint256 standardKeyCount, uint256 adminKeyCount
  ) {

    AdditionalKeyCount memory additionalKeyCount = _additionalKeyCounts;
    standardKeyCount = uint256(additionalKeyCount.standard) + 1;
    adminKeyCount = uint256(additionalKeyCount.admin) + 1;
  }

  function getKeyType(
    address key
  ) external view returns (bool standard, bool admin) {

    KeyType keyType = _keys[uint160(key)];
    standard = (keyType == KeyType.Standard || keyType == KeyType.Dual);
    admin = (keyType == KeyType.Admin || keyType == KeyType.Dual);
  }

  function getNonce() external returns (uint256 nonce) {

    nonce = _nonce;
  }

  function _getAdminActionID(
    uint160 argument, uint256 nonce
  ) internal view returns (bytes32 adminActionID) {

    adminActionID = keccak256(
      abi.encodePacked(
        address(this), _DHARMA_KEY_RING_VERSION, nonce, argument
      )
    );
  }

  function _verifySignature(
    bytes32 hash, bytes memory signature
  ) internal view {

    require(
      _keys[uint160(hash.recover(signature))] == KeyType.Dual,
      "Supplied signature does not have a signer with the required key type."
    );
  }
}