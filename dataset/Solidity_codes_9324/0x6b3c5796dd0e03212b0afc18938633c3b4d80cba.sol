
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
}// MIT

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
}// MIT

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
}// MIT

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
}// MIT

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


interface IERC1155 is IERC165 {

    event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value);

    event TransferBatch(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256[] ids,
        uint256[] values
    );

    event ApprovalForAll(address indexed account, address indexed operator, bool approved);

    event URI(string value, uint256 indexed id);

    function balanceOf(address account, uint256 id) external view returns (uint256);


    function balanceOfBatch(address[] calldata accounts, uint256[] calldata ids)
        external
        view
        returns (uint256[] memory);


    function setApprovalForAll(address operator, bool approved) external;


    function isApprovedForAll(address account, address operator) external view returns (bool);


    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes calldata data
    ) external;


    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] calldata ids,
        uint256[] calldata amounts,
        bytes calldata data
    ) external;

}// MIT
pragma solidity 0.8.10;

struct User {
    uint256 tokenAmount;
    uint256 rewardAmount;
    uint256 totalWeight;
    uint256 subYieldRewards;
    Deposit[] deposits;
}

struct Deposit {
    uint256 tokenAmount;
    uint256 weight;
    uint64 lockedFrom;
    uint64 lockedUntil;
    bool isYield;
}

interface IPool {

    
    function CART() external view returns (address);


    function poolToken() external view returns (address);


    function isFlashPool() external view returns (bool);


    function weight() external view returns (uint256);


    function lastYieldDistribution() external view returns (uint256);


    function yieldRewardsPerWeight() external view returns (uint256);


    function usersLockingWeight() external view returns (uint256);


    function weightMultiplier() external view returns (uint256);


    function balanceOf(address _user) external view returns (uint256);


    function getDepositsLength(address _user) external view returns (uint256);


    function getOriginDeposit(address _user, uint256 _depositId) external view returns (Deposit memory);


    function getUser(address _user) external view returns (User memory);


    function stake(
        uint256 _amount,
        uint64 _lockedUntil,
        address _nftAddress,
        uint256 _nftTokenId
    ) external;


    function unstake(
        uint256 _depositId,
        uint256 _amount
    ) external;


    function sync() external;


    function processRewards() external;


    function setWeight(uint256 _weight) external;


    function NFTWeightUpdated(address _nftAddress, uint256 _nftWeight) external;


    function setWeightMultiplierbyFactory(uint256 _newWeightMultiplier) external;


    function getNFTWeight(address _nftAddress) external view returns (uint256);


    function weightToReward(uint256 _weight, uint256 rewardPerWeight) external pure returns (uint256);


    function rewardToWeight(uint256 reward, uint256 rewardPerWeight) external pure returns (uint256);


}// MIT

pragma solidity 0.8.10;


interface ICorePool is IPool {


    function poolTokenReserve() external view returns (uint256);


    function stakeAsPool(address _staker, uint256 _amount) external;

}// MIT
pragma solidity 0.8.10;


interface ITokenRecipient {

  function tokensReceived(
      address from,
      uint amount,
      bytes calldata exData
  ) external returns (bool);

}// MIT
pragma solidity 0.8.10;

interface IFactory {


    struct PoolData {
        address poolToken;
        address poolAddress;
        uint256 weight;
        bool isFlashPool;
    }

    function FACTORY_UID() external view returns (uint256);


    function CART() external view returns (address);


    function cartPerBlock() external view returns (uint256);

    
    function totalWeight() external view returns (uint256);


    function endBlock() external view returns (uint256);


    function getPoolData(address _poolToken) external view returns (PoolData memory);


    function getPoolAddress(address poolToken) external view returns (address);


    function isPoolExists(address _pool) external view returns (bool);

    
    function mintYieldTo(address _to, uint256 _amount) external;

}// MIT
pragma solidity 0.8.10;


