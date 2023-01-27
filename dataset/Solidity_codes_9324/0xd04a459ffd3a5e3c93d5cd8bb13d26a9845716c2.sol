pragma solidity >=0.7.0;

contract Authorizable {


    address public owner;
    mapping(address => bool) public authorized;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {

        require(msg.sender == owner, "Sender not owner");
        _;
    }

    modifier onlyAuthorized() {

        require(isAuthorized(msg.sender), "Sender not Authorized");
        _;
    }

    function isAuthorized(address who) public view returns (bool) {

        return authorized[who];
    }

    function authorize(address who) external onlyOwner() {

        _authorize(who);
    }

    function deauthorize(address who) external onlyOwner() {

        authorized[who] = false;
    }

    function setOwner(address who) public onlyOwner() {

        owner = who;
    }

    function _authorize(address who) internal {

        authorized[who] = true;
    }
}// MIT

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
                computedHash = keccak256(abi.encodePacked(computedHash, proofElement));
            } else {
                computedHash = keccak256(abi.encodePacked(proofElement, computedHash));
            }
        }
        return computedHash;
    }
}// Apache-2.0
pragma solidity ^0.8.3;

interface IERC20 {

    function symbol() external view returns (string memory);


    function balanceOf(address account) external view returns (uint256);


    function decimals() external view returns (uint8);


    function transfer(address recipient, uint256 amount)
        external
        returns (bool);


    function allowance(address owner, address spender)
        external
        view
        returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}// Apache-2.0
pragma solidity ^0.8.3;


interface ILockingVault {

    function deposit(
        address fundedAccount,
        uint256 amount,
        address firstDelegation
    ) external;


    function withdraw(uint256 amount) external;


    function token() external returns (IERC20);

}// Apache-2.0
pragma solidity ^0.8.3;


abstract contract AbstractMerkleRewards {
    bytes32 public rewardsRoot;
    IERC20 public immutable token;
    mapping(address => uint256) public claimed;
    ILockingVault public lockingVault;

    constructor(
        bytes32 _rewardsRoot,
        IERC20 _token,
        ILockingVault _lockingVault
    ) {
        rewardsRoot = _rewardsRoot;
        token = _token;
        lockingVault = _lockingVault;
        _token.approve(address(lockingVault), type(uint256).max);
    }

    function claimAndDelegate(
        uint256 amount,
        address delegate,
        uint256 totalGrant,
        bytes32[] calldata merkleProof,
        address destination
    ) external {
        require(delegate != address(0), "Zero addr delegation");
        _validateWithdraw(amount, totalGrant, merkleProof);
        lockingVault.deposit(destination, amount, delegate);
    }

    function claim(
        uint256 amount,
        uint256 totalGrant,
        bytes32[] calldata merkleProof,
        address destination
    ) external virtual {
        _validateWithdraw(amount, totalGrant, merkleProof);
        token.transfer(destination, amount);
    }

    function _validateWithdraw(
        uint256 amount,
        uint256 totalGrant,
        bytes32[] memory merkleProof
    ) internal {
        bytes32 leafHash = keccak256(abi.encodePacked(msg.sender, totalGrant));

        require(
            MerkleProof.verify(merkleProof, rewardsRoot, leafHash),
            "Invalid Proof"
        );
        require(claimed[msg.sender] + amount <= totalGrant, "Claimed too much");
        claimed[msg.sender] += amount;
    }
}

contract MerkleRewards is AbstractMerkleRewards {

    constructor(
        bytes32 _rewardsRoot,
        IERC20 _token,
        ILockingVault _lockingVault
    ) AbstractMerkleRewards(_rewardsRoot, _token, _lockingVault) {}
}// Apache-2.0
pragma solidity ^0.8.3;



contract Airdrop is MerkleRewards, Authorizable {

    uint256 public immutable expiration;

    constructor(
        address _governance,
        bytes32 _merkleRoot,
        IERC20 _token,
        uint256 _expiration,
        ILockingVault _lockingVault
    ) MerkleRewards(_merkleRoot, _token, _lockingVault) {
        expiration = _expiration;
        setOwner(_governance);
    }

    function reclaim(address destination) external onlyOwner {

        require(block.timestamp > expiration, "Not expired");
        uint256 unclaimed = token.balanceOf(address(this));
        token.transfer(destination, unclaimed);
    }

    function claim(
        uint256 amount,
        uint256 totalGrant,
        bytes32[] calldata merkleProof,
        address destination
    ) external virtual override {

        revert("Not Allowed to claim");
    }
}