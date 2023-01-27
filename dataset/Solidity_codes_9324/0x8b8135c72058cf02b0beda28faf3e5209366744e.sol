
pragma solidity >=0.8.0;





abstract contract ERC20 {

    event Transfer(address indexed from, address indexed to, uint256 amount);

    event Approval(address indexed owner, address indexed spender, uint256 amount);


    string public name;

    string public symbol;

    uint8 public immutable decimals;


    uint256 public totalSupply;

    mapping(address => uint256) public balanceOf;

    mapping(address => mapping(address => uint256)) public allowance;


    bytes32 public constant PERMIT_TYPEHASH =
        keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)");

    uint256 internal immutable INITIAL_CHAIN_ID;

    bytes32 internal immutable INITIAL_DOMAIN_SEPARATOR;

    mapping(address => uint256) public nonces;


    constructor(
        string memory _name,
        string memory _symbol,
        uint8 _decimals
    ) {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;

        INITIAL_CHAIN_ID = block.chainid;
        INITIAL_DOMAIN_SEPARATOR = computeDomainSeparator();
    }


    function approve(address spender, uint256 amount) public virtual returns (bool) {
        allowance[msg.sender][spender] = amount;

        emit Approval(msg.sender, spender, amount);

        return true;
    }

    function transfer(address to, uint256 amount) public virtual returns (bool) {
        balanceOf[msg.sender] -= amount;

        unchecked {
            balanceOf[to] += amount;
        }

        emit Transfer(msg.sender, to, amount);

        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual returns (bool) {
        uint256 allowed = allowance[from][msg.sender]; // Saves gas for limited approvals.

        if (allowed != type(uint256).max) allowance[from][msg.sender] = allowed - amount;

        balanceOf[from] -= amount;

        unchecked {
            balanceOf[to] += amount;
        }

        emit Transfer(from, to, amount);

        return true;
    }


    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public virtual {
        require(deadline >= block.timestamp, "PERMIT_DEADLINE_EXPIRED");

        unchecked {
            bytes32 digest = keccak256(
                abi.encodePacked(
                    "\x19\x01",
                    DOMAIN_SEPARATOR(),
                    keccak256(abi.encode(PERMIT_TYPEHASH, owner, spender, value, nonces[owner]++, deadline))
                )
            );

            address recoveredAddress = ecrecover(digest, v, r, s);

            require(recoveredAddress != address(0) && recoveredAddress == owner, "INVALID_SIGNER");

            allowance[recoveredAddress][spender] = value;
        }

        emit Approval(owner, spender, value);
    }

    function DOMAIN_SEPARATOR() public view virtual returns (bytes32) {
        return block.chainid == INITIAL_CHAIN_ID ? INITIAL_DOMAIN_SEPARATOR : computeDomainSeparator();
    }

    function computeDomainSeparator() internal view virtual returns (bytes32) {
        return
            keccak256(
                abi.encode(
                    keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"),
                    keccak256(bytes(name)),
                    keccak256("1"),
                    block.chainid,
                    address(this)
                )
            );
    }


    function _mint(address to, uint256 amount) internal virtual {
        totalSupply += amount;

        unchecked {
            balanceOf[to] += amount;
        }

        emit Transfer(address(0), to, amount);
    }

    function _burn(address from, uint256 amount) internal virtual {
        balanceOf[from] -= amount;

        unchecked {
            totalSupply -= amount;
        }

        emit Transfer(from, address(0), amount);
    }
}
library SafeTransferLib {


    function safeTransferETH(address to, uint256 amount) internal {

        bool callStatus;

        assembly {
            callStatus := call(gas(), to, amount, 0, 0, 0, 0)
        }

        require(callStatus, "ETH_TRANSFER_FAILED");
    }


    function safeTransferFrom(
        ERC20 token,
        address from,
        address to,
        uint256 amount
    ) internal {

        bool callStatus;

        assembly {
            let freeMemoryPointer := mload(0x40)

            mstore(freeMemoryPointer, 0x23b872dd00000000000000000000000000000000000000000000000000000000) // Begin with the function selector.
            mstore(add(freeMemoryPointer, 4), and(from, 0xffffffffffffffffffffffffffffffffffffffff)) // Mask and append the "from" argument.
            mstore(add(freeMemoryPointer, 36), and(to, 0xffffffffffffffffffffffffffffffffffffffff)) // Mask and append the "to" argument.
            mstore(add(freeMemoryPointer, 68), amount) // Finally append the "amount" argument. No mask as it's a full 32 byte value.

            callStatus := call(gas(), token, 0, freeMemoryPointer, 100, 0, 0)
        }

        require(didLastOptionalReturnCallSucceed(callStatus), "TRANSFER_FROM_FAILED");
    }

    function safeTransfer(
        ERC20 token,
        address to,
        uint256 amount
    ) internal {

        bool callStatus;

        assembly {
            let freeMemoryPointer := mload(0x40)

            mstore(freeMemoryPointer, 0xa9059cbb00000000000000000000000000000000000000000000000000000000) // Begin with the function selector.
            mstore(add(freeMemoryPointer, 4), and(to, 0xffffffffffffffffffffffffffffffffffffffff)) // Mask and append the "to" argument.
            mstore(add(freeMemoryPointer, 36), amount) // Finally append the "amount" argument. No mask as it's a full 32 byte value.

            callStatus := call(gas(), token, 0, freeMemoryPointer, 68, 0, 0)
        }

        require(didLastOptionalReturnCallSucceed(callStatus), "TRANSFER_FAILED");
    }

    function safeApprove(
        ERC20 token,
        address to,
        uint256 amount
    ) internal {

        bool callStatus;

        assembly {
            let freeMemoryPointer := mload(0x40)

            mstore(freeMemoryPointer, 0x095ea7b300000000000000000000000000000000000000000000000000000000) // Begin with the function selector.
            mstore(add(freeMemoryPointer, 4), and(to, 0xffffffffffffffffffffffffffffffffffffffff)) // Mask and append the "to" argument.
            mstore(add(freeMemoryPointer, 36), amount) // Finally append the "amount" argument. No mask as it's a full 32 byte value.

            callStatus := call(gas(), token, 0, freeMemoryPointer, 68, 0, 0)
        }

        require(didLastOptionalReturnCallSucceed(callStatus), "APPROVE_FAILED");
    }


    function didLastOptionalReturnCallSucceed(bool callStatus) private pure returns (bool success) {

        assembly {
            let returnDataSize := returndatasize()

            if iszero(callStatus) {
                returndatacopy(0, 0, returnDataSize)

                revert(0, returnDataSize)
            }

            switch returnDataSize
            case 32 {
                returndatacopy(0, 0, returnDataSize)

                success := iszero(iszero(mload(0)))
            }
            case 0 {
                success := 1
            }
            default {
                success := 0
            }
        }
    }
}
library MerkleProof {

    function verify(
        bytes32[] memory proof,
        bytes32 root,
        bytes32 leaf
    ) internal pure returns (bool) {

        return processProof(proof, leaf) == root;
    }

    function processProof(bytes32[] memory proof, bytes32 leaf) internal pure returns (bytes32) {

        bytes32 computedHash = leaf;
        for (uint256 i = 0; i < proof.length; i++) {
            bytes32 proofElement = proof[i];
            if (computedHash <= proofElement) {
                computedHash = _efficientHash(computedHash, proofElement);
            } else {
                computedHash = _efficientHash(proofElement, computedHash);
            }
        }
        return computedHash;
    }

    function _efficientHash(bytes32 a, bytes32 b) private pure returns (bytes32 value) {

        assembly {
            mstore(0x00, a)
            mstore(0x20, b)
            value := keccak256(0x00, 0x40)
        }
    }
}
contract aCNV is ERC20("Concave A Token (aCNV)", "aCNV", 18) {



    using SafeTransferLib for ERC20;


    ERC20 public immutable FRAX = ERC20(0x853d955aCEf822Db058eb8505911ED77F175b99e);

    ERC20 public immutable DAI = ERC20(0x6B175474E89094C44Da98b954EedeAC495271d0F);

    string constant AMOUNT_ERROR = "!AMOUNT";

    string constant TOKEN_IN_ERROR = "!TOKEN_IN";

    string constant EXCEEDS_SUPPLY = "EXCEEDS_SUPPLY";

    string constant PAUSED = "PAUSED";


    address public treasury = 0x226e7AF139a0F34c6771DeB252F9988876ac1Ced;

    bytes32 public merkleRoot;

    bytes32[] public roots;

    uint256 public rate;

    uint256 public maxSupply = 333_000 * 1e18;

    uint256 public totalMinted;

    bool public transfersPaused = true;


    struct Participant {
        uint256 purchased; // amount (in total) of pCNV that user has purchased
        uint256 redeemed;  // amount (in total) of pCNV that user has redeemed
    }

    mapping(address => Participant) public participants;

    mapping(bytes32 => mapping(address => uint256)) public spentAmounts;


    event TreasurySet(address treasury);

    event NewRound(bytes32 merkleRoot, uint256 rate);

    event Managed(address target, uint256 amount, uint256 totalMinted);

    event Minted(
        address indexed depositedFrom,
        address indexed mintedTo,
        uint256 amount,
        uint256 deposited,
        uint256 totalMinted
    );

    event SupplyChanged(uint256 oldMax, uint256 newMax);


    modifier onlyConcave() {

        require(msg.sender == treasury, "!CONCAVE");
        _;
    }


    function setTreasury(
        address _treasury
    ) external onlyConcave {

        treasury = _treasury;
        emit TreasurySet(_treasury);
    }

    function setRound(
        bytes32 _merkleRoot,
        uint256 _rate
    ) external onlyConcave {

        roots.push(_merkleRoot);
        merkleRoot = _merkleRoot;
        rate = _rate;

        emit NewRound(merkleRoot,rate);
    }

    function manage(
        address target,
        uint256 amount
    ) external onlyConcave {

        uint256 newAmount = totalMinted + amount;
        require(newAmount <= maxSupply,EXCEEDS_SUPPLY);
        totalMinted = newAmount;
        _mint(target, amount);
        emit Managed(target, amount, totalMinted);
    }

    function manageSupply(uint256 _maxSupply) external onlyConcave {

        require(_maxSupply >= totalMinted, "LOWER_THAN_MINT");
        emit SupplyChanged(maxSupply, _maxSupply);
        maxSupply = _maxSupply;
    }

    function setTransfersPaused(bool paused) external onlyConcave {

        transfersPaused = paused;
    }


    function mint(
        address to,
        address tokenIn,
        uint256 maxAmount,
        uint256 amountIn,
        bytes32[] calldata proof
    ) external returns (uint256 amountOut) {

        return _purchase(msg.sender, to, tokenIn, maxAmount, amountIn, proof);
    }

    function mintWithPermit(
        address to,
        address tokenIn,
        uint256 maxAmount,
        uint256 amountIn,
        bytes32[] calldata proof,
        uint256 permitDeadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountOut) {

        require(tokenIn == address(DAI), TOKEN_IN_ERROR);
        ERC20(tokenIn).permit(msg.sender, address(this), amountIn, permitDeadline, v, r, s);
        return _purchase(msg.sender, to, tokenIn, maxAmount, amountIn, proof);
    }

    function transfer(
        address to,
        uint256 amount
    ) public virtual override returns (bool) {

        require(!transfersPaused,PAUSED);
        return super.transfer(to, amount);
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {

        require(!transfersPaused,PAUSED);
        return super.transferFrom(from, to, amount);
    }


    function _purchase(
        address sender,
        address to,
        address tokenIn,
        uint256 maxAmount,
        uint256 amountIn,
        bytes32[] calldata proof
    ) internal returns(uint256 amountOut) {

        require(tokenIn == address(DAI) || tokenIn == address(FRAX), TOKEN_IN_ERROR);

        require(MerkleProof.verify(proof, merkleRoot, keccak256(abi.encodePacked(to, maxAmount))), "!PROOF");

        uint256 newAmount = spentAmounts[merkleRoot][to] + amountIn; // save gas
        require(newAmount <= maxAmount, AMOUNT_ERROR);
        spentAmounts[merkleRoot][to] = newAmount;

        amountOut = amountIn * 1e18 / rate;

        require(totalMinted + amountOut <= maxSupply, EXCEEDS_SUPPLY);

        Participant storage participant = participants[to];

        participant.purchased += amountOut;

        totalMinted += amountOut;

        ERC20(tokenIn).safeTransferFrom(sender, treasury, amountIn);

        _mint(to, amountOut);

        emit Minted(sender, to, amountOut, amountIn, totalMinted);
    }

    function rescue(address token) external onlyConcave {

        if (token == address(0)) payable(treasury).transfer( address(this).balance );
        else ERC20(token).transfer(treasury, ERC20(token).balanceOf(address(this)));
    }
}

