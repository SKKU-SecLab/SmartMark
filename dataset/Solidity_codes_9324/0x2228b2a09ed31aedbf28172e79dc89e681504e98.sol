
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

}//Unlicense
pragma solidity ^0.8.0;



contract CoreStaking is IERC721Receiver {

    address public immutable targetAddress;
    uint256 public immutable boostRate;

    mapping(address => uint256[]) internal _stakedTokensOfOwner;
    mapping(uint256 => address) public stakedTokenOwners;

    constructor(address _targetAddress, uint256 _boostRate) {
        targetAddress = _targetAddress;
        boostRate = _boostRate;
    }


    function onERC721Received(
        address,
        address,
        uint256,
        bytes calldata
    ) public pure override returns (bytes4) {

        return this.onERC721Received.selector;
    }


    function _stake(address _owner, uint256[] calldata tokenIds) internal {

        IERC721 target = IERC721(targetAddress);

        for (uint256 i = 0; i < tokenIds.length; i++) {
            uint256 tokenId = tokenIds[i];
            stakedTokenOwners[tokenId] = _owner;
            _stakedTokensOfOwner[_owner].push(tokenId);
            target.safeTransferFrom(_owner, address(this), tokenId);
        }

        emit Staked(_owner, tokenIds);
    }

    function _withdraw(address _owner, uint256[] calldata tokenIds) internal {

        IERC721 target = IERC721(targetAddress);

        for (uint256 i = 0; i < tokenIds.length; i++) {
            uint256 tokenId = tokenIds[i];
            require(
                stakedTokenOwners[tokenId] == _owner,
                "You must own the token."
            );

            stakedTokenOwners[tokenId] = address(0);

            uint256[] memory newStakedTokensOfOwner = _stakedTokensOfOwner[
                _owner
            ];
            for (uint256 q = 0; q < newStakedTokensOfOwner.length; q++) {
                if (newStakedTokensOfOwner[q] == tokenId) {
                    newStakedTokensOfOwner[q] = newStakedTokensOfOwner[
                        newStakedTokensOfOwner.length - 1
                    ];
                }
            }

            _stakedTokensOfOwner[_owner] = newStakedTokensOfOwner;
            _stakedTokensOfOwner[_owner].pop();

            target.safeTransferFrom(address(this), _owner, tokenId);
        }

        emit Withdrawn(_owner, tokenIds);
    }

    function _stakingMultiplierForToken(uint256 _tokenId)
        internal
        view
        returns (uint256)
    {

        return stakedTokenOwners[_tokenId] != address(0) ? boostRate : 1;
    }


    event Staked(address indexed user, uint256[] tokenIds);
    event Withdrawn(address indexed user, uint256[] tokenIds);
}//Unlicense
pragma solidity ^0.8.0;


interface ICoreRewarder {

    function stake(
        uint256[] calldata tokenIds
    ) external;


    function withdraw(
        uint256[] calldata tokenIds
    ) external;


    function claim(uint256[] calldata tokenIds) external;


    function earned(uint256[] memory tokenIds)
        external
        view
        returns (uint256);


    function lastClaimTimesOfTokens(uint256[] memory tokenIds)
        external
        view
        returns (uint256[] memory);


    function isOwner(address owner, uint256 tokenId)
        external
        view
        returns (bool);


    function tokensOfOwner(address _owner)
        external
        view
        returns (uint256[] memory);


    function stakedTokensOfOwner(address owner)
        external
        view
        returns (uint256[] memory);

}//Unlicense
pragma solidity ^0.8.0;


interface ICollection {

    function balanceOf(address owner) external view returns (uint256 balance);


    function ownerOf(uint256 tokenId) external view returns (address owner);


    function tokensOfOwner(address _owner)
        external
        view
        returns (uint256[] memory);

}//Unlicense
pragma solidity ^0.8.0;


interface IINT {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address to, uint256 amount) external returns (bool);


    function allowance(address owner, address spender)
        external
        view
        returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);


    function mint(address to, uint256 amount) external;


    function burnFrom(address account, uint256 amount) external;

}//Unlicense
pragma solidity ^0.8.0;




