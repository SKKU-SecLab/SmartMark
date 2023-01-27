pragma solidity ^0.7.0;
pragma experimental ABIEncoderV2;

contract PrismProxy {


    struct ProxyStorage {
        address admin;

        address pendingAdmin;

        address implementation;

        address pendingImplementation;

        uint8 version;
    }

    bytes32 constant PRISM_PROXY_STORAGE_POSITION = keccak256("prism.proxy.storage");

    event NewPendingImplementation(address indexed oldPendingImplementation, address indexed newPendingImplementation);

    event NewImplementation(address indexed oldImplementation, address indexed newImplementation);

    event NewPendingAdmin(address indexed oldPendingAdmin, address indexed newPendingAdmin);

    event NewAdmin(address indexed oldAdmin, address indexed newAdmin);

    function proxyStorage() internal pure returns (ProxyStorage storage ps) {        

        bytes32 position = PRISM_PROXY_STORAGE_POSITION;
        assembly {
            ps.slot := position
        }
    }

    
    function setPendingProxyImplementation(address newPendingImplementation) public returns (bool) {

        ProxyStorage storage s = proxyStorage();
        require(msg.sender == s.admin, "Prism::setPendingProxyImp: caller must be admin");

        address oldPendingImplementation = s.pendingImplementation;

        s.pendingImplementation = newPendingImplementation;

        emit NewPendingImplementation(oldPendingImplementation, s.pendingImplementation);

        return true;
    }

    function acceptProxyImplementation() public returns (bool) {

        ProxyStorage storage s = proxyStorage();
        require(msg.sender == s.pendingImplementation && s.pendingImplementation != address(0), "Prism::acceptProxyImp: caller must be pending implementation");
 
        address oldImplementation = s.implementation;
        address oldPendingImplementation = s.pendingImplementation;

        s.implementation = s.pendingImplementation;

        s.pendingImplementation = address(0);
        s.version++;

        emit NewImplementation(oldImplementation, s.implementation);
        emit NewPendingImplementation(oldPendingImplementation, s.pendingImplementation);

        return true;
    }

    function setPendingProxyAdmin(address newPendingAdmin) public returns (bool) {

        ProxyStorage storage s = proxyStorage();
        require(msg.sender == s.admin, "Prism::setPendingProxyAdmin: caller must be admin");

        address oldPendingAdmin = s.pendingAdmin;

        s.pendingAdmin = newPendingAdmin;

        emit NewPendingAdmin(oldPendingAdmin, newPendingAdmin);

        return true;
    }

    function acceptProxyAdmin() public returns (bool) {

        ProxyStorage storage s = proxyStorage();
        require(msg.sender == s.pendingAdmin && msg.sender != address(0), "Prism::acceptProxyAdmin: caller must be pending admin");

        address oldAdmin = s.admin;
        address oldPendingAdmin = s.pendingAdmin;

        s.admin = s.pendingAdmin;

        s.pendingAdmin = address(0);

        emit NewAdmin(oldAdmin, s.admin);
        emit NewPendingAdmin(oldPendingAdmin, s.pendingAdmin);

        return true;
    }

    function proxyAdmin() public view returns (address) {

        ProxyStorage storage s = proxyStorage();
        return s.admin;
    }

    function pendingProxyAdmin() public view returns (address) {

        ProxyStorage storage s = proxyStorage();
        return s.pendingAdmin;
    }

    function proxyImplementation() public view returns (address) {

        ProxyStorage storage s = proxyStorage();
        return s.implementation;
    }

    function pendingProxyImplementation() public view returns (address) {

        ProxyStorage storage s = proxyStorage();
        return s.pendingImplementation;
    }

    function proxyImplementationVersion() public view returns (uint8) {

        ProxyStorage storage s = proxyStorage();
        return s.version;
    }

    function _forwardToImplementation() internal {

        ProxyStorage storage s = proxyStorage();
        (bool success, ) = s.implementation.delegatecall(msg.data);

        assembly {
              let free_mem_ptr := mload(0x40)
              returndatacopy(free_mem_ptr, 0, returndatasize())

              switch success
              case 0 { revert(free_mem_ptr, returndatasize()) }
              default { return(free_mem_ptr, returndatasize()) }
        }
    }
}// MIT
pragma solidity ^0.7.0;


contract VotingPowerPrism is PrismProxy {


    constructor(address _admin) {
        ProxyStorage storage s = proxyStorage();
        s.admin = _admin;
    }

    receive() external payable {
        _forwardToImplementation();
    }

    fallback() external payable {
        _forwardToImplementation();
    }
}