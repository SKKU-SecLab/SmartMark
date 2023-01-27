
pragma solidity 0.8.11;

interface IMerkleWalletClaimer {

    function factory() external view returns (address);

    function merkleRoot() external view returns (bytes32);

    function isClaimed(uint256 index) external view returns (bool);

    function claim(uint256 index, address wallet, address initialSigningKey, bytes calldata claimantSignature, bytes32[] calldata merkleProof) external;

    function claimFor(address owner, uint256 index, address wallet, address initialSigningKey, bytes calldata claimantSignature, bytes32[] calldata merkleProof) external;

    event Claimed(uint256 index, address wallet, address owner);
}

interface WalletFactory {

    function newSmartWallet(
        address userSigningKey
    ) external returns (address wallet);

}

interface Wallet {

    function claimOwnership(address owner) external;

}

library MerkleProof {

    function verify(bytes32[] memory proof, bytes32 root, bytes32 leaf) internal pure returns (bool) {

        bytes32 computedHash = leaf;

        for (uint256 i = 0; i < proof.length; i++) {
            bytes32 proofElement = proof[i];

            if (computedHash <= proofElement) {
                computedHash = _efficientHash(computedHash, proofElement);
            } else {
                computedHash = _efficientHash(proofElement, computedHash);
            }
        }

        return computedHash == root;
    }

    function _efficientHash(bytes32 a, bytes32 b) private pure returns (bytes32 value) {

        assembly {
            mstore(0x00, a)
            mstore(0x20, b)
            value := keccak256(0x00, 0x40)
        }
    }
}

library ECDSA {

  function recover(
    bytes32 hash, bytes memory signature
  ) internal pure returns (address) {

    if (signature.length != 65) {
      return (address(0));
    }

    bytes32 r;
    bytes32 s;
    uint8 v;

    assembly {
      r := mload(add(signature, 0x20))
      s := mload(add(signature, 0x40))
      v := byte(0, mload(add(signature, 0x60)))
    }

    if (uint256(s) > 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0) {
      return address(0);
    }

    if (v != 27 && v != 28) {
      return address(0);
    }

    return ecrecover(hash, v, r, s);
  }

  function toEthSignedMessageHash(address subject) internal pure returns (bytes32) {

    return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n20", subject));
  }
}

contract MerkleWalletClaimer is IMerkleWalletClaimer {

    using ECDSA for address;
    using ECDSA for bytes32;
    address public immutable override factory;
    bytes32 public immutable override merkleRoot;

    mapping (address => address[]) public claimedWalletsByOwner;

    mapping(uint256 => uint256) private claimedBitMap;

    constructor(address factory_, bytes32 merkleRoot_) {
        factory = factory_;
        merkleRoot = merkleRoot_;
    }

    function claim(
        uint256 index,
        address wallet,
        address initialSigningKey,
        bytes calldata claimantSignature,
        bytes32[] calldata merkleProof
    ) external override {

        _claim(msg.sender, index, wallet, initialSigningKey, claimantSignature, merkleProof);
    }

    function claimFor(
        address owner,
        uint256 index,
        address wallet,
        address initialSigningKey,
        bytes calldata claimantSignature,
        bytes32[] calldata merkleProof
    ) external override {

        _claim(owner, index, wallet, initialSigningKey, claimantSignature, merkleProof);
    }

    function isClaimed(uint256 index) public view override returns (bool) {

        uint256 claimedWordIndex = index >> 8;
        uint256 claimedBitIndex = index & 0xff;
        uint256 claimedWord = claimedBitMap[claimedWordIndex];
        uint256 mask = (1 << claimedBitIndex);
        return claimedWord & mask != 0;
    }

    function _setClaimed(uint256 index) private {

        uint256 claimedWordIndex = index >> 8;
        uint256 claimedBitIndex = index & 0xff;
        claimedBitMap[claimedWordIndex] = claimedBitMap[claimedWordIndex] | (1 << claimedBitIndex);
    }

    function _deployIfNecessary(address wallet, address initialSigningKey) private {

        uint256 walletCode;
        assembly { walletCode := extcodesize(wallet) }
        if (walletCode == 0) {
            WalletFactory(factory).newSmartWallet(initialSigningKey);

            assembly { walletCode := extcodesize(wallet) }
            require(
                walletCode != 0,
                'MerkleWalletClaimer: Invalid initial signing key supplied.'
            );
        }
    }

    function _claim(
        address owner,
        uint256 index,
        address wallet,
        address initialSigningKey,
        bytes calldata claimantSignature,
        bytes32[] calldata merkleProof
    ) private {

        require(!isClaimed(index), 'MerkleWalletClaimer: Wallet already claimed.');

        bytes32 messageHash = owner.toEthSignedMessageHash();

        uint256 claimantKey = uint256(uint160(messageHash.recover(claimantSignature)));

        bytes32 node = keccak256(abi.encodePacked(index, wallet, claimantKey));
        require(
            MerkleProof.verify(merkleProof, merkleRoot, node),
            'MerkleWalletClaimer: Invalid proof.'
        );

        _setClaimed(index);

        _deployIfNecessary(wallet, initialSigningKey);

        Wallet(wallet).claimOwnership(owner);

        claimedWalletsByOwner[owner].push(wallet);
        emit Claimed(index, wallet, owner);
    }
}