
pragma solidity 0.5.17;

interface EllipticCurveInterface {


    function validateSignature(bytes32 message, uint[2] calldata rs, uint[2] calldata Q) external view returns (bool);


}

interface RegisterInterface {


  function isDeviceMintable(bytes32 hardwareHash) external view returns (bool);

  function getRootDetails(bytes32 root) external view returns (uint256, uint256, uint256, uint256, string memory, string memory, uint256, uint256);

  function mintKong(bytes32[] calldata proof, bytes32 root, bytes32 hardwareHash, address recipient) external;


}

contract KongEntropyMerkle {


    address public _regAddress;
    address public _eccAddress;

    mapping(bytes32 => bool) public _mintedKeys;

    event Minted(
        bytes32 hardwareHash,
        bytes32 message,
        uint256 r,
        uint256 s
    );

    constructor(address eccAddress, address regAddress) public {

        _eccAddress = eccAddress;
        _regAddress = regAddress;

    }

    function submitEntropy(
        bytes32[] memory merkleProof, 
        bytes32 merkleRoot, 
        bytes32 primaryPublicKeyHash,
        bytes32 secondaryPublicKeyHash,
        bytes32 hardwareSerial,
        uint256 tertiaryPublicKeyX,
        uint256 tertiaryPublicKeyY,
        address to,
        uint256 blockNumber,
        uint256[2] memory rs
    )
        public
    {


        bytes32 hashedKey = sha256(abi.encodePacked(tertiaryPublicKeyX, tertiaryPublicKeyY));

        bytes32 hardwareHash = sha256(abi.encodePacked(primaryPublicKeyHash, secondaryPublicKeyHash, hashedKey, hardwareSerial));

        require(_mintedKeys[hardwareHash] == false, 'Already minted.');

        require(RegisterInterface(_regAddress).isDeviceMintable(hardwareHash), 'Minted in registry.');

        uint256 kongAmount;
        (kongAmount, , , , , , , ) = RegisterInterface(_regAddress).getRootDetails(merkleRoot);
        for (uint i=0; i < kongAmount / uint(10 ** 19); i++) {
            keccak256(abi.encodePacked(blockhash(block.number)));
        }

        bytes32 messageHash = sha256(abi.encodePacked(to, blockhash(blockNumber)));
        require(_validateSignature(messageHash, rs, tertiaryPublicKeyX, tertiaryPublicKeyY), 'Invalid signature.');

        RegisterInterface(_regAddress).mintKong(merkleProof, merkleRoot, hardwareHash, to);

        _mintedKeys[hardwareHash] = true;

        emit Minted(hardwareHash, messageHash, rs[0], rs[1]);
    }

    function _validateSignature(
        bytes32 message,
        uint256[2] memory rs,
        uint256 publicKeyX,
        uint256 publicKeyY
    )
        internal view returns (bool)
    {

        return EllipticCurveInterface(_eccAddress).validateSignature(message, rs, [publicKeyX, publicKeyY]);
    }

    function isDeviceMinted(
        bytes32 hardwareHash
    )
        external view returns (bool)
    {

        return _mintedKeys[hardwareHash];
    }

}