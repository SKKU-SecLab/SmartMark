
pragma solidity 0.5.4;

contract SecretRegistry {

    mapping(bytes32 => uint256) private secrethash_to_block;

    event SecretRevealed(bytes32 indexed secrethash, bytes32 secret);

    function registerSecret(bytes32 secret) public returns (bool) {

        bytes32 secrethash = sha256(abi.encodePacked(secret));
        if (secrethash_to_block[secrethash] > 0) {
            return false;
        }
        secrethash_to_block[secrethash] = block.number;
        emit SecretRevealed(secrethash, secret);
        return true;
    }

    function registerSecretBatch(bytes32[] memory secrets) public returns (bool) {

        bool completeSuccess = true;
        for(uint i = 0; i < secrets.length; i++) {
            if(!registerSecret(secrets[i])) {
                completeSuccess = false;
            }
        }
        return completeSuccess;
    }

    function getSecretRevealBlockHeight(bytes32 secrethash) public view returns (uint256) {

        return secrethash_to_block[secrethash];
    }
}





