
pragma solidity ^0.8.0;

interface IERC20 {

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
        _approve(owner, spender, _allowances[owner][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {

        address owner = _msgSender();
        uint256 currentAllowance = _allowances[owner][spender];
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
pragma solidity ^0.8.1;


contract GUMP is ERC20, Ownable {

    address private daoAddress = 0xD509AD2af3356cE1Df748cfd5BCA19Ad1b199f7c;
    address public swapPoolAddress;

    mapping(address => bool) public exemptFee;
    mapping(address => address) public inviter;

    address[] public shareHolders;
    mapping(address => bool) private inShareHolders;
    uint256 public shareHolderIndex;

    uint256 public dividendLimite = 1000 * 10 ** 9;


    constructor() ERC20("The Myth of America", "GUMP") {
        uint256 initialSupply = 7200 * 10**8 * 10**9;
        _mint(msg.sender, initialSupply);
        
        exemptFee[msg.sender] = true;
        exemptFee[daoAddress] = true;
        exemptFee[address(this)] = true;
    }

    function decimals() public pure override returns (uint8) {
        return 9;
    }


    function setExemptFee(address account, bool isExempt) public onlyOwner {
        exemptFee[account] = isExempt;
    }

    function setSwapPool(address pool) public onlyOwner {
        swapPoolAddress = pool;
    }

    function setDividendLimite(uint256 limite) public onlyOwner {
        dividendLimite = limite;
    }

    function inviterUpdate(address from, address to, uint256 toBalance) private {
        if (toBalance != 0 || inviter[to] != address(0)) {
            return;
        }

        if (from.code.length == 0 && to.code.length == 0) {
            inviter[to] = from;
        }
    }

    function shareHoldersUpdate(address shareholder) private {
        if ((shareholder == address(this)) || (shareholder == swapPoolAddress)) {
            return;
        }

        if (inShareHolders[shareholder]) {
            return;
        }

        if (IERC20(swapPoolAddress).balanceOf(shareholder) > 0) {
            shareHolders.push(shareholder);
            inShareHolders[shareholder] = true;
        }
    }

    function shareHoldersLength() public view returns(uint256) {
        return shareHolders.length;
    }


    function _transfer(address from, address to, uint256 amount) internal override {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        uint256 toBalance = balanceOf(to);

        if (swapPoolAddress == address(0)) {
            super._transfer(from, to, amount);
            inviterUpdate(from, to, toBalance);
            return;
        }

        if (exemptFee[from] || exemptFee[to] || to == swapPoolAddress) {
            super._transfer(from, to, amount);
        } else {
            uint256 totalFee = amount / 10;
            uint256 arrivalAmount = amount - totalFee;
            super._transfer(from, to, arrivalAmount);

            uint256 burnAmount = totalFee / 10;
            super._burn(from, burnAmount);

            uint256 daoAmount = totalFee / 10;
            super._transfer(from, daoAddress, daoAmount);

            uint256 inviterFee = 0;
            if (from == swapPoolAddress) {
                address cur = to;
                for(uint8 i = 0; i < 7; i++) {
                    cur = inviter[cur];
                    if (cur == address(0)) {
                        break;
                    }

                    if (i == 0) {
                        uint256 tmp = (totalFee / 10) * 3;
                        super._transfer(from, cur, tmp);
                        inviterFee += tmp;
                    } else if (i == 1 || i == 2) {
                        uint256 tmp = totalFee / 10;
                        super._transfer(from, cur, tmp);
                        inviterFee += tmp;
                    } else {
                        uint256 tmp = totalFee / 20;
                        super._transfer(from, cur, tmp);
                        inviterFee += tmp;
                    }
                }
            }

            super._transfer(from, address(this), (totalFee - burnAmount - daoAmount - inviterFee));
        }

        
        IERC20 swapPool = IERC20(swapPoolAddress);
        uint256 poolTotalSupply = swapPool.totalSupply();
        if(balanceOf(address(this)) >= dividendLimite && from != address(this) && shareHolders.length > 0 && poolTotalSupply > 0) {
            for (int256 i = 0; i < 2; i++) {
                if (shareHolderIndex >= shareHolders.length) {
                    shareHolderIndex = 0;
                    break;
                }

                address shareHolder = shareHolders[shareHolderIndex];
                
                uint256 dividend = dividendLimite * swapPool.balanceOf(shareHolder) / poolTotalSupply;

                if (dividend >= 1 * 10**9 && balanceOf(address(this)) >= dividend) {
                    super._transfer(address(this), shareHolder, dividend);
                }

                shareHolderIndex++;
            }
        }

        inviterUpdate(from, to, toBalance);
        shareHoldersUpdate(from);
        shareHoldersUpdate(to);
    }
}