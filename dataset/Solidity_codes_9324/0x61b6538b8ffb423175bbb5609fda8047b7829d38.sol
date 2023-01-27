
pragma solidity 0.6.12; // optimization runs: 200, evm version: istanbul


interface IDharmaUNIDelegator {

    function getDefaultDelegationPayload() external pure returns (bytes32);

    function validateDefaultPayload(address delegator, bytes calldata signature) external view returns (bool valid);

    function delegateToDharmaViaDefault(bytes calldata signature) external returns (bool ok);

    
    function getCustomDelegationPayload(address delegator, uint256 expiry) external view returns (bytes32);

    function validateCustomPayload(address delegator, uint256 expiry, bytes calldata signature) external view returns (bool valid);

    function delegateToDharmaViaCustom(address delegator, uint256 expiry, bytes calldata signature) external returns (bool ok);

}


interface IUNI {

    function nonces(address account) external view returns (uint256);

    function delegateBySig(address delegatee, uint nonce, uint expiry, uint8 v, bytes32 r, bytes32 s) external;

}


contract DharmaUNIDelegator is IDharmaUNIDelegator {

    bytes32 internal constant DOMAIN_TYPEHASH = keccak256(
        "EIP712Domain(string name,uint256 chainId,address verifyingContract)"
    );

    bytes32 internal constant DOMAIN_SEPARATOR = bytes32(
        0x28e9a6a663fbec82798f959fbf7b0805000a2aa21154d62a24be5f2a8716bf81
    );

    bytes32 internal constant DELEGATION_TYPEHASH = keccak256(
        "Delegation(address delegatee,uint256 nonce,uint256 expiry)"
    );

    bytes32 internal constant STRUCT_HASH_FOR_ZERO_NONCE_AND_DISTANT_EXPIRY = bytes32(
        0x8e3dad336fbf63723cdd6a970ccff74331f69d237e030433c4fb2d299d44fdd6
    );
    
    bytes32 internal constant DEFAULT_DELEGATION_PAYLOAD = bytes32(
        0x96b14b7fefb98540ed60068884902ad2b61901691cd14a23fdd0e24bc7515f24
    );

    IUNI public constant UNI = IUNI(0x1f9840a85d5aF5bf1D1762F925BDADdC4201F984);
    
    address public constant DHARMA_DELEGATEE = address(
        0x7e4A8391C728fEd9069B2962699AB416628B19Fa
    );
    
    uint256 internal constant ZERO_NONCE = uint256(0);
    
    uint256 internal constant DISTANT_EXPIRY = uint256(999999999999999999);
    
    constructor() public {
        require(
            DOMAIN_SEPARATOR == keccak256(
                abi.encode(
                    DOMAIN_TYPEHASH, keccak256(bytes("Uniswap")), uint256(1), address(UNI)
                )
            ),
            "Domain Separator does not match computed domain separator."
        );
        
        require(
            STRUCT_HASH_FOR_ZERO_NONCE_AND_DISTANT_EXPIRY == keccak256(
                abi.encode(
                    DELEGATION_TYPEHASH, DHARMA_DELEGATEE, ZERO_NONCE, DISTANT_EXPIRY
                )
            ),
            "Default struct hash does not match computed default struct hash."
        );
        
        require(
            DEFAULT_DELEGATION_PAYLOAD == keccak256(
                abi.encodePacked(
                    "\x19\x01", DOMAIN_SEPARATOR, STRUCT_HASH_FOR_ZERO_NONCE_AND_DISTANT_EXPIRY
                )
            ),
            "Default initial delegation payload does not match computed default payload."
        );
    }
    
    function getDefaultDelegationPayload() external pure override returns (bytes32) {

        return DEFAULT_DELEGATION_PAYLOAD;
    }

    function validateDefaultPayload(
        address delegator, bytes calldata signature
    ) external view override returns (bool valid) {

        uint256 delegatorNonce = UNI.nonces(delegator);
        (uint8 v, bytes32 r, bytes32 s) = _unpackSignature(signature);
        valid = (delegatorNonce == 0 && ecrecover(DEFAULT_DELEGATION_PAYLOAD, v, r, s) == delegator);
    }

    function delegateToDharmaViaDefault(bytes calldata signature) external override returns (bool ok) {

        (uint8 v, bytes32 r, bytes32 s) = _unpackSignature(signature);
        UNI.delegateBySig(DHARMA_DELEGATEE, ZERO_NONCE, DISTANT_EXPIRY, v, r, s);
        ok = true;
    }
    
    function getCustomDelegationPayload(
        address delegator, uint256 expiry
    ) public view override returns (bytes32) {

        uint256 nonce = UNI.nonces(delegator);
        bytes32 structHash = keccak256(
            abi.encode(
                DELEGATION_TYPEHASH, DHARMA_DELEGATEE, nonce, expiry
            )
        );
        return keccak256(abi.encodePacked("\x19\x01", DOMAIN_SEPARATOR, structHash));
    }

    function validateCustomPayload(
        address delegator, uint256 expiry, bytes calldata signature
    ) external view override returns (bool valid) {

        bytes32 customPayload = getCustomDelegationPayload(delegator, expiry);
        (uint8 v, bytes32 r, bytes32 s) = _unpackSignature(signature);
        valid = (block.timestamp <= expiry && ecrecover(customPayload, v, r, s) == delegator);
    }

    function delegateToDharmaViaCustom(
        address delegator, uint256 expiry, bytes calldata signature
    ) external override returns (bool ok) {

        uint256 delegatorNonce = UNI.nonces(delegator);
        (uint8 v, bytes32 r, bytes32 s) = _unpackSignature(signature);
        UNI.delegateBySig(DHARMA_DELEGATEE, delegatorNonce, expiry, v, r, s);
        ok = true;
    }
    
    function _unpackSignature(
        bytes memory signature
    ) internal pure returns (uint8 v, bytes32 r, bytes32 s) {

        require(signature.length == 65, "Signature length is incorrect.");

        assembly {
            r := mload(add(signature, 0x20))
            s := mload(add(signature, 0x40))
            v := byte(0, mload(add(signature, 0x60)))
        }
    }
}