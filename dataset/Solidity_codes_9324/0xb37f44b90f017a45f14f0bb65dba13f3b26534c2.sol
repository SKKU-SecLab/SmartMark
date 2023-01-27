pragma solidity 0.8.7;

abstract contract Proxied {
    modifier proxied() {
        address proxyAdminAddress = _proxyAdmin();
        if (proxyAdminAddress == address(0)) {
            assembly {
                sstore(
                    0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103,
                    0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
                )
            }
        } else {
            require(msg.sender == proxyAdminAddress);
        }
        _;
    }

    modifier onlyProxyAdmin() {
        require(msg.sender == _proxyAdmin(), "NOT_AUTHORIZED");
        _;
    }

    function _proxyAdmin() internal view returns (address adminAddress) {
        assembly {
            adminAddress := sload(
                0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103
            )
        }
    }
}// MIT
pragma solidity 0.8.7;


contract GaugeRegistry is Proxied {

    address[] public gauges;
    mapping(address => address) public gaugeToVault;

    event AddGauge(address gauge, address vault);
    event RemoveGauge(address gauge, address vault);

    constructor() {} // solhint-disable no-empty-blocks

    function addGauge(address newGauge, address vault) external onlyProxyAdmin {

        require(
            gaugeToVault[newGauge] == address(0),
            "GaugeRegistry: gauge already added"
        );
        gauges.push(newGauge);
        gaugeToVault[newGauge] = vault;
        emit AddGauge(newGauge, vault);
    }

    function removeGauge(address gauge) external onlyProxyAdmin {

        _removeFromArray(gauge);
        emit RemoveGauge(gauge, gaugeToVault[gauge]);
        delete gaugeToVault[gauge];
    }

    function _removeFromArray(address target) internal {

        uint256 index = 1 ether;
        address[] memory _gauges = gauges;
        for (uint256 i = 0; i < _gauges.length; i++) {
            if (_gauges[i] == target) {
                index = i;
                break;
            }
        }
        require(index < 1 ether, "GaugeRegistry: element not found");
        gauges[index] = _gauges[_gauges.length - 1];
        gauges.pop();
    }
}