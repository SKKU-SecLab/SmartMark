
pragma solidity ^0.8.0;

library Clones {

    function clone(address implementation) internal returns (address instance) {

        assembly {
            let ptr := mload(0x40)
            mstore(ptr, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
            mstore(add(ptr, 0x14), shl(0x60, implementation))
            mstore(add(ptr, 0x28), 0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000)
            instance := create(0, ptr, 0x37)
        }
        require(instance != address(0), "ERC1167: create failed");
    }

    function cloneDeterministic(address implementation, bytes32 salt) internal returns (address instance) {

        assembly {
            let ptr := mload(0x40)
            mstore(ptr, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
            mstore(add(ptr, 0x14), shl(0x60, implementation))
            mstore(add(ptr, 0x28), 0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000)
            instance := create2(0, ptr, 0x37, salt)
        }
        require(instance != address(0), "ERC1167: create2 failed");
    }

    function predictDeterministicAddress(
        address implementation,
        bytes32 salt,
        address deployer
    ) internal pure returns (address predicted) {

        assembly {
            let ptr := mload(0x40)
            mstore(ptr, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
            mstore(add(ptr, 0x14), shl(0x60, implementation))
            mstore(add(ptr, 0x28), 0x5af43d82803e903d91602b57fd5bf3ff00000000000000000000000000000000)
            mstore(add(ptr, 0x38), shl(0x60, deployer))
            mstore(add(ptr, 0x4c), salt)
            mstore(add(ptr, 0x6c), keccak256(ptr, 0x37))
            predicted := keccak256(add(ptr, 0x37), 0x55)
        }
    }

    function predictDeterministicAddress(address implementation, bytes32 salt)
        internal
        view
        returns (address predicted)
    {

        return predictDeterministicAddress(implementation, salt, address(this));
    }
}// MIT

pragma solidity ^0.8.0;

abstract contract Initializable {
    bool private _initialized;

    bool private _initializing;

    modifier initializer() {
        require(_initializing || !_initialized, "Initializable: contract is already initialized");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }
}/////////////////////////////////////////////////////////////////////////////////////
pragma solidity ^0.8.4;
contract Buffer is Initializable {

  mapping (address => uint) public withdrawn;
  bytes32 public root;
  uint public totalReceived;
  function initialize(bytes32 _root) initializer public {

    root = _root;
  }
  receive () external payable {
    totalReceived += msg.value;
  }
  function withdraw(address account, uint256 amount, bytes32[] calldata proof) external payable {

    bytes32 hash = keccak256(abi.encodePacked(account, amount));
    for (uint256 i = 0; i < proof.length; i++) {
      bytes32 proofElement = proof[i];
      if (hash <= proofElement) {
        hash = _hash(hash, proofElement);
      } else {
        hash = _hash(proofElement, hash);
      }
    }
    require(hash == root, "1");
    uint payment = totalReceived * amount / 10**12 - withdrawn[account];
    withdrawn[account] += payment;
    _transfer(account, payment);
  }
  function _hash(bytes32 a, bytes32 b) private pure returns (bytes32 value) {

    assembly {
      mstore(0x00, a)
      mstore(0x20, b)
      value := keccak256(0x00, 0x40)
    }
  }
  error TransferFailed();
  function _transfer(address to, uint256 amount) internal {

    bool callStatus;
    assembly {
      callStatus := call(gas(), to, amount, 0, 0, 0, 0)
    }
    if (!callStatus) revert TransferFailed();
  }
}// MIT
pragma solidity ^0.8.4;
contract Factory {

  event ContractDeployed(address indexed owner, address indexed group, bytes32 cid, string title);
  address public immutable implementation;
  constructor() {
    implementation = address(new Buffer());
  }
  function genesis(string memory title, bytes32 _root, bytes32 _cid) external returns (address) {

    address payable clone = payable(Clones.clone(implementation));
    Buffer buffer = Buffer(clone);
    buffer.initialize(_root);
    emit ContractDeployed(msg.sender, clone, _cid, title);
    return clone;
  }
}