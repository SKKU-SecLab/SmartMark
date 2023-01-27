

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
}

interface IERCClone {

  function initialize(
    address owner_,
    string memory name_,
    string memory symbol_
   ) external;


  function initialize(
    address owner,
    string memory name_,
    string memory symbol_,
    uint256 cap_,
    uint256 maxPerTx_,
    uint256 price_) external;


  function initialize(
    address owner,
    string memory name_,
    string memory symbol_,
    uint256 cap_,
    uint256 freeCap_,
    uint256 maxPerTx_,
    uint256 price_) external;

}

contract NFTCloner {

  using Clones for address;

  event Cloned(address instance, string name, string symbol);

  function clone1(
    address implementation,
    string memory name,
    string memory symbol
  ) external {

      address newClone = implementation.clone();

      IERCClone(newClone).initialize(msg.sender, name, symbol);

      emit Cloned(newClone, name, symbol);
  }

  function clone2(
    address implementation,
    string memory name,
    string memory symbol,
    uint256 cap,
    uint256 maxPerTx,
    uint256 price) external {

      address newClone = implementation.clone();

      IERCClone(newClone).initialize(msg.sender, name, symbol, cap, maxPerTx, price);

      emit Cloned(newClone, name, symbol);
  }

  function clone3(
    address implementation,
    string memory name,
    string memory symbol,
    uint256 cap,
    uint256 freeCap,
    uint256 maxPerTx,
    uint256 price) external {

      address newClone = implementation.clone();

      IERCClone(newClone).initialize(msg.sender, name, symbol, cap, freeCap, maxPerTx, price);

      emit Cloned(newClone, name, symbol);
  }

}