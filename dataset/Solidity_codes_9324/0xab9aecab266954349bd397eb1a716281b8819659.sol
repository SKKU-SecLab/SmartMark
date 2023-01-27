
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


interface iGuardianKongz {
    function walletOfOwner(address _owner) external view returns (uint256[] memory);
    function balanceOf(address account) external view returns (uint256);
}

contract GuardianKongzToken is ERC20, Ownable {
    address private GuardianKongz = 0x5E90bB26A930038d7c139cA6a39CB1b5dA8e5f60;

    uint256 public productIndex = 1;

    bool claimPaused = true;

    uint256 constant private GEN_LEG_BASE = 50 ether;
    uint256 constant private GEN_BASE = 30 ether;
    uint256 constant private LEG_BASE = 10 ether;
    uint256 constant private ORI_BASE = 2 ether;

    uint256 private START_TIME = 1643673600; // GMT: Tuesday, 1 February 2022 00:00:00

    mapping(uint256 => uint256) public lastClaim;
    mapping(uint256 => bool) public isLegendary;

      struct Products {
        string name;
        uint256 price;
        uint256 quantity;
        uint256 limit;
    }

    mapping(uint256 => Products) public shopProducts;
    mapping(address => mapping(uint256 => uint256)) public userInventory;

    constructor() ERC20("gkongz", "GKONGZ") {}

    function getBaseRate(uint256 _id) private view returns (uint256) {
        if(_id > 0 && _id < 223) {
            if(isLegendary[_id]) {
                return GEN_LEG_BASE;
            }
            return GEN_BASE;
        }
        if(isLegendary[_id]){
            return LEG_BASE;
        }
        return ORI_BASE;
    }

    function getClaimableRewards(uint256[] memory _id) public view returns (uint256) {
        uint256 rewards = 0;
        uint256 baseRate;

        for (uint256 i = 0; i < _id.length; i++) {
            uint256 id = _id[i];
            baseRate = getBaseRate(id);
            rewards = rewards + (baseRate * (block.timestamp - (lastClaim[id] > START_TIME ? lastClaim[id] : START_TIME)) / 86400);
        }
        return rewards;
    }

    function claimReward() external {
        require(!claimPaused, "Claiming reward has been paused");

        uint256[] memory KongzId = iGuardianKongz(GuardianKongz).walletOfOwner(msg.sender);

        uint256 claimAmount = getClaimableRewards(KongzId);
        _mint(msg.sender, claimAmount);

        for (uint256 j = 0; j < KongzId.length; j++) {
            lastClaim[KongzId[j]] = block.timestamp;
        }
    }

    function flipReward() external onlyOwner {
        claimPaused = !claimPaused;
    }

    function setLegendary(uint256[] memory _tokenId) external onlyOwner {
        for (uint256 i = 0; i < _tokenId.length; i++){
            isLegendary[_tokenId[i]] = true;
        }
    }

    function buy(uint256 _index, uint256 _qty) external {
        uint256 NFTOwned = iGuardianKongz(GuardianKongz).balanceOf(msg.sender);
        uint256 TokenOwned = balanceOf(msg.sender);
        
        require(NFTOwned > 0, "NFT, Not eligible");
        require(TokenOwned > 0, "Token, Not eligible");
        require(TokenOwned >= shopProducts[_index].price, "Insufficient $GKongz!");
        require(shopProducts[_index].quantity >= _qty, "No stock!");
        require(userInventory[msg.sender][_index] + _qty <= shopProducts[_index].limit, "Over limit");

        _burn(msg.sender, shopProducts[_index].price * _qty);
        shopProducts[_index].quantity -= _qty;
        userInventory[msg.sender][_index] += _qty;
    }

    function addNewProduct(string memory _name, uint256 _price, uint256 _quantity, uint256 _limit) external onlyOwner {
        shopProducts[productIndex].name = _name;
        shopProducts[productIndex].price = _price;
        shopProducts[productIndex].quantity = _quantity;
        shopProducts[productIndex].limit = _limit;
        productIndex++;
    }
}