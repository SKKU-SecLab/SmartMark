
pragma solidity >=0.6.0 <0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}// MIT

pragma solidity >=0.6.0 <0.8.0;

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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
}// MIT

pragma solidity >=0.6.0 <0.8.0;

library Clones {

    function clone(address master) internal returns (address instance) {

        assembly {
            let ptr := mload(0x40)
            mstore(ptr, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
            mstore(add(ptr, 0x14), shl(0x60, master))
            mstore(add(ptr, 0x28), 0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000)
            instance := create(0, ptr, 0x37)
        }
        require(instance != address(0), "ERC1167: create failed");
    }

    function cloneDeterministic(address master, bytes32 salt) internal returns (address instance) {

        assembly {
            let ptr := mload(0x40)
            mstore(ptr, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
            mstore(add(ptr, 0x14), shl(0x60, master))
            mstore(add(ptr, 0x28), 0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000)
            instance := create2(0, ptr, 0x37, salt)
        }
        require(instance != address(0), "ERC1167: create2 failed");
    }

    function predictDeterministicAddress(address master, bytes32 salt, address deployer) internal pure returns (address predicted) {

        assembly {
            let ptr := mload(0x40)
            mstore(ptr, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
            mstore(add(ptr, 0x14), shl(0x60, master))
            mstore(add(ptr, 0x28), 0x5af43d82803e903d91602b57fd5bf3ff00000000000000000000000000000000)
            mstore(add(ptr, 0x38), shl(0x60, deployer))
            mstore(add(ptr, 0x4c), salt)
            mstore(add(ptr, 0x6c), keccak256(ptr, 0x37))
            predicted := keccak256(add(ptr, 0x37), 0x55)
        }
    }

    function predictDeterministicAddress(address master, bytes32 salt) internal view returns (address predicted) {

        return predictDeterministicAddress(master, salt, address(this));
    }
}// MIT


pragma solidity >=0.6.0 <0.8.0;

interface IECDSANodeManagement {    

    function initialize(
        address _owner,
        address[] memory _members,
        uint256 _honestThreshold) external;

}// MIT

pragma solidity 0.6.12;


contract ECDSAFactory is Ownable {

  event ECDSANodeGroupCreated(
    address indexed keepAddress,
    address[] members,
    address indexed owner,
    uint256 honestThreshold
  );

  struct LatestNodeGroup {
    address keepAddress;
    address[] members;
    address owner;
    uint256 honestThreshold;
  }

  LatestNodeGroup public latestNodeGroup;

  constructor() public Ownable() {}

  function getMembers() public view returns (address[] memory) {

    return latestNodeGroup.members;
  }

  function deploy(
    address nodeMgmtAddress,
    address owner,
    address[] memory members,
    uint256 honestThreshold
  ) external onlyOwner returns (address) {

    address nodeClone = Clones.clone(nodeMgmtAddress);
    IECDSANodeManagement(nodeClone).initialize(owner, members, honestThreshold);

    latestNodeGroup.keepAddress = nodeClone;
    latestNodeGroup.members = members;
    latestNodeGroup.owner = owner;
    latestNodeGroup.honestThreshold = honestThreshold;

    emit ECDSANodeGroupCreated(nodeClone, members, owner, honestThreshold);
    return nodeClone;
  }
}