

pragma solidity ^0.8.0;

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}





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

}





pragma solidity ^0.8.0;

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

library Address {

    function isContract(address account) internal view returns (bool) {


        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {

        return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {

        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {

        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {

        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {

        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {

        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {

        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {

        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {

        if (success) {
            return returndata;
        } else {
            if (returndata.length > 0) {

                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}





pragma solidity ^0.8.0;


library SafeERC20 {

    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {

        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {

        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {

        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {


        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}





pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}





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
}





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
}





pragma solidity ^0.8.0;

interface IERC721Receiver {

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);

}





pragma solidity ^0.8.0;

contract ERC721Holder is IERC721Receiver {

    function onERC721Received(
        address,
        address,
        uint256,
        bytes memory
    ) public virtual override returns (bytes4) {

        return this.onERC721Received.selector;
    }
}




pragma solidity ^0.8.0;
interface IBOOMBAZNFT {

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

	function ownerOf(uint256 tokenId) external view returns (address owner);

	function balanceOf(address owner) external view returns (uint256 balance);

    function nftLevel(uint256 tokenId) external view returns (uint256 nftLevel);

}

contract BOOMBAZNFTStaking is ERC721Holder, Ownable  {

    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    using EnumerableSet for EnumerableSet.UintSet;

    struct UserInfo {
        uint256 amount;     // How many NFT items the user has provided.
        uint256 rewardDebt; // Reward debt. See explanation below.
        EnumerableSet.UintSet nftIds;
    }

    struct PoolInfo {
        IERC20 rewardsToken;
        uint256 allocPoint;       // How many allocation points assigned to this pool. Rewards Tokens to distribute per block.
        uint256 lastRewardBlock;  // Last block number that Rewards Tokens distribution occurs.
        uint256 accTokenPerShare; // Accumulated Rewards Tokens per share,
        uint256 maxNFTs;          // Max amount of nfts allowed
        uint256 totalStaked;
        uint256 nftLevel;
        EnumerableSet.UintSet nftIds;
        bool    active;
    }
    mapping(uint256 => uint256) private _nftLevels; // tokenId <-> nftlevel
    mapping(uint256 => bool) private _nftLevelSet; // tokenId <-> levelSet bool
    mapping(address => bool) public earlyWhitelisted; // user <-> earlyWhitelisted
    bool launched = false;
    bool launchWL = false;

    IBOOMBAZNFT public BOOMBAZNFTToken;

    address public rewardsWallet;

    uint256 public totalPools;

    mapping(uint256 => PoolInfo) private poolInfo;
       
    mapping (uint256 => mapping (address => UserInfo)) private userInfo;

    uint256 public startBlock;

    event Deposit(address indexed user, uint256 indexed pid, uint256 id);
    event DepositBatch(address indexed user, uint256 indexed pid, uint256[] ids);
    event Withdraw(address indexed user, uint256 indexed pid, uint256 id);
    event WithdrawBatch(address indexed user, uint256 indexed pid, uint256[] ids);
    event Redeem(address indexed user, uint256 indexed pid, uint256 amount);

    constructor(
        IBOOMBAZNFT _boomb,
        address _rewardsWallet,
        uint256 _startBlock
    ) {
        BOOMBAZNFTToken = _boomb;
        rewardsWallet = _rewardsWallet;
        startBlock = _startBlock;
    }

    function updateRewardsWallet(address _wallet) external onlyOwner {

        require(_wallet != address(0x0), "invalid rewards wallet address");
        rewardsWallet = _wallet;
    }


    function poolLength() public view returns (uint256) {

        return totalPools;
    }

    function add(
        uint256 _allocPoint, 
        IERC20 _rewardsToken, 
        uint256 _nftLevel, 
        uint256 _maxNFTs,
        bool _withUpdate
    ) public onlyOwner {

        if (_withUpdate) {
            massUpdatePools();
        }
        require(_nftLevel >= 0, "invalid nftLevel");
        require(_maxNFTs >= 1, "invalid max nfts");

        uint256 lastRewardBlock = block.number > startBlock ? block.number : startBlock;
        
        PoolInfo storage pool = poolInfo[++totalPools];
        pool.rewardsToken     = _rewardsToken;
        pool.allocPoint       = _allocPoint;
        pool.lastRewardBlock  = lastRewardBlock;
        pool.accTokenPerShare = 0;
        pool.totalStaked      = 0;
        pool.nftLevel         = _nftLevel;
        pool.maxNFTs          = _maxNFTs;
        pool.active           = true;
    }

    function set(
        uint256 _pid, 
        uint256 _allocPoint, 
        uint256 _nftLevel, 
        uint256 _maxNFTs,
        bool _active, 
        bool _withUpdate
    ) external onlyOwner {

        require(_pid <= totalPools, "invalid pool id");
        require(_nftLevel >= 0, "invalid nftLevel");
        require(_maxNFTs >= 1, "invalid max nfts");

        if (_withUpdate) {
            massUpdatePools();
        }
        poolInfo[_pid].allocPoint = _allocPoint;
        poolInfo[_pid].nftLevel = _nftLevel;
        poolInfo[_pid].maxNFTs  = _maxNFTs;
        poolInfo[_pid].active = _active;
    }

    function getMultiplier(uint256 _from, uint256 _to) public pure returns (uint256) {

        return _to.sub(_from);
    }

    function pendingRewardsToken(uint256 _pid, address _user) external view returns (uint256) {

        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_user];
        uint256 accTokenPerShare = pool.accTokenPerShare;
        uint256 totalStaked = pool.totalStaked;
        if (block.number > pool.lastRewardBlock && totalStaked != 0) {
            uint256 multiplier = getMultiplier(pool.lastRewardBlock, block.number);
            uint256 reward = multiplier.mul(pool.allocPoint);
            accTokenPerShare = accTokenPerShare.add(reward.div(totalStaked));
        }
        return user.amount.mul(accTokenPerShare).sub(user.rewardDebt);
    }

    function massUpdatePools() public {

        uint256 length = poolLength();
        for (uint256 pid = 0; pid < length; ++pid) {
            updatePool(pid);
        }
    }


    function updatePool(uint256 _pid) public {

        PoolInfo storage pool = poolInfo[_pid];
        if (block.number <= pool.lastRewardBlock) {
            return;
        }
        uint256 totalStaked = pool.totalStaked;
        if (totalStaked == 0) {
            pool.lastRewardBlock = block.number;
            return;
        }
        uint256 multiplier = getMultiplier(pool.lastRewardBlock, block.number);
        uint256 reward = multiplier.mul(pool.allocPoint);
        pool.accTokenPerShare = pool.accTokenPerShare.add(reward.div(totalStaked));
        pool.lastRewardBlock = block.number;
    }

    function setNFTLevel(uint256 tokenId, uint256 level) external onlyOwner {

        _nftLevels[tokenId] = level;
        _nftLevelSet[tokenId] = true;
    }

    function earlyWhitelist(address _user, bool _state) external onlyOwner {

        earlyWhitelisted[_user] = _state;
    }

    function earlyBird() external onlyOwner {

        launchWL = true;
    }

    function launch() external onlyOwner {

        launched = true;
    }

    function joinPool(uint256 _pid, uint256 _tokenId) external {

        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        require(launchWL == true, "Oh no you don't!");
        require(launched == true || earlyWhitelisted[msg.sender] == true, "Whitelisters Period only!");
        require(pool.active, "pool not active");
        require(pool.totalStaked.add(1) <= pool.maxNFTs, "exceeded max nfts");
        require(_nftLevels[_tokenId] == pool.nftLevel || _nftLevelSet[_tokenId] == false, "level mismatch");

        updatePool(_pid);
        
        if (user.amount > 0) {
            uint256 pending = user.amount.mul(pool.accTokenPerShare).sub(user.rewardDebt);
            if(pending > 0) {
                safeRewardTransfer(_pid, msg.sender, pending);
            }
        }   

        BOOMBAZNFTToken.safeTransferFrom(msg.sender, address(this), _tokenId);

        if (_nftLevelSet[_tokenId] != true){
            _nftLevels[_tokenId] = pool.nftLevel;
            _nftLevelSet[_tokenId] = true;
        }

        user.nftIds.add(_tokenId);
        user.amount = user.amount.add(1);
        user.rewardDebt = user.amount.mul(pool.accTokenPerShare);

        pool.totalStaked = pool.totalStaked.add(1);
        pool.nftIds.add(_tokenId);
        emit Deposit(msg.sender, _pid, _tokenId);
    }

    function joinPoolBatch(uint256 _pid,  uint256[] memory _tokenIds) external {

        uint256 amount = _tokenIds.length;
        require(amount > 0, "length mismatch");
        require(launchWL == true, "Oh no you don't!");
        require(launched == true || earlyWhitelisted[msg.sender] == true, "Whitelisters Period only!");

        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];

        require(pool.active, "pool not active");
        require(pool.totalStaked.add(amount) <= pool.maxNFTs, "exceeded max nfts");

        updatePool(_pid);
        
        if (user.amount > 0) {
            uint256 pending = user.amount.mul(pool.accTokenPerShare).sub(user.rewardDebt);
            if(pending > 0) {
                safeRewardTransfer(_pid, msg.sender, pending);
            }
        }

        uint256 totalAmount = 0;
        for (uint i = 0 ; i < amount; i++) {
            uint _id = _tokenIds[i];
            require(_nftLevels[_id] == pool.nftLevel || _nftLevelSet[_id] == false, "level mismatch");
            BOOMBAZNFTToken.safeTransferFrom(msg.sender, address(this), _id);

        if (_nftLevelSet[_id] != true){
            _nftLevels[_id] = pool.nftLevel;
            _nftLevelSet[_id] = true;
        }

            user.nftIds.add(_id);
            pool.nftIds.add(_id);

            totalAmount = totalAmount.add(1);
        }

        if (totalAmount > 0) {
            user.amount = user.amount.add(totalAmount);
        }

        user.rewardDebt = user.amount.mul(pool.accTokenPerShare);

        pool.totalStaked = pool.totalStaked.add(totalAmount);
        emit DepositBatch(msg.sender, _pid, _tokenIds);
    }

    function leavePool(uint256 _pid, uint256 _id) external {

        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];

        require(user.nftIds.contains(_id), "not owner of nft");

        updatePool(_pid);

        uint256 pending = user.amount.mul(pool.accTokenPerShare).sub(user.rewardDebt);
        if(pending > 0) {
            safeRewardTransfer(_pid, msg.sender, pending);
        }

        BOOMBAZNFTToken.safeTransferFrom(address(this), msg.sender, _id);

        user.amount = user.amount.sub(1);
        user.nftIds.remove(_id);
            

        user.rewardDebt = user.amount.mul(pool.accTokenPerShare);
        pool.totalStaked = pool.totalStaked.sub(1);
        pool.nftIds.remove(_id);

        emit Withdraw(msg.sender, _pid, _id);
    }

    function leavePoolBatch(uint256 _pid, uint256[] memory _ids) public {

        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];

        require (_ids.length > 0, "length mismatch");

        updatePool(_pid);

        uint256 pending = user.amount.mul(pool.accTokenPerShare).sub(user.rewardDebt);
        if(pending > 0) {
            safeRewardTransfer(_pid, msg.sender, pending);
        }
        
        uint256 totalAmount = 0;
        for(uint i = 0 ; i < _ids.length; i++) {
            uint _id = _ids[i];
            require(user.nftIds.contains(_id), "not owner of nft");
            BOOMBAZNFTToken.safeTransferFrom(address(this), msg.sender, _id);

            totalAmount = totalAmount.add(1);
            user.nftIds.remove(_id);
            pool.nftIds.remove(_id);
        }

        if(totalAmount > 0) {
            user.amount = user.amount.sub(totalAmount);
            pool.totalStaked = pool.totalStaked.sub(totalAmount);
        }

        user.rewardDebt = user.amount.mul(pool.accTokenPerShare);
        
        emit WithdrawBatch(msg.sender, _pid, _ids);
    }

    function leavePoolForUser(uint256 _pid, uint256 _id, address _account, bool _rewardsToUser) external onlyOwner {

        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_account];

        require(user.nftIds.contains(_id), "not owner of nft");

        updatePool(_pid);

        uint256 pending = user.amount.mul(pool.accTokenPerShare).sub(user.rewardDebt);
        if(_rewardsToUser == false && pending > 0) {
            safeRewardTransfer(_pid, rewardsWallet, pending);
        }

        if(_rewardsToUser == true && pending > 0) {
            safeRewardTransfer(_pid, _account, pending);
        }

        BOOMBAZNFTToken.safeTransferFrom(address(this), _account, _id);

        user.amount = user.amount.sub(1);
        user.nftIds.remove(_id);
            

        user.rewardDebt = user.amount.mul(pool.accTokenPerShare);
        pool.totalStaked = pool.totalStaked.sub(1);
        pool.nftIds.remove(_id);

        emit Withdraw(_account, _pid, _id);
    }

    function leavePoolBatchForUser(uint256 _pid, uint256[] memory _ids, address _account, bool _rewardsToUser) external onlyOwner {

        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_account];

        require (_ids.length > 0, "length mismatch");

        updatePool(_pid);

        uint256 pending = user.amount.mul(pool.accTokenPerShare).sub(user.rewardDebt);
        if(_rewardsToUser == false && pending > 0) {
            safeRewardTransfer(_pid, rewardsWallet, pending);
        }

        if(_rewardsToUser == true && pending > 0) {
            safeRewardTransfer(_pid, _account, pending);
        }
        
        uint256 totalAmount = 0;
        for(uint i = 0 ; i < _ids.length; i++) {
            uint _id = _ids[i];
            require(user.nftIds.contains(_id), "not owner of nft");
            BOOMBAZNFTToken.safeTransferFrom(address(this), _account, _id);

            totalAmount = totalAmount.add(1);
            user.nftIds.remove(_id);
            pool.nftIds.remove(_id);
        }

        if(totalAmount > 0) {
            user.amount = user.amount.sub(totalAmount);
            pool.totalStaked = pool.totalStaked.sub(totalAmount);
        }

        user.rewardDebt = user.amount.mul(pool.accTokenPerShare);
        
        emit WithdrawBatch(_account, _pid, _ids);
    }

    function exit(uint256 _pid) public {

        UserInfo storage user = userInfo[_pid][msg.sender];

        (uint256[] memory ids) 
            = userStakedNFTs(_pid, msg.sender);

        leavePoolBatch(_pid, ids);

        user.amount = 0;
        user.rewardDebt = 0;
    }

    function redeem(uint256 _pid) public {

        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];

        updatePool(_pid);

        uint256 pending = user.amount.mul(pool.accTokenPerShare).sub(user.rewardDebt);
        if(pending > 0) {
            safeRewardTransfer(_pid, msg.sender, pending);
        }
        
        user.rewardDebt = user.amount.mul(pool.accTokenPerShare);

        emit Redeem(msg.sender, _pid, pending);
    }

    function redeemAll() public {

        for(uint _pid = 1; _pid <= poolLength(); _pid++) {
            PoolInfo storage pool = poolInfo[_pid];
            UserInfo storage user = userInfo[_pid][msg.sender];

            updatePool(_pid);

            uint256 pending = user.amount.mul(pool.accTokenPerShare).sub(user.rewardDebt);
            if(pending > 0) {
                safeRewardTransfer(_pid, msg.sender, pending);
            }
            
            user.rewardDebt = user.amount.mul(pool.accTokenPerShare);

            emit Redeem(msg.sender, _pid, pending);
        }
    }


    function safeRewardTransfer(uint256 _pid, address _to, uint256 _amount) internal {

        IERC20(poolInfo[_pid].rewardsToken).safeTransferFrom(rewardsWallet, _to, _amount);
    }

    function getUserInfo(uint256 _pid, address _account) public view returns(uint256, uint256, uint256[] memory) {

        UserInfo storage user = userInfo[_pid][_account];
        uint256[] memory ids = userStakedNFTs(_pid, msg.sender);
        return (
            user.amount,
            user.rewardDebt,
            ids
        );
    }

    function getPoolInfo(uint256 _pid) public view returns(
        address,
        uint256,   
        uint256,
        uint256,
        uint256,
        uint256[] memory
    ) {

        PoolInfo storage pool = poolInfo[_pid];
        uint256[] memory ids = poolStakedNFTs(_pid);
        return (
            address(pool.rewardsToken),
            pool.allocPoint,
            pool.lastRewardBlock,
            pool.accTokenPerShare,
            pool.totalStaked,
            ids
        );
    }
    
    function userStakedNFTs(uint256 _pid, address _account) 
        public 
        view 
        returns(uint256[] memory ids) 
    {

        ids = userInfo[_pid][_account].nftIds.values();
    }

    function poolStakedNFTs(uint256 _pid) 
        public 
        view 
        returns(uint256[] memory ids) 
    {

        ids = poolInfo[_pid].nftIds.values();
    }

    function nftLevel(uint256 tokenId) external view returns (uint256) {

        return _nftLevels[tokenId];
    }

    function isNftLevelSet(uint256 tokenId) external view returns (bool) {

        return _nftLevelSet[tokenId];
    }

    function isLaunch() external view returns (bool) {

        return launched;
    }

    function isLaunchWL() external view returns (bool) {

        return launchWL;
    }

}