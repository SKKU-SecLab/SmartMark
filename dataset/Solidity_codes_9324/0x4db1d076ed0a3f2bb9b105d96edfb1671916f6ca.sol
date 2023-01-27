pragma solidity ^0.6.6;


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
}
pragma solidity ^0.6.6;


contract ACOProxy {

    
    event ProxyAdminUpdated(address previousAdmin, address newAdmin);
    
    event SetImplementation(address previousImplementation, address newImplementation);
    
    bytes32 private constant adminPosition = keccak256("acoproxy.admin");
    
    bytes32 private constant implementationPosition = keccak256("acoproxy.implementation");

    modifier onlyAdmin() {

        require(msg.sender == admin(), "ACOProxy::onlyAdmin");
        _;
    }
    
    constructor(address _admin, address _implementation, bytes memory _initdata) public {
        _setAdmin(_admin);
        _setImplementation(_implementation, _initdata);
    }

    fallback() external payable {
        address addr = implementation();
        assembly {
            calldatacopy(0, 0, calldatasize())
            let result := delegatecall(gas(), addr, 0, calldatasize(), 0, 0)
            returndatacopy(0, 0, returndatasize())
            switch result
            case 0 { revert(0, returndatasize()) }
            default { return(0, returndatasize()) }
        }
    }
    
    function proxyType() public pure returns(uint256) {

        return 2; 
    }
    
    function admin() public view returns (address adm) {

        bytes32 position = adminPosition;
        assembly {
            adm := sload(position)
        }
    }
    
    function implementation() public view returns (address impl) {

        bytes32 position = implementationPosition;
        assembly {
            impl := sload(position)
        }
    }

    function transferProxyAdmin(address newAdmin) external onlyAdmin {

        _setAdmin(newAdmin);
    }
    
    function setImplementation(address newImplementation, bytes calldata initData) external onlyAdmin {

        _setImplementation(newImplementation, initData);
    }

    function _setAdmin(address newAdmin) internal {

        require(newAdmin != address(0), "ACOProxy::_setAdmin: Invalid admin");
        
        emit ProxyAdminUpdated(admin(), newAdmin);
        
        bytes32 position = adminPosition;
        assembly {
            sstore(position, newAdmin)
        }
    }
    
    function _setImplementation(address newImplementation, bytes memory initData) internal {

        require(Address.isContract(newImplementation), "ACOProxy::_setImplementation: Invalid implementation");
        
        emit SetImplementation(implementation(), newImplementation);
        
        bytes32 position = implementationPosition;
        assembly {
            sstore(position, newImplementation)
        }
        if (initData.length > 0) {
            (bool success,) = newImplementation.delegatecall(initData);
            assert(success);
        }
    }
}
