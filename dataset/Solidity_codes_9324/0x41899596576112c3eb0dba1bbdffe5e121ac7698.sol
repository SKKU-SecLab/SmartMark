
pragma solidity ^0.6.0;

contract Ownable {

    address private _owner;
    address private _pendingOwner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function initializeOwnable() internal {

        require(_owner == address(0), "already initialized");
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), msg.sender);
    }


    function owner() public view returns (address) {

        return _owner;
    }

    modifier onlyOwner() {

        require(isOwner(), "msg.sender is not owner");
        _;
    }

    function isOwner() public view returns (bool) {

        return msg.sender == _owner;

    }

    function transferOwnership(address newOwner) public onlyOwner {

        _pendingOwner = newOwner;
    }

    function receiveOwnership() public {

        require(msg.sender == _pendingOwner, "only pending owner can call this function");
        _transferOwnership(_pendingOwner);
        _pendingOwner = address(0);
    }

    function _transferOwnership(address newOwner) internal {

        require(newOwner != address(0));
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

    uint256[50] private __gap;
}

interface IArmorMaster {

    function registerModule(bytes32 _key, address _module) external;

    function getModule(bytes32 _key) external view returns(address);

    function keep() external;

}

interface IKeeperRecipient {

    function keep() external;

}


contract ArmorMaster is Ownable, IArmorMaster {

    mapping(bytes32 => address) internal _modules;

    bytes32[] internal _jobs;

    function initialize() external {

        Ownable.initializeOwnable();
        _modules[bytes32("MASTER")] = address(this);
    }

    function registerModule(bytes32 _key, address _module) external override onlyOwner {

        _modules[_key] = _module;
    }

    function getModule(bytes32 _key) external override view returns(address) {

        return _modules[_key];
    }

    function addJob(bytes32 _key) external onlyOwner {

        require(_jobs.length < 3, "cannot have more than 3 jobs");
        require(_modules[_key] != address(0), "module is not listed");
        for(uint256 i = 0; i< _jobs.length; i++){
            require(_jobs[i] != _key, "already registered");
        }
        _jobs.push(_key);
    }

    function deleteJob(bytes32 _key) external onlyOwner {

        for(uint256 i = 0; i < _jobs.length; i++) {
            if(_jobs[i] == _key) {
                _jobs[i] = _jobs[_jobs.length - 1];
                _jobs.pop();
                return;
            }
        }
        revert("job not found");
    }

    function keep() external override {

        for(uint256 i = 0; i < _jobs.length; i++) {
            IKeeperRecipient(_modules[_jobs[i]]).keep();
        }
    }

    function jobs() external view returns(bytes32[] memory) {

        return _jobs;
    }

}