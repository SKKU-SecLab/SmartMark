

pragma solidity 0.8.11;



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


pragma solidity ^0.8.0;

interface IERC20 {

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


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}


pragma solidity ^0.8.0;

interface IERC20Metadata is IERC20 {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function decimals() external view returns (uint8);

}


pragma solidity ^0.8.0;

contract ERC20 is Context, IERC20, IERC20Metadata {

    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    function name() public view virtual override returns (string memory) {

        return _name;
    }

    function symbol() public view virtual override returns (string memory) {

        return _symbol;
    }

    function decimals() public view virtual override returns (uint8) {

        return 18;
    }

    function totalSupply() public view virtual override returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address account)
        public
        view
        virtual
        override
        returns (uint256)
    {

        return _balances[account];
    }

    function transfer(address to, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {

        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    function allowance(address owner, address spender)
        public
        view
        virtual
        override
        returns (uint256)
    {

        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {

        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {

        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue)
        public
        virtual
        returns (bool)
    {

        address owner = _msgSender();
        _approve(owner, spender, _allowances[owner][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        virtual
        returns (bool)
    {

        address owner = _msgSender();
        uint256 currentAllowance = _allowances[owner][spender];
        require(
            currentAllowance >= subtractedValue,
            "ERC20: decreased allowance below zero"
        );
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {

        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(
            fromBalance >= amount,
            "ERC20: transfer amount exceeds balance"
        );
        unchecked {
            _balances[from] = fromBalance - amount;
        }
        _balances[to] += amount;

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {

        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {

        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(
                currentAllowance >= amount,
                "ERC20: insufficient allowance"
            );
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}


    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

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

pragma solidity 0.8.11;

interface ICryptoBearWatchClub {
    function ownerOf(uint256 tokenId) external view returns (address owner);

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;
}

pragma solidity 0.8.11;

contract Arkouda is ERC20, Ownable, IERC721Receiver {
    ICryptoBearWatchClub public CryptoBearWatchClub;

    enum TX_TYPE {
        UNSTAKE,
        CLAIM
    }

    bool public stakingLive;

    uint256 public constant tier1Reward = 30 ether;
    uint256 public constant tier2Reward = 9 ether;
    uint256 public constant tier3Reward = 3 ether;

    mapping(uint256 => uint256) public tokenIdTier;

    mapping(uint256 => address) public tokenOwner;

    mapping(address => mapping(uint256 => uint256)) public lastUpdate;

    mapping(address => bool) public allowedAddresses;

    event Staked(address indexed staker, uint256[] tokenIds, uint256 stakeTime);
    event Unstaked(address indexed unstaker, uint256[] tokenIds);
    event RewardsPaid(
        address indexed claimer,
        uint256[] tokenIds,
        uint256 _tier1Rewards,
        uint256 _tier2Rewards,
        uint256 _tier3Rewards
    );

    constructor(ICryptoBearWatchClub _cryptoBearWatchClub)
        ERC20("Arkouda", "$ark")
    {
        CryptoBearWatchClub = _cryptoBearWatchClub;
    }

    modifier isTokenOwner(uint256[] memory _tokenIds) {
        for (uint256 i = 0; i < _tokenIds.length; i++) {
            require(
                tokenOwner[_tokenIds[i]] == _msgSender(),
                "CALLER_IS_NOT_STAKER"
            );
        }
        _;
    }

    modifier isStakingLive() {
        require(stakingLive, "STAKING_IS_NOT_LIVE_YET");
        _;
    }

    modifier checkInputLength(uint256[] memory _tokenIds) {
        require(_tokenIds.length > 0, "INVALID_INPUT_LENGTH");
        _;
    }

    function startStaking() external onlyOwner {
        require(!stakingLive, "STAKING_IS_ALREADY_LIVE");
        stakingLive = true;
    }

    function setAllowedAddresses(address _address, bool _access)
        external
        onlyOwner
    {
        allowedAddresses[_address] = _access;
    }

    function setCBWCNFTTier(uint256[] calldata _tokenIds, uint256 _tier)
        external
        onlyOwner
    {
        require(_tier == 1 || _tier == 2, "INVALID_TIER");
        for (uint256 i = 0; i < _tokenIds.length; i++) {
            require(tokenIdTier[_tokenIds[i]] == 0, "TIER_ALREADY_SET");
            tokenIdTier[_tokenIds[i]] = _tier;
        }
    }

    function onERC721Received(
        address,
        address,
        uint256,
        bytes memory
    ) external pure override returns (bytes4) {
        return this.onERC721Received.selector;
    }

    function burn(uint256 amount) external {
        require(
            allowedAddresses[_msgSender()],
            "ADDRESS_DOES_NOT_HAVE_PERMISSION_TO_BURN"
        );
        _burn(_msgSender(), amount);
    }

    function stakeCBWC(uint256[] calldata _tokenIds)
        external
        isStakingLive
        checkInputLength(_tokenIds)
    {
        for (uint256 i = 0; i < _tokenIds.length; i++) {
            require(
                CryptoBearWatchClub.ownerOf(_tokenIds[i]) == _msgSender(),
                "CBWC_NFT_IS_NOT_YOURS"
            );

            CryptoBearWatchClub.safeTransferFrom(
                _msgSender(),
                address(this),
                _tokenIds[i]
            );

            tokenOwner[_tokenIds[i]] = _msgSender();

            lastUpdate[_msgSender()][_tokenIds[i]] = block.timestamp;
        }

        emit Staked(_msgSender(), _tokenIds, block.timestamp);
    }

    function unStakeCBWC(uint256[] calldata _tokenIds)
        external
        isStakingLive
        isTokenOwner(_tokenIds)
        checkInputLength(_tokenIds)
    {
        claimOrUnstake(_tokenIds, TX_TYPE.UNSTAKE);
        emit Unstaked(_msgSender(), _tokenIds);
    }

    function claimRewards(uint256[] calldata _tokenIds)
        external
        isStakingLive
        isTokenOwner(_tokenIds)
        checkInputLength(_tokenIds)
    {
        claimOrUnstake(_tokenIds, TX_TYPE.CLAIM);
    }

    function claimOrUnstake(uint256[] memory _tokenIds, TX_TYPE txType)
        private
    {
        uint256 rewards;
        uint256 _tier1Rewards;
        uint256 _tier2Rewards;
        uint256 _tier3Rewards;
        uint256 tier;

        for (uint256 i = 0; i < _tokenIds.length; i++) {
            (rewards, tier) = getPendingRewardAndTier(_tokenIds[i]);
            if (tier == 1) {
                _tier1Rewards += rewards;
            } else if (tier == 2) {
                _tier2Rewards += rewards;
            } else {
                _tier3Rewards += rewards;
            }

            if (txType == TX_TYPE.UNSTAKE) {
                CryptoBearWatchClub.safeTransferFrom(
                    address(this),
                    _msgSender(),
                    _tokenIds[i]
                );

                tokenOwner[_tokenIds[i]] = address(0);

                lastUpdate[_msgSender()][_tokenIds[i]] = 0;
            } else {
                lastUpdate[_msgSender()][_tokenIds[i]] = block.timestamp;
            }
        }
        _mint(_msgSender(), (_tier1Rewards + _tier2Rewards + _tier3Rewards));
        emit RewardsPaid(
            _msgSender(),
            _tokenIds,
            _tier1Rewards,
            _tier2Rewards,
            _tier3Rewards
        );
    }

    function getTotalClaimable(uint256[] memory _tokenIds)
        external
        view
        returns (uint256 totalRewards)
    {
        for (uint256 i = 0; i < _tokenIds.length; i++) {
            totalRewards += getPendingReward(_tokenIds[i]);
        }
    }

    function getPendingReward(uint256 _tokenId)
        public
        view
        returns (uint256 reward)
    {
        if (lastUpdate[_msgSender()][_tokenId] == 0) {
            return 0;
        }
        (reward, ) = getPendingRewardAndTier(_tokenId);
    }

    function getPendingRewardAndTier(uint256 _tokenId)
        private
        view
        returns (uint256 rewards, uint256 tier)
    {
        uint256 secondsHeld = block.timestamp -
            lastUpdate[_msgSender()][_tokenId];

        if (tokenIdTier[_tokenId] == 1) {
            return (((tier1Reward * secondsHeld) / 86400), 1);
        } else if (tokenIdTier[_tokenId] == 2) {
            return (((tier2Reward * secondsHeld) / 86400), 2);
        } else {
            return (((tier3Reward * secondsHeld) / 86400), 3);
        }
    }
}