
pragma solidity ^0.8.0;

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}// MIT

pragma solidity ^0.8.0;


interface IERC721 is IERC165 {

    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    function balanceOf(address owner) external view returns (uint256 balance);


    function ownerOf(uint256 tokenId) external view returns (address owner);


    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;


    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;


    function approve(address to, uint256 tokenId) external;


    function getApproved(uint256 tokenId) external view returns (address operator);


    function setApprovalForAll(address operator, bool _approved) external;


    function isApprovedForAll(address owner, address operator) external view returns (bool);


    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;

}// MIT

pragma solidity ^0.8.0;

library Strings {

    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";

    function toString(uint256 value) internal pure returns (string memory) {


        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    function toHexString(uint256 value) internal pure returns (string memory) {

        if (value == 0) {
            return "0x00";
        }
        uint256 temp = value;
        uint256 length = 0;
        while (temp != 0) {
            length++;
            temp >>= 8;
        }
        return toHexString(value, length);
    }

    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {

        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _HEX_SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }
}// MIT

pragma solidity ^0.8.0;


library ECDSA {

    enum RecoverError {
        NoError,
        InvalidSignature,
        InvalidSignatureLength,
        InvalidSignatureS,
        InvalidSignatureV
    }

    function _throwError(RecoverError error) private pure {

        if (error == RecoverError.NoError) {
            return; // no error: do nothing
        } else if (error == RecoverError.InvalidSignature) {
            revert("ECDSA: invalid signature");
        } else if (error == RecoverError.InvalidSignatureLength) {
            revert("ECDSA: invalid signature length");
        } else if (error == RecoverError.InvalidSignatureS) {
            revert("ECDSA: invalid signature 's' value");
        } else if (error == RecoverError.InvalidSignatureV) {
            revert("ECDSA: invalid signature 'v' value");
        }
    }

    function tryRecover(bytes32 hash, bytes memory signature) internal pure returns (address, RecoverError) {

        if (signature.length == 65) {
            bytes32 r;
            bytes32 s;
            uint8 v;
            assembly {
                r := mload(add(signature, 0x20))
                s := mload(add(signature, 0x40))
                v := byte(0, mload(add(signature, 0x60)))
            }
            return tryRecover(hash, v, r, s);
        } else if (signature.length == 64) {
            bytes32 r;
            bytes32 vs;
            assembly {
                r := mload(add(signature, 0x20))
                vs := mload(add(signature, 0x40))
            }
            return tryRecover(hash, r, vs);
        } else {
            return (address(0), RecoverError.InvalidSignatureLength);
        }
    }

    function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {

        (address recovered, RecoverError error) = tryRecover(hash, signature);
        _throwError(error);
        return recovered;
    }

    function tryRecover(
        bytes32 hash,
        bytes32 r,
        bytes32 vs
    ) internal pure returns (address, RecoverError) {

        bytes32 s = vs & bytes32(0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff);
        uint8 v = uint8((uint256(vs) >> 255) + 27);
        return tryRecover(hash, v, r, s);
    }

    function recover(
        bytes32 hash,
        bytes32 r,
        bytes32 vs
    ) internal pure returns (address) {

        (address recovered, RecoverError error) = tryRecover(hash, r, vs);
        _throwError(error);
        return recovered;
    }

    function tryRecover(
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure returns (address, RecoverError) {

        if (uint256(s) > 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0) {
            return (address(0), RecoverError.InvalidSignatureS);
        }
        if (v != 27 && v != 28) {
            return (address(0), RecoverError.InvalidSignatureV);
        }

        address signer = ecrecover(hash, v, r, s);
        if (signer == address(0)) {
            return (address(0), RecoverError.InvalidSignature);
        }

        return (signer, RecoverError.NoError);
    }

    function recover(
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure returns (address) {

        (address recovered, RecoverError error) = tryRecover(hash, v, r, s);
        _throwError(error);
        return recovered;
    }

    function toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32) {

        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }

    function toEthSignedMessageHash(bytes memory s) internal pure returns (bytes32) {

        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n", Strings.toString(s.length), s));
    }

    function toTypedDataHash(bytes32 domainSeparator, bytes32 structHash) internal pure returns (bytes32) {

        return keccak256(abi.encodePacked("\x19\x01", domainSeparator, structHash));
    }
}// MIT

pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}// MIT

pragma solidity ^0.8.0;


abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _transferOwnership(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}// MIT
pragma solidity ^0.8.7;


contract SpermRace is Ownable {

    using ECDSA for bytes32;

    uint internal immutable MAX_INT = 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff;

    IERC721 spermGameContract;

    mapping(uint => uint) public eggTokenIdToSpermTokenIdBet;
    mapping(uint => bool) public uniqueTokenIds;

    bool inProgress;
    bool enforceRaceEntrySignature;

    uint public constant TOTAL_EGGS = 1778;
    uint public constant TOTAL_SUPPLY = 8888;

    uint public maxParticipantsInRace = 4000;
    uint public numOfFertilizationSpermTokens = 2;
    uint public raceEntryFee = 0 ether;
    uint public bettingFee = 0 ether;

    uint[] public tokenIdParticipants;
    uint[] public raceRandomNumbers;
    uint[] public participantsInRound;
    uint[] public fertilizedTokenIds = new uint[]((TOTAL_EGGS / 256) + 1);

    address private operatorAddress;

    constructor(address _spermGameContractAddress) {
        spermGameContract = IERC721(_spermGameContractAddress);
        operatorAddress = msg.sender;
        inProgress = false;
        enforceRaceEntrySignature = false;
    }

    function enterRace(uint[] calldata tokenIds, bytes[] calldata signatures) external payable enforceMaxParticipantsInRace(tokenIds.length) enforceSignatureEntry(tokenIds, signatures) {

        require(inProgress, "Sperm race is not in progress");
        require(msg.value >= raceEntryFee, "Insufficient fee supplied to enter race");
        for (uint i = 0; i < tokenIds.length; i++) {
            require((tokenIds[i] % 5) != 0, "One of the supplied tokenIds is not a sperm");
            require(spermGameContract.ownerOf(tokenIds[i]) == msg.sender, "Not the owner of one or more of the supplied tokenIds");

            tokenIdParticipants.push(tokenIds[i]);
        }
    }

    function fertilize(uint eggTokenId, uint[] calldata spermTokenIds, bytes[] memory signatures) external {

        require(!inProgress, "Sperm race is ongoing");

        require((eggTokenId % 5) == 0, "Supplied eggTokenId is not an egg");
        require(spermGameContract.ownerOf(eggTokenId) == msg.sender, "Not the owner of the egg");
        require(spermTokenIds.length == numOfFertilizationSpermTokens, "Must bring along the correct number of sperms");
        require(spermTokenIds.length == signatures.length, "Each sperm requires a signatures");
        require(!isFertilized(eggTokenId), "Egg tokenId is already fertilized");

        setFertilized(eggTokenId);

        for (uint i = 0; i < spermTokenIds.length; i++) {
            require((spermTokenIds[i] % 5) != 0, "One or more of the supplied spermTokenIds is not a sperm");
            isTokenInFallopianPool(spermTokenIds[i], signatures[i]);
            require(!isFertilized(spermTokenIds[i]), "One of the spermTokenIds has already fertilized an egg");
            setFertilized(spermTokenIds[i]);
        }
    }

    function bet(uint eggTokenId, uint spermTokenId) external payable {

        require(!inProgress || (raceRandomNumbers.length == 0), "Race is already in progress");
        require(msg.value >= bettingFee, "Insufficient fee to place bet");
        require(spermGameContract.ownerOf(eggTokenId) == msg.sender, "Not the owner of the egg");
        require((eggTokenId % 5) == 0, "Supplied eggTokenId is not an egg");
        require((spermTokenId % 5) != 0, "Supplied spermTokenId is not a sperm");

        eggTokenIdToSpermTokenIdBet[eggTokenId] = spermTokenId;
    }

    function calculateTraitsFromTokenId(uint tokenId) public pure returns (uint) {

        if ((tokenId == 409) || (tokenId == 1386) || (tokenId == 1499) || (tokenId == 1556) || (tokenId == 1971) || (tokenId == 2561) || (tokenId == 3896) || (tokenId == 4719) || (tokenId == 6044) || (tokenId == 6861) || (tokenId == 8348) || (tokenId == 8493)) {
            return 12;
        }

        uint magicNumber = 69420;
        uint iq = (uint(keccak256(abi.encodePacked(tokenId, magicNumber, "IQ"))) % 4) + 1;
        uint speed = (uint(keccak256(abi.encodePacked(tokenId, magicNumber, "Speed"))) % 4) + 1;
        uint strength = (uint(keccak256(abi.encodePacked(tokenId, magicNumber, "Strength"))) % 4) + 1;

        return iq + speed + strength;
    }

    function progressRace(uint num) external onlyOwner {

        require(inProgress, "Races must be in progress to progress");
        uint randomNumber = random(tokenIdParticipants.length);
        for (uint i = 0; i < num; i++) {
            randomNumber >>= 8;
            raceRandomNumbers.push(randomNumber);
            participantsInRound.push(tokenIdParticipants.length);
        }
    }

    function toggleRace() external onlyOwner {

        inProgress = !inProgress;
    }

    function setOperatorAddress(address _address) external onlyOwner {

        operatorAddress = _address;
    }

    function resetRace() external onlyOwner {

        require(!inProgress, "Sperm race is ongoing");

        delete tokenIdParticipants;
        delete raceRandomNumbers;
        delete participantsInRound;
        fertilizedTokenIds = new uint[]((TOTAL_EGGS / 256) + 1);
    }

    function leaderboard(uint index) external view returns (uint[] memory, uint[] memory) {

        uint[] memory leaders = new uint[](participantsInRound[index]);
        uint[] memory progress = new uint[](participantsInRound[index]);
        uint[] memory tokenRaceTraits = new uint[](8888);

        for (uint i = 0; i < participantsInRound[index]; i++) {
            leaders[i] = tokenIdParticipants[i];
            tokenRaceTraits[tokenIdParticipants[i]] = calculateTraitsFromTokenId(tokenIdParticipants[i]);
        }

        for (uint k = 0; k < participantsInRound[index]; k++) {
            uint randomIndex = raceRandomNumbers[index] % (participantsInRound[index] - k);
            uint randomValA = leaders[randomIndex];
            uint randomValB = progress[randomIndex];

            leaders[randomIndex] = leaders[k];
            leaders[k] = randomValA;

            progress[randomIndex] = progress[k];
            progress[k] = randomValB;
        }

        for (uint j = 0; j < participantsInRound[index]; j = j + 2) {
            if (j == (participantsInRound[index] - 1)) {
                progress[j]++;
            } else {
                uint scoreA = tokenRaceTraits[leaders[j]];
                uint scoreB = tokenRaceTraits[leaders[j+1]];

                if ((raceRandomNumbers[index] % (scoreA + scoreB)) < scoreA) {
                    progress[j]++;
                } else {
                   progress[j+1]++;
                }
            }
        }

       return (leaders, progress);
    }

    function setMaxParticipantsInRace(uint _maxParticipants) external onlyOwner {

        maxParticipantsInRace = _maxParticipants;
    }

    function setNumOfFertilizationSpermTokens(uint _numOfTokens) external onlyOwner {

        numOfFertilizationSpermTokens = _numOfTokens;
    }

    function setRaceEntryFee(uint _entryFee) external onlyOwner {

        raceEntryFee = _entryFee;
    }

    function setBettingFee(uint _bettingFee) external onlyOwner {

        bettingFee = _bettingFee;
    }

    function setEnforceRaceEntrySignature (bool _enableSignature) external onlyOwner {
        enforceRaceEntrySignature = _enableSignature;
    }

    function getTokenIdParticipants() external view returns (uint[] memory) {

        return tokenIdParticipants;
    }

    function random(uint seed) internal view returns (uint) {

        return uint(keccak256(abi.encodePacked(tx.origin, blockhash(block.number - 1), block.timestamp, seed)));
    }

    function isValidSignature(bytes32 hash, bytes memory signature) internal view returns (bool isValid) {

        bytes32 signedHash = keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
        return signedHash.recover(signature) == operatorAddress;
    }

    function isTokenInFallopianPool(uint tokenId, bytes memory signature) internal view {

        bytes32 msgHash = keccak256(abi.encodePacked(tokenId));
        require(isValidSignature(msgHash, signature), "Invalid signature");
    }

    function isFertilized(uint tokenId) public view returns (bool) {

        uint[] memory bitMapList = fertilizedTokenIds;
        uint partitionIndex = tokenId / 256;
        uint partition = bitMapList[partitionIndex];
        if (partition == MAX_INT) {
            return true;
        }
        uint bitIndex = tokenId % 256;
        uint bit = partition & (1 << bitIndex);
        return (bit != 0);
    }

    function setFertilized(uint tokenId) internal {

        uint[] storage bitMapList = fertilizedTokenIds;
        uint partitionIndex = tokenId / 256;
        uint partition = bitMapList[partitionIndex];
        uint bitIndex = tokenId % 256;
        bitMapList[partitionIndex] = partition | (1 << bitIndex);
    }

    function numOfRounds() external view returns (uint) {

        return raceRandomNumbers.length;
    }

    function numOfParticipants() external view returns (uint) {

        return tokenIdParticipants.length;
    }

    modifier enforceMaxParticipantsInRace(uint num) {

        require((tokenIdParticipants.length + num) <= maxParticipantsInRace, "Race participants has reached the maximum allowed");
        _;
    }

    modifier enforceSignatureEntry(uint[] calldata tokenIds, bytes[] calldata signatures) {

        if (enforceRaceEntrySignature) {
            require(tokenIds.length == signatures.length, "Number of signatures must match number of tokenIds");
            for (uint i = 0; i < tokenIds.length; i++) {
                bytes32 msgHash = keccak256(abi.encodePacked(tokenIds[i]));
                require(isValidSignature(msgHash, signatures[i]), "Invalid signature");
            }
        }
        _;
    }
}