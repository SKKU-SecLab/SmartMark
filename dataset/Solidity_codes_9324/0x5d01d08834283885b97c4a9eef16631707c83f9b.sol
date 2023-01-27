

pragma solidity 0.4.26;

interface IERC721 {

    function safeTransferFrom(address from, address to, uint256 tokenId) external;

    function transferFrom(address from, address to, uint256 tokenId) external;

}

interface IERC1155 {

    function safeTransferFrom(address from, address to, uint256 tokenId, uint256 amount, bytes data) external;

}

contract MerkleValidator {


    function matchERC721UsingCriteria(
        address from,
        address to,
        IERC721 token,
        uint256 tokenId,
        bytes32 root,
        bytes32[] proof
    ) payable external returns (bool) {

        if (root != bytes32(0)) {
            verifyProof(tokenId, root, proof);
        } else if (proof.length != 0) {
            revert("expect no proof");
        }

        token.transferFrom(from, to, tokenId);

        return true;
    }

    function matchERC721WithSafeTransferUsingCriteria(
        address from,
        address to,
        IERC721 token,
        uint256 tokenId,
        bytes32 root,
        bytes32[] proof
    ) payable external returns (bool) {

        if (root != bytes32(0)) {
            verifyProof(tokenId, root, proof);
        } else if (proof.length != 0) {
            revert("expect no proof");
        }

        token.safeTransferFrom(from, to, tokenId);

        return true;
    }

    function matchERC1155UsingCriteria(
        address from,
        address to,
        IERC1155 token,
        uint256 tokenId,
        uint256 amount,
        bytes32 root,
        bytes32[] proof
    ) payable external returns (bool) {

        if (root != bytes32(0)) {
            verifyProof(tokenId, root, proof);
        } else if (proof.length != 0) {
            revert("expect no proof");
        }

        token.safeTransferFrom(from, to, tokenId, amount, "");

        return true;
    }

    function verifyProof(
        uint256 leaf,
        bytes32 root,
        bytes32[] memory proof
    ) public pure {

        bytes32 computedHash = bytes32(leaf);
        for (uint256 i = 0; i < proof.length; i++) {
            bytes32 proofElement = proof[i];
            if (computedHash <= proofElement) {
                computedHash = efficientHash(computedHash, proofElement);
            } else {
                computedHash = efficientHash(proofElement, computedHash);
            }
        }
        if (computedHash != root) {
            revert("invalid proof");
        }
    }

    function calculateProof(
        uint256 leafA,
        uint256 leafB
    ) public pure returns(bytes32) {

        bytes32 computedHashA = bytes32(leafA);
        bytes32 computedHashB = bytes32(leafB);

        bytes32 proof;
        if (computedHashA <= computedHashB) {
            proof = efficientHash(computedHashA, computedHashB);
        } else {
            proof = efficientHash(computedHashB, computedHashA);
        }
        return proof;
    }

    function efficientHash(
        bytes32 a,
        bytes32 b
    ) public pure returns (bytes32 value) {

        assembly {
            mstore(0x00, a)
            mstore(0x20, b)
            value := keccak256(0x00, 0x40)
        }
    }
}