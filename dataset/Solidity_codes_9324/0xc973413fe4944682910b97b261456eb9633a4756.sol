
pragma solidity ^0.8.0;


library SignatureVerifier {

    function verify(
        address signer,
        address account,
        uint256[] calldata ids,
        bytes calldata signature
    ) external pure returns (bool) {

        bytes32 messageHash = getMessageHash(account, ids);
        bytes32 ethSignedMessageHash = getEthSignedMessageHash(messageHash);

        return recoverSigner(ethSignedMessageHash, signature) == signer;
    }

    function verify(
        address signer,
        uint256 id,
        address[] calldata accounts,
        bytes calldata signature
    ) external pure returns (bool) {

        bytes32 messageHash = getMessageHash(id, accounts);
        bytes32 ethSignedMessageHash = getEthSignedMessageHash(messageHash);

        return recoverSigner(ethSignedMessageHash, signature) == signer;
    }

    function getMessageHash(address account, uint256[] memory ids) internal pure returns (bytes32) {

        return keccak256(abi.encodePacked(account, ids));
    }
    function getMessageHash(uint256 id, address[] memory accounts) internal pure returns (bytes32) {

        return keccak256(abi.encodePacked(id, accounts));
    }

    function getEthSignedMessageHash(bytes32 messageHash) internal pure returns (bytes32) {

        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", messageHash));
    }

    function recoverSigner(bytes32 _ethSignedMessageHash, bytes memory _signature)
        internal
        pure
        returns (address)
    {

        (bytes32 r, bytes32 s, uint8 v) = splitSignature(_signature);

        return ecrecover(_ethSignedMessageHash, v, r, s);
    }

    function splitSignature(bytes memory signature)
        internal
        pure
        returns (
            bytes32 r,
            bytes32 s,
            uint8 v
        )
    {

        require(signature.length == 65, "invalid signature length");

        assembly {
            r := mload(add(signature, 32))
            s := mload(add(signature, 64))
            v := byte(0, mload(add(signature, 96)))
        }
    }
}