abstract contract CartPoolBase is IPool, ReentrancyGuard, ITokenRecipient {
    
    address public immutable override CART;

    mapping(address => User) public users;

    address public immutable factory;

    address public immutable override poolToken;

    uint256 public override weight;

    uint256 public override lastYieldDistribution;

    uint256 public override yieldRewardsPerWeight;

    uint256 public override usersLockingWeight;

    mapping(address => uint256) public supportNTF;

    uint256 public weightMultiplier;

    uint256 internal constant REWARD_PER_WEIGHT_MULTIPLIER = 1e48;

    uint256 internal constant DEPOSIT_BATCH_SIZE  = 20;

    event Staked(address indexed _by, address indexed _from, uint256 amount);


    event Unstaked(address indexed _by, address indexed _to, uint256 amount);

    event Synchronized(address indexed _by, uint256 yieldRewardsPerWeight, uint256 lastYieldDistribution);

    event YieldClaimed(address indexed _by, address indexed _to, uint256 amount);

    event PoolWeightUpdated(uint256 _fromVal, uint256 _toVal);

    event EmergencyWithdraw(address indexed _by, uint256 amount);

    constructor(
        address _cart,
        address _factory,
        address _poolToken,
        uint256 _weight
    ) {
        require(_cart != address(0), "cart token address not set");
        require(_factory != address(0), "CART Pool fct address not set");
        require(_poolToken != address(0), "pool token address not set");
        require(_weight > 0, "pool weight not set");

        require(
            IFactory(_factory).FACTORY_UID() == 0xb77099a6d99df5887a6108e413b3c6dfe0c11a1583c9d9b3cd08bfb8ca996aef,
            "unexpected FACTORY_UID"
        );

        CART = _cart;
        factory = _factory;
        poolToken = _poolToken;
        weight = _weight;
        weightMultiplier = 1e24;
    }

    function balanceOf(address _user) external view override returns (uint256) {
        return users[_user].tokenAmount;
    }

    function getOriginDeposit(address _user, uint256 _depositId) external view override returns (Deposit memory) {
        return users[_user].deposits[_depositId];
    } 

    function getDepositsLength(address _user) external view override returns (uint256) {
        return users[_user].deposits.length;
    }
    
    function getNFTWeight(address _nftAddress) external view returns (uint256) {
        return supportNTF[_nftAddress];
    }

    function getUser(address _user) external view returns (User memory) {
        return users[_user];
    }

    function tokensReceived(address _staker, uint _amount, bytes calldata _data) external override nonReentrant returns (bool) {
        require(msg.sender == CART, "must from cart");
        require(_data.length == 60, "length of bytes error");

        uint64 _lockPeriod = uint64(toUint(_data, 0));
        address _nftAddress = address(toBytes20(_data, 20));
        uint _nftTokenId = toUint(_data, 40);
    
        _stake(_staker, _amount, _lockPeriod, _nftAddress, _nftTokenId);
        return true;
    }
    
    function toBytes20(bytes memory _b, uint _offset) private pure returns (bytes20) {
        bytes20 out;
        for (uint i = 0; i < 20; i++) {
        out |= bytes20(_b[_offset + i] & 0xFF) >> (i * 8);
        }
        return out;
    }

    function toUint(bytes memory _b, uint _offset) private pure returns (uint) {
        uint out;
        for(uint i = 0; i < 20; i++){
        out = out + uint8(_b[_offset + i])*(2**(8*(20-(i+1))));
        }
        return out;
    }

    function stake (
        uint256 _amount,
        uint64 _lockPeriod,
        address _nftAddress,
        uint256 _nftTokenId
    ) external override nonReentrant {
        transferPoolTokenFrom(msg.sender, address(this), _amount);
        _stake(msg.sender, _amount, _lockPeriod, _nftAddress, _nftTokenId);
    }

    function unstake(
        uint256 _depositId,
        uint256 _amount
    ) external override nonReentrant {
        _unstake(msg.sender, _depositId, _amount);
    }

    function sync() external override {
        _sync();
    }

    function processRewards() external virtual override nonReentrant {
        _processRewards(msg.sender, true);
    }

    function setWeight(uint256 _weight) external override {
        require(msg.sender == factory, "access denied");

        emit PoolWeightUpdated(weight, _weight);

        weight = _weight;
    }

    function NFTWeightUpdated(address _nftAddress, uint256 _nftWeight) external {
        require(msg.sender == factory, "access denied");
        supportNTF[_nftAddress] = _nftWeight;
    }

    function setWeightMultiplierbyFactory(uint256 _newWeightMultiplier) external {
        require(msg.sender == factory, "access denied");
        weightMultiplier = _newWeightMultiplier;
    }

    function _pendingYieldRewards(address _staker) internal view returns (uint256 pending) {
        User memory user = users[_staker];

        return weightToReward(user.totalWeight, yieldRewardsPerWeight) - user.subYieldRewards;
    }

    function _stake(
        address _staker,
        uint256 _amount,
        uint64 _lockPeriod,
        address _nftAddress,
        uint256 _nftTokenId
    ) internal virtual {

        require(_amount > 0, "zero amount");
        require(_lockPeriod == 0 || _lockPeriod <= 365 days,"invalid lock interval");
 
        _sync();

        User storage user = users[_staker];
        if (user.tokenAmount > 0) {
            _processRewards(_staker, false);
        }

        if (user.deposits.length == 0) {
            Deposit memory unlockedDeposit =
                Deposit({
                    tokenAmount: 0,
                    weight: 0,
                    lockedFrom: 0,
                    lockedUntil: 0,
                    isYield: false
                });
            user.deposits.push(unlockedDeposit);
        }

        uint64 lockFrom = uint64(now256());
        uint64 lockPeriod = _lockPeriod;

        uint256 stakeWeight = ((lockPeriod * weightMultiplier) / 365 days + weightMultiplier) * _amount;

        require(stakeWeight > 0, "invalid stakeWeight");    

        if (lockPeriod == 0) {
            uint nft_weight = 0;
            if (_nftTokenId != 0 && _nftAddress != address(0) ) {
                require(IERC721(_nftAddress).ownerOf(_nftTokenId) == msg.sender, "the NFT tokenId doesn't match the user");
                nft_weight = supportNTF[_nftAddress];
            }
            
            uint256 oldStakeWeight = user.deposits[0].weight;
            uint256 newStakeWeight = oldStakeWeight + _amount * weightMultiplier + nft_weight * weightMultiplier;
            user.deposits[0].tokenAmount += _amount;
            user.deposits[0].weight = newStakeWeight;
            user.deposits[0].lockedFrom = 0;

            user.tokenAmount += _amount;
            user.totalWeight = (user.totalWeight - oldStakeWeight + newStakeWeight);
            user.subYieldRewards = weightToReward(user.totalWeight, yieldRewardsPerWeight);

            usersLockingWeight = (usersLockingWeight - oldStakeWeight + newStakeWeight);
        } else {
            Deposit memory deposit =
                Deposit({
                    tokenAmount: _amount,
                    weight: stakeWeight,
                    lockedFrom: lockFrom,
                    lockedUntil: lockFrom + lockPeriod,
                    isYield: false
                });
            user.deposits.push(deposit);

            user.tokenAmount += _amount;
            user.totalWeight += stakeWeight;
            user.subYieldRewards = weightToReward(user.totalWeight, yieldRewardsPerWeight);

            usersLockingWeight += stakeWeight;
        }

        emit Staked(msg.sender, _staker, _amount);
    }

    function _unstake(
        address _staker,
        uint256 _depositId,
        uint256 _amount
    ) internal virtual {
        require(_amount > 0, "zero amount");

        User storage user = users[_staker];
        Deposit storage stakeDeposit = user.deposits[_depositId];
        bool isYield = stakeDeposit.isYield;

        require(stakeDeposit.tokenAmount >= _amount, "amount exceeds stake");

        _sync();
        _processRewards(_staker, false);

        uint256 previousWeight = stakeDeposit.weight;
        uint256 newWeight =
            (((stakeDeposit.lockedUntil - stakeDeposit.lockedFrom) * weightMultiplier) /
                365 days +
                weightMultiplier) * (stakeDeposit.tokenAmount - _amount);

        if (stakeDeposit.tokenAmount == _amount) {
            delete user.deposits[_depositId];
        } else {
            stakeDeposit.tokenAmount -= _amount;
            stakeDeposit.weight = newWeight;
        }

        user.tokenAmount -= _amount;
        user.totalWeight = user.totalWeight - previousWeight + newWeight;
        user.subYieldRewards = weightToReward(user.totalWeight, yieldRewardsPerWeight);

        usersLockingWeight = usersLockingWeight - previousWeight + newWeight;

        if (isYield) {
            user.rewardAmount -= _amount;
            IFactory(factory).mintYieldTo(msg.sender, _amount);
        } else {
            transferPoolToken(msg.sender, _amount);
        }

        emit Unstaked(msg.sender, _staker, _amount);
    }

    function emergencyWithdraw() external nonReentrant {
        require(IFactory(factory).totalWeight() == 0, "totalWeight != 0");

        _emergencyWithdraw(msg.sender);
    }

    function _emergencyWithdraw(
        address _staker
    ) internal virtual {
        User storage user = users[_staker];

        uint256 totalWeight = user.totalWeight ;
        uint256 amount = user.tokenAmount;
        uint256 reward = user.rewardAmount;

        user.tokenAmount = 0;
        user.rewardAmount = 0;
        user.totalWeight = 0;
        user.subYieldRewards = 0;

        delete user.deposits;

        usersLockingWeight = usersLockingWeight - totalWeight;

        transferPoolToken(msg.sender, amount - reward);
        IFactory(factory).mintYieldTo(msg.sender, reward);

        emit EmergencyWithdraw(msg.sender, amount);
    }

    function _sync() internal virtual {

        if (lastYieldDistribution == 0) {
            lastYieldDistribution = blockNumber();
        }
        uint256 endBlock = IFactory(factory).endBlock();
        if (lastYieldDistribution >= endBlock) {
            return;
        }
        if (blockNumber() <= lastYieldDistribution) {
            return;
        }
        if (usersLockingWeight == 0) {
            lastYieldDistribution = blockNumber();
            return;
        }

        uint256 currentBlock = blockNumber() > endBlock ? endBlock : blockNumber();
        uint256 blocksPassed = currentBlock - lastYieldDistribution;
        uint256 cartPerBlock = IFactory(factory).cartPerBlock();

        uint256 cartReward = (blocksPassed * cartPerBlock * weight) / IFactory(factory).totalWeight();

        yieldRewardsPerWeight += rewardToWeight(cartReward, usersLockingWeight);
        lastYieldDistribution = currentBlock;

        emit Synchronized(msg.sender, yieldRewardsPerWeight, lastYieldDistribution);
    }

    function _processRewards(
        address _staker,
        bool _withUpdate
    ) internal virtual returns (uint256 pendingYield) {
        if (_withUpdate) {
            _sync();
        }

        pendingYield = _pendingYieldRewards(_staker);

        if (pendingYield == 0) return 0;

        User storage user = users[_staker];

        if (poolToken == CART) {
            IFactory(factory).mintYieldTo(_staker, pendingYield);
        } else {
            address cartPool = IFactory(factory).getPoolAddress(CART);
            require(cartPool != address(0),"invalid cart pool address");
            ICorePool(cartPool).stakeAsPool(_staker, pendingYield);
        }

        if (_withUpdate) {
            user.subYieldRewards = weightToReward(user.totalWeight, yieldRewardsPerWeight);
        }

        emit YieldClaimed(msg.sender, _staker, pendingYield);
    }


    function weightToReward(uint256 _weight, uint256 rewardPerWeight) public pure returns (uint256) {
        return (_weight * rewardPerWeight) / REWARD_PER_WEIGHT_MULTIPLIER;
    }

    function rewardToWeight(uint256 reward, uint256 rewardPerWeight) public pure returns (uint256) {
        return (reward * REWARD_PER_WEIGHT_MULTIPLIER) / rewardPerWeight;
    }

    function blockNumber() public view virtual returns (uint256) {
        return block.number;
    }

    function now256() public view virtual returns (uint256) {
        return block.timestamp;
    }

    function transferPoolToken(address _to, uint256 _value) internal {
        SafeERC20.safeTransfer(IERC20(poolToken), _to, _value);
    }

    function transferPoolTokenFrom(
        address _from,
        address _to,
        uint256 _value
    ) internal {
        SafeERC20.safeTransferFrom(IERC20(poolToken), _from, _to, _value);
    }
}// MIT

