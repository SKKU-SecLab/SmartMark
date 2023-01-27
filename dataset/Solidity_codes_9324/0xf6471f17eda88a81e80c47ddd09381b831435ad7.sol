
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

interface iAdv {
    function walletOfOwner(address address_)
        external
        view
        returns (uint256[] memory);
}

contract Chronos is ERC20, Ownable {
    iAdv public AdvContract;

    uint256 public constant BASE_RATE = 5 ether;
    uint256 public START;
    bool rewardPaused = false;

    mapping(address => uint256) public rewards;
    mapping(address => uint256) public lastUpdate;

    mapping(uint256 => uint256) public stakedAdv;

    struct Perms {
        bool Grantee;
        bool Burner;
        bool Staker;
    }

    mapping(address => Perms) public permsMap;

    event AdvStaked(uint256 advId, uint256 util);

    constructor(address advContract) ERC20("CHRONOS", "CHR") {
        AdvContract = iAdv(advContract);
        START = block.timestamp;
    }

    function updateReward(address from, address to) external {
        require(msg.sender == address(AdvContract));
        if (from != address(0)) {
            rewards[from] += getPendingReward(from);
            lastUpdate[from] = block.timestamp;
        }
        if (to != address(0)) {
            rewards[to] += getPendingReward(to);
            lastUpdate[to] = block.timestamp;
        }
    }

    function withdrawChronos() external {
        require(!rewardPaused, "Claiming Chronos has been paused");
        uint256 calcrew = rewards[msg.sender] + getPendingReward(msg.sender);
        rewards[msg.sender] = 0;
        lastUpdate[msg.sender] = block.timestamp;
        _mint(msg.sender, calcrew);
    }

    function grantChronos(address _address, uint256 _amount) external {
        require(
            permsMap[msg.sender].Grantee,
            "Address does not have permission to distrubute tokens"
        );
        _mint(_address, _amount);
    }

    function burnUnclaimed(address user, uint256 amount) external {
        require(
            permsMap[msg.sender].Burner || msg.sender == address(AdvContract),
            "Address does not have permission to burn"
        );
        require(user != address(0), "ERC20: burn from the zero address");
        uint256 unclaimed = rewards[user] + getPendingReward(user);
        require(
            unclaimed >= amount,
            "ERC20: burn amount exceeds unclaimed balance"
        );
        rewards[user] = unclaimed - amount;
        lastUpdate[user] = block.timestamp;
    }

    function burn(address user, uint256 amount) external {
        require(
            permsMap[msg.sender].Burner || msg.sender == address(AdvContract),
            "Address does not have permission to burn"
        );
        _burn(user, amount);
    }

    function stake(
        address from,
        uint256 advId,
        uint256 util
    ) external {
        require(
            permsMap[msg.sender].Staker || msg.sender == address(AdvContract),
            "Address does not have permission to stake"
        );
        rewards[from] += getPendingReward(from);
        lastUpdate[from] = block.timestamp;
        stakedAdv[advId] = util;
        emit AdvStaked(advId, util);
    }

    function viewStake(uint256 advId) external view returns (uint256) {
        return stakedAdv[advId];
    }

    function getTotalClaimable(address user) external view returns (uint256) {
        return rewards[user] + getPendingReward(user);
    }

    function getPendingReward(address user) internal view returns (uint256) {
        uint256[] memory tokensheld = AdvContract.walletOfOwner(user);
        uint256 accum = 0;
        for (uint256 i; i < tokensheld.length; i++) {
            if (stakedAdv[tokensheld[i]] == 0) {
                if (tokensheld[i] > 5000) {
                    accum += 1;
                } else {
                    accum += 2;
                }
            }
        }

        return
            (accum *
                BASE_RATE *
                (block.timestamp -
                    (lastUpdate[user] >= START ? lastUpdate[user] : START))) /
            172800;
    }

    function setAllowedAddresses(
        address _address,
        bool _grant,
        bool _burn,
        bool _stake
    ) external onlyOwner {
        permsMap[_address].Grantee = _grant;
        permsMap[_address].Burner = _burn;
        permsMap[_address].Staker = _stake;
    }

    function viewPerms(address _address)
        external
        view
        returns (
            bool,
            bool,
            bool
        )
    {
        return (
            permsMap[_address].Grantee,
            permsMap[_address].Burner,
            permsMap[_address].Staker
        );
    }

    function toggleReward() public onlyOwner {
        rewardPaused = !rewardPaused;
    }
}