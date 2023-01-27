
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

    uint256 public stakedSupply;

    mapping(address => uint256[]) internal _stakedTokensOfOwner;
    mapping(uint256 => address) public stakedTokenOwners;

    constructor(address _targetAddress, uint256 _boostRate) {
        targetAddress = _targetAddress;
        boostRate = _boostRate;
    }


    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) public pure override returns (bytes4) {

        return this.onERC721Received.selector;
    }


    function _stake(uint256[] calldata tokenIds) internal {

        stakedSupply += tokenIds.length;
        IERC721 target = IERC721(targetAddress);

        for (uint256 i = 0; i < tokenIds.length; i++) {
            uint256 tokenId = tokenIds[i];
            require(
                target.ownerOf(tokenId) == msg.sender,
                "You must own the token."
            );

            stakedTokenOwners[tokenId] = msg.sender;

            _stakedTokensOfOwner[msg.sender].push(tokenId);
            target.safeTransferFrom(msg.sender, address(this), tokenId);
        }

        emit Staked(msg.sender, tokenIds.length);
    }

    function _withdraw(uint256[] calldata tokenIds) internal {

        stakedSupply -= tokenIds.length;
        IERC721 target = IERC721(targetAddress);

        for (uint256 i = 0; i < tokenIds.length; i++) {
            uint256 tokenId = tokenIds[i];
            require(
                stakedTokenOwners[tokenId] == msg.sender,
                "You must own the token."
            );

            stakedTokenOwners[tokenId] = address(0);

            uint256[] memory newStakedTokensOfOwner = _stakedTokensOfOwner[
                msg.sender
            ];
            for (uint256 q = 0; q < newStakedTokensOfOwner.length; q++) {
                if (newStakedTokensOfOwner[q] == tokenId) {
                    newStakedTokensOfOwner[q] = newStakedTokensOfOwner[
                        newStakedTokensOfOwner.length - 1
                    ];
                }
            }

            _stakedTokensOfOwner[msg.sender] = newStakedTokensOfOwner;
            _stakedTokensOfOwner[msg.sender].pop();

            target.safeTransferFrom(address(this), msg.sender, tokenId);
        }

        emit Withdrawn(msg.sender, tokenIds.length);
    }


    event Staked(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);
}//Unlicense
pragma solidity ^0.8.0;


interface ICoreRewarder {

    function stake(
        address _owner,
        uint256[] calldata tokenIdsForClaim,
        uint256[] calldata tokenIds
    ) external;


    function withdraw(
        address _owner,
        uint256[] calldata tokenIdsForClaim,
        uint256[] calldata tokenIds
    ) external;


    function claim(address owner, uint256[] calldata tokenIds) external;


