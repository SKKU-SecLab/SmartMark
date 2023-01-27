
pragma solidity 0.5.11; // optimization runs: 200, evm version: petersburg


interface DharmaSmartWalletFactoryV1Interface {

  event SmartWalletDeployed(address wallet, address userSigningKey);

  function newSmartWallet(
    address userSigningKey
  ) external returns (address wallet);

  
  function getNextSmartWallet(
    address userSigningKey
  ) external view returns (address wallet);

}


interface DharmaSmartWalletInitializer {

  function initialize(address userSigningKey) external;

}


contract UpgradeBeaconProxyV1Prototype {

  address private constant _UPGRADE_BEACON = address(
    0x5BF07ceDF1296B1C11966832c3e75895ad6E1E2a
  );

  constructor(bytes memory initializationCalldata) public payable {
    (bool ok, ) = _implementation().delegatecall(initializationCalldata);
    
    if (!ok) {
      assembly {
        returndatacopy(0, 0, returndatasize)
        revert(0, returndatasize)
      }
    }
  }

  function () external payable {
    _delegate(_implementation());
  }

  function _implementation() private view returns (address implementation) {

    (bool ok, bytes memory returnData) = _UPGRADE_BEACON.staticcall("");
    
    require(ok, string(returnData));

    implementation = abi.decode(returnData, (address));
  }

  function _delegate(address implementation) private {

    assembly {
      calldatacopy(0, 0, calldatasize)

      let result := delegatecall(gas, implementation, 0, calldatasize, 0, 0)

      returndatacopy(0, 0, returndatasize)

      switch result
      case 0 { revert(0, returndatasize) }
      default { return(0, returndatasize) }
    }
  }
}


contract DharmaSmartWalletFactoryV1Prototype is DharmaSmartWalletFactoryV1Interface {

  DharmaSmartWalletInitializer private _INITIALIZER;

  function newSmartWallet(
    address userSigningKey
  ) external returns (address wallet) {

    bytes memory initializationCalldata = abi.encodeWithSelector(
      _INITIALIZER.initialize.selector,
      userSigningKey
    );
    
    wallet = _deployUpgradeBeaconProxyInstance(initializationCalldata);

    emit SmartWalletDeployed(wallet, userSigningKey);
  }

  function getNextSmartWallet(
    address userSigningKey
  ) external view returns (address wallet) {

    bytes memory initializationCalldata = abi.encodeWithSelector(
      _INITIALIZER.initialize.selector,
      userSigningKey
    );
    
    wallet = _computeNextAddress(initializationCalldata);
  }

  function _deployUpgradeBeaconProxyInstance(
    bytes memory initializationCalldata
  ) private returns (address upgradeBeaconProxyInstance) {

    bytes memory initCode = abi.encodePacked(
      type(UpgradeBeaconProxyV1Prototype).creationCode,
      abi.encode(initializationCalldata)
    );

    (uint256 salt, ) = _getSaltAndTarget(initCode);

    assembly {
      let encoded_data := add(0x20, initCode) // load initialization code.
      let encoded_size := mload(initCode)     // load the init code's length.
      upgradeBeaconProxyInstance := create2(  // call `CREATE2` w/ 4 arguments.
        callvalue,                            // forward any supplied endowment.
        encoded_data,                         // pass in initialization code.
        encoded_size,                         // pass in init code's length.
        salt                                  // pass in the salt value.
      )

      if iszero(upgradeBeaconProxyInstance) {
        returndatacopy(0, 0, returndatasize)
        revert(0, returndatasize)
      }
    }
  }

  function _computeNextAddress(
    bytes memory initializationCalldata
  ) private view returns (address target) {

    bytes memory initCode = abi.encodePacked(
      type(UpgradeBeaconProxyV1Prototype).creationCode,
      abi.encode(initializationCalldata)
    );

    (, target) = _getSaltAndTarget(initCode);
  }

  function _getSaltAndTarget(
    bytes memory initCode
  ) private view returns (uint256 nonce, address target) {

    bytes32 initCodeHash = keccak256(initCode);

    nonce = 0;
    
    uint256 codeSize;

    while (true) {
      target = address(            // derive the target deployment address.
        uint160(                   // downcast to match the address type.
          uint256(                 // cast to uint to truncate upper digits.
            keccak256(             // compute CREATE2 hash using 4 inputs.
              abi.encodePacked(    // pack all inputs to the hash together.
                bytes1(0xff),      // pass in the control character.
                address(this),     // pass in the address of this contract.
                nonce,              // pass in the salt from above.
                initCodeHash       // pass in hash of contract creation code.
              )
            )
          )
        )
      );

      assembly { codeSize := extcodesize(target) }

      if (codeSize == 0) {
        break;
      }

      nonce++;
    }
  }
}