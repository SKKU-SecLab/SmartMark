


pragma solidity ^0.4.25;


library Signatures {


    bytes constant internal SIGNATURE_PREFIX = "\x19Ethereum Signed Message:\n32";
    uint constant internal SIGNATURE_LENGTH = 65;

    function getSignerFromSignature(bytes32 _message, bytes _signature)
    public
    pure
    returns (address)
    {

        bytes32 r;
        bytes32 s;
        uint8 v;

        if (_signature.length != SIGNATURE_LENGTH) {
            return 0;
        }

        assembly {
            r := mload(add(_signature, 32))
            s := mload(add(_signature, 64))
            v := and(mload(add(_signature, 65)), 255)
        }

        if (v < 27) {
            v += 27;
        }

        return ecrecover(
            keccak256(abi.encodePacked(SIGNATURE_PREFIX, _message)),
            v,
            r,
            s
        );
    }

    function getSignersFromSignatures(bytes32 _message, bytes _signatures)
    public
    pure
    returns (address[] memory _addresses)
    {

        require(validSignaturesLength(_signatures), "SIGNATURES_SHOULD_HAVE_CORRECT_LENGTH");
        _addresses = new address[](numSignatures(_signatures));
        for (uint i = 0; i < _addresses.length; i++) {
            _addresses[i] = getSignerFromSignature(_message, signatureAt(_signatures, i));
        }
    }

    function numSignatures(bytes _signatures)
    private
    pure
    returns (uint256)
    {

        return _signatures.length / SIGNATURE_LENGTH;
    }

    function validSignaturesLength(bytes _signatures)
    internal
    pure
    returns (bool)
    {

        return (_signatures.length % SIGNATURE_LENGTH) == 0;
    }

    function signatureAt(bytes _signatures, uint position)
    private
    pure
    returns (bytes)
    {

        return slice(_signatures, position * SIGNATURE_LENGTH, SIGNATURE_LENGTH);
    }

    function bytesToBytes4(bytes memory source)
    private
    pure
    returns (bytes4 output) {

        if (source.length == 0) {
            return 0x0;
        }
        assembly {
            output := mload(add(source, 4))
        }
    }

    function slice(bytes _bytes, uint _start, uint _length)
    private
    pure
    returns (bytes)
    {

        require(_bytes.length >= (_start + _length), "SIGNATURES_SLICE_SIZE_SHOULD_NOT_OVERTAKE_BYTES_LENGTH");

        bytes memory tempBytes;

        assembly {
            switch iszero(_length)
            case 0 {
                tempBytes := mload(0x40)

                let lengthmod := and(_length, 31)

                let mc := add(add(tempBytes, lengthmod), mul(0x20, iszero(lengthmod)))
                let end := add(mc, _length)

                for {
                    let cc := add(add(add(_bytes, lengthmod), mul(0x20, iszero(lengthmod))), _start)
                } lt(mc, end) {
                    mc := add(mc, 0x20)
                    cc := add(cc, 0x20)
                } {
                    mstore(mc, mload(cc))
                }

                mstore(tempBytes, _length)

                mstore(0x40, and(add(mc, 31), not(31)))
            }
            default {
                tempBytes := mload(0x40)

                mstore(0x40, add(tempBytes, 0x20))
            }
        }

        return tempBytes;
    }

}