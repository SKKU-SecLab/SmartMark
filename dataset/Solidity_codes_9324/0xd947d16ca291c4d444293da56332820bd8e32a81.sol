


pragma solidity ^0.6.0;

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


pragma solidity ^0.6.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}


pragma solidity ^0.6.0;

contract Ownable is Context {

    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {

        return _owner;
    }

    modifier onlyOwner() {

        require(_owner == _msgSender(), "Ownable: caller is not the owner");
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
}


pragma solidity =0.6.11;

interface Mintable {

    function setTokenId(uint256 id, bytes32 sig) external;

    function mint(address account, uint256 id, uint256 amount) external;

}


pragma solidity =0.6.11;




contract Minter is Ownable {

    event Claimed(
        uint256 index,
        bytes32 sig,
        address account,
        uint256 count
    );

    bytes32 public immutable merkleRoot;

    Mintable public mintable;

    mapping(uint256 => bool) public claimed;

    uint256 public nextId = 1;
    mapping(bytes32 => uint256) public sigToTokenId;

    constructor(bytes32 _merkleRoot) public {
        merkleRoot = _merkleRoot;
    }

    function setMintable(Mintable _mintable) public onlyOwner {

        require(address(mintable) == address(0), "Minter: Can't set Mintable contract twice");
        mintable = _mintable;
    }

    function merkleVerify(bytes32 node, bytes32[] memory proof) public view returns (bool) {

        return MerkleProof.verify(proof, merkleRoot, node);
    }

    function makeNode(
        uint256 index,
        bytes32 sig,
        address account,
        uint256 count
    ) public pure returns (bytes32) {

        return keccak256(abi.encodePacked(index, sig, account, count));
    }

    function claim(
        uint256 index,
        bytes32 sig,
        address account,
        uint256 count,
        bytes32[] memory proof
    ) public {

        require(address(mintable) != address(0), "Minter: Must have a mintable set");

        require(!claimed[index], "Minter: Can't claim a drop that's already been claimed");
        claimed[index] = true;

        bytes32 node = makeNode(index, sig, account, count);
        require(merkleVerify(node, proof), "Minter: merkle verification failed");

        uint256 id = sigToTokenId[sig];
        if (id == 0) {
            sigToTokenId[sig] = nextId;
            mintable.setTokenId(nextId, sig);
            id = nextId;

            nextId++;
        }

        mintable.mint(account, id, count);

        emit Claimed(index, sig, account, count);
    }
}