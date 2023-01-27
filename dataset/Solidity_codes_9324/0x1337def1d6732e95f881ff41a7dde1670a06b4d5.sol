


pragma solidity 0.8.4;

abstract contract Proxy {
    fallback() external payable {
        address _impl = implementation();
        require(_impl != address(0));

        assembly {
            let ptr := mload(0x40)
            calldatacopy(ptr, 0, calldatasize())
            let result := delegatecall(gas(), _impl, ptr, calldatasize(), 0, 0)
            let size := returndatasize()
            returndatacopy(ptr, 0, size)

            switch result
            case 0 { revert(ptr, size) }
            default { return(ptr, size) }
            }
    }

    function implementation() public view virtual returns (address);
}



pragma solidity 0.8.4;

contract UpgradeabilityProxy is Proxy {

    event Upgraded(address indexed implementation);

    bytes32 private constant IMPLEMENTATION_POSITION = keccak256("org.armor.proxy.implementation");

    constructor() public {}

    function implementation() public view override returns (address impl) {

        bytes32 position = IMPLEMENTATION_POSITION;
        assembly {
            impl := sload(position)
        }
    }

    function _setImplementation(address _newImplementation) internal {

        bytes32 position = IMPLEMENTATION_POSITION;
        assembly {
        sstore(position, _newImplementation)
        }
    }

    function _upgradeTo(address _newImplementation) internal {

        address currentImplementation = implementation();
        require(currentImplementation != _newImplementation);
        _setImplementation(_newImplementation);
        emit Upgraded(_newImplementation);
    }
}




pragma solidity 0.8.4;

contract OwnedUpgradeabilityProxy is UpgradeabilityProxy {

    event ProxyOwnershipTransferred(address previousOwner, address newOwner);

    bytes32 private constant PROXY_OWNER_POSITION = keccak256("org.armor.proxy.owner");

    constructor(address _implementation) public {
        _setUpgradeabilityOwner(msg.sender);
        _upgradeTo(_implementation);
    }

    modifier onlyProxyOwner() {

        require(msg.sender == proxyOwner());
        _;
    }

    function proxyOwner() public view returns (address owner) {

        bytes32 position = PROXY_OWNER_POSITION;
        assembly {
            owner := sload(position)
        }
    }

    function transferProxyOwnership(address _newOwner) public onlyProxyOwner {

        require(_newOwner != address(0));
        _setUpgradeabilityOwner(_newOwner);
        emit ProxyOwnershipTransferred(proxyOwner(), _newOwner);
    }

    function upgradeTo(address _implementation) public onlyProxyOwner {

        _upgradeTo(_implementation);
    }

    function _setUpgradeabilityOwner(address _newProxyOwner) internal {

        bytes32 position = PROXY_OWNER_POSITION;
        assembly {
            sstore(position, _newProxyOwner)
        }
    }
}