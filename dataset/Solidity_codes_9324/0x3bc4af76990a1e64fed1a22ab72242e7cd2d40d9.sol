
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
pragma solidity >=0.8.12 <0.9.0;


interface IPPASurrealestates {

    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;


    function ownerOf(uint256 tokenId) external view returns (address);

}

interface IStakingListener {

    function notifyChange(address account) external;

}

contract SurrealestateStaking is ERC721Holder, Ownable {

    IPPASurrealestates surrealestates;
    address surrealestateContractAddress;

    constructor() public {
        surrealestateContractAddress = _getSurrealestatesContractAddress();
        surrealestates = IPPASurrealestates(surrealestateContractAddress);
    }

    function _getSurrealestatesContractAddress()
        internal
        view
        returns (address)
    {

        address addr;
        assembly {
            switch chainid()
            case 1 {
                addr := 0x6f3185b51a42e03a4f0eaaf37604ddd499ef9b12
            }
            case 4 {
                addr := 0x6551111b5d3C7e4B5436409C2e70A8Fbe1757407
            }
        }
        return addr;
    }

    uint256 stakingLockPeriod = 7776000; // 90 days in seconds.

    struct StakingMultiplier {
        uint256 numeratorMinus1; // Store as "minus 1" because we want this to default to 1, but uninitialized vars default to 0.
        uint256 denominatorMinus1;
    }

    struct AccountInfo {
        uint256 numStaked;
        uint256 pointsStaked;
        uint256 lastRefreshTimestamp;
        uint256 tokensEarnedBeforeLastRefresh;
        StakingMultiplier stakingMultiplier;
    }
    mapping(address => AccountInfo) public accounts;

    struct TokenInfo {
        bool isLocked;
        uint256 lockedUntil;
        address owner;
    }
    mapping(uint256 => TokenInfo) public tokens;

    mapping(address => bool) public approvedManagers;

    IStakingListener[] listeners;

    uint256 public earnPeriodSeconds = 36000;

    modifier onlyApprovedManager() {

        require(
            owner() == msg.sender || approvedManagers[msg.sender],
            "Caller is not an approved manager"
        );
        _;
    }

    function _notifyAllListeners(address account) internal {

        for (uint256 i = 0; i < listeners.length; i++) {
            listeners[i].notifyChange(account);
        }
    }

    function stake(uint256[] calldata tokenIds, bool lock) public {

        refreshTokensEarned(msg.sender);
        for (uint256 i = 0; i < tokenIds.length; i++) {
            require(
                surrealestates.ownerOf(tokenIds[i]) == msg.sender,
                "Not your token"
            );

            surrealestates.transferFrom(msg.sender, address(this), tokenIds[i]);
            tokens[tokenIds[i]].owner = msg.sender;
            accounts[msg.sender].pointsStaked += pointsByTokenId(tokenIds[i]);
        }
        accounts[msg.sender].numStaked += tokenIds.length;

        if (lock) {
            uint256 lockUntil = block.timestamp + stakingLockPeriod;
            for (uint256 i = 0; i < tokenIds.length; i++) {
                tokens[tokenIds[i]].lockedUntil = lockUntil;
                tokens[tokenIds[i]].isLocked = true;
                accounts[msg.sender].pointsStaked += pointsByTokenId(
                    tokenIds[i]
                );
            }
        }

        _notifyAllListeners(msg.sender);
    }

    function lockStaking(uint256[] calldata tokenIds) public {

        refreshTokensEarned(msg.sender);
        uint256 lockUntil = block.timestamp + stakingLockPeriod;
        for (uint256 i = 0; i < tokenIds.length; i++) {
            require(
                tokens[tokenIds[i]].owner == msg.sender,
                "Token is not currently staked"
            );
            require(
                tokens[tokenIds[i]].lockedUntil < block.timestamp,
                "Token is already locked"
            );
            if (!tokens[tokenIds[i]].isLocked) {
                tokens[tokenIds[i]].isLocked = true;
                accounts[msg.sender].pointsStaked += pointsByTokenId(
                    tokenIds[i]
                );
            }
            tokens[tokenIds[i]].lockedUntil = lockUntil;
        }
        _notifyAllListeners(msg.sender);
    }

    function refreshTokensEarned(address addr) internal {

        if (block.timestamp == accounts[addr].lastRefreshTimestamp) {
            return;
        }
        if (accounts[addr].lastRefreshTimestamp == 0) {
            accounts[addr].lastRefreshTimestamp = block.timestamp;
            return;
        }

        uint256 totalTokensEarned = calculateTokensEarned(addr);
        accounts[addr].tokensEarnedBeforeLastRefresh = totalTokensEarned;
        accounts[addr].lastRefreshTimestamp = block.timestamp;
    }

    function calculateTokensEarned(address addr) public view returns (uint256) {

        uint256 secondsStakedSinceLastRefresh = block.timestamp -
            accounts[addr].lastRefreshTimestamp;

        uint256 tokensEarnedSinceLastRefresh = (secondsStakedSinceLastRefresh *
            (accounts[addr].pointsStaked) *
            (accounts[addr].stakingMultiplier.numeratorMinus1 + 1)) /
            (accounts[addr].stakingMultiplier.denominatorMinus1 + 1) /
            earnPeriodSeconds;
        return
            accounts[addr].tokensEarnedBeforeLastRefresh +
            tokensEarnedSinceLastRefresh;
    }

    function unstake(uint256[] calldata tokenIds) public {

        refreshTokensEarned(msg.sender);

        for (uint256 i = 0; i < tokenIds.length; i++) {
            require(
                tokens[tokenIds[i]].owner == msg.sender,
                "Caller is not currently staking the provided tokenId"
            );
            _unstakeSingle(tokenIds[i]);
        }
        accounts[msg.sender].numStaked -= tokenIds.length;
        _notifyAllListeners(msg.sender);
    }

    function _unstakeSingle(uint256 tokenId) internal {

        require(
            tokens[tokenId].lockedUntil < block.timestamp,
            "Token is still locked"
        );
        accounts[tokens[tokenId].owner].pointsStaked -= pointsByTokenId(
            tokenId
        );

        if (tokens[tokenId].isLocked) {
            tokens[tokenId].isLocked = false;
            accounts[tokens[tokenId].owner].pointsStaked -= pointsByTokenId(
                tokenId
            );
        }

        surrealestates.transferFrom(address(this), msg.sender, tokenId);

        tokens[tokenId].owner = address(0);
    }

    function addApprovedManager(address managerAddr) public onlyOwner {

        approvedManagers[managerAddr] = true;
    }

    function removeApprovedManager(address managerAddr) public onlyOwner {

        approvedManagers[managerAddr] = false;
    }

    function setStakingLockPeriod(uint256 newPeriod)
        public
        onlyApprovedManager
    {

        stakingLockPeriod = newPeriod;
    }

    function setEarnPeriod(uint256 newSeconds) public onlyApprovedManager {

        earnPeriodSeconds = newSeconds;
    }

    function setEarningMultiplier(
        address addr,
        uint256 numerator,
        uint256 denominator
    ) public onlyApprovedManager {

        refreshTokensEarned(addr);
        accounts[addr].stakingMultiplier = StakingMultiplier(
            numerator - 1,
            denominator - 1
        );
    }

    function addStakingListener(address contractAddress) public onlyOwner {

        listeners.push(IStakingListener(contractAddress));
    }

    function resetStakingListeners() public onlyOwner {

        delete listeners;
    }

    function stakedTokensOfOwner(
        address addr,
        uint256 start,
        uint256 stop
    ) public view returns (uint256[] memory) {

        if (accounts[addr].numStaked == 0) {
            return new uint256[](0);
        }

        uint256 index = 0;
        uint256[] memory ownedTokens = new uint256[](accounts[addr].numStaked);

        for (uint256 tokenId = start; tokenId <= stop; tokenId++) {
            if (tokens[tokenId].owner == addr) {
                ownedTokens[index] = tokenId;
                index++;
                if (index == accounts[addr].numStaked) {
                    break;
                }
            }
        }

        return ownedTokens;
    }

    function unstakeAsOwner(address addr, uint256[] calldata tokenIds)
        public
        onlyOwner
    {

        for (uint256 i = 0; i < tokenIds.length; i++) {
            surrealestates.transferFrom(address(this), addr, tokenIds[i]);
        }
    }

    function pointsByTokenId(uint256 tokenId) public view returns (uint256) {

        return 1000 + uint256(uint8(rawPointsByTokenId[tokenId]));
    }

    function setRawPoints(bytes memory newRawPoints) public onlyOwner {

        rawPointsByTokenId = newRawPoints;
    }

    bytes rawPointsByTokenId;
}