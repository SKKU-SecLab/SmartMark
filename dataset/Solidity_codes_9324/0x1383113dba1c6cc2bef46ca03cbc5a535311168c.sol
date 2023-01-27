

pragma solidity >=0.6.0 <0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract InblocksPrecedenceSynchronizer is Ownable {


    struct Info {
        uint index;
        uint timestamp;
    }

    mapping(bytes32 => Info) internal byRoot;
    mapping(uint => bytes32) internal byIndex;
    uint internal count;

    event Synchronized(bytes32 root, uint index, uint timestamp);

    function getLast() public view returns (bool isSynchronized, bytes32 root, int index, int timestamp) {

        return getByIndex(count - 1);
    }

    function getByIndex(uint _index) public view returns (bool isSynchronized, bytes32 root, int index, int timestamp) {

        bytes32 _root;
        if (_index < count) {
            _root = byIndex[_index];
        }
        return getByRoot(_root);
    }

    function getByRoot(bytes32 _root) public view returns (bool isSynchronized, bytes32 root, int index, int timestamp) {

        if (byRoot[_root].timestamp == 0) {
            return (false, "", - 1, - 1);
        }
        return (true, _root, int(byRoot[_root].index), int(byRoot[_root].timestamp));
    }

    function synchronize(bytes32 root, uint index) public onlyOwner {

        require(index == count);
        byIndex[index] = root;
        byRoot[root] = Info({index : index, timestamp : block.timestamp});
        count++;
        emit Synchronized(root, byRoot[root].index, byRoot[root].timestamp);
    }

}