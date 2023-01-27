
pragma solidity 0.8.3;


library VerifySignaturePool02 {


    function getMessageHash(
        address nft,
        uint tokenID,
        uint valuation,
        uint expireAtBlock
    ) public pure returns (bytes32) {

        return keccak256(abi.encodePacked(nft, tokenID, valuation, expireAtBlock));
    }

    function getEthSignedMessageHash(bytes32 _messageHash)
        public
        pure
        returns (bytes32)
    {

        return
            keccak256(
                abi.encodePacked("\x19Ethereum Signed Message:\n32", _messageHash)
            );
    }

    function verify(
        address nft,
        uint tokenID,
        uint valuation,
        uint expireAtBlock,
        address _signer,
        bytes memory signature
    ) public pure returns (bool) {

        bytes32 messageHash = getMessageHash(nft, tokenID, valuation, expireAtBlock);
        bytes32 ethSignedMessageHash = getEthSignedMessageHash(messageHash);

        return recoverSigner(ethSignedMessageHash, signature) == _signer;
    }

    function recoverSigner(bytes32 _ethSignedMessageHash, bytes memory _signature)
        internal
        pure
        returns (address)
    {

        (bytes32 r, bytes32 s, uint8 v) = splitSignature(_signature);

        return ecrecover(_ethSignedMessageHash, v, r, s);
    }

    function splitSignature(bytes memory sig)
        internal
        pure
        returns (
            bytes32 r,
            bytes32 s,
            uint8 v
        )
    {

        require(sig.length == 65, "invalid signature length");

        assembly {

            r := mload(add(sig, 32))
            s := mload(add(sig, 64))
            v := byte(0, mload(add(sig, 96)))
        }

    }
}