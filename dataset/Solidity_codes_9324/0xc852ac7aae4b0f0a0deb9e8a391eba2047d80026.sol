


pragma solidity ^0.8.2;


abstract contract ICounterfactualNFT
{
    function initialize(address owner, string memory _uri)
        public
        virtual;
}



pragma solidity ^0.8.0;

library Create2Upgradeable {

    function deploy(
        uint256 amount,
        bytes32 salt,
        bytes memory bytecode
    ) internal returns (address) {

        address addr;
        require(address(this).balance >= amount, "Create2: insufficient balance");
        require(bytecode.length != 0, "Create2: bytecode length is zero");
        assembly {
            addr := create2(amount, add(bytecode, 0x20), mload(bytecode), salt)
        }
        require(addr != address(0), "Create2: Failed on deploy");
        return addr;
    }

    function computeAddress(bytes32 salt, bytes32 bytecodeHash) internal view returns (address) {

        return computeAddress(salt, bytecodeHash, address(this));
    }

    function computeAddress(
        bytes32 salt,
        bytes32 bytecodeHash,
        address deployer
    ) internal pure returns (address) {

        bytes32 _data = keccak256(abi.encodePacked(bytes1(0xff), deployer, salt, bytecodeHash));
        return address(uint160(uint256(_data)));
    }
}


pragma solidity ^0.8.2;


library CloneFactory {

  function getByteCode(address target) internal pure returns (bytes memory byteCode) {

    bytes20 targetBytes = bytes20(target);
    assembly {
      byteCode := mload(0x40)
      mstore(byteCode, 0x37)

      let clone := add(byteCode, 0x20)
      mstore(clone, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
      mstore(add(clone, 0x14), targetBytes)
      mstore(add(clone, 0x28), 0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000)

      mstore(0x40, add(byteCode, 0x60))
    }
  }
}


pragma solidity ^0.8.2;
pragma experimental ABIEncoderV2;



contract NFTFactory
{

    event NFTContractCreated (address nftContract, address owner, string baseURI);

    string public constant NFT_CONTRACT_CREATION = "NFT_CONTRACT_CREATION";
    address public immutable implementation;

    constructor(
        address _implementation
        )
    {
        implementation = _implementation;
    }

    function createNftContract(
        address            owner,
        string    calldata baseURI
        )
        external
        payable
        returns (address nftContract)
    {

        nftContract = Create2Upgradeable.deploy(
            0,
            keccak256(abi.encodePacked(NFT_CONTRACT_CREATION, owner, baseURI)),
            CloneFactory.getByteCode(implementation)
        );

        ICounterfactualNFT(nftContract).initialize(owner, baseURI);

        emit NFTContractCreated(nftContract, owner, baseURI);
    }

    function computeNftContractAddress(
        address          owner,
        string  calldata baseURI
        )
        public
        view
        returns (address)
    {

        return _computeAddress(owner, baseURI);
    }

    function getNftContractCreationCode()
        public
        view
        returns (bytes memory)
    {

        return CloneFactory.getByteCode(implementation);
    }

    function _computeAddress(
        address          owner,
        string  calldata baseURI
        )
        private
        view
        returns (address)
    {

        return Create2Upgradeable.computeAddress(
            keccak256(abi.encodePacked(NFT_CONTRACT_CREATION, owner, baseURI)),
            keccak256(CloneFactory.getByteCode(implementation))
        );
    }
}