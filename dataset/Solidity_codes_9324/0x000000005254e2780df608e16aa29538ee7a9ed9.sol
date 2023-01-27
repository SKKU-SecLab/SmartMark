
pragma solidity >=0.8.0;



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


pragma solidity >=0.8.0;


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



pragma solidity ^0.8.0;

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


pragma solidity >=0.8.0;

interface ICNV {

    function mint(address to, uint256 amount) external returns (uint256);


    function totalSupply() external view returns (uint256);

}


contract pCNV is ERC20("Concave Presale Token", "pCNV", 18) {



    using SafeTransferLib for ERC20;


    uint256 public immutable GENESIS = block.timestamp;

    uint256 public immutable TWO_YEARS = 63072000;

    ERC20 public immutable FRAX = ERC20(0x853d955aCEf822Db058eb8505911ED77F175b99e);

    ERC20 public immutable DAI = ERC20(0x6B175474E89094C44Da98b954EedeAC495271d0F);

    string constant AMOUNT_ERROR = "!AMOUNT";

    string constant TOKEN_IN_ERROR = "!TOKEN_IN";


    ICNV public CNV;

    address public treasury = 0x226e7AF139a0F34c6771DeB252F9988876ac1Ced;

    bytes32 public merkleRoot;

    bytes32[] public roots;

    uint256 public rate;

    uint256 public maxSupply = 33000000000000000000000000;

    uint256 public totalMinted;

    bool public redeemable;

    bool public transfersPaused;


    struct Participant {
        uint256 purchased; // amount (in total) of pCNV that user has purchased
        uint256 redeemed;  // amount (in total) of pCNV that user has redeemed
    }

    mapping(address => Participant) public participants;

    mapping(bytes32 => mapping(address => uint256)) public spentAmounts;


    event TreasurySet(address treasury);

    event RedeemableSet(address CNV);

    event NewRound(bytes32 merkleRoot, uint256 rate);

    event Managed(address target, uint256 amount, uint256 maxSupply);

    event Minted(
        address indexed depositedFrom,
        address indexed mintedTo,
        uint256 amount,
        uint256 deposited,
        uint256 totalMinted
    );

    event Redeemed(
        address indexed burnedFrom,
        address indexed mintedTo,
        uint256 burned,
        uint256 minted
    );


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

    function setRedeemable(
        address _CNV
    ) external onlyConcave {

        redeemable = true;
        CNV = ICNV(_CNV);

        emit RedeemableSet(_CNV);
    }

    function setRound(
        bytes32 _merkleRoot,
        uint256 _rate
    ) external onlyConcave {

        require(_rate > 0, "!RATE");
        roots.push(_merkleRoot);
        merkleRoot = _merkleRoot;
        rate = _rate;

        emit NewRound(merkleRoot,rate);
    }

    function manage(
        address target,
        uint256 amount
    ) external onlyConcave {

        uint256 newAmount;
        if (target == address(0)) {
            require(amount <= maxSupply, AMOUNT_ERROR);
            newAmount = maxSupply - amount;
            require(newAmount >= totalMinted, AMOUNT_ERROR);
            maxSupply = newAmount;

            emit Managed(target, amount, maxSupply);
            return;
        }
        newAmount = totalMinted + amount;
        require(newAmount <= maxSupply, AMOUNT_ERROR);
        totalMinted = newAmount;
        _mint(target, amount);

        emit Managed(target, amount, maxSupply);
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

        _beforeTransfer(msg.sender, to, amount);
        return super.transfer(to, amount);
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {

        _beforeTransfer(from, to, amount);
        return super.transferFrom(from, to, amount);
    }

    function redeem(
        address to,
        uint256 amountIn
    ) external {

        require(redeemable, "!REDEEMABLE");

        Participant storage participant = participants[msg.sender];

        uint256 amountOut = redeemAmountOut(msg.sender, amountIn);

        participant.redeemed += amountIn;

        _burn(msg.sender, amountIn);

        CNV.mint(to, amountOut);

        emit Redeemed(msg.sender, to, amountIn, amountOut);
    }


    function redeemAmountOut(address who, uint256 amountIn) public view returns (uint256) {

        require(amountIn <= maxRedeemAmountIn(who), AMOUNT_ERROR);

        uint256 ratio = 1e18 * amountIn / maxRedeemAmountIn(who);

        return maxRedeemAmountOut(who) * ratio / 1e18;
    }

    function maxRedeemAmountIn(
        address who
    ) public view returns (uint256) {

        if (!redeemable) return 0;
        if (CNV.totalSupply() == 0) return 0;
        Participant memory participant = participants[who];
        return participant.purchased * purchaseVested() / 1e18 - participant.redeemed;
    }

    function maxRedeemAmountOut(
        address who
    ) public view returns (uint256) {

        return amountVested() * percentToRedeem(who) / 1e18;
    }

    function percentToRedeem(
        address who
    ) public view returns (uint256) {

        return 1e18 * maxRedeemAmountIn(who) / maxSupply;
    }

    function elapsed() public view returns (uint256) {

        return block.timestamp - GENESIS;
    }

    function supplyVested() public view returns (uint256) {

        return elapsed() > TWO_YEARS ? 1e17 : 1e17 * elapsed() / TWO_YEARS;
    }

    function purchaseVested() public view returns (uint256) {

        return elapsed() > TWO_YEARS ? 1e18 : 1e18 * elapsed() / TWO_YEARS;
    }

    function amountVested() public view returns (uint256) {

        return CNV.totalSupply() * supplyVested() / 1e18;
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

        require(totalMinted + amountOut <= maxSupply, AMOUNT_ERROR);

        Participant storage participant = participants[to];

        participant.purchased += amountOut;

        totalMinted += amountOut;

        ERC20(tokenIn).safeTransferFrom(sender, treasury, amountIn);

        _mint(to, amountOut);

        emit Minted(sender, to, amountOut, amountIn, totalMinted);
    }

    function _beforeTransfer(
        address from,
        address to,
        uint256 amount
    ) internal {

        require(!transfersPaused, "PAUSED");

        Participant storage toParticipant = participants[to];

        Participant storage fromParticipant = participants[from];

        uint256 adjustedAmount = amount * fromParticipant.redeemed / fromParticipant.purchased;

        fromParticipant.redeemed -= adjustedAmount;

        fromParticipant.purchased -= amount;

        toParticipant.redeemed += adjustedAmount;

        toParticipant.purchased += amount;
    }

    function rescue(address token) external onlyConcave {

        if (token == address(0)) payable(treasury).transfer( address(this).balance );
        else ERC20(token).transfer(treasury, ERC20(token).balanceOf(address(this)));
    }
}

