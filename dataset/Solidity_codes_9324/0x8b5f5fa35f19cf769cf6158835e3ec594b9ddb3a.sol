

pragma solidity 0.6.9;

interface IIdeaTokenNameVerifier {

    function verifyTokenName(string calldata name) external pure returns (bool);

}




contract SubstackNameVerifier is IIdeaTokenNameVerifier {

    function verifyTokenName(string calldata name) external pure override returns (bool) {

        bytes memory b = bytes(name);
        if(b.length == 0 || b.length > 63) {
            return false;
        }

        bytes1 firstChar = b[0];
        bytes1 lastChar = b[b.length - 1];

        if(firstChar == 0x2D || lastChar == 0x2D) { // -
            return false;
        }

        for(uint i = 0; i < b.length; i++) {
            bytes1 char = b[i];
            if (!(char >= 0x61 && char <= 0x7A) && // a-z
                !(char >= 0x30 && char <= 0x39) && // 0-9
                char != 0x2D
                ) { 
                return false;
            }
        }

        return true;
    }
}