    function earned(address owner, uint256[] memory tokenIds)
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




contract CoreRewarder is CoreStaking, ICoreRewarder, Ownable, ReentrancyGuard {

    bool public isStakingEnabled;
    bool public isClaimingEnabled;
    address public immutable rewardAddress;

    uint256 public immutable rewardRate;
    uint256 public immutable rewardFrequency;
    uint256 public immutable initialReward;
    uint256 public startTime;
    uint256 public finishTime;

    mapping(uint256 => uint256) public lastClaimTimes;
    mapping(address => uint256) public pendingRewards;

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


    function setStartTime(uint256 _startTime) public onlyOwner {

        require(startTime == 0, "Start time is already set");
        startTime = _startTime;
    }

    function start() public onlyOwner {

        require(startTime == 0, "Start time is already set");
        startTime = block.timestamp;
    }

    function setFinishTime(uint256 _finishTime) public onlyOwner {

        finishTime = _finishTime;
    }

    function finish() public onlyOwner {

        finishTime = block.timestamp;
    }

    function setIsStakingEnabled(bool _isStakingEnabled) public onlyOwner {

        isStakingEnabled = _isStakingEnabled;
    }

    function setIsClaimingEnabled(bool _isClaimingEnabled) public onlyOwner {

        isClaimingEnabled = _isClaimingEnabled;
    }


    function stake(
        address _owner,
        uint256[] calldata tokenIdsForClaim,
        uint256[] calldata tokenIds
    ) public override nonReentrant {

        require(isStakingEnabled, "Stakig is not enabled");
        _updateRewards(_owner, tokenIdsForClaim);
        _stake(tokenIds);
    }

    function withdraw(
        address _owner,
        uint256[] calldata tokenIdsForClaim,
        uint256[] calldata tokenIds
    ) public override nonReentrant {

        _updateRewards(_owner, tokenIdsForClaim);
        _withdraw(tokenIds);
    }

    function claim(address owner, uint256[] calldata tokenIds)
        public
        override
        nonReentrant
    {

        require(isClaimingEnabled, "Claiming is not enabled");
        _claim(owner, tokenIds);
    }

    function earned(address owner, uint256[] calldata tokenIds)
        public
        view
        override
        returns (uint256)
    {

        return _earnedTokenRewards(tokenIds) + pendingRewards[owner];
    }


    function lastClaimTimesOfTokens(uint256[] memory tokenIds)
        public
        view
        override
        returns (uint256[] memory)
    {

        uint256[] memory _lastClaimTimesOfTokens = new uint256[](
            tokenIds.length
        );
        for (uint256 i = 0; i < tokenIds.length; i++) {
            _lastClaimTimesOfTokens[i] = lastClaimTimes[tokenIds[i]];
        }
        return _lastClaimTimesOfTokens;
    }

    function isOwner(address owner, uint256 tokenId)
        public
        view
        override
        returns (bool)
    {

        return _isOwner(owner, tokenId);
    }

    function stakedTokensOfOwner(address owner)
        public
        view
        override
        returns (uint256[] memory)
    {

        return _stakedTokensOfOwner[owner];
    }

    function tokensOfOwner(address owner)
        public
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


    function _updateRewards(address _owner, uint256[] memory _tokenIds)
        internal
    {

        require(
            _tokenIds.length == _allBalanceOf(_owner),
            "Invalid tokenIds for update rewards"
        );
        uint256 rewardAmount = _earnedTokenRewards(_tokenIds);
        _resetTimes(_owner, _tokenIds);
        pendingRewards[_owner] += rewardAmount;
    }

    function _claim(address _owner, uint256[] memory _tokenIds) internal {

        require(
            _tokenIds.length == _allBalanceOf(_owner),
            "Invalid tokenIds for claim"
        );
        uint256 rewardAmount = _earnedTokenRewards(_tokenIds);
        if (rewardAmount == 0) {
            return;
        }
        _resetTimes(_owner, _tokenIds);
        rewardAmount += pendingRewards[_owner];
        pendingRewards[_owner] = 0;
        emit RewardClaimed(_owner, rewardAmount);
        IINT(rewardAddress).mint(_owner, rewardAmount);
    }

    function _resetTimes(address _owner, uint256[] memory _tokenIds) internal {

        uint256 _currentTime = block.timestamp;
        if (finishTime != 0 && finishTime < _currentTime) {
            _currentTime = finishTime;
        }
        for (uint256 i = 0; i < _tokenIds.length; i++) {
            require(
                _isOwner(_owner, _tokenIds[i]),
                "You need to own this token"
            );
            lastClaimTimes[_tokenIds[i]] = _currentTime;
        }
    }

    function _earnedTokenRewards(uint256[] memory _tokenIds)
        internal
        view
        returns (uint256)
    {

        uint256 _startTime = startTime;
        uint256 _currentTime = block.timestamp;
        uint256 _boostRate = boostRate;

        uint256 rewardAmount;
        if (finishTime != 0 && finishTime < _currentTime) {
            _currentTime = finishTime;
        }
        for (uint256 i = 0; i < _tokenIds.length; i++) {
            rewardAmount += _earnedFromToken(
                _tokenIds[i],
                _startTime,
                _currentTime,
                _boostRate
            );
        }
        return rewardAmount;
    }

    function _earnedFromToken(
        uint256 _tokenId,
        uint256 _startTime,
        uint256 _currentTime,
        uint256 _boostRate
    ) internal view returns (uint256) {

        uint256 _lastClaimTimeOfToken = lastClaimTimes[_tokenId];
        uint256 lastClaimTime;

        if (_startTime > _lastClaimTimeOfToken) {
            lastClaimTime = _startTime;
        } else {
            lastClaimTime = _lastClaimTimeOfToken;
        }

        uint256 amount;

        if (_startTime != 0 && _startTime <= _currentTime) {
            uint256 multiplier = stakedTokenOwners[_tokenId] != address(0)
                ? _boostRate
                : 1;
            amount +=
                ((_currentTime - lastClaimTime) / rewardFrequency) *
                rewardRate *
                multiplier *
                1e18;
        }

        if (_lastClaimTimeOfToken == 0) {
            return amount + initialReward;
        }

        return amount;
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

    function _allBalanceOf(address _owner) internal view returns (uint256) {

        return
            ICollection(targetAddress).balanceOf(_owner) +
            _stakedTokensOfOwner[_owner].length;
    }

    event RewardClaimed(address indexed user, uint256 reward);
}//Unlicense
pragma solidity ^0.8.0;



contract TheDudesRewarder is CoreRewarder {

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