
pragma solidity >=0.6.0 <0.8.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}// MIT

pragma solidity >=0.6.0 <0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}// MIT

pragma solidity >=0.6.0 <0.8.0;

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}// MIT

pragma solidity >=0.6.0 <0.8.0;


abstract contract Pausable is Context {
    event Paused(address account);

    event Unpaused(address account);

    bool private _paused;

    constructor () internal {
        _paused = false;
    }

    function paused() public view virtual returns (bool) {
        return _paused;
    }

    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
        _;
    }

    modifier whenPaused() {
        require(paused(), "Pausable: not paused");
        _;
    }

    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}// MIT

pragma solidity >=0.6.0 <0.8.0;

library SafeMath {

    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b > a) return (false, 0);
        return (true, a - b);
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b == 0) return (false, 0);
        return (true, a / b);
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b == 0) return (false, 0);
        return (true, a % b);
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b <= a, "SafeMath: subtraction overflow");
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0, "SafeMath: division by zero");
        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0, "SafeMath: modulo by zero");
        return a % b;
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b <= a, errorMessage);
        return a - b;
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        return a / b;
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        return a % b;
    }
}// GPL-2.0-only
pragma solidity >=0.6.10 <0.8.0;

interface IVerifier {

    function verify(bytes memory serialized_proof, uint256 _keyId) external;

}// GPL-2.0-only
pragma solidity >=0.6.10 <0.8.0;

interface IRollupProcessor {

    function feeDistributor() external view returns (address);


    function escapeHatch(
        bytes calldata proofData,
        bytes calldata signatures,
        bytes calldata viewingKeys
    ) external;


    function processRollup(
        bytes calldata proofData,
        bytes calldata signatures,
        bytes calldata viewingKeys,
        bytes calldata providerSignature,
        address provider,
        address payable feeReceiver,
        uint256 feeLimit
    ) external;


    function depositPendingFunds(
        uint256 assetId,
        uint256 amount,
        address owner
    ) external payable;


    function depositPendingFundsPermit(
        uint256 assetId,
        uint256 amount,
        address owner,
        address spender,
        uint256 permitApprovalAmount,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;


    function setRollupProvider(address provderAddress, bool valid) external;


    function approveProof(bytes32 _proofHash) external;


    function setFeeDistributor(address feeDistributorAddress) external;


    function setVerifier(address verifierAddress) external;


    function setSupportedAsset(address linkedToken, bool supportsPermit) external;


    function setAssetPermitSupport(uint256 assetId, bool supportsPermit) external;


    function getSupportedAsset(uint256 assetId) external view returns (address);


    function getSupportedAssets() external view returns (address[] memory);


    function getTotalDeposited() external view returns (uint256[] memory);


    function getTotalWithdrawn() external view returns (uint256[] memory);


    function getTotalPendingDeposit() external view returns (uint256[] memory);


    function getTotalFees() external view returns (uint256[] memory);


    function getAssetPermitSupport(uint256 assetId) external view returns (bool);


    function getEscapeHatchStatus() external view returns (bool, uint256);


    function getUserPendingDeposit(uint256 assetId, address userAddress) external view returns (uint256);

}// GPL-2.0-only
pragma solidity >=0.6.10 <0.8.0;

interface IFeeDistributor {

    event FeeReimbursed(address receiver, uint256 amount);

    function txFeeBalance(uint256 assetId) external view returns (uint256);


    function deposit(uint256 assetId, uint256 amount) external payable returns (uint256 depositedAmount);


    function reimburseGas(
        uint256 gasUsed,
        uint256 feeLimit,
        address payable feeReceiver
    ) external returns (uint256 reimbursement);

}// GPL-2.0-only
pragma solidity >=0.6.10 <0.8.0;


interface IERC20Permit is IERC20 {