pragma solidity 0.8.10;


contract CartCorePool is CartPoolBase {

    bool public constant override isFlashPool = false;

    uint256 public poolTokenReserve;

    constructor(
        address _cart,
        address _factory,
        address _poolToken,
        uint256 _weight
    ) CartPoolBase(_cart, _factory, _poolToken, _weight) {}

    function processRewards() external override nonReentrant{

        _processRewards(msg.sender, true);
        User storage user = users[msg.sender];
    }

    function stakeAsPool(address _staker, uint256 _amount) external {

        require(IFactory(factory).isPoolExists(msg.sender), "access denied");
        require(poolToken == CART, "not CART token pool");

        _sync();
        User storage user = users[_staker];
        if (user.tokenAmount > 0) {
            _processRewards(_staker, false);
        }
        if (user.deposits.length == 0) {
            Deposit memory unlockedDeposit =
                Deposit({
                    tokenAmount: 0,
                    weight: 0,
                    lockedFrom: 0,
                    lockedUntil: 0,
                    isYield: false
                });
            user.deposits.push(unlockedDeposit);
        }
        uint256 depositWeight = _amount * 2 * weightMultiplier;
        Deposit memory newDeposit =
            Deposit({
                tokenAmount: _amount,
                lockedFrom: uint64(now256()),
                lockedUntil: uint64(now256() + 365 days),
                weight: depositWeight,
                isYield: true
            });
        user.tokenAmount += _amount;
        user.rewardAmount += _amount;
        user.totalWeight += depositWeight;
        user.deposits.push(newDeposit);

        usersLockingWeight += depositWeight;

        user.subYieldRewards = weightToReward(user.totalWeight, yieldRewardsPerWeight);

        poolTokenReserve += _amount;
    }
    
    function _stake(
        address _staker,
        uint256 _amount,
        uint64 _lockPeriod,
        address _nftAddress,
        uint256 _nftTokenId
    ) internal override {

        super._stake(_staker, _amount, _lockPeriod, _nftAddress, _nftTokenId);
        User storage user = users[_staker];

        poolTokenReserve += _amount;
    }

    function _unstake(
        address _staker,
        uint256 _depositId,
        uint256 _amount
    ) internal override {

        User storage user = users[_staker];
        Deposit memory stakeDeposit = user.deposits[_depositId];
        require(stakeDeposit.lockedFrom == 0 || now256() > stakeDeposit.lockedUntil, "deposit not yet unlocked");
        poolTokenReserve -= _amount;
        super._unstake(_staker, _depositId, _amount);
    }

    function _emergencyWithdraw(
        address _staker
    ) internal override {

        User storage user = users[_staker];
        uint256 amount = user.tokenAmount;

        poolTokenReserve -= amount;
        super._emergencyWithdraw(_staker);
    }

    function _processRewards(
        address _staker,
        bool _withUpdate
    ) internal override returns (uint256 pendingYield) {

        pendingYield = super._processRewards(_staker, _withUpdate);
    }

    function transferCartToken(address _to, uint256 _value) internal {

        SafeERC20.safeTransfer(IERC20(CART), _to, _value);
    }

    function transferCartTokenFrom(
        address _from,
        address _to,
        uint256 _value
    ) internal {

        SafeERC20.safeTransferFrom(IERC20(CART), _from, _to, _value);
    }
}