
pragma solidity ^0.8.0;

library MerkleProof {

    function verify(bytes32[] memory proof, bytes32 root, bytes32 leaf) internal pure returns (bool) {

        bytes32 computedHash = leaf;

        for (uint256 i = 0; i < proof.length; i++) {
            bytes32 proofElement = proof[i];

            if (computedHash <= proofElement) {
                computedHash = keccak256(abi.encodePacked(computedHash, proofElement));
            } else {
                computedHash = keccak256(abi.encodePacked(proofElement, computedHash));
            }
        }

        return computedHash == root;
    }
}

interface IMerkleDistributor {

    function merkleRoot() external view returns (bytes32);

    function isClaimed(uint256 index) external view returns (bool);

    function claim(uint256 index, address account, uint256 amount, bytes32[] calldata merkleProof) external;


    event Claimed(uint256 index, address account, uint256 amount);
}

contract ETHDistributor is IMerkleDistributor {

    bytes32 public immutable override merkleRoot;
    address public owner;

    mapping(uint256 => uint256) private claimedBitMap;

    constructor(bytes32 merkleRoot_) {
        merkleRoot = merkleRoot_;
        owner = msg.sender;
    }

    receive() external payable {}

    function isClaimed(uint256 index) public view override returns (bool) {

        uint256 claimedWordIndex = index / 256;
        uint256 claimedBitIndex = index % 256;
        uint256 claimedWord = claimedBitMap[claimedWordIndex];
        uint256 mask = (1 << claimedBitIndex);
        return claimedWord & mask == mask;
    }

    function _setClaimed(uint256 index) private {

        uint256 claimedWordIndex = index / 256;
        uint256 claimedBitIndex = index % 256;
        claimedBitMap[claimedWordIndex] = claimedBitMap[claimedWordIndex] | (1 << claimedBitIndex);
    }

    function claim(uint256 index, address account, uint256 amount, bytes32[] calldata merkleProof) external override {

        require(!isClaimed(index), 'ETHDistributor: Drop already claimed.');

        bytes32 node = keccak256(abi.encodePacked(index, account, amount));
        require(MerkleProof.verify(merkleProof, merkleRoot, node), 'ETHDistributor: Invalid proof.');

        _setClaimed(index);
        payable(account).transfer(amount);

        emit Claimed(index, account, amount);
    }

    function withdrawRemaining() external {

        require(msg.sender == owner, "ETHDistributor: wrong sender");
        payable(msg.sender).transfer(address(this).balance);
    }
}