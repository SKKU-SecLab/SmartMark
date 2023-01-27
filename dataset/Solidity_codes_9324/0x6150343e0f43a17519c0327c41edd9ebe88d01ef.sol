
pragma solidity ^0.7.0;


contract Ownable
{

    address public owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor()
    {
        owner = msg.sender;
    }

    modifier onlyOwner()
    {

        require(msg.sender == owner, "UNAUTHORIZED");
        _;
    }

    function transferOwnership(
        address newOwner
        )
        public
        virtual
        onlyOwner
    {

        require(newOwner != address(0), "ZERO_ADDRESS");
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }

    function renounceOwnership()
        public
        onlyOwner
    {

        emit OwnershipTransferred(owner, address(0));
        owner = address(0);
    }
}


pragma experimental ABIEncoderV2;







contract Claimable is Ownable
{

    address public pendingOwner;

    modifier onlyPendingOwner() {

        require(msg.sender == pendingOwner, "UNAUTHORIZED");
        _;
    }

    function transferOwnership(
        address newOwner
        )
        public
        override
        onlyOwner
    {

        require(newOwner != address(0) && newOwner != owner, "INVALID_ADDRESS");
        pendingOwner = newOwner;
    }

    function claimOwnership()
        public
        onlyPendingOwner
    {

        emit OwnershipTransferred(owner, pendingOwner);
        owner = pendingOwner;
        pendingOwner = address(0);
    }
}



abstract contract IBlockVerifier is Claimable
{

    event CircuitRegistered(
        uint8  indexed blockType,
        uint16         blockSize,
        uint8          blockVersion
    );

    event CircuitDisabled(
        uint8  indexed blockType,
        uint16         blockSize,
        uint8          blockVersion
    );


    function registerCircuit(
        uint8    blockType,
        uint16   blockSize,
        uint8    blockVersion,
        uint[18] calldata vk
        )
        external
        virtual;

    function disableCircuit(
        uint8  blockType,
        uint16 blockSize,
        uint8  blockVersion
        )
        external
        virtual;

    function verifyProofs(
        uint8  blockType,
        uint16 blockSize,
        uint8  blockVersion,
        uint[] calldata publicInputs,
        uint[] calldata proofs
        )
        external
        virtual
        view
        returns (bool);

    function isCircuitRegistered(
        uint8  blockType,
        uint16 blockSize,
        uint8  blockVersion
        )
        external
        virtual
        view
        returns (bool);

    function isCircuitEnabled(
        uint8  blockType,
        uint16 blockSize,
        uint8  blockVersion
        )
        external
        virtual
        view
        returns (bool);
}







contract ReentrancyGuard
{

    uint private _guardValue;

    modifier nonReentrant()
    {

        require(_guardValue == 0, "REENTRANCY");

        _guardValue = 1;

        _;

        _guardValue = 0;
    }
}





