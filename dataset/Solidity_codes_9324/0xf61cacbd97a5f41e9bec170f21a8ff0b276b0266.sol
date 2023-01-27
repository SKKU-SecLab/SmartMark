
pragma solidity >=0.6.0 <0.8.0;

library SafeMath {

    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b > a) return (false, 0);
        return (true, a - b);
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b == 0) return (false, 0);
        return (true, a / b);
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b == 0) return (false, 0);
        return (true, a % b);
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b <= a, "SafeMath: subtraction overflow");
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0, "SafeMath: division by zero");
        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0, "SafeMath: modulo by zero");
        return a % b;
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b <= a, errorMessage);
        return a - b;
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        return a / b;
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        return a % b;
    }
}// MIT

pragma solidity >=0.6.2 <0.8.0;

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

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {

        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {

        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
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
}// UNLICENSED
pragma solidity 0.7.0;

contract UpgradeabilityProxy {


    using SafeMath for uint;

    bytes32 private constant proxyOwnerPosition = keccak256("proxy.owner");
    bytes32 private constant newProxyOwnerPosition = keccak256("proxy.newOwner");
    bytes32 private constant implementationPosition = keccak256("proxy.implementation");
    bytes32 private constant newImplementationPosition = keccak256("proxy.newImplementation");
    bytes32 private constant timelockPosition = keccak256("proxy.timelock");
    uint public constant timelockPeriod = 21600; // 6 hours

    constructor (address _proxyOwner, address implementation_, bytes memory initializationData, bool forceCall) {
        _setProxyOwner(_proxyOwner);
        _setImplementation(implementation_);
        if (initializationData.length > 0 || forceCall) {
            Address.functionDelegateCall(_implementation(), initializationData);
        }
    }


    modifier ifProxyOwner() {

        if (msg.sender == _proxyOwner()) {
            _;
        } else {
            _delegate(_implementation());
        }
    }

    function _proxyOwner() internal view returns (address proxyOwner_) {

        bytes32 position = proxyOwnerPosition;
        assembly {
            proxyOwner_ := sload(position)
        }
    }

    function proxyOwner() public ifProxyOwner returns (address proxyOwner_) {

        return _proxyOwner();
    }

    function newProxyOwner() public ifProxyOwner returns (address _newProxyOwner) {

        bytes32 position = newProxyOwnerPosition;
        assembly {
            _newProxyOwner := sload(position)
        }
    }

    function _setProxyOwner(address _newProxyOwner) private {

        bytes32 position = proxyOwnerPosition;
        assembly {
            sstore(position, _newProxyOwner)
        }
    }

    function setNewProxyOwner(address _newProxyOwner) public ifProxyOwner {

        bytes32 position = newProxyOwnerPosition; 
        assembly {
            sstore(position, _newProxyOwner)
        }
    }

    function transferProxyOwnership() public {

        address _newProxyOwner = newProxyOwner();
        if (msg.sender == _newProxyOwner) {
            _setProxyOwner(_newProxyOwner);
        } else {
            _delegate(_implementation());
        }
    }

    function _implementation() private view returns (address implementation_) {

        bytes32 position = implementationPosition;
        assembly {
            implementation_ := sload(position)
        }
    }
    

    function implementation() public ifProxyOwner returns (address implementation_) {

        return _implementation();
    }

    function newImplementation() public ifProxyOwner returns (address _newImplementation) {

        bytes32 position = newImplementationPosition;
        assembly {
            _newImplementation := sload(position)
        }
    } 

    function timelock() public ifProxyOwner returns (uint _timelock) {

        bytes32 position = timelockPosition;
        assembly {
            _timelock := sload(position)
        }
    }

    function _setTimelock(uint newTimelock) private {

        bytes32 position = timelockPosition;
        assembly {
            sstore(position, newTimelock)
        }
    }

    function _setImplementation(address _newImplementation) private {

        bytes32 position = implementationPosition;
        assembly {
            sstore(position, _newImplementation)
        }
    }


    function setNewImplementation(address _newImplementation) public ifProxyOwner {

        bytes32 position = newImplementationPosition; 
        assembly {
            sstore(position, _newImplementation)
        }
        uint newTimelock = block.timestamp.add(timelockPeriod);
        _setTimelock(newTimelock);
    }

    function transferImplementation() public ifProxyOwner {

        require(block.timestamp >= timelock(), "UpgradeabilityProxy: cannot transfer implementation yet.");
        _setImplementation(newImplementation());
    }

    function _delegate(address _implementation) internal virtual {

        assembly {
            calldatacopy(0, 0, calldatasize())


            let result := delegatecall(gas(), _implementation, 0, calldatasize(), 0, 0)

            returndatacopy(0, 0, returndatasize())

            switch result
            case 0 { revert(0, returndatasize()) }
            default { return(0, returndatasize()) }
        }
    }


    fallback () external payable virtual {
        _delegate(implementation());
    }


    receive () external payable virtual {
        _delegate(implementation());
    }
}