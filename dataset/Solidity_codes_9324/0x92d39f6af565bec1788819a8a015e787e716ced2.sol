pragma solidity ^0.5.2;

contract IFactRegistry {

    function isValid(bytes32 fact)
        external view
        returns(bool);

}
pragma solidity ^0.5.2;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount)
        external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}
pragma solidity ^0.5.2;

contract PublicInputOffsets {

    uint256 internal constant OFFSET_LOG_TRACE_LENGTH = 0;
    uint256 internal constant OFFSET_VDF_OUTPUT_X = 1;
    uint256 internal constant OFFSET_VDF_OUTPUT_Y = 2;
    uint256 internal constant OFFSET_VDF_INPUT_X = 3;
    uint256 internal constant OFFSET_VDF_INPUT_Y = 4;
    uint256 internal constant OFFSET_N_ITER = 0;
}
pragma solidity ^0.5.2;

contract VendingMachineERC20 is PublicInputOffsets {



    event LogNewPayment(uint256 seed, uint256 n_iter, uint256 paymentAmount);
    event LogPaymentReclaimed(
        address sender,
        uint256 seed,
        uint256 n_iter,
        uint256 tag,
        uint256 reclaimedAmount
    );
    event LogNewRandomness(uint256 seed, uint256 n_iter, bytes32 randomness);

    struct Payment {
        uint256 timeSent;
        uint256 amount;
    }

    mapping(uint256 => mapping(uint256 => uint256)) public prizes;
    mapping(address => mapping(uint256 => mapping(uint256 => mapping(uint256 => Payment))))
        public payments;
    mapping(uint256 => mapping(uint256 => bytes32)) public registeredRandomness;
    mapping(address => bool) owners;

    IFactRegistry public verifierContract;
    address public tokenAddress;
    uint256 internal constant PRIME = 0x30000003000000010000000000000001;
    uint256 internal constant PUBLIC_INPUT_SIZE = 5;
    uint256 internal constant RECLAIM_DELAY = 1 days;

    modifier onlyOwner {

        require(owners[msg.sender], "ONLY_OWNER");
        _;
    }

    modifier randomnessNotRegistered(uint256 seed, uint256 n_iter) {

        require(
            registeredRandomness[seed][n_iter] == 0,
            "REGSITERED_RANDOMNESS"
        );
        _;
    }

    constructor(address verifierAddress, address token) public {
        owners[msg.sender] = true;
        verifierContract = IFactRegistry(verifierAddress);
        tokenAddress = token;
    }

    function addOwner(address newOwner) external onlyOwner {

        owners[newOwner] = true;
    }

    function removeOwner(address removedOwner) external onlyOwner {

        require(msg.sender != removedOwner, "CANT_REMOVE_SELF");
        owners[removedOwner] = false;
    }

    function addPayment(
        uint256 seed,
        uint256 n_iter,
        uint256 tag,
        uint256 paymentAmount
    ) external randomnessNotRegistered(seed, n_iter) {

        transferIn(paymentAmount);

        payments[msg.sender][seed][n_iter][tag].amount += paymentAmount;
        payments[msg.sender][seed][n_iter][tag].timeSent = now;
        prizes[seed][n_iter] += paymentAmount;

        emit LogNewPayment(seed, n_iter, paymentAmount);
    }

    function reclaimPayment(
        uint256 seed,
        uint256 n_iter,
        uint256 tag
    ) external randomnessNotRegistered(seed, n_iter) {

        Payment memory userPayment = payments[msg.sender][seed][n_iter][tag];

        require(userPayment.amount > 0, "NO_PAYMENT");

        uint256 lastPaymentTime = userPayment.timeSent;
        uint256 releaseTime = lastPaymentTime + RECLAIM_DELAY;
        assert(releaseTime >= RECLAIM_DELAY);
        require(now >= releaseTime, "PAYMENT_LOCKED");

        prizes[seed][n_iter] -= userPayment.amount;
        payments[msg.sender][seed][n_iter][tag].amount = 0;

        transferOut(userPayment.amount);

        emit LogPaymentReclaimed(
            msg.sender,
            seed,
            n_iter,
            tag,
            userPayment.amount
        );
    }

    function registerAndCollect(
        uint256 seed,
        uint256 n_iter,
        uint256 vdfOutputX,
        uint256 vdfOutputY
    ) external onlyOwner randomnessNotRegistered(seed, n_iter) {

        registerNewRandomness(seed, n_iter, vdfOutputX, vdfOutputY);
        transferOut(prizes[seed][n_iter]);
    }

    function registerNewRandomness(
        uint256 seed,
        uint256 n_iter,
        uint256 vdfOutputX,
        uint256 vdfOutputY
    ) internal {

        require(vdfOutputX < PRIME && vdfOutputY < PRIME, "INVALID_VDF_OUTPUT");

        (uint256 vdfInputX, uint256 vdfInputY) = seed2vdfInput(seed);

        uint256[PUBLIC_INPUT_SIZE] memory proofPublicInput;
        proofPublicInput[OFFSET_N_ITER] = n_iter;
        proofPublicInput[OFFSET_VDF_INPUT_X] = vdfInputX;
        proofPublicInput[OFFSET_VDF_INPUT_Y] = vdfInputY;
        proofPublicInput[OFFSET_VDF_OUTPUT_X] = vdfOutputX;
        proofPublicInput[OFFSET_VDF_OUTPUT_Y] = vdfOutputY;

        require(
            verifierContract.isValid(
                keccak256(abi.encodePacked(proofPublicInput))
            ),
            "FACT_NOT_REGISTERED"
        );

        bytes32 randomness = keccak256(
            abi.encodePacked(
                proofPublicInput[OFFSET_VDF_OUTPUT_X],
                proofPublicInput[OFFSET_VDF_OUTPUT_Y],
                "veedo"
            )
        );
        registeredRandomness[seed][n_iter] = randomness;

        emit LogNewRandomness(seed, n_iter, randomness);
    }

    function transferOut(uint256 amount) internal {

        safeERC20Call(
            address(tokenAddress),
            abi.encodeWithSelector(
                IERC20(0).transfer.selector,
                msg.sender,
                amount
            )
        );
    }

    function transferIn(uint256 amount) internal {

        safeERC20Call(
            address(tokenAddress),
            abi.encodeWithSelector(
                IERC20(0).transferFrom.selector,
                msg.sender,
                address(this),
                amount
            )
        );
    }

    function safeERC20Call(address tokenAddress, bytes memory callData)
        internal
    {

        (bool success, bytes memory returndata) = address(tokenAddress).call(
            callData
        );
        require(success, string(returndata));

        if (returndata.length > 0) {
            require(abi.decode(returndata, (bool)), "ERC20_OPERATION_FAILED");
        }
    }

    function seed2vdfInput(uint256 seed)
        public
        pure
        returns (uint256, uint256)
    {

        uint256 vdfInput = uint256(keccak256(abi.encodePacked(seed, "veedo")));
        uint256 vdfInputX = vdfInput & ((1 << 125) - 1);
        uint256 vdfInputY = ((vdfInput >> 125) & ((1 << 125) - 1));
        return (vdfInputX, vdfInputY);
    }
}
