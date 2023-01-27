
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
        uint256 tokenId,
        bytes calldata data
    ) external;


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


    function setApprovalForAll(address operator, bool _approved) external;


    function getApproved(uint256 tokenId) external view returns (address operator);


    function isApprovedForAll(address owner, address operator) external view returns (bool);

}// MIT

pragma solidity ^0.8.0;

interface IERC20 {

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);

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
}// MIT

pragma solidity ^0.8.0;

library Strings {

    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";

    function toString(uint256 value) internal pure returns (string memory) {


        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    function toHexString(uint256 value) internal pure returns (string memory) {

        if (value == 0) {
            return "0x00";
        }
        uint256 temp = value;
        uint256 length = 0;
        while (temp != 0) {
            length++;
            temp >>= 8;
        }
        return toHexString(value, length);
    }

    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {

        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _HEX_SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
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
}// MIT

pragma solidity ^0.8.0;

contract StakingContract is Ownable, ReentrancyGuard {

    using Strings for uint256;

    address public rtoken;
    address public nftAddress;
    
    struct UserInfo {
        uint256 tokenId;
        uint256 rarity;
        uint256 startTime;
    }
    
    mapping(address => UserInfo[]) public userInfo;
    mapping(address => uint256) public stakingAmount;

    event Stake(address indexed user, uint256 amount);
    event UnStake(address indexed user, uint256 amount);

    bytes32[5] public rarityMerkleRoot;
    uint256[5] public rewardTokenPerDay;

    constructor(address _rTokenAddress, address _nftTokenAddress, bytes32[] memory _rarityMerkleRoot, uint256[] memory _rewardTokenPerDay) {
        rtoken = _rTokenAddress;
        nftAddress = _nftTokenAddress;

        for(uint256 i = 0; i < _rarityMerkleRoot.length; i++) {
            rarityMerkleRoot[i] = _rarityMerkleRoot[i];
        }
        for(uint256 i = 0; i < _rewardTokenPerDay.length; i++) {
            rewardTokenPerDay[i] = _rewardTokenPerDay[i] * 1 ether;
        }
    }

    function updateRarityMerkleRoots(bytes32[] memory _rarityMerkleRoot) public onlyOwner() {

        for(uint256 i = 0; i < _rarityMerkleRoot.length; i++) {
            rarityMerkleRoot[i] = _rarityMerkleRoot[i];
        }
    }

    function changeRewardTokenAddress(address _rewardTokenAddress) public onlyOwner {

        rtoken = _rewardTokenAddress;
    }

    function changeNftTokenAddress(address _nftTokenAddress) public onlyOwner {

        nftAddress = _nftTokenAddress;
    }

    function changeRewardTokenPerDay(uint256[] memory _rewardTokenPerDay) public onlyOwner {

        for(uint256 i = 0; i < 5; i++)  
            rewardTokenPerDay[i] = _rewardTokenPerDay[i];
    }

    function approve(address tokenAddress, address spender, uint256 amount) public onlyOwner returns (bool) {

      IERC20(tokenAddress).approve(spender, amount);
      return true;
    }

    function pendingReward(address _user, uint256 _tokenId, uint256 _rarity) public view returns (uint256) {


        (bool _isStaked, uint256 _startTime) = getStakingItemInfo(_user, _tokenId);
        if(!_isStaked) return 0;

        uint256 currentTime = block.timestamp;        
        uint256 rewardAmount = rewardTokenPerDay[_rarity] * (currentTime - _startTime) / 1 days;
        return rewardAmount;
    }

    function pendingTotalReward(address _user) public view returns(uint256) {

        uint256 pending = 0;
        for (uint256 i = 0; i < userInfo[_user].length; i++) {
            uint256 temp = pendingReward(_user, userInfo[_user][i].tokenId, userInfo[_user][i].rarity);
            pending = pending + temp;
        }
        return pending;
    }

    function getRarity(bytes32[] calldata _merkleProof, uint256 _tokenId) public view returns(uint256) {

        bytes32 leaf = keccak256(abi.encodePacked(_tokenId.toString()));
        for(uint256 i = 0; i < 5; i++) {
            if(MerkleProof.verify(_merkleProof, rarityMerkleRoot[i], leaf)) {
                return i;
            }
        }
        return 5;
    }

    function stake(uint256[] memory tokenIds, bytes32[][] calldata _merkleProofs) public {

        for(uint256 i = 0; i < tokenIds.length; i++) {
            (bool _isStaked,) = getStakingItemInfo(msg.sender, tokenIds[i]);
            if(_isStaked) continue;
            require(IERC721(nftAddress).ownerOf(tokenIds[i]) == msg.sender, "Not your NFT");

            IERC721(nftAddress).transferFrom(address(msg.sender), address(this), tokenIds[i]);

            uint256 _rarity = getRarity(_merkleProofs[i], tokenIds[i]);
            require(_rarity < 5, "Invalid in merkleproof");

            UserInfo memory info;
            info.tokenId = tokenIds[i];
            info.rarity = _rarity;
            info.startTime = block.timestamp;

            userInfo[msg.sender].push(info);
            stakingAmount[msg.sender] = stakingAmount[msg.sender] + 1;
            emit Stake(msg.sender, 1);
        }
    }

    function unstake(uint256[] memory tokenIds) public nonReentrant {

        require(tokenIds.length > 0, "Token number to unstake is zero.");
        uint256 pending = pendingTotalReward(msg.sender);
        if(pending > 0) {
            IERC20(rtoken).transfer(msg.sender, pending);
        }

        for(uint256 i = 0; i < tokenIds.length; i++) {
            (bool _isStaked,) = getStakingItemInfo(msg.sender, tokenIds[i]);
            if(!_isStaked) continue;
            if(IERC721(nftAddress).ownerOf(tokenIds[i]) != address(this)) continue;

            removeFromUserInfo(tokenIds[i]);
            if(stakingAmount[msg.sender] > 0)
                stakingAmount[msg.sender] = stakingAmount[msg.sender] - 1;
            IERC721(nftAddress).transferFrom(address(this), msg.sender, tokenIds[i]);
            emit UnStake(msg.sender, 1);
        }
    }

    function getStakingItemInfo(address _user, uint256 _tokenId) public view returns(bool _isStaked, uint256 _startTime) {

        for(uint256 i = 0; i < userInfo[_user].length; i++) {
            if(userInfo[_user][i].tokenId == _tokenId) {
                _isStaked = true;
                _startTime = userInfo[_user][i].startTime;
                break;
            }
        }
    }

    function removeFromUserInfo(uint256 tokenId) private {        

        for (uint256 i = 0; i < userInfo[msg.sender].length; i++) {
            if (userInfo[msg.sender][i].tokenId == tokenId) {
                userInfo[msg.sender][i] = userInfo[msg.sender][userInfo[msg.sender].length - 1];
                userInfo[msg.sender].pop();
                break;
            }
        }        
    }

    function claim() public {


        uint256 reward = pendingTotalReward(msg.sender);

        for (uint256 i = 0; i < userInfo[msg.sender].length; i++)
            userInfo[msg.sender][i].startTime = block.timestamp;

        IERC20(rtoken).transfer(msg.sender, reward);
    }
}