
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


interface IERC20Metadata is IERC20 {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function decimals() external view returns (uint8);

}// MIT

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

}// MIT

pragma solidity ^0.8.0;


abstract contract ERC20Burnable is Context, ERC20 {
    function burn(uint256 amount) public virtual {
        _burn(_msgSender(), amount);
    }

    function burnFrom(address account, uint256 amount) public virtual {
        uint256 currentAllowance = allowance(account, _msgSender());
        require(currentAllowance >= amount, "ERC20: burn amount exceeds allowance");
        unchecked {
            _approve(account, _msgSender(), currentAllowance - amount);
        }
        _burn(account, amount);
    }
}// MIT

pragma solidity ^0.8.0;


abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _setOwner(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}//MIT
pragma solidity ^0.8.4;


interface IStakingErc721 {
  function ownerOf(uint256 tokenId) external view returns (address);
  function supportsInterface(bytes4 interfaceId)
    external
    view
    returns (bool);
}

interface IMainErc721 {
  function checkBouns(address addr) external view returns (uint256);
}

contract Popmeow is ERC20Burnable, Ownable {

    uint256 private constant VIP_RATE = 34722222222222; // 3 per day
    uint256 private constant NORMAL_RATE = 11574074074074; // 1 per day
    uint256 public maxLoopSize = 200;

    uint256 public tokenCount = 1;

    mapping(uint256 => mapping(uint256 => uint256)) private tokenStorage;
    mapping(uint256 => address) private idToContract;
    mapping(address => uint256) private whiteList;
    mapping(address => uint256) private bounsClaimedList;
    mapping(address => bool) private vipList;
    address private constant popcats = 0x5784fcf6653bE795c138E0db039d1a6410b7c88E;
    bool public stakeOpen = true;

    IMainErc721 private constant mainContract = IMainErc721(popcats);

    constructor() ERC20("Popmeow", "PMW") {
        whiteList[popcats] = tokenCount;
        idToContract[tokenCount] = popcats;
        vipList[popcats] = true;
    }

    modifier stakingActive {
        require(stakeOpen, "Staking not active");
        _;
    }

    function getBouns() view external returns (uint256) {
        uint256 bouns = mainContract.checkBouns(msg.sender);
        require(bouns > 0,"Staking: Sender not in bouns list");
        uint256 remainBouns = bouns - bounsClaimedList[msg.sender];
        require(remainBouns > 0,"Staking: No bouns remain");
        return remainBouns;
    }

    function claimBouns() external {
        uint256 bouns = mainContract.checkBouns(msg.sender);
        uint256 remainBouns = bouns - bounsClaimedList[msg.sender];
        require(remainBouns > 0,"Staking: No bouns remain");
        bounsClaimedList[msg.sender] = bouns;
        _mint(msg.sender, remainBouns);
    }

    function toggleStakingActive() external onlyOwner {
        stakeOpen = !stakeOpen;
    }

    function setVip(address contractAddr, bool status) external onlyOwner {
        vipList[contractAddr] = status;
    }

    function onVip(address contractAddr) external view returns (bool) {
        return vipList[contractAddr];
    }

    function setMaxLoopSize(uint256 size) external onlyOwner {
        require(size > 0,"loop size must greater than 0");
        maxLoopSize = size;
    }
    function unstakeCheck(address contractAddr, uint256[] calldata tokenIds) external view returns (bool[] memory) {
        require(tokenIds.length <= maxLoopSize,"Staking: check stake size exceed");
        uint256 contractId = whiteList[contractAddr];
        require(contractId > 0, "Staking: contract not on whitelist");
        bool[] memory stakeResult = new bool[](tokenIds.length);
        for (uint256 i = 0; i < tokenIds.length; i++) {
            if(tokenStorage[contractId][tokenIds[i]] == 0){
                stakeResult[i] = true;
            }
        }
        return stakeResult;
    }

    function getWhiteList() external view returns (address[] memory) {
        address[] memory contractList = new address[](tokenCount);
        uint256 arrIndex = 0;
        for (uint256 i = 0; i < tokenCount; i++) {
            uint256 indexOfId = i + 1;
            if(idToContract[indexOfId] != address(0)){
                contractList[arrIndex] = idToContract[indexOfId];
                arrIndex++;
            }
        }
        return contractList;
    }
    
    function addToWhitelist(address contractAddr) external onlyOwner {
        IStakingErc721 erc721 = IStakingErc721(contractAddr);
        require(erc721.supportsInterface(0x80ac58cd), "Staking: Erc721 not support");
        tokenCount ++;
        whiteList[contractAddr] = tokenCount;
        idToContract[tokenCount] = contractAddr;
    }

    function removeFromWhitelist(address contractAddr) external onlyOwner {
        uint256 tokenId = whiteList[contractAddr];
        require(tokenId > 0,"Staking: contract not on whitelist");
        idToContract[tokenId] = address(0);
        whiteList[contractAddr] = 0;
    }

    function stakeByToken(address contractAddr, uint256 tokenId) external stakingActive {
        uint256 contractId = whiteList[contractAddr];
        require(contractId > 0, "Staking: contract not on whitelist");
        IStakingErc721 erc721 = IStakingErc721(contractAddr);
        require(erc721.ownerOf(tokenId) == msg.sender, "Staking: Sender not owner");
        require(tokenStorage[contractId][tokenId] == 0,"Staking: token is already staked");
        tokenStorage[contractId][tokenId] = block.timestamp;
    }

    function claimRewardByToken(address contractAddr, uint256 tokenId) external {
        uint256 contractId = whiteList[contractAddr];
        require(contractId > 0, "Staking: contract not on whitelist");
        IStakingErc721 erc721 = IStakingErc721(contractAddr);
        require(erc721.ownerOf(tokenId) == msg.sender, "Staking: Sender not owner");
        uint256 lastStakeTime = tokenStorage[contractId][tokenId];
        require(lastStakeTime > 0,"Staking: token not stake");
        uint256 blocktime = block.timestamp;
        uint256 totalRewards = (blocktime - lastStakeTime) * (vipList[contractAddr] ? VIP_RATE : NORMAL_RATE);
        _mint(msg.sender, totalRewards);
        tokenStorage[contractId][tokenId] = blocktime;
    }

    function stakeByContract(address contractAddr, uint256[] calldata tokenIds) external stakingActive {
        require(tokenIds.length > 0,"Staking: token size must greater than 0");
        require(tokenIds.length <= maxLoopSize,"Staking: stake size exceed");
        uint256 blocktime = block.timestamp;
        uint256 contractId = whiteList[contractAddr];
        IStakingErc721 erc721 = IStakingErc721(contractAddr);
        require(contractId > 0, "Staking: contract not on whitelist");
        for (uint256 i = 0; i < tokenIds.length; i++) {
            uint256 tokenId = tokenIds[i];
            require(erc721.ownerOf(tokenId) == msg.sender, "Staking: contain token not own");
            uint256 lastStakeTime = tokenStorage[contractId][tokenId];
            require(lastStakeTime == 0,"Staking: contain staked token");
            tokenStorage[contractId][tokenId] = blocktime;
        }
    }

    function getContractStakedRewards(address contractAddr, uint256[] calldata tokenIds) external view returns (uint256[] memory) {
        require(tokenIds.length <= maxLoopSize,"Staking: search size exceed");
        uint256 contractId = whiteList[contractAddr];
        require(contractId > 0, "Staking: contract not on whitelist");
        uint256 blocktime = block.timestamp;
        uint256 rate = vipList[contractAddr] ? VIP_RATE : NORMAL_RATE;
        uint256[] memory totalRewards = new uint256[](tokenIds.length);
        for (uint256 i = 0; i < tokenIds.length; i++) {
            uint256 lastStakeTime = tokenStorage[contractId][tokenIds[i]];
            if(lastStakeTime > 0){
                totalRewards[i] = (blocktime - lastStakeTime) * rate;
            }else if(lastStakeTime == 0){
                totalRewards[i] = 0;
            }
        }
        return totalRewards;
    }

    function claimByContract(address contractAddr, uint256[] calldata tokenIds) external stakingActive {
        require(tokenIds.length > 0,"Staking: token size must greater than 0");
        require(tokenIds.length <= maxLoopSize,"Staking: claim size exceed");
        uint256 contractId = whiteList[contractAddr];
        require(contractId > 0, "Staking: contract not on whitelist");
        uint256 blocktime = block.timestamp;
        uint256 totalRewards = 0;
        IStakingErc721 erc721 = IStakingErc721(contractAddr);
        uint256 rate = vipList[contractAddr] ? VIP_RATE : NORMAL_RATE;
        for (uint256 i = 0; i < tokenIds.length; i++) {
            uint256 tokenId = tokenIds[i];
            require(erc721.ownerOf(tokenId) == msg.sender, "Staking: contain token not own");
            uint256 lastStakeTime = tokenStorage[contractId][tokenId];
            require(lastStakeTime > 0,"Staking: contain unstake token");
            tokenStorage[contractId][tokenId] = blocktime;
            totalRewards += ((blocktime - lastStakeTime) * rate);
        }
        if(totalRewards > 0){
        _mint(msg.sender, totalRewards);
        }
    }

}