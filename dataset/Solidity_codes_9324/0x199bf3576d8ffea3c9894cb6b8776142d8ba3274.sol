


pragma solidity 0.7.5;

contract EternalStorage {

    mapping(bytes32 => uint256) internal uintStorage;
    mapping(bytes32 => string) internal stringStorage;
    mapping(bytes32 => address) internal addressStorage;
    mapping(bytes32 => bytes) internal bytesStorage;
    mapping(bytes32 => bool) internal boolStorage;
    mapping(bytes32 => int256) internal intStorage;
}



pragma solidity ^0.7.0;

library Address {

    function isContract(address account) internal view returns (bool) {

        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {

      return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {

        return _functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {

        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {

        require(address(this).balance >= value, "Address: insufficient balance for call");
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(address target, bytes memory data, uint256 weiValue, string memory errorMessage) private returns (bytes memory) {

        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{ value: weiValue }(data);
        if (success) {
            return returndata;
        } else {
            if (returndata.length > 0) {

                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}


pragma solidity 0.7.5;

abstract contract Proxy {
    function implementation() public view virtual returns (address);

    fallback() external payable {
        address _impl = implementation();
        require(_impl != address(0));
        assembly {
            let ptr := mload(0x40)
            calldatacopy(ptr, 0, calldatasize())
            let result := delegatecall(gas(), _impl, ptr, calldatasize(), 0, 0)
            mstore(0x40, add(ptr, returndatasize()))
            returndatacopy(ptr, 0, returndatasize())

            switch result
                case 0 {
                    revert(ptr, returndatasize())
                }
                default {
                    return(ptr, returndatasize())
                }
        }
    }
}


pragma solidity 0.7.5;

contract UpgradeabilityStorage {

    uint256 internal _version;

    address internal _implementation;

    function version() external view returns (uint256) {

        return _version;
    }

    function implementation() public view virtual returns (address) {

        return _implementation;
    }
}


pragma solidity 0.7.5;




contract UpgradeabilityProxy is Proxy, UpgradeabilityStorage {

    event Upgraded(uint256 version, address indexed implementation);

    function implementation() public view override(Proxy, UpgradeabilityStorage) returns (address) {

        return UpgradeabilityStorage.implementation();
    }

    function _upgradeTo(uint256 version, address implementation) internal {

        require(_implementation != implementation);

        require(Address.isContract(implementation));

        require(version > _version);

        _version = version;
        _implementation = implementation;
        emit Upgraded(version, implementation);
    }
}


pragma solidity 0.7.5;

contract UpgradeabilityOwnerStorage {

    address internal _upgradeabilityOwner;

    function upgradeabilityOwner() public view returns (address) {

        return _upgradeabilityOwner;
    }

    function setUpgradeabilityOwner(address newUpgradeabilityOwner) internal {

        _upgradeabilityOwner = newUpgradeabilityOwner;
    }
}


pragma solidity 0.7.5;



contract OwnedUpgradeabilityProxy is UpgradeabilityOwnerStorage, UpgradeabilityProxy {

    event ProxyOwnershipTransferred(address previousOwner, address newOwner);

    constructor() {
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

    function upgradeToAndCall(
        uint256 version,
        address implementation,
        bytes calldata data
    ) external payable onlyUpgradeabilityOwner {

        upgradeTo(version, implementation);
        (bool status, ) = address(this).call{ value: msg.value }(data);
        require(status);
    }
}


pragma solidity 0.7.5;



contract EternalStorageProxy is EternalStorage, OwnedUpgradeabilityProxy {


}