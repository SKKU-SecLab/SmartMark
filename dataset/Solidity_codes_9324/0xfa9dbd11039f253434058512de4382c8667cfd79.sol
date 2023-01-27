
pragma solidity ^0.8.0;

interface IERC721ReceiverUpgradeable {

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);

}// MIT

pragma solidity ^0.8.1;

library AddressUpgradeable {

    function isContract(address account) internal view returns (bool) {


        return account.code.length > 0;
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


abstract contract Initializable {
    bool private _initialized;

    bool private _initializing;

    modifier initializer() {
        require(_initializing ? _isConstructor() : !_initialized, "Initializable: contract is already initialized");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }

    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    function _isConstructor() private view returns (bool) {
        return !AddressUpgradeable.isContract(address(this));
    }
}// MIT

pragma solidity ^0.8.0;

abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal onlyInitializing {
    }

    function __Context_init_unchained() internal onlyInitializing {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }

    uint256[50] private __gap;
}// MIT

pragma solidity ^0.8.0;


abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function __Ownable_init() internal onlyInitializing {
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal onlyInitializing {
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

    uint256[49] private __gap;
}// MIT

pragma solidity ^0.8.0;

interface IPaperHands {


    function balanceOf(address) external view returns (uint256);


    function batchTransferFrom(
        address _from,
        address _to,
        uint256[] memory _tokenIds
    ) external;

    function batchSafeTransferFrom(
        address _from,
        address _to,
        uint256[] memory _tokenIds,
        bytes memory _data
    ) external;

    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory data
    ) external;

}// MIT

pragma solidity ^0.8.0;

interface IDiamondHandsPass {

    function mint(address recipient, uint256 tokenId) external;

}//MIT
pragma solidity ^0.8.0;



contract PaperHandsStaking is Initializable, OwnableUpgradeable, IERC721ReceiverUpgradeable {

    address public paperHandsContract;
    address public diamondHandsPassContract;
    uint256 public lockDuration;
    uint256 public passiveEmission;
    uint256 public activeEmission;
    uint256 public lockEmission;

    mapping(address => bool) private admins;

    struct LastUpdate {
        uint256 passive;
        uint256 active;
        uint256 lock;
    }

    struct Reward {
        uint256 passive;
        uint256 active;
        uint256 lock;
    }

    uint256 public startTime;

    mapping(address => LastUpdate) public lastUpdates;

    mapping(address => Reward) public rewards;

    mapping(address => uint256[]) public stakedActiveTokens;
    mapping(address => uint256[]) public stakedLockTokens;
    mapping(uint256 => uint256) public stakedLockTokensTimestamps;

    uint256 public timestamp1155;
    uint256 private constant INTERVAL = 86400;

    event Stake(
        address indexed user,
        uint256[] indexed tokenIDs,
        bool indexed locked
    );
    event Withdraw(
        address indexed user,
        uint256[] indexed tokenIDs,
        bool indexed locked
    );

    function initialize(address _paperHandsContract, uint256 _startTime) public initializer {

        __Ownable_init();
        paperHandsContract = _paperHandsContract;
        startTime = _startTime;
        lockDuration = 86400 * 56;
        passiveEmission = 100 ether;
        activeEmission = 200 ether;
        lockEmission = 888 ether;
    }

    modifier multiAdmin() {

        require(admins[msg.sender] == true, "NOT_ADMIN");
        _;
    }

    function addAdmin(address _admin) external onlyOwner {

        require(_admin != address(0), "INVALID_ADDRESS");
        admins[_admin] = true;
    }

    function removeAdmin(address _admin) external onlyOwner {

        require(admins[_admin] == true, "ADMIN_NOT_SET");
        admins[_admin] = false;
    }

    function setTimestamp1155(uint256 _timestamp1155) external onlyOwner {

        timestamp1155 = _timestamp1155;
    }

    function setAddress1155(address _address1155) external onlyOwner {

        diamondHandsPassContract = _address1155;
    }

    function setPassiveEmission(uint256 _passiveEmission) external onlyOwner {

        passiveEmission = _passiveEmission;
    }

    function setActiveEmission(uint256 _activeEmission) external onlyOwner {

        activeEmission = _activeEmission;
    }

    function setLockEmission(uint256 _lockEmission) external onlyOwner {

        lockEmission = _lockEmission;
    }

    function viewPassivePendingReward(address _user)
        external
        view
        returns (uint256)
    {

        return _getPassivePendingReward(_user);
    }

    function viewActivePendingReward(address _user)
        external
        view
        returns (uint256)
    {

        return _getActivePendingReward(_user);
    }

    function viewLockPendingReward(address _user)
        external
        view
        returns (uint256)
    {

        return _getLockPendingReward(_user);
    }

    function viewAllPendingReward(address _user)
        external
        view
        returns (uint256)
    {

        return
            _getPassivePendingReward(_user) +
            _getActivePendingReward(_user) +
            _getLockPendingReward(_user);
    }

    function viewAllRewards(address _user) external view returns (uint256) {

        Reward memory _rewards = rewards[_user];
        return _rewards.passive + _rewards.active + _rewards.lock;
    }

    function viewActiveTokens(address _user) external view returns (uint256[] memory activeTokens) {

        uint256 activeArrLength = stakedActiveTokens[_user].length;
        activeTokens = new uint256[](activeArrLength);
        for (uint256 i; i < activeArrLength; i++) {
            activeTokens[i] = stakedActiveTokens[_user][i];
        }
    }

    function viewLockTokens(address _user) external view returns (uint256[] memory lockTokens) {

        uint256 lockArrLength = stakedLockTokens[_user].length;
        lockTokens = new uint256[](lockArrLength);
        for (uint256 i; i < lockArrLength; i++) {
            lockTokens[i] = stakedLockTokens[_user][i];
        }
    }

    function stakeActive(address owner, uint256[] memory tokenIds) external {

        rewards[owner].active += _getActivePendingReward(owner);
        lastUpdates[owner].active = block.timestamp;
        for (uint256 i; i < tokenIds.length; i++) {
            stakedActiveTokens[owner].push(tokenIds[i]);
        }
        IPaperHands(paperHandsContract).batchSafeTransferFrom(
            owner,
            address(this),
            tokenIds,
            ""
        );
        emit Stake(owner, tokenIds, false);
    }

    function withdrawActive() external {

        rewards[msg.sender].active += _getActivePendingReward(msg.sender);
        lastUpdates[msg.sender].active = block.timestamp;
        uint256 arrLen = stakedActiveTokens[msg.sender]
            .length;
        require(arrLen > 0, "NO_ACTIVE_STAKE");
        uint256[] memory tokenIds = new uint256[](arrLen);
        tokenIds = stakedActiveTokens[msg.sender];
        IPaperHands(paperHandsContract).batchSafeTransferFrom(
            address(this),
            msg.sender,
            tokenIds,
            ""
        );
        delete stakedActiveTokens[msg.sender];
        emit Withdraw(msg.sender, tokenIds, false);
    }

    function stakeLock(address owner, uint256[] memory tokenIds) external {

        rewards[owner].lock += _getLockPendingReward(owner);
        lastUpdates[owner].lock = block.timestamp;
        for (uint256 i; i < tokenIds.length; i++) {
            stakedLockTokens[owner].push(tokenIds[i]);
            stakedLockTokensTimestamps[tokenIds[i]] =
                ((block.timestamp + lockDuration) / 86400) *
                86400;
        }
        IPaperHands(paperHandsContract).batchSafeTransferFrom(
            owner,
            address(this),
            tokenIds,
            ""
        );
        if (block.timestamp <= timestamp1155) {
            uint256 quantity = tokenIds.length / 2;
            if (quantity > 0) {
            IDiamondHandsPass(diamondHandsPassContract).mint(owner,quantity);
            }
        }
        emit Stake(owner, tokenIds, true);
    }

    function withdrawLock() external {

        rewards[msg.sender].lock += _getLockPendingReward(msg.sender);
        lastUpdates[msg.sender].lock = block.timestamp;
        uint256[] storage _stakelockTokens = stakedLockTokens[msg.sender];
        uint256 unlockArrLength;
        uint256 lockArrLength;
        for (uint256 i; i < _stakelockTokens.length; i++) {
            block.timestamp < stakedLockTokensTimestamps[_stakelockTokens[i]]
                ? lockArrLength = lockArrLength + 1
                : unlockArrLength = unlockArrLength + 1;
        }
        require(unlockArrLength > 0, "NO_UNLOCKED");
        if (lockArrLength == 0) {
            IPaperHands(paperHandsContract).batchSafeTransferFrom(
                address(this),
                msg.sender,
                _stakelockTokens,
                ""
            );
            emit Withdraw(msg.sender, _stakelockTokens, true);
            delete stakedLockTokens[msg.sender];
        } else {
            uint256[] memory unlockedTokens = new uint256[](unlockArrLength);
            uint256[] memory lockedTokens = new uint256[](lockArrLength);
            uint256 unlockArrLengthConst = unlockArrLength;
            uint256 lockArrLengthConst = lockArrLength;
            for (uint256 i; i < _stakelockTokens.length; i++) {
                if (
                    block.timestamp <
                    stakedLockTokensTimestamps[_stakelockTokens[i]]
                ) {
                    lockedTokens[lockArrLengthConst - lockArrLength] = (
                        _stakelockTokens[i]
                    );
                    lockArrLength = lockArrLength - 1;
                } else {
                    unlockedTokens[unlockArrLengthConst - unlockArrLength] = (
                        _stakelockTokens[i]
                    );
                    unlockArrLength = unlockArrLength - 1;
                }
            }
            stakedLockTokens[msg.sender] = lockedTokens;
            IPaperHands(paperHandsContract).batchSafeTransferFrom(
                address(this),
                msg.sender,
                unlockedTokens,
                ""
            );
            emit Withdraw(msg.sender, unlockedTokens, true);
        }
    }

    function setStartTime(uint256 _timestamp) external onlyOwner {

        if (_timestamp == 0) {
            startTime = block.timestamp;
        } else {
            startTime = _timestamp;
        }
    }

    function _getPassivePendingReward(address _user)
        internal
        view
        returns (uint256)
    {

        if (_user == address(this)) {
            return 0;
        }
        return
            (IPaperHands(paperHandsContract).balanceOf(_user) *
                passiveEmission *
                (block.timestamp -
                    (
                        lastUpdates[_user].passive >= startTime
                            ? lastUpdates[_user].passive
                            : startTime
                    ))) / INTERVAL;
    }

    function _getActivePendingReward(address _user)
        internal
        view
        returns (uint256)
    {

        return
            (stakedActiveTokens[_user].length *
                activeEmission *
                (block.timestamp -
                    (
                        lastUpdates[_user].active >= startTime
                            ? lastUpdates[_user].active
                            : startTime
                    ))) / INTERVAL;
    }

    function _getLockPendingReward(address _user)
        internal
        view
        returns (uint256)
    {

        return
            (stakedLockTokens[_user].length *
                lockEmission *
                (block.timestamp -
                    (
                        lastUpdates[_user].lock >= startTime
                            ? lastUpdates[_user].lock
                            : startTime
                    ))) / INTERVAL;
    }

    function transferRewards(address _from, address _to) external multiAdmin {

        if (_from != address(0) && _from != address(this)) {
            rewards[_from].passive += _getPassivePendingReward(_from);
            lastUpdates[_from].passive = block.timestamp;
        }

        if (_to != address(0) && _to != address(this)) {
            rewards[_to].passive += _getPassivePendingReward(_to);
            lastUpdates[_to].passive = block.timestamp;
        }
    }

    function onERC721Received(
        address,
        address,
        uint256 _tokenId,
        bytes memory
    ) public virtual override returns (bytes4) {

        return this.onERC721Received.selector;
    }
}