

pragma solidity ^0.8.1;


contract SignatureVerifier {


    function verifySignature(bytes32 hash, bytes memory signature, address signer) public pure returns (bool) {

        address addressFromSig = recoverSigner(hash, signature);
        return addressFromSig == signer;
    }

    function recoverSigner(bytes32 hash, bytes memory sig) public pure returns (address) {

        require(sig.length == 65, "Require correct length");

        bytes32 r;
        bytes32 s;
        uint8 v;

        assembly {
            r := mload(add(sig, 32))
            s := mload(add(sig, 64))
            v := byte(0, mload(add(sig, 96)))
        }

        if (v < 27) {
            v += 27;
        }

        require(v == 27 || v == 28, "Signature version not match");

        return recoverSigner2(hash, v, r, s);
    }

    function recoverSigner2(bytes32 h, uint8 v, bytes32 r, bytes32 s) public pure returns (address) {

        bytes memory prefix = "\x19Ethereum Signed Message:\n32";
        bytes32 prefixedHash = keccak256(abi.encodePacked(prefix, h));
        address addr = ecrecover(prefixedHash, v, r, s);

        return addr;
    }
}