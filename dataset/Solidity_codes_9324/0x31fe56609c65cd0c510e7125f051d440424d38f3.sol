
pragma solidity ^0.8.7;

contract StealthKeyRegistry {


  event StealthKeyChanged(
    address indexed registrant,
    uint256 spendingPubKeyPrefix,
    uint256 spendingPubKey,
    uint256 viewingPubKeyPrefix,
    uint256 viewingPubKey
  );


  bytes32 public constant STEALTHKEYS_TYPEHASH =
    keccak256(
      "StealthKeys(uint256 spendingPubKeyPrefix,uint256 spendingPubKey,uint256 viewingPubKeyPrefix,uint256 viewingPubKey)"
    );

  bytes32 public immutable DOMAIN_SEPARATOR;

  mapping(address => mapping(uint256 => uint256)) keys;

  constructor() {
    DOMAIN_SEPARATOR = keccak256(
      abi.encode(
        keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"),
        keccak256(bytes("Umbra Stealth Key Registry")),
        keccak256(bytes("1")),
        block.chainid,
        address(this)
      )
    );
  }


  function setStealthKeys(
    uint256 _spendingPubKeyPrefix,
    uint256 _spendingPubKey,
    uint256 _viewingPubKeyPrefix,
    uint256 _viewingPubKey
  ) external {

    _setStealthKeys(msg.sender, _spendingPubKeyPrefix, _spendingPubKey, _viewingPubKeyPrefix, _viewingPubKey);
  }

  function setStealthKeysOnBehalf(
    address _registrant,
    uint256 _spendingPubKeyPrefix,
    uint256 _spendingPubKey,
    uint256 _viewingPubKeyPrefix,
    uint256 _viewingPubKey,
    uint8 _v,
    bytes32 _r,
    bytes32 _s
  ) external {

    bytes32 _digest =
      keccak256(
        abi.encodePacked(
          "\x19\x01",
          DOMAIN_SEPARATOR,
          keccak256(
            abi.encode(
              STEALTHKEYS_TYPEHASH,
              _spendingPubKeyPrefix,
              _spendingPubKey,
              _viewingPubKeyPrefix,
              _viewingPubKey
            )
          )
        )
      );

    address _recovered = ecrecover(_digest, _v, _r, _s);
    require(_recovered == _registrant, "StealthKeyRegistry: Invalid Signature");

    _setStealthKeys(_registrant, _spendingPubKeyPrefix, _spendingPubKey, _viewingPubKeyPrefix, _viewingPubKey);
  }

  function _setStealthKeys(
    address _registrant,
    uint256 _spendingPubKeyPrefix,
    uint256 _spendingPubKey,
    uint256 _viewingPubKeyPrefix,
    uint256 _viewingPubKey
  ) internal {

    require(
      (_spendingPubKeyPrefix == 2 || _spendingPubKeyPrefix == 3) &&
        (_viewingPubKeyPrefix == 2 || _viewingPubKeyPrefix == 3),
      "StealthKeyRegistry: Invalid Prefix"
    );

    emit StealthKeyChanged(_registrant, _spendingPubKeyPrefix, _spendingPubKey, _viewingPubKeyPrefix, _viewingPubKey);

    _spendingPubKeyPrefix -= 2;

    delete keys[_registrant][1 - _spendingPubKeyPrefix];
    delete keys[_registrant][5 - _viewingPubKeyPrefix];

    keys[_registrant][_spendingPubKeyPrefix] = _spendingPubKey;
    keys[_registrant][_viewingPubKeyPrefix] = _viewingPubKey;
  }


  function stealthKeys(address _registrant)
    external
    view
    returns (
      uint256 spendingPubKeyPrefix,
      uint256 spendingPubKey,
      uint256 viewingPubKeyPrefix,
      uint256 viewingPubKey
    )
  {

    if (keys[_registrant][0] != 0) {
      spendingPubKeyPrefix = 2;
      spendingPubKey = keys[_registrant][0];
    } else {
      spendingPubKeyPrefix = 3;
      spendingPubKey = keys[_registrant][1];
    }

    if (keys[_registrant][2] != 0) {
      viewingPubKeyPrefix = 2;
      viewingPubKey = keys[_registrant][2];
    } else {
      viewingPubKeyPrefix = 3;
      viewingPubKey = keys[_registrant][3];
    }

    return (spendingPubKeyPrefix, spendingPubKey, viewingPubKeyPrefix, viewingPubKey);
  }
}