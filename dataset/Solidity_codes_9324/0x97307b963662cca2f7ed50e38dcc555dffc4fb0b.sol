
pragma solidity ^0.7.0;

library Address {

    function isContract(address account) internal view returns (bool) {


        uint256 size;
        assembly { size := extcodesize(account) }
        return size > 0;
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

        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {

        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {

        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {

        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {

        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {

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
}// MIT

pragma solidity ^0.7.3;

contract GraphProxyStorage {

    bytes32
        internal constant IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;

    bytes32
        internal constant PENDING_IMPLEMENTATION_SLOT = 0x9e5eddc59e0b171f57125ab86bee043d9128098c3a6b9adb4f2e86333c2f6f8c;

    bytes32
        internal constant ADMIN_SLOT = 0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103;

    event PendingImplementationUpdated(
        address indexed oldPendingImplementation,
        address indexed newPendingImplementation
    );

    event ImplementationUpdated(
        address indexed oldImplementation,
        address indexed newImplementation
    );

    event AdminUpdated(address indexed oldAdmin, address indexed newAdmin);

    modifier onlyAdmin() {

        require(msg.sender == _admin(), "Caller must be admin");
        _;
    }

    function _admin() internal view returns (address adm) {

        bytes32 slot = ADMIN_SLOT;
        assembly {
            adm := sload(slot)
        }
    }

    function _setAdmin(address _newAdmin) internal {

        bytes32 slot = ADMIN_SLOT;
        assembly {
            sstore(slot, _newAdmin)
        }

        emit AdminUpdated(_admin(), _newAdmin);
    }

    function _implementation() internal view returns (address impl) {

        bytes32 slot = IMPLEMENTATION_SLOT;
        assembly {
            impl := sload(slot)
        }
    }

    function _pendingImplementation() internal view returns (address impl) {

        bytes32 slot = PENDING_IMPLEMENTATION_SLOT;
        assembly {
            impl := sload(slot)
        }
    }

    function _setImplementation(address _newImplementation) internal {

        address oldImplementation = _implementation();

        bytes32 slot = IMPLEMENTATION_SLOT;
        assembly {
            sstore(slot, _newImplementation)
        }

        emit ImplementationUpdated(oldImplementation, _newImplementation);
    }

    function _setPendingImplementation(address _newImplementation) internal {

        address oldPendingImplementation = _pendingImplementation();

        bytes32 slot = PENDING_IMPLEMENTATION_SLOT;
        assembly {
            sstore(slot, _newImplementation)
        }

        emit PendingImplementationUpdated(oldPendingImplementation, _newImplementation);
    }
}// MIT

pragma solidity ^0.7.3;



contract GraphProxy is GraphProxyStorage {

    modifier ifAdmin() {

        if (msg.sender == _admin()) {
            _;
        } else {
            _fallback();
        }
    }

    modifier ifAdminOrPendingImpl() {

        if (msg.sender == _admin() || msg.sender == _pendingImplementation()) {
            _;
        } else {
            _fallback();
        }
    }

    constructor(address _impl, address _admin) {
        assert(ADMIN_SLOT == bytes32(uint256(keccak256("eip1967.proxy.admin")) - 1));
        assert(
            IMPLEMENTATION_SLOT == bytes32(uint256(keccak256("eip1967.proxy.implementation")) - 1)
        );
        assert(
            PENDING_IMPLEMENTATION_SLOT ==
                bytes32(uint256(keccak256("eip1967.proxy.pendingImplementation")) - 1)
        );

        _setAdmin(_admin);
        _setPendingImplementation(_impl);
    }

    function admin() external ifAdminOrPendingImpl returns (address) {

        return _admin();
    }

    function implementation() external ifAdminOrPendingImpl returns (address) {

        return _implementation();
    }

    function pendingImplementation() external ifAdminOrPendingImpl returns (address) {

        return _pendingImplementation();
    }

    function setAdmin(address _newAdmin) external ifAdmin {

        require(_newAdmin != address(0), "Cannot change the admin of a proxy to the zero address");
        _setAdmin(_newAdmin);
    }

    function upgradeTo(address _newImplementation) external ifAdmin {

        _setPendingImplementation(_newImplementation);
    }

    function acceptUpgrade() external ifAdminOrPendingImpl {

        _acceptUpgrade();
    }

    function acceptUpgradeAndCall(bytes calldata data) external ifAdminOrPendingImpl {

        _acceptUpgrade();
        (bool success, ) = _implementation().delegatecall(data);
        require(success);
    }

    function _acceptUpgrade() internal {

        address _pendingImplementation = _pendingImplementation();
        require(Address.isContract(_pendingImplementation), "Implementation must be a contract");
        require(
            _pendingImplementation != address(0) && msg.sender == _pendingImplementation,
            "Caller must be the pending implementation"
        );

        _setImplementation(_pendingImplementation);
        _setPendingImplementation(address(0));
    }

    function _fallback() internal {

        require(msg.sender != _admin(), "Cannot fallback to proxy target");

        assembly {
            let ptr := mload(0x40)

            let impl := and(sload(IMPLEMENTATION_SLOT), 0xffffffffffffffffffffffffffffffffffffffff)

            calldatacopy(ptr, 0, calldatasize())

            let result := delegatecall(gas(), impl, ptr, calldatasize(), 0, 0)
            let size := returndatasize()

            returndatacopy(ptr, 0, size)

            switch result
                case 0 {
                    revert(ptr, size)
                }
                default {
                    return(ptr, size)
                }
        }
    }

    fallback() external payable {
        _fallback();
    }

    receive() external payable {
        _fallback();
    }
}