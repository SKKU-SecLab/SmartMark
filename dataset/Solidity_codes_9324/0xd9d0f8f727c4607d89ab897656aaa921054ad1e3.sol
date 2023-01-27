

pragma solidity 0.4.24;

contract EternalStorage {

    mapping(bytes32 => uint256) internal uintStorage;
    mapping(bytes32 => string) internal stringStorage;
    mapping(bytes32 => address) internal addressStorage;
    mapping(bytes32 => bytes) internal bytesStorage;
    mapping(bytes32 => bool) internal boolStorage;
    mapping(bytes32 => int256) internal intStorage;

}


pragma solidity ^0.4.24;


library AddressUtils {


  function isContract(address _addr) internal view returns (bool) {

    uint256 size;
    assembly { size := extcodesize(_addr) }
    return size > 0;
  }

}


pragma solidity 0.4.24;

contract Proxy {

    function implementation() public view returns (address);


    function() public payable {
        address _impl = implementation();
        require(_impl != address(0));
        assembly {
            let ptr := mload(0x40)
            calldatacopy(ptr, 0, calldatasize)
            let result := delegatecall(gas, _impl, ptr, calldatasize, 0, 0)
            mstore(0x40, add(ptr, returndatasize))
            returndatacopy(ptr, 0, returndatasize)

            switch result
                case 0 {
                    revert(ptr, returndatasize)
                }
                default {
                    return(ptr, returndatasize)
                }
        }
    }
}


pragma solidity 0.4.24;

contract UpgradeabilityStorage {

    uint256 internal _version;

    address internal _implementation;

    function version() external view returns (uint256) {

        return _version;
    }

    function implementation() public view returns (address) {

        return _implementation;
    }
}


pragma solidity 0.4.24;




contract UpgradeabilityProxy is Proxy, UpgradeabilityStorage {

    event Upgraded(uint256 version, address indexed implementation);

    function _upgradeTo(uint256 version, address implementation) internal {

        require(_implementation != implementation);

        require(AddressUtils.isContract(implementation));

        require(version > _version);

        _version = version;
        _implementation = implementation;
        emit Upgraded(version, implementation);
    }
}


pragma solidity 0.4.24;

contract UpgradeabilityOwnerStorage {

    address internal _upgradeabilityOwner;

    function upgradeabilityOwner() public view returns (address) {

        return _upgradeabilityOwner;
    }

    function setUpgradeabilityOwner(address newUpgradeabilityOwner) internal {

        _upgradeabilityOwner = newUpgradeabilityOwner;
    }
}


pragma solidity 0.4.24;



contract OwnedUpgradeabilityProxy is UpgradeabilityOwnerStorage, UpgradeabilityProxy {

    event ProxyOwnershipTransferred(address previousOwner, address newOwner);

    constructor() public {
        setUpgradeabilityOwner(msg.sender);
    }

    modifier onlyUpgradeabilityOwner() {

        require(msg.sender == upgradeabilityOwner());
        _;
    }

    function transferProxyOwnership(address newOwner) external onlyUpgradeabilityOwner {

        require(newOwner != address(0));
        emit ProxyOwnershipTransferred(upgradeabilityOwner(), newOwner);
        setUpgradeabilityOwner(newOwner);
    }

    function upgradeTo(uint256 version, address implementation) public onlyUpgradeabilityOwner {

        _upgradeTo(version, implementation);
    }

    function upgradeToAndCall(uint256 version, address implementation, bytes data)
        external
        payable
        onlyUpgradeabilityOwner
    {

        upgradeTo(version, implementation);
        require(address(this).call.value(msg.value)(data));
    }
}


pragma solidity 0.4.24;



contract EternalStorageProxy is EternalStorage, OwnedUpgradeabilityProxy {}
