
pragma solidity ^0.8.0;

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}// MIT

pragma solidity ^0.8.0;


interface IERC721 is IERC165 {

    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    function balanceOf(address owner) external view returns (uint256 balance);


    function ownerOf(uint256 tokenId) external view returns (address owner);


    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;


    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;


    function approve(address to, uint256 tokenId) external;


    function getApproved(uint256 tokenId) external view returns (address operator);


    function setApprovalForAll(address operator, bool _approved) external;


    function isApprovedForAll(address owner, address operator) external view returns (bool);


    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;

}// MIT

pragma solidity ^0.8.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address to, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}// MIT

pragma solidity ^0.8.0;

library EnumerableSet {


    struct Set {
        bytes32[] _values;
        mapping(bytes32 => uint256) _indexes;
    }

    function _add(Set storage set, bytes32 value) private returns (bool) {

        if (!_contains(set, value)) {
            set._values.push(value);
            set._indexes[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

    function _remove(Set storage set, bytes32 value) private returns (bool) {

        uint256 valueIndex = set._indexes[value];

        if (valueIndex != 0) {

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;

            if (lastIndex != toDeleteIndex) {
                bytes32 lastvalue = set._values[lastIndex];

                set._values[toDeleteIndex] = lastvalue;
                set._indexes[lastvalue] = valueIndex; // Replace lastvalue's index to valueIndex
            }

            set._values.pop();

            delete set._indexes[value];

            return true;
        } else {
            return false;
        }
    }

    function _contains(Set storage set, bytes32 value) private view returns (bool) {

        return set._indexes[value] != 0;
    }

    function _length(Set storage set) private view returns (uint256) {

        return set._values.length;
    }

    function _at(Set storage set, uint256 index) private view returns (bytes32) {

        return set._values[index];
    }

    function _values(Set storage set) private view returns (bytes32[] memory) {

        return set._values;
    }


    struct Bytes32Set {
        Set _inner;
    }

    function add(Bytes32Set storage set, bytes32 value) internal returns (bool) {

        return _add(set._inner, value);
    }

    function remove(Bytes32Set storage set, bytes32 value) internal returns (bool) {

        return _remove(set._inner, value);
    }

    function contains(Bytes32Set storage set, bytes32 value) internal view returns (bool) {

        return _contains(set._inner, value);
    }

    function length(Bytes32Set storage set) internal view returns (uint256) {

        return _length(set._inner);
    }

    function at(Bytes32Set storage set, uint256 index) internal view returns (bytes32) {

        return _at(set._inner, index);
    }

    function values(Bytes32Set storage set) internal view returns (bytes32[] memory) {

        return _values(set._inner);
    }


    struct AddressSet {
        Set _inner;
    }

    function add(AddressSet storage set, address value) internal returns (bool) {

        return _add(set._inner, bytes32(uint256(uint160(value))));
    }

    function remove(AddressSet storage set, address value) internal returns (bool) {

        return _remove(set._inner, bytes32(uint256(uint160(value))));
    }

    function contains(AddressSet storage set, address value) internal view returns (bool) {

        return _contains(set._inner, bytes32(uint256(uint160(value))));
    }

    function length(AddressSet storage set) internal view returns (uint256) {

        return _length(set._inner);
    }

    function at(AddressSet storage set, uint256 index) internal view returns (address) {

        return address(uint160(uint256(_at(set._inner, index))));
    }

    function values(AddressSet storage set) internal view returns (address[] memory) {

        bytes32[] memory store = _values(set._inner);
        address[] memory result;

        assembly {
            result := store
        }

        return result;
    }


    struct UintSet {
        Set _inner;
    }

    function add(UintSet storage set, uint256 value) internal returns (bool) {

        return _add(set._inner, bytes32(value));
    }

    function remove(UintSet storage set, uint256 value) internal returns (bool) {

        return _remove(set._inner, bytes32(value));
    }

    function contains(UintSet storage set, uint256 value) internal view returns (bool) {

        return _contains(set._inner, bytes32(value));
    }

    function length(UintSet storage set) internal view returns (uint256) {

        return _length(set._inner);
    }

    function at(UintSet storage set, uint256 index) internal view returns (uint256) {

        return uint256(_at(set._inner, index));
    }

    function values(UintSet storage set) internal view returns (uint256[] memory) {

        bytes32[] memory store = _values(set._inner);
        uint256[] memory result;

        assembly {
            result := store
        }

        return result;
    }
}// MIT

pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}// MIT

pragma solidity ^0.8.0;


abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _transferOwnership(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}// MIT

pragma solidity ^0.8.0;

abstract contract ReentrancyGuard {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
    }
}// GPL-3.0
pragma solidity ^0.8;


contract JPEGCStaking is Ownable, ReentrancyGuard {

    using EnumerableSet for EnumerableSet.UintSet;

    event Deposit(address indexed user, uint256 indexed nft);
    event Withdraw(address indexed user, uint256 indexed nft);
    event Claim(address indexed user, uint256 indexed nft, uint256 amount);

    struct PoolState {
        uint256 lastRewardBlock;
        uint256 rewardsPerBlock;
        uint256 accRewardPerNft;
        uint256 endBlock;
    }

    IERC721 public immutable jpegc;
    IERC20 public immutable jpeg;

    uint256 public totalNftsStaked;

    PoolState internal poolState;

    mapping(address => EnumerableSet.UintSet) internal stakedNfts;
    mapping(uint256 => uint256) internal lastAccRewardPerNFT;

    constructor(IERC721 _jpegc, IERC20 _jpeg) {
        jpegc = _jpegc;
        jpeg = _jpeg;
    }


    function allocateRewards(uint256 startBlock, uint256 rewardsPerBlock, uint256 endBlock) external onlyOwner {

        require(poolState.lastRewardBlock == 0, "ALREADY_ALLOCATED");
        require(startBlock > block.number, "INVALID_START_BLOCK");
        require(rewardsPerBlock > 0, "INVALID_REWARDS_PER_BLOCK");
        require(endBlock > startBlock, "INVALID_END_BLOCK");

        poolState.lastRewardBlock = startBlock;
        poolState.rewardsPerBlock = rewardsPerBlock;
        poolState.endBlock = endBlock;

        jpeg.transferFrom(msg.sender, address(this), (endBlock - startBlock) * rewardsPerBlock);
    }

    function deposit(uint256[] memory nfts) external nonReentrant {

        require(nfts.length > 0, "INVALID_NFTS");
        require(poolState.lastRewardBlock > 0, "NOT_STARTED");
        _update();

        totalNftsStaked += nfts.length;
        uint256 accRewardPerNFT = poolState.accRewardPerNft;
        for (uint256 i = 0; i < nfts.length; i++) {
            stakedNfts[msg.sender].add(nfts[i]);
            lastAccRewardPerNFT[nfts[i]] = accRewardPerNFT;

            jpegc.transferFrom(msg.sender, address(this), nfts[i]);

            emit Deposit(msg.sender, nfts[i]);
        }
    }

    function withdraw(uint256[] memory nfts) public nonReentrant {

        require(nfts.length > 0, "INVALID_NFTS");
        _update();

        totalNftsStaked -= nfts.length;

        uint256 accRewardPerNft = poolState.accRewardPerNft;
        uint256 toClaim;
        for (uint256 i = 0; i < nfts.length; i++) {
            require(stakedNfts[msg.sender].contains(nfts[i]), "NOT_AUTHORIZED");
            toClaim += (accRewardPerNft - lastAccRewardPerNFT[nfts[i]]) /
                1e36;
            stakedNfts[msg.sender].remove(nfts[i]);
            jpegc.safeTransferFrom(address(this), msg.sender, nfts[i]);

            emit Withdraw(msg.sender, nfts[i]);
        }

        if(toClaim > 0)
            jpeg.transfer(msg.sender, toClaim);

    }

    function claim(uint256[] memory nfts) public nonReentrant {

        require(nfts.length > 0, "INVALID_NFTS");
        _update();

        uint256 accRewardPerNft = poolState.accRewardPerNft;
        uint256 claimable;
        for (uint256 i = 0; i < nfts.length; i++) {
            require(stakedNfts[msg.sender].contains(nfts[i]), "NOT_AUTHORIZED");
            uint256 toClaim = (accRewardPerNft - lastAccRewardPerNFT[nfts[i]]) /
                1e36;
            lastAccRewardPerNFT[nfts[i]] = accRewardPerNft;

            claimable += toClaim;

            emit Claim(msg.sender, nfts[i], toClaim);
        }

        require(claimable > 0, "NO_REWARDS");

        jpeg.transfer(msg.sender, claimable);
    }


    function claimAll() external {

        claim(stakedNfts[msg.sender].values());
    }

    function withdrawAll() external {

        withdraw(stakedNfts[msg.sender].values());
    }


    function userStakedNfts(address account)
        external
        view
        returns (uint256[] memory)
    {

        return stakedNfts[account].values();
    }
    
    function pendingReward(uint256 nft) public view returns (uint256) {

        uint256 accRewardPerNft = poolState.accRewardPerNft;
        
        uint256 blockNumber = block.number;

        if (blockNumber > poolState.endBlock)
            blockNumber = poolState.endBlock;

        if (blockNumber > poolState.lastRewardBlock && totalNftsStaked > 0) {
            uint256 reward = ((blockNumber - poolState.lastRewardBlock)) *
                poolState.rewardsPerBlock *
                1e36;
            accRewardPerNft += reward / totalNftsStaked;
        }

        return (accRewardPerNft - lastAccRewardPerNFT[nft]) / 1e36;
    }

    function pendingUserReward(address account)
        external
        view
        returns (uint256 totalReward)
    {

        for (uint256 i = 0; i < stakedNfts[account].length(); i++) {
            totalReward += pendingReward(stakedNfts[account].at(i));
        }
    }

    function _update() internal {

        PoolState memory pool = poolState;

        uint256 blockNumber = block.number;

        if (blockNumber > pool.endBlock)
            blockNumber = pool.endBlock;

        if (blockNumber <= pool.lastRewardBlock) return;

        if (totalNftsStaked == 0) {
            poolState.lastRewardBlock = blockNumber;
            return;
        }

        uint256 reward = ((blockNumber - pool.lastRewardBlock)) *
            pool.rewardsPerBlock *
            1e36;
        poolState.accRewardPerNft =
            pool.accRewardPerNft +
            reward /
            totalNftsStaked;
        poolState.lastRewardBlock = blockNumber;
    }
}