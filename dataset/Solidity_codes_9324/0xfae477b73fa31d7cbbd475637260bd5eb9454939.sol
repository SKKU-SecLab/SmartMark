
pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}


abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _setOwner(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}


pragma solidity ^0.8.0;


library SafeMath {

    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        return a + b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        return a * b;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        return a % b;
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}


pragma solidity ^0.8.0;

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}


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

}


interface IERC721Enumerable is IERC721 {

    function totalSupply() external view returns (uint256);


    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256 tokenId);


    function tokenByIndex(uint256 index) external view returns (uint256);

}


interface IERC721Receiver {

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);

}


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
}


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
}


library Math {

    function max(uint256 a, uint256 b) internal pure returns (uint256) {

        return a >= b ? a : b;
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {

        return a < b ? a : b;
    }

    function average(uint256 a, uint256 b) internal pure returns (uint256) {

        return (a & b) + (a ^ b) / 2;
    }

    function ceilDiv(uint256 a, uint256 b) internal pure returns (uint256) {

        return a / b + (a % b == 0 ? 0 : 1);
    }
}


abstract contract Pausable is Context {
    event Paused(address account);

    event Unpaused(address account);

    bool private _paused;

    constructor() {
        _paused = false;
    }

    function paused() public view virtual returns (bool) {
        return _paused;
    }

    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
        _;
    }

    modifier whenPaused() {
        require(paused(), "Pausable: not paused");
        _;
    }

    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}


interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}


