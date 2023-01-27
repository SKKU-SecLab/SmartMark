
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

interface IERC721Receiver {

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);

}// MIT

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
pragma solidity 0.8.10;


contract HighStreetNftPool is ReentrancyGuard, ERC721Holder {


    struct Deposit {
        uint256 rewardAmount;
        uint64 lockedFrom;
        uint64 lockedUntil;
    }

    struct User {
        uint256 tokenAmount;
        uint256 rewardAmount;
        uint256 subYieldRewards;
        uint16[] list;
        Deposit[] deposits;
    }

    address public immutable HIGH;

    mapping(address => User) public users;

    address public immutable poolToken;

    uint256 public lastYieldDistribution;

    uint256 public yieldRewardsPerToken;

    uint256 public usersLockingAmount;

    uint256 public highPerBlock;

    uint256 public endBlock;

    uint256 internal constant REWARD_PER_TOKEN_MULTIPLIER = 1e24;

    uint256 public constant DEPOSIT_BATCH_SIZE  = 20;

    uint256 public constant NFT_BATCH_SIZE  = 100;

    uint16 internal constant UINT_16_MAX = type(uint16).max;

    event Staked(address indexed _by, address indexed _from, uint256 amount, uint256[] nfts);

    event Unstaked(address indexed _by, address indexed _to, uint256 amount, uint256[] nfts);

    event UnstakedReward(address indexed _by, address indexed _to, uint256 amount);

    event Synchronized(address indexed _by, uint256 yieldRewardsPerToken, uint256 lastYieldDistribution);

    event YieldClaimed(address indexed _by, address indexed _to, uint256 amount);

    constructor(
        address _high,
        address _poolToken,
        uint256 _initBlock,
        uint256 _endBlock,
        uint256 _highPerBlock
    ) {
        require(_high != address(0), "high token address not set");
        require(_poolToken != address(0), "pool token address not set");
        require(_initBlock >= blockNumber(), "Invalid init block");

        HIGH = _high;
        poolToken = _poolToken;
        highPerBlock = _highPerBlock;

        lastYieldDistribution = _initBlock;
        endBlock = _endBlock;
    }

    function pendingYieldRewards(address _staker) external view returns (uint256) {

        uint256 newYieldRewardsPerToken;

        if (blockNumber() > lastYieldDistribution && usersLockingAmount != 0) {
            uint256 multiplier =
                blockNumber() > endBlock ? endBlock - lastYieldDistribution : blockNumber() - lastYieldDistribution;
            uint256 highRewards = multiplier * highPerBlock;

            newYieldRewardsPerToken = rewardToToken(highRewards, usersLockingAmount) + yieldRewardsPerToken;
        } else {
            newYieldRewardsPerToken = yieldRewardsPerToken;
        }

        User memory user = users[_staker];
        uint256 pending = tokenToReward(user.tokenAmount, newYieldRewardsPerToken) - user.subYieldRewards;

        return pending;
    }

    function balanceOf(address _user) external view returns (uint256) {

        return users[_user].tokenAmount;
    }

    function getNftId(address _user, uint256 _index) external view returns (int32) {

        uint16 value = users[_user].list[_index];
        if(value == 0) {
            return -1;
        } else if(value == UINT_16_MAX) {
            return  0;
        } else {
            return int32(uint32(value));
        }
    }

    function getNftsLength(address _user) external view returns (uint256) {

        return users[_user].list.length;
    }

    function getDeposit(address _user, uint256 _depositId) external view returns (Deposit memory) {

        return users[_user].deposits[_depositId];
    }

    function getDepositsLength(address _user) external view returns (uint256) {

        return users[_user].deposits.length;
    }

    function getDepositsBatch(address _user, uint256 _pageId) external view returns (Deposit[] memory) {

        uint256 pageStart = _pageId * DEPOSIT_BATCH_SIZE;
        uint256 pageEnd = (_pageId + 1) * DEPOSIT_BATCH_SIZE;
        uint256 pageLength = DEPOSIT_BATCH_SIZE;

        if(pageEnd > (users[_user].deposits.length - pageStart)) {
            pageEnd = users[_user].deposits.length;
            pageLength = pageEnd - pageStart;
        }

        Deposit[] memory deposits = new Deposit[](pageLength);
        for(uint256 i = pageStart; i < pageEnd; ++i) {
            deposits[i-pageStart] = users[_user].deposits[i];
        }
        return deposits;
    }

    function getDepositsBatchLength(address _user) external view returns (uint256) {

        if(users[_user].deposits.length == 0) {
            return 0;
        }
        return 1 + (users[_user].deposits.length - 1) / DEPOSIT_BATCH_SIZE;
    }


    function getNftsBatch(address _user, uint256 _pageId) external view returns (int32[] memory) {

        uint256 pageStart = _pageId * NFT_BATCH_SIZE;
        uint256 pageEnd = (_pageId + 1) * NFT_BATCH_SIZE;
        uint256 pageLength = NFT_BATCH_SIZE;

        if(pageEnd > (users[_user].list.length - pageStart)) {
            pageEnd = users[_user].list.length;
            pageLength = pageEnd - pageStart;
        }

        int32[] memory list = new int32[](pageLength);
        uint16 value;
        for(uint256 i = pageStart; i < pageEnd; ++i) {
            value = users[_user].list[i];
            if(value == 0) {
                list[i-pageStart] = -1;
            } else if(value == UINT_16_MAX) {
                list[i-pageStart] = 0;
            } else {
                list[i-pageStart] = int32(uint32(value));
            }
        }
        return list;
    }

    function getNftsBatchLength(address _user) external view returns (uint256) {

        if(users[_user].list.length == 0) {
            return 0;
        }
        return 1 + (users[_user].list.length - 1) / NFT_BATCH_SIZE;
    }

    function stake(
        uint256[] calldata _nftIds
    ) external nonReentrant {

        require(!isPoolDisabled(), "Pool disable");
        _stake(msg.sender, _nftIds);
    }

    function unstake(
        uint256[] calldata _listIds
    ) external nonReentrant {

        _unstake(msg.sender, _listIds);
    }

    function unstakeReward(
        uint256 _depositId
    ) external nonReentrant {

        User storage user = users[msg.sender];
        Deposit memory stakeDeposit = user.deposits[_depositId];
        require(now256() > stakeDeposit.lockedUntil, "deposit not yet unlocked");
        _unstakeReward(msg.sender, _depositId);
    }

    function sync() external {

        _sync();
    }

    function processRewards() external virtual nonReentrant {

        _processRewards(msg.sender, true);
    }

    function _pendingYieldRewards(address _staker) internal view returns (uint256 pending) {

        User memory user = users[_staker];

        return tokenToReward(user.tokenAmount, yieldRewardsPerToken) - user.subYieldRewards;
    }

    function _stake(
        address _staker,
        uint256[] calldata _nftIds
    ) internal virtual {

        require(_nftIds.length > 0, "zero amount");
        require(_nftIds.length <= 40, "length exceeds limitation");

        _sync();

        User storage user = users[_staker];
        if (user.tokenAmount > 0) {
            _processRewards(_staker, false);
        }

        uint256 addedAmount;
        for(uint i; i < _nftIds.length; ++i) {
            IERC721(poolToken).safeTransferFrom(_staker, address(this), _nftIds[i]);
            if(_nftIds[i] == 0) {
                user.list.push(UINT_16_MAX);
            } else {
                user.list.push(uint16(_nftIds[i]));
            }
            addedAmount = addedAmount + 1;
        }

        user.tokenAmount += addedAmount;
        user.subYieldRewards = tokenToReward(user.tokenAmount, yieldRewardsPerToken);
        usersLockingAmount += addedAmount;

        emit Staked(msg.sender, _staker, addedAmount, _nftIds);
    }

    function _unstake(
        address _staker,
        uint256[] calldata _listIds
    ) internal virtual {

        require(_listIds.length > 0, "zero amount");
        require(_listIds.length <= 40, "length exceeds limitation");

        User storage user = users[_staker];
        uint16[] memory list = user.list;
        uint256 amount = _listIds.length;
        require(user.tokenAmount >= amount, "amount exceeds stake");

        _sync();
        _processRewards(_staker, false);

        user.tokenAmount -= amount;
        user.subYieldRewards = tokenToReward(user.tokenAmount, yieldRewardsPerToken);
        usersLockingAmount = usersLockingAmount - amount;

        uint256 index;
        uint256[] memory nfts = new uint256[](_listIds.length);
        for(uint i; i < _listIds.length; ++i) {
            index = _listIds[i];
            if(UINT_16_MAX == list[index]) {
                nfts[i] = 0;
            } else {
                nfts[i] = uint256(list[index]);
            }
            IERC721(poolToken).safeTransferFrom(address(this), _staker, nfts[i]);
            if (user.tokenAmount  != 0) {
                delete user.list[index];
            }
        }

        if (user.tokenAmount  == 0) {
            delete user.list;
        }

        emit Unstaked(msg.sender, _staker, amount, nfts);
    }

    function _unstakeReward(
        address _staker,
        uint256 _depositId
    ) internal virtual {


        User storage user = users[_staker];
        Deposit storage stakeDeposit = user.deposits[_depositId];

        uint256 amount = stakeDeposit.rewardAmount;

        require(amount >= 0, "amount exceeds stake");

        delete user.deposits[_depositId];

        user.rewardAmount -= amount;

        SafeERC20.safeTransfer(IERC20(HIGH), _staker, amount);

        emit UnstakedReward(msg.sender, _staker, amount);
    }

    function _sync() internal virtual {


        if (lastYieldDistribution >= endBlock) {
            return;
        }
        if (blockNumber() <= lastYieldDistribution) {
            return;
        }
        if (usersLockingAmount == 0) {
            lastYieldDistribution = blockNumber();
            return;
        }

        uint256 currentBlock = blockNumber() > endBlock ? endBlock : blockNumber();
        uint256 blocksPassed = currentBlock - lastYieldDistribution;

        uint256 highReward = blocksPassed * highPerBlock;

        yieldRewardsPerToken += rewardToToken(highReward, usersLockingAmount);
        lastYieldDistribution = currentBlock;

        emit Synchronized(msg.sender, yieldRewardsPerToken, lastYieldDistribution);
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

        Deposit memory newDeposit =
            Deposit({
                rewardAmount: pendingYield,
                lockedFrom: uint64(now256()),
                lockedUntil: uint64(now256() + 365 days) // staking yield for 1 year
            });
        user.deposits.push(newDeposit);

        user.rewardAmount += pendingYield;

        if (_withUpdate) {
            user.subYieldRewards = tokenToReward(user.tokenAmount, yieldRewardsPerToken);
        }

        emit YieldClaimed(msg.sender, _staker, pendingYield);
    }

    function tokenToReward(uint256 _token, uint256 _rewardPerToken) public pure returns (uint256) {

        return (_token * _rewardPerToken) / REWARD_PER_TOKEN_MULTIPLIER;
    }

    function rewardToToken(uint256 _reward, uint256 _rewardPerToken) public pure returns (uint256) {

        return (_reward * REWARD_PER_TOKEN_MULTIPLIER) / _rewardPerToken;
    }

    function isPoolDisabled() public view returns (bool) {

        return blockNumber() >= endBlock;
    }

    function blockNumber() public view virtual returns (uint256) {

        return block.number;
    }

    function now256() public view virtual returns (uint256) {

        return block.timestamp;
    }
}