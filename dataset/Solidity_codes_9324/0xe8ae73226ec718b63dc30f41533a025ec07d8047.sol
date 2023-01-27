
pragma solidity 0.8.11;

interface WalletInterface {

  event CallSuccess(
    bool rolledBack,
    address to,
    uint256 value,
    bytes data,
    bytes returnData
  );

  event CallFailure(
    address to,
    uint256 value,
    bytes data,
    string revertReason
  );

  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );

  struct Call {
    address to;
    uint96 value;
    bytes data;
  }

  struct CallReturn {
    bool ok;
    bytes returnData;
  }

  struct ValueReplacement {
    uint24 returnDataOffset;
    uint8 valueLength;
    uint16 callIndex;
  }

  struct DataReplacement {
    uint24 returnDataOffset;
    uint24 dataLength;
    uint16 callIndex;
    uint24 callDataOffset;
  }

  struct AdvancedCall {
    address to;
    uint96 value;
    bytes data;
    ValueReplacement[] replaceValue;
    DataReplacement[] replaceData;
  }

  struct AdvancedCallReturn {
    bool ok;
    bytes returnData;
    uint96 callValue;
    bytes callData;
  }

  receive() external payable;

  function execute(
    Call[] calldata calls
  ) external returns (bool[] memory ok, bytes[] memory returnData);


  function executeAdvanced(
    AdvancedCall[] calldata calls
  ) external returns (AdvancedCallReturn[] memory callResults);


  function simulate(
    Call[] calldata calls
  ) external /* view */ returns (bool[] memory ok, bytes[] memory returnData);


  function simulateAdvanced(
    AdvancedCall[] calldata calls
  ) external /* view */ returns (AdvancedCallReturn[] memory callResults);


  function claimOwnership(address owner) external;


  function transferOwnership(address newOwner) external;


  function cancelOwnershipTransfer() external;


  function acceptOwnership() external;


  function owner() external view returns (address);


  function isOwner() external view returns (bool);


  function isValidSignature(bytes32 digest, bytes memory signature) external view returns (bytes4);


  function getImplementation() external view returns (address implementation);


  function getVersion() external pure returns (uint256 version);


  function initialize(address) external pure;

}


library Address {

  function isContract(address account) internal view returns (bool) {

    uint256 size;
    assembly { size := extcodesize(account) }
    return size > 0;
  }
}


