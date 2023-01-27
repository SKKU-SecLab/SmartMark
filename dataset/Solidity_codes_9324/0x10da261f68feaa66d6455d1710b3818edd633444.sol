
pragma solidity 0.8.1;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}


abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    function isOwner() public view returns (bool) {
        return _msgSender() == _owner;
    }

    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}


contract CloneFactory {

    function createClone(address target, bytes32 salt) internal returns (address result) {

        bytes20 targetBytes = bytes20(target);
        assembly {
            let clone := mload(0x40)
            mstore(clone, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
            mstore(add(clone, 0x14), targetBytes)
            mstore(add(clone, 0x28), 0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000)
            result := create2(0, clone, 0x37, salt)
        }
  }
  
  function computeCloneAddress(address target, bytes32 salt) internal view returns (address) {

        bytes20 targetBytes = bytes20(target);
        bytes32 bytecodeHash;
        assembly {
            let clone := mload(0x40)
            mstore(clone, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
            mstore(add(clone, 0x14), targetBytes)
            mstore(add(clone, 0x28), 0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000)
            bytecodeHash := keccak256(clone, 0x37)
        }
        bytes32 _data = keccak256(
            abi.encodePacked(bytes1(0xff), address(this), salt, bytecodeHash)
        );
        return address(bytes20(_data << 96));
    }
    
    function isClone(address target, address query) internal view returns (bool result) {

        bytes20 targetBytes = bytes20(target);
        assembly {
            let clone := mload(0x40)
            mstore(clone, 0x363d3d373d3d3d363d7300000000000000000000000000000000000000000000)
            mstore(add(clone, 0xa), targetBytes)
            mstore(add(clone, 0x1e), 0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000)
            
            let other := add(clone, 0x40)
            extcodecopy(query, other, 0, 0x2d)
            result := and(
                eq(mload(clone), mload(other)),
                eq(mload(add(clone, 0xd)), mload(add(other, 0xd)))
            )
        }
    }
}


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


interface IERC20 {

    function transfer(address recipient, uint256 amount) external returns (bool);

    function balanceOf(address account) external view returns (uint256);

}


interface IERC721 {

    function safeTransferFrom(address from, address to, uint256 tokenId) external;

    function ownerOf(uint256 tokenId) external view returns (address owner);

}


library Address {

    function isContract(address account) internal view returns (bool) {


        uint256 size;
        assembly { size := extcodesize(account) }
        return size > 0;
    }
}


library SafeERC20 {

    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {

        callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function callOptionalReturn(IERC20 token, bytes memory data) private {


        require(address(token).isContract(), "SafeERC20: call to non-contract");

        (bool success, bytes memory returndata) = address(token).call(data);
        require(success, "SafeERC20: low-level call failed");

        if (returndata.length > 0) { // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}


interface IAstrodrop {

    function token() external view returns (address);

    function merkleRoot() external view returns (bytes32);

    function isClaimed(uint256 index) external view returns (bool);

    function claim(uint256 index, address account, uint256 amount, bytes32[] calldata merkleProof) external;


    event Claimed(uint256 index, address account, uint256 amount);
}


contract Astrodrop is IAstrodrop, Ownable {

    using SafeERC20 for IERC20;

    address public override token;
    bytes32 public override merkleRoot;
    bool public initialized;
    uint256 public expireTimestamp;

    mapping(uint256 => uint256) public claimedBitMap;

    function init(address owner_, address token_, bytes32 merkleRoot_, uint256 expireTimestamp_) external {

        require(!initialized, "Astrodrop: Initialized");
        initialized = true;

        token = token_;
        merkleRoot = merkleRoot_;
        expireTimestamp = expireTimestamp_;
        
        _transferOwnership(owner_);
    }

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

        require(!isClaimed(index), 'MerkleDistributor: Drop already claimed.');

        bytes32 node = keccak256(abi.encodePacked(index, account, amount));
        require(MerkleProof.verify(merkleProof, merkleRoot, node), 'Astrodrop: Invalid proof');

        _setClaimed(index);
        IERC20(token).safeTransfer(account, amount);

        emit Claimed(index, account, amount);
    }

    function sweep(address token_, address target) external onlyOwner {

        require(block.timestamp >= expireTimestamp || token_ != token, "Astrodrop: Not expired");
        IERC20 tokenContract = IERC20(token_);
        uint256 balance = tokenContract.balanceOf(address(this));
        tokenContract.safeTransfer(target, balance);
    }
}


contract AstrodropERC721 is IAstrodrop, Ownable {

    using SafeERC20 for IERC20;

    address public override token;
    bytes32 public override merkleRoot;
    bool public initialized;
    uint256 public expireTimestamp;

    mapping(uint256 => uint256) public claimedBitMap;

    function init(address owner_, address token_, bytes32 merkleRoot_, uint256 expireTimestamp_) external {

        require(!initialized, "Astrodrop: Initialized");
        initialized = true;

        token = token_;
        merkleRoot = merkleRoot_;
        expireTimestamp = expireTimestamp_;
        
        _transferOwnership(owner_);
    }

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

        require(!isClaimed(index), 'MerkleDistributor: Drop already claimed.');

        bytes32 node = keccak256(abi.encodePacked(index, account, amount));
        require(MerkleProof.verify(merkleProof, merkleRoot, node), 'Astrodrop: Invalid proof');

        _setClaimed(index);
        IERC721 tokenContract = IERC721(token);
        tokenContract.safeTransferFrom(tokenContract.ownerOf(amount), account, amount);

        emit Claimed(index, account, amount);
    }

    function sweep(address token_, address target) external onlyOwner {

        require(block.timestamp >= expireTimestamp || token_ != token, "Astrodrop: Not expired");
        IERC20 tokenContract = IERC20(token_);
        uint256 balance = tokenContract.balanceOf(address(this));
        tokenContract.safeTransfer(target, balance);
    }
}


contract AstrodropFactory is CloneFactory {

    event CreateAstrodrop(address astrodrop, bytes32 ipfsHash);

    function createAstrodrop(
        address template,
        address token,
        bytes32 merkleRoot,
        uint256 expireTimestamp,
        bytes32 salt,
        bytes32 ipfsHash
    ) external returns (Astrodrop drop) {

        drop = Astrodrop(createClone(template, salt));
        drop.init(msg.sender, token, merkleRoot, expireTimestamp);
        emit CreateAstrodrop(address(drop), ipfsHash);
    }

    function computeAstrodropAddress(
        address template,
        bytes32 salt
    ) external view returns (address) {

        return computeCloneAddress(template, salt);
    }
    
    function isAstrodrop(address template, address query) external view returns (bool) {

        return isClone(template, query);
    }
}