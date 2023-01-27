
pragma solidity ^0.8.9;

interface IERC721Receiver {

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);

}

interface IERC721 {

    function ownerOf(uint256 tokenId) external view returns (address);


    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

}

library Address {

    function isContract(address account) internal view returns (bool) {


        return account.code.length > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(
            address(this).balance >= amount,
            "Address: insufficient balance"
        );

        (bool success, ) = recipient.call{value: amount}("");
        require(
            success,
            "Address: unable to send value, recipient may have reverted"
        );
    }

    function functionCall(address target, bytes memory data)
        internal
        returns (bytes memory)
    {

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

        return
            functionCallWithValue(
                target,
                data,
                value,
                "Address: low-level call with value failed"
            );
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {

        require(
            address(this).balance >= value,
            "Address: insufficient balance for call"
        );
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(
            data
        );
        return verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data)
        internal
        view
        returns (bytes memory)
    {

        return
            functionStaticCall(
                target,
                data,
                "Address: low-level static call failed"
            );
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

    function functionDelegateCall(address target, bytes memory data)
        internal
        returns (bytes memory)
    {

        return
            functionDelegateCall(
                target,
                data,
                "Address: low-level delegate call failed"
            );
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

library SafeERC20 {

    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {

        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.transfer.selector, to, value)
        );
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {


        bytes memory returndata = address(token).functionCall(
            data,
            "SafeERC20: low-level call failed"
        );
        if (returndata.length > 0) {
            require(
                abi.decode(returndata, (bool)),
                "SafeERC20: ERC20 operation did not succeed"
            );
        }
    }
}

interface IERC20 {

    function balanceOf(address account) external view returns (uint256);


    function transfer(address to, uint256 amount) external returns (bool);

}

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

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

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
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

contract NFTStaking is Ownable, IERC721Receiver {

    uint256 private _totalStaked;
    uint256 public endTimestamp;
    uint256 public ratePerDay;
    uint256 public tokenDecimals;

    mapping(address => uint) kinBonusActiveSince;

    mapping(uint => bool) legendary;

    uint public legendaryMultiplier = 150;

    uint public kinBonusMultiplier = 2;

    uint public kinCount = 7;

    mapping(uint256 => uint256) private rarities;

    mapping(address => uint256) private timeStaked;
    mapping(address => uint256) private lastChecked;
    mapping(address => uint256) private remainingClaims;
    mapping(address => uint256[]) private stakedIds;

    mapping(uint256 => uint256) private experiences;

    mapping(address => uint256) claimedSoFar;

    mapping(uint256 => uint256) private rarityTiers;
    mapping(uint256 => uint256) private kins;

    mapping(uint256 => Lock) private locks;

    uint256 public maxLevel = 100;

    uint256 public lockCount;

    uint256 public expRate = 100;
    uint256 public expDecimals = 5;

    mapping(address => bool) private hasStaked;

    uint256 public claimedAmount;

    struct Lock {
        uint256 lockTime;
        uint256 rewardMultiplier;
    }

    struct Stake {
        uint256 tokenId;
        uint256 timestamp;
        address owner;
        uint256 lockEndTimestamp;
        uint256 rewardMultiplier;
    }

    event NFTStaked(address owner, uint256 tokenId, uint256 value);
    event NFTUnstaked(address owner, uint256 tokenId, uint256 value);
    event Claimed(address owner, uint256 amount);

    IERC721 nft;
    IERC20 token;

    mapping(uint256 => Stake) private vault;

    constructor(
        IERC721 _nft,
        IERC20 _token,
        uint256 duration,
        uint256 rate_,
        uint256 tokenDecimals_
    ) {
        nft = _nft;
        token = _token;
        endTimestamp = block.timestamp + duration;
        ratePerDay = rate_ * 10 ** tokenDecimals_;
        tokenDecimals = tokenDecimals_;
        addLock(30 days, 100);
        addLock(60 days, 115);
        addLock(90 days, 130);
        addLock(120 days, 150);
        rarityTiers[0] = 100;
        rarityTiers[1] = 115;
        rarityTiers[2] = 130;
        rarityTiers[3] = 150;
    }

    

    function setToken(address t) external onlyOwner {

        token = IERC20(t);
    }

    function setKinBonusMultiplier(uint newV) external onlyOwner {

        kinBonusMultiplier = newV;
    }

    function isLegendary(uint tokenId) public view returns(bool) {

        return legendary[tokenId];
    }

    function addLegendary(uint tokenId) external onlyOwner {

        legendary[tokenId] = true;
    }

    function removeLegendary(uint tokenId) external onlyOwner {

        legendary[tokenId] = false;
    }

    function setLegendaryMultiplier(uint newVal) external onlyOwner {

        legendaryMultiplier = newVal;
    }

    function editRarityTierMultiplier(uint256 t, uint256 multiplier)
        external
        onlyOwner
    {

        rarityTiers[t] = multiplier;
    }

    function addLock(
        uint256 lockTime_,
        uint256 rewardMultiplier_
    ) public onlyOwner {

        locks[lockCount] = Lock({
            lockTime: lockTime_,
            rewardMultiplier: rewardMultiplier_
        });
        lockCount++;
    }

    function setMaxLevel(uint256 n) external onlyOwner {

        maxLevel = n;
    }

    function editLock(
        uint256 lockNumber,
        uint256 lockTime_,
        uint256 rewardMultiplier_
    ) external onlyOwner {

        locks[lockNumber] = Lock({
            lockTime: lockTime_,
            rewardMultiplier: rewardMultiplier_
        });
    }

    function stake(uint256[] calldata tokenIds, uint256 lockType_) external {

        hasStaked[msg.sender] = true;
        uint256 tokenId;
        _totalStaked += tokenIds.length;
        Lock memory l = getLockInfo(lockType_);
        bool hasStake = stakedIds[msg.sender].length > 0;
        for (uint256 i = 0; i < tokenIds.length; i++) {
            tokenId = tokenIds[i];
            require(nft.ownerOf(tokenId) == msg.sender, "not your nft");
            require(vault[tokenId].tokenId == 0, "already staked");

            nft.transferFrom(msg.sender, address(this), tokenId);
            emit NFTStaked(msg.sender, tokenId, block.timestamp);
            uint256 rarityMultiplier = rarityTiers[rarities[tokenId]];
            uint legendaryMult = legendary[tokenId] ? legendaryMultiplier : 100;
            vault[tokenId] = Stake({
                owner: msg.sender,
                tokenId: uint256(tokenId),
                timestamp: getTimestamp(),
                lockEndTimestamp: block.timestamp + l.lockTime,
                rewardMultiplier: ratePerDay * (l.rewardMultiplier + rarityMultiplier + legendaryMult) / 100
            });
            stakedIds[msg.sender].push(tokenId);
        }
        
        if (!hasStake) {
            lastChecked[msg.sender] = block.timestamp;
        }
        if(isKinBonus(msg.sender)) kinBonusActiveSince[msg.sender] = block.timestamp;
    }

    function _unstakeMany(address account, uint256[] calldata tokenIds)
        internal
    {

        uint256 tokenId;
        _totalStaked -= tokenIds.length;
        uint idx;
        for (uint256 i = 0; i < tokenIds.length; i++) {
            tokenId = tokenIds[i];
            Stake memory staked = vault[tokenId];
            require(staked.owner == msg.sender, "not an owner");
            require(
                staked.lockEndTimestamp <= block.timestamp,
                "Nft is still locked"
            );
            delete vault[tokenId];
            for (uint256 ii = 0; ii < stakedIds[account].length; ii++) {
                if (stakedIds[account][ii] == tokenId) idx = ii;
            }
            require(idx < stakedIds[account].length);
            stakedIds[account][idx] = stakedIds[account][stakedIds[account].length-1];
            stakedIds[account].pop();

            emit NFTUnstaked(account, tokenId, block.timestamp);
            nft.transferFrom(address(this), account, tokenId);
        }
        if (stakedIds[account].length == 0) {
            timeStaked[msg.sender] += block.timestamp - lastChecked[account];
            lastChecked[account] = block.timestamp;
        }

        if(!isKinBonus(msg.sender)) kinBonusActiveSince[msg.sender] = 0;

    }

    function timeSpentStaking(address account) external view  returns(uint t){

        t += timeStaked[account];
        if (stakedIds[account].length > 0 && lastChecked[account] > 0) t += block.timestamp - lastChecked[account];
    }

    function emergencyUnstake(address account, uint256[] calldata tokenIds) external onlyOwner {

        uint256 tokenId;
        _totalStaked -= tokenIds.length;
        uint idx;
        for (uint256 i = 0; i < tokenIds.length; i++) {
            tokenId = tokenIds[i];
            delete vault[tokenId];
            for (uint256 ii = 0; ii < stakedIds[account].length - 1; ii++) {
                if (stakedIds[account][ii] == tokenId) idx = ii;
            }
            require(idx < stakedIds[account].length);
            stakedIds[account][idx] = stakedIds[account][stakedIds[account].length-1];
            stakedIds[account].pop();

            emit NFTUnstaked(account, tokenId, block.timestamp);
            nft.transferFrom(address(this), account, tokenId);
        }
    }

    function claim(uint256[] calldata tokenIds) external {

        _claim(msg.sender, tokenIds, false);
    }

    function unstake(uint256[] calldata tokenIds) external {

        _claim(msg.sender, tokenIds, true);
    }

    function setEndTimestamp(uint256 newTimestamp) external onlyOwner {

        endTimestamp = newTimestamp;
    }

    function update(
        uint256[] calldata tokenIds_,
        uint256[] calldata tiers,
        uint256[] calldata kinTypes
    ) external onlyOwner {

        require(tokenIds_.length == tiers.length, "Bad array lengths");
        for (uint256 i; i < tokenIds_.length; i++) {
            rarities[tokenIds_[i]] = tiers[i];
            kins[tokenIds_[i]] = kinTypes[i];
        }
    }
 
    function isKinBonus(address account) public view returns(bool) {

        bool[] memory _kins = new bool[](kinCount);

        for (uint i;i<stakedIds[account].length;i++){
            _kins[kins[stakedIds[account][i]]] = true;
        }
        uint cnt;
        for (uint i;i<_kins.length;i++){
            if (_kins[i]) cnt++;
        }
        return cnt == kinCount;
    }

    function _claim(
        address account,
        uint256[] calldata tokenIds,
        bool _unstake
    ) internal {

        uint256 tokenId;
        uint256 earned = remainingClaims[account];
        for (uint256 i = 0; i < tokenIds.length; i++) {
            tokenId = tokenIds[i];
            Stake memory staked = vault[tokenId];
            if (staked.owner != account) continue;
            earned += staked.rewardMultiplier * (block.timestamp - staked.timestamp) / 86400;
            if (kinBonusActiveSince[account] != 0) earned += ratePerDay * kinBonusMultiplier * (block.timestamp - kinBonusActiveSince[account]) / 86400;
            kinBonusActiveSince[msg.sender] = block.timestamp;
            experiences[tokenId] += expRate * 10 ** expDecimals * (block.timestamp - staked.timestamp) / 86400;
            vault[tokenId].timestamp = getTimestamp();
        }
        if (earned > 0) {
            if (token.balanceOf(address(this)) < earned) {
                remainingClaims[account] = earned;
            } else {
                token.transfer(account, earned);
                claimedSoFar[account] += earned;
                claimedAmount += earned;
                remainingClaims[account] = 0;
            }
        }
        if (_unstake) {
            _unstakeMany(account, tokenIds);
        }
        emit Claimed(account, earned);
    }

    function onERC721Received(
        address,
        address from,
        uint256,
        bytes calldata
    ) external pure override returns (bytes4) {

        require(from == address(0x0), "Cannot send nfts to Vault directly");
        return IERC721Receiver.onERC721Received.selector;
    }

    function withdrawTokens(address token_, uint256 amount) external onlyOwner {

        if (amount > IERC20(token_).balanceOf(address(this)))
            amount = IERC20(token_).balanceOf(address(this));
        SafeERC20.safeTransfer(IERC20(token_), owner(), amount);
    }


    function getAllLocks() external view returns (Lock[] memory) {

        Lock[] memory _locks = new Lock[](lockCount);
        for (uint256 i = 0; i < lockCount; i++) {
            _locks[i] = locks[i];
        }
        return _locks;
    }

    function stakedOrNot(address account) external view returns(bool) {

        return hasStaked[account];
    }

    function getStakedIds(address account)
        public
        view
        returns (uint256[] memory)
    {

        return stakedIds[account];
    }

    function getMetadata() external view returns (address, address) {

        return (address(nft), address(token));
    }

    function stakeInfo(uint256 tokenId) external view returns (Stake memory) {

        return vault[tokenId];
    }

    function getRemainingLeft() external view returns (uint256) {

        return remainingClaims[msg.sender];
    }

    function earningInfo(address account)
        external
        view
        returns (uint256 earned)
    {

        uint256 tokenId;
        uint256[] memory tokenIds = getStakedIds(account);
        earned = remainingClaims[account];
        for (uint256 i = 0; i < tokenIds.length; i++) {
            tokenId = tokenIds[i];
            Stake memory staked = vault[tokenId];
            if (staked.owner != account) continue;
            earned += staked.rewardMultiplier * (block.timestamp - staked.timestamp) / 86400;
            if (kinBonusActiveSince[account] != 0) earned += ratePerDay * kinBonusMultiplier * (block.timestamp - kinBonusActiveSince[account]) / 86400;
        }
    }

    function getRarity(uint256 tokenId) external view returns (uint256) {

        return rarities[tokenId];
    }

    function getXpEarned(uint256 tokenId_)
        public
        view
        returns (uint256 experience)
    {

        experience += experiences[tokenId_];
        Stake memory staked = vault[tokenId_];
        if (staked.timestamp != 0)
        experience += expRate * 10 ** expDecimals * (block.timestamp - staked.timestamp) / 86400;
    }

    function getTimestamp() private view returns (uint256) {

        return
            block.timestamp > endTimestamp
                ? endTimestamp
                : block.timestamp;
    }

    function totalStaked() external view returns (uint256) {

        return _totalStaked;
    }

    function getLockInfo(uint256 lockType_) public view returns (Lock memory l) {

        require(lockType_ < lockCount, "Nonexistent locktype");
        l = locks[lockType_];
    }

    function getRarityTierMultiplier(uint256 t) external view returns (uint256) {

        return rarityTiers[t];
    }

    function getLevel(uint256 tokenId) public view returns (uint256 level) {

        uint256 _level = uint256(getXpEarned(tokenId) / 10**expDecimals / 100) + 1;
        return _level > maxLevel ? maxLevel : _level;
    }

    function getProgress(uint256[] calldata tokenIds) external view returns(uint256[] memory xps) {

        for (uint i;i<tokenIds.length;i++){
            xps[i] = getXpEarned(tokenIds[i]);
        }
    }

    function getLevels(address account)
        external
        view
        returns (uint256[] memory)
    {

        uint256[] memory tokenIds = getStakedIds(account);
        uint256[] memory levels = new uint256[](tokenIds.length);
        for (uint256 i = 0; i < tokenIds.length; i++) {
            levels[i] = getLevel(tokenIds[i]);
        }
        return levels;
    }

    function getMaxLevel(uint256[] calldata tokenIds)
        external
        view
        returns (uint256, uint256)
    {

        uint256 max;
        uint256 maxId;
        for (uint256 i = 0; i < tokenIds.length; i++) {
            if (getLevel(tokenIds[i]) > max) {
                max = getLevel(tokenIds[i]);
                maxId = tokenIds[i];
            }
        }
        return (maxId, max);
    }

    function getLevels2(uint256[] calldata tokenIds)
        external
        view
        returns (uint256[] memory)
    {

        uint256[] memory levels = new uint256[](tokenIds.length);
        for (uint256 i = 0; i < tokenIds.length; i++) {
            levels[i] = getLevel(tokenIds[i]);
        }
        return levels;
    }

    function farmed(address account) external view returns (uint256 amount) {

        return claimedSoFar[account];
    }

    function grantLevels(uint256[] calldata tokenIds, uint256 level)
        external
        onlyOwner
    {

        for (uint256 i; i < tokenIds.length; i++) {
            experiences[tokenIds[i]] += 100 * 10**expDecimals * level;
        }
    }
}