    function nonces(address user) external view returns (uint256);


    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

}// GPL-2.0-only

pragma solidity >=0.6.0 <0.8.0;
pragma experimental ABIEncoderV2;

library Types {

    uint256 constant PROGRAM_WIDTH = 4;
    uint256 constant NUM_NU_CHALLENGES = 11;

    uint256 constant coset_generator0 = 0x0000000000000000000000000000000000000000000000000000000000000005;
    uint256 constant coset_generator1 = 0x0000000000000000000000000000000000000000000000000000000000000006;
    uint256 constant coset_generator2 = 0x0000000000000000000000000000000000000000000000000000000000000007;

    uint256 constant coset_generator7 = 0x000000000000000000000000000000000000000000000000000000000000000c;

    struct G1Point {
        uint256 x;
        uint256 y;
    }

    struct G2Point {
        uint256 x0;
        uint256 x1;
        uint256 y0;
        uint256 y1;
    }

    struct Proof {
        G1Point W1;
        G1Point W2;
        G1Point W3;
        G1Point W4;
        G1Point Z;
        G1Point T1;
        G1Point T2;
        G1Point T3;
        G1Point T4;
        uint256 w1;
        uint256 w2;
        uint256 w3;
        uint256 w4;
        uint256 sigma1;
        uint256 sigma2;
        uint256 sigma3;
        uint256 q_arith;
        uint256 q_ecc;
        uint256 q_c;
        uint256 linearization_polynomial;
        uint256 grand_product_at_z_omega;
        uint256 w1_omega;
        uint256 w2_omega;
        uint256 w3_omega;
        uint256 w4_omega;
        G1Point PI_Z;
        G1Point PI_Z_OMEGA;
        G1Point recursive_P1;
        G1Point recursive_P2;
        uint256 quotient_polynomial_eval;
    }

    struct ChallengeTranscript {
        uint256 alpha_base;
        uint256 alpha;
        uint256 zeta;
        uint256 beta;
        uint256 gamma;
        uint256 u;
        uint256 v0;
        uint256 v1;
        uint256 v2;
        uint256 v3;
        uint256 v4;
        uint256 v5;
        uint256 v6;
        uint256 v7;
        uint256 v8;
        uint256 v9;
        uint256 v10;
    }

    struct VerificationKey {
        uint256 circuit_size;
        uint256 num_inputs;
        uint256 work_root;
        uint256 domain_inverse;
        uint256 work_root_inverse;
        G1Point Q1;
        G1Point Q2;
        G1Point Q3;
        G1Point Q4;
        G1Point Q5;
        G1Point QM;
        G1Point QC;
        G1Point QARITH;
        G1Point QECC;
        G1Point QRANGE;
        G1Point QLOGIC;
        G1Point SIGMA1;
        G1Point SIGMA2;
        G1Point SIGMA3;
        G1Point SIGMA4;
        bool contains_recursive_proof;
        uint256 recursive_proof_indices;
        G2Point g2_x;

        uint256 zeta_pow_n;
    }
}// GPL-2.0-only
pragma solidity >=0.6.0 <0.8.0;


library Bn254Crypto {

    uint256 constant p_mod = 21888242871839275222246405745257275088696311157297823662689037894645226208583;
    uint256 constant r_mod = 21888242871839275222246405745257275088548364400416034343698204186575808495617;

    function pow_small(
        uint256 base,
        uint256 exponent,
        uint256 modulus
    ) internal pure returns (uint256) {

        uint256 result = 1;
        uint256 input = base;
        uint256 count = 1;

        assembly {
            let endpoint := add(exponent, 0x01)
            for {} lt(count, endpoint) { count := add(count, count) }
            {
                if and(exponent, count) {
                    result := mulmod(result, input, modulus)
                }
                input := mulmod(input, input, modulus)
            }
        }

        return result;
    }

    function invert(uint256 fr) internal view returns (uint256)
    {

        uint256 output;
        bool success;
        uint256 p = r_mod;
        assembly {
            let mPtr := mload(0x40)
            mstore(mPtr, 0x20)
            mstore(add(mPtr, 0x20), 0x20)
            mstore(add(mPtr, 0x40), 0x20)
            mstore(add(mPtr, 0x60), fr)
            mstore(add(mPtr, 0x80), sub(p, 2))
            mstore(add(mPtr, 0xa0), p)
            success := staticcall(gas(), 0x05, mPtr, 0xc0, 0x00, 0x20)
            output := mload(0x00)
        }
        require(success, "pow precompile call failed!");
        return output;
    }

    function new_g1(uint256 x, uint256 y)
        internal
        pure
        returns (Types.G1Point memory)
    {

        uint256 xValue;
        uint256 yValue;
        assembly {
            xValue := mod(x, r_mod)
            yValue := mod(y, r_mod)
        }
        return Types.G1Point(xValue, yValue);
    }

    function new_g2(uint256 x0, uint256 x1, uint256 y0, uint256 y1)
        internal
        pure
        returns (Types.G2Point memory)
    {

        return Types.G2Point(x0, x1, y0, y1);
    }

    function P1() internal pure returns (Types.G1Point memory) {

        return Types.G1Point(1, 2);
    }

    function P2() internal pure returns (Types.G2Point memory) {

        return Types.G2Point({
            x0: 0x198e9393920d483a7260bfb731fb5d25f1aa493335a9e71297e485b7aef312c2,
            x1: 0x1800deef121f1e76426a00665e5c4479674322d4f75edadd46debd5cd992f6ed,
            y0: 0x090689d0585ff075ec9e99ad690c3395bc4b313370b38ef355acdadcd122975b,
            y1: 0x12c85ea5db8c6deb4aab71808dcb408fe3d1e7690c43d37b4ce6cc0166fa7daa
        });
    }


    function pairingProd2(
        Types.G1Point memory a1,
        Types.G2Point memory a2,
        Types.G1Point memory b1,
        Types.G2Point memory b2
    ) internal view returns (bool) {

        validateG1Point(a1);
        validateG1Point(b1);
        bool success;
        uint256 out;
        assembly {
            let mPtr := mload(0x40)
            mstore(mPtr, mload(a1))
            mstore(add(mPtr, 0x20), mload(add(a1, 0x20)))
            mstore(add(mPtr, 0x40), mload(a2))
            mstore(add(mPtr, 0x60), mload(add(a2, 0x20)))
            mstore(add(mPtr, 0x80), mload(add(a2, 0x40)))
            mstore(add(mPtr, 0xa0), mload(add(a2, 0x60)))

            mstore(add(mPtr, 0xc0), mload(b1))
            mstore(add(mPtr, 0xe0), mload(add(b1, 0x20)))
            mstore(add(mPtr, 0x100), mload(b2))
            mstore(add(mPtr, 0x120), mload(add(b2, 0x20)))
            mstore(add(mPtr, 0x140), mload(add(b2, 0x40)))
            mstore(add(mPtr, 0x160), mload(add(b2, 0x60)))
            success := staticcall(
                gas(),
                8,
                mPtr,
                0x180,
                0x00,
                0x20
            )
            out := mload(0x00)
        }
        require(success, "Pairing check failed!");
        return (out != 0);
    }

    function validateG1Point(Types.G1Point memory point) internal pure {

        bool is_well_formed;
        uint256 p = p_mod;
        assembly {
            let x := mload(point)
            let y := mload(add(point, 0x20))

            is_well_formed := and(
                and(
                    and(lt(x, p), lt(y, p)),
                    not(or(iszero(x), iszero(y)))
                ),
                eq(mulmod(y, y, p), addmod(mulmod(x, mulmod(x, x, p), p), 3, p))
            )
        }
        require(is_well_formed, "Bn254: G1 point not on curve, or is malformed");
    }
}// GPL-2.0-only
pragma solidity >=0.6.10 <0.8.0;


contract Decoder {

    using SafeMath for uint256;

    function decodeProof(bytes memory proofData, uint256 numberOfAssets)
        internal
        pure
        returns (
            uint256[4] memory nums,
            bytes32 oldDataRoot,
            bytes32 newDataRoot,
            bytes32 oldNullRoot,
            bytes32 newNullRoot,
            bytes32 oldRootRoot,
            bytes32 newRootRoot
        )
    {

        uint256 rollupId;
        uint256 rollupSize;
        uint256 dataStartIndex;
        uint256 numTxs;
        assembly {
            let dataStart := add(proofData, 0x20) // jump over first word, it's length of data
            rollupId := mload(dataStart)
            rollupSize := mload(add(dataStart, 0x20))
            dataStartIndex := mload(add(dataStart, 0x40))
            oldDataRoot := mload(add(dataStart, 0x60))
            newDataRoot := mload(add(dataStart, 0x80))
            oldNullRoot := mload(add(dataStart, 0xa0))
            newNullRoot := mload(add(dataStart, 0xc0))
            oldRootRoot := mload(add(dataStart, 0xe0))
            newRootRoot := mload(add(dataStart, 0x100))
            numTxs := mload(add(add(dataStart, 0x120), mul(0x20, numberOfAssets)))
        }
        return (
            [rollupId, rollupSize, dataStartIndex, numTxs],
            oldDataRoot,
            newDataRoot,
            oldNullRoot,
            newNullRoot,
            oldRootRoot,
            newRootRoot
        );
    }

    function extractTotalTxFee(bytes memory proofData, uint256 assetId) internal pure returns (uint256) {

        uint256 totalTxFee;
        assembly {
            totalTxFee := mload(add(add(proofData, 0x140), mul(0x20, assetId)))
        }
        return totalTxFee;
    }
}// GPL-2.0-only
pragma solidity >=0.6.10 <0.8.0;

library RollupProcessorLibrary {


    function validateSignature(
        bytes32 digest,
        bytes memory signature,
        address signer
    ) internal view {

        bool result;
        address recoveredSigner = address(0x0);
        require(signer != address(0x0), 'validateSignature: ZERO_ADDRESS');


        bytes32 message;
        assembly {
            mstore(0, "\x19Ethereum Signed Message:\n32")
            mstore(add(0, 28), digest)
            message := keccak256(0, 60)
        }
        assembly {
            let mPtr := mload(0x40)
            let byteLength := mload(signature)

            mstore(mPtr, message)

            let v := shr(248, mload(add(signature, 0x60))) // bitshifting, to resemble padLeft
            let s := mload(add(signature, 0x40))


            mstore(add(mPtr, 0x60), s)
            mstore(add(mPtr, 0x40), mload(add(signature, 0x20)))
            mstore(add(mPtr, 0x20), v)
            result := and(
                and(
                    lt(s, 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A1),
                    and(
                        eq(byteLength, 0x41),
                        or(eq(v, 27), eq(v, 28))
                    )
                ),
                staticcall(gas(), 0x01, mPtr, 0x80, mPtr, 0x20)
            )

            switch eq(message, mload(mPtr))
            case 0 {
                recoveredSigner := mload(mPtr)
            }
            mstore(mPtr, byteLength) // and put the byte length back where it belongs
        
            result := and(result, not(iszero(recoveredSigner)))
        }

        require(result, 'validateSignature: signature recovery failed');
        require(recoveredSigner == signer, 'validateSignature: INVALID_SIGNATURE');
    }

    function validateUnpackedSignature(
        bytes32 digest,
        bytes memory signature,
        address signer
    ) internal view {

        bool result;
        address recoveredSigner = address(0x0);
        require(signer != address(0x0), 'validateSignature: ZERO_ADDRESS');


        bytes32 message;
        assembly {
            mstore(0, "\x19Ethereum Signed Message:\n32")
            mstore(28, digest)
            message := keccak256(0, 60)
        }
        assembly {
            let byteLength := mload(signature)

            mstore(signature, message)

            let v := mload(add(signature, 0x60))
            let s := mload(add(signature, 0x40))


            mstore(add(signature, 0x60), s)
            mstore(add(signature, 0x40), mload(add(signature, 0x20)))
            mstore(add(signature, 0x20), v)
            result := and(
                and(
                    lt(s, 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A1),
                    and(
                        eq(byteLength, 0x60),
                        or(eq(v, 27), eq(v, 28))
                    )
                ),
                staticcall(gas(), 0x01, signature, 0x80, signature, 0x20)
            )

            switch eq(message, mload(signature))
            case 0 {
                recoveredSigner := mload(signature)
            }
            mstore(signature, byteLength) // and put the byte length back where it belongs
        
            result := and(result, not(iszero(recoveredSigner)))
        }

        require(result, 'validateSignature: signature recovery failed');
        require(recoveredSigner == signer, 'validateSignature: INVALID_SIGNATURE');
    }
}// GPL-2.0-only
pragma solidity >=0.6.10 <0.8.0;



contract RollupProcessor is IRollupProcessor, Decoder, Ownable, Pausable {

    using SafeMath for uint256;

    bytes32 public dataRoot = 0x2708a627d38d74d478f645ec3b4e91afa325331acf1acebe9077891146b75e39;
    bytes32 public nullRoot = 0x2694dbe3c71a25d92213422d392479e7b8ef437add81e1e17244462e6edca9b1;
    bytes32 public rootRoot = 0x2d264e93dc455751a721aead9dba9ee2a9fef5460921aeede73f63f6210e6851;

    uint256 public dataSize;
    uint256 public nextRollupId;

    IVerifier public verifier;

    uint256 public constant numberOfAssets = 4;
    uint256 public constant txNumPubInputs = 12;
    uint256 public constant rollupNumPubInputs = 10 + numberOfAssets;
    uint256 public constant txPubInputLength = txNumPubInputs * 32; // public inputs length for of each inner proof tx
    uint256 public constant rollupPubInputLength = rollupNumPubInputs * 32;
    uint256 public constant ethAssetId = 0;
    uint256 public immutable escapeBlockLowerBound;
    uint256 public immutable escapeBlockUpperBound;

    event RollupProcessed(
        uint256 indexed rollupId,
        bytes32 dataRoot,
        bytes32 nullRoot,
        bytes32 rootRoot,
        uint256 dataSize
    );
    event Deposit(uint256 assetId, address depositorAddress, uint256 depositValue);
    event Withdraw(uint256 assetId, address withdrawAddress, uint256 withdrawValue);
    event WithdrawError(bytes errorReason);
    event AssetAdded(uint256 indexed assetId, address indexed assetAddress);
    event RollupProviderUpdated(address indexed providerAddress, bool valid);
    event VerifierUpdated(address indexed verifierAddress);

    address[] public supportedAssets;

    mapping(address => bool) assetPermitSupport;

    mapping(uint256 => mapping(address => uint256)) public userPendingDeposits;

    mapping(address => mapping(bytes32 => bool)) public depositProofApprovals;

    mapping(address => bool) public rollupProviders;

    address public override feeDistributor;

    uint256[] public totalPendingDeposit;
    uint256[] public totalDeposited;
    uint256[] public totalWithdrawn;
    uint256[] public totalFees;

    constructor(
        address _verifierAddress,
        uint256 _escapeBlockLowerBound,
        uint256 _escapeBlockUpperBound,
        address _contractOwner
    ) public {
        verifier = IVerifier(_verifierAddress);
        escapeBlockLowerBound = _escapeBlockLowerBound;
        escapeBlockUpperBound = _escapeBlockUpperBound;
        rollupProviders[msg.sender] = true;
        totalPendingDeposit.push(0);
        totalDeposited.push(0);
        totalWithdrawn.push(0);
        totalFees.push(0);
        transferOwnership(_contractOwner);
    }

    function setRollupProvider(address providerAddress, bool valid) public override onlyOwner {

        rollupProviders[providerAddress] = valid;
        emit RollupProviderUpdated(providerAddress, valid);
    }

    function setVerifier(address _verifierAddress) public override onlyOwner {

        verifier = IVerifier(_verifierAddress);
        emit VerifierUpdated(_verifierAddress);
    }

    function setFeeDistributor(address feeDistributorAddress) public override onlyOwner {

        feeDistributor = feeDistributorAddress;
    }


    function approveProof(bytes32 _proofHash) public override whenNotPaused {

        depositProofApprovals[msg.sender][_proofHash] = true;
    }

    function getSupportedAsset(uint256 assetId) public view override returns (address) {

        if (assetId == ethAssetId) {
            return address(0x0);
        }

        return supportedAssets[assetId - 1];
    }

    function getSupportedAssets() external view override returns (address[] memory) {

        return supportedAssets;
    }

    function getTotalDeposited() external view override returns (uint256[] memory) {

        return totalDeposited;
    }

    function getTotalWithdrawn() external view override returns (uint256[] memory) {

        return totalWithdrawn;
    }

    function getTotalPendingDeposit() external view override returns (uint256[] memory) {

        return totalPendingDeposit;
    }

    function getTotalFees() external view override returns (uint256[] memory) {

        return totalFees;
    }

    function getAssetPermitSupport(uint256 assetId) external view override returns (bool) {

        address assetAddress = getSupportedAsset(assetId);
        return assetPermitSupport[assetAddress];
    }

    function getEscapeHatchStatus() public view override returns (bool, uint256) {

        uint256 blockNum = block.number;

        bool isOpen = blockNum % escapeBlockUpperBound >= escapeBlockLowerBound;
        uint256 blocksRemaining = 0;
        if (isOpen) {
            blocksRemaining = escapeBlockUpperBound - (blockNum % escapeBlockUpperBound);
        } else {
            blocksRemaining = escapeBlockLowerBound - (blockNum % escapeBlockUpperBound);
        }
        return (isOpen, blocksRemaining);
    }

    function getUserPendingDeposit(uint256 assetId, address userAddress) external view override returns (uint256) {

        return userPendingDeposits[assetId][userAddress];
    }

    function increasePendingDepositBalance(
        uint256 assetId,
        address depositorAddress,
        uint256 amount
    ) internal {

        userPendingDeposits[assetId][depositorAddress] = userPendingDeposits[assetId][depositorAddress].add(amount);
        totalPendingDeposit[assetId] = totalPendingDeposit[assetId].add(amount);
    }

    function decreasePendingDepositBalance(
        uint256 assetId,
        address transferFromAddress,
        uint256 amount
    ) internal {

        uint256 userBalance = userPendingDeposits[assetId][transferFromAddress];
        require(userBalance >= amount, 'Rollup Processor: INSUFFICIENT_DEPOSIT');

        userPendingDeposits[assetId][transferFromAddress] = userBalance.sub(amount);
        totalPendingDeposit[assetId] = totalPendingDeposit[assetId].sub(amount);
        totalDeposited[assetId] = totalDeposited[assetId].add(amount);
    }

    function setSupportedAsset(address linkedToken, bool supportsPermit) external override onlyOwner {

        require(linkedToken != address(0x0), 'Rollup Processor: ZERO_ADDRESS');

        supportedAssets.push(linkedToken);
        assetPermitSupport[linkedToken] = supportsPermit;

        uint256 assetId = supportedAssets.length;
        require(assetId < numberOfAssets, 'Rollup Processor: MAX_ASSET_REACHED');

        totalPendingDeposit.push(0);
        totalDeposited.push(0);
        totalWithdrawn.push(0);
        totalFees.push(0);

        emit AssetAdded(assetId, linkedToken);
    }

    function setAssetPermitSupport(uint256 assetId, bool supportsPermit) external override onlyOwner {

        address assetAddress = getSupportedAsset(assetId);
        require(assetAddress != address(0x0), 'Rollup Processor: TOKEN_ASSET_NOT_LINKED');

        assetPermitSupport[assetAddress] = supportsPermit;
    }

    function depositPendingFunds(
        uint256 assetId,
        uint256 amount,
        address depositorAddress
    ) external payable override whenNotPaused {

        if (assetId == ethAssetId) {
            require(msg.value == amount, 'Rollup Processor: WRONG_AMOUNT');

            increasePendingDepositBalance(assetId, depositorAddress, amount);
        } else {
            require(msg.value == 0, 'Rollup Processor: WRONG_PAYMENT_TYPE');

            address assetAddress = getSupportedAsset(assetId);
            internalDeposit(assetId, assetAddress, depositorAddress, amount);
        }
    }

    function depositPendingFundsPermit(
        uint256 assetId,
        uint256 amount,
        address depositorAddress,
        address spender,
        uint256 permitApprovalAmount,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external override whenNotPaused {

        address assetAddress = getSupportedAsset(assetId);
        IERC20Permit(assetAddress).permit(depositorAddress, spender, permitApprovalAmount, deadline, v, r, s);
        internalDeposit(assetId, assetAddress, depositorAddress, amount);
    }

    function internalDeposit(
        uint256 assetId,
        address assetAddress,
        address depositorAddress,
        uint256 amount
    ) internal {

        uint256 rollupAllowance = IERC20(assetAddress).allowance(depositorAddress, address(this));
        require(rollupAllowance >= amount, 'Rollup Processor: INSUFFICIENT_TOKEN_APPROVAL');

        IERC20(assetAddress).transferFrom(depositorAddress, address(this), amount);
        increasePendingDepositBalance(assetId, depositorAddress, amount);

        emit Deposit(assetId, depositorAddress, amount);
    }

    function escapeHatch(
        bytes calldata proofData,
        bytes calldata signatures,
        bytes calldata viewingKeys
    ) external override whenNotPaused {

        (bool isOpen, ) = getEscapeHatchStatus();
        require(isOpen, 'Rollup Processor: ESCAPE_BLOCK_RANGE_INCORRECT');

        processRollupProof(proofData, signatures, viewingKeys);
    }

    function processRollup(
        bytes calldata proofData,
        bytes calldata signatures,
        bytes calldata viewingKeys,
        bytes calldata providerSignature,
        address provider,
        address payable feeReceiver,
        uint256 feeLimit
    ) external override whenNotPaused {

        uint256 initialGas = gasleft();

        require(rollupProviders[provider], 'Rollup Processor: UNKNOWN_PROVIDER');
        bytes memory sigData =
            abi.encodePacked(proofData[0:rollupPubInputLength], feeReceiver, feeLimit, feeDistributor);
        RollupProcessorLibrary.validateSignature(keccak256(sigData), providerSignature, provider);

        processRollupProof(proofData, signatures, viewingKeys);

        transferFee(proofData);

        (bool success, ) =
            feeDistributor.call(
                abi.encodeWithSignature(
                    'reimburseGas(uint256,uint256,address)',
                    initialGas - gasleft(),
                    feeLimit,
                    feeReceiver
                )
            );
        require(success, 'Rollup Processor: REIMBURSE_GAS_FAILED');
    }

    function processRollupProof(
        bytes memory proofData,
        bytes memory signatures,
        bytes calldata /*viewingKeys*/
    ) internal {

        uint256 numTxs = verifyProofAndUpdateState(proofData);
        processDepositsAndWithdrawals(proofData, numTxs, signatures);
    }

    function verifyProofAndUpdateState(bytes memory proofData) internal returns (uint256) {

        (
            bytes32 newDataRoot,
            bytes32 newNullRoot,
            uint256 rollupId,
            uint256 rollupSize,
            bytes32 newRootRoot,
            uint256 numTxs,
            uint256 newDataSize
        ) = validateMerkleRoots(proofData);

        bool proof_verified = false;
        address verifierAddress;
        uint256 temp1;
        uint256 temp2;
        uint256 temp3;
        assembly {
            let inputPtr := sub(proofData, 0x44)
            verifierAddress := sload(verifier_slot)

            temp1 := mload(inputPtr)
            temp2 := mload(add(inputPtr, 0x20))
            temp3 := mload(add(inputPtr, 0x40))

            mstore8(inputPtr, 0xac)
            mstore8(add(inputPtr, 0x01), 0x31)
            mstore8(add(inputPtr, 0x02), 0x8c)
            mstore8(add(inputPtr, 0x03), 0x5d)
            mstore(add(inputPtr, 0x04), 0x40)
            mstore(add(inputPtr, 0x24), rollupSize)

            let callSize := add(mload(proofData), 0x64)

            proof_verified := staticcall(gas(), verifierAddress, inputPtr, callSize, 0x00, 0x00)

            mstore(inputPtr, temp1)
            mstore(add(inputPtr, 0x20), temp2)
            mstore(add(inputPtr, 0x40), temp3)
        }

        require(proof_verified, 'proof verification failed');

        dataRoot = newDataRoot;
        nullRoot = newNullRoot;
        nextRollupId = rollupId.add(1);
        rootRoot = newRootRoot;
        dataSize = newDataSize;

        emit RollupProcessed(rollupId, dataRoot, nullRoot, rootRoot, dataSize);
        return numTxs;
    }

    function validateMerkleRoots(bytes memory proofData)
        internal
        view
        returns (
            bytes32,
            bytes32,
            uint256,
            uint256,
            bytes32,
            uint256,
            uint256
        )
    {

        (
            uint256[4] memory nums,
            bytes32 oldDataRoot,
            bytes32 newDataRoot,
            bytes32 oldNullRoot,
            bytes32 newNullRoot,
            bytes32 oldRootRoot,
            bytes32 newRootRoot
        ) = decodeProof(proofData, numberOfAssets);

        nums[3] = nums[1] == 0 ? 1 : nums[1];

        uint256 toInsert = nums[3].mul(2);
        if (dataSize % toInsert == 0) {
            require(nums[2] == dataSize, 'Rollup Processor: INCORRECT_DATA_START_INDEX');
        } else {
            uint256 expected = dataSize + toInsert - (dataSize % toInsert);
            require(nums[2] == expected, 'Rollup Processor: INCORRECT_DATA_START_INDEX');
        }

        require(oldDataRoot == dataRoot, 'Rollup Processor: INCORRECT_DATA_ROOT');
        require(oldNullRoot == nullRoot, 'Rollup Processor: INCORRECT_NULL_ROOT');
        require(oldRootRoot == rootRoot, 'Rollup Processor: INCORRECT_ROOT_ROOT');
        require(nums[0] == nextRollupId, 'Rollup Processor: ID_NOT_SEQUENTIAL');

        return (newDataRoot, newNullRoot, nums[0], nums[1], newRootRoot, nums[3], nums[2] + toInsert);
    }

    function processDepositsAndWithdrawals(
        bytes memory proofData,
        uint256 numTxs,
        bytes memory signatures
    ) internal {

        uint256 sigIndex = 0x00;
        uint256 proofDataPtr;
        assembly {
            proofDataPtr := add(proofData, 0x20) // add 0x20 to skip over 1st field in bytes array (the length field)
        }
        proofDataPtr += rollupPubInputLength; // update pointer to skip over rollup public inputs and point to inner tx public inputs
        uint256 end = proofDataPtr + (numTxs * txPubInputLength);
        uint256 stepSize = txPubInputLength;

        while (proofDataPtr < end) {
            uint256 proofId;
            uint256 publicInput;
            uint256 publicOutput;
            bool txNeedsProcessing;
            assembly {
                proofId := mload(proofDataPtr)
                publicInput := mload(add(proofDataPtr, 0x20))
                publicOutput := mload(add(proofDataPtr, 0x40))
                txNeedsProcessing := and(iszero(proofId), or(not(iszero(publicInput)), not(iszero(publicOutput))))
            }

            if (txNeedsProcessing) {
                uint256 assetId;
                assembly {
                    assetId := mload(add(proofDataPtr, 0x60))
                }

                if (publicInput > 0) {
                    address inputOwner;
                    bytes32 digest;
                    assembly {
                        inputOwner := mload(add(proofDataPtr, 0x140))

                        digest := keccak256(proofDataPtr, stepSize)
                    }
                    if (!depositProofApprovals[inputOwner][digest]) {
                        bytes memory signature;
                        uint256 temp;
                        assembly {
                            signature := add(signatures, sigIndex)
                            temp := mload(signature)
                            mstore(signature, 0x60)
                        }
                        RollupProcessorLibrary.validateUnpackedSignature(digest, signature, inputOwner);
                        assembly {
                            mstore(signature, temp)
                            sigIndex := add(sigIndex, 0x60)
                        }
                    }
                    decreasePendingDepositBalance(assetId, inputOwner, publicInput);
                }

                if (publicOutput > 0) {
                    address outputOwner;
                    assembly {
                        outputOwner := mload(add(proofDataPtr, 0x160))
                    }
                    withdraw(publicOutput, outputOwner, assetId);
                }
            }
            proofDataPtr += txPubInputLength;
        }
    }

    function transferFee(bytes memory proofData) internal {

        for (uint256 i = 0; i < numberOfAssets; ++i) {
            uint256 txFee = extractTotalTxFee(proofData, i);
            if (txFee > 0) {
                bool success;
                if (i == ethAssetId) {
                    (success, ) = payable(feeDistributor).call{value: txFee}('');
                } else {
                    address assetAddress = getSupportedAsset(i);
                    IERC20(assetAddress).approve(feeDistributor, txFee);
                    (success, ) = feeDistributor.call(abi.encodeWithSignature('deposit(uint256,uint256)', i, txFee));
                }
                require(success, 'Rollup Processor: DEPOSIT_TX_FEE_FAILED');
                totalFees[i] = totalFees[i].add(txFee);
            }
        }
    }

    function withdraw(
        uint256 withdrawValue,
        address receiverAddress,
        uint256 assetId
    ) internal {

        require(receiverAddress != address(0), 'Rollup Processor: ZERO_ADDRESS');
        if (assetId == 0) {
            payable(receiverAddress).call{gas: 30000, value: withdrawValue}('');
        } else {
            address assetAddress = getSupportedAsset(assetId);
            IERC20(assetAddress).transfer(receiverAddress, withdrawValue);
        }
        totalWithdrawn[assetId] = totalWithdrawn[assetId].add(withdrawValue);
    }
}