library BatchVerifier {

    function GroupOrder ()
        public pure returns (uint256)
    {
        return 21888242871839275222246405745257275088548364400416034343698204186575808495617;
    }

    function NegateY( uint256 Y )
        internal pure returns (uint256)
    {

        uint q = 21888242871839275222246405745257275088696311157297823662689037894645226208583;
        return q - (Y % q);
    }

    function getProofEntropy(
        uint256[] memory in_proof,
        uint256[] memory proof_inputs,
        uint proofNumber
    )
        internal pure returns (uint256)
    {

        return uint(
            keccak256(
                abi.encodePacked(
                    in_proof[proofNumber*8 + 0], in_proof[proofNumber*8 + 1], in_proof[proofNumber*8 + 2], in_proof[proofNumber*8 + 3],
                    in_proof[proofNumber*8 + 4], in_proof[proofNumber*8 + 5], in_proof[proofNumber*8 + 6], in_proof[proofNumber*8 + 7],
                    proof_inputs[proofNumber]
                )
            )
        ) >> 3;
    }

    function accumulate(
        uint256[] memory in_proof,
        uint256[] memory proof_inputs, // public inputs, length is num_inputs * num_proofs
        uint256 num_proofs
    ) internal view returns (
        bool success,
        uint256[] memory proofsAandC,
        uint256[] memory inputAccumulators
    ) {

        uint256 q = 21888242871839275222246405745257275088548364400416034343698204186575808495617;
        uint256 numPublicInputs = proof_inputs.length / num_proofs;
        uint256[] memory entropy = new uint256[](num_proofs);
        inputAccumulators = new uint256[](numPublicInputs + 1);

        for (uint256 proofNumber = 0; proofNumber < num_proofs; proofNumber++) {
            if (proofNumber == 0) {
                entropy[proofNumber] = 1;
            } else {
                entropy[proofNumber] = getProofEntropy(in_proof, proof_inputs, proofNumber);
            }
            require(entropy[proofNumber] != 0, "Entropy should not be zero");
            inputAccumulators[0] = addmod(inputAccumulators[0], entropy[proofNumber], q);
            for (uint256 i = 0; i < numPublicInputs; i++) {
                require(proof_inputs[proofNumber * numPublicInputs + i] < q, "INVALID_INPUT");
                inputAccumulators[i+1] = addmod(inputAccumulators[i+1], mulmod(entropy[proofNumber], proof_inputs[proofNumber * numPublicInputs + i], q), q);
            }
        }

        uint256[3] memory mul_input;


        proofsAandC = new uint256[](num_proofs*2 + 2);

        proofsAandC[0] = in_proof[0];
        proofsAandC[1] = in_proof[1];

        for (uint256 proofNumber = 1; proofNumber < num_proofs; proofNumber++) {
            require(entropy[proofNumber] < q, "INVALID_INPUT");
            mul_input[0] = in_proof[proofNumber*8];
            mul_input[1] = in_proof[proofNumber*8 + 1];
            mul_input[2] = entropy[proofNumber];
            assembly {
                success := staticcall(sub(gas(), 2000), 7, mul_input, 0x60, mul_input, 0x40)
            }
            if (!success) {
                return (false, proofsAandC, inputAccumulators);
            }
            proofsAandC[proofNumber*2] = mul_input[0];
            proofsAandC[proofNumber*2 + 1] = mul_input[1];
        }


        uint256[4] memory add_input;

        add_input[0] = in_proof[6];
        add_input[1] = in_proof[7];

        for (uint256 proofNumber = 1; proofNumber < num_proofs; proofNumber++) {
            mul_input[0] = in_proof[proofNumber*8 + 6];
            mul_input[1] = in_proof[proofNumber*8 + 7];
            mul_input[2] = entropy[proofNumber];
            assembly {
                success := staticcall(sub(gas(), 2000), 7, mul_input, 0x60, add(add_input, 0x40), 0x40)
            }
            if (!success) {
                return (false, proofsAandC, inputAccumulators);
            }

            assembly {
                success := staticcall(sub(gas(), 2000), 6, add_input, 0x80, add_input, 0x40)
            }
            if (!success) {
                return (false, proofsAandC, inputAccumulators);
            }
        }

        proofsAandC[num_proofs*2] = add_input[0];
        proofsAandC[num_proofs*2 + 1] = add_input[1];
    }

    function prepareBatches(
        uint256[14] memory in_vk,
        uint256[4] memory vk_gammaABC,
        uint256[] memory inputAccumulators
    ) internal view returns (
        bool success,
        uint256[4] memory finalVksAlphaX
    ) {

        uint256[4] memory add_input;
        uint256[3] memory mul_input;

        for (uint256 i = 0; i < inputAccumulators.length; i++) {
            mul_input[0] = vk_gammaABC[2*i];
            mul_input[1] = vk_gammaABC[2*i + 1];
            mul_input[2] = inputAccumulators[i];

            assembly {
                success := staticcall(sub(gas(), 2000), 7, mul_input, 0x60, add(add_input, 0x40), 0x40)
            }
            if (!success) {
                return (false, finalVksAlphaX);
            }

            assembly {
                success := staticcall(sub(gas(), 2000), 6, add_input, 0x80, add_input, 0x40)
            }
            if (!success) {
                return (false, finalVksAlphaX);
            }
        }

        finalVksAlphaX[2] = add_input[0];
        finalVksAlphaX[3] = add_input[1];

        uint256[3] memory finalVKalpha;
        finalVKalpha[0] = in_vk[0];
        finalVKalpha[1] = in_vk[1];
        finalVKalpha[2] = inputAccumulators[0];

        assembly {
            success := staticcall(sub(gas(), 2000), 7, finalVKalpha, 0x60, finalVKalpha, 0x40)
        }
        if (!success) {
            return (false, finalVksAlphaX);
        }

        finalVksAlphaX[0] = finalVKalpha[0];
        finalVksAlphaX[1] = finalVKalpha[1];
    }


    function BatchVerify (
        uint256[14] memory in_vk, // verifying key is always constant number of elements
        uint256[4] memory vk_gammaABC, // variable length, depends on number of inputs
        uint256[] memory in_proof, // proof itself, length is 8 * num_proofs
        uint256[] memory proof_inputs, // public inputs, length is num_inputs * num_proofs
        uint256 num_proofs
    )
    internal
    view
    returns (bool success)
    {
        require(in_proof.length == num_proofs * 8, "Invalid proofs length for a batch");
        require(proof_inputs.length % num_proofs == 0, "Invalid inputs length for a batch");
        require(((vk_gammaABC.length / 2) - 1) == proof_inputs.length / num_proofs, "Invalid verification key");


        bool valid;
        uint256[] memory proofsAandC;
        uint256[] memory inputAccumulators;
        (valid, proofsAandC, inputAccumulators) = accumulate(in_proof, proof_inputs, num_proofs);
        if (!valid) {
            return false;
        }

        uint256[4] memory finalVksAlphaX;
        (valid, finalVksAlphaX) = prepareBatches(in_vk, vk_gammaABC, inputAccumulators);
        if (!valid) {
            return false;
        }

        uint256[] memory inputs = new uint256[](6*num_proofs + 18);
        for (uint256 proofNumber = 0; proofNumber < num_proofs; proofNumber++) {
            inputs[proofNumber*6] = proofsAandC[proofNumber*2];
            inputs[proofNumber*6 + 1] = proofsAandC[proofNumber*2 + 1];
            inputs[proofNumber*6 + 2] = in_proof[proofNumber*8 + 2];
            inputs[proofNumber*6 + 3] = in_proof[proofNumber*8 + 3];
            inputs[proofNumber*6 + 4] = in_proof[proofNumber*8 + 4];
            inputs[proofNumber*6 + 5] = in_proof[proofNumber*8 + 5];
        }

        inputs[num_proofs*6] = finalVksAlphaX[0];
        inputs[num_proofs*6 + 1] = NegateY(finalVksAlphaX[1]);
        inputs[num_proofs*6 + 2] = in_vk[2];
        inputs[num_proofs*6 + 3] = in_vk[3];
        inputs[num_proofs*6 + 4] = in_vk[4];
        inputs[num_proofs*6 + 5] = in_vk[5];

        inputs[num_proofs*6 + 6] = finalVksAlphaX[2];
        inputs[num_proofs*6 + 7] = NegateY(finalVksAlphaX[3]);
        inputs[num_proofs*6 + 8] = in_vk[6];
        inputs[num_proofs*6 + 9] = in_vk[7];
        inputs[num_proofs*6 + 10] = in_vk[8];
        inputs[num_proofs*6 + 11] = in_vk[9];

        inputs[num_proofs*6 + 12] = proofsAandC[num_proofs*2];
        inputs[num_proofs*6 + 13] = NegateY(proofsAandC[num_proofs*2 + 1]);
        inputs[num_proofs*6 + 14] = in_vk[10];
        inputs[num_proofs*6 + 15] = in_vk[11];
        inputs[num_proofs*6 + 16] = in_vk[12];
        inputs[num_proofs*6 + 17] = in_vk[13];

        uint256 inputsLength = inputs.length * 32;
        uint[1] memory out;
        require(inputsLength % 192 == 0, "Inputs length should be multiple of 192 bytes");

        assembly {
            success := staticcall(sub(gas(), 2000), 8, add(inputs, 0x20), inputsLength, out, 0x20)
        }
        return success && out[0] == 1;
    }
}