contract LostStaking is Ownable, IERC721Receiver, ReentrancyGuard, Pausable {

    using EnumerableSet for EnumerableSet.UintSet; 
    
    address nullAddress = 0x0000000000000000000000000000000000000000;
    address public stakingDestinationAddress;
    address public stakingLostGirlAddr;
    address public erc20Address;
    address public ownerAddr;

    uint256 public expiration;
  
    mapping(address => EnumerableSet.UintSet) _deposits;
    mapping(address => mapping(uint256 => uint256)) _depositBlocks;
    mapping(address => mapping(uint256 => uint256)) _depositBlocksTmp;
    mapping(address => mapping(uint256 => uint256)) _depositRarity;
    mapping(uint256 => uint256) _rewardArray;
    mapping(uint256 => uint256) _rewardRarity;

    constructor(
      address _stakingDestinationAddress, // Nft Contract Address
      address _stakingLostGirlAddress, //nft Contract girl
      uint256 _expiration,  //in days
      address _erc20Address, // Token address
      uint256[] memory rewardArray,
      uint256[] memory rewardRarity
    ) {
        stakingLostGirlAddr = _stakingLostGirlAddress;
        stakingDestinationAddress = _stakingDestinationAddress;
        expiration = block.timestamp * (_expiration * 1 days);
        erc20Address = _erc20Address;
        ownerAddr = msg.sender;
        
        for (uint256 i; i < rewardArray.length; i++) {
            _rewardArray[i] = rewardArray[i];
        }

        for (uint256 i; i < rewardRarity.length; i++) {
            _rewardRarity[i] = rewardRarity[i];
        }
        
        _pause();
    }

    modifier isExpired() {

        require(0 < ((expiration - block.timestamp) / 60 / 60 / 24), "Close Staking");
        _;
    }

    function pause() external onlyOwner {

        _pause();
    }

    function unpause() external onlyOwner {

        _unpause();
    }


    function updateReward(uint256[] memory _updateReward) external onlyOwner() {

        for (uint256 i; i < _updateReward.length; i++) {
            _rewardArray[i] = _updateReward[i];
        }
    }

    function updateRarity(uint256[] memory _updateRarity) external onlyOwner() {

        for (uint256 i; i < _updateRarity.length; i++) {
            _rewardRarity[i] = _updateRarity[i];
        }
    }

    function setExpiration(uint256 _expiration) external onlyOwner() {

        expiration = block.timestamp * (_expiration * 1 days);
    }

    function balanceOfLostGirl(address account, uint256 tokens) external view returns (uint256 balance) {

        uint256 balanceOfd = IERC721(stakingLostGirlAddr).balanceOf(account);
        
        if(balanceOfd > 0 && balanceOfd <= 3){
            return (tokens*_rewardArray[0]);
        }else if(balanceOfd >= 4 && balanceOfd <= 6){
            return (tokens*_rewardArray[1]);
        }else if(balanceOfd >= 7 && balanceOfd <= 9){
            return (tokens*_rewardArray[2]);
        }else if(balanceOfd >= 10 && balanceOfd <= 15){
            return (tokens*_rewardArray[3]);
        }else if(balanceOfd > 15){
            return (tokens*_rewardArray[4]);
        }
        return (tokens*100);
    }

    function depositsOf(address account) external view returns (uint256[] memory) {

      EnumerableSet.UintSet storage depositSet = _deposits[account];
      uint256[] memory tokenIds = new uint256[] (depositSet.length());

      for (uint256 i; i < depositSet.length(); i++) {
        tokenIds[i] = depositSet.at(i);
      }
      return tokenIds;
    }

    function calculateRewards(address account, uint256[] memory tokenIds) external view returns (uint256[] memory rewards) 
    {

      rewards = new uint256[](tokenIds.length);

      for (uint256 i; i < tokenIds.length; i++) {

            uint256 tokenId = tokenIds[i];
        
            if(_deposits[account].contains(tokenId)){
                uint256 diff = (block.timestamp - _depositBlocks[account][tokenId]) / 60 / 60 / 24;
                uint256 tokenCount = _rewardRarity[_depositRarity[account][tokenId]] * diff;
                rewards[i] = this.balanceOfLostGirl(account, tokenCount);
            }else{
                rewards[i] = 0;
            }
        
      }

      return rewards;
    }

    function calculateReward(address account, uint256 tokenId) public view isExpired returns (uint256) {

        uint256 diff = (block.timestamp - _depositBlocks[account][tokenId]) / 60 / 60 / 24;
        uint256 totalToken = (_rewardRarity[_depositRarity[account][tokenId]] * ((_deposits[account].contains(tokenId) ? 1 : 0) * diff));
        return this.balanceOfLostGirl(account, totalToken);
    }

    function claimRewards(uint256[] calldata tokenIds) public whenNotPaused {

        uint256 reward; 
        uint256 blockCur = block.timestamp;

        for (uint256 i; i < tokenIds.length; i++) {
            reward += calculateReward(msg.sender, tokenIds[i]);

            _depositBlocks[msg.sender][tokenIds[i]] = blockCur;
        }
        
        if (reward > 0) {
            IERC20(erc20Address).transferFrom(ownerAddr, msg.sender, (((reward * 10**18)/100)/100));
        } 
    }

    function deposit(uint256[] calldata tokenIds, uint256[] calldata _rarity) external whenNotPaused {

        require(msg.sender != stakingDestinationAddress, "Invalid address");
        claimRewards(tokenIds);

        for (uint256 i; i < tokenIds.length; i++) {
            uint256 blockCur1 = block.timestamp;
            _depositBlocksTmp[msg.sender][tokenIds[i]] = blockCur1;
            _depositRarity[msg.sender][tokenIds[i]] = _rarity[i];
            
            IERC721(stakingDestinationAddress).safeTransferFrom(
                msg.sender,
                address(this),
                tokenIds[i],
                ""
            );

            _deposits[msg.sender].add(tokenIds[i]);
        }
    }

    function withdraw(uint256[] calldata tokenIds) external whenNotPaused nonReentrant() {

        claimRewards(tokenIds);

        for (uint256 i; i < tokenIds.length; i++) {
            require( _deposits[msg.sender].contains(tokenIds[i]), "Staking: token not deposited");
            uint256 diff = (block.timestamp - _depositBlocksTmp[msg.sender][tokenIds[i]]) / 60 / 60 / 24;
        
            _deposits[msg.sender].remove(tokenIds[i]);

            IERC721(stakingDestinationAddress).safeTransferFrom(
                address(this),
                msg.sender,
                tokenIds[i],
                ""
            );
        }
    }
 
    function onERC721Received(
        address,
        address,
        uint256,
        bytes calldata
    ) external pure override returns (bytes4) {

        return IERC721Receiver.onERC721Received.selector;
    }
}