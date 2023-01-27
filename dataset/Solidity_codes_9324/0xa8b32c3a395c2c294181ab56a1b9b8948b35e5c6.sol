





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

    function balanceOf(address account) public view virtual override returns (uint256) {

        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {

        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {

        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {

        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {

        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        unchecked {
            _approve(sender, _msgSender(), currentAllowance - amount);
        }

        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {

        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(_msgSender(), spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {

        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[sender] = senderBalance - amount;
        }
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);

        _afterTokenTransfer(sender, recipient, amount);
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




pragma solidity ^0.8.9;



interface TokenContract { 
    function allowanceFor(address spender) external view returns(uint256); 
    function transferFrom(address _from, address _to, uint256 _value) external returns(bool); 
    function balanceOf(address owner) external view returns(uint); function burnFrom(address account, uint256 amount) external; 
}

interface NFTContract { 
    function ownerOf(uint256 _tokenId) external view returns (address); 
    function transferFrom(address from, address to, uint tokenId) external payable; 
} 

contract BulldogsStaking is ReentrancyGuard {

    event _adminSetCollectionEarnRate(uint collectionId, uint _earnRate);
    event _adminSetCollectionSwapCost(uint collectionId, uint _swapRate);
    event _adminSetTokensCollections(uint[] _tokenIds, uint _collectionId);
    event _adminSetMinStakingPerion(uint period);
    event _adminSetFreezePeriod(uint period);
    event _adminSetClaimableBalance(address[] _address, uint amount);
    event _adminAddBonus(address[] _address, uint amount);

    event _userSetTokenCollection(uint _tokenId, uint _collectionId);
    event _setTokenContract(address _address);
    event _setNFTContract(address _address);

    event Staked(uint tokenId);
    event Unstaked(uint256 tokenId);
    event BBonesClaimed(address _address, uint amount);
    event bulldogUpgraded(uint tokenId);
    event bulldogSwapped(uint tokenId);

    address private _owner;
    address private _tokenContractAddress;
    address private _nftContractAddress;

    uint minStakingPeriod = 930;

    uint freezePeriod = 20000;


    mapping(uint => uint) public tokensData;

    mapping(uint => uint) public earnRates;

    mapping(uint => uint) public upgradeabilityCost;

    mapping(uint => uint) public swappingCost;

    mapping(address => uint) public claimableBalance;

    struct Staker {
        uint[] stakedTokens;

        mapping(uint => uint) tokenStakeBlock;
    }

    mapping(address => Staker) private stakeHolders;


    constructor () {
        _owner = msg.sender;

        earnRates[1] = 1;
        earnRates[2] = 2;
        earnRates[3] = 8;
        earnRates[4] = 24;
        earnRates[5] = 36;
        earnRates[6] = 0;

        upgradeabilityCost[1] = 100;
        upgradeabilityCost[2] = 400;
        upgradeabilityCost[3] = 2400;
        upgradeabilityCost[4] = 4800;

        swappingCost[1] = 50;
        swappingCost[2] = 200;
        swappingCost[3] = 1200;
        swappingCost[4] = 2400;
        swappingCost[5] = 3200;
    }


    modifier onlyOwner {
        require(msg.sender == _owner || msg.sender == address(this), "You're not owner");
        _;
    }

    modifier staked(uint tokenId)  {
        require(stakeHolders[msg.sender].tokenStakeBlock[tokenId] != 0, "You have not staked this token");
        _;
    }

    modifier notStaked(uint tokenId) {
        require(stakeHolders[msg.sender].tokenStakeBlock[tokenId] == 0, "You have already staked this token");
        _;
    }

    modifier freezePeriodPassed(uint tokenId) {
        uint blockNum = stakeHolders[msg.sender].tokenStakeBlock[tokenId];
        require(blockNum + freezePeriod <= block.number, "This token is freezed, try again later");
        _;
    }

    modifier ownerOfToken(uint tokenId) {
        require(msg.sender == NFTContract(_nftContractAddress).ownerOf(tokenId) || stakeHolders[msg.sender].tokenStakeBlock[tokenId] > 0, "You are not owner of this token");
        _;
    }


    function adminSetCollectionEarnRate(uint collectionId, uint _earnRate) external onlyOwner {
        earnRates[collectionId] = _earnRate;
        emit _adminSetCollectionEarnRate(collectionId, _earnRate);
    }

    function adminSetCollectionSwapCost(uint collectionId, uint _swapCost) external onlyOwner {
        swappingCost[collectionId] = _swapCost;
        emit _adminSetCollectionSwapCost(collectionId, _swapCost);
    }

    function adminSetTokensCollections(uint[] memory _tokenIds, uint _collectionId) external onlyOwner {
        for (uint i=0; i < _tokenIds.length; i++) {
            tokensData[_tokenIds[i]] = _collectionId;
        }
        emit _adminSetTokensCollections(_tokenIds, _collectionId);
    }

    function adminSetClaimableBalance(address[] memory _address, uint amount) external onlyOwner {
        for (uint i=0; i < _address.length; i++) {
            claimableBalance[_address[i]] = amount;
        }
        emit _adminSetClaimableBalance(_address, amount);
    }

    function adminAddBonus(address[] memory _address, uint amount) public onlyOwner {
        for (uint i=0; i < _address.length; i++) {
            claimableBalance[_address[i]] += amount;
        }
        emit _adminAddBonus(_address, amount);
    }

    function userSetTokenCollection(uint _tokenId, uint _collectionId) internal {
        tokensData[_tokenId] = _collectionId;
        emit _userSetTokenCollection(_tokenId, _collectionId);
    }

    function setMinStakingPeriod(uint period) public onlyOwner {
        minStakingPeriod = period;
        emit _adminSetMinStakingPerion(period);
    }

    function setFreezePeriod(uint period) public onlyOwner {
        freezePeriod = period;
        emit _adminSetFreezePeriod(period);
    }


    function setTokenContract(address _address) public onlyOwner {
        _tokenContractAddress = _address;
        emit _setTokenContract(_address);
    }

    function setNFTContract(address _address) public onlyOwner {
        _nftContractAddress = _address;
        emit _setNFTContract(_address);
    }



    function getBlocksTillUnfreeze(uint tokenId, address _address) public view returns(uint) {
        uint blocksPassed = block.number - stakeHolders[_address].tokenStakeBlock[tokenId];
        if (blocksPassed >= freezePeriod) {
            return 0;
        }
        return freezePeriod - blocksPassed;
    }

    function getTokenEarnRate(uint _tokenId) public view returns(uint tokenEarnRate) {
        return earnRates[tokensData[_tokenId]];
    }

    function getTokenUPNL(uint tokenId, address _address) public view returns(uint) {

        if (stakeHolders[_address].tokenStakeBlock[tokenId] == 0) {
            return 0;
        }

        uint tokenBlockDiff = block.number - stakeHolders[_address].tokenStakeBlock[tokenId];

        if (tokenBlockDiff <= freezePeriod) {
            return 0;
        }

        if (tokenBlockDiff >= minStakingPeriod) {
            uint quotient;
            uint remainder;

            (quotient, remainder) = superDivision(tokenBlockDiff, minStakingPeriod);
            if (quotient > 0) {
                uint blockRate = getTokenEarnRate(tokenId);
                uint tokenEarnings = blockRate * quotient;
                return tokenEarnings;

            }
        }
        return 0;
    }

    function getTotalUPNL(address _address) public view returns(uint) {
        uint totalUPNL = 0;

        uint tokensCount = stakeHolders[_address].stakedTokens.length;
        for (uint i = 0; i < tokensCount; i++) {
            totalUPNL += getTokenUPNL(stakeHolders[_address].stakedTokens[i], _address);
        }
        return totalUPNL;
    }



    function stake(uint tokenId, uint tokenCollection) public nonReentrant notStaked(tokenId) ownerOfToken(tokenId) {
        if (tokensData[tokenId] == 0) {
            userSetTokenCollection(tokenId, tokenCollection);
        }

        require(tokensData[tokenId] >= 1 && tokensData[tokenId] < 6, "You cannot stake this bulldog");

        NFTContract(_nftContractAddress).transferFrom(msg.sender, address(this), tokenId);

        stakeHolders[msg.sender].tokenStakeBlock[tokenId] = block.number + 1;
        stakeHolders[msg.sender].stakedTokens.push(tokenId);

        emit Staked(tokenId);
    }

    function unstake(uint256 tokenId) public nonReentrant ownerOfToken(tokenId) staked(tokenId) freezePeriodPassed(tokenId) {
        claimableBalance[msg.sender] += getTokenUPNL(tokenId, msg.sender);

        stakeHolders[msg.sender].tokenStakeBlock[tokenId] = 0;

        uint tokensCount = stakeHolders[msg.sender].stakedTokens.length;

        uint[] memory newStakedTokens = new uint[](tokensCount - 1);

        uint j = 0;
        for (uint i = 0; i < tokensCount; i++) {
            if (stakeHolders[msg.sender].stakedTokens[i] != tokenId) {
                newStakedTokens[j] = stakeHolders[msg.sender].stakedTokens[i];
                j += 1;
            }
        }
        stakeHolders[msg.sender].stakedTokens = newStakedTokens;

        NFTContract(_nftContractAddress).transferFrom(address(this), msg.sender, tokenId);

        emit Unstaked(tokenId);

    }

    function superDivision(uint numerator, uint denominator) internal pure returns(uint quotient, uint remainder) {
        quotient  = numerator / denominator;
        remainder = numerator - denominator * quotient;
    }

    function claimBBones(address _address) public nonReentrant {

        uint amountToPay = 0;
        uint tokensCount = stakeHolders[_address].stakedTokens.length;

        for (uint i = 0; i < tokensCount; i++) {
            uint tokenId = stakeHolders[_address].stakedTokens[i];
            uint tokenBlockDiff = block.number - stakeHolders[_address].tokenStakeBlock[tokenId];

            if (tokenBlockDiff >= minStakingPeriod && stakeHolders[_address].tokenStakeBlock[tokenId] + freezePeriod <= block.number) {
                uint quotient;
                uint remainder;

                (quotient, remainder) = superDivision(tokenBlockDiff, minStakingPeriod);
                if (quotient > 0) {
                    uint blockRate = getTokenEarnRate(tokenId);
                    uint tokenEarnings = blockRate * quotient;
                    amountToPay += tokenEarnings;

                    stakeHolders[_address].tokenStakeBlock[tokenId] = block.number - remainder + 1;
                }
            }
        }

        if (claimableBalance[_address] > 0) {
            amountToPay += claimableBalance[_address];
            claimableBalance[_address] = 0;
        }

        TokenContract(_tokenContractAddress).transferFrom(_tokenContractAddress, _address, amountToPay);
        emit BBonesClaimed(_address, amountToPay);
    }

    function stakedTokensOf(address _address) public view returns (uint[] memory) {
        return stakeHolders[_address].stakedTokens;
    }


    function upgradeBulldog(uint tokenId, uint collectionId, uint upgradeType) public nonReentrant ownerOfToken(tokenId) {

        if (tokensData[tokenId] == 0) {
            tokensData[tokenId] = collectionId;
        }

        require(tokensData[tokenId] >= 1 && tokensData[tokenId] < 5, "Your bulldog cannot be upgraded further");

        require(TokenContract(_tokenContractAddress).balanceOf(msg.sender) >= upgradeabilityCost[tokensData[tokenId]], "You don't have enough $BBONES");

        if (upgradeType == 1) {

            if (stakeHolders[msg.sender].tokenStakeBlock[tokenId] > 0) {
                claimableBalance[msg.sender] += getTokenUPNL(tokenId, msg.sender);

                stakeHolders[msg.sender].tokenStakeBlock[tokenId] = block.number + 1;
            }
            TokenContract(_tokenContractAddress).burnFrom(msg.sender, upgradeabilityCost[tokensData[tokenId]]);
            tokensData[tokenId] += 1;
            emit bulldogUpgraded(tokenId);
        }

        if (upgradeType == 2) {
            TokenContract(_tokenContractAddress).burnFrom(msg.sender, upgradeabilityCost[tokensData[tokenId]]);
            emit bulldogSwapped(tokenId);
        }
    }
}


