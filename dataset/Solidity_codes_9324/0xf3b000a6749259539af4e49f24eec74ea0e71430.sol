
pragma solidity ^0.7.3;

contract Governed {


    address public governor;
    address public pendingGovernor;


    event NewPendingOwnership(address indexed from, address indexed to);
    event NewOwnership(address indexed from, address indexed to);

    modifier onlyGovernor {

        require(msg.sender == governor, "Only Governor can call");
        _;
    }

    function _initialize(address _initGovernor) internal {

        governor = _initGovernor;
    }

    function transferOwnership(address _newGovernor) external onlyGovernor {

        require(_newGovernor != address(0), "Governor must be set");

        address oldPendingGovernor = pendingGovernor;
        pendingGovernor = _newGovernor;

        emit NewPendingOwnership(oldPendingGovernor, pendingGovernor);
    }

    function acceptOwnership() external {

        require(
            pendingGovernor != address(0) && msg.sender == pendingGovernor,
            "Caller must be pending governor"
        );

        address oldGovernor = governor;
        address oldPendingGovernor = pendingGovernor;

        governor = pendingGovernor;
        pendingGovernor = address(0);

        emit NewOwnership(oldGovernor, governor);
        emit NewPendingOwnership(oldPendingGovernor, pendingGovernor);
    }
}// MIT

pragma solidity ^0.7.3;

interface IGraphProxy {

    function admin() external returns (address);


    function setAdmin(address _newAdmin) external;


    function implementation() external returns (address);


    function pendingImplementation() external returns (address);


    function upgradeTo(address _newImplementation) external;


    function acceptUpgrade() external;


    function acceptUpgradeAndCall(bytes calldata data) external;

}// MIT

pragma solidity ^0.7.3;


contract GraphUpgradeable {

    bytes32
        internal constant IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;

    modifier onlyProxyAdmin(IGraphProxy _proxy) {

        require(msg.sender == _proxy.admin(), "Caller must be the proxy admin");
        _;
    }

    modifier onlyImpl {

        require(msg.sender == _implementation(), "Caller must be the implementation");
        _;
    }

    function _implementation() internal view returns (address impl) {

        bytes32 slot = IMPLEMENTATION_SLOT;
        assembly {
            impl := sload(slot)
        }
    }

    function acceptProxy(IGraphProxy _proxy) external onlyProxyAdmin(_proxy) {

        _proxy.acceptUpgrade();
    }

    function acceptProxyAndCall(IGraphProxy _proxy, bytes calldata _data)
        external
        onlyProxyAdmin(_proxy)
    {

        _proxy.acceptUpgradeAndCall(_data);
    }
}// MIT

pragma solidity ^0.7.3;



contract GraphProxyAdmin is Governed {


    constructor() {
        Governed._initialize(msg.sender);
    }

    function getProxyImplementation(IGraphProxy _proxy) public view returns (address) {

        (bool success, bytes memory returndata) = address(_proxy).staticcall(hex"5c60da1b");
        require(success);
        return abi.decode(returndata, (address));
    }

    function getProxyPendingImplementation(IGraphProxy _proxy) public view returns (address) {

        (bool success, bytes memory returndata) = address(_proxy).staticcall(hex"396f7b23");
        require(success);
        return abi.decode(returndata, (address));
    }

    function getProxyAdmin(IGraphProxy _proxy) public view returns (address) {

        (bool success, bytes memory returndata) = address(_proxy).staticcall(hex"f851a440");
        require(success);
        return abi.decode(returndata, (address));
    }

    function changeProxyAdmin(IGraphProxy _proxy, address _newAdmin) public onlyGovernor {

        _proxy.setAdmin(_newAdmin);
    }

    function upgrade(IGraphProxy _proxy, address _implementation) public onlyGovernor {

        _proxy.upgradeTo(_implementation);
    }

    function acceptProxy(GraphUpgradeable _implementation, IGraphProxy _proxy) public onlyGovernor {

        _implementation.acceptProxy(_proxy);
    }

    function acceptProxyAndCall(
        GraphUpgradeable _implementation,
        IGraphProxy _proxy,
        bytes calldata _data
    ) external onlyGovernor {

        _implementation.acceptProxyAndCall(_proxy, _data);
    }
}