library ECDSA {

    enum RecoverError {
        NoError,
        InvalidSignature,
        InvalidSignatureLength,
        InvalidSignatureS,
        InvalidSignatureV
    }

    function _throwError(RecoverError error) private pure {

        if (error == RecoverError.NoError) {
            return; // no error: do nothing
        } else if (error == RecoverError.InvalidSignature) {
            revert("ECDSA: invalid signature");
        } else if (error == RecoverError.InvalidSignatureLength) {
            revert("ECDSA: invalid signature length");
        } else if (error == RecoverError.InvalidSignatureS) {
            revert("ECDSA: invalid signature 's' value");
        } else if (error == RecoverError.InvalidSignatureV) {
            revert("ECDSA: invalid signature 'v' value");
        }
    }

    function tryRecover(bytes32 hash, bytes memory signature) internal pure returns (address, RecoverError) {

        if (signature.length == 65) {
            bytes32 r;
            bytes32 s;
            uint8 v;
            assembly {
                r := mload(add(signature, 0x20))
                s := mload(add(signature, 0x40))
                v := byte(0, mload(add(signature, 0x60)))
            }
            return tryRecover(hash, v, r, s);
        } else if (signature.length == 64) {
            bytes32 r;
            bytes32 vs;
            assembly {
                r := mload(add(signature, 0x20))
                vs := mload(add(signature, 0x40))
            }
            return tryRecover(hash, r, vs);
        } else {
            return (address(0), RecoverError.InvalidSignatureLength);
        }
    }

    function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {

        (address recovered, RecoverError error) = tryRecover(hash, signature);
        _throwError(error);
        return recovered;
    }

    function tryRecover(
        bytes32 hash,
        bytes32 r,
        bytes32 vs
    ) internal pure returns (address, RecoverError) {

        bytes32 s = vs & bytes32(0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff);
        uint8 v = uint8((uint256(vs) >> 255) + 27);
        return tryRecover(hash, v, r, s);
    }

    function recover(
        bytes32 hash,
        bytes32 r,
        bytes32 vs
    ) internal pure returns (address) {

        (address recovered, RecoverError error) = tryRecover(hash, r, vs);
        _throwError(error);
        return recovered;
    }

    function tryRecover(
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure returns (address, RecoverError) {

        if (uint256(s) > 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0) {
            return (address(0), RecoverError.InvalidSignatureS);
        }
        if (v != 27 && v != 28) {
            return (address(0), RecoverError.InvalidSignatureV);
        }

        address signer = ecrecover(hash, v, r, s);
        if (signer == address(0)) {
            return (address(0), RecoverError.InvalidSignature);
        }

        return (signer, RecoverError.NoError);
    }

    function recover(
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure returns (address) {

        (address recovered, RecoverError error) = tryRecover(hash, v, r, s);
        _throwError(error);
        return recovered;
    }
}


contract SmartWallet is WalletInterface {

  using Address for address;

  address private __DEPRECATED_SLOT_ONE__;
  uint256 private __DEPRECATED_SLOT_TWO__;

  bytes4 internal _selfCallContext;

  address internal _owner;

  address internal _newPotentialOwner;

  address public constant merkleWalletClaimer = address(
    0xD8470a6d796d54F13f243A4cf1a890E65bF3670E
  );

  address internal constant _UPGRADE_BEACON = address(
    0x000000000026750c571ce882B17016557279ADaa
  );

  uint256 internal constant _VERSION = 17;

  receive() external payable override {}

  function execute(
    Call[] calldata calls
  ) external override onlyOwner() returns (bool[] memory ok, bytes[] memory returnData) {

    for (uint256 i = 0; i < calls.length; i++) {
      if (calls[i].value == 0) {
        _ensureValidGenericCallTarget(calls[i].to);
      }
    }


    ok = new bool[](calls.length);
    returnData = new bytes[](calls.length);

    _selfCallContext = this.execute.selector;

    (bool externalOk, bytes memory rawCallResults) = address(this).call(
      abi.encodeWithSelector(
        this._execute.selector, calls
      )
    );

    if (!externalOk) {
      delete _selfCallContext;
    }

    CallReturn[] memory callResults = abi.decode(rawCallResults, (CallReturn[]));
    for (uint256 i = 0; i < callResults.length; i++) {
      Call memory currentCall = calls[i];

      ok[i] = callResults[i].ok;
      returnData[i] = callResults[i].returnData;

      if (callResults[i].ok) {
        emit CallSuccess(
          !externalOk, // If another call failed this will have been rolled back
          currentCall.to,
          uint256(currentCall.value),
          currentCall.data,
          callResults[i].returnData
        );
      } else {
        emit CallFailure(
          currentCall.to,
          uint256(currentCall.value),
          currentCall.data,
          _decodeRevertReason(callResults[i].returnData)
        );

        break;
      }
    }
  }

  function _execute(
    Call[] calldata calls
  ) external returns (CallReturn[] memory callResults) {

    _enforceSelfCallFrom(this.execute.selector);

    bool rollBack = false;
    callResults = new CallReturn[](calls.length);

    for (uint256 i = 0; i < calls.length; i++) {
      (bool ok, bytes memory returnData) = calls[i].to.call{
        value: uint256(calls[i].value)
      }(calls[i].data);
      callResults[i] = CallReturn({ok: ok, returnData: returnData});
      if (!ok) {
        rollBack = true;
        break;
      }
    }

    if (rollBack) {
      bytes memory callResultsBytes = abi.encode(callResults);
      assembly { revert(add(32, callResultsBytes), mload(callResultsBytes)) }
    }
  }

  function executeAdvanced(
    AdvancedCall[] calldata calls
  ) external override onlyOwner() returns (AdvancedCallReturn[] memory callResults) {

    for (uint256 i = 0; i < calls.length; i++) {
      if (calls[i].value == 0) {
        _ensureValidGenericCallTarget(calls[i].to);
      }
    }


    callResults = new AdvancedCallReturn[](calls.length);

    _selfCallContext = this.executeAdvanced.selector;

    (bool externalOk, bytes memory rawCallResults) = address(this).call(
      abi.encodeWithSelector(
        this._executeAdvanced.selector, calls
      )
    );

    if (
      rawCallResults.length > 68 && // prefix (4) + position (32) + length (32)
      rawCallResults[0] == bytes1(0x08) &&
      rawCallResults[1] == bytes1(0xc3) &&
      rawCallResults[2] == bytes1(0x79) &&
      rawCallResults[3] == bytes1(0xa0)
    ) {
      assembly {
        returndatacopy(0, 0, returndatasize())
        revert(0, returndatasize())
      }
    }

    if (!externalOk) {
      delete _selfCallContext;
    }

    callResults = abi.decode(rawCallResults, (AdvancedCallReturn[]));
    for (uint256 i = 0; i < callResults.length; i++) {
      AdvancedCall memory currentCall = calls[i];

      if (callResults[i].ok) {
        emit CallSuccess(
          !externalOk, // If another call failed this will have been rolled back
          currentCall.to,
          uint256(callResults[i].callValue),
          callResults[i].callData,
          callResults[i].returnData
        );
      } else {
        emit CallFailure(
          currentCall.to,
          uint256(callResults[i].callValue),
          callResults[i].callData,
          _decodeRevertReason(callResults[i].returnData)
        );

        break;
      }
    }
  }

  function _executeAdvanced(
    AdvancedCall[] memory calls
  ) public returns (AdvancedCallReturn[] memory callResults) {

    _enforceSelfCallFrom(this.executeAdvanced.selector);

    bool rollBack = false;
    callResults = new AdvancedCallReturn[](calls.length);

    for (uint256 i = 0; i < calls.length; i++) {
      AdvancedCall memory a = calls[i];
      uint256 callValue = uint256(a.value);
      bytes memory callData = a.data;
      uint256 callIndex;

      (bool ok, bytes memory returnData) = a.to.call{value: callValue}(callData);
      callResults[i] = AdvancedCallReturn({
          ok: ok,
          returnData: returnData,
          callValue: uint96(callValue),
          callData: callData
      });
      if (!ok) {
        rollBack = true;
        break;
      }

      for (uint256 j = 0; j < a.replaceValue.length; j++) {
        callIndex = uint256(a.replaceValue[j].callIndex);

        if (i >= callIndex) {
          revert("Cannot replace value using call that has not yet been performed.");
        }

        uint256 returnOffset = uint256(a.replaceValue[j].returnDataOffset);
        uint256 valueLength = uint256(a.replaceValue[j].valueLength);

        if (valueLength == 0 || valueLength > 32) {
          revert("bad valueLength");
        }

        if (returnData.length < returnOffset + valueLength) {
          revert("Return values are too short to give back a value at supplied index.");
        }

        AdvancedCall memory callTarget = calls[callIndex];
        uint256 valueOffset = 32 - valueLength;
        assembly {
          returndatacopy(
            add(add(callTarget, 32), valueOffset), returnOffset, valueLength
          )
        }
      }

      for (uint256 k = 0; k < a.replaceData.length; k++) {
        callIndex = uint256(a.replaceData[k].callIndex);

        if (i >= callIndex) {
          revert("Cannot replace data using call that has not yet been performed.");
        }

        uint256 callOffset = uint256(a.replaceData[k].callDataOffset);
        uint256 returnOffset = uint256(a.replaceData[k].returnDataOffset);
        uint256 dataLength = uint256(a.replaceData[k].dataLength);

        if (returnData.length < returnOffset + dataLength) {
          revert("Return values are too short to give back a value at supplied index.");
        }

        bytes memory callTargetData = calls[callIndex].data;

        if (callTargetData.length < callOffset + dataLength) {
          revert("Calldata too short to insert returndata at supplied offset.");
        }

        assembly {
          returndatacopy(
            add(callTargetData, add(32, callOffset)), returnOffset, dataLength
          )
        }
      }
    }

    if (rollBack) {
      bytes memory callResultsBytes = abi.encode(callResults);
      assembly { revert(add(32, callResultsBytes), mload(callResultsBytes)) }
    }
  }

  function simulate(
    Call[] calldata calls
  ) external /* view */ override returns (bool[] memory ok, bytes[] memory returnData) {

    for (uint256 i = 0; i < calls.length; i++) {
      if (calls[i].value == 0) {
        _ensureValidGenericCallTarget(calls[i].to);
      }
    }

    ok = new bool[](calls.length);
    returnData = new bytes[](calls.length);

    _selfCallContext = this.simulate.selector;

    (bool mustBeFalse, bytes memory rawCallResults) = address(this).call(
      abi.encodeWithSelector(
        this._simulate.selector, calls
      )
    );

    if (mustBeFalse) {
      revert("Simulation code must revert!");
    }

    delete _selfCallContext;

    CallReturn[] memory callResults = abi.decode(rawCallResults, (CallReturn[]));
    for (uint256 i = 0; i < callResults.length; i++) {
      ok[i] = callResults[i].ok;
      returnData[i] = callResults[i].returnData;

      if (!callResults[i].ok) {
        break;
      }
    }
  }

  function _simulate(
    Call[] calldata calls
  ) external returns (CallReturn[] memory callResults) {

    _enforceSelfCallFrom(this.simulate.selector);

    callResults = new CallReturn[](calls.length);

    for (uint256 i = 0; i < calls.length; i++) {
      (bool ok, bytes memory returnData) = calls[i].to.call{
        value: uint256(calls[i].value)
      }(calls[i].data);
      callResults[i] = CallReturn({ok: ok, returnData: returnData});
      if (!ok) {
        break;
      }
    }

    bytes memory callResultsBytes = abi.encode(callResults);
    assembly { revert(add(32, callResultsBytes), mload(callResultsBytes)) }
  }

  function simulateAdvanced(
    AdvancedCall[] calldata calls
  ) external /* view */ override returns (AdvancedCallReturn[] memory callResults) {

    for (uint256 i = 0; i < calls.length; i++) {
      if (calls[i].value == 0) {
        _ensureValidGenericCallTarget(calls[i].to);
      }
    }

    callResults = new AdvancedCallReturn[](calls.length);

    _selfCallContext = this.simulateAdvanced.selector;

    (bool mustBeFalse, bytes memory rawCallResults) = address(this).call(
      abi.encodeWithSelector(
        this._simulateAdvanced.selector, calls
      )
    );

    if (mustBeFalse) {
      revert("Simulation code must revert!");
    }

    if (
      rawCallResults.length > 68 && // prefix (4) + position (32) + length (32)
      rawCallResults[0] == bytes1(0x08) &&
      rawCallResults[1] == bytes1(0xc3) &&
      rawCallResults[2] == bytes1(0x79) &&
      rawCallResults[3] == bytes1(0xa0)
    ) {
      assembly {
        returndatacopy(0, 0, returndatasize())
        revert(0, returndatasize())
      }
    }

    delete _selfCallContext;

    callResults = abi.decode(rawCallResults, (AdvancedCallReturn[]));
  }

  function _simulateAdvanced(
    AdvancedCall[] calldata calls
  ) external /* view */ returns (AdvancedCallReturn[] memory callResults) {

    _enforceSelfCallFrom(this.simulateAdvanced.selector);

    callResults = new AdvancedCallReturn[](calls.length);

    for (uint256 i = 0; i < calls.length; i++) {
      AdvancedCall memory a = calls[i];
      uint256 callValue = uint256(a.value);
      bytes memory callData = a.data;
      uint256 callIndex;

      (bool ok, bytes memory returnData) = a.to.call{value: callValue}(callData);
      callResults[i] = AdvancedCallReturn({
          ok: ok,
          returnData: returnData,
          callValue: uint96(callValue),
          callData: callData
      });
      if (!ok) {
        break;
      }

      for (uint256 j = 0; j < a.replaceValue.length; j++) {
        callIndex = uint256(a.replaceValue[j].callIndex);

        if (i >= callIndex) {
          revert("Cannot replace value using call that has not yet been performed.");
        }

        uint256 returnOffset = uint256(a.replaceValue[j].returnDataOffset);
        uint256 valueLength = uint256(a.replaceValue[j].valueLength);

        if (valueLength == 0 || valueLength > 32) {
          revert("bad valueLength");
        }

        if (returnData.length < returnOffset + valueLength) {
          revert("Return values are too short to give back a value at supplied index.");
        }

        AdvancedCall memory callTarget = calls[callIndex];
        uint256 valueOffset = 32 - valueLength;
        assembly {
          returndatacopy(
            add(add(callTarget, 32), valueOffset), returnOffset, valueLength
          )
        }
      }

      for (uint256 k = 0; k < a.replaceData.length; k++) {
        callIndex = uint256(a.replaceData[k].callIndex);

        if (i >= callIndex) {
          revert("Cannot replace data using call that has not yet been performed.");
        }

        uint256 callOffset = uint256(a.replaceData[k].callDataOffset);
        uint256 returnOffset = uint256(a.replaceData[k].returnDataOffset);
        uint256 dataLength = uint256(a.replaceData[k].dataLength);

        if (returnData.length < returnOffset + dataLength) {
          revert("Return values are too short to give back a value at supplied index.");
        }

        bytes memory callTargetData = calls[callIndex].data;

        if (callTargetData.length < callOffset + dataLength) {
          revert("Calldata too short to insert returndata at supplied offset.");
        }

        assembly {
          returndatacopy(
            add(callTargetData, add(32, callOffset)), returnOffset, dataLength
          )
        }
      }
    }

    bytes memory callResultsBytes = abi.encode(callResults);
    assembly { revert(add(32, callResultsBytes), mload(callResultsBytes)) }
  }

  function claimOwnership(address newOwner) external override {

    require(
      msg.sender == merkleWalletClaimer,
      "Only the MerkleWalletClaimer contract can call this function."
    );

    require(
      _owner == address(0),
      "Cannot claim ownership with an owner already set."
    );

    require(newOwner != address(0), "New owner cannot be the zero address.");

    _setOwner(newOwner);
  }

  function transferOwnership(address newOwner) external override onlyOwner() {

    require(
      newOwner != address(0),
      "transferOwnership: new potential owner is the zero address."
    );

    _newPotentialOwner = newOwner;
  }

  function cancelOwnershipTransfer() external override onlyOwner() {

    delete _newPotentialOwner;
  }

  function acceptOwnership() external override {

    require(
      msg.sender == _newPotentialOwner,
      "acceptOwnership: current owner must set caller as new potential owner."
    );

    delete _newPotentialOwner;

    _setOwner(msg.sender);
  }

  function owner() external view override returns (address) {

    return _owner;
  }

  function isOwner() public view override returns (bool) {

    return msg.sender == _owner;
  }

  function isValidSignature(
    bytes32 digest,
    bytes memory signature
  ) external view returns (bytes4) {

    return ECDSA.recover(digest, signature) == _owner
      ? this.isValidSignature.selector
      : bytes4(0);
  }

  function getImplementation() external view override returns (address implementation) {

    (bool ok, bytes memory returnData) = _UPGRADE_BEACON.staticcall("");

    if (!(ok && returnData.length == 32)) {
      revert("Could not retrieve implementation.");
    }

    implementation = abi.decode(returnData, (address));
  }

  function getVersion() external pure override returns (uint256 version) {

    version = _VERSION;
  }

  function initialize(address) external pure override {}


  modifier onlyOwner() {

    require(isOwner(), "caller is not the owner.");
    _;
  }

  function _setOwner(address newOwner) internal {

    emit OwnershipTransferred(_owner, newOwner);

    _owner = newOwner;
  }

  function _enforceSelfCallFrom(bytes4 selfCallContext) internal {

    if (msg.sender != address(this) || _selfCallContext != selfCallContext) {
      revert("External accounts or unapproved internal functions cannot call this.");
    }

    delete _selfCallContext;
  }

  function _ensureValidGenericCallTarget(address to) internal view {

    if (!to.isContract()) {
      revert("Invalid `to` parameter - must supply a contract address containing code.");
    }

    if (to == address(this)) {
      revert("Invalid `to` parameter - cannot supply the address of this contract.");
    }
  }

  function _decodeRevertReason(
    bytes memory revertData
  ) internal pure returns (string memory revertReason) {

    if (
      revertData.length > 68 && // prefix (4) + position (32) + length (32)
      revertData[0] == bytes1(0x08) &&
      revertData[1] == bytes1(0xc3) &&
      revertData[2] == bytes1(0x79) &&
      revertData[3] == bytes1(0xa0)
    ) {
      bytes memory revertReasonBytes = new bytes(revertData.length - 4);
      for (uint256 i = 4; i < revertData.length; i++) {
        revertReasonBytes[i - 4] = revertData[i];
      }

      revertReason = abi.decode(revertReasonBytes, (string));
    } else {
      revertReason = "(no revert reason)";
    }
  }
}