contract CoreRewarder is ICoreRewarder, CoreStaking, Ownable {

    struct TokenStatus {
        uint128 lastClaimTime;
        uint128 pendingReward;
    }

    bool public isStakingEnabled;
    bool public isClaimingEnabled;

    address public immutable rewardAddress;
    uint256 public immutable rewardRate;
    uint256 public immutable rewardFrequency;
    uint256 public immutable initialReward;

    uint256 public startTime;
    uint256 public finishTime;

    mapping(uint256 => TokenStatus) public tokenStatusses;

    constructor(
        address _targetAddress,
        address _rewardAddress,
        uint256 _rewardRate,
        uint256 _rewardFrequency,
        uint256 _initialReward,
        uint256 _boostRate
    ) CoreStaking(_targetAddress, _boostRate) {
        rewardAddress = _rewardAddress;
        rewardRate = _rewardRate;
        rewardFrequency = _rewardFrequency;
        initialReward = _initialReward;
    }


    function setStartTime(uint256 _startTime) external onlyOwner {

        require(startTime == 0, "Start time is already set");
        startTime = _startTime;
    }

    function start() external onlyOwner {

        require(startTime == 0, "Start time is already set");
        startTime = block.timestamp;
    }

    function setFinishTime(uint256 _finishTime) external onlyOwner {

        finishTime = _finishTime;
    }

    function finish() external onlyOwner {

        finishTime = block.timestamp;
    }

    function setIsStakingEnabled(bool _isStakingEnabled) external onlyOwner {

        isStakingEnabled = _isStakingEnabled;
    }

    function setIsClaimingEnabled(bool _isClaimingEnabled) external onlyOwner {

        isClaimingEnabled = _isClaimingEnabled;
    }


    function stake(uint256[] calldata tokenIds) external override {

        require(isStakingEnabled, "Stakig is not enabled");
        if (_isRewardingStarted(startTime)) {
            _updatePendingRewards(msg.sender, tokenIds);
        }
        _stake(msg.sender, tokenIds);
    }

    function withdraw(uint256[] calldata tokenIds) external override {

        if (_isRewardingStarted(startTime)) {
            _updatePendingRewards(msg.sender, tokenIds);
        }
        _withdraw(msg.sender, tokenIds);
    }

    function claim(uint256[] calldata tokenIds) external override {

        require(isClaimingEnabled, "Claiming is not enabled");
        _claim(msg.sender, tokenIds);
    }

    function earned(uint256[] calldata tokenIds)
        external
        view
        override
        returns (uint256)
    {

        if (!_isRewardingStarted(startTime)) {
            return initialReward * tokenIds.length;
        }
        return _earnedRewards(tokenIds);
    }


    function lastClaimTimesOfTokens(uint256[] memory tokenIds)
        external
        view
        override
        returns (uint256[] memory)
    {

        uint256[] memory _lastClaimTimesOfTokens = new uint256[](
            tokenIds.length
        );
        for (uint256 i = 0; i < tokenIds.length; i++) {
            _lastClaimTimesOfTokens[i] = tokenStatusses[tokenIds[i]]
                .lastClaimTime;
        }
        return _lastClaimTimesOfTokens;
    }

    function isOwner(address owner, uint256 tokenId)
        external
        view
        override
        returns (bool)
    {

        return _isOwner(owner, tokenId);
    }

    function stakedTokensOfOwner(address owner)
        external
        view
        override
        returns (uint256[] memory)
    {

        return _stakedTokensOfOwner[owner];
    }

    function tokensOfOwner(address owner)
        external
        view
        override
        returns (uint256[] memory)
    {

        uint256[] memory tokenIds = ICollection(targetAddress).tokensOfOwner(
            owner
        );
        uint256[] memory stakedTokensIds = _stakedTokensOfOwner[owner];
        uint256[] memory mergedTokenIds = new uint256[](
            tokenIds.length + stakedTokensIds.length
        );
        for (uint256 i = 0; i < tokenIds.length; i++) {
            mergedTokenIds[i] = tokenIds[i];
        }
        for (uint256 i = 0; i < stakedTokensIds.length; i++) {
            mergedTokenIds[i + tokenIds.length] = stakedTokensIds[i];
        }
        return mergedTokenIds;
    }


    function _claim(address _owner, uint256[] memory _tokenIds) internal {

        uint256 rewardAmount = _earnedRewards(_tokenIds);
        _resetPendingRewards(_owner, _tokenIds);

        require(rewardAmount != 0, "Can't claim 0 rewards");

        emit RewardClaimed(_owner, rewardAmount);
        IINT(rewardAddress).mint(_owner, rewardAmount);
    }

    function _updatePendingRewards(address _owner, uint256[] memory _tokenIds)
        internal
    {

        uint256 _startTime = startTime;
        uint256 _currentTime = _fixedCurrentTime();

        for (uint256 i = 0; i < _tokenIds.length; i++) {
            require(
                _isOwner(_owner, _tokenIds[i]),
                "You need to own this token"
            );

            TokenStatus memory status = tokenStatusses[_tokenIds[i]];
            status.pendingReward += uint128(
                _earnedTokenReward(_tokenIds[i], _startTime, _currentTime)
            );
            status.lastClaimTime = uint128(_currentTime);
            tokenStatusses[_tokenIds[i]] = status;
        }
    }

    function _resetPendingRewards(address _owner, uint256[] memory _tokenIds)
        internal
    {

        uint256 _currentTime = _fixedCurrentTime();

        for (uint256 i = 0; i < _tokenIds.length; i++) {
            require(
                _isOwner(_owner, _tokenIds[i]),
                "You need to own this token"
            );

            TokenStatus memory status = tokenStatusses[_tokenIds[i]];
            status.pendingReward = 0;
            status.lastClaimTime = uint128(_currentTime);
            tokenStatusses[_tokenIds[i]] = status;
        }
    }

    function _earnedRewards(uint256[] memory _tokenIds)
        internal
        view
        returns (uint256)
    {

        uint256 _startTime = startTime;
        uint256 _currentTime = _fixedCurrentTime();
        uint256 rewardAmount;

        for (uint256 i = 0; i < _tokenIds.length; i++) {
            rewardAmount += _earnedTokenReward(
                _tokenIds[i],
                _startTime,
                _currentTime
            );
            rewardAmount += tokenStatusses[_tokenIds[i]].pendingReward;
        }
        return rewardAmount;
    }

    function _earnedTokenReward(
        uint256 _tokenId,
        uint256 _startTime,
        uint256 _currentTime
    ) internal view returns (uint256) {

        uint256 _lastClaimTimeOfToken = tokenStatusses[_tokenId].lastClaimTime;
        uint256 fixedLastClaimTimeOfToken = _fixedLastClaimTimeOfToken(
            _startTime,
            _lastClaimTimeOfToken
        );

        uint256 multiplier = _stakingMultiplierForToken(_tokenId);
        uint256 amount = ((_currentTime - fixedLastClaimTimeOfToken) /
            rewardFrequency) *
            rewardRate *
            multiplier *
            1e18;

        if (_lastClaimTimeOfToken == 0) {
            return amount + initialReward;
        }

        return amount;
    }

    function _isRewardingStarted(uint256 _startTime)
        internal
        view
        returns (bool)
    {

        if (_startTime != 0 && _startTime < block.timestamp) {
            return true;
        }
        return false;
    }

    function _fixedLastClaimTimeOfToken(
        uint256 _startTime,
        uint256 _lastClaimTimeOfToken
    ) internal pure returns (uint256) {

        if (_startTime > _lastClaimTimeOfToken) {
            return _startTime;
        }
        return _lastClaimTimeOfToken;
    }

    function _fixedCurrentTime() internal view returns (uint256) {

        uint256 period = (block.timestamp - startTime) / rewardFrequency;
        uint256 currentTime = startTime + rewardFrequency * period;
        if (finishTime != 0 && finishTime < currentTime) {
            return finishTime;
        }
        return currentTime;
    }

    function _isOwner(address _owner, uint256 _tokenId)
        internal
        view
        returns (bool)
    {

        if (stakedTokenOwners[_tokenId] == _owner) {
            return true;
        }
        return IERC721(targetAddress).ownerOf(_tokenId) == _owner;
    }

    event RewardClaimed(address indexed user, uint256 reward);
}//Unlicense
pragma solidity ^0.8.0;



contract ThePixelsIncRewarder is CoreRewarder {

    constructor(
        address targetAddress,
        address rewardAddress,
        uint256 rewardRate,
        uint256 rewardFrequency,
        uint256 initialReward,
        uint256 boostRate
    )
        CoreRewarder(
            targetAddress,
            rewardAddress,
            rewardRate,
            rewardFrequency,
            initialReward,
            boostRate
        )
    {}
}