library Verifier
{

    function ScalarField ()
        internal
        pure
        returns (uint256)
    {
        return 21888242871839275222246405745257275088548364400416034343698204186575808495617;
    }

    function NegateY( uint256 Y )
        internal pure returns (uint256)
    {

        uint q = 21888242871839275222246405745257275088696311157297823662689037894645226208583;
        return q - (Y % q);
    }


    function Verify(
        uint256[14] memory in_vk,
        uint256[4] memory vk_gammaABC,
        uint256[] memory in_proof,
        uint256[] memory proof_inputs
        )
        internal
        view
        returns (bool)
    {

        uint256 snark_scalar_field = 21888242871839275222246405745257275088548364400416034343698204186575808495617;
        require(((vk_gammaABC.length / 2) - 1) == proof_inputs.length, "INVALID_VALUE");

        uint256[3] memory mul_input;
        uint256[4] memory add_input;
        bool success;
        uint m = 2;

        add_input[0] = vk_gammaABC[0];
        add_input[1] = vk_gammaABC[1];

        for (uint i = 0; i < proof_inputs.length; i++) {
            require(proof_inputs[i] < snark_scalar_field, "INVALID_INPUT");
            mul_input[0] = vk_gammaABC[m++];
            mul_input[1] = vk_gammaABC[m++];
            mul_input[2] = proof_inputs[i];

            assembly {
                success := staticcall(sub(gas(), 2000), 7, mul_input, 0x80, add(add_input, 0x40), 0x60)
            }
            if (!success) {
                return false;
            }

            assembly {
                success := staticcall(sub(gas(), 2000), 6, add_input, 0xc0, add_input, 0x60)
            }
            if (!success) {
                return false;
            }
        }

        uint[24] memory input = [
            in_proof[0], in_proof[1],                           // proof.A   (G1)
            in_proof[2], in_proof[3], in_proof[4], in_proof[5], // proof.B   (G2)

            in_vk[0], NegateY(in_vk[1]),                        // -vk.alpha (G1)
            in_vk[2], in_vk[3], in_vk[4], in_vk[5],             // vk.beta   (G2)

            add_input[0], NegateY(add_input[1]),                // -vk_x     (G1)
            in_vk[6], in_vk[7], in_vk[8], in_vk[9],             // vk.gamma  (G2)

            in_proof[6], NegateY(in_proof[7]),                  // -proof.C  (G1)
            in_vk[10], in_vk[11], in_vk[12], in_vk[13]          // vk.delta  (G2)
        ];

        uint[1] memory out;
        assembly {
            success := staticcall(sub(gas(), 2000), 8, input, 768, out, 0x20)
        }
        return success && out[0] != 0;
    }
}








