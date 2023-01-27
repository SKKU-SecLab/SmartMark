pragma solidity >=0.8.10;




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
} // OZ: MerkleProof

abstract contract DAOToken {

    event Transfer(address indexed from, address indexed to, uint256 amount);

    event Approval(address indexed owner, address indexed spender, uint256 amount);

    event DelegateChanged(address indexed delegator, address indexed fromDelegate, address indexed toDelegate);

    event DelegateVotesChanged(address indexed delegate, uint256 previousBalance, uint256 newBalance);




    error NoArrayParity();

    error SignatureExpired();

    error NullAddress();

    error InvalidNonce();

    error NotDetermined();

    error InvalidSignature();

    error Uint32max();

    error Uint96max();


    string public name;

    string public symbol;

    uint8 public constant decimals = 18;


    uint256 public totalSupply;

    mapping(address => uint256) public balanceOf;

    mapping(address => mapping(address => uint256)) public allowance;


    bytes32 public constant PERMIT_TYPEHASH =
    keccak256('Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)');

    uint256 internal INITIAL_CHAIN_ID;

    bytes32 internal INITIAL_DOMAIN_SEPARATOR;

    mapping(address => uint256) public nonces;



    bytes32 public constant DELEGATION_TYPEHASH =
    keccak256('Delegation(address delegatee,uint256 nonce,uint256 deadline)');

    mapping(address => address) internal _delegates;

    mapping(address => mapping(uint256 => Checkpoint)) public checkpoints;

    mapping(address => uint256) public numCheckpoints;

    struct Checkpoint {
        uint32 fromTimestamp;
        uint96 votes;
    }


    function _init(
        string memory name_,
        string memory symbol_
    ) internal virtual {
        name = name_;

        symbol = symbol_;

        INITIAL_CHAIN_ID = block.chainid;

        INITIAL_DOMAIN_SEPARATOR = _computeDomainSeparator();
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

        _moveDelegates(delegates(msg.sender), delegates(to), amount);

        emit Transfer(msg.sender, to, amount);

        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual returns (bool) {
        if (allowance[from][msg.sender] != type(uint256).max)
            allowance[from][msg.sender] -= amount;

        balanceOf[from] -= amount;

        unchecked {
            balanceOf[to] += amount;
        }

        _moveDelegates(delegates(from), delegates(to), amount);

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
        if (block.timestamp > deadline) revert SignatureExpired();

        unchecked {
            bytes32 digest = keccak256(
                abi.encodePacked(
                    '\x19\x01',
                    DOMAIN_SEPARATOR(),
                    keccak256(abi.encode(PERMIT_TYPEHASH, owner, spender, value, nonces[owner]++, deadline))
                )
            );

            address recoveredAddress = ecrecover(digest, v, r, s);

            if (recoveredAddress == address(0) || recoveredAddress != owner) revert InvalidSignature();

            allowance[recoveredAddress][spender] = value;
        }

        emit Approval(owner, spender, value);
    }

    function DOMAIN_SEPARATOR() public view virtual returns (bytes32) {
        return block.chainid == INITIAL_CHAIN_ID ? INITIAL_DOMAIN_SEPARATOR : _computeDomainSeparator();
    }

    function _computeDomainSeparator() internal view virtual returns (bytes32) {
        return
        keccak256(
            abi.encode(
                keccak256('EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)'),
                keccak256(bytes(name)),
                keccak256('1'),
                block.chainid,
                address(this)
            )
        );
    }


    function delegates(address delegator) public view virtual returns (address) {
        address current = _delegates[delegator];

        return current == address(0) ? delegator : current;
    }

    function getCurrentVotes(address account) public view virtual returns (uint256) {
        unchecked {
            uint256 nCheckpoints = numCheckpoints[account];

            return nCheckpoints != 0 ? checkpoints[account][nCheckpoints - 1].votes : 0;
        }
    }

    function delegate(address delegatee) public virtual {
        _delegate(msg.sender, delegatee);
    }

    function delegateBySig(
        address delegatee,
        uint256 nonce,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public virtual {
        if (block.timestamp > deadline) revert SignatureExpired();

        bytes32 structHash = keccak256(abi.encode(DELEGATION_TYPEHASH, delegatee, nonce, deadline));

        bytes32 digest = keccak256(abi.encodePacked('\x19\x01', DOMAIN_SEPARATOR(), structHash));

        address signatory = ecrecover(digest, v, r, s);

        if (signatory == address(0)) revert NullAddress();

        unchecked {
            if (nonce != nonces[signatory]++) revert InvalidNonce();
        }

        _delegate(signatory, delegatee);
    }

    function getPriorVotes(address account, uint256 timestamp) public view virtual returns (uint96) {
        if (block.timestamp <= timestamp) revert NotDetermined();

        uint256 nCheckpoints = numCheckpoints[account];

        if (nCheckpoints == 0) return 0;

        unchecked {
            if (checkpoints[account][nCheckpoints - 1].fromTimestamp <= timestamp)
                return checkpoints[account][nCheckpoints - 1].votes;

            if (checkpoints[account][0].fromTimestamp > timestamp) return 0;

            uint256 lower;

            uint256 upper = nCheckpoints - 1;

            while (upper > lower) {
                uint256 center = upper - (upper - lower) / 2;

                Checkpoint memory cp = checkpoints[account][center];

                if (cp.fromTimestamp == timestamp) {
                    return cp.votes;
                } else if (cp.fromTimestamp < timestamp) {
                    lower = center;
                } else {
                    upper = center - 1;
                }
            }

            return checkpoints[account][lower].votes;

        }
    }

    function _delegate(address delegator, address delegatee) internal virtual {
        address currentDelegate = delegates(delegator);

        _delegates[delegator] = delegatee;

        _moveDelegates(currentDelegate, delegatee, balanceOf[delegator]);

        emit DelegateChanged(delegator, currentDelegate, delegatee);
    }

    function _moveDelegates(
        address srcRep,
        address dstRep,
        uint256 amount
    ) internal virtual {
        if (srcRep != dstRep && amount != 0)
            if (srcRep != address(0)) {
                uint256 srcRepNum = numCheckpoints[srcRep];

                uint256 srcRepOld = srcRepNum != 0 ? checkpoints[srcRep][srcRepNum - 1].votes : 0;

                uint256 srcRepNew = srcRepOld - amount;

                _writeCheckpoint(srcRep, srcRepNum, srcRepOld, srcRepNew);
            }

        if (dstRep != address(0)) {
            uint256 dstRepNum = numCheckpoints[dstRep];

            uint256 dstRepOld = dstRepNum != 0 ? checkpoints[dstRep][dstRepNum - 1].votes : 0;

            uint256 dstRepNew = dstRepOld + amount;

            _writeCheckpoint(dstRep, dstRepNum, dstRepOld, dstRepNew);
        }
    }

    function _writeCheckpoint(
        address delegatee,
        uint256 nCheckpoints,
        uint256 oldVotes,
        uint256 newVotes
    ) internal virtual {
        unchecked {
            if (nCheckpoints != 0 && checkpoints[delegatee][nCheckpoints - 1].fromTimestamp == block.timestamp) {
                checkpoints[delegatee][nCheckpoints - 1].votes = _safeCastTo96(newVotes);
            } else {
                checkpoints[delegatee][nCheckpoints] = Checkpoint(_safeCastTo32(block.timestamp), _safeCastTo96(newVotes));

                numCheckpoints[delegatee] = nCheckpoints + 1;
            }
        }

        emit DelegateVotesChanged(delegatee, oldVotes, newVotes);
    }


    function _mint(address to, uint256 amount) internal virtual {
        totalSupply += amount;

        unchecked {
            balanceOf[to] += amount;
        }

        _moveDelegates(address(0), delegates(to), amount);

        emit Transfer(address(0), to, amount);
    }

    function _burn(address from, uint256 amount) internal virtual {
        balanceOf[from] -= amount;

        unchecked {
            totalSupply -= amount;
        }

        _moveDelegates(delegates(from), address(0), amount);

        emit Transfer(from, address(0), amount);
    }

    function burn(uint256 amount) public virtual {
        _burn(msg.sender, amount);
    }


    function _safeCastTo32(uint256 x) internal pure virtual returns (uint32) {
        if (x > type(uint32).max) revert Uint32max();

        return uint32(x);
    }

    function _safeCastTo96(uint256 x) internal pure virtual returns (uint96) {
        if (x > type(uint96).max) revert Uint96max();

        return uint96(x);
    }
}

contract AphraToken is DAOToken {



    bytes32 public immutable merkleRoot;


    mapping(address => bool) public hasClaimed;

    address public minter;

    uint256 public mintingAllowedAfter;

    uint32 public constant minimumTimeBetweenMints = 1 days * 365;

    uint8 public constant mintCap = 3;

    error NotMinter();
    error NoMintYet();
    error MintCapExceeded(uint256 maxAllowed, uint256 mintAttempt);


    error AlreadyClaimed();
    error NotInMerkle();

    event MinterChanged(address indexed minter, address indexed newMinter);
    event Claim(address indexed to, uint256 amount);

    constructor(bytes32 merkleRoot_,
                address minter_,
                uint256 mintingAllowedAfter_
    ) {
        _init("Aphra Finance", "APHRA");
        merkleRoot = merkleRoot_;
        minter = minter_;
        mintingAllowedAfter = mintingAllowedAfter_;
        emit MinterChanged(address(0), minter);
    }

    function setMinter(address newMinter_) external {

        if (msg.sender != minter) revert NotMinter();
        minter = newMinter_;
        emit MinterChanged(newMinter_, minter);
    }

    function mint(uint256 rawAmount) external {

        if (msg.sender != minter) revert NotMinter();
        if (block.timestamp <= mintingAllowedAfter) revert NoMintYet();
        mintingAllowedAfter = block.timestamp + minimumTimeBetweenMints;
        uint256 mintableBalance = ((totalSupply * mintCap) / 100);
        if (rawAmount > mintableBalance) revert MintCapExceeded(mintableBalance, rawAmount);
        _mint(minter, rawAmount);
    }

    function claim(address to, uint256 amount, bytes32[] calldata proof) external {

        if (hasClaimed[to]) revert AlreadyClaimed();

        bytes32 leaf = keccak256(abi.encodePacked(to, amount));
        bool isValidLeaf = MerkleProof.verify(proof, merkleRoot, leaf);
        if (!isValidLeaf) revert NotInMerkle();

        hasClaimed[to] = true;

        _mint(to, amount);

        emit Claim(to, amount);
    }
}