pragma solidity ^0.5.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}pragma solidity ^0.5.16;

contract Owned {

    address public owner;
    address public nominatedOwner;

    constructor(address _owner) public {
        require(_owner != address(0), "Owner address cannot be 0");
        owner = _owner;
        emit OwnerChanged(address(0), _owner);
    }

    function nominateNewOwner(address _owner) external onlyOwner {

        nominatedOwner = _owner;
        emit OwnerNominated(_owner);
    }

    function acceptOwnership() external {

        require(msg.sender == nominatedOwner, "You must be nominated before you can accept ownership");
        emit OwnerChanged(owner, nominatedOwner);
        owner = nominatedOwner;
        nominatedOwner = address(0);
    }

    modifier onlyOwner {

        _onlyOwner();
        _;
    }

    function _onlyOwner() private view {

        require(msg.sender == owner, "Only the contract owner may perform this action");
    }

    event OwnerNominated(address newOwner);
    event OwnerChanged(address oldOwner, address newOwner);
}pragma solidity ^0.5.0;

library MerkleProof {

    function verify(bytes32[] memory proof, bytes32 root, bytes32 leaf) internal pure returns (bool) {

        bytes32 computedHash = leaf;

        for (uint256 i = 0; i < proof.length; i++) {
            bytes32 proofElement = proof[i];

            if (computedHash < proofElement) {
                computedHash = keccak256(abi.encodePacked(computedHash, proofElement));
            } else {
                computedHash = keccak256(abi.encodePacked(proofElement, computedHash));
            }
        }

        return computedHash == root;
    }
}pragma solidity ^0.5.16;


contract Pausable is Owned {

    uint public lastPauseTime;
    bool public paused;

    constructor() internal {
        require(owner != address(0), "Owner must be set");
    }

    function setPaused(bool _paused) external onlyOwner {

        if (_paused == paused) {
            return;
        }

        paused = _paused;

        if (paused) {
            lastPauseTime = now;
        }

        emit PauseChanged(paused);
    }

    event PauseChanged(bool isPaused);

    modifier notPaused {

        require(!paused, "This action cannot be performed while the contract is paused");
        _;
    }
}pragma solidity ^0.5.16;


contract Airdrop is Owned, Pausable {

    IERC20 public token;

    bytes32 public root; // merkle tree root

    uint256 public startTime;

    mapping(uint256 => uint256) public _claimed;

    constructor(
        address _owner,
        IERC20 _token,
        bytes32 _root
    ) public Owned(_owner) Pausable() {
        token = _token;
        root = _root;
        startTime = block.timestamp;
    }

    function claimed(uint256 index) public view returns (uint256 claimedBlock, uint256 claimedMask) {

        claimedBlock = _claimed[index / 256];
        claimedMask = (uint256(1) << uint256(index % 256));
        require((claimedBlock & claimedMask) == 0, "Tokens have already been claimed");
    }

    function canClaim(uint256 index) external view returns (bool) {

        uint256 claimedBlock = _claimed[index / 256];
        uint256 claimedMask = (uint256(1) << uint256(index % 256));
        return ((claimedBlock & claimedMask) == 0);
    }

    function claim(
        uint256 index,
        uint256 amount,
        bytes32[] memory merkleProof
    ) public notPaused {

        require(token.balanceOf(address(this)) > amount, "Contract doesnt have enough tokens");

        (uint256 claimedBlock, uint256 claimedMask) = claimed(index);
        _claimed[index / 256] = claimedBlock | claimedMask;

        bytes32 leaf = keccak256(abi.encodePacked(index, msg.sender, amount));
        require(MerkleProof.verify(merkleProof, root, leaf), "Proof is not valid");
        token.transfer(msg.sender, amount);
        emit Claim(msg.sender, amount, block.timestamp);
    }

    function _selfDestruct(address payable beneficiary) external onlyOwner {

        require(block.timestamp > (startTime + 365 days), "Contract can only be selfdestruct after a year");

        token.transfer(beneficiary, token.balanceOf(address(this)));

        selfdestruct(beneficiary);
    }

    event Claim(address claimer, uint256 amount, uint timestamp);
}