interface IAgent{}


interface IAgentRegistry
{

    function isAgent(
        address owner,
        address agent
        )
        external
        view
        returns (bool);


    function isAgent(
        address[] calldata owners,
        address            agent
        )
        external
        view
        returns (bool);

}






interface IDepositContract
{

    function isTokenSupported(address token)
        external
        view
        returns (bool);


    function deposit(
        address from,
        address token,
        uint96  amount,
        bytes   calldata extraData
        )
        external
        payable
        returns (uint96 amountReceived);


    function withdraw(
        address from,
        address to,
        address token,
        uint    amount,
        bytes   calldata extraData
        )
        external
        payable;


    function transfer(
        address from,
        address to,
        address token,
        uint    amount
        )
        external
        payable;


    function isETH(address addr)
        external
        view
        returns (bool);

}






abstract contract ILoopringV3 is Claimable
{
    event ExchangeStakeDeposited(address exchangeAddr, uint amount);
    event ExchangeStakeWithdrawn(address exchangeAddr, uint amount);
    event ExchangeStakeBurned(address exchangeAddr, uint amount);
    event SettingsUpdated(uint time);

    mapping (address => uint) internal exchangeStake;

    address public lrcAddress;
    uint    public totalStake;
    address public blockVerifierAddress;
    uint    public forcedWithdrawalFee;
    uint    public tokenRegistrationFeeLRCBase;
    uint    public tokenRegistrationFeeLRCDelta;
    uint8   public protocolTakerFeeBips;
    uint8   public protocolMakerFeeBips;

    address payable public protocolFeeVault;

    function updateSettings(
        address payable _protocolFeeVault,   // address(0) not allowed
        address _blockVerifierAddress,       // address(0) not allowed
        uint    _forcedWithdrawalFee
        )
        external
        virtual;

    function updateProtocolFeeSettings(
        uint8 _protocolTakerFeeBips,
        uint8 _protocolMakerFeeBips
        )
        external
        virtual;

    function getExchangeStake(
        address exchangeAddr
        )
        public
        virtual
        view
        returns (uint stakedLRC);

    function burnExchangeStake(
        uint amount
        )
        external
        virtual
        returns (uint burnedLRC);

    function depositExchangeStake(
        address exchangeAddr,
        uint    amountLRC
        )
        external
        virtual
        returns (uint stakedLRC);

    function withdrawExchangeStake(
        address recipient,
        uint    requestedAmount
        )
        external
        virtual
        returns (uint amountLRC);

    function getProtocolFeeValues(
        )
        public
        virtual
        view
        returns (
            uint8 takerFeeBips,
            uint8 makerFeeBips
        );
}



