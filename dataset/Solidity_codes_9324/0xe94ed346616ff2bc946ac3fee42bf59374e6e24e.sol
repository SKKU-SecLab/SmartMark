
pragma solidity ^0.8.9;

contract AltProofOfIntegrity {


    constructor() {}

    function generateProof(string memory base, uint256 salt) public pure returns (bytes32) {

        return keccak256(abi.encodePacked(base, salt));
    }

    function verifyProof(bytes32 proof, string memory base, uint256 salt) public pure returns (bool) {

        return proof == generateProof(base, salt);
    }
}