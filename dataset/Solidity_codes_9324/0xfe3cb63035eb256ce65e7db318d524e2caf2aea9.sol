
pragma solidity 0.5.2;


interface EllipticCurveInterface {


    function validateSignature(bytes32 message, uint[2] calldata rs, uint[2] calldata Q) external view returns (bool);


}

interface RegisterInterface {


  function getKongAmount(bytes32 hardwareHash) external view returns (uint);

  function verifyMintableHardwareHash(bytes32 primaryPublicKeyHash, bytes32 secondaryPublicKeyHash, bytes32 tertiaryPublicKeyHash, bytes32 hardwareSerial) external view returns (bytes32);

  function mintKong(bytes32 hardwareHash, address recipient) external;


}


contract KongEntropyDirectMint {


    address public _regAddress;
    address public _eccAddress;

    bytes32[] public _hashedSignaturesArray;

    uint256 public _hashedSignaturesIndex;

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

        bytes32 calculatedHardwareHash = sha256(abi.encodePacked(primaryPublicKeyHash, secondaryPublicKeyHash, hashedKey, hardwareSerial));

        require(_mintedKeys[calculatedHardwareHash] == false, 'Has already been minted.');

        bytes32 compareHardwareHash = RegisterInterface(_regAddress).verifyMintableHardwareHash(primaryPublicKeyHash, secondaryPublicKeyHash, hashedKey, hardwareSerial);        

        require(calculatedHardwareHash == compareHardwareHash, 'Invalid parameter, hashes do not match.');

        uint scaledKongAmount = RegisterInterface(_regAddress).getKongAmount(calculatedHardwareHash) / uint(10 ** 17);

        bytes32 powHash = blockhash(block.number);
        for (uint i=0; i < scaledKongAmount; i++) {
            powHash = keccak256(abi.encodePacked(powHash));
        }

        bytes32 messageHash = sha256(abi.encodePacked(to, blockhash(blockNumber)));
        require(_validateSignature(messageHash, rs, tertiaryPublicKeyX, tertiaryPublicKeyY), 'Invalid signature.');

        bytes32 sigHash = sha256(abi.encodePacked(rs[0], rs[1]));

        _hashedSignaturesIndex = _hashedSignaturesArray.push(sigHash);

        _mintedKeys[calculatedHardwareHash] = true;

        RegisterInterface(_regAddress).mintKong(calculatedHardwareHash, to);

        emit Minted(calculatedHardwareHash, messageHash, rs[0], rs[1]);
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

    function getHashedSignature(
        uint256 index
    )
        public view returns(bytes32)
    {

        require(index <= _hashedSignaturesIndex - 1, 'Invalid index.');
        return _hashedSignaturesArray[index];
    }

}