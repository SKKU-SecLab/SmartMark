
pragma solidity ^0.8.4;


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
}


interface IERC721 {

  function transferFrom(address from, address to, uint256 tokenId) external;

}

contract SantaSwapExchange {



  struct SantaNFT {
    address nftContract;
    uint256 tokenId;
  }


  uint256 immutable public RECLAIM_OPEN;


  address public owner;
  bytes32 public merkle;
  mapping(address => uint256) public nftCount;
  mapping(address => SantaNFT[]) public nfts;


  error NotOwner();
  error NotClaimable();


  constructor() {
    owner = msg.sender;
    RECLAIM_OPEN = block.timestamp + 604_800;
  }

  function _leaf(
    address giftee, 
    address santa, 
    uint256 santaIndex
  ) internal pure returns (bytes32) {

    return keccak256(abi.encodePacked(giftee, santa, santaIndex));
  }

  function _verify(
    bytes32 leaf,
    bytes32[] calldata proof
  ) internal view returns (bool) {

    return MerkleProof.verify(proof, merkle, leaf);
  }

  function santaDepositNFT(address nftContract, uint256 tokenId) external {

    IERC721(nftContract).transferFrom(msg.sender, address(this), tokenId);
    nftCount[msg.sender]++;
    nfts[msg.sender].push(SantaNFT(nftContract, tokenId));
  }

  function gifteeClaimNFT(
    address santa,
    uint256 santaIndex,
    bytes32[] calldata proof
  ) external {

    if (merkle == 0) revert NotClaimable();
    if (!_verify(_leaf(msg.sender, santa, santaIndex), proof)) revert NotClaimable();

    SantaNFT memory nft = nfts[santa][santaIndex];
    IERC721(nft.nftContract).transferFrom(address(this), msg.sender, nft.tokenId);
  }

  function santaReclaimNFT(uint256 index) external {

    if (block.timestamp < RECLAIM_OPEN) revert NotClaimable();
    if (index + 1 > nfts[msg.sender].length) revert NotClaimable();

    SantaNFT memory nft = nfts[msg.sender][index];
    IERC721(nft.nftContract).transferFrom(address(this), msg.sender, nft.tokenId);
  }

  function adminWithdrawNFT(
    address nftContract,
    uint256 tokenId,
    address recipient
  ) external {

    if (msg.sender != owner) revert NotOwner();

    IERC721(nftContract).transferFrom(
      address(this),
      recipient,
      tokenId
    );
  }

  function adminWithdrawNFTBulk(
    address[] calldata contracts,
    uint256[] calldata tokenIds,
    address[] calldata recipients
  ) external {

    if (msg.sender != owner) revert NotOwner();

    for (uint256 i = 0; i < contracts.length; i++) {
      IERC721(contracts[i]).transferFrom(
        address(this),
        recipients[i],
        tokenIds[i]
      );
    }
  }

  function adminUpdateMerkle(bytes32 merkleRoot) external {

    if (msg.sender != owner) revert NotOwner();
    merkle = merkleRoot;
  }

  function adminUpdateOwner(address newOwner) external {

    if (msg.sender != owner) revert NotOwner();
    owner = newOwner;
  }
}