library ExchangeData
{

    enum TransactionType
    {
        NOOP,
        DEPOSIT,
        WITHDRAWAL,
        TRANSFER,
        SPOT_TRADE,
        ACCOUNT_UPDATE,
        AMM_UPDATE
    }

    struct Token
    {
        address token;
    }

    struct ProtocolFeeData
    {
        uint32 syncedAt; // only valid before 2105 (85 years to go)
        uint8  takerFeeBips;
        uint8  makerFeeBips;
        uint8  previousTakerFeeBips;
        uint8  previousMakerFeeBips;
    }

    struct AuxiliaryData
    {
        uint  txIndex;
        bytes data;
    }

    struct Block
    {
        uint8      blockType;
        uint16     blockSize;
        uint8      blockVersion;
        bytes      data;
        uint256[8] proof;

        bool storeBlockInfoOnchain;

        AuxiliaryData[] auxiliaryData;

        bytes offchainData;
    }

    struct BlockInfo
    {
        uint32  timestamp;
        bytes28 blockDataHash;
    }

    struct Deposit
    {
        uint96 amount;
        uint64 timestamp;
    }

    struct ForcedWithdrawal
    {
        address owner;
        uint64  timestamp;
    }

    struct Constants
    {
        uint SNARK_SCALAR_FIELD;
        uint MAX_OPEN_FORCED_REQUESTS;
        uint MAX_AGE_FORCED_REQUEST_UNTIL_WITHDRAW_MODE;
        uint TIMESTAMP_HALF_WINDOW_SIZE_IN_SECONDS;
        uint MAX_NUM_ACCOUNTS;
        uint MAX_NUM_TOKENS;
        uint MIN_AGE_PROTOCOL_FEES_UNTIL_UPDATED;
        uint MIN_TIME_IN_SHUTDOWN;
        uint TX_DATA_AVAILABILITY_SIZE;
        uint MAX_AGE_DEPOSIT_UNTIL_WITHDRAWABLE_UPPERBOUND;
    }

    function SNARK_SCALAR_FIELD() internal pure returns (uint) {

        return 21888242871839275222246405745257275088548364400416034343698204186575808495617;
    }
    function MAX_OPEN_FORCED_REQUESTS() internal pure returns (uint16) { return 4096; }

    function MAX_AGE_FORCED_REQUEST_UNTIL_WITHDRAW_MODE() internal pure returns (uint32) { return 15 days; }

    function TIMESTAMP_HALF_WINDOW_SIZE_IN_SECONDS() internal pure returns (uint32) { return 7 days; }

    function MAX_NUM_ACCOUNTS() internal pure returns (uint) { return 2 ** 32; }

    function MAX_NUM_TOKENS() internal pure returns (uint) { return 2 ** 16; }

    function MIN_AGE_PROTOCOL_FEES_UNTIL_UPDATED() internal pure returns (uint32) { return 7 days; }

    function MIN_TIME_IN_SHUTDOWN() internal pure returns (uint32) { return 30 days; }

    function TX_DATA_AVAILABILITY_SIZE() internal pure returns (uint32) { return 68; }

    function MAX_AGE_DEPOSIT_UNTIL_WITHDRAWABLE_UPPERBOUND() internal pure returns (uint32) { return 15 days; }

    function ACCOUNTID_PROTOCOLFEE() internal pure returns (uint32) { return 0; }


    function TX_DATA_AVAILABILITY_SIZE_PART_1() internal pure returns (uint32) { return 29; }

    function TX_DATA_AVAILABILITY_SIZE_PART_2() internal pure returns (uint32) { return 39; }


    struct AccountLeaf
    {
        uint32   accountID;
        address  owner;
        uint     pubKeyX;
        uint     pubKeyY;
        uint32   nonce;
        uint     feeBipsAMM;
    }

    struct BalanceLeaf
    {
        uint16   tokenID;
        uint96   balance;
        uint96   weightAMM;
        uint     storageRoot;
    }

    struct MerkleProof
    {
        ExchangeData.AccountLeaf accountLeaf;
        ExchangeData.BalanceLeaf balanceLeaf;
        uint[48]                 accountMerkleProof;
        uint[24]                 balanceMerkleProof;
    }

    struct BlockContext
    {
        bytes32 DOMAIN_SEPARATOR;
        uint32  timestamp;
    }

    struct State
    {
        uint32  maxAgeDepositUntilWithdrawable;
        bytes32 DOMAIN_SEPARATOR;

        ILoopringV3      loopring;
        IBlockVerifier   blockVerifier;
        IAgentRegistry   agentRegistry;
        IDepositContract depositContract;


        bytes32 merkleRoot;

        mapping(uint => BlockInfo) blocks;
        uint  numBlocks;

        Token[] tokens;

        mapping (address => uint16) tokenToTokenId;

        mapping (uint32 => mapping (uint16 => bool)) withdrawnInWithdrawMode;

        mapping (address => mapping (uint16 => uint)) amountWithdrawable;

        mapping (uint32 => mapping (uint16 => ForcedWithdrawal)) pendingForcedWithdrawals;

        mapping (address => mapping (uint16 => Deposit)) pendingDeposits;

        mapping (address => mapping (bytes32 => bool)) approvedTx;

        mapping (address => mapping (address => mapping (uint16 => mapping (uint => mapping (uint32 => address))))) withdrawalRecipient;


        uint32 numPendingForcedTransactions;

        ProtocolFeeData protocolFeeData;

        uint shutdownModeStartTime;

        uint withdrawalModeStartTime;

        mapping (address => uint) protocolFeeLastWithdrawnTime;
    }
}




