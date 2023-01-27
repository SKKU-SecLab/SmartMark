



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


pragma solidity ^0.8.4;


interface TPT {
    function balanceOf(address owner) external view returns (uint256);
    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256);
}

interface TPTM is TPT {
    function balancesOfOwnerByRarity(address owner) external view returns (uint8[] memory);
}

contract Pencil is ERC20, Ownable {
    TPT public TPTGen1;
    TPT public TPTGen2;
    TPTM public TPTGen3;

    bool public accumulationActive = false;
    bool public accumulationMultiplier = false;
    uint48 public start;
    uint192 public cap;

    struct Level {
        uint64 dailyReward;
        uint64 multiplier;
        uint128 baseClaim;
    }

    struct TokenLengths {
        uint8 level0;
        uint8 level1;
        uint8 level2;
        uint8 level3;
        uint8 level4;
        uint8 level5;
    }

    bool[1953] private _gen1BaseClaimed;
    bool[1953] private _gen2BaseClaimed;
    uint8[1953] private _rewardLevel = [4,4,3,2,4,5,5,1,1,3,2,5,5,5,3,0,4,5,4,4,5,4,1,4,4,0,2,3,0,3,3,3,2,3,2,5,4,5,5,5,3,3,0,2,1,4,4,2,0,3,4,5,5,0,4,3,5,1,4,3,2,3,5,1,2,5,5,5,3,5,5,1,3,0,5,4,3,2,5,5,5,5,0,5,5,2,2,5,5,4,5,3,3,3,4,3,4,4,1,5,3,4,4,2,1,4,0,3,5,3,2,3,5,4,3,4,3,5,5,2,5,4,4,5,5,4,3,5,3,3,1,1,0,5,5,4,5,3,4,4,5,5,4,5,5,2,3,1,3,1,4,2,1,3,3,5,4,5,3,5,5,2,2,5,3,3,4,4,3,1,4,4,2,4,0,5,3,4,2,0,0,3,5,2,5,5,4,3,5,4,4,4,5,5,5,4,3,5,4,5,5,3,2,1,5,2,3,4,4,2,5,4,4,5,5,3,3,4,5,5,1,1,3,5,4,1,3,4,3,5,3,2,4,1,2,5,4,0,0,4,1,0,0,2,5,5,5,4,2,3,5,5,3,4,5,4,3,2,2,4,4,1,4,3,4,4,3,4,5,3,4,4,3,2,5,2,3,3,4,4,4,4,1,5,4,0,4,4,2,3,1,5,3,5,4,3,1,3,5,2,4,1,5,4,2,5,4,3,3,1,5,1,3,4,3,2,5,2,5,5,3,5,1,3,1,5,4,4,4,5,4,1,5,5,0,4,5,1,3,5,2,3,1,4,4,5,4,4,4,5,4,2,3,1,3,4,2,3,1,5,2,3,1,3,4,1,5,2,4,2,5,5,5,1,4,1,4,5,5,4,2,3,2,4,4,3,4,3,0,2,2,4,1,2,1,3,2,3,1,4,4,4,3,3,3,1,3,4,4,4,1,5,3,2,4,4,3,5,4,1,4,2,2,3,3,0,5,5,4,5,5,4,0,4,5,3,3,3,4,4,5,4,2,2,2,1,2,3,3,5,4,5,3,4,4,5,5,5,3,4,1,4,3,4,4,5,4,5,5,3,3,2,2,5,5,4,2,3,3,4,1,4,4,0,2,3,5,5,3,4,4,3,3,5,5,2,4,0,4,2,2,2,5,2,4,1,5,5,4,5,0,5,5,4,5,5,3,0,4,1,5,3,5,1,3,5,5,5,2,3,1,1,2,3,3,5,4,5,2,5,2,1,1,1,3,2,5,3,1,4,2,5,5,2,5,4,4,5,2,5,5,4,5,5,5,1,4,4,5,3,5,4,3,2,1,2,5,5,2,4,0,3,3,4,1,3,3,4,2,5,5,5,4,5,5,4,4,5,3,4,5,4,2,4,3,3,2,0,5,0,3,5,3,3,5,0,3,2,3,3,5,4,1,2,4,2,5,3,0,4,1,1,5,5,3,5,1,3,5,5,4,3,0,1,5,0,5,2,5,4,1,1,5,4,5,3,1,3,5,5,1,4,4,4,1,2,3,1,3,3,3,4,1,5,0,2,5,2,4,5,5,5,3,4,2,0,2,3,3,2,4,3,3,4,2,0,1,4,5,5,4,4,3,1,1,4,3,5,4,1,5,5,4,0,4,4,2,2,5,4,5,4,5,4,3,2,5,4,2,5,5,3,5,1,1,5,3,4,1,5,2,4,5,2,5,2,2,4,5,5,0,1,3,1,4,5,5,5,4,5,3,2,3,4,3,4,2,3,4,2,5,1,2,4,3,4,4,2,4,4,5,4,2,4,2,4,5,5,4,4,4,1,5,1,1,2,1,2,5,5,4,3,2,5,5,3,4,5,0,1,5,3,4,5,5,2,1,5,4,4,5,3,0,1,2,2,1,5,1,5,4,3,5,5,5,4,2,4,4,1,3,3,5,4,0,5,5,5,4,2,2,1,5,4,2,5,4,3,1,3,3,5,2,4,3,5,2,4,5,5,3,2,4,2,5,3,5,5,4,2,4,3,5,3,5,4,0,3,3,4,3,5,2,5,4,1,3,4,0,4,1,5,5,5,4,3,4,4,0,2,5,5,1,3,4,3,5,4,3,2,3,3,2,4,2,4,4,0,5,2,4,2,5,5,4,2,5,0,3,4,5,5,3,5,2,5,2,5,2,5,5,5,5,2,3,4,4,5,1,5,4,4,5,5,5,1,3,5,4,2,1,5,3,3,2,2,5,2,5,0,3,3,4,3,5,3,4,5,5,0,5,5,2,4,5,5,5,4,1,5,5,4,3,5,3,2,5,5,5,3,2,3,5,3,3,5,2,4,1,5,5,3,3,3,4,4,3,5,1,5,3,5,1,3,5,2,5,1,4,5,2,4,3,3,2,3,4,2,5,4,4,0,4,5,1,3,4,4,0,5,5,4,4,4,4,2,3,4,4,0,5,5,3,2,5,3,1,3,3,5,3,5,4,3,5,2,5,5,1,4,3,5,4,5,4,3,4,3,1,3,2,4,3,4,3,4,2,1,1,1,1,2,1,3,2,5,0,3,4,1,3,2,4,4,4,5,4,5,0,2,4,3,2,4,3,3,4,5,5,2,3,4,2,3,1,3,2,3,2,2,1,2,4,3,4,5,2,5,0,4,2,4,5,1,4,2,5,5,4,0,4,4,4,5,4,3,2,4,5,3,3,2,3,5,5,3,4,5,5,5,5,2,2,1,3,5,2,4,2,3,5,0,4,3,5,0,5,4,3,4,4,1,4,4,5,3,2,2,3,2,5,3,1,5,5,5,1,1,0,1,3,2,1,4,2,2,3,2,1,5,2,4,3,3,2,3,0,5,5,5,0,1,5,5,5,3,5,3,4,5,2,0,4,3,3,5,5,2,4,2,3,4,3,3,2,2,1,5,2,5,4,5,5,5,1,3,4,1,5,2,2,5,2,5,2,4,3,3,3,5,4,2,4,4,3,5,4,5,5,5,1,5,4,4,2,3,4,2,3,5,4,3,1,4,3,3,5,4,4,4,5,3,3,3,4,3,4,3,5,5,5,3,3,2,5,3,3,5,2,4,3,1,0,2,5,2,3,4,5,2,5,3,4,4,2,2,5,1,3,5,4,5,0,5,3,4,4,4,2,2,3,5,5,4,3,3,4,2,3,4,3,2,4,2,4,4,4,2,5,5,4,4,2,1,2,2,3,4,3,1,4,4,5,2,5,3,5,5,4,0,4,5,4,5,4,4,5,4,4,5,1,4,2,4,2,0,2,4,3,3,3,1,2,4,4,4,5,5,5,3,4,4,4,5,5,5,2,3,3,2,3,5,4,4,3,0,3,5,3,2,2,1,1,5,3,4,4,5,5,1,3,5,2,4,2,4,5,3,4,5,4,3,0,2,3,2,1,3,5,2,3,5,5,2,2,4,1,3,4,0,4,4,5,2,4,1,5,4,2,3,2,4,1,2,4,3,4,5,2,1,4,3,3,2,3,4,2,3,0,5,4,5,3,3,0,4,4,5,1,4,2,5,4,1,4,3,3,0,0,3,2,4,1,2,5,5,1,5,1,5,3,4,3,5,5,5,5,4,3,5,5,4,5,3,5,2,5,2,5,5,5,4,3,4,4,4,1,1,5,5,4,4,4,4,5,4,4,1,5,0,5,3,5,4,4,4,4,0,0,4,5,5,4,4,3,4,3,5,5,2,3,3,1,3,5,3,0,1,4,3,0,3,5,1,4,3,5,4,5,5,4,1,5,2,1,5,3,4,4,2,4,1,0,2,0,1,4,4,2,4,2,5,5,1,4,3,4,1,2,3,5,5,4,5,4,3,1,3,5,2,3,2,5,1,3,1,4,5,4,4,4,4,3,0,2,2,0,1,2,0,2,5,4,5,2,1,2,4,3,3,2,0,3,2,2,4,5,2,4,3,2,5,1,4,2,4,4,4,4,2,5,4,5,4,4,3,3,5,5,5,1,4,1,5,2,1,4,3,5,1,3,4,3,4,1,0,3,2,5,3,3,4,5,0,5,5,3,3,5,5,3,5,2,4,3,2,3,5,3,3,4,2,4,5,4,5,5,5,1,5,5,4,2,4,1,5,4,5,3,5,4,4,4,4,3,4,2,5,4,5,5,0,0,2,1,1,2,5,4,3,3,5,4,4,5,4,2,3,2,2,3,4,4,3,5,3,3,5,5,1,1,4,1,2,5,2,2,5,3,3,3,4,4,5,4,5,0,5,5,4,5,5,1,4,0,4,4,3,4,2,4,2,5,3,5,4,4,5,5,3,2,4,5,2,4,1,0,2,4,5,3,3,5,1,5,4,5,3,4,5,2,4,3,5,3,3,5,2,4,3,4,4,4,2,2,4,2,3,4,3,5,3,3,5,4,5,5,5,5,5,0,5,3,2,2,4,4,5,5,4,3,4,1];
    uint48[1953] private _lastClaimed;

    mapping(uint256 => Level) public levels;
    mapping(address => bool) public allowedToBurn;

    event BaseRewardClaimed(uint256 gen1TokenId, uint256 gen2TokenId, uint256 amount);
    event RewardClaimed(uint256 gen1TokenId, uint256 amount);

    constructor(address gen1, address gen2) ERC20("Pencil", "PENCIL") {
        TPTGen1 = TPT(gen1);
        TPTGen2 = TPT(gen2);
        cap = 20000000 * 10 ** 18;

        _setLevel(0, 10, 60, 400);  // Einstein
        _setLevel(1,  9, 50, 360);  // Pythagoras
        _setLevel(2,  8, 40, 320);  // Euclid
        _setLevel(3,  7, 30, 280);  // Archimedes
        _setLevel(4,  6, 20, 240);  // Aristotle
        _setLevel(5,  5, 10, 200);  // Gauss

        _mint(_msgSender(), 20000 * 10 ** 18);
    }

    function burn(address user, uint256 amount) external {
        require(allowedToBurn[msg.sender], "Address does not have permission to burn");
        _burn(user, amount);
    }

    function checkBaseReward(address recipient) external view returns (uint256) {
        uint256 gen1Count = TPTGen1.balanceOf(recipient);
        require(gen1Count > 0, "Wallet must own a Genesis NFT");

        uint256 gen2Count = TPTGen2.balanceOf(recipient);
        require(gen2Count > 0, "Wallet must own a Gen2 NFT");

        uint256[] memory gen2TokenIds = new uint256[](gen2Count);
        uint256 gen2TokenIdsLength;

        for (uint256 i; i < gen2Count; i++) {
            uint256 gen2TokenId = TPTGen2.tokenOfOwnerByIndex(recipient, i);
            if (_gen2BaseClaimed[gen2TokenId] == false) {
                gen2TokenIds[gen2TokenIdsLength] = gen2TokenId;
                gen2TokenIdsLength++;
            }
        }

        require(gen2TokenIdsLength > 0, "No unclaimed Gen2 NFTs available");

        uint256 total;

        for (uint256 i; i < gen1Count; i++) {
            uint256 gen1TokenId = TPTGen1.tokenOfOwnerByIndex(recipient, i);
            if (_gen1BaseClaimed[gen1TokenId] == false && gen2TokenIdsLength > 0) {
                gen2TokenIdsLength--;
                total += levels[_rewardLevel[gen1TokenId]].baseClaim;
            }
        }

        return total;
    }

    function checkBaseRewardByTokenId(uint256 nftId, uint8 gen) external view returns (bool) {
        require(nftId < 1953, "Invalid Token ID");

        if (gen == 2) {
            return _gen1BaseClaimed[nftId];
        }

        return _gen2BaseClaimed[nftId];
    }

    function checkReward(address recipient) external view returns (uint256) {
        require(accumulationActive == true, "Reward claiming not active");

        uint256 gen1Count = TPTGen1.balanceOf(recipient);
        require(gen1Count > 0, "Wallet must own a Genesis NFT");

        uint256 total;
        for (uint256 i; i < gen1Count; i++) {
            uint256 gen1TokenId = TPTGen1.tokenOfOwnerByIndex(recipient, i);
            total += levels[_rewardLevel[gen1TokenId]].dailyReward * (block.timestamp - (_lastClaimed[gen1TokenId] > 0 ? _lastClaimed[gen1TokenId] : start)) / 86400;
        }

        return total;
    }

    function claimBaseReward() external {
        uint256 gen1Count = TPTGen1.balanceOf(msg.sender);
        require(gen1Count > 0, "Wallet must own a Genesis NFT");

        uint256 gen2Count = TPTGen2.balanceOf(msg.sender);
        require(gen2Count > 0, "Wallet must own a Gen2 NFT");

        uint256[] memory gen2TokenIds = new uint256[](gen2Count);
        uint256 gen2TokenIdsLength;

        for (uint256 i; i < gen2Count; i++) {
            uint256 gen2TokenId = TPTGen2.tokenOfOwnerByIndex(msg.sender, i);
            if (_gen2BaseClaimed[gen2TokenId] == false) {
                gen2TokenIds[gen2TokenIdsLength] = gen2TokenId;
                gen2TokenIdsLength++;
            }
        }

        require(gen2TokenIdsLength > 0, "No unclaimed Gen2 NFTs available");

        bool rewarded;
        for (uint256 i; i < gen1Count; i++) {
            uint256 gen1TokenId = TPTGen1.tokenOfOwnerByIndex(msg.sender, i);
            if (_gen1BaseClaimed[gen1TokenId] == false && gen2TokenIdsLength > 0) {
                gen2TokenIdsLength--;
                uint256 amount = levels[_rewardLevel[gen1TokenId]].baseClaim;

                _mint(_msgSender(), amount);
                _gen1BaseClaimed[gen1TokenId] = true;
                _gen2BaseClaimed[gen2TokenIds[gen2TokenIdsLength]] = true;
                rewarded = true;

                emit BaseRewardClaimed(gen1TokenId, gen2TokenIds[gen2TokenIdsLength], amount);
            }
        }

        require(rewarded == true, "No unclaimed Gen1 NFTs available");
    }

    function claimReward() external {
        require(accumulationActive == true, "Reward claiming not active");

        uint8[] memory multipliers = new uint8[](6);
        TokenLengths memory gen1TokenLengths;
        uint256 gen1Count = TPTGen1.balanceOf(msg.sender);
        uint256 gen3Count;
        uint256 total;

        uint256[] memory gen1TokenIdsLevel0 = new uint256[](gen1Count);
        uint256[] memory gen1TokenIdsLevel1 = new uint256[](gen1Count);
        uint256[] memory gen1TokenIdsLevel2 = new uint256[](gen1Count);
        uint256[] memory gen1TokenIdsLevel3 = new uint256[](gen1Count);
        uint256[] memory gen1TokenIdsLevel4 = new uint256[](gen1Count);
        uint256[] memory gen1TokenIdsLevel5 = new uint256[](gen1Count);

        require(gen1Count > 0, "Wallet must own a Genesis NFT");

        if (gen1Count > 40) {
            gen1Count = 40;
        }

        if (accumulationMultiplier == true) {
            gen3Count = TPTGen3.balanceOf(msg.sender);
            if (gen3Count > 0) {
                multipliers = TPTGen3.balancesOfOwnerByRarity(msg.sender);
            }
        }

        for (uint256 i; i < gen1Count; i++) {
            uint256 gen1TokenId = TPTGen1.tokenOfOwnerByIndex(msg.sender, i);

            if (_rewardLevel[gen1TokenId] == 5) {
                gen1TokenIdsLevel5[gen1TokenLengths.level5] = gen1TokenId;
                gen1TokenLengths.level5++;
            }
            else if (_rewardLevel[gen1TokenId] == 4) {
                gen1TokenIdsLevel4[gen1TokenLengths.level4] = gen1TokenId;
                gen1TokenLengths.level4++;
            }
            else if (_rewardLevel[gen1TokenId] == 3) {
                gen1TokenIdsLevel3[gen1TokenLengths.level3] = gen1TokenId;
                gen1TokenLengths.level3++;
            }
            else if (_rewardLevel[gen1TokenId] == 2) {
                gen1TokenIdsLevel2[gen1TokenLengths.level2] = gen1TokenId;
                gen1TokenLengths.level2++;
            }
            else if (_rewardLevel[gen1TokenId] == 1) {
                gen1TokenIdsLevel1[gen1TokenLengths.level1] = gen1TokenId;
                gen1TokenLengths.level1++;
            }
            else {
                gen1TokenIdsLevel0[gen1TokenLengths.level0] = gen1TokenId;
                gen1TokenLengths.level0++;
            }
        }

        if (gen1TokenLengths.level0 > 0) {
            total += _getClaim(gen1TokenIdsLevel0, multipliers, gen1TokenLengths, gen3Count, 0);
        }

        if (gen1TokenLengths.level1 > 0) {
            total += _getClaim(gen1TokenIdsLevel1, multipliers, gen1TokenLengths, gen3Count, 1);
        }

        if (gen1TokenLengths.level2 > 0) {
            total += _getClaim(gen1TokenIdsLevel2, multipliers, gen1TokenLengths, gen3Count, 2);
        }

        if (gen1TokenLengths.level3 > 0) {
            total += _getClaim(gen1TokenIdsLevel3, multipliers, gen1TokenLengths, gen3Count, 3);
        }

        if (gen1TokenLengths.level4 > 0) {
            total += _getClaim(gen1TokenIdsLevel4, multipliers, gen1TokenLengths, gen3Count, 4);
        }

        if (gen1TokenLengths.level5 > 0) {
            total += _getClaim(gen1TokenIdsLevel5, multipliers, gen1TokenLengths, gen3Count, 5);
        }

        _mint(_msgSender(), total);
    }

    function flipState() external onlyOwner {
        accumulationActive = !accumulationActive;
        if (start == 0) {
            start = uint48(block.timestamp);
        }
    }

    function flipStateMultiplier() external onlyOwner {
        accumulationMultiplier = !accumulationMultiplier;
    }

    function _getClaim(uint256[] memory _gen1TokenIds, uint8[] memory _multipliers, TokenLengths memory _gen1TokenLengths, uint256 _gen3Count, uint256 _levelIdx) internal returns (uint256) {
        uint256 total;
        uint256 gen1Count;
        uint256 multiplierIdx;

        if (_levelIdx == 5) {
            multiplierIdx = _gen1TokenLengths.level4 + _gen1TokenLengths.level3 + _gen1TokenLengths.level2 + _gen1TokenLengths.level1 + _gen1TokenLengths.level0;
            gen1Count = _gen1TokenLengths.level5;
        }
        else if (_levelIdx == 4) {
            multiplierIdx = _gen1TokenLengths.level3 + _gen1TokenLengths.level2 + _gen1TokenLengths.level1 + _gen1TokenLengths.level0;
            gen1Count = _gen1TokenLengths.level4;
        }
        else if (_levelIdx == 3) {
            multiplierIdx = _gen1TokenLengths.level2 + _gen1TokenLengths.level1 + _gen1TokenLengths.level0;
            gen1Count = _gen1TokenLengths.level3;
        }
        else if (_levelIdx == 2) {
            multiplierIdx = _gen1TokenLengths.level1 + _gen1TokenLengths.level0;
            gen1Count = _gen1TokenLengths.level2;
        }
        else if (_levelIdx == 1) {
            multiplierIdx = _gen1TokenLengths.level0;
            gen1Count = _gen1TokenLengths.level1;
        }
        else {
            gen1Count = _gen1TokenLengths.level0;
        }

        for (uint256 i; i < gen1Count; i++) {
            uint256 amount = levels[_levelIdx].dailyReward * (block.timestamp - (_lastClaimed[_gen1TokenIds[i]] > 0 ? _lastClaimed[_gen1TokenIds[i]] : start)) / 86400;

            if (multiplierIdx < _gen3Count) {
                for (uint256 l; l < 6; l++) {
                    if (_multipliers[l] > 0) {
                        amount += (amount * uint256(levels[l].multiplier)) / 100;
                        _multipliers[l]--;
                        break;
                    }
                }
                multiplierIdx++;
            }

            total += amount;
            _lastClaimed[_gen1TokenIds[i]] = uint48(block.timestamp);
            emit RewardClaimed(_gen1TokenIds[i], amount);
        }

        return total;
    }

    function _mint(address account, uint256 amount) internal virtual override {
        require(totalSupply() + amount <= cap, "Cap exceeded");
        super._mint(account, amount);
    }

    function setCap(uint192 amount) external onlyOwner {
        require(amount > 0, "Invalid cap");
        cap = amount * 10 ** 18;
    }

    function setAllowedToBurn(address account, bool allowed) public onlyOwner {
        allowedToBurn[account] = allowed;
    }

    function setLevel(uint256 idx, uint64 dailyReward, uint64 multiplier, uint128 baseClaim) external onlyOwner {
        require(idx >= 0 && idx <= 6, "Invalid level index");
        require(baseClaim > 0, "Base claim must be greater than 0");
        require(dailyReward > 0, "Daily reward must be greater than 0");
        require(multiplier >= 0, "Invalid multiplier bonus");
        _setLevel(idx, dailyReward, multiplier, baseClaim);
    }

    function _setLevel(uint256 _idx, uint64 _dailyReward, uint64 _multiplier, uint128 _baseClaim) internal {
        levels[_idx] = Level(_dailyReward * 10 ** 18, _multiplier, _baseClaim * 10 ** 18);
    }

    function setMultiplierAddress(address account) external onlyOwner {
        TPTGen3 = TPTM(account);
        setAllowedToBurn(account, true);
    }
}