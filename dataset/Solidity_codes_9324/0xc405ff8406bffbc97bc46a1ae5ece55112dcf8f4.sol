pragma solidity ^0.5.2;

contract IFactRegistry {

    function isValid(bytes32 fact)
        external view
        returns(bool);

}
pragma solidity ^0.5.2;


contract PublicInputOffsets {

    uint256 internal constant OFFSET_LOG_TRACE_LENGTH = 0;
    uint256 internal constant OFFSET_VDF_OUTPUT_X = 1;
    uint256 internal constant OFFSET_VDF_OUTPUT_Y = 2;
    uint256 internal constant OFFSET_VDF_INPUT_X = 3;
    uint256 internal constant OFFSET_VDF_INPUT_Y = 4;
}
pragma solidity ^0.5.2;



contract BeaconContract is PublicInputOffsets {

    event LogNewRandomness(uint256 blockNumber, bytes32 randomness);
    mapping(uint256 => bytes32) private registeredRandomness;

    uint256 latestBlockNumber;
    address public owner;
    uint256 public n_iterations;
    IFactRegistry verifierContract;
    uint256 internal constant PRIME = 0x30000003000000010000000000000001;
    uint256 internal constant MAX_LOG_TRACE_LENGTH = 40;
    uint256 internal constant PUBLIC_INPUT_SIZE = 5;

    modifier onlyOwner {

        require(msg.sender == owner, "Sender is not the owner");
        _;
    }

    constructor(address verifierAddress, uint256 n_iters) public {
        owner = msg.sender;
        verifierContract = IFactRegistry(verifierAddress);
        n_iterations = n_iters;
    }

    function registerNewRandomness(
        uint256 blockNumber,
        bytes32 blockHash,
        uint256[PUBLIC_INPUT_SIZE] calldata proofPublicInput
    ) external onlyOwner {

        require(
            blockNumber < block.number && block.number <= blockNumber + 255,
            "Block is not within the last 256 blocks."
        );
        require(
            blockhash(blockNumber) == blockHash && blockHash != 0,
            "blockHash does not match blockNumber or too old."
        );
        require(
            proofPublicInput[OFFSET_LOG_TRACE_LENGTH] < MAX_LOG_TRACE_LENGTH,
            "VDF reported length exceeds the integer overflow protection limit."
        );
        require(
            n_iterations == 10 * 2**proofPublicInput[OFFSET_LOG_TRACE_LENGTH] - 1,
            "Public input and n_iterations are not compatible."
        );
        require(
            proofPublicInput[OFFSET_VDF_OUTPUT_X] < PRIME &&
                proofPublicInput[OFFSET_VDF_OUTPUT_Y] < PRIME,
            "Invalid vdf output."
        );
        uint256 vdfInput = uint256(keccak256(abi.encodePacked(blockHash, "veedo")));
        require(
            vdfInput & ((1 << 125) - 1) == proofPublicInput[OFFSET_VDF_INPUT_X],
            "blockHash does not match the given proofPublicInput."
        );
        require(
            ((vdfInput >> 125) & ((1 << 125) - 1)) == proofPublicInput[OFFSET_VDF_INPUT_Y],
            "blockHash does not match the given proofPublicInput."
        );
        require(
            verifierContract.isValid(keccak256(abi.encodePacked(proofPublicInput))),
            "No valid proof provided."
        );
        bytes32 randomness = keccak256(
            abi.encodePacked(
                proofPublicInput[OFFSET_VDF_OUTPUT_X],
                proofPublicInput[OFFSET_VDF_OUTPUT_Y],
                "veedo"
            )
        );
        registeredRandomness[blockNumber] = randomness;
        emit LogNewRandomness(blockNumber, randomness);
        if (blockNumber > latestBlockNumber) {
            latestBlockNumber = blockNumber;
        }
    }

    function getRandomness(uint256 blockNumber)
        external
        view
        returns (bytes32)
    {

        return registeredRandomness[blockNumber];
    }

    function getLatestRandomness() external view returns (uint256, bytes32) {

        return (latestBlockNumber, registeredRandomness[latestBlockNumber]);
    }
}