contract BlockVerifier is ReentrancyGuard, IBlockVerifier
{

    struct Circuit
    {
        bool registered;
        bool enabled;
        uint[18] verificationKey;
    }

    mapping (uint8 => mapping (uint16 => mapping (uint8 => Circuit))) public circuits;

    constructor() Claimable() {}

    function registerCircuit(
        uint8    blockType,
        uint16   blockSize,
        uint8    blockVersion,
        uint[18] calldata vk
        )
        external
        override
        nonReentrant
        onlyOwner
    {

        Circuit storage circuit = circuits[blockType][blockSize][blockVersion];
        require(circuit.registered == false, "ALREADY_REGISTERED");

        for (uint i = 0; i < 18; i++) {
            circuit.verificationKey[i] = vk[i];
        }
        circuit.registered = true;
        circuit.enabled = true;

        emit CircuitRegistered(
            blockType,
            blockSize,
            blockVersion
        );
    }

    function disableCircuit(
        uint8  blockType,
        uint16 blockSize,
        uint8  blockVersion
        )
        external
        override
        nonReentrant
        onlyOwner
    {

        Circuit storage circuit = circuits[blockType][blockSize][blockVersion];
        require(circuit.registered == true, "NOT_REGISTERED");
        require(circuit.enabled == true, "ALREADY_DISABLED");

        circuit.enabled = false;

        emit CircuitDisabled(
            blockType,
            blockSize,
            blockVersion
        );
    }

    function verifyProofs(
        uint8  blockType,
        uint16 blockSize,
        uint8  blockVersion,
        uint[] calldata publicInputs,
        uint[] calldata proofs
        )
        external
        override
        view
        returns (bool)
    {

        Circuit storage circuit = circuits[blockType][blockSize][blockVersion];
        require(circuit.registered == true, "NOT_REGISTERED");

        uint[18] storage vk = circuit.verificationKey;
        uint[14] memory _vk = [
            vk[0], vk[1], vk[2], vk[3], vk[4], vk[5], vk[6],
            vk[7], vk[8], vk[9], vk[10], vk[11], vk[12], vk[13]
        ];
        uint[4] memory _vk_gammaABC = [vk[14], vk[15], vk[16], vk[17]];

        if (publicInputs.length == 1) {
            return Verifier.Verify(_vk, _vk_gammaABC, proofs, publicInputs);
        } else {
            return BatchVerifier.BatchVerify(
                _vk,
                _vk_gammaABC,
                proofs,
                publicInputs,
                publicInputs.length
            );
        }
    }

    function isCircuitRegistered(
        uint8  blockType,
        uint16 blockSize,
        uint8  blockVersion
        )
        external
        override
        view
        returns (bool)
    {

        return circuits[blockType][blockSize][blockVersion].registered;
    }

    function isCircuitEnabled(
        uint8  blockType,
        uint16 blockSize,
        uint8  blockVersion
        )
        external
        override
        view
        returns (bool)
    {

        return circuits[blockType][blockSize][blockVersion].enabled;
    }

    function getVerificationKey(
        uint8  blockType,
        uint16 blockSize,
        uint8  blockVersion
        )
        external
        view
        returns (uint[18] memory)
    {

        return circuits[blockType][blockSize][blockVersion].verificationKey;
    }
}