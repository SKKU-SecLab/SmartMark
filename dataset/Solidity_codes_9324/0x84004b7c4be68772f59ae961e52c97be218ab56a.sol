



pragma solidity ^0.8.0;

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}




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
        uint256 tokenId,
        bytes calldata data
    ) external;


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


    function setApprovalForAll(address operator, bool _approved) external;


    function getApproved(uint256 tokenId) external view returns (address operator);


    function isApprovedForAll(address owner, address operator) external view returns (bool);

}




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
}




pragma solidity ^0.8.0;

interface IERC20 {

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address to, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

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

    function transfer(address to, uint256 amount) public virtual override returns (bool) {

        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {

        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {

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

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {

        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {

        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
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
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
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
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
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


pragma solidity 0.8.7;






contract HQStaking is ERC20("HQCOIN", "HQCOIN"), Ownable {
    using SafeMath for uint256;
    bool paused = false;
    bool boostersEnabled = false;
    IERC721 nft;

    uint256 private STAKINGREWARD = 1 ether;
    uint256 private STARREWARD = 2 ether;

    mapping(uint256 => bool) private starIds;
    mapping(uint256 => address) public tokenIdOwners;
    mapping(address => uint256) public lastClaimTime;
    mapping(address => uint256) public numberTokensStaked;
    mapping(address => uint256) public numberStarCount;
    mapping(address => uint256) private _balances;
    mapping(address => bool) public staff;
    mapping(address => mapping(uint256 => uint256)) public ownerTokenIds;
    mapping(uint256 => mapping(address => bool)) public boosters;
    mapping(uint256 => uint256) public boosterRewards;
    mapping(uint256 => uint256) public boosterUpgradePrice;

    modifier updateReward(address account) {
        uint256 reward = getRewards(account);
        lastClaimTime[account] = block.timestamp;
        _balances[account] += reward;
        _;
    }

    modifier onlyAllowedContracts() {
        require(staff[msg.sender] || msg.sender == owner());
        _;
    }

    constructor(address _nftAddress) {
        nft = IERC721(_nftAddress);
        boosterRewards[5] = 150;
        boosterRewards[4] = 140;
        boosterRewards[3] = 130;
        boosterRewards[2] = 120;
        boosterRewards[1] = 110;
    }

    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }

    function mintFromExtentionContract(address _user, uint256 _amount)
        external
        onlyAllowedContracts
    {
        _mint(_user, _amount);
    }

    function burnFromExtentionContract(address _user, uint256 _amount)
        external
        onlyAllowedContracts
    {
        _burn(_user, _amount);
    }


    function setBoosterUpgradePrice(uint256 id, uint256 price) external onlyOwner{
        boosterUpgradePrice[id] = price;
    }

    function puchaseBooster(uint256 id) external {
        require(boostersEnabled, "Boosters are not enabled");
        require(id > 0 && id <= 5, "Invalid booster ID");
        require(balanceOf(msg.sender) >=  boosterUpgradePrice[id], "Not enough Native tokens");
        if(id == 1){
            _burn(msg.sender, boosterUpgradePrice[id]);
            boosters[id][msg.sender] = true;
        }else{
            require(boosters[id -1][msg.sender], "You need to own the Tier before this");
            _burn(msg.sender, boosterUpgradePrice[id]);
            boosters[id][msg.sender] = true;
        }
    }

    function setBoosterRewatds(uint256 id, uint256 reward) external onlyOwner{
        boosterRewards[id] = reward;
    }

    function initStars(uint256[] calldata tokenIds, bool state)
        public
        onlyOwner
    {
        unchecked {
            uint256 len = tokenIds.length;
            for (uint256 i = 0; i < len; i++) {
                uint256 tokenId = tokenIds[i];
                starIds[tokenId] = state;
            }
        }
    }

    function isStar(uint256 tokenId) public view returns (bool) {
        return starIds[tokenId];
    }

    function setStakingReward(uint256 val) public onlyOwner {
        STAKINGREWARD = val;
    }

    function setStarReward(uint256 val) public onlyOwner {
        STARREWARD = val;
    }

    function setStaff(address user, bool state) public onlyOwner {
        staff[user] = state;
    }

    function viewRewards(address account) public view returns (uint256) {
        uint256 rewards = getRewards(account);
        return rewards;
    }

    function getRewards(address account) internal view returns (uint256) {
        uint256 _cReward = (numberTokensStaked[account] -
            numberStarCount[account]) * STAKINGREWARD;
        uint256 _legendaryReward = numberStarCount[account] * STARREWARD;
        uint256 totalReward = _cReward + _legendaryReward;
        uint256 _lastClaimed = lastClaimTime[account];
        return totalReward.mul(block.timestamp.sub(_lastClaimed)).div(86400);
    }

    function getBalance(address account) public view returns (uint256) {
        uint256 pendingReward = getRewards(account);
        return pendingReward + _balances[account];
    }

    function claimRewards() external updateReward(msg.sender) {
        uint256 reward = _balances[msg.sender];
        _balances[msg.sender] = 0;
        uint256 bonus = calculateBonus(reward, msg.sender);
        _mint(msg.sender, bonus);
        
    }

    function viewRewardWithBonus(address account)
        public
        view
        returns (uint256)
    {
        uint256 bal = getBalance(account);

       uint256 bonus = calculateBonus(bal, msg.sender);
        return bonus;
    }

    function calculateBonus(uint256 reward, address account)
        internal
        view
        returns (uint256)
    {

        if (boosters[5][account]) {
            return reward.mul(boosterRewards[5]).div(100);
        } else if (boosters[4][account]) {
            return reward.mul(boosterRewards[4]).div(100);
        } else if (boosters[3][account]) {
            return reward.mul(boosterRewards[3]).div(100);
        } else if (boosters[2][account]) {
            return reward.mul(boosterRewards[2]).div(100);
        } else if (boosters[1][account]) {
            return reward.mul(boosterRewards[1]).div(100);
        } else {
            return reward;
        }
    }

    function getUserstakedIds(address _user)
        public
        view
        returns (uint256[] memory)
    {
        uint256 len = numberTokensStaked[_user];
        uint256[] memory temp = new uint256[](len);
        for (uint256 i = 0; i < len; ++i) {
            temp[i] = ownerTokenIds[_user][i];
        }
        return temp;
    }

    function stake(uint256[] calldata tokenIds)
        external
        updateReward(msg.sender)
    {
        require(!paused, "Contract is paused");
        unchecked {
            uint256 len = tokenIds.length;
            uint256 numStaked = numberTokensStaked[msg.sender];
            for (uint256 i = 0; i < len; i++) {
                uint256 tokenId = tokenIds[i];
                if (starIds[tokenId]) {
                    numberStarCount[msg.sender]++;
                }
                tokenIdOwners[tokenId] = msg.sender;
                ownerTokenIds[msg.sender][numStaked] = tokenId;
                numStaked++;
                nft.transferFrom(msg.sender, address(this), tokenId);
            }
            numberTokensStaked[msg.sender] = numStaked;
        }
    }

    function unstake(uint256[] calldata tokenIds)
        external
        updateReward(msg.sender)
    {
        unchecked {
            uint256 len = tokenIds.length;

            for (uint256 i = 0; i < len; i++) {
                uint256 tokenId = tokenIds[i];
                if (starIds[tokenId]) {
                    numberStarCount[msg.sender]--;
                }
                require(
                    tokenIdOwners[tokenId] == msg.sender,
                    "You dont own this ID"
                );
                removeFromUserStakedTokens(msg.sender, tokenId);

                numberTokensStaked[msg.sender]--;

                delete tokenIdOwners[tokenId];
                nft.transferFrom(address(this), msg.sender, tokenId);
            }
        }
    }

    function togglePause() public onlyOwner {
        paused = !paused;
    }

     function toogleBoostersEnabled() public onlyOwner {
        boostersEnabled = !boostersEnabled;
    }

    function removeFromUserStakedTokens(address user, uint256 tokenId)
        internal
    {
        uint256 _numStaked = numberTokensStaked[user];
        for (uint256 j = 0; j < _numStaked; ++j) {
            if (ownerTokenIds[user][j] == tokenId) {
                uint256 lastIndex = _numStaked - 1;
                ownerTokenIds[user][j] = ownerTokenIds[user][lastIndex];
                delete ownerTokenIds[user][lastIndex];
                break;
            }
        }
    }
}