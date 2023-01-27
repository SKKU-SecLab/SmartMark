
pragma solidity ^0.4.24;

contract Owned {


    address public owner;

    event OwnerChanged(address indexed _newOwner);

    modifier onlyOwner {

        require(msg.sender == owner, "Must be owner");
        _;
    }

    constructor() public {
        owner = msg.sender;
    }

    function changeOwner(address _newOwner) external onlyOwner {

        require(_newOwner != address(0), "Address must not be null");
        owner = _newOwner;
        emit OwnerChanged(_newOwner);
    }
}

contract DappRegistry is Owned {


    mapping (address => mapping (bytes4 => bool)) internal authorised;

    event Registered(address indexed _contract, bytes4[] _methods);
    event Deregistered(address indexed _contract, bytes4[] _methods);

    function register(address _contract, bytes4[] _methods) external onlyOwner {

        for(uint i = 0; i < _methods.length; i++) {
            authorised[_contract][_methods[i]] = true;
        }
        emit Registered(_contract, _methods);
    }

    function deregister(address _contract, bytes4[] _methods) external onlyOwner {

        for(uint i = 0; i < _methods.length; i++) {
            authorised[_contract][_methods[i]] = false;
        }
        emit Deregistered(_contract, _methods);
    }

    function isRegistered(address _contract, bytes4 _method) external view returns (bool) {

        return authorised[_contract][_method];
    }  

    function isRegistered(address _contract, bytes4[] _methods) external view returns (bool) {

        for(uint i = 0; i < _methods.length; i++) {
            if (!authorised[_contract][_methods[i]]) {
                return false;
            }
        }
        